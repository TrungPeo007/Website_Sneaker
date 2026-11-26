<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.functions" prefix="fn" %>

<c:set var="pageTitle" value="Trang nội dung" />
<c:set var="adminMenu" value="pages" />
<c:set var="pageCss" value="admin-pages.css" />
<%@ include file="../layouts/admin-header.jsp" %>

        <div class="top">
            <div>
                <h1 class="page-title">Trang nội dung</h1>
                <p class="page-sub">Nhập nội dung cho các trang ở chân trang web. Tiêu đề cột "Dịch Vụ" và "Chính Sách" là cố định, ở đây chỉ thêm và sửa các trang nằm bên dưới.</p>
            </div>
        </div>

        <c:if test="${not empty success}">
            <div class="alert ok"><c:out value="${success}"/></div>
        </c:if>
        <c:if test="${not empty error}">
            <div class="alert err"><c:out value="${error}"/></div>
        </c:if>

        <%-- Đếm số trang không hiện ở footer, để chỉ hiện khung đó khi có trang --%>
        <c:set var="hiddenCount" value="0"/>
        <c:forEach var="p" items="${pages}">
            <c:if test="${p.footerGroup == 'NONE'}"><c:set var="hiddenCount" value="${hiddenCount + 1}"/></c:if>
        </c:forEach>

        <c:forTokens items="SERVICE,POLICY,NONE" delims="," var="grp">
            <c:if test="${grp != 'NONE' or hiddenCount > 0}">
                <c:set var="cnt" value="0"/>

                <div class="card pg-group pg-table">
                    <div class="pg-group-head">
                        <div>
                            <c:choose>
                                <c:when test="${grp == 'SERVICE'}">
                                    <div class="pg-eyebrow">Tiêu đề cột ở footer</div>
                                    <h2 class="pg-group-title">Dịch Vụ</h2>
                                    <p class="pg-group-sub">Các trang bên dưới hiện dưới tiêu đề "Dịch Vụ".</p>
                                </c:when>
                                <c:when test="${grp == 'POLICY'}">
                                    <div class="pg-eyebrow">Tiêu đề cột ở footer</div>
                                    <h2 class="pg-group-title">Chính Sách</h2>
                                    <p class="pg-group-sub">Các trang bên dưới hiện dưới tiêu đề "Chính Sách".</p>
                                </c:when>
                                <c:otherwise>
                                    <div class="pg-eyebrow">Không nằm ở footer</div>
                                    <h2 class="pg-group-title">Trang riêng</h2>
                                    <p class="pg-group-sub">Chỉ vào được khi có link trực tiếp.</p>
                                </c:otherwise>
                            </c:choose>
                        </div>
                        <c:if test="${grp != 'NONE'}">
                            <a href="${ctx}/admin/pages/new?group=${grp}" class="btn-add-sm">+ Thêm trang vào đây</a>
                        </c:if>
                    </div>

                    <div class="table-wrap">
                        <table>
                            <thead>
                            <tr>
                                <th>Trang</th>
                                <th>Nội dung</th>
                                <th>Thứ tự</th>
                                <th>Trạng thái</th>
                                <th>Cập nhật</th>
                                <th>Thao tác</th>
                            </tr>
                            </thead>
                            <tbody>
                            <c:forEach var="p" items="${pages}">
                                <c:if test="${p.footerGroup == grp}">
                                    <c:set var="cnt" value="${cnt + 1}"/>
                                    <tr>
                                        <td>
                                            <div class="pg-name"><c:out value="${p.title}"/></div>
                                            <a class="pg-slug" href="${ctx}/pages/${p.slug}" target="_blank" rel="noopener">/pages/${p.slug}</a>
                                        </td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${empty p.content or fn:startsWith(p.content, 'Nội dung mẫu')}">
                                                    <span class="pg-content-sample">Chưa nhập nội dung</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="pg-content-ok">Đã có nội dung</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td><span class="num">${p.sortOrder}</span></td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${p.active}"><span class="status on">Đang hiện</span></c:when>
                                                <c:otherwise><span class="status off">Đã ẩn</span></c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td class="pg-date">${p.lastChangeText}</td>
                                        <td>
                                            <div class="actions">
                                                <a href="${ctx}/admin/pages/${p.id}/edit" class="btn-edit">Sửa nội dung</a>
                                                <form action="${ctx}/admin/pages/${p.id}/delete" method="post"
                                                      class="js-delete" data-name="<c:out value='${p.title}'/>">
                                                    <button type="submit" class="btn-del">Xóa</button>
                                                </form>
                                            </div>
                                        </td>
                                    </tr>
                                </c:if>
                            </c:forEach>
                            </tbody>
                        </table>
                    </div>

                    <c:if test="${cnt == 0}">
                        <div class="empty">Chưa có trang nào ở đây. Bấm "Thêm trang vào đây" để thêm.</div>
                    </c:if>
                </div>
            </c:if>
        </c:forTokens>

        <p class="note">
            Trang <b>Đã ẩn</b> sẽ không hiện cho khách và link ở footer cũng biến mất. Số <b>Thứ tự</b> nhỏ đứng trước.
            Muốn chuyển một trang sang cột khác thì bấm <b>Sửa nội dung</b> rồi đổi ô <b>Hiện ở footer</b>.
        </p>

<script>
    // Hỏi xác nhận trước khi xóa
    document.addEventListener('submit', function (e) {
        var form = e.target;
        if (!form.classList.contains('js-delete')) return;
        var name = form.getAttribute('data-name') || 'trang này';
        if (!confirm('Xóa trang "' + name + '"?\nLink của trang này ở footer cũng sẽ biến mất.')) {
            e.preventDefault();
        }
    });
</script>

<%@ include file="../layouts/admin-footer.jsp" %>