<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.functions" prefix="fn" %>

<c:set var="pageTitle" value="${empty form.id ? 'Thêm bộ sưu tập' : 'Sửa bộ sưu tập'}" />
<c:set var="adminMenu" value="lookbooks" />
<c:set var="pageCss" value="admin-lookbooks.css" />
<%@ include file="../layouts/admin-header.jsp" %>

<style>
    /* Chọn sản phẩm cho bộ sưu tập (góc vuông, không bo tròn) */
    .lbs-box { border: 1.5px solid #F2D9A8; background: #fff; }
    .lbs-bar {
        display: flex; flex-wrap: wrap; align-items: center; gap: 10px;
        padding: 10px 12px; border-bottom: 1px solid #F3E6CB; background: #FFFDF8;
    }
    .lbs-bar input[type="search"] {
        flex: 1; min-width: 180px; padding: 9px 12px;
        border: 1.5px solid #F2D9A8; border-radius: 0; background: #fff; font: inherit;
    }
    .lbs-bar input[type="search"]:focus { outline: none; border-color: #F7941D; }
    .lbs-count { margin-left: auto; font-size: 12.5px; font-weight: 800; color: #D97706; white-space: nowrap; }

    .lbs-list { display: grid; grid-template-columns: repeat(2, minmax(0, 1fr)); max-height: 340px; overflow-y: auto; }
    .lbs-item {
        position: relative; display: flex; align-items: center; gap: 12px;
        padding: 12px 14px; border-bottom: 1px solid #F8EEDA; cursor: pointer;
        font-size: 14px; line-height: 1.4; color: #5C4430;
        transition: background .2s;
    }
    .lbs-item:hover { background: #FFF6E6; }
    .lbs-item[hidden] { display: none; }
    .lbs-item input { position: absolute; opacity: 0; pointer-events: none; }

    .lbs-item i {
        position: relative; flex: none; width: 20px; height: 20px;
        border: 2px solid #D9C3A0; background: #fff;
        transition: background .2s, border-color .2s;
    }
    .lbs-item i::after {
        content: ""; position: absolute; left: 5px; top: 1px; width: 5px; height: 10px;
        border: solid #fff; border-width: 0 2px 2px 0;
        transform: rotate(45deg) scale(0); transition: transform .2s;
    }
    .lbs-item input:checked + i { background: #F7941D; border-color: #F7941D; }
    .lbs-item input:checked + i::after { transform: rotate(45deg) scale(1); }
    .lbs-item input:checked ~ span { font-weight: 800; color: #6E3A12; }
    .lbs-item input:focus-visible + i { outline: 2px solid #F7941D; outline-offset: 2px; }

    .lbs-none { padding: 22px 16px; text-align: center; font-size: 13.5px; color: #9A8C7E; }

    @media (max-width: 700px) { .lbs-list { grid-template-columns: minmax(0, 1fr); } }
</style>

        <h1 class="page-title">${empty form.id ? 'Thêm bộ sưu tập mới' : 'Chỉnh sửa bộ sưu tập'}</h1>
        <p class="page-sub">Chọn các sản phẩm thuộc bộ sưu tập (ví dụ hàng mới ra, Thu Đông) và thêm ảnh phối đồ. Khách bấm vào bộ sưu tập sẽ thấy đúng những sản phẩm đó.</p>

        <c:if test="${not empty error}">
            <div class="alert"><c:out value="${error}"/></div>
        </c:if>

        <form action="${ctx}/admin/lookbooks/save" method="post" class="card lb-form" id="lbForm">
            <c:if test="${not empty form.id}">
                <input type="hidden" name="id" value="${form.id}">
            </c:if>

            <div class="field">
                <label class="f" for="title">Tên bộ sưu tập <span class="req">*</span></label>
                <input type="text" id="title" name="title" maxlength="150" required autofocus
                       placeholder="VD: Amber Street"
                       value="<c:out value='${form.title}'/>">
            </div>

            <div class="field">
                <label class="f" for="description">Mô tả <span class="opt">(tuỳ chọn)</span></label>
                <textarea id="description" name="description" maxlength="1000"
                          placeholder="Một hai câu giới thiệu phong cách của bộ sưu tập"><c:out value="${form.description}"/></textarea>
            </div>

            <div class="field-row">
                <div class="field">
                    <label class="f" for="sortOrder">Thứ tự</label>
                    <input type="number" id="sortOrder" name="sortOrder" min="0" max="9999" step="1"
                           value="${empty form.sortOrder ? 0 : form.sortOrder}">
                    <div class="hint">Số nhỏ đứng trước.</div>
                </div>
            </div>

            <%-- ===== Sản phẩm thuộc bộ sưu tập ===== --%>
            <div class="field">
                <label class="f">Sản phẩm thuộc bộ sưu tập <span class="opt">(chọn nhiều)</span></label>

                <%-- Gom id đã chọn thành chuỗi ",1,5,9," để đối chiếu (không phụ thuộc kiểu Integer/Long) --%>
                <c:set var="pidCsv" value="," />
                <c:forEach var="x" items="${form.productIds}">
                    <c:set var="pidCsv" value="${pidCsv}${x}," />
                </c:forEach>

                <c:choose>
                    <c:when test="${not empty productOptions}">
                        <div class="lbs-box" id="prodBox">
                            <div class="lbs-bar">
                                <input type="search" id="prodSearch" placeholder="Tìm sản phẩm theo tên..." autocomplete="off">
                                <button type="button" class="btn-sm" id="prodAll">Chọn các mục đang hiện</button>
                                <button type="button" class="btn-sm" id="prodNone">Bỏ chọn hết</button>
                                <span class="lbs-count" id="prodCount"></span>
                            </div>
                            <div class="lbs-list" id="prodList">
                                <c:forEach var="o" items="${productOptions}">
                                    <c:set var="needle" value=",${o.id}," />
                                    <label class="lbs-item" data-name="<c:out value='${o.name}'/>">
                                        <input type="checkbox" name="productIds" value="${o.id}" ${fn:contains(pidCsv, needle) ? 'checked' : ''}>
                                        <i></i>
                                        <span><c:out value="${o.name}"/></span>
                                    </label>
                                </c:forEach>
                            </div>
                            <div class="lbs-none" id="prodNoneMsg" hidden>Không tìm thấy sản phẩm nào khớp.</div>
                        </div>
                        <div class="hint">Sản phẩm đã gắn vào ảnh bên dưới cũng tự hiện trong bộ sưu tập, không cần chọn lại ở đây.</div>
                    </c:when>
                    <c:otherwise>
                        <div class="lbp-empty">Chưa có sản phẩm nào. Hãy thêm sản phẩm trong trang quản lý sản phẩm trước.</div>
                    </c:otherwise>
                </c:choose>
            </div>

            <%-- ===== Ảnh bìa ===== --%>
            <div class="field">
                <label class="f">Ảnh bìa <span class="opt">(tuỳ chọn, để trống sẽ lấy ảnh đầu tiên trong bộ sưu tập)</span></label>
                <input type="hidden" id="coverImageUrl" name="coverImageUrl"
                       value="<c:out value='${form.coverImageUrl}'/>">
                <input type="file" id="coverFile" accept="image/*,.heic,.heif,.avif,.jfif,.jxl,.tif,.tiff" hidden>

                <div class="upload-row">
                    <button type="button" class="btn-sm" id="coverBrowse">Chọn ảnh bìa</button>
                    <button type="button" class="btn-sm" id="coverClear" hidden>Xóa ảnh bìa</button>
                    <span class="file-name" id="coverName">Chưa chọn ảnh</span>
                </div>
                <div class="hint" id="coverHint">Chọn file ảnh bất kỳ, tối đa 5MB.</div>
                <div class="cover-preview" id="coverPreview">
                    <span id="coverTxt">Chưa có ảnh bìa</span>
                    <img id="coverImg" alt="Xem trước ảnh bìa">
                </div>
            </div>

            <%-- ===== Các ảnh trong bộ sưu tập ===== --%>
            <div class="field">
                <div class="lbp-head">
                    <label class="f">Ảnh trong bộ sưu tập <span class="opt">(tối đa 24 ảnh)</span></label>
                    <button type="button" class="btn-sm" id="photoAdd">+ Thêm ảnh</button>
                </div>
                <input type="file" id="photoFile" accept="image/*,.heic,.heif,.avif,.jfif,.jxl,.tif,.tiff" multiple hidden>

                <div class="lbp-list" id="photoList">
                    <c:forEach var="it" items="${form.items}" varStatus="st">
                        <div class="lbp-row">
                            <div class="lbp-thumb"><img alt=""><span class="lbp-num"></span></div>
                            <div class="lbp-fields">
                                <input type="hidden" data-f="imageUrl" name="items[${st.index}].imageUrl"
                                       value="<c:out value='${it.imageUrl}'/>">
                                <input type="text" data-f="caption" name="items[${st.index}].caption" maxlength="300"
                                       placeholder="Chú thích ảnh (tuỳ chọn)" value="<c:out value='${it.caption}'/>">
                                <select data-f="productId" name="items[${st.index}].productId">
                                    <option value="">Không gắn sản phẩm</option>
                                    <c:forEach var="o" items="${productOptions}">
                                        <option value="${o.id}" ${o.id == it.productId ? 'selected' : ''}><c:out value="${o.name}"/></option>
                                    </c:forEach>
                                </select>
                            </div>
                            <div class="lbp-tools">
                                <button type="button" class="lbp-btn" data-act="up" aria-label="Dời lên">↑</button>
                                <button type="button" class="lbp-btn" data-act="down" aria-label="Dời xuống">↓</button>
                                <button type="button" class="lbp-btn del" data-act="del" aria-label="Xóa ảnh">×</button>
                            </div>
                        </div>
                    </c:forEach>
                </div>

                <div class="lbp-empty" id="photoEmpty">Chưa có ảnh nào. Bấm "+ Thêm ảnh" để chọn ảnh từ máy (chọn được nhiều ảnh cùng lúc).</div>
                <div class="hint" id="photoHint">Thứ tự các ảnh ở đây là thứ tự khách nhìn thấy. Gắn sản phẩm vào ảnh thì khách bấm được sang trang sản phẩm.</div>
            </div>

            <div class="field">
                <%-- Ô ẩn "_active": báo cho Spring biết checkbox có mặt trong form, bỏ tick thì mới lưu là false --%>
                <input type="hidden" name="_active" value="on">
                <label class="check">
                    <input type="checkbox" name="active" value="true" ${empty form.id or form.active ? 'checked' : ''}>
                    Hiển thị cho khách xem
                </label>
            </div>

            <div class="form-actions">
                <a href="${ctx}/admin/lookbooks" class="btn-cancel">Hủy</a>
                <button type="submit" class="btn-save">${empty form.id ? 'Thêm bộ sưu tập' : 'Lưu thay đổi'}</button>
            </div>
        </form>

<%-- Mẫu một dòng ảnh mới (JS nhân bản mỗi khi tải ảnh lên) --%>
<template id="photoTpl">
    <div class="lbp-row">
        <div class="lbp-thumb"><img alt=""><span class="lbp-num"></span></div>
        <div class="lbp-fields">
            <input type="hidden" data-f="imageUrl">
            <input type="text" data-f="caption" maxlength="300" placeholder="Chú thích ảnh (tuỳ chọn)">
            <select data-f="productId">
                <option value="">Không gắn sản phẩm</option>
                <c:forEach var="o" items="${productOptions}">
                    <option value="${o.id}"><c:out value="${o.name}"/></option>
                </c:forEach>
            </select>
        </div>
        <div class="lbp-tools">
            <button type="button" class="lbp-btn" data-act="up" aria-label="Dời lên">↑</button>
            <button type="button" class="lbp-btn" data-act="down" aria-label="Dời xuống">↓</button>
            <button type="button" class="lbp-btn del" data-act="del" aria-label="Xóa ảnh">×</button>
        </div>
    </div>
</template>

<script>
    // Nhận mọi file ảnh: trình duyệt báo là ảnh (image/...) hoặc đuôi file là đuôi ảnh quen thuộc
    var IMG_EXT = /\.(jpe?g|jfif|pjpeg|pjp|png|apng|gif|webp|avif|bmp|dib|tiff?|svg|ico|cur|heic|heif|jxl|jp2|j2k|jpx|psd|tga|dds|hdr|exr|pcx|pnm|pbm|pgm|ppm|wbmp|xbm)$/i;
    function isImageFile(file) {
        return (file.type && file.type.indexOf('image/') === 0) || IMG_EXT.test(file.name || '');
    }

    /* ---------- Chọn sản phẩm cho bộ sưu tập ---------- */
    (function () {
        var box = document.getElementById('prodBox');
        if (!box) return;

        var items = Array.prototype.slice.call(box.querySelectorAll('.lbs-item'));
        var search = document.getElementById('prodSearch');
        var count = document.getElementById('prodCount');
        var noneMsg = document.getElementById('prodNoneMsg');

        // bỏ dấu tiếng Việt để tìm "giay" ra "Giày"
        function norm(s) {
            return (s || '').toLowerCase().normalize('NFD').replace(/[\u0300-\u036f]/g, '').replace(/đ/g, 'd');
        }

        function updateCount() {
            var n = items.filter(function (it) { return it.querySelector('input').checked; }).length;
            count.textContent = 'Đã chọn ' + n + ' / ' + items.length + ' sản phẩm';
        }

        function applyFilter() {
            var q = norm(search.value.trim());
            var shown = 0;
            items.forEach(function (it) {
                var ok = !q || norm(it.getAttribute('data-name')).indexOf(q) !== -1;
                it.hidden = !ok;
                if (ok) shown++;
            });
            noneMsg.hidden = shown > 0;
        }

        search.addEventListener('input', applyFilter);
        // Enter trong ô tìm kiếm không được gửi form
        search.addEventListener('keydown', function (e) { if (e.key === 'Enter') e.preventDefault(); });

        document.getElementById('prodAll').addEventListener('click', function () {
            items.forEach(function (it) { if (!it.hidden) it.querySelector('input').checked = true; });
            updateCount();
        });
        document.getElementById('prodNone').addEventListener('click', function () {
            items.forEach(function (it) { it.querySelector('input').checked = false; });
            updateCount();
        });
        box.addEventListener('change', updateCount);

        updateCount();
    })();

    (function () {
        var ctx = '${ctx}';
        var MAX_SIZE = 5 * 1024 * 1024;
        var MAX_PHOTOS = 24;

        var form = document.getElementById('lbForm');
        var uploading = 0;

        function resolve(v) {
            v = (v || '').trim();
            if (!v) return '';
            if (/^https?:\/\//i.test(v)) return v;
            if (v.charAt(0) === '/') return ctx + v;
            return ctx + '/static/assets/images/' + v;
        }

        // Kiểm tra một file trước khi tải lên: trả về lời báo lỗi, hoặc null nếu ổn
        function check(file) {
            if (!isImageFile(file)) return 'không phải file ảnh';
            if (file.size > MAX_SIZE) return 'quá lớn (tối đa 5MB)';
            return null;
        }

        // Tải một ảnh lên server, trả về Promise với tên file do server đặt
        function upload(file) {
            var data = new FormData();
            data.append('file', file);
            return fetch(ctx + '/admin/upload/image', { method: 'POST', body: data, credentials: 'same-origin' })
                .then(function (res) {
                    return res.json().catch(function () { return {}; }).then(function (body) {
                        if (!res.ok || !body.fileName) {
                            throw new Error(body.error || 'Tải ảnh thất bại, hãy thử lại hoặc đăng nhập lại.');
                        }
                        return body.fileName;
                    });
                });
        }

        function setMsg(el, text, type) {
            el.textContent = text;
            el.className = 'hint' + (type ? ' ' + type : '');
        }

        /* ---------- Ảnh bìa ---------- */
        var cover = document.getElementById('coverImageUrl');
        var coverFile = document.getElementById('coverFile');
        var coverBrowse = document.getElementById('coverBrowse');
        var coverClear = document.getElementById('coverClear');
        var coverName = document.getElementById('coverName');
        var coverHint = document.getElementById('coverHint');
        var coverImg = document.getElementById('coverImg');
        var coverTxt = document.getElementById('coverTxt');
        var coverDefault = coverHint.textContent;

        function showCover() {
            var v = cover.value.trim();
            var src = resolve(v);
            coverName.textContent = v || 'Chưa chọn ảnh';
            coverClear.hidden = !v;
            if (!src) {
                coverImg.style.display = 'none';
                coverTxt.style.display = '';
                coverTxt.textContent = 'Chưa có ảnh bìa';
                return;
            }
            coverImg.onload = function () { coverImg.style.display = 'block'; coverTxt.style.display = 'none'; };
            coverImg.onerror = function () { coverImg.style.display = 'none'; coverTxt.style.display = ''; coverTxt.textContent = 'Không xem trước được ảnh này'; };
            coverImg.src = src;
        }

        coverBrowse.addEventListener('click', function () { coverFile.click(); });
        coverClear.addEventListener('click', function () {
            cover.value = '';
            coverFile.value = '';
            setMsg(coverHint, coverDefault, '');
            showCover();
        });

        coverFile.addEventListener('change', function () {
            var file = coverFile.files[0];
            coverFile.value = '';
            if (!file) return;
            var err = check(file);
            if (err) { setMsg(coverHint, '"' + file.name + '" ' + err + '.', 'err'); return; }

            uploading++;
            coverBrowse.disabled = true;
            setMsg(coverHint, 'Đang tải ảnh lên...', '');
            upload(file)
                .then(function (name) { cover.value = name; setMsg(coverHint, 'Đã tải ảnh bìa lên.', 'ok'); showCover(); })
                .catch(function (e) { setMsg(coverHint, e.message, 'err'); })
                .then(function () { uploading--; coverBrowse.disabled = false; });
        });

        showCover();

        /* ---------- Các ảnh trong bộ sưu tập ---------- */
        var list = document.getElementById('photoList');
        var addBtn = document.getElementById('photoAdd');
        var photoFile = document.getElementById('photoFile');
        var empty = document.getElementById('photoEmpty');
        var photoHint = document.getElementById('photoHint');
        var tpl = document.getElementById('photoTpl');
        var photoDefault = photoHint.textContent;

        function rows() { return Array.prototype.slice.call(list.querySelectorAll('.lbp-row')); }

        // Đánh số lại thứ tự, đặt lại tên ô cho đúng chỉ số (items[0], items[1]...), khóa nút ở đầu/cuối
        function refresh() {
            var rs = rows();
            rs.forEach(function (row, i) {
                row.querySelectorAll('[data-f]').forEach(function (el) {
                    el.name = 'items[' + i + '].' + el.getAttribute('data-f');
                });
                row.querySelector('.lbp-num').textContent = i + 1;

                var img = row.querySelector('img');
                var src = resolve(row.querySelector('[data-f="imageUrl"]').value);
                if (img.getAttribute('src') !== src) img.setAttribute('src', src);
                img.onerror = function () { row.classList.add('broken'); };

                row.querySelector('[data-act="up"]').disabled = (i === 0);
                row.querySelector('[data-act="down"]').disabled = (i === rs.length - 1);
            });
            empty.hidden = rs.length > 0;
            addBtn.style.display = rs.length >= MAX_PHOTOS ? 'none' : '';
        }

        function addRow(fileName) {
            var node = tpl.content.firstElementChild.cloneNode(true);
            node.querySelector('[data-f="imageUrl"]').value = fileName;
            list.appendChild(node);
        }

        // Dời lên / dời xuống / xóa
        list.addEventListener('click', function (e) {
            var btn = e.target.closest('.lbp-btn');
            if (!btn) return;
            var row = btn.closest('.lbp-row');
            var act = btn.getAttribute('data-act');
            if (act === 'del') {
                row.remove();
            } else if (act === 'up' && row.previousElementSibling) {
                list.insertBefore(row, row.previousElementSibling);
            } else if (act === 'down' && row.nextElementSibling) {
                list.insertBefore(row.nextElementSibling, row);
            }
            setMsg(photoHint, photoDefault, '');
            refresh();
        });

        addBtn.addEventListener('click', function () { photoFile.click(); });

        photoFile.addEventListener('change', function () {
            var files = Array.prototype.slice.call(photoFile.files);
            photoFile.value = '';
            if (!files.length) return;

            var notes = [];
            var room = MAX_PHOTOS - rows().length;
            if (files.length > room) {
                notes.push('Chỉ thêm được ' + Math.max(room, 0) + ' ảnh nữa, các ảnh dư đã bị bỏ qua.');
                files = files.slice(0, Math.max(room, 0));
            }

            var valid = files.filter(function (f) {
                var err = check(f);
                if (err) { notes.push('"' + f.name + '" ' + err + '.'); return false; }
                return true;
            });
            if (!valid.length) { setMsg(photoHint, notes.join(' ') || photoDefault, 'err'); return; }

            uploading++;
            addBtn.disabled = true;
            var done = 0;
            setMsg(photoHint, 'Đang tải ảnh 1/' + valid.length + '...', '');

            // Tải lần lượt từng ảnh để giữ đúng thứ tự đã chọn
            valid.reduce(function (chain, file) {
                return chain.then(function () {
                    return upload(file)
                        .then(function (name) { addRow(name); refresh(); })
                        .catch(function (e) { notes.push('"' + file.name + '": ' + e.message); })
                        .then(function () {
                            done++;
                            if (done < valid.length) setMsg(photoHint, 'Đang tải ảnh ' + (done + 1) + '/' + valid.length + '...', '');
                        });
                });
            }, Promise.resolve()).then(function () {
                uploading--;
                addBtn.disabled = false;
                if (notes.length) setMsg(photoHint, notes.join(' '), 'err');
                else setMsg(photoHint, 'Đã tải ' + valid.length + ' ảnh lên.', 'ok');
            });
        });

        // Không cho gửi form khi ảnh đang tải dở; trước khi gửi đảm bảo tên các ô đúng chỉ số
        form.addEventListener('submit', function (e) {
            if (uploading > 0) {
                e.preventDefault();
                setMsg(photoHint, 'Ảnh đang tải lên, vui lòng đợi một chút rồi bấm lưu.', 'err');
                return;
            }
            refresh();
        });

        refresh();
    })();
</script>

<%@ include file="../layouts/admin-footer.jsp" %>
