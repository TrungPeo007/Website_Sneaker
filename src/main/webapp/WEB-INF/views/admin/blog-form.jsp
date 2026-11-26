<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.functions" prefix="fn" %>

<c:set var="isNew" value="${empty form.id}" />
<c:set var="pageTitle" value="${isNew ? 'Viết bài mới' : 'Sửa bài viết'}" />
<c:set var="adminMenu" value="blogs" />
<c:set var="pageCss" value="admin-blogs.css" />
<%@ include file="../layouts/admin-header.jsp" %>

        <div class="top">
            <div>
                <h1 class="page-title">${isNew ? 'Viết bài mới' : 'Sửa bài viết'}</h1>
                <p class="page-sub"><a class="bl-link" href="${ctx}/admin/blogs">Quay lại danh sách bài viết</a></p>
            </div>
        </div>

        <c:if test="${not empty error}">
            <div class="alert err"><c:out value="${error}"/></div>
        </c:if>

        <form class="bl-form" method="post" action="${ctx}/admin/blogs/save" id="blogForm">
            <input type="hidden" name="id" value="${form.id}">
            <input type="hidden" name="_published" value="on">

            <section class="bl-col-main">
                <label class="bl-field">
                    <span>Tiêu đề</span>
                    <input type="text" name="title" id="fTitle" maxlength="200" required
                           value="<c:out value='${form.title}'/>" placeholder="Ví dụ: Cách chọn size giày chạy bộ">
                </label>

                <label class="bl-field">
                    <span>Mô tả ngắn <em id="sumCount">0/500</em></span>
                    <textarea name="summary" id="fSummary" rows="3" maxlength="500"
                              placeholder="Hiện ở danh sách bài viết, nên viết 1-2 câu."><c:out value="${form.summary}"/></textarea>
                </label>

                <div class="bl-field">
                    <span>Nội dung</span>
                    <div class="bl-toolbar" role="toolbar" aria-label="Định dạng nội dung">
                        <button type="button" data-do="h2">Tiêu đề lớn</button>
                        <button type="button" data-do="h3">Tiêu đề nhỏ</button>
                        <button type="button" data-do="bold">In đậm</button>
                        <button type="button" data-do="bullet">Gạch đầu dòng</button>
                        <button type="button" data-do="quote">Trích dẫn</button>
                        <button type="button" data-do="image">Chèn ảnh</button>
                    </div>
                    <textarea name="content" id="fContent" rows="22"
                              placeholder="Viết nội dung ở đây. Dòng trống để sang đoạn mới."><c:out value="${form.content}"/></textarea>
                    <p class="bl-hint">
                        Gõ <code>## Tiêu đề</code> cho tiêu đề lớn, <code>- ý</code> cho gạch đầu dòng,
                        <code>**chữ**</code> để in đậm, <code>&gt; câu</code> để trích dẫn,
                        <code>[chữ](https://...)</code> để chèn link. Ảnh nằm trên một dòng riêng:
                        <code>![chú thích](ten-file.jpg)</code>.
                    </p>
                </div>
            </section>

            <aside class="bl-col-side">
                <div class="bl-panel">
                    <h2>Xuất bản</h2>
                    <label class="bl-check">
                        <input type="checkbox" name="published" id="fPublished" ${form.published ? 'checked' : ''}>
                        <span>Đăng bài (khách xem được)</span>
                    </label>
                    <p class="bl-hint">Bỏ chọn để lưu thành bản nháp, chỉ admin xem được.</p>
                    <button type="submit" class="bl-btn bl-btn-primary bl-block">Lưu bài viết</button>
                    <c:if test="${not isNew}">
                        <a class="bl-btn bl-block" href="${ctx}/admin/blogs/${form.id}/preview" target="_blank" rel="noopener">Xem trước</a>
                    </c:if>
                </div>

                <div class="bl-panel">
                    <h2>Ảnh đại diện</h2>
                    <div class="bl-thumbbox" id="thumbBox">
                        <img id="thumbImg" alt="" src="${thumbSrc}" ${empty thumbSrc ? 'hidden' : ''}>
                        <span id="thumbEmpty" ${empty thumbSrc ? '' : 'hidden'}>Chưa có ảnh</span>
                    </div>
                    <input type="text" name="thumbnailUrl" id="fThumb" maxlength="500"
                           value="<c:out value='${form.thumbnailUrl}'/>" placeholder="Tên file hoặc link ảnh">
                    <button type="button" class="bl-btn bl-block" id="btnThumb">Tải ảnh lên</button>
                </div>

                <div class="bl-panel">
                    <h2>Thông tin thêm</h2>
                    <label class="bl-field">
                        <span>Tác giả</span>
                        <input type="text" name="author" maxlength="100" value="<c:out value='${form.author}'/>"
                               placeholder="Để trống sẽ hiện PolySneaker">
                    </label>
                    <label class="bl-field">
                        <span>Đường dẫn bài viết</span>
                        <input type="text" name="slug" id="fSlug" maxlength="220" value="<c:out value='${form.slug}'/>"
                               placeholder="Tự tạo từ tiêu đề nếu để trống">
                    </label>
                    <p class="bl-hint">Link bài: <strong>/blog/<span id="slugShow"><c:out value="${empty form.slug ? '...' : form.slug}"/></span></strong></p>
                </div>
            </aside>
        </form>

        <input type="file" id="filePick" accept="image/*" hidden>

<script>
(function () {
    var CTX = '${ctx}';
    var IMG_BASE = '${imgBase}';
    var IS_NEW = '${isNew}' === 'true';
    // Nhận ảnh: ImageUploadController (field "file", trả {"fileName": "..."} hoặc {"error": "..."})
    var UPLOAD_URL = CTX + '/admin/upload/image';
    var UPLOAD_FIELD = 'file';

    var title = document.getElementById('fTitle');
    var slug = document.getElementById('fSlug');
    var slugShow = document.getElementById('slugShow');
    var summary = document.getElementById('fSummary');
    var sumCount = document.getElementById('sumCount');
    var content = document.getElementById('fContent');
    var thumb = document.getElementById('fThumb');
    var thumbImg = document.getElementById('thumbImg');
    var thumbEmpty = document.getElementById('thumbEmpty');
    var picker = document.getElementById('filePick');
    var pickFor = null; // 'thumb' hoặc 'inline'

    function slugify(s) {
        return s.replace(/đ/g, 'd').replace(/Đ/g, 'D').normalize('NFD').replace(/[\u0300-\u036f]/g, '')
            .toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/^-+|-+$/g, '');
    }
    function srcOf(f) {
        if (!f) return '';
        if (/^https?:\/\//.test(f)) return f;
        if (f.charAt(0) === '/') return CTX + f;
        return IMG_BASE + f;
    }

    /* đếm ký tự mô tả */
    function countSummary() { sumCount.textContent = summary.value.length + '/500'; }
    summary.addEventListener('input', countSummary); countSummary();

    /* tự tạo slug khi viết bài mới */
    var slugTouched = slug.value.trim() !== '';
    slug.addEventListener('input', function () {
        slugTouched = slug.value.trim() !== '';
        slugShow.textContent = slugify(slug.value) || '...';
    });
    title.addEventListener('input', function () {
        if (IS_NEW && !slugTouched) {
            slug.value = slugify(title.value);
            slugShow.textContent = slug.value || '...';
        }
    });

    /* ảnh đại diện */
    function showThumb() {
        var s = srcOf(thumb.value.trim());
        thumbImg.hidden = !s; thumbEmpty.hidden = !!s;
        if (s) thumbImg.src = s;
    }
    thumb.addEventListener('change', showThumb);
    thumbImg.addEventListener('error', function () { thumbImg.hidden = true; thumbEmpty.hidden = false; });

    function upload(file) {
        var fd = new FormData();
        fd.append(UPLOAD_FIELD, file);
        return fetch(UPLOAD_URL, { method: 'POST', body: fd }).then(function (r) {
            return r.json().catch(function () { return {}; }).then(function (j) {
                if (!r.ok || !j.fileName) throw new Error(j.error || 'Tải ảnh lên không thành công.');
                return j.fileName;
            });
        });
    }

    document.getElementById('btnThumb').addEventListener('click', function () { pickFor = 'thumb'; picker.click(); });
    picker.addEventListener('change', function () {
        var f = picker.files[0]; picker.value = '';
        if (!f) return;
        upload(f).then(function (name) {
            if (pickFor === 'thumb') { thumb.value = name; showThumb(); }
            else insertBlock('![](' + name + ')');
        }).catch(function (err) {
            alert(err.message || 'Tải ảnh lên không thành công.');
        });
    });

    /* thanh định dạng nội dung */
    function insertLinePrefix(prefix) {
        var s = content.selectionStart, e = content.selectionEnd, v = content.value;
        var ls = v.lastIndexOf('\n', s - 1) + 1;
        content.value = v.slice(0, ls) + prefix + v.slice(ls);
        content.focus();
        content.selectionStart = content.selectionEnd = e + prefix.length;
    }
    function wrapBold() {
        var s = content.selectionStart, e = content.selectionEnd, v = content.value;
        var sel = v.slice(s, e) || 'chữ in đậm';
        content.value = v.slice(0, s) + '**' + sel + '**' + v.slice(e);
        content.focus();
        content.selectionStart = s + 2; content.selectionEnd = s + 2 + sel.length;
    }
    function insertBlock(text) {
        var e = content.selectionEnd, v = content.value;
        var before = (e > 0 && v.charAt(e - 1) !== '\n') ? '\n' : '';
        var ins = before + text + '\n';
        content.value = v.slice(0, e) + ins + v.slice(e);
        content.focus();
        content.selectionStart = content.selectionEnd = e + ins.length;
    }
    document.querySelector('.bl-toolbar').addEventListener('click', function (ev) {
        var b = ev.target.closest('button[data-do]');
        if (!b) return;
        var act = b.getAttribute('data-do');
        if (act === 'h2') insertLinePrefix('## ');
        else if (act === 'h3') insertLinePrefix('### ');
        else if (act === 'bullet') insertLinePrefix('- ');
        else if (act === 'quote') insertLinePrefix('> ');
        else if (act === 'bold') wrapBold();
        else if (act === 'image') { pickFor = 'inline'; picker.click(); }
    });
})();
</script>

<%@ include file="../layouts/admin-footer.jsp" %>
