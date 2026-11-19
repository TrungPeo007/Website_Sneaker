<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%--
  Khung nhập mã giảm giá. Nhúng vào checkout.jsp BÊN TRONG form đặt hàng:

      <jsp:include page="/WEB-INF/views/discount-box.jsp">
          <jsp:param name="subtotal" value="${cartTotal}" />
      </jsp:include>

  (cartTotal là tiền hàng, số nguyên, chưa giảm.)
  Form đặt hàng sẽ gửi thêm 2 field: couponCode và voucherCode.
  Số tiền hiện ở đây chỉ để xem trước; lúc đặt hàng server tính lại.
--%>
<link rel="stylesheet" href="${pageContext.request.contextPath}/static/assets/css/discount-box.css">

<div class="dbox" id="discountBox" data-subtotal="${param.subtotal}">
    <div class="dbox-title">Mã giảm giá</div>
    <div class="dbox-row">
        <input id="dbCoupon" name="couponCode" placeholder="Mã coupon" autocomplete="off" maxlength="30">
        <input id="dbVoucher" name="voucherCode" placeholder="Mã voucher của bạn" autocomplete="off" maxlength="30">
        <button type="button" class="dbox-btn" id="dbApply">Áp dụng</button>
    </div>
    <div class="dbox-result" id="dbResult" role="status"></div>
    <div class="dbox-link"><a href="${pageContext.request.contextPath}/my/vouchers" target="_blank">Xem voucher của tôi</a></div>
</div>

<script>
(function () {
    var box = document.getElementById('discountBox');
    var subtotal = parseInt(box.dataset.subtotal || '0', 10);
    var coupon = document.getElementById('dbCoupon');
    var voucher = document.getElementById('dbVoucher');
    var btn = document.getElementById('dbApply');
    var result = document.getElementById('dbResult');
    var money = function (n) { return Number(n).toLocaleString('vi-VN') + 'đ'; };

    function show(ok, text) {
        result.className = 'dbox-result ' + (ok ? 'ok' : 'err');
        result.textContent = text;
    }

    function apply() {
        var body = new URLSearchParams();
        body.append('subtotal', subtotal);
        body.append('coupon', coupon.value.trim());
        body.append('voucher', voucher.value.trim());
        var csrf = document.querySelector('input[name="_csrf"]');
        if (csrf) body.append('_csrf', csrf.value);

        btn.disabled = true;
        fetch('${pageContext.request.contextPath}/api/discount/preview', { method: 'POST', body: body })
            .then(function (r) { return r.json(); })
            .then(function (d) {
                if (!d.ok) { show(false, d.message); return; }
                show(true, d.totalDiscount > 0
                    ? 'Giảm ' + money(d.totalDiscount) + ', tạm tính còn ' + money(d.finalAmount)
                    : d.message);
            })
            .catch(function () { show(false, 'Không kiểm tra được mã, thử lại sau'); })
            .then(function () { btn.disabled = false; });
    }

    btn.addEventListener('click', apply);

    // Nhấn Enter trong ô nhập mã chỉ để áp dụng mã, KHÔNG được gửi form đặt hàng
    [coupon, voucher].forEach(function (el) {
        el.addEventListener('keydown', function (e) {
            if (e.key === 'Enter') { e.preventDefault(); apply(); }
        });
    });
})();
</script>
