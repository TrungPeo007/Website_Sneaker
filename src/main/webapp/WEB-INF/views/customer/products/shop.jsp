<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<%@ taglib uri="jakarta.tags.functions" prefix="fn" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<c:set var="pageTitle" value="Sản phẩm" scope="request"/>
<c:set var="activeMenu" value="shop" scope="request"/>
<jsp:include page="/WEB-INF/views/layouts/header.jsp"/>

<%-- CSS của trang danh sách sản phẩm --%>
<link rel="stylesheet" href="${ctx}/static/assets/css/shop.css">

<section class="sec shop-sec">
    <div class="sec-head">
        <div>
            <div class="eyebrow">Cửa hàng</div>
            <h1 class="sec-title">
                <c:out value="${empty currentCategory ? 'Tất cả sản phẩm' : currentCategory.name}"/>
            </h1>
        </div>
    </div>

    <div class="shop-layout" id="shopLayout">

        <%-- ===== Cột trái: lọc theo size ===== --%>
        <c:if test="${not empty products}">
            <aside class="shop-side" id="shopSide">
                <div class="fl">
                    <button type="button" class="fl-head" id="flToggle" aria-expanded="true" aria-controls="flBody">
                        <span class="fl-title">Size <span class="fl-badge" id="flBadge" hidden>0</span></span>
                        <svg class="fl-chev" width="16" height="16" viewBox="0 0 24 24" fill="none"
                             stroke="currentColor" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round"
                             aria-hidden="true">
                            <polyline points="18 15 12 9 6 15"/>
                        </svg>
                    </button>
                    <div class="fl-body" id="flBody">
                        <div class="fl-inner">
                            <div class="fl-list" id="flList" role="group" aria-label="Lọc theo size"></div>
                            <button type="button" class="fl-clear" id="flClear" hidden>Bỏ chọn size</button>
                        </div>
                    </div>
                </div>
            </aside>
        </c:if>

        <div class="shop-main">

            <%-- ===== Thanh sắp xếp + lọc giá ===== --%>
            <c:if test="${not empty products}">
                <div class="sb" id="shopBar">

                    <div class="sb-row sb-top">
                        <div class="sb-count" id="sbCount"><b>${fn:length(products)}</b> sản phẩm</div>
                        <div class="sb-sort">
                            <span>Sắp xếp</span>
                            <%-- select gốc vẫn giữ để lưu giá trị; JS dựng dropdown tuỳ biến ngay cạnh --%>
                            <select id="sbSort" aria-label="Sắp xếp sản phẩm">
                                <option value="default">Mặc định</option>
                                <option value="newest">Mới nhất</option>
                                <option value="price-asc">Giá tăng dần</option>
                                <option value="price-desc">Giá giảm dần</option>
                                <option value="name-asc">Tên A → Z</option>
                                <option value="rating">Đánh giá cao nhất</option>
                                <option value="discount">Giảm giá nhiều nhất</option>
                            </select>
                        </div>
                    </div>

                    <div class="sb-row">
                        <span class="sb-label">Mức giá</span>
                        <div class="sb-chips" id="sbChips">
                            <button type="button" class="sb-chip" data-min="" data-max="2000000">Dưới 2 triệu</button>
                            <button type="button" class="sb-chip" data-min="2000000" data-max="3000000">2 – 3 triệu</button>
                            <button type="button" class="sb-chip" data-min="3000000" data-max="4000000">3 – 4 triệu</button>
                            <button type="button" class="sb-chip" data-min="4000000" data-max="">Trên 4 triệu</button>
                        </div>
                    </div>

                    <div class="sb-row sb-tune">
                        <div class="sb-slidebox">
                            <div class="sb-slider" id="sbSlider">
                                <span class="sb-track"></span>
                                <span class="sb-fill"></span>
                                <input type="range" id="sbLo" min="0" max="5000000" step="50000" value="0" aria-label="Kéo chọn giá thấp nhất">
                                <input type="range" id="sbHi" min="0" max="5000000" step="50000" value="5000000" aria-label="Kéo chọn giá cao nhất">
                            </div>
                            <div class="sb-readout" id="sbReadout"></div>
                        </div>

                        <div class="sb-range">
                            <input type="number" id="sbMin" min="0" step="50000" inputmode="numeric" placeholder="Từ (₫)" aria-label="Giá thấp nhất">
                            <i></i>
                            <input type="number" id="sbMax" min="0" step="50000" inputmode="numeric" placeholder="Đến (₫)" aria-label="Giá cao nhất">
                        </div>

                        <label class="sb-check">
                            <input type="checkbox" id="sbSale">
                            <span class="sb-sw"></span>
                            Chỉ đang giảm giá
                        </label>

                        <button type="button" class="sb-reset" id="sbReset" hidden>Xóa lọc</button>
                    </div>

                    <%-- Các bộ lọc đang áp dụng (bấm để gỡ từng cái) --%>
                    <div class="sb-row sb-tags" id="sbTags" hidden></div>

                    <%-- Thanh tiến độ: tỉ lệ sản phẩm còn hiển thị --%>
                    <div class="sb-line" aria-hidden="true"><i id="sbLine"></i></div>
                </div>
            </c:if>

            <div class="p-grid" id="shopGrid">
                <c:forEach var="p" items="${products}">

                    <%-- Các size còn hàng của sản phẩm, ví dụ "40,41,42.5" --%>
                    <c:set var="sz" value=""/>
                    <c:forEach var="d" items="${p.details}">
                        <c:if test="${d.active and d.stockQuantity gt 0}">
                            <c:set var="sz" value="${sz}${empty sz ? '' : ','}${d.size.stripTrailingZeros().toPlainString()}"/>
                        </c:if>
                    </c:forEach>

                    <article class="p-card" data-href="${ctx}/products/${p.id}" style="cursor:pointer"
                             data-id="${p.id}"
                             data-price="${p.salePrice}"
                             data-rating="${p.avgRating}"
                             data-reviews="${p.reviewCount}"
                             data-discount="${empty p.discountPercent ? 0 : p.discountPercent}"
                             data-sizes="${sz}"
                             data-name="<c:out value='${fn:toLowerCase(p.name)}'/>">
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

                <div class="p-empty sb-none" id="sbNone" hidden>Không có sản phẩm nào phù hợp với bộ lọc. Hãy thử mở rộng bộ lọc.</div>
            </div>
        </div>
    </div>
</section>

<%-- JS của trang (phải nằm sau phần HTML ở trên) --%>
<script src="${ctx}/static/assets/js/shop.js"></script>
<script src="${ctx}/static/assets/js/product-card.js"></script>

<jsp:include page="/WEB-INF/views/layouts/footer.jsp"/>
