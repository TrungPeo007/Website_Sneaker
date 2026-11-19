package com.polysneaker.polysneaker.service;

import jakarta.mail.MessagingException;
import jakarta.mail.internet.MimeMessage;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.mail.MailPreparationException;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.stereotype.Service;

import java.io.UnsupportedEncodingException;
import java.math.BigDecimal;
import java.nio.charset.StandardCharsets;
import java.sql.Timestamp;
import java.text.NumberFormat;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.Locale;
import java.util.Map;

@Service
public class EmailService {

    private static final String COMPANY =
            "Công ty cổ phần giày Poly Sneaker";

    private static final Locale VI_LOCALE =
            new Locale("vi", "VN");

    private static final DateTimeFormatter DATE_FORMAT =
            DateTimeFormatter.ofPattern("HH:mm dd/MM/yyyy");

    private final JavaMailSender mailSender;

    @Value("${app.mail.from}")
    private String from;

    public EmailService(JavaMailSender mailSender) {
        this.mailSender = mailSender;
    }

    // =====================================================
    // EMAIL 1: REGISTER OTP
    // =====================================================

    public void sendRegisterCode(
            String to,
            String username,
            String code
    ) {
        if (isBlank(to) || isBlank(code)) {
            return;
        }

        String html = wrap(
                "<h2 style=\"margin:0 0 12px\">Xin chào "
                        + escape(username) + ",</h2>"

                + "<p>" + COMPANY
                        + " gửi bạn mã OTP như sau:</p>"

                + "<p style=\"font-size:32px;font-weight:800;"
                        + "letter-spacing:8px;margin:16px 0\">"
                        + escape(code) + "</p>"

                + "<p>Mã có hiệu lực trong <b>10 phút</b>. "
                        + "Vui lòng không chia sẻ mã này cho bất kỳ ai. "
                        + "Nếu bạn không đăng ký, hãy bỏ qua email này.</p>"
        );

        send(
                to,
                "[PolySneaker] Mã OTP xác thực đăng ký: " + code,
                html
        );
    }

    // =====================================================
    // EMAIL 2: REGISTER SUCCESS
    // =====================================================

    public void sendRegisterSuccess(
            String to,
            String username
    ) {
        if (isBlank(to)) {
            return;
        }

        String time = LocalDateTime.now().format(DATE_FORMAT);

        String html = wrap(
                "<h2 style=\"margin:0 0 12px\">"
                        + "Đăng ký tài khoản thành công</h2>"

                + "<p>" + COMPANY
                        + " xin xác nhận quý khách đã đăng ký tài khoản thành công:</p>"

                + "<table style=\"border-collapse:collapse;"
                        + "width:100%;margin:12px 0\">"

                + row(
                        "Tên đăng nhập",
                        "<b>" + escape(username) + "</b>"
                )

                + row("Email", escape(to))

                + row("Thời gian đăng ký", time)

                + "</table>"

                + "<p style=\"background:#fff7ed;"
                        + "border:1px solid #fed7aa;"
                        + "border-radius:8px;padding:12px;margin:16px 0\">"

                + "<b>Quý khách vui lòng tải file Excel thông tin tài khoản</b> "
                + "ở trang vừa hiển thị sau khi xác thực OTP "
                + "để xem lại tên đăng nhập và mật khẩu đã đặt. "
                + "Hãy cất giữ file cẩn thận và không chia sẻ cho người khác."
                + "</p>"

                + "<p style=\"font-size:13px;color:#666\">"
                + "Nếu không phải quý khách đăng ký, "
                + "vui lòng liên hệ hotline 1900 8899.</p>"
        );

        send(
                to,
                "[PolySneaker] Xác nhận đăng ký tài khoản thành công",
                html
        );
    }

    // =====================================================
    // EMAIL 3: ORDER SUCCESS
    // =====================================================

    public void sendOrderSuccess(
            String to,
            Map<String, Object> order,
            List<Map<String, Object>> lines
    ) {
        if (isBlank(to) || order == null) {
            return;
        }

        // Order information

        String orderId = str(firstNonNull(
                order.get("OrderId"),
                order.get("orderId")
        ));

        String receiverName = str(firstNonNull(
                order.get("ReceiverName"),
                order.get("receiverName")
        ));

        String phone = str(firstNonNull(
                order.get("Phone"),
                order.get("phone")
        ));

        String address = str(firstNonNull(
                order.get("Address"),
                order.get("address")
        ));

        String paymentMethod = str(firstNonNull(
                order.get("PaymentMethod"),
                order.get("paymentMethod"),
                "COD"
        ));

        String note = str(firstNonNull(
                order.get("Note"),
                order.get("note")
        ));

        // Product details + summary

        String itemsRows = buildItemsRows(lines);
        String summaryRows = buildSummaryRows(order);

        // Complete email HTML

        String html = wrap(
                "<h2 style=\"margin:0 0 10px\">"
                        + "Đặt hàng thành công #"
                        + escape(orderId)
                        + "</h2>"

                + "<p>Xin chào <b>"
                        + escape(receiverName)
                        + "</b>, "
                        + COMPANY
                        + " đã nhận đơn hàng của bạn và đang chuẩn bị xử lý.</p>"

                + "<table style=\"border-collapse:collapse;"
                        + "width:100%;margin:12px 0;font-size:14px\">"

                + row(
                        "Mã đơn hàng",
                        "<b>#" + escape(orderId) + "</b>"
                )

                + row("Người nhận", escape(receiverName))

                + row("Số điện thoại", escape(phone))

                + row("Địa chỉ giao hàng", escape(address))

                + row("Thanh toán", escape(paymentMethod))

                + (!note.isBlank()
                        ? row("Ghi chú", escape(note))
                        : "")

                + "</table>"

                + itemsTable(itemsRows)

                + "<table style=\"border-collapse:collapse;"
                        + "width:100%;margin-top:12px;font-size:14px\">"

                + summaryRows

                + "</table>"

                + "<p style=\"font-size:13px;color:#666;"
                        + "margin-top:16px\">"
                        + "Cảm ơn bạn đã mua sắm tại PolySneaker!</p>"
        );

        send(
                to,
                "[PolySneaker] Xác nhận đơn hàng #" + orderId,
                html
        );
    }

    // =====================================================
    // EMAIL 4: PAYMENT SUCCESS (admin bấm "Thanh toán thành công")
    // =====================================================

    public void sendPaymentSuccess(
            String to,
            Map<String, Object> order,
            List<Map<String, Object>> lines
    ) {
        if (isBlank(to) || order == null) {
            return;
        }

        String orderId = str(firstNonNull(
                order.get("OrderId"),
                order.get("orderId")
        ));

        String receiverName = str(firstNonNull(
                order.get("ReceiverName"),
                order.get("receiverName")
        ));

        String phone = str(firstNonNull(
                order.get("Phone"),
                order.get("phone")
        ));

        String address = str(firstNonNull(
                order.get("Address"),
                order.get("address")
        ));

        String paymentMethod = str(firstNonNull(
                order.get("PaymentMethod"),
                order.get("paymentMethod"),
                "COD"
        ));

        String paidTime = formatDateTime(firstNonNull(
                order.get("PaidAt"),
                order.get("paidAt")
        ));

        String html = wrap(
                "<h2 style=\"margin:0 0 10px\">"
                        + "Thanh toán thành công đơn hàng #"
                        + escape(orderId)
                        + "</h2>"

                + "<p>Xin chào <b>"
                        + escape(receiverName)
                        + "</b>, "
                        + COMPANY
                        + " xác nhận đã nhận được thanh toán cho đơn hàng của bạn.</p>"

                + "<table style=\"border-collapse:collapse;"
                        + "width:100%;margin:12px 0;font-size:14px\">"

                + row(
                        "Mã đơn hàng",
                        "<b>#" + escape(orderId) + "</b>"
                )

                + row("Trạng thái thanh toán", "<b style=\"color:#16a34a\">Đã thanh toán</b>")

                + row("Thời gian thanh toán", escape(paidTime))

                + row("Hình thức thanh toán", escape(paymentMethod))

                + row("Người nhận", escape(receiverName))

                + row("Số điện thoại", escape(phone))

                + row("Địa chỉ giao hàng", escape(address))

                + "</table>"

                + itemsTable(buildItemsRows(lines))

                + "<table style=\"border-collapse:collapse;"
                        + "width:100%;margin-top:12px;font-size:14px\">"

                + buildSummaryRows(order)

                + "</table>"

                + "<p style=\"font-size:13px;color:#666;"
                        + "margin-top:16px\">"
                        + "Đơn hàng sẽ sớm được chuyển cho đơn vị vận chuyển. "
                        + "Cảm ơn bạn đã mua sắm tại PolySneaker!</p>"
        );

        send(
                to,
                "[PolySneaker] Thanh toán thành công đơn hàng #" + orderId,
                html
        );
    }

    // =====================================================
    // PRIVATE HELPER METHODS
    // =====================================================

    /**
     * Send HTML email.
     */
    private void send(
            String to,
            String subject,
            String html
    ) {
        if (isBlank(to)) {
            return;
        }

        try {

            MimeMessage msg = mailSender.createMimeMessage();

            MimeMessageHelper helper = new MimeMessageHelper(
                    msg,
                    false,
                    StandardCharsets.UTF_8.name()
            );

            helper.setFrom(from, "PolySneaker");
            helper.setTo(to);
            helper.setSubject(subject);
            helper.setText(html, true);

            mailSender.send(msg);

        } catch (MessagingException | UnsupportedEncodingException e) {

            throw new MailPreparationException(e);
        }
    }

    /**
     * Build the product rows (<tr>...) of the order.
     */
    private String buildItemsRows(List<Map<String, Object>> lines) {

        StringBuilder itemsRows = new StringBuilder();

        if (lines == null) {
            return "";
        }

        for (Map<String, Object> ln : lines) {

            if (ln == null) {
                continue;
            }

            String prodName = escape(str(firstNonNull(
                    ln.get("ProductName"),
                    ln.get("productName"),
                    "Sản phẩm"
            )));

            String size = escape(formatSize(firstNonNull(
                    ln.get("Size"),
                    ln.get("size")
            )));

            int qty = toInt(firstNonNull(
                    ln.get("Quantity"),
                    ln.get("quantity"),
                    0
            ));

            BigDecimal unitPrice = toMoney(firstNonNull(
                    ln.get("UnitPrice"),
                    ln.get("unitPrice"),
                    0
            ));

            Object lineTotalRaw = firstNonNull(
                    ln.get("LineTotal"),
                    ln.get("lineTotal")
            );

            BigDecimal lineTotal;

            if (lineTotalRaw != null) {
                lineTotal = toMoney(lineTotalRaw);
            } else {
                lineTotal = unitPrice.multiply(
                        BigDecimal.valueOf(qty)
                );
            }

            itemsRows.append("<tr>")

                    .append("<td style=\"padding:8px;"
                            + "border-bottom:1px solid #eee\">")

                    .append("<b>")
                    .append(prodName)
                    .append("</b>")

                    .append(size.isEmpty()
                            ? ""
                            : "<br><small style=\"color:#666\">"
                                    + "Size: " + size
                                    + "</small>")

                    .append("</td>")

                    .append("<td style=\"padding:8px;"
                            + "border-bottom:1px solid #eee;"
                            + "text-align:center\">")
                    .append(qty)
                    .append("</td>")

                    .append("<td style=\"padding:8px;"
                            + "border-bottom:1px solid #eee;"
                            + "text-align:right\">")
                    .append(formatVnd(unitPrice))
                    .append("</td>")

                    .append("<td style=\"padding:8px;"
                            + "border-bottom:1px solid #eee;"
                            + "text-align:right\">")
                    .append("<b>")
                    .append(formatVnd(lineTotal))
                    .append("</b>")
                    .append("</td>")

                    .append("</tr>");
        }

        return itemsRows.toString();
    }

    /**
     * Build the summary rows (subtotal, discount, total).
     */
    private String buildSummaryRows(Map<String, Object> order) {

        Object subtotalObj = firstNonNull(
                order.get("Subtotal"),
                order.get("subtotal")
        );

        Object discountObj = firstNonNull(
                order.get("DiscountAmount"),
                order.get("discountAmount"),
                BigDecimal.ZERO
        );

        Object totalObj = firstNonNull(
                order.get("TotalAmount"),
                order.get("totalAmount"),
                BigDecimal.ZERO
        );

        StringBuilder summaryRows = new StringBuilder();

        if (subtotalObj != null) {

            summaryRows.append(
                    row(
                            "Tạm tính",
                            formatVnd(toMoney(subtotalObj))
                    )
            );
        }

        BigDecimal discount = toMoney(discountObj);

        if (discount.compareTo(BigDecimal.ZERO) > 0) {

            summaryRows.append(
                    row(
                            "Giảm giá",
                            "-" + formatVnd(discount)
                    )
            );
        }

        summaryRows.append("<tr>")

                .append("<td style=\"padding:10px 8px;"
                        + "border-top:2px solid #222;"
                        + "font-weight:700\">")
                .append("Tổng thanh toán")
                .append("</td>")

                .append("<td style=\"padding:10px 8px;"
                        + "border-top:2px solid #222;"
                        + "text-align:right;font-weight:800;"
                        + "color:#f26b1d;font-size:16px\">")

                .append(formatVnd(toMoney(totalObj)))

                .append("</td></tr>");

        return summaryRows.toString();
    }

    /**
     * Wrap the product rows into a full table with header.
     */
    private String itemsTable(String itemsRows) {

        return "<h3 style=\"margin:16px 0 8px;font-size:15px\">"
                + "Chi tiết sản phẩm</h3>"

                + "<table style=\"border-collapse:collapse;"
                + "width:100%;font-size:13.5px\">"

                + "<thead><tr style=\"background:#f9fafb;"
                + "border-bottom:1px solid #e5e7eb\">"

                + "<th style=\"padding:8px;text-align:left\">"
                + "Sản phẩm</th>"

                + "<th style=\"padding:8px;text-align:center\">"
                + "SL</th>"

                + "<th style=\"padding:8px;text-align:right\">"
                + "Đơn giá</th>"

                + "<th style=\"padding:8px;text-align:right\">"
                + "Thành tiền</th>"

                + "</tr></thead>"

                + "<tbody>"
                + itemsRows
                + "</tbody>"

                + "</table>";
    }

    /**
     * Wrap email content.
     */
    private String wrap(String inner) {

        return "<div style=\"font-family:Arial,sans-serif;"
                + "max-width:560px;margin:auto;padding:24px;"
                + "border:1px solid #eee;border-radius:12px;color:#222\">"

                + inner

                + "</div>";
    }

    /**
     * Create HTML table row.
     */
    private String row(String label, String value) {

        return "<tr>"

                + "<td style=\"padding:8px;"
                + "border-bottom:1px solid #eee;color:#666\">"
                + label
                + "</td>"

                + "<td style=\"padding:8px;"
                + "border-bottom:1px solid #eee;"
                + "text-align:right\">"
                + value
                + "</td>"

                + "</tr>";
    }

    /**
     * Escape HTML special characters.
     */
    private String escape(String s) {

        if (s == null) {
            return "";
        }

        return s.replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&#39;");
    }

    /**
     * Get first non-null value.
     */
    private static Object firstNonNull(Object... values) {

        for (Object value : values) {

            if (value != null) {
                return value;
            }
        }

        return null;
    }

    /**
     * Convert object to String.
     */
    private static String str(Object o) {

        return o == null ? "" : o.toString();
    }

    /**
     * Convert object to Integer.
     */
    private static int toInt(Object o) {

        if (o instanceof Number) {
            return ((Number) o).intValue();
        }

        if (o == null) {
            return 0;
        }

        try {
            return Integer.parseInt(o.toString().trim());

        } catch (NumberFormatException e) {
            return 0;
        }
    }

    /**
     * Convert object to BigDecimal.
     */
    private static BigDecimal toMoney(Object o) {

        if (o == null) {
            return BigDecimal.ZERO;
        }

        if (o instanceof BigDecimal) {
            return (BigDecimal) o;
        }

        try {

            return new BigDecimal(o.toString().trim());

        } catch (NumberFormatException e) {

            return BigDecimal.ZERO;
        }
    }

    /**
     * Format product size.
     */
    private static String formatSize(Object size) {

        if (size == null) {
            return "";
        }

        if (size instanceof BigDecimal) {

            return ((BigDecimal) size)
                    .stripTrailingZeros()
                    .toPlainString();
        }

        return size.toString();
    }

    /**
     * Format a date/time value from the database (Timestamp, LocalDateTime...).
     * If the value is missing, use the current time.
     */
    private static String formatDateTime(Object value) {

        if (value instanceof Timestamp) {
            return ((Timestamp) value).toLocalDateTime().format(DATE_FORMAT);
        }

        if (value instanceof LocalDateTime) {
            return ((LocalDateTime) value).format(DATE_FORMAT);
        }

        return LocalDateTime.now().format(DATE_FORMAT);
    }

    /**
     * Format Vietnamese currency.
     */
    private static String formatVnd(BigDecimal amount) {

        NumberFormat nf = NumberFormat.getInstance(VI_LOCALE);

        nf.setMaximumFractionDigits(0);

        return nf.format(amount) + "₫";
    }

    /**
     * Check null or blank String.
     */
    private static boolean isBlank(String value) {

        return value == null || value.isBlank();
    }
}