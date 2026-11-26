<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<%@ taglib uri="jakarta.tags.functions" prefix="fn" %>

<c:set var="pageTitle" value="Quản lý sản phẩm" />
<c:set var="adminMenu" value="products" />
<c:set var="pageCss" value="admin-products.css" />
<%@ include file="../layouts/admin-header.jsp" %>

        <div class="top">
            <div>
                <h1 class="page-title">Quản lý sản phẩm</h1>
                <p class="page-sub">Tổng cộng ${fn:length(products)} sản phẩm</p>
            </div>
            <a href="${ctx}/admin/products/new" class="btn-add">+ Thêm sản phẩm</a>
        </div>

        <c:if test="${not empty success}">
            <div class="alert ok"><c:out value="${success}"/></div>
        </c:if>
        <c:if test="${not empty error}">
            <div class="alert err"><c:out value="${error}"/></div>
        </c:if>

        <div class="tools">
            <div class="search-box">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><circle cx="11" cy="11" r="7"/><line x1="21" y1="21" x2="16.5" y2="16.5"/></svg>
                <input type="text" id="search" class="search" placeholder="Tìm theo tên sản phẩm hoặc danh mục...">
            </div>
        </div>

        <div class="card">
            <div class="table-wrap">
                <table>
                    <thead>
                    <tr>
                        <th>Ảnh</th>
                        <th>Sản phẩm</th>
                        <th>Giá</th>
                        <th>Size &amp; tồn kho</th>
                        <th>Trạng thái</th>
                        <th>Thao tác</th>
                    </tr>
                    </thead>
                    <tbody id="rows">
                    <c:forEach var="p" items="${products}">
                        <c:set var="totalStock" value="0"/>
                        <c:forEach var="d" items="${p.details}">
                            <c:set var="totalStock" value="${totalStock + d.stockQuantity}"/>
                        </c:forEach>

                        <tr data-search="<c:out value='${fn:toLowerCase(p.name)} ${fn:toLowerCase(p.category.name)}'/>">
                            <td>
                                <div class="thumb">
                                    <c:choose>
                                        <c:when test="${empty p.mainImageUrl}">Không ảnh</c:when>
                                        <c:when test="${fn:startsWith(p.mainImageUrl, 'http')}">
                                            <img src="<c:out value='${p.mainImageUrl}'/>" alt="<c:out value='${p.name}'/>">
                                        </c:when>
                                        <c:otherwise>
                                            <img src="${ctx}/static/assets/images/<c:out value='${p.mainImageUrl}'/>" alt="<c:out value='${p.name}'/>">
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                            </td>
                            <td>
                                <div class="p-name">
                                    <c:out value="${p.name}"/>
                                    <c:if test="${not empty p.badge}"><span class="chip"><c:out value="${p.badge}"/></span></c:if>
                                </div>
                                <div class="p-meta"><c:out value="${p.category.name}"/></div>
                            </td>
                            <td>
                                <div class="price"><fmt:formatNumber value="${p.salePrice}" pattern="#,##0"/>₫</div>
                                <c:if test="${p.originalPrice > p.salePrice}">
                                    <div class="price-old"><fmt:formatNumber value="${p.originalPrice}" pattern="#,##0"/>₫</div>
                                </c:if>
                            </td>
                            <td>
                                <div class="stock ${totalStock <= 0 ? 'low' : ''}">
                                    <c:choose>
                                        <c:when test="${totalStock <= 0}">Hết hàng</c:when>
                                        <c:otherwise>Còn ${totalStock} đôi</c:otherwise>
                                    </c:choose>
                                </div>
                                <div class="sizes">
                                    <c:forEach var="d" items="${p.details}" varStatus="st">
                                        <fmt:formatNumber value="${d.size}" pattern="#.#"/><c:if test="${!st.last}">, </c:if>
                                    </c:forEach>
                                </div>
                            </td>
                            <td>
                                <c:choose>
                                    <c:when test="${p.active}"><span class="status on">Đang bán</span></c:when>
                                    <c:otherwise><span class="status off">Đã ẩn</span></c:otherwise>
                                </c:choose>
                            </td>
                            <td>
                                <div class="actions">
                                    <a href="${ctx}/admin/products/${p.id}/edit" class="btn-edit">Sửa</a>
                                    <form action="${ctx}/admin/products/${p.id}/delete" method="post"
                                          class="js-delete" data-name="<c:out value='${p.name}'/>">
                                        <button type="submit" class="btn-del">Xóa</button>
                                    </form>
                                </div>
                            </td>
                        </tr>
                    </c:forEach>
                    </tbody>
                </table>
            </div>

            <c:if test="${empty products}">
                <div class="empty">Chưa Có Sản Phẩm </div>
            </c:if>
            <div class="empty" id="noResult" hidden>Không tìm thấy sản phẩm phù hợp.</div>
        </div>

<script>
    // Hỏi xác nhận trước khi xóa
    document.addEventListener('submit', function (e) {
        var form = e.target;
        if (!form.classList.contains('js-delete')) return;
        var name = form.getAttribute('data-name') || 'sản phẩm này';
        if (!confirm('Xóa "' + name + '"?\nCác size và ảnh phụ của sản phẩm cũng sẽ bị xóa.')) {
            e.preventDefault();
        }
    });

    // Lọc nhanh theo tên / danh mục
    (function () {
        var input = document.getElementById('search');
        var rows = document.querySelectorAll('#rows tr');
        var noResult = document.getElementById('noResult');

        input.addEventListener('input', function () {
            var q = input.value.trim().toLowerCase();
            var shown = 0;
            rows.forEach(function (tr) {
                var match = !q || tr.getAttribute('data-search').indexOf(q) !== -1;
                tr.hidden = !match;
                if (match) shown++;
            });
            noResult.hidden = shown > 0 || rows.length === 0;
        });
    })();
</script>

<%@ include file="../layouts/admin-footer.jsp" %>
