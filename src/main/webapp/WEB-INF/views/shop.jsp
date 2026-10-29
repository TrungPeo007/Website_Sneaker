<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<%@ taglib uri="jakarta.tags.functions" prefix="fn" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<c:set var="pageTitle" value="Sản phẩm" scope="request"/>
<c:set var="activeMenu" value="shop" scope="request"/>
<jsp:include page="/WEB-INF/views/layouts/header.jsp"/>

<section class="sec">
    <div class="sec-head">
        <div>
            <div class="eyebrow">Cửa hàng</div>
            <h1 class="sec-title">
                <c:out value="${empty currentCategory ? 'Tất cả sản phẩm' : currentCategory.name}"/>
            </h1>
        </div>
    </div>

    <div class="p-grid">
        <c:forEach var="p" items="${products}">
            <article class="p-card" data-href="${ctx}/products/${p.id}" style="cursor:pointer">
                <div class="p-media">
                    <svg class="ph"><use href="#ic-shoe"/></svg>

                    <c:if test="${not empty p.mainImageUrl}">
                        <c:choose>
                            <c:when test="${fn:startsWith(p.mainImageUrl, 'http')}">
                                <c:set var="img" value="${p.mainImageUrl}"/>
                            </c:when>
                            <c:when test="${fn:startsWith(p.mainImageUrl, '/')}">
                                <c:set var="img" value="${ctx}${p.mainImageUrl}"/>
                            </c:when>
                            <c:otherwise>
                                <c:set var="img" value="${ctx}/static/assets/images/${p.mainImageUrl}"/>
                            </c:otherwise>
                        </c:choose>
                        <img src="<c:out value='${img}'/>" alt="<c:out value='${p.name}'/>" onerror="this.style.display='none'">
                    </c:if>

                    <c:choose>
                        <c:when test="${not empty p.badge}">
                            <span class="p-tag hot"><c:out value="${p.badge}"/></span>
                        </c:when>
                        <c:when test="${not empty p.discountPercent and p.discountPercent gt 0}">
                            <span class="p-tag sale">-${p.discountPercent}%</span>
                        </c:when>
                    </c:choose>

                    <button class="heart" type="button" aria-label="Yêu thích"><svg width="18" height="18"><use href="#ic-heart"/></svg></button>
                </div>
                <div class="p-body">
                    <div class="p-brand"><c:out value="${p.category.name}"/></div>
                    <div class="p-name"><a href="${ctx}/products/${p.id}" style="color:inherit;text-decoration:none"><c:out value="${p.name}"/></a></div>
                    <div class="rate">
                        <span class="stars" style="--rate:${p.avgRating * 20}%">★★★★★</span>
                        <fmt:formatNumber value="${p.avgRating}" minFractionDigits="1" maxFractionDigits="1"/> (${p.reviewCount})
                    </div>
                    <div class="p-foot">
                        <div class="price"><fmt:formatNumber value="${p.salePrice}" type="number" groupingUsed="true"/>₫</div>
                        <c:if test="${p.originalPrice gt p.salePrice}">
                            <div class="old"><fmt:formatNumber value="${p.originalPrice}" type="number" groupingUsed="true"/>₫</div>
                        </c:if>
                    </div>
                </div>
            </article>
        </c:forEach>

        <c:if test="${empty products}">
            <div class="p-empty">Chưa có sản phẩm phù hợp.</div>
        </c:if>
    </div>
</section>

<script>
    // Bấm tim để thích / bỏ thích
    document.querySelectorAll('.heart').forEach(function (btn) {
        btn.addEventListener('click', function (e) {
            e.preventDefault();
            btn.classList.toggle('on');
        });
    });

    // Bấm vào thẻ sản phẩm (trừ nút tim) -> sang trang chi tiết
    document.querySelectorAll('.p-card[data-href]').forEach(function (card) {
        card.addEventListener('click', function (e) {
            if (e.target.closest('button, a')) return;
            window.location.href = card.getAttribute('data-href');
        });
    });
</script>
<script src="${ctx}/static/assets/js/product-card.js"></script>

<jsp:include page="/WEB-INF/views/layouts/footer.jsp"/>