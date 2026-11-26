package com.polysneaker.polysneaker.service.discount;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import com.polysneaker.polysneaker.security.CurrentUser;

import java.math.BigDecimal;
import java.security.SecureRandom;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;

/**
 * Toàn bộ nghiệp vụ voucher + coupon (JdbcTemplate, SQL Server, script v8).
 *
 * Phía khách:  preview()  -> xem trước số tiền giảm
 *              redeem()   -> gọi TRONG transaction đặt hàng, sau khi đã insert Orders + OrderDetails
 *              release()  -> gọi khi hủy đơn để trả lượt coupon / mở lại voucher
 * Phía admin:  list / save / toggle / delete coupon, issue / revoke voucher.
 */
@Service
public class DiscountService {

    /** Lỗi nghiệp vụ, message hiển thị thẳng cho người dùng. */
    public static class DiscountException extends RuntimeException {
        private static final long serialVersionUID = 1L;

        public DiscountException(String message) {
            super(message);
        }
    }

    /** Kết quả áp mã. Giảm coupon trước, rồi voucher giảm tiếp trên phần còn lại. */
    public record Applied(Long couponId, String couponCode, long couponDiscount,
                          Long voucherId, String voucherCode, long voucherDiscount) {
        public long total() {
            return couponDiscount + voucherDiscount;
        }

        public static Applied none() {
            return new Applied(null, null, 0, null, null, 0);
        }
    }

    private static final DateTimeFormatter INPUT = DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm");
    private static final String ALNUM = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789";
    private final SecureRandom random = new SecureRandom();
    private final JdbcTemplate jdbc;

    public DiscountService(JdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    // =====================================================================
    //  PHÍA KHÁCH
    // =====================================================================

    /** Tính giảm giá (không ghi DB). Ném DiscountException nếu mã không dùng được. */
    public Applied preview(int accountId, long subtotal, String couponCode, String voucherCode) {
        String cc = norm(couponCode);
        String vc = norm(voucherCode);
        if (cc == null && vc == null) return Applied.none();
        if (subtotal <= 0) throw new DiscountException("Giỏ hàng đang trống");

        long running = subtotal;
        Long couponId = null;
        long couponDisc = 0;
        Long voucherId = null;
        long voucherDisc = 0;

        if (cc != null) {
            Map<String, Object> c = one("SELECT * FROM dbo.vw_CouponSummary WHERE Code = ?", cc);
            if (c == null) throw new DiscountException("Mã coupon không tồn tại");
            switch (str(c, "EffectiveStatus")) {
                case "DISABLED" -> throw new DiscountException("Coupon này đã bị tắt");
                case "UPCOMING" -> throw new DiscountException("Coupon chưa tới thời gian áp dụng");
                case "EXPIRED" -> throw new DiscountException("Coupon đã hết hạn");
                case "USED_UP" -> throw new DiscountException("Coupon đã hết lượt sử dụng");
                default -> { }
            }
            long min = lng(c, "MinOrderAmount");
            if (subtotal < min) {
                throw new DiscountException("Đơn tối thiểu " + money(min) + "đ để dùng coupon này");
            }
            Integer used = jdbc.queryForObject(
                    "SELECT COUNT(*) FROM dbo.CouponUsages WHERE CouponId = ? AND AccountId = ?",
                    Integer.class, c.get("CouponId"), accountId);
            if (used != null && used >= lng(c, "PerAccountLimit")) {
                throw new DiscountException("Bạn đã dùng hết số lần cho phép của coupon này");
            }
            couponId = lng(c, "CouponId");
            couponDisc = calc(str(c, "DiscountType"), lng(c, "DiscountValue"), lngOrNull(c, "MaxDiscount"), running);
            running -= couponDisc;
        }

        if (vc != null) {
            Map<String, Object> v = one("SELECT *, CASE WHEN GETDATE() < StartsAt THEN 1 ELSE 0 END AS NotStarted "
                    + "FROM dbo.vw_VoucherDetail WHERE Code = ?", vc);
            if (v == null || lng(v, "AccountId") != accountId) {
                throw new DiscountException("Voucher không tồn tại hoặc không thuộc tài khoản của bạn");
            }
            switch (str(v, "EffectiveStatus")) {
                case "USED" -> throw new DiscountException("Voucher này đã được sử dụng");
                case "REVOKED" -> throw new DiscountException("Voucher này đã bị thu hồi");
                case "EXPIRED" -> throw new DiscountException("Voucher đã hết hạn");
                default -> { }
            }
            if (lng(v, "NotStarted") == 1) throw new DiscountException("Voucher chưa tới thời gian sử dụng");
            long min = lng(v, "MinOrderAmount");
            if (subtotal < min) {
                throw new DiscountException("Đơn tối thiểu " + money(min) + "đ để dùng voucher này");
            }
            voucherId = lng(v, "VoucherId");
            voucherDisc = calc(str(v, "DiscountType"), lng(v, "DiscountValue"), lngOrNull(v, "MaxDiscount"), running);
        }
        return new Applied(couponId, cc, couponDisc, voucherId, vc, voucherDisc);
    }

    /**
     * Gọi NGAY SAU khi đã insert Orders + OrderDetails, trong CÙNG transaction đặt hàng.
     * Trừ lượt coupon, đánh dấu voucher đã dùng, ghi snapshot vào Orders và trừ TotalAmount.
     * subtotal phải là tiền hàng tính từ server (không lấy từ form).
     * Không truyền mã nào thì trả về Applied.none() và không làm gì.
     */
    @Transactional
    public Applied redeem(int accountId, long orderId, long subtotal, String couponCode, String voucherCode) {
        Applied a = preview(accountId, subtotal, couponCode, voucherCode);
        if (a.couponId() == null && a.voucherId() == null) return a;

        if (a.couponId() != null) {
            int n = jdbc.update("UPDATE dbo.Coupons SET UsedCount = UsedCount + 1 "
                    + "WHERE CouponId = ? AND (UsageLimit IS NULL OR UsedCount < UsageLimit)", a.couponId());
            if (n != 1) throw new DiscountException("Coupon vừa hết lượt sử dụng");
            jdbc.update("INSERT INTO dbo.CouponUsages (CouponId, AccountId, OrderId, DiscountAmount) VALUES (?,?,?,?)",
                    a.couponId(), accountId, orderId, a.couponDiscount());
        }
        if (a.voucherId() != null) {
            int n = jdbc.update("UPDATE dbo.Vouchers SET Status = 'USED', UsedOrderId = ?, UsedAt = GETDATE() "
                    + "WHERE VoucherId = ? AND AccountId = ? AND Status = 'UNUSED' AND ExpiresAt >= GETDATE()",
                    orderId, a.voucherId(), accountId);
            if (n != 1) throw new DiscountException("Voucher không còn dùng được");
        }
        int n = jdbc.update("UPDATE dbo.Orders SET DiscountAmount = ?, CouponCode = ?, VoucherCode = ?, "
                        + "TotalAmount = CASE WHEN TotalAmount > ? THEN TotalAmount - ? ELSE 0 END, UpdatedAt = GETDATE() "
                        + "WHERE OrderId = ? AND AccountId = ? AND DiscountAmount = 0",
                a.total(), a.couponCode(), a.voucherCode(), a.total(), a.total(), orderId, accountId);
        if (n != 1) throw new DiscountException("Không áp được mã giảm giá cho đơn hàng");
        return a;
    }

    /** Gọi khi đơn bị HỦY: trả lượt coupon, mở lại voucher. Gọi nhiều lần cũng an toàn. */
    @Transactional
    public void release(long orderId) {
        List<Long> couponIds = jdbc.queryForList(
                "SELECT CouponId FROM dbo.CouponUsages WHERE OrderId = ?", Long.class, orderId);
        for (Long id : couponIds) {
            jdbc.update("UPDATE dbo.Coupons SET UsedCount = CASE WHEN UsedCount > 0 THEN UsedCount - 1 ELSE 0 END "
                    + "WHERE CouponId = ?", id);
        }
        jdbc.update("DELETE FROM dbo.CouponUsages WHERE OrderId = ?", orderId);
        jdbc.update("UPDATE dbo.Vouchers SET Status = 'UNUSED', UsedOrderId = NULL, UsedAt = NULL "
                + "WHERE UsedOrderId = ? AND Status = 'USED'", orderId);
    }

    public List<Map<String, Object>> myVouchers(int accountId) {
        return jdbc.queryForList("SELECT * FROM dbo.vw_VoucherDetail WHERE AccountId = ? "
                + "ORDER BY CASE WHEN EffectiveStatus = 'UNUSED' THEN 0 ELSE 1 END, ExpiresAt", accountId);
    }

    // =====================================================================
    //  PHÍA ADMIN - COUPON
    // =====================================================================

    public List<Map<String, Object>> listCoupons(String q, String status) {
        StringBuilder sql = new StringBuilder("SELECT * FROM dbo.vw_CouponSummary WHERE 1 = 1");
        List<Object> args = new ArrayList<>();
        if (q != null && !q.isBlank()) {
            sql.append(" AND (Code LIKE ? OR Title LIKE ?)");
            String k = "%" + q.trim() + "%";
            args.add(k);
            args.add(k);
        }
        if (status != null && !status.isBlank()) {
            sql.append(" AND EffectiveStatus = ?");
            args.add(status);
        }
        sql.append(" ORDER BY CreatedAt DESC");
        return jdbc.queryForList(sql.toString(), args.toArray());
    }

    public Map<String, String> newCouponForm() {
        Map<String, String> f = new HashMap<>();
        f.put("type", "PERCENT");
        f.put("minOrder", "0");
        f.put("perAccountLimit", "1");
        f.put("isActive", "on");
        return f;
    }

    /** Dữ liệu đổ vào form sửa coupon. Trả null nếu không có. */
    public Map<String, String> couponForm(int id) {
        Map<String, Object> c = one("SELECT * FROM dbo.Coupons WHERE CouponId = ?", id);
        if (c == null) return null;
        Map<String, String> f = new HashMap<>();
        f.put("id", String.valueOf(id));
        f.put("code", plain(c, "Code"));
        f.put("title", plain(c, "Title"));
        f.put("description", plain(c, "Description"));
        f.put("type", plain(c, "DiscountType"));
        f.put("value", plain(c, "DiscountValue"));
        f.put("maxDiscount", plain(c, "MaxDiscount"));
        f.put("minOrder", plain(c, "MinOrderAmount"));
        f.put("usageLimit", plain(c, "UsageLimit"));
        f.put("perAccountLimit", plain(c, "PerAccountLimit"));
        f.put("startsAt", dt(c, "StartsAt"));
        f.put("expiresAt", dt(c, "ExpiresAt"));
        if (Boolean.TRUE.equals(c.get("IsActive"))) f.put("isActive", "on");
        return f;
    }

    @Transactional
    public void saveCoupon(Map<String, String> p, CurrentUser u) {
        Integer id = (p.get("id") == null || p.get("id").isBlank()) ? null : Integer.valueOf(p.get("id").trim());
        String title = s(p, "title");
        String desc = s(p, "description");
        String type = s(p, "type");
        Long value = l(p, "value", "Mức giảm");
        Long max = l(p, "maxDiscount", "Giảm tối đa");
        Long minObj = l(p, "minOrder", "Đơn tối thiểu");
        long min = minObj == null ? 0 : minObj;
        Long limit = l(p, "usageLimit", "Tổng lượt dùng");
        Long perObj = l(p, "perAccountLimit", "Lượt mỗi tài khoản");
        long per = perObj == null ? 1 : perObj;
        Timestamp start = ts(p, "startsAt", "Ngày bắt đầu");
        Timestamp end = ts(p, "expiresAt", "Ngày hết hạn");
        boolean active = p.get("isActive") != null;

        if (title == null) throw new DiscountException("Nhập tiêu đề coupon");
        if (start == null) start = new Timestamp(System.currentTimeMillis() - 60_000);
        validateRule(type, value, max, min, start, end);
        if ("AMOUNT".equals(type)) max = null;
        if (limit != null && limit <= 0) throw new DiscountException("Tổng lượt dùng phải lớn hơn 0 (để trống nếu không giới hạn)");
        if (per < 1) throw new DiscountException("Lượt mỗi tài khoản phải từ 1 trở lên");

        if (id == null) {
            String code = norm(p.get("code"));
            checkCode(code);
            jdbc.update("INSERT INTO dbo.Coupons (Code, Title, Description, DiscountType, DiscountValue, MaxDiscount, "
                            + "MinOrderAmount, UsageLimit, PerAccountLimit, StartsAt, ExpiresAt, IsActive, CreatedBy) "
                            + "VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?)",
                    code, title, desc, type, value, max, min, limit, per, start, end, active, u.accountId());
            audit(u, "COUPON_CREATE", code, title);
        } else {
            Map<String, Object> cur = one("SELECT Code, UsedCount FROM dbo.Coupons WHERE CouponId = ?", id);
            if (cur == null) throw new DiscountException("Không tìm thấy coupon");
            if (limit != null && limit < lng(cur, "UsedCount")) {
                throw new DiscountException("Tổng lượt dùng không được nhỏ hơn số lượt đã dùng (" + lng(cur, "UsedCount") + ")");
            }
            jdbc.update("UPDATE dbo.Coupons SET Title = ?, Description = ?, DiscountType = ?, DiscountValue = ?, "
                            + "MaxDiscount = ?, MinOrderAmount = ?, UsageLimit = ?, PerAccountLimit = ?, StartsAt = ?, "
                            + "ExpiresAt = ?, IsActive = ?, UpdatedAt = GETDATE() WHERE CouponId = ?",
                    title, desc, type, value, max, min, limit, per, start, end, active, id);
            audit(u, "COUPON_UPDATE", str(cur, "Code"), title);
        }
    }

    @Transactional
    public void toggleCoupon(int id, CurrentUser u) {
        int n = jdbc.update("UPDATE dbo.Coupons SET IsActive = CASE WHEN IsActive = 1 THEN 0 ELSE 1 END, "
                + "UpdatedAt = GETDATE() WHERE CouponId = ?", id);
        if (n != 1) throw new DiscountException("Không tìm thấy coupon");
        audit(u, "COUPON_TOGGLE", "CouponId=" + id, null);
    }

    @Transactional
    public void deleteCoupon(int id, CurrentUser u) {
        Integer used = jdbc.queryForObject("SELECT COUNT(*) FROM dbo.CouponUsages WHERE CouponId = ?", Integer.class, id);
        if (used != null && used > 0) {
            throw new DiscountException("Coupon đã được dùng, hãy tắt thay vì xóa");
        }
        int n = jdbc.update("DELETE FROM dbo.Coupons WHERE CouponId = ?", id);
        if (n != 1) throw new DiscountException("Không tìm thấy coupon");
        audit(u, "COUPON_DELETE", "CouponId=" + id, null);
    }

    public List<Map<String, Object>> couponUsages(int couponId) {
        return jdbc.queryForList("SELECT cu.UsageId, cu.OrderId, cu.DiscountAmount, cu.UsedAt, a.Username "
                + "FROM dbo.CouponUsages cu JOIN dbo.Accounts a ON a.AccountId = cu.AccountId "
                + "WHERE cu.CouponId = ? ORDER BY cu.UsedAt DESC", couponId);
    }

    public Map<String, Object> couponInfo(int id) {
        return one("SELECT * FROM dbo.vw_CouponSummary WHERE CouponId = ?", id);
    }

    // =====================================================================
    //  PHÍA ADMIN - VOUCHER
    // =====================================================================

    public List<Map<String, Object>> listVouchers(String q, String status) {
        StringBuilder sql = new StringBuilder("SELECT * FROM dbo.vw_VoucherDetail WHERE 1 = 1");
        List<Object> args = new ArrayList<>();
        if (q != null && !q.isBlank()) {
            sql.append(" AND (Code LIKE ? OR OwnerUsername LIKE ? OR Title LIKE ?)");
            String k = "%" + q.trim() + "%";
            args.add(k);
            args.add(k);
            args.add(k);
        }
        if (status != null && !status.isBlank()) {
            sql.append(" AND EffectiveStatus = ?");
            args.add(status);
        }
        sql.append(" ORDER BY CreatedAt DESC");
        return jdbc.queryForList(sql.toString(), args.toArray());
    }

    public Map<String, String> newVoucherForm() {
        Map<String, String> f = new HashMap<>();
        f.put("type", "AMOUNT");
        f.put("minOrder", "0");
        return f;
    }

    /** Cấp voucher cho 1 khách (theo username). Để trống code thì hệ thống tự sinh. */
    @Transactional
    public void issueVoucher(Map<String, String> p, CurrentUser u) {
        String username = s(p, "username");
        String title = s(p, "title");
        String reason = s(p, "reason");
        String type = s(p, "type");
        Long value = l(p, "value", "Mức giảm");
        Long max = l(p, "maxDiscount", "Giảm tối đa");
        Long minObj = l(p, "minOrder", "Đơn tối thiểu");
        long min = minObj == null ? 0 : minObj;
        Timestamp start = ts(p, "startsAt", "Ngày bắt đầu");
        Timestamp end = ts(p, "expiresAt", "Ngày hết hạn");

        if (username == null) throw new DiscountException("Nhập username của khách");
        if (title == null) throw new DiscountException("Nhập tiêu đề voucher");
        if (end == null) throw new DiscountException("Voucher phải có ngày hết hạn");
        if (start == null) start = new Timestamp(System.currentTimeMillis() - 60_000);
        validateRule(type, value, max, min, start, end);
        if ("AMOUNT".equals(type)) max = null;

        Map<String, Object> acc = one("SELECT AccountId, Role, IsActive FROM dbo.Accounts WHERE Username = ?", username);
        if (acc == null) throw new DiscountException("Không có tài khoản '" + username + "'");
        if (!"CUSTOMER".equals(str(acc, "Role"))) throw new DiscountException("Chỉ cấp voucher cho tài khoản khách hàng");
        if (!Boolean.TRUE.equals(acc.get("IsActive"))) throw new DiscountException("Tài khoản này đang bị khóa");

        String code = norm(p.get("code"));
        if (code == null) {
            do {
                code = "VC-" + randomPart(8);
            } while (codeTaken(code));
        } else {
            checkCode(code);
        }
        jdbc.update("INSERT INTO dbo.Vouchers (Code, AccountId, Title, Reason, DiscountType, DiscountValue, MaxDiscount, "
                        + "MinOrderAmount, StartsAt, ExpiresAt, IssuedBy) VALUES (?,?,?,?,?,?,?,?,?,?,?)",
                code, acc.get("AccountId"), title, reason, type, value, max, min, start, end, u.accountId());
        audit(u, "VOUCHER_ISSUE", code, "Cấp cho " + username + ": " + title);
    }

    @Transactional
    public void revokeVoucher(int id, CurrentUser u) {
        int n = jdbc.update("UPDATE dbo.Vouchers SET Status = 'REVOKED' WHERE VoucherId = ? AND Status = 'UNUSED'", id);
        if (n != 1) throw new DiscountException("Chỉ thu hồi được voucher chưa dùng");
        audit(u, "VOUCHER_REVOKE", "VoucherId=" + id, null);
    }

    // =====================================================================
    //  HELPER
    // =====================================================================

    private void audit(CurrentUser u, String action, String target, String detail) {
        jdbc.update("INSERT INTO dbo.AuditLogs (AccountId, Username, Role, Action, Target, Detail) VALUES (?,?,?,?,?,?)",
                u.accountId(), u.username(), u.role(), action, target,
                detail != null && detail.length() > 1000 ? detail.substring(0, 1000) : detail);
    }

    static long calc(String type, long value, Long max, long base) {
        long d = "PERCENT".equals(type) ? base * value / 100 : value;
        if ("PERCENT".equals(type) && max != null && d > max) d = max;
        return Math.max(0, Math.min(d, base));
    }

    private static void validateRule(String type, Long value, Long max, long min, Timestamp start, Timestamp end) {
        if (!"PERCENT".equals(type) && !"AMOUNT".equals(type)) throw new DiscountException("Chọn loại giảm giá");
        if (value == null) throw new DiscountException("Nhập mức giảm");
        if ("PERCENT".equals(type) && (value < 1 || value > 100)) throw new DiscountException("Giảm theo % phải từ 1 đến 100");
        if ("AMOUNT".equals(type) && value <= 0) throw new DiscountException("Số tiền giảm phải lớn hơn 0");
        if (max != null && max <= 0) throw new DiscountException("Giảm tối đa phải lớn hơn 0 (để trống nếu không chặn)");
        if (min < 0) throw new DiscountException("Đơn tối thiểu không được âm");
        if (end != null && !end.after(start)) throw new DiscountException("Ngày hết hạn phải sau ngày bắt đầu");
    }

    private void checkCode(String code) {
        if (code == null) throw new DiscountException("Nhập mã");
        if (!code.matches("[A-Z0-9_-]{3,30}")) {
            throw new DiscountException("Mã chỉ gồm chữ, số, gạch ngang, gạch dưới (3-30 ký tự, không dấu, không khoảng trắng)");
        }
        if (codeTaken(code)) throw new DiscountException("Mã '" + code + "' đã tồn tại (coupon hoặc voucher)");
    }

    private boolean codeTaken(String code) {
        Integer n = jdbc.queryForObject("SELECT (SELECT COUNT(*) FROM dbo.Coupons WHERE Code = ?) "
                + "+ (SELECT COUNT(*) FROM dbo.Vouchers WHERE Code = ?)", Integer.class, code, code);
        return n != null && n > 0;
    }

    private String randomPart(int len) {
        StringBuilder sb = new StringBuilder(len);
        for (int i = 0; i < len; i++) sb.append(ALNUM.charAt(random.nextInt(ALNUM.length())));
        return sb.toString();
    }

    private Map<String, Object> one(String sql, Object... args) {
        List<Map<String, Object>> r = jdbc.queryForList(sql, args);
        return r.isEmpty() ? null : r.get(0);
    }

    private static String norm(String code) {
        return (code == null || code.isBlank()) ? null : code.trim().toUpperCase(Locale.ROOT);
    }

    private static String s(Map<String, String> p, String k) {
        String v = p.get(k);
        return (v == null || v.isBlank()) ? null : v.trim();
    }

    private static Long l(Map<String, String> p, String k, String label) {
        String v = s(p, k);
        if (v == null) return null;
        try {
            return Long.parseLong(v.replace(".", "").replace(",", ""));
        } catch (NumberFormatException e) {
            throw new DiscountException(label + " không hợp lệ");
        }
    }

    private static Timestamp ts(Map<String, String> p, String k, String label) {
        String v = s(p, k);
        if (v == null) return null;
        try {
            return Timestamp.valueOf(LocalDateTime.parse(v.substring(0, Math.min(v.length(), 16)), INPUT));
        } catch (Exception e) {
            throw new DiscountException(label + " không hợp lệ");
        }
    }

    private static String str(Map<String, Object> m, String k) {
        return String.valueOf(m.get(k));
    }

    private static long lng(Map<String, Object> m, String k) {
        return ((Number) m.get(k)).longValue();
    }

    private static Long lngOrNull(Map<String, Object> m, String k) {
        Object o = m.get(k);
        return o == null ? null : ((Number) o).longValue();
    }

    private static String plain(Map<String, Object> m, String k) {
        Object o = m.get(k);
        if (o == null) return "";
        return o instanceof BigDecimal bd ? bd.toPlainString() : o.toString();
    }

    private static String dt(Map<String, Object> m, String k) {
        Object o = m.get(k);
        return o == null ? "" : ((Timestamp) o).toLocalDateTime().format(INPUT);
    }

    private static String money(long v) {
        return String.format("%,d", v).replace(',', '.');
    }
}