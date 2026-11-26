<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<%@ taglib uri="jakarta.tags.functions" prefix="fn" %>

<c:set var="pageTitle" value="Quản lý bài viết" />
<c:set var="adminMenu" value="blogs" />
<c:set var="pageCss" value="admin-blogs.css" />
<%@ include file="../layouts/admin-header.jsp" %>

        <div class="top">
            <div>
                <h1 class="page-title">Quản lý bài viết</h1>
                <p class="page-sub">Tổng cộng ${fn:length(blogs)} bài viết<c:if test="${not empty q}"> khớp với "<c:out value="${q}"/>"</c:if></p>
            </div>
            <a href="${ctx}/admin/blogs/new" class="btn-add">+ Thêm bài viết</a>
        </div>

        <c:if test="${not empty success}">
            <div class="alert ok"><c:out value="${success}"/></div>
        </c:if>
        <c:if test="${not empty error}">
            <div class="alert err"><c:out value="${error}"/></div>
        </c:if>

        <form class="bl-search" method="get" action="${ctx}/admin/blogs">
            <input type="search" name="q" value="<c:out value='${q}'/>" placeholder="Tìm theo tiêu đề bài viết">
            <button type="submit" class="bl-btn">Tìm</button>
            <c:if test="${not empty q}"><a class="bl-link" href="${ctx}/admin/blogs">Xóa tìm kiếm</a></c:if>
        </form>

        <div class="card">
            <div class="table-wrap">
                <table>
                    <thead>
                    <tr>
                        <th>Ảnh đại diện</th>
                        <th>Bài viết</th>
                        <th>Tác giả</th>
                        <th>Ngày tạo</th>
                        <th>Trạng thái</th>
                        <th>Thao tác</th>
                    </tr>
                    </thead>
                    <tbody>
                    <c:forEach var="b" items="${blogs}">
                        <tr>
                            <td>
                                <div class="bl-thumb">
                                    <c:choose>
                                        <c:when test="${empty b.thumbSrc}">Chưa có ảnh</c:when>
                                        <c:otherwise><img src="<c:out value='${b.thumbSrc}'/>" alt="" onerror="this.style.display='none'"></c:otherwise>
                                    </c:choose>
                                </div>
                            </td>
                            <td>
                                <div class="bl-title"><c:out value="${b.title}"/></div>
                                <div class="bl-slug">/blog/<c:out value="${b.slug}"/></div>
                            </td>
                            <td><c:out value="${empty b.author ? 'PolySneaker' : b.author}"/></td>
                            <td><fmt:formatDate value="${b.createdAt}" pattern="dd/MM/yyyy HH:mm"/></td>
                            <td>
                                <c:choose>
                                    <c:when test="${b.published}"><span class="status on">Đã đăng</span></c:when>
                                    <c:otherwise><span class="status off">Bản nháp</span></c:otherwise>
                                </c:choose>
                            </td>
                            <td>
                                <div class="actions">
                                    <a href="${ctx}/admin/blogs/${b.id}/preview" class="btn-edit" target="_blank" rel="noopener">Xem</a>
                                    <a href="${ctx}/admin/blogs/${b.id}/edit" class="btn-edit">Sửa</a>
                                    <form action="${ctx}/admin/blogs/${b.id}/toggle" method="post">
                                        <button type="submit" class="btn-edit bl-toggle">${b.published ? 'Ẩn' : 'Đăng'}</button>
                                    </form>
                                    <form action="${ctx}/admin/blogs/${b.id}/delete" method="post"
                                          class="js-delete" data-name="<c:out value='${b.title}'/>">
                                        <button type="submit" class="btn-del">Xóa</button>
                                    </form>
                                </div>
                            </td>
                        </tr>
                    </c:forEach>
                    </tbody>
                </table>
            </div>

            <c:if test="${empty blogs}">
                <div class="empty">
                    <c:choose>
                        <c:when test="${not empty q}">Không có bài viết nào khớp với từ khóa này.</c:when>
                        <c:otherwise>Chưa có bài viết nào. Bấm "Thêm bài viết" để viết bài đầu tiên.</c:otherwise>
                    </c:choose>
                </div>
            </c:if>
        </div>

        <p class="note">
            Bài <b>Đã đăng</b> hiện ở trang Blog cho khách. Bài <b>Bản nháp</b> chỉ admin thấy, bấm "Xem" để xem trước đúng như khách sẽ thấy.
            Bấm "Ẩn" để đưa bài đã đăng về bản nháp, "Đăng" để xuất bản lại.
        </p>

<script>
    // Hỏi xác nhận trước khi xóa
    document.addEventListener('submit', function (e) {
        var form = e.target;
        if (!form.classList.contains('js-delete')) return;
        var name = form.getAttribute('data-name') || 'bài viết này';
        if (!confirm('Xóa bài viết "' + name + '"?\nBài viết sẽ bị xóa hẳn và không thể khôi phục.')) {
            e.preventDefault();
        }
    });
</script>

<%@ include file="../layouts/admin-footer.jsp" %>
