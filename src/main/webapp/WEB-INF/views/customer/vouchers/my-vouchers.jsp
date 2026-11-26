<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<c:set var="pageTitle" value="Voucher của tôi" scope="request" />
<c:set var="activeMenu" value="vouchers" scope="request" />
<jsp:include page="/WEB-INF/views/layouts/header.jsp" />

<link rel="stylesheet" href="${ctx}/static/assets/css/my-vouchers.css">

<section class="sec vc">

    <header class="vc-hero">
        <div class="eyebrow">Ưu đãi</div>
        <h1 class="sec-title">Voucher của tôi</h1>
        <p>Voucher được cấp riêng cho tài khoản của bạn. Sao chép mã rồi nhập ở bước thanh toán để được giảm giá.</p>
        <span class="vc-rule"></span>
    </header>

    <c:choose>
        <c:when test="${not empty vouchers}">
            <div class="vc-grid">
                <c:forEach var="v" items="${vouchers}">
                    <c:set var="usable" value="${v.EffectiveStatus == 'UNUSED'}" />
                    <article class="vc-card ${usable ? '' : 'off'}">

                        <span class="vc-badge">
                            <c:choose>
                                <c:when test="${v.EffectiveStatus == 'UNUSED'}">Còn dùng được</c:when>
                                <c:when test="${v.EffectiveStatus == 'USED'}">Đã dùng</c:when>
                                <c:when test="${v.EffectiveStatus == 'EXPIRED'}">Hết hạn</c:when>
                                <c:otherwise>Đã thu hồi</c:otherwise>
                            </c:choose>
                        </span>

                        <div class="vc-off">
                            <c:choose>
                                <c:when test="${v.DiscountType == 'PERCENT'}">Giảm ${v.DiscountValue}%</c:when>
                                <c:otherwise>Giảm <fmt:formatNumber value="${v.DiscountValue}" pattern="#,##0" />đ</c:otherwise>
                            </c:choose>
                        </div>
                        <div class="vc-title"><c:out value="${v.Title}" /></div>

                        <c:if test="${v.DiscountType == 'PERCENT' && not empty v.MaxDiscount}">
                            <p class="vc-meta">Giảm tối đa <fmt:formatNumber value="${v.MaxDiscount}" pattern="#,##0" />đ</p>
                        </c:if>
                        <c:if test="${v.MinOrderAmount > 0}">
                            <p class="vc-meta">Cho đơn từ <fmt:formatNumber value="${v.MinOrderAmount}" pattern="#,##0" />đ</p>
                        </c:if>
                        <p class="vc-meta">Hạn dùng: <fmt:formatDate value="${v.ExpiresAt}" pattern="dd/MM/yyyy HH:mm" /></p>

                        <div class="vc-code">
                            <input readonly value="<c:out value='${v.Code}'/>" aria-label="Mã voucher">
                            <c:if test="${usable}">
                                <button type="button" class="vc-copy">Sao chép</button>
                            </c:if>
                        </div>
                    </article>
                </c:forEach>
            </div>
        </c:when>
        <c:otherwise>
            <div class="vc-empty">
                <b>Bạn chưa có voucher nào</b>
                Khi PolySneaker tặng voucher cho bạn, chúng sẽ hiện ở đây.
            </div>
        </c:otherwise>
    </c:choose>
</section>

<script>
    document.querySelectorAll('.vc-copy').forEach(function (btn) {
        btn.addEventListener('click', function () {
            var input = btn.parentNode.querySelector('input');
            var done = function () {
                var old = btn.textContent;
                btn.textContent = 'Đã chép';
                setTimeout(function () { btn.textContent = old; }, 1500);
            };
            if (navigator.clipboard && navigator.clipboard.writeText) {
                navigator.clipboard.writeText(input.value).then(done);
            } else {
                input.select();
                document.execCommand('copy');
                done();
            }
        });
    });
</script>

<jsp:include page="/WEB-INF/views/layouts/footer.jsp" />
