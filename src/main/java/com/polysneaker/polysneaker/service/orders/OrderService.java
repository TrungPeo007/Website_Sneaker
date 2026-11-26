
package com.polysneaker.polysneaker.service.orders;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.polysneaker.polysneaker.service.Cart.Cart;
import com.polysneaker.polysneaker.service.Cart.CartService;
import com.polysneaker.polysneaker.service.discount.DiscountService;
import com.polysneaker.polysneaker.service.exception.ShopException;
import com.polysneaker.polysneaker.service.mail.EmailService;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.regex.Pattern;

@Service
public class OrderService {

    private static final Logger log =
            LoggerFactory.getLogger(OrderService.class);

    private static final Pattern PHONE =
            Pattern.compile("^(0|\\+84)\\d{9,10}$");

    private final JdbcTemplate jdbc;
    private final CartService cartService;
    private final DiscountService discountService;
    private final EmailService emailService;

    public OrderService(
            JdbcTemplate jdbc,
            CartService cartService,
            DiscountService discountService,
            EmailService emailService
    ) {
        this.jdbc = jdbc;
        this.cartService = cartService;
        this.discountService = discountService;
        this.emailService = emailService;
    }

    /**
     * Điền sẵn thông tin nhận hàng từ hồ sơ tài khoản.
     */
    public Map<String, String> checkoutForm(int accountId) {

        Map<String, Object> a = one(
                "SELECT FullName, Phone, Address "
                        + "FROM dbo.Accounts WHERE AccountId = ?",
                accountId
        );

        Map<String, String> f = new HashMap<>();

        f.put("receiverName",
                a == null ? "" : str(a.get("FullName")));

        f.put("phone",
                a == null ? "" : str(a.get("Phone")));

        f.put("address",
                a == null ? "" : str(a.get("Address")));

        f.put("paymentMethod", "COD");

        return f;
    }

    /**
     * Tạo đơn từ các dòng giỏ hàng đã chọn.
     * Tiền hàng luôn được tính lại từ database.
     */
    @Transactional
    public int placeOrder(
            int accountId,
            Set<Integer> itemIds,
            Map<String, String> p
    ) {

        String name = s(p, "receiverName");
        String phone = s(p, "phone");
        String address = s(p, "address");
        String note = s(p, "note");

        String payment = "COD";

        if (name == null) {
            throw new ShopException("Nhập họ tên người nhận");
        }

        if (name.length() > 100) {
            throw new ShopException("Họ tên tối đa 100 ký tự");
        }

        if (phone == null
                || !PHONE.matcher(phone.replace(" ", "")).matches()) {
            throw new ShopException(
                    "Số điện thoại không hợp lệ (VD: 0901234567)"
            );
        }

        phone = phone.replace(" ", "");

        if (address == null) {
            throw new ShopException("Nhập địa chỉ giao hàng");
        }

        if (address.length() > 300) {
            throw new ShopException("Địa chỉ tối đa 300 ký tự");
        }

        if (note != null && note.length() > 500) {
            note = note.substring(0, 500);
        }

        Cart cart = cartService.load(accountId, itemIds);

        if (cart.items().isEmpty()) {
            throw new ShopException(
                    "Chưa có sản phẩm nào được chọn để thanh toán"
            );
        }

        // Khóa tồn kho theo ProductDetailId để hạn chế deadlock.
        List<Map<String, Object>> items =
                new ArrayList<>(cart.items());

        items.sort(
                Comparator.comparingInt(
                        m -> ((Number) m.get("ProductDetailId")).intValue()
                )
        );

        for (Map<String, Object> it : items) {

            if (((Number) it.get("Sellable")).intValue() == 0) {
                throw new ShopException(
                        label(it)
                                + " hiện không còn bán, hãy xóa khỏi giỏ hàng"
                );
            }
        }

        long subtotal = cart.subtotal();

        Integer orderId = jdbc.queryForObject(
                "INSERT INTO dbo.Orders "
                        + "(AccountId, ReceiverName, Phone, Address, Note, "
                        + "PaymentMethod, Status, TotalAmount) "
                        + "OUTPUT INSERTED.OrderId "
                        + "VALUES (?,?,?,?,?,?, 'PENDING', ?)",

                Integer.class,
                accountId,
                name,
                phone,
                address,
                note,
                payment,
                subtotal
        );

        if (orderId == null) {
            throw new ShopException(
                    "Không tạo được đơn hàng, thử lại sau"
            );
        }

        // Trừ tồn kho và ghi lịch sử.
        for (Map<String, Object> it : items) {

            int pdId = ((Number) it.get("ProductDetailId")).intValue();
            int qty = ((Number) it.get("Quantity")).intValue();

            Integer before = jdbc.queryForObject(
                    "SELECT StockQuantity "
                            + "FROM dbo.ProductDetails WITH (UPDLOCK, ROWLOCK) "
                            + "WHERE ProductDetailId = ?",

                    Integer.class,
                    pdId
            );

            if (before == null || before < qty) {
                throw new ShopException(
                        label(it) + " chỉ còn "
                                + (before == null ? 0 : before)
                                + " đôi, hãy giảm số lượng"
                );
            }

            int n = jdbc.update(
                    "UPDATE dbo.ProductDetails "
                            + "SET StockQuantity = StockQuantity - ?, "
                            + "SoldQuantity = SoldQuantity + ? "
                            + "WHERE ProductDetailId = ? "
                            + "AND StockQuantity >= ?",

                    qty, qty, pdId, qty
            );

            if (n != 1) {
                throw new ShopException(
                        label(it) + " vừa hết hàng, hãy thử lại"
                );
            }

            jdbc.update(
                    "INSERT INTO dbo.OrderDetails "
                            + "(OrderId, ProductDetailId, ProductName, "
                            + "Size, UnitPrice, Quantity) "
                            + "VALUES (?,?,?,?,?,?)",

                    orderId,
                    pdId,
                    it.get("ProductName"),
                    it.get("Size"),
                    it.get("SalePrice"),
                    qty
            );

            jdbc.update(
                    "INSERT INTO dbo.StockMovements "
                            + "(ProductDetailId, MovementType, Quantity, "
                            + "StockBefore, StockAfter, RefType, RefId, "
                            + "Note, CreatedBy) "
                            + "VALUES (?, 'OUT_SALE', ?, ?, ?, 'ORDER', ?, ?, ?)",

                    pdId,
                    -qty,
                    before,
                    before - qty,
                    orderId,
                    "Bán cho đơn #" + orderId,
                    accountId
            );
        }

        // Xử lý voucher / coupon.
        discountService.redeem(
                accountId,
                orderId,
                subtotal,
                p.get("couponCode"),
                p.get("voucherCode")
        );

        // Xóa sản phẩm đã thanh toán khỏi giỏ.
        List<Integer> paidIds = new ArrayList<>();

        for (Map<String, Object> it : items) {
            paidIds.add(
                    ((Number) it.get("CartItemId")).intValue()
            );
        }

        cartService.removeMany(accountId, paidIds);

        // Gửi email xác nhận.
        sendOrderConfirmationEmail(accountId, orderId, subtotal);

        return orderId;
    }

    /**
     * Gửi email xác nhận đơn hàng.
     * Lỗi email không làm ảnh hưởng đến đơn hàng.
     */
    private void sendOrderConfirmationEmail(
            int accountId,
            int orderId,
            long subtotal
    ) {

        try {

            String email = accountEmail(accountId);

            if (email == null || email.isBlank()) {
                return;
            }

            Map<String, Object> order =
                    myOrder(accountId, orderId);

            if (order == null) {
                return;
            }

            order.putIfAbsent("Subtotal", subtotal);

            List<Map<String, Object>> lines =
                    orderLines(orderId);

            emailService.sendOrderSuccess(
                    email,
                    order,
                    lines
            );

        } catch (Exception e) {

            log.error(
                    "Gửi email xác nhận đặt hàng #{} thất bại",
                    orderId,
                    e
            );
        }
    }

    private String accountEmail(int accountId) {

        Map<String, Object> acc = one(
                "SELECT Email FROM dbo.Accounts WHERE AccountId = ?",
                accountId
        );

        return acc == null
                ? null
                : str(acc.get("Email")).trim();
    }

    /**
     * Khách hủy đơn:
     * Chỉ đơn đang chờ xác nhận mới được hủy.
     */
    @Transactional
    public void cancel(int accountId, int orderId) {

        Map<String, Object> o = one(
                "SELECT OrderId, AccountId, Status "
                        + "FROM dbo.Orders WITH (UPDLOCK, ROWLOCK) "
                        + "WHERE OrderId = ?",
                orderId
        );

        if (o == null
                || ((Number) o.get("AccountId")).intValue() != accountId) {

            throw new ShopException("Không tìm thấy đơn hàng");
        }

        if (!"PENDING".equals(str(o.get("Status")))) {
            throw new ShopException(
                    "Chỉ hủy được đơn đang chờ xác nhận"
            );
        }

        jdbc.update(
                "UPDATE dbo.Orders "
                        + "SET Status = 'CANCELLED', UpdatedAt = GETDATE() "
                        + "WHERE OrderId = ?",
                orderId
        );

        List<Map<String, Object>> lines = jdbc.queryForList(
                "SELECT ProductDetailId, Quantity "
                        + "FROM dbo.OrderDetails "
                        + "WHERE OrderId = ? "
                        + "ORDER BY ProductDetailId",
                orderId
        );

        for (Map<String, Object> ln : lines) {

            int pdId =
                    ((Number) ln.get("ProductDetailId")).intValue();

            int qty =
                    ((Number) ln.get("Quantity")).intValue();

            Integer before = jdbc.queryForObject(
                    "SELECT StockQuantity "
                            + "FROM dbo.ProductDetails WITH (UPDLOCK, ROWLOCK) "
                            + "WHERE ProductDetailId = ?",

                    Integer.class,
                    pdId
            );

            int b = before == null ? 0 : before;

            jdbc.update(
                    "UPDATE dbo.ProductDetails "
                            + "SET StockQuantity = StockQuantity + ?, "
                            + "SoldQuantity = CASE "
                            + "WHEN SoldQuantity >= ? "
                            + "THEN SoldQuantity - ? ELSE 0 END "
                            + "WHERE ProductDetailId = ?",

                    qty, qty, qty, pdId
            );

            jdbc.update(
                    "INSERT INTO dbo.StockMovements "
                            + "(ProductDetailId, MovementType, Quantity, "
                            + "StockBefore, StockAfter, RefType, RefId, "
                            + "Note, CreatedBy) "
                            + "VALUES (?, 'CANCEL_RETURN', ?, ?, ?, 'ORDER', ?, ?, ?)",

                    pdId,
                    qty,
                    b,
                    b + qty,
                    orderId,
                    "Hủy đơn #" + orderId,
                    accountId
            );
        }

        discountService.release(orderId);
    }

    /**
     * Danh sách đơn hàng của khách hàng.
     */
    public List<Map<String, Object>> myOrders(int accountId) {

        return jdbc.queryForList(
                "SELECT o.OrderId, o.Status, o.PaymentMethod, "
                        + "o.TotalAmount, o.DiscountAmount, o.CreatedAt, "
                        + "(SELECT ISNULL(SUM(od.Quantity), 0) "
                        + "FROM dbo.OrderDetails od "
                        + "WHERE od.OrderId = o.OrderId) AS TotalItems "
                        + "FROM dbo.Orders o "
                        + "WHERE o.AccountId = ? "
                        + "ORDER BY o.CreatedAt DESC, o.OrderId DESC",

                accountId
        );
    }

    /**
     * Đơn của chính khách này.
     * Trả về null nếu không tồn tại hoặc không thuộc khách hàng.
     */
    public Map<String, Object> myOrder(
            int accountId,
            int orderId
    ) {

        return one(
                "SELECT * FROM dbo.Orders "
                        + "WHERE OrderId = ? AND AccountId = ?",

                orderId,
                accountId
        );
    }

    /**
     * Chi tiết sản phẩm trong đơn hàng.
     */
    public List<Map<String, Object>> orderLines(int orderId) {

        return jdbc.queryForList(
                "SELECT OrderDetailId, ProductName, Size, "
                        + "UnitPrice, Quantity, "
                        + "UnitPrice * Quantity AS LineTotal "
                        + "FROM dbo.OrderDetails "
                        + "WHERE OrderId = ? "
                        + "ORDER BY OrderDetailId",

                orderId
        );
    }

    // =====================================================
    // HELPERS
    // =====================================================

    private Map<String, Object> one(
            String sql,
            Object... args
    ) {

        List<Map<String, Object>> r =
                jdbc.queryForList(sql, args);

        return r.isEmpty() ? null : r.get(0);
    }

    private static String s(
            Map<String, String> p,
            String k
    ) {

        String v = p.get(k);

        return (v == null || v.isBlank())
                ? null
                : v.trim();
    }

    private static String str(Object o) {

        return o == null ? "" : o.toString();
    }

    private static String label(Map<String, Object> it) {

        Object size = it.get("Size");

        String sz = size instanceof BigDecimal bd
                ? bd.stripTrailingZeros().toPlainString()
                : str(size);

        return it.get("ProductName") + " (size " + sz + ")";
    }
}
