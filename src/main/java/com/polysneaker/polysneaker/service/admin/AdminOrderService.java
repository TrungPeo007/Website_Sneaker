package com.polysneaker.polysneaker.service.admin;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.polysneaker.polysneaker.security.CurrentUser;
import com.polysneaker.polysneaker.service.discount.DiscountService;
import com.polysneaker.polysneaker.service.exception.ShopException;
import com.polysneaker.polysneaker.service.mail.EmailService;

import java.math.BigDecimal;
import java.util.List;
import java.util.Map;

/**
 * Quản lý đơn hàng phía admin, theo quy tắc DB v9:
 *  - markPaid(): admin xác nhận khách đã trả tiền -> PaymentStatus = PAID, PaidAt, PaidBy
 *                và TRỪ tồn kho đúng số lượng khách đặt (ghi StockMovements OUT_SALE). Chỉ chạy được 1 lần cho mỗi đơn.
 *                Sau đó gửi email xác nhận thanh toán thành công về email tài khoản đặt hàng.
 *  - advance():  PENDING -> CONFIRMED -> SHIPPING -> COMPLETED (hoàn tất chỉ khi đã thanh toán).
 *  - cancel():   hủy đơn; nếu đơn đã PAID thì cộng tồn kho lại (StockMovements CANCEL_RETURN); trả lượt coupon, mở lại voucher.
 */
@Service
public class AdminOrderService {

    private static final Logger log = LoggerFactory.getLogger(AdminOrderService.class);

    private final JdbcTemplate jdbc;
    private final DiscountService discountService;
    private final EmailService emailService;

    public AdminOrderService(JdbcTemplate jdbc,
                             DiscountService discountService,
                             EmailService emailService) {
        this.jdbc = jdbc;
        this.discountService = discountService;
        this.emailService = emailService;
    }

    // ------------------------------------------------------------ đọc

    public List<Map<String, Object>> list() {
        return jdbc.queryForList("SELECT TOP 500 * FROM dbo.vw_OrderSummary ORDER BY CreatedAt DESC, OrderId DESC");
    }

    public Map<String, Object> find(int orderId) {
        return one("SELECT s.*, pb.Username AS PaidByName FROM dbo.vw_OrderSummary s "
                + "LEFT JOIN dbo.Accounts pb ON pb.AccountId = s.PaidBy WHERE s.OrderId = ?", orderId);
    }

    /** Các dòng của đơn kèm tồn kho hiện tại (để admin biết còn đủ hàng để trừ kho không). */
    public List<Map<String, Object>> lines(int orderId) {
        return jdbc.queryForList("SELECT od.OrderDetailId, od.ProductDetailId, od.ProductName, od.Size, od.UnitPrice, od.Quantity, "
                + "od.UnitPrice * od.Quantity AS LineTotal, pd.StockQuantity "
                + "FROM dbo.OrderDetails od JOIN dbo.ProductDetails pd ON pd.ProductDetailId = od.ProductDetailId "
                + "WHERE od.OrderId = ? ORDER BY od.OrderDetailId", orderId);
    }

    // ------------------------------------------------------------ thanh toán thành công -> trừ kho

    @Transactional
    public void markPaid(CurrentUser admin, int orderId) {
        Map<String, Object> o = lockOrder(orderId);
        if ("CANCELLED".equals(str(o.get("Status")))) throw new ShopException("Đơn đã hủy, không thể xác nhận thanh toán");
        if (!"UNPAID".equals(str(o.get("PaymentStatus")))) throw new ShopException("Đơn này đã được xác nhận thanh toán rồi");

        for (Map<String, Object> ln : orderLinesForStock(orderId)) {
            int pdId = ((Number) ln.get("ProductDetailId")).intValue();
            int qty = ((Number) ln.get("Quantity")).intValue();

            Integer before = jdbc.queryForObject(
                    "SELECT StockQuantity FROM dbo.ProductDetails WITH (UPDLOCK, ROWLOCK) WHERE ProductDetailId = ?",
                    Integer.class, pdId);
            if (before == null || before < qty) {
                throw new ShopException(label(ln) + " chỉ còn " + (before == null ? 0 : before)
                        + " đôi, không đủ " + qty + " đôi khách đặt để trừ kho. Hãy nhập thêm hàng rồi xác nhận lại.");
            }
            int n = jdbc.update("UPDATE dbo.ProductDetails SET StockQuantity = StockQuantity - ?, "
                    + "SoldQuantity = SoldQuantity + ? WHERE ProductDetailId = ? AND StockQuantity >= ?",
                    qty, qty, pdId, qty);
            if (n != 1) throw new ShopException(label(ln) + " vừa thay đổi tồn kho, hãy thử lại");

            jdbc.update("INSERT INTO dbo.StockMovements (ProductDetailId, MovementType, Quantity, StockBefore, StockAfter, "
                    + "RefType, RefId, Note, CreatedBy) VALUES (?, 'OUT_SALE', ?, ?, ?, 'ORDER', ?, ?, ?)",
                    pdId, -qty, before, before - qty, orderId, "Thanh toán đơn #" + orderId, admin.accountId());
        }

        int n = jdbc.update("UPDATE dbo.Orders SET PaymentStatus = 'PAID', PaidAt = GETDATE(), PaidBy = ?, UpdatedAt = GETDATE() "
                + "WHERE OrderId = ? AND PaymentStatus = 'UNPAID'", admin.accountId(), orderId);
        if (n != 1) throw new ShopException("Không cập nhật được trạng thái thanh toán, hãy thử lại");
        audit(admin, "ORDER_PAID", "Đơn #" + orderId, "Thanh toán thành công, đã trừ tồn kho");

        sendPaymentSuccessEmail(orderId);
    }

    private void sendPaymentSuccessEmail(int orderId) {
        try {
            Map<String, Object> orderRow = one("SELECT AccountId FROM dbo.Orders WHERE OrderId = ?", orderId);
            if (orderRow == null || orderRow.get("AccountId") == null) return;

            int accountId = ((Number) orderRow.get("AccountId")).intValue();
            Map<String, Object> acc = one("SELECT Email FROM dbo.Accounts WHERE AccountId = ?", accountId);
            if (acc == null) return;

            String email = str(acc.get("Email")).trim();
            if (email.isBlank()) return;

            Map<String, Object> orderSummary = find(orderId);
            List<Map<String, Object>> orderLines = jdbc.queryForList(
                    "SELECT OrderDetailId, ProductName, Size, UnitPrice, Quantity, UnitPrice * Quantity AS LineTotal "
                    + "FROM dbo.OrderDetails WHERE OrderId = ? ORDER BY OrderDetailId", orderId);
            emailService.sendPaymentSuccess(email, orderSummary != null ? orderSummary : orderRow, orderLines);
        } catch (Exception e) {
            log.error("Gửi email thanh toán thành công đơn #{} thất bại", orderId, e);
        }
    }

    // ------------------------------------------------------------ chuyển trạng thái

    @Transactional
    public void advance(CurrentUser admin, int orderId, String newStatus) {
        Map<String, Object> o = lockOrder(orderId);
        String cur = str(o.get("Status"));
        String next = switch (cur) {
            case "PENDING" -> "CONFIRMED";
            case "CONFIRMED" -> "SHIPPING";
            case "SHIPPING" -> "COMPLETED";
            default -> null;
        };
        if (next == null) throw new ShopException("Đơn ở trạng thái này không thể chuyển tiếp");
        if (!next.equals(newStatus)) throw new ShopException("Chỉ được chuyển sang bước kế tiếp của đơn");
        if ("COMPLETED".equals(next) && !"PAID".equals(str(o.get("PaymentStatus")))) {
            throw new ShopException("Hãy bấm \"Thanh toán thành công\" trước khi hoàn tất đơn");
        }
        jdbc.update("UPDATE dbo.Orders SET Status = ?, UpdatedAt = GETDATE() WHERE OrderId = ?", next, orderId);
        audit(admin, "ORDER_STATUS", "Đơn #" + orderId, cur + " -> " + next);
    }

    // ------------------------------------------------------------ hủy đơn

    @Transactional
    public void cancel(CurrentUser admin, int orderId) {
        Map<String, Object> o = lockOrder(orderId);
        String cur = str(o.get("Status"));
        if ("CANCELLED".equals(cur)) throw new ShopException("Đơn đã được hủy trước đó");
        if ("COMPLETED".equals(cur)) throw new ShopException("Đơn đã hoàn tất, không thể hủy");

        jdbc.update("UPDATE dbo.Orders SET Status = 'CANCELLED', UpdatedAt = GETDATE() WHERE OrderId = ?", orderId);

        boolean paid = "PAID".equals(str(o.get("PaymentStatus")));
        if (paid) {
            // đơn đã trừ kho lúc thanh toán thì cộng lại
            for (Map<String, Object> ln : orderLinesForStock(orderId)) {
                int pdId = ((Number) ln.get("ProductDetailId")).intValue();
                int qty = ((Number) ln.get("Quantity")).intValue();
                Integer before = jdbc.queryForObject(
                        "SELECT StockQuantity FROM dbo.ProductDetails WITH (UPDLOCK, ROWLOCK) WHERE ProductDetailId = ?",
                        Integer.class, pdId);
                int b = before == null ? 0 : before;
                jdbc.update("UPDATE dbo.ProductDetails SET StockQuantity = StockQuantity + ?, "
                        + "SoldQuantity = CASE WHEN SoldQuantity >= ? THEN SoldQuantity - ? ELSE 0 END "
                        + "WHERE ProductDetailId = ?", qty, qty, qty, pdId);
                jdbc.update("INSERT INTO dbo.StockMovements (ProductDetailId, MovementType, Quantity, StockBefore, StockAfter, "
                        + "RefType, RefId, Note, CreatedBy) VALUES (?, 'CANCEL_RETURN', ?, ?, ?, 'ORDER', ?, ?, ?)",
                        pdId, qty, b, b + qty, orderId, "Hủy đơn #" + orderId, admin.accountId());
            }
        }
        discountService.release(orderId);
        audit(admin, "ORDER_CANCEL", "Đơn #" + orderId, paid ? "Đã cộng lại tồn kho" : "Đơn chưa thanh toán, kho không đổi");
    }

    // ------------------------------------------------------------ helper

    private Map<String, Object> lockOrder(int orderId) {
        Map<String, Object> o = one("SELECT OrderId, Status, PaymentStatus FROM dbo.Orders WITH (UPDLOCK, ROWLOCK) "
                + "WHERE OrderId = ?", orderId);
        if (o == null) throw new ShopException("Không tìm thấy đơn hàng");
        return o;
    }

    /** Dòng đơn theo thứ tự ProductDetailId (khóa tồn kho cùng thứ tự để tránh deadlock). */
    private List<Map<String, Object>> orderLinesForStock(int orderId) {
        return jdbc.queryForList("SELECT ProductDetailId, ProductName, Size, Quantity FROM dbo.OrderDetails "
                + "WHERE OrderId = ? ORDER BY ProductDetailId", orderId);
    }

    private void audit(CurrentUser u, String action, String target, String detail) {
        jdbc.update("INSERT INTO dbo.AuditLogs (AccountId, Username, Role, Action, Target, Detail) VALUES (?,?,?,?,?,?)",
                u.accountId(), u.username(), u.role(), action, target, detail);
    }

    private Map<String, Object> one(String sql, Object... args) {
        List<Map<String, Object>> r = jdbc.queryForList(sql, args);
        return r.isEmpty() ? null : r.get(0);
    }

    private static String str(Object o) {
        return o == null ? "" : o.toString();
    }

    private static String label(Map<String, Object> ln) {
        Object size = ln.get("Size");
        String sz = size instanceof BigDecimal bd ? bd.stripTrailingZeros().toPlainString() : str(size);
        return ln.get("ProductName") + " (size " + sz + ")";
    }
}