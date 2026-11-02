<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.functions" prefix="fn" %>

<c:set var="pageTitle" value="Quản lý danh mục" />
<c:set var="adminMenu" value="categories" />
<c:set var="pageCss" value="admin-categories.css" />
<%@ include file="../layouts/admin-header.jsp" %>

        <div class="top">
            <div>
                <h1 class="page-title">Quản lý danh mục</h1>
                <p class="page-sub">Tổng cộng ${fn:length(rows)} danh mục</p>
            </div>
            <a href="${ctx}/admin/categories/new" class="btn-add">+ Thêm danh mục</a>
        </div>

        <c:if test="${not empty success}">
            <div class="alert ok"><c:out value="${success}"/></div>
        </c:if>
        <c:if test="${not empty error}">
            <div class="alert err"><c:out value="${error}"/></div>
        </c:if>

        <div class="tools">
            <div class="search-box">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">
                    <circle cx="11" cy="11" r="7"></circle>
                    <line x1="21" y1="21" x2="16.65" y2="16.65"></line>
                </svg>
                <input type="text" id="search" class="search" placeholder="Tìm theo tên danh mục..." autocomplete="off">
            </div>
        </div>

        <div class="card">
            <div class="table-wrap">
                <table>
                    <thead>
                    <tr>
                        <th>Danh mục</th>
                        <th>Mô tả</th>
                        <th>Nội dung</th>
                        <th>Trạng thái</th>
                        <th>Thao tác</th>
                    </tr>
                    </thead>
                    <tbody id="rows">
                    <c:forEach var="r" items="${rows}">
                        <tr class="${r.root ? 'is-root' : 'is-child'}"
                            data-search="<c:out value='${fn:toLowerCase(r.name)}'/>">
                            <td>
                                <div class="c-name">
                                    <c:if test="${not r.root}"><span class="tree">└</span></c:if>
                                    <span><c:out value="${r.name}"/></span>
                                    <c:if test="${r.root}"><span class="tag">Nhóm</span></c:if>
                                </div>
                            </td>
                            <td class="c-desc">
                                <c:choose>
                                    <c:when test="${empty r.description}">—</c:when>
                                    <c:otherwise><c:out value="${r.description}"/></c:otherwise>
                                </c:choose>
                            </td>
                            <td>
                                <c:choose>
                                    <c:when test="${r.root}"><span class="num">${r.childCount}</span> danh mục con</c:when>
                                    <c:otherwise><span class="num">${r.productCount}</span> sản phẩm</c:otherwise>
                                </c:choose>
                            </td>
                            <td>
                                <c:choose>
                                    <c:when test="${r.active}"><span class="status on">Đang hiện</span></c:when>
                                    <c:otherwise><span class="status off">Đã ẩn</span></c:otherwise>
                                </c:choose>
                            </td>
                            <td>
                                <div class="actions">
                                    <a href="${ctx}/admin/categories/${r.id}/edit" class="btn-edit">Sửa</a>
                                    <form action="${ctx}/admin/categories/${r.id}/delete" method="post"
                                          class="js-delete" data-name="<c:out value='${r.name}'/>">
                                        <button type="submit" class="btn-del">Xóa</button>
                                    </form>
                                </div>
                            </td>
                        </tr>
                    </c:forEach>
                    </tbody>
                </table>
            </div>

            <c:if test="${empty rows}">
                <div class="empty">Chưa có danh mục nào. Bấm "Thêm danh mục" để tạo danh mục đầu tiên.</div>
            </c:if>
            <div class="empty" id="noResult" hidden>Không tìm thấy danh mục phù hợp.</div>
        </div>

        <p class="note">
            <b>Nhóm</b> (danh mục gốc, ví dụ Shoes) dùng để gom các danh mục con. Sản phẩm chỉ được gắn vào <b>danh mục con</b>
            (ví dụ Nike Jordan), và các danh mục con đang hiện sẽ xuất hiện trong menu "Sản Phẩm" ngoài cửa hàng.
            Danh mục đang có sản phẩm hoặc danh mục con thì không xóa được, hãy chuyển sản phẩm đi hoặc chuyển sang "Đã ẩn".
        </p>

<script>
    // Hỏi xác nhận trước khi xóa
    document.addEventListener('submit', function (e) {
        var form = e.target;
        if (!form.classList.contains('js-delete')) return;
        var name = form.getAttribute('data-name') || 'danh mục này';
        if (!confirm('Xóa danh mục "' + name + '"?')) {
            e.preventDefault();
        }
    });
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