<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.functions" prefix="fn" %>

<c:set var="pageTitle" value="Quản lý bộ sưu tập" />
<c:set var="adminMenu" value="lookbooks" />
<c:set var="pageCss" value="admin-lookbooks.css" />
<%@ include file="../layouts/admin-header.jsp" %>

        <div class="top">
            <div>
                <h1 class="page-title">Quản lý bộ sưu tập</h1>
                <p class="page-sub">Tổng cộng ${fn:length(lookbooks)} bộ sưu tập</p>
            </div>
            <a href="${ctx}/admin/lookbooks/new" class="btn-add">+ Thêm bộ sưu tập</a>
        </div>

        <c:if test="${not empty success}">
            <div class="alert ok"><c:out value="${success}"/></div>
        </c:if>
        <c:if test="${not empty error}">
            <div class="alert err"><c:out value="${error}"/></div>
        </c:if>

        <div class="card lbk-table">
            <div class="table-wrap">
                <table>
                    <thead>
                    <tr>
                        <th>Ảnh bìa</th>
                        <th>Bộ sưu tập</th>
                        <th>Số ảnh</th>
                        <th>Sản phẩm</th>
                        <th>Thứ tự</th>
                        <th>Trạng thái</th>
                        <th>Thao tác</th>
                    </tr>
                    </thead>
                    <tbody>
                    <c:forEach var="l" items="${lookbooks}">
                        <tr>
                            <td>
                                <div class="lbk-thumb">
                                    <c:choose>
                                        <c:when test="${empty l.coverImageUrl}">Chưa có ảnh</c:when>
                                        <c:when test="${fn:startsWith(l.coverImageUrl, 'http')}">
                                            <img src="<c:out value='${l.coverImageUrl}'/>" alt="" onerror="this.style.display='none'">
                                        </c:when>
                                        <c:when test="${fn:startsWith(l.coverImageUrl, '/')}">
                                            <img src="${ctx}<c:out value='${l.coverImageUrl}'/>" alt="" onerror="this.style.display='none'">
                                        </c:when>
                                        <c:otherwise>
                                            <img src="${ctx}/static/assets/images/<c:out value='${l.coverImageUrl}'/>" alt="" onerror="this.style.display='none'">
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                            </td>
                            <td>
                                <div class="lbk-name"><c:out value="${l.title}"/></div>
                                <c:if test="${not empty l.description}">
                                    <div class="lbk-desc"><c:out value="${fn:substring(l.description, 0, 90)}"/><c:if test="${fn:length(l.description) > 90}">…</c:if></div>
                                </c:if>
                            </td>
                            <td><span class="num">${l.photoCount}</span> ảnh</td>
                            <td><span class="num">${l.productCount}</span> sản phẩm</td>
                            <td><span class="num">${l.sortOrder}</span></td>
                            <td>
                                <c:choose>
                                    <c:when test="${l.active}"><span class="status on">Đang hiện</span></c:when>
                                    <c:otherwise><span class="status off">Đã ẩn</span></c:otherwise>
                                </c:choose>
                            </td>
                            <td>
                                <div class="actions">
                                    <a href="${ctx}/admin/lookbooks/${l.id}/edit" class="btn-edit">Sửa</a>
                                    <form action="${ctx}/admin/lookbooks/${l.id}/delete" method="post"
                                          class="js-delete" data-name="<c:out value='${l.title}'/>">
                                        <button type="submit" class="btn-del">Xóa</button>
                                    </form>
                                </div>
                            </td>
                        </tr>
                    </c:forEach>
                    </tbody>
                </table>
            </div>

            <c:if test="${empty lookbooks}">
                <div class="empty">Chưa có bộ sưu tập nào. Bấm "Thêm bộ sưu tập" để tạo bộ đầu tiên.</div>
            </c:if>
        </div>

        <p class="note">
            Mỗi bộ sưu tập gồm các <b>sản phẩm</b> thuộc bộ sưu tập (ví dụ hàng mới ra, Thu Đông) và các ảnh phối đồ.
            Khách bấm vào bộ sưu tập sẽ thấy đúng những sản phẩm đó. Sản phẩm gắn vào ảnh cũng tự hiện trong bộ sưu tập.
            Bộ sưu tập <b>Đã ẩn</b> khách sẽ không thấy. Số <b>Thứ tự</b> nhỏ đứng trước.
        </p>

<script>
    // Hỏi xác nhận trước khi xóa
    document.addEventListener('submit', function (e) {
        var form = e.target;
        if (!form.classList.contains('js-delete')) return;
        var name = form.getAttribute('data-name') || 'bộ sưu tập này';
        if (!confirm('Xóa bộ sưu tập "' + name + '"?\nTất cả ảnh trong bộ sưu tập cũng sẽ bị xóa khỏi danh sách.')) {
            e.preventDefault();
        }
    });
</script>

<%@ include file="../layouts/admin-footer.jsp" %>
