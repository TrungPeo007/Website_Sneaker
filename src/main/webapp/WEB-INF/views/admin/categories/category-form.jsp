<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>

<%-- Mở từ nút "+ Danh mục con" thì URL có ?parentId=..., lúc này chọn sẵn nhóm --%>
<c:set var="isNew" value="${empty form.id}" />
<c:set var="addingChild" value="${isNew and not empty param.parentId}" />
<c:set var="formTitle" value="${not isNew ? 'Chỉnh sửa danh mục' : (addingChild ? 'Thêm danh mục con' : 'Thêm nhóm mới')}" />

<c:set var="pageTitle" value="${formTitle}" />
<c:set var="adminMenu" value="categories" />
<c:set var="pageCss" value="admin-category-form.css" />
<%@ include file="../layouts/admin-header.jsp" %>

        <h1 class="page-title">${formTitle}</h1>
        <p class="page-sub">Danh mục con sẽ hiện trong ô chọn danh mục của sản phẩm và trong menu "Sản Phẩm" ngoài cửa hàng.</p>

        <c:if test="${not empty error}">
            <div class="alert"><c:out value="${error}"/></div>
        </c:if>

        <form action="${ctx}/admin/categories/save" method="post" class="card" id="categoryForm">
            <c:if test="${not empty form.id}">
                <input type="hidden" name="id" value="${form.id}">
            </c:if>

            <div class="field">
                <label class="f" for="name">Tên danh mục <span class="req">*</span></label>
                <input type="text" id="name" name="name" maxlength="100" required autofocus
                       placeholder="${addingChild ? 'VD: Nike Jordan, Adidas Running' : 'VD: Shoes'}"
                       value="<c:out value='${form.name}'/>">
            </div>

            <div class="field">
                <label class="f" for="parentId">Thuộc nhóm</label>
                <select id="parentId" name="parentId" ${hasChildren ? 'disabled' : ''}>
                    <option value="">-- Không có (tạo danh mục gốc / nhóm) --</option>
                    <c:forEach var="p" items="${parents}">
                        <option value="${p.id}" ${(p.id == form.parentId or (isNew and p.id == param.parentId)) ? 'selected' : ''}>
                            <c:out value="${p.name}"/>
                        </option>
                    </c:forEach>
                </select>
                <c:choose>
                    <c:when test="${hasChildren}">
                        <div class="hint">Danh mục này đang có danh mục con nên là nhóm gốc, không thể chuyển vào nhóm khác.</div>
                    </c:when>
                    <c:when test="${isNew and empty parents}">
                        <div class="hint">Chưa có nhóm nào. Anh cứ tạo nhóm trước (ví dụ "Shoes") bằng cách để trống ô này, sau đó quay lại bấm "+ Danh mục con" ở dòng của nhóm.</div>
                    </c:when>
                    <c:otherwise>
                        <div class="hint">Sản phẩm chỉ chọn được <b>danh mục con</b>, nên thường anh sẽ chọn nhóm "Shoes". Để trống nếu muốn tạo một nhóm mới.</div>
                    </c:otherwise>
                </c:choose>
            </div>

            <div class="field">
                <label class="f" for="description">Mô tả <span class="opt">(tuỳ chọn)</span></label>
                <textarea id="description" name="description" maxlength="500"><c:out value="${form.description}"/></textarea>
            </div>

            <div class="field">
                <%-- Ô ẩn "_active": báo cho Spring biết checkbox có mặt trong form, bỏ tick thì mới lưu là false --%>
                <input type="hidden" name="_active" value="on">
                <label class="check">
                    <input type="checkbox" name="active" value="true" ${isNew or form.active ? 'checked' : ''}>
                    Hiển thị ngoài cửa hàng
                </label>
                <div class="hint">Bỏ tick để ẩn danh mục khỏi menu và ô chọn danh mục mà không cần xóa.</div>
            </div>

            <div class="form-actions">
                <a href="${ctx}/admin/categories" class="btn-cancel">Hủy</a>
                <button type="submit" class="btn-save">${isNew ? (addingChild ? 'Thêm danh mục con' : 'Thêm nhóm') : 'Lưu thay đổi'}</button>
            </div>
        </form>
<script src="${ctx}/static/assets/js/custom-select.js"></script>
<%@ include file="../layouts/admin-footer.jsp" %>
