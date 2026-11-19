package com.polysneaker.polysneaker.dto;

import java.util.HashMap;
import java.util.Map;
import java.util.Set;

/**
 * Dữ liệu form thanh toán. checkout.jsp đọc qua ${f.receiverName}, ${f.phone}...
 * Form tự làm sạch (normalize) và tự kiểm tra (validate).
 */
public class CheckoutForm {

    /** Các cách thanh toán đang hỗ trợ. Thêm "BANK" vào đây khi làm xong chuyển khoản. */
    private static final Set<String> PAYMENT_METHODS = Set.of("COD");

    private String receiverName;
    private String phone;
    private String address;
    private String note;
    private String paymentMethod = "COD";
    private String couponCode;
    private String voucherCode;

    // ---------------------------------------------------------------
    // Tạo form / chuyển qua lại với Map (OrderService đang dùng Map)
    // ---------------------------------------------------------------

    /** Tạo form từ Map, ví dụ dữ liệu điền sẵn lấy từ tài khoản. */
    public static CheckoutForm from(Map<String, String> m) {
        CheckoutForm f = new CheckoutForm();
        if (m != null) {
            f.receiverName = m.get("receiverName");
            f.phone = m.get("phone");
            f.address = m.get("address");
            f.note = m.get("note");
            f.couponCode = m.get("couponCode");
            f.voucherCode = m.get("voucherCode");
            if (m.get("paymentMethod") != null) {
                f.paymentMethod = m.get("paymentMethod");
            }
        }
        return f;
    }

    /** Chuyển sang Map để đưa cho OrderService.placeOrder. */
    public Map<String, String> toMap() {
        Map<String, String> m = new HashMap<>();
        m.put("receiverName", nz(receiverName));
        m.put("phone", nz(phone));
        m.put("address", nz(address));
        m.put("note", nz(note));
        m.put("paymentMethod", nz(paymentMethod));
        m.put("couponCode", nz(couponCode));
        m.put("voucherCode", nz(voucherCode));
        return m;
    }

    // ---------------------------------------------------------------
    // Làm sạch + kiểm tra
    // ---------------------------------------------------------------

    /** Cắt khoảng trắng thừa ở các ô khách nhập. */
    public void normalize() {
        receiverName = nz(receiverName);
        phone = nz(phone);
        address = nz(address);
        note = nz(note);
        paymentMethod = nz(paymentMethod).toUpperCase();
        couponCode = nz(couponCode);
        voucherCode = nz(voucherCode);
        if (paymentMethod.isEmpty()) {
            paymentMethod = "COD";
        }
    }

    /** Trả về câu báo lỗi, hoặc null nếu hợp lệ. Gọi normalize() trước. */
    public String validate() {
        if (!PAYMENT_METHODS.contains(paymentMethod)) {
            return "Hiện chỉ hỗ trợ thanh toán khi nhận hàng (COD).";
        }
        if (phone.isEmpty()) {
            return "Vui lòng nhập số điện thoại.";
        }
        if (!phone.matches("[0-9+ ]{8,15}")) {
            return "Số điện thoại không hợp lệ.";
        }
        if (address.isEmpty()) {
            return "Vui lòng nhập địa chỉ giao hàng.";
        }
        if (address.length() > 300) {
            return "Địa chỉ quá dài (tối đa 300 ký tự).";
        }
        if (note.length() > 500) {
            return "Ghi chú quá dài (tối đa 500 ký tự).";
        }
        return null;
    }

    private static String nz(String s) {
        return s == null ? "" : s.trim();
    }

    // ---------------------------------------------------------------
    // Getter / setter
    // ---------------------------------------------------------------

    public String getReceiverName() { return receiverName; }
    public void setReceiverName(String receiverName) { this.receiverName = receiverName; }

    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }

    public String getAddress() { return address; }
    public void setAddress(String address) { this.address = address; }

    public String getNote() { return note; }
    public void setNote(String note) { this.note = note; }

    public String getPaymentMethod() { return paymentMethod; }
    public void setPaymentMethod(String paymentMethod) { this.paymentMethod = paymentMethod; }

    public String getCouponCode() { return couponCode; }
    public void setCouponCode(String couponCode) { this.couponCode = couponCode; }

    public String getVoucherCode() { return voucherCode; }
    public void setVoucherCode(String voucherCode) { this.voucherCode = voucherCode; }
}