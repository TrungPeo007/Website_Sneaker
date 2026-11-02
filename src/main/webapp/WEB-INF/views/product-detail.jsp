<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<%@ taglib uri="jakarta.tags.functions" prefix="fn" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<c:set var="pageTitle" scope="request">
    <c:out value="${product.name}" /> - PolySneaker
</c:set>
<c:set var="activeMenu" value="" scope="request" />
<jsp:include page="/WEB-INF/views/layouts/header.jsp" />

<%-- Số ảnh trong thư viện --%>
<c:set var="galleryCount" value="${fn:length(gallery)}" />

<%-- Ảnh đầu tiên (ảnh đại diện) dùng cho khung ảnh lớn --%>
<c:set var="firstSrc" value="" />
<c:if test="${not empty gallery}">
    <c:set var="g0" value="${gallery[0]}" />
    <c:choose>
        <c:when test="${fn:startsWith(g0, 'http')}">
            <c:set var="firstSrc" value="${g0}" />
        </c:when>
        <c:when test="${fn:startsWith(g0, '/')}">
            <c:set var="firstSrc" value="${ctx}${g0}" />
        </c:when>
        <c:otherwise>
            <c:set var="firstSrc" value="${ctx}/static/assets/images/${g0}" />
        </c:otherwise>
    </c:choose>
</c:if>

<%-- CSS của trang chi tiết sản phẩm --%>
<link rel="stylesheet" href="${ctx}/static/assets/css/product-detail.css">

<section class="pd">

    <nav class="pd-crumb" aria-label="Điều hướng">
        <a href="${ctx}/">Trang chủ</a><span>/</span>
        <c:if test="${not empty product.category}">
            <span><c:out value="${product.category.name}" /></span><span>/</span>
        </c:if>
        <b><c:out value="${product.name}" /></b>
    </nav>

    <div class="pd-top">

        <%--===== Ảnh =====--%>
        <div class="pd-gallery ${galleryCount gt 1 ? '' : 'single'}">

            <c:if test="${galleryCount gt 1}">
                <div class="pd-thumbs-col">
                    <div class="pd-thumbs">
                        <button type="button" class="pd-arrow" id="pdPrev" aria-label="Ảnh trước">
                            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor"
                                 stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round">
                                <polyline points="18 15 12 9 6 15" />
                            </svg>
                        </button>
                        <div class="pd-thumb-list" id="pdThumbList">
                            <c:forEach var="g" items="${gallery}" varStatus="st">
                                <c:choose>
                                    <c:when test="${fn:startsWith(g, 'http')}">
                                        <c:set var="gsrc" value="${g}" />
                                    </c:when>
                                    <c:when test="${fn:startsWith(g, '/')}">
                                        <c:set var="gsrc" value="${ctx}${g}" />
                                    </c:when>
                                    <c:otherwise>
                                        <c:set var="gsrc" value="${ctx}/static/assets/images/${g}" />
                                    </c:otherwise>
                                </c:choose>
                                <button type="button" class="pd-thumb ${st.first ? 'on' : ''}"
                                        data-src="<c:out value='${gsrc}'/>" aria-label="Ảnh ${st.index + 1}">
                                    <img src="<c:out value='${gsrc}'/>" alt="" onerror="this.style.display='none'">
                                </button>
                            </c:forEach>
                        </div>
                        <button type="button" class="pd-arrow" id="pdNext" aria-label="Ảnh sau">
                            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor"
                                 stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round">
                                <polyline points="6 9 12 15 18 9" />
                            </svg>
                        </button>
                    </div>
                </div>
            </c:if>

            <div class="pd-main ${empty firstSrc ? 'noimg' : ''}" id="pdMainBox">
                <span class="none">Chưa có ảnh sản phẩm</span>
                <c:if test="${not empty firstSrc}">
                    <img id="pdMain" src="<c:out value='${firstSrc}'/>" alt="<c:out value='${product.name}'/>"
                         draggable="false"
                         onerror="this.style.display='none'; this.parentNode.classList.add('noimg')">
                </c:if>

                <c:if test="${galleryCount gt 1}">
                    <button type="button" class="pd-nav prev" id="pdMainPrev" aria-label="Ảnh trước">
                        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor"
                             stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round">
                            <polyline points="15 18 9 12 15 6" />
                        </svg>
                    </button>
                    <button type="button" class="pd-nav next" id="pdMainNext" aria-label="Ảnh sau">
                        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor"
                             stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round">
                            <polyline points="9 18 15 12 9 6" />
                        </svg>
                    </button>
                    <span class="pd-count" id="pdCount">1 / ${galleryCount}</span>
                </c:if>

                <c:choose>
                    <c:when test="${not empty product.badge}">
                        <span class="pd-flag"><c:out value="${product.badge}" /></span>
                    </c:when>
                    <c:when test="${not empty product.discountPercent and product.discountPercent gt 0}">
                        <span class="pd-flag sale">-${product.discountPercent}%</span>
                    </c:when>
                </c:choose>
            </div>
        </div>

        <%--===== Thông tin + mua hàng =====--%>
        <div class="pd-info" id="pdInfo" data-id="${product.id}"
             data-name="<c:out value='${product.name}'/>"
             data-price="${product.salePrice}" data-image="<c:out value='${firstSrc}'/>">

            <h1 class="pd-title"><c:out value="${product.name}" /></h1>

            <div class="pd-sub">
                <div class="rate">
                    <span class="stars" style="--rate:${product.avgRating * 20}%">★★★★★</span>
                    <fmt:formatNumber value="${product.avgRating}" minFractionDigits="1" maxFractionDigits="1" />
                    (${product.reviewCount} đánh giá)
                </div>
            </div>

            <div class="pd-price-row">
                <span class="pd-price">
                    <fmt:formatNumber value="${product.salePrice}" type="number" groupingUsed="true" />₫
                </span>
                <c:if test="${product.originalPrice gt product.salePrice}">
                    <span class="pd-old">
                        <fmt:formatNumber value="${product.originalPrice}" type="number" groupingUsed="true" />₫
                    </span>
                    <span class="pd-off">-${product.discountPercent}%</span>
                </c:if>
                <span class="pd-vat">(Đã bao gồm VAT)</span>
            </div>

            <div class="pd-meta">
                <div><span>Mã sản phẩm</span><b>PS-<fmt:formatNumber value="${product.id}" pattern="0000" /></b></div>
                <c:if test="${not empty product.category}">
                    <div><span>Danh mục</span><b><c:out value="${product.category.name}" /></b></div>
                </c:if>
                <div><span>Tình trạng</span>
                    <c:choose>
                        <c:when test="${totalStock gt 0}"><b class="ok">Còn hàng</b></c:when>
                        <c:otherwise><b class="out">Hết hàng</b></c:otherwise>
                    </c:choose>
                </div>
            </div>

            <div class="pd-label">Chọn size <small id="pdSizeSel">(chưa chọn)</small></div>
            <div class="pd-sizes" id="pdSizes">
                <c:forEach var="d" items="${sizes}">
                    <button type="button" class="pd-size"
                            data-size="<fmt:formatNumber value='${d.size}' pattern='#.#'/>"
                            data-stock="${d.stockQuantity}" ${d.stockQuantity le 0 ? 'disabled' : '' }>
                        <fmt:formatNumber value="${d.size}" pattern="#.#" />
                    </button>
                </c:forEach>
                <c:if test="${empty sizes}"><span class="pd-vat">Sản phẩm chưa có size.</span></c:if>
            </div>
            <div class="pd-stock" id="pdStock">Vui lòng chọn size để xem số lượng còn lại.</div>

            <div class="pd-buy">
                <div class="pd-qty">
                    <button type="button" id="pdMinus" aria-label="Giảm">−</button>
                    <input type="number" id="pdQty" value="1" min="1" max="99" inputmode="numeric"
                           aria-label="Số lượng">
                    <button type="button" id="pdPlus" aria-label="Tăng">+</button>
                </div>
                <button type="button" class="pd-add" id="pdAdd" ${totalStock le 0 ? 'disabled' : '' }>
                    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor"
                         stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">
                        <circle cx="9" cy="21" r="1" />
                        <circle cx="20" cy="21" r="1" />
                        <path d="M1 1h4l2.7 13.4a2 2 0 0 0 2 1.6h9.7a2 2 0 0 0 2-1.6L23 6H6" />
                    </svg>
                    <c:choose>
                        <c:when test="${totalStock le 0}">Hết hàng</c:when>
                        <c:otherwise>Thêm vào giỏ hàng</c:otherwise>
                    </c:choose>
                </button>
            </div>
            <div class="pd-msg" id="pdMsg" role="status"></div>

            <div class="pd-perks">
                <div class="pd-perk"><b>100% chính hãng</b>Kiểm định kỹ 2 lớp trước khi giao.</div>
                <div class="pd-perk"><b>Đổi trả 30 ngày</b>Hỗ trợ đổi size nhanh chóng.</div>
                <div class="pd-perk"><b>Giao nhanh 2 giờ</b>Đóng hộp 2 lớp chống va đập.</div>
            </div>
        </div>
    </div>

    <%--===== Mô tả =====--%>
    <div class="pd-sec">
        <h2>Mô tả sản phẩm</h2>
        <c:choose>
            <c:when test="${not empty description}">
                <div class="pd-desc"><c:out value="${description}" /></div>
            </c:when>
            <c:otherwise>
                <div class="pd-desc empty">Sản phẩm chưa có mô tả.</div>
            </c:otherwise>
        </c:choose>
    </div>

    <%--===== Gợi ý =====--%>
    <c:if test="${not empty related}">
        <div class="pd-sec">
            <h2>Có thể bạn cũng thích</h2>
            <div class="p-grid">
                <c:forEach var="p" items="${related}">
                    <article class="p-card" data-href="${ctx}/products/${p.id}" style="cursor:pointer">
                        <div class="p-media">
                            <svg class="ph"><use href="#ic-shoe" /></svg>
                            <c:if test="${not empty p.mainImageUrl}">
                                <c:choose>
                                    <c:when test="${fn:startsWith(p.mainImageUrl, 'http')}">
                                        <c:set var="img" value="${p.mainImageUrl}" />
                                    </c:when>
                                    <c:when test="${fn:startsWith(p.mainImageUrl, '/')}">
                                        <c:set var="img" value="${ctx}${p.mainImageUrl}" />
                                    </c:when>
                                    <c:otherwise>
                                        <c:set var="img" value="${ctx}/static/assets/images/${p.mainImageUrl}" />
                                    </c:otherwise>
                                </c:choose>
                                <img src="<c:out value='${img}'/>" alt="<c:out value='${p.name}'/>"
                                     onerror="this.style.display='none'">
                            </c:if>
                            <c:choose>
                                <c:when test="${not empty p.badge}">
                                    <span class="p-tag hot"><c:out value="${p.badge}" /></span>
                                </c:when>
                                <c:when test="${not empty p.discountPercent and p.discountPercent gt 0}">
                                    <span class="p-tag sale">-${p.discountPercent}%</span>
                                </c:when>
                            </c:choose>
                        </div>
                        <div class="p-body">
                            <div class="p-brand"><c:out value="${p.category.name}" /></div>
                            <div class="p-name">
                                <a href="${ctx}/products/${p.id}" style="color:inherit;text-decoration:none">
                                    <c:out value="${p.name}" />
                                </a>
                            </div>
                            <div class="rate">
                                <span class="stars" style="--rate:${p.avgRating * 20}%">★★★★★</span>
                                <fmt:formatNumber value="${p.avgRating}" minFractionDigits="1" maxFractionDigits="1" />
                                (${p.reviewCount})
                            </div>
                            <div class="p-foot">
                                <div>
                                    <div class="price">
                                        <fmt:formatNumber value="${p.salePrice}" type="number" groupingUsed="true" />₫
                                    </div>
                                    <c:if test="${p.originalPrice gt p.salePrice}">
                                        <div class="old">
                                            <fmt:formatNumber value="${p.originalPrice}" type="number"
                                                              groupingUsed="true" />₫
                                        </div>
                                    </c:if>
                                </div>
                            </div>
                        </div>
                    </article>
                </c:forEach>
            </div>
        </div>
    </c:if>
</section>

<div class="pd-toast" id="pdToast" role="status"></div>

<%-- JS của trang chi tiết sản phẩm (phải nằm sau phần HTML ở trên) --%>
<script src="${ctx}/static/assets/js/product-detail.js"></script>

<jsp:include page="/WEB-INF/views/layouts/footer.jsp" />
