<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>

<c:set var="pageTitle" value="${empty form.id ? 'Thêm trang' : 'Sửa trang'}" />
<c:set var="adminMenu" value="pages" />
<c:set var="pageCss" value="admin-pages.css" />
<%@ include file="../layouts/admin-header.jsp" %>

        <h1 class="page-title">${empty form.id ? 'Thêm trang mới' : 'Chỉnh sửa trang'}</h1>
        <p class="page-sub">Nội dung nhập ở đây sẽ hiện trên website và có link ở chân trang.</p>

        <c:if test="${not empty error}">
            <div class="alert"><c:out value="${error}"/></div>
        </c:if>

        <form action="${ctx}/admin/pages/save" method="post" class="card pg-form-card" id="pageForm">
            <c:if test="${not empty form.id}">
                <input type="hidden" name="id" value="${form.id}">
            </c:if>

            <div class="field">
                <label class="f" for="title">Tiêu đề <span class="req">*</span></label>
                <input type="text" id="title" name="title" maxlength="200" required autofocus
                       placeholder="VD: Chính sách bảo mật"
                       value="<c:out value='${form.title}'/>">
            </div>

            <div class="field">
                <label class="f" for="slug">Đường dẫn <span class="opt">(tự tạo từ tiêu đề, có thể sửa)</span></label>
                <input type="text" id="slug" name="slug" maxlength="100"
                       placeholder="VD: chinh-sach-bao-mat"
                       value="<c:out value='${form.slug}'/>">
                <div class="hint">Link của trang: <code id="slugUrl"></code>. Đổi đường dẫn thì link cũ sẽ không dùng được nữa.</div>
            </div>

            <div class="field-row">
                <div class="field">
                    <label class="f" for="footerGroup">Hiện ở footer</label>
                    <select id="footerGroup" name="footerGroup">
                        <option value="SERVICE" ${form.footerGroup == 'SERVICE' ? 'selected' : ''}>Cột "Dịch Vụ"</option>
                        <option value="POLICY" ${form.footerGroup == 'POLICY' ? 'selected' : ''}>Cột "Chính Sách"</option>
                        <option value="NONE" ${form.footerGroup == 'NONE' ? 'selected' : ''}>Không hiện ở footer</option>
                    </select>
                </div>
                <div class="field">
                    <label class="f" for="sortOrder">Thứ tự</label>
                    <input type="number" id="sortOrder" name="sortOrder" min="0" max="9999" step="1"
                           value="${empty form.sortOrder ? 0 : form.sortOrder}">
                    <div class="hint">Số nhỏ đứng trước.</div>
                </div>
            </div>

            <div class="field">
                <label class="f" for="content">Nội dung <span class="req">*</span></label>
                <textarea id="content" name="content" required rows="18"
                          placeholder="## Điều kiện bảo hành&#10;- Sản phẩm còn hóa đơn.&#10;&#10;Đoạn văn bình thường viết như thế này."><c:out value="${form.content}"/></textarea>
                <div class="hint">
                    Dòng bắt đầu bằng <code>## </code> là tiêu đề mục, bắt đầu bằng <code>- </code> là gạch đầu dòng.
                    Dòng trống để ngắt đoạn. Không cần viết HTML.
                </div>
            </div>

            <div class="field">
                <%-- Ô ẩn "_active": báo cho Spring biết checkbox có mặt trong form, bỏ tick thì mới lưu là false --%>
                <input type="hidden" name="_active" value="on">
                <label class="check">
                    <input type="checkbox" name="active" value="true" ${empty form.id or form.active ? 'checked' : ''}>
                    Hiển thị cho khách xem
                </label>
                <div class="hint">Bỏ tick để ẩn trang (và link ở footer) mà không cần xóa.</div>
            </div>

            <div class="form-actions">
                <a href="${ctx}/admin/pages" class="btn-cancel">Hủy</a>
                <button type="submit" class="btn-save">${empty form.id ? 'Thêm trang' : 'Lưu thay đổi'}</button>
            </div>
        </form>

<script>
    // Tự tạo đường dẫn từ tiêu đề (bỏ dấu tiếng Việt), trừ khi anh đã tự nhập đường dẫn
    (function () {
        var base = '${ctx}/pages/';
        var title = document.getElementById('title');
        var slug = document.getElementById('slug');
        var url = document.getElementById('slugUrl');
        var manual = slug.value.trim() !== '';

        function make(s) {
            return s.normalize('NFD').replace(/[\u0300-\u036f]/g, '')
                    .replace(/đ/g, 'd').replace(/Đ/g, 'd')
                    .toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/^-+|-+$/g, '');
        }

        function show() {
            var v = slug.value.trim() ? make(slug.value) : make(title.value);
            url.textContent = base + (v || '...');
        }

        title.addEventListener('input', function () {
            if (!manual) slug.value = make(title.value);
            show();
        });
        slug.addEventListener('input', function () {
            manual = slug.value.trim() !== '';
            show();
        });
        show();
    })();
</script>

<%@ include file="../layouts/admin-footer.jsp" %>