<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<%@ taglib uri="jakarta.tags.functions" prefix="fn" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<c:set var="sessUser" value="${not empty sessionScope.loginUser ? sessionScope.loginUser : sessionScope['com.polysneaker.polysneaker.dto.LoginUser']}" />
<c:set var="receiverNameVal" value="${not empty f.receiverName ? f.receiverName : sessUser.username}" />
<!DOCTYPE html>
<html lang="vi">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Thanh toán - PolySneaker</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Nunito+Sans:wght@400;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${ctx}/static/assets/css/checkout.css">
</head>

<body class="co-body">

    <%-- Trang thanh toán đứng riêng: không dùng header/footer của website --%>
    <header class="co-top">
        <a class="co-brand" href="${ctx}/">Poly<b>Sneaker</b></a>
        <a class="co-bag" href="${ctx}/shop" aria-label="Tiếp tục mua sắm">
            <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor"
                stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"
                aria-hidden="true">
                <path d="M6 8h12l1 12H5L6 8z" />
                <path d="M9 8V7a3 3 0 0 1 6 0v1" />
            </svg>
        </a>
    </header>

    <form id="checkoutForm" class="co-layout" method="post" action="${ctx}/checkout">
        <input type="hidden" name="items" value="<c:out value='${itemIds}'/>">
        <input type="hidden" name="paymentMethod" value="COD">

        <%--============CỘT TRÁI: thông tin============--%>
        <div class="co-main">
            <div class="co-col">

                <c:if test="${not empty error}">
                    <div class="co-alert err">
                        <c:out value="${error}" />
                    </div>
                </c:if>

                <h2 class="co-h">Liên hệ</h2>
                <div class="co-grid">
                    <div class="co-f full">
                        <input type="text" id="receiverName" name="receiverName"
                            value="<c:out value='${receiverNameVal}'/>"
                            placeholder=" " readonly>
                        <label for="receiverName">Họ tên người nhận *</label>
                    </div>
                    <div class="co-f full">
                        <input type="text" id="phone" name="phone"
                            value="<c:out value='${f.phone}'/>" maxlength="15" inputmode="tel"
                            placeholder=" " required>
                        <label for="phone">Số điện thoại *</label>
                    </div>
                </div>

                <h2 class="co-h">Giao hàng</h2>
                <div class="co-grid">
                    <div class="co-f full">
                        <input type="text" id="address" name="address"
                            value="<c:out value='${f.address}'/>" maxlength="300"
                            placeholder=" " required>
                        <label for="address">Địa chỉ giao hàng *</label>
                    </div>
                    <div class="co-f full">
                        <input type="text" id="note" name="note"
                            value="<c:out value='${f.note}'/>" maxlength="500" placeholder=" ">
                        <label for="note">Ghi chú (VD: giao giờ hành chính)</label>
                    </div>
                </div>

                <h2 class="co-h">Thanh toán</h2>
                <p class="co-sub">Mọi giao dịch đều được bảo mật.</p>
                <label class="co-opt">
                    <input type="radio" checked disabled>
                    <span><b>Thanh toán khi nhận hàng (COD)</b><small>Trả tiền mặt cho người
                            giao hàng. Các hình thức thanh toán khác sẽ có sớm.</small></span>
                </label>

                <button type="submit" class="co-btn">Đặt hàng</button>
                <a class="co-back" href="${ctx}/shop">&lsaquo; Tiếp tục mua sắm</a>
            </div>
        </div>

        <%--============CỘT PHẢI: tóm tắt đơn hàng============--%>
        <aside class="co-sum">
            <div class="co-sum-in">
                <c:forEach var="it" items="${items}">
                    <div class="co-line">
                        <div class="co-thumb">
                            <c:set var="img" value="${it.MainImageUrl}" />
                            <c:choose>
                                <c:when test="${empty img}"></c:when>
                                <c:when test="${fn:startsWith(img, 'http')}"><img
                                        src="<c:out value='${img}'/>" alt=""></c:when>
                                <c:when test="${fn:startsWith(img, '/')}"><img
                                        src="${ctx}<c:out value='${img}'/>" alt=""></c:when>
                                <c:otherwise><img
                                        src="${ctx}/static/assets/images/<c:out value='${img}'/>"
                                        alt=""></c:otherwise>
                            </c:choose>
                            <i class="co-qty">${it.Quantity}</i>
                        </div>
                        <div class="co-lname">
                            <b>
                                <c:out value="${it.ProductName}" />
                            </b>
                            <small>Size
                                <fmt:formatNumber value="${it.Size}" pattern="#.#" />
                            </small>
                        </div>
                        <span class="co-lprice">
                            <fmt:formatNumber value="${it.SalePrice * it.Quantity}"
                                pattern="#,##0" />₫
                        </span>
                    </div>
                </c:forEach>

                <div class="co-disc">
                    <jsp:include page="/WEB-INF/views/discount-box.jsp">
                        <jsp:param name="subtotal" value="${subtotal}" />
                        <jsp:param name="coupon" value="${f.couponCode}" />
                        <jsp:param name="voucher" value="${f.voucherCode}" />
                    </jsp:include>
                </div>

                <div class="co-row total"><span>Tạm tính</span><b>
                        <fmt:formatNumber value="${subtotal}" pattern="#,##0" />₫
                    </b></div>
                <p class="co-note">Số tiền giảm và tổng thanh toán cuối cùng được tính khi
                    bạn đặt hàng.</p>
            </div>
        </aside>
    </form>

    <script>
        (function () {
            var form = document.getElementById('checkoutForm');
            var submitting = false;
            form.addEventListener('submit', function (e) {
                if (typeof form.checkValidity === 'function' && !form.checkValidity()) {
                    return;
                }
                if (submitting) {
                    e.preventDefault();
                    return;
                }
                submitting = true;
                var btn = form.querySelector('.co-btn');
                if (btn) {
                    btn.disabled = true;
                    btn.textContent = 'Đang xử lý...';
                }
            });
        })();
    </script>
</body>

</html>