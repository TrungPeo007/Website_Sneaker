<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>

<c:set var="pageTitle" value="${empty form.id ? 'Thêm sản phẩm' : 'Sửa sản phẩm'}" />
<c:set var="adminMenu" value="products" />
<c:set var="pageCss" value="admin-product-form.css" />
<%@ include file="../layouts/admin-header.jsp" %>

        <h1 class="page-title">${empty form.id ? 'Thêm sản phẩm mới' : 'Chỉnh sửa sản phẩm'}</h1>
        <p class="page-sub">Điền thông tin sản phẩm, kích cỡ và số lượng tồn kho.</p>

        <c:if test="${not empty error}">
            <div class="alert"><c:out value="${error}"/></div>
        </c:if>

        <form action="${ctx}/admin/products/save" method="post" class="card" id="productForm">
            <c:if test="${not empty form.id}">
                <input type="hidden" name="id" value="${form.id}">
            </c:if>

            <div class="grid">
                <div class="full">
                    <label class="f" for="name">Tên sản phẩm <span class="req">*</span></label>
                    <input type="text" id="name" name="name" maxlength="200" required
                           value="<c:out value='${form.name}'/>">
                </div>

                <div>
                    <label class="f" for="categoryId">Danh mục <span class="req">*</span></label>
                    <select id="categoryId" name="categoryId" required>
                        <option value="">-- Chọn danh mục --</option>
                        <c:forEach var="c" items="${categories}">
                            <option value="${c.id}" ${c.id == form.categoryId ? 'selected' : ''}>
                                <c:out value="${c.name}"/>
                            </option>
                        </c:forEach>
                    </select>
                    <c:if test="${empty categories}">
                        <div class="hint err">Chưa có danh mục nào để chọn. Hãy
                            <a href="${ctx}/admin/categories" style="text-decoration:underline">thêm danh mục</a> trước.</div>
                    </c:if>
                </div>

                <div>
                    <label class="f" for="badge">Nhãn (tuỳ chọn)</label>
                    <input type="text" id="badge" name="badge" maxlength="30" placeholder="VD: Bán chạy, Mới"
                           value="<c:out value='${form.badge}'/>">
                </div>

                <div>
                    <label class="f" for="originalPrice">Giá gốc (₫) <span class="req">*</span></label>
                    <input type="number" id="originalPrice" name="originalPrice" min="0" step="1000" required
                           value="${form.originalPrice}" placeholder="Nhập giá gốc sản phẩm">
                </div>

                <div>
                    <label class="f" for="salePrice">Giá bán (₫) <span style="font-weight:600;color:var(--muted)">(tuỳ chọn)</span></label>
                    <input type="number" id="salePrice" name="salePrice" min="0" step="1000"
                           placeholder="Nhập mã giảm giá"
                           value="${form.salePrice}">
                </div>
                <div class="full">
                    <label class="f">Ảnh đại diện</label>

                    <%-- Tên file ảnh sau khi tải lên được lưu ở đây và gửi cùng form --%>
                    <input type="hidden" id="mainImageUrl" name="mainImageUrl"
                           value="<c:out value='${form.mainImageUrl}'/>">
                    <input type="file" id="imageFile" accept="image/*,.heic,.heif,.avif,.jfif,.jxl,.tif,.tiff" hidden>

                    <div class="upload-row">
                        <button type="button" class="btn-browse" id="browseBtn">
                            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="17 8 12 3 7 8"/><line x1="12" y1="3" x2="12" y2="15"/></svg>
                            Chọn ảnh từ máy
                        </button>
                        <button type="button" class="btn-sm" id="clearImg" hidden>Xóa ảnh</button>
                        <span class="file-name" id="fileName">Chưa chọn ảnh</span>
                    </div>
                    <div class="hint" id="uploadHint">Chọn file ảnh bất kỳ (JPG, PNG, WEBP, AVIF, GIF, BMP, SVG...), tối đa 5MB.</div>

                    <div class="preview" id="preview">
                        <span id="previewTxt">Chưa có ảnh</span>
                        <img id="previewImg" alt="Xem trước">
                    </div>
                </div>

                <%-- ===== Ảnh phụ (các góc chụp khác) ===== --%>
                <div class="full">
                    <label class="f">Ảnh phụ <span class="opt">(các góc chụp khác, tối đa 10 ảnh)</span></label>
                    <input type="file" id="galleryFile" accept="image/*,.heic,.heif,.avif,.jfif,.jxl,.tif,.tiff" multiple hidden>

                    <div class="gal-grid" id="galGrid">
                        <c:forEach var="g" items="${form.galleryImages}">
                            <div class="gal-item">
                                <input type="hidden" name="galleryImages" value="<c:out value='${g}'/>">
                                <img alt="">
                                <span class="gal-num"></span>
                                <div class="gal-tools">
                                    <button type="button" class="gal-btn" data-act="left" aria-label="Dời sang trái">‹</button>
                                    <button type="button" class="gal-btn" data-act="right" aria-label="Dời sang phải">›</button>
                                    <button type="button" class="gal-btn del" data-act="del" aria-label="Xóa ảnh">×</button>
                                </div>
                            </div>
                        </c:forEach>
                        <button type="button" class="gal-add" id="galAdd">
                            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
                            Thêm ảnh
                        </button>
                    </div>
                    <div class="hint" id="galHint">Chọn được nhiều ảnh cùng lúc, đuôi ảnh nào cũng được. Thứ tự các ô là thứ tự hiển thị ở trang sản phẩm, ảnh đại diện luôn hiện đầu tiên.</div>
                </div>

                <div class="full">
                    <label class="f" for="description">Mô tả</label>
                    <textarea id="description" name="description"><c:out value="${form.description}"/></textarea>
                </div>

                <%-- ===== Chất liệu + Thông số kỹ thuật (nằm ngay dưới Mô tả) ===== --%>
                <div class="full">
                    <label class="f" for="material">Chất liệu</label>
                    <input type="text" id="material" name="material" maxlength="500"
                           placeholder="VD: Da thật, đế cao su, lót vải lưới"
                           value="<c:out value='${form.material}'/>">
                </div>

                <div class="full">
                    <label class="f" for="specifications">Thông số kỹ thuật</label>
                    <textarea id="specifications" name="specifications"
                              placeholder="Mỗi dòng một thông số, ví dụ:&#10;Trọng lượng: 350g&#10;Chiều cao cổ giày: Cao cổ&#10;Xuất xứ: Việt Nam"><c:out value="${form.specifications}"/></textarea>
                    <div class="hint">Mỗi dòng ghi một thông số để khách dễ đọc.</div>
                </div>

                <div class="full">
                    <label class="check">
                        <input type="checkbox" name="active" value="true"
                               ${empty form.id or form.active ? 'checked' : ''}>
                        Đang bán (hiển thị ngoài cửa hàng)
                    </label>
                </div>
            </div>

            <hr style="border:none;border-top:1px solid #F8EEDA;margin:26px 0 18px;">

            <div class="sizes-head">
                <h3>Kích cỡ &amp; tồn kho <span class="req">*</span></h3>
                <button type="button" class="btn-sm" id="addSize">+ Thêm size</button>
            </div>

            <div id="sizeRows">
                <c:forEach var="s" items="${form.sizes}" varStatus="st">
                    <div class="size-row">
                        <input type="number" name="sizes" step="0.5" min="1" max="99.5" placeholder="Size (VD: 42)" value="${s}">
                        <input type="number" name="stocks" min="0" step="1" placeholder="Tồn kho" value="${form.stocks[st.index]}">
                        <button type="button" class="btn-x" aria-label="Xóa dòng">×</button>
                    </div>
                </c:forEach>
                <c:if test="${empty form.sizes}">
                    <div class="size-row">
                        <input type="number" name="sizes" step="0.5" min="1" max="99.5" placeholder="Size (VD: 42)">
                        <input type="number" name="stocks" min="0" step="1" placeholder="Tồn kho" value="0">
                        <button type="button" class="btn-x" aria-label="Xóa dòng">×</button>
                    </div>
                </c:if>
            </div>
            <div class="hint">Dòng size để trống sẽ được bỏ qua. Size trùng nhau thì lấy dòng sau.</div>

            <div class="form-actions">
                <a href="${ctx}/admin/products" class="btn-cancel">Hủy</a>
                <button type="submit" class="btn-save">${empty form.id ? 'Thêm sản phẩm' : 'Lưu thay đổi'}</button>
            </div>
        </form>

<script>
    // Nhận mọi file ảnh: trình duyệt báo là ảnh (image/...) hoặc đuôi file là đuôi ảnh quen thuộc.
    // Kiểm tra thêm đuôi vì một số loại (HEIC, JFIF, AVIF...) trình duyệt có thể không báo loại file.
   var IMG_EXT = /\.(jpe?g|jfif|pjpeg|pjp|png|apng|gif|webp|avif|bmp|dib|tiff?|svg|ico|cur|heic|heif|jxl|jp2|j2k|jpx|psd|tga|dds|hdr|exr|pcx|pnm|pbm|pgm|ppm|wbmp|xbm)$/i;
    function isImageFile(file) {
        return (file.type && file.type.indexOf('image/') === 0) || IMG_EXT.test(file.name || '');
    }

    // Thêm / xóa dòng size
    (function () {
        var wrap = document.getElementById('sizeRows');

        document.getElementById('addSize').addEventListener('click', function () {
            var row = document.createElement('div');
            row.className = 'size-row';
            row.innerHTML =
                '<input type="number" name="sizes" step="0.5" min="1" max="99.5" placeholder="Size (VD: 42)">' +
                '<input type="number" name="stocks" min="0" step="1" placeholder="Tồn kho" value="0">' +
                '<button type="button" class="btn-x" aria-label="Xóa dòng">×</button>';
            wrap.appendChild(row);
        });

        wrap.addEventListener('click', function (e) {
            if (!e.target.classList.contains('btn-x')) return;
            var rows = wrap.querySelectorAll('.size-row');
            if (rows.length > 1) e.target.parentNode.remove();
            else rows[0].querySelectorAll('input').forEach(function (i) { i.value = ''; });
        });
    })();

    // Chọn ảnh từ máy -> tải lên server -> lưu tên file vào input ẩn
    (function () {
        var ctx = '${ctx}';
        var MAX_SIZE = 5 * 1024 * 1024;

        var form = document.getElementById('productForm');
        var hidden = document.getElementById('mainImageUrl');
        var fileInput = document.getElementById('imageFile');
        var browseBtn = document.getElementById('browseBtn');
        var clearBtn = document.getElementById('clearImg');
        var nameEl = document.getElementById('fileName');
        var hint = document.getElementById('uploadHint');
        var img = document.getElementById('previewImg');
        var txt = document.getElementById('previewTxt');
        var defaultHint = hint.textContent;
        var uploading = false;

        function resolve(v) {
            v = (v || '').trim();
            if (!v) return '';
            if (/^https?:\/\//i.test(v)) return v;
            if (v.charAt(0) === '/') return ctx + v;
            return ctx + '/static/assets/images/' + v;
        }

        function setMsg(message, type) {
            hint.textContent = message;
            hint.className = 'hint' + (type ? ' ' + type : '');
        }

        function show() {
            var value = hidden.value.trim();
            var src = resolve(value);
            nameEl.textContent = value ? value : 'Chưa chọn ảnh';
            clearBtn.hidden = !value;

            if (!src) {
                img.style.display = 'none';
                txt.style.display = '';
                txt.textContent = 'Chưa có ảnh';
                return;
            }
            img.onload = function () { img.style.display = 'block'; txt.style.display = 'none'; };
            img.onerror = function () { img.style.display = 'none'; txt.style.display = ''; txt.textContent = 'Không xem trước được ảnh (trình duyệt không hiển thị được loại ảnh này): ' + src; };
            img.src = src;
        }

        browseBtn.addEventListener('click', function () { fileInput.click(); });

        clearBtn.addEventListener('click', function () {
            hidden.value = '';
            fileInput.value = '';
            setMsg(defaultHint, '');
            show();
        });

        fileInput.addEventListener('change', function () {
            var file = fileInput.files[0];
            if (!file) return;

            if (!isImageFile(file)) {
                setMsg('File này không phải file ảnh, vui lòng chọn file ảnh khác.', 'err');
                fileInput.value = '';
                return;
            }
            if (file.size > MAX_SIZE) {
                setMsg('Ảnh quá lớn, tối đa 5MB.', 'err');
                fileInput.value = '';
                return;
            }

            var data = new FormData();
            data.append('file', file);

            uploading = true;
            browseBtn.disabled = true;
            setMsg('Đang tải ảnh lên...', '');

            fetch(ctx + '/admin/upload/image', { method: 'POST', body: data, credentials: 'same-origin' })
                .then(function (res) {
                    return res.json().catch(function () { return {}; }).then(function (body) {
                        return { ok: res.ok, body: body };
                    });
                })
                .then(function (r) {
                    if (!r.ok || !r.body.fileName) {
                        throw new Error(r.body.error || 'Tải ảnh thất bại, hãy thử lại hoặc đăng nhập lại.');
                    }
                    hidden.value = r.body.fileName;
                    setMsg('Đã tải ảnh lên thành công.', 'ok');
                    show();
                })
                .catch(function (err) { setMsg(err.message, 'err'); })
                .finally(function () {
                    uploading = false;
                    browseBtn.disabled = false;
                    fileInput.value = '';
                });
        });

        // Không cho gửi form khi ảnh đang tải lên dở
        form.addEventListener('submit', function (e) {
            if (uploading) {
                e.preventDefault();
                setMsg('Ảnh đang tải lên, vui lòng đợi một chút rồi bấm lưu.', 'err');
            }
        });

        show();
    })();

    // Ảnh phụ: chọn nhiều ảnh, tải lên, đổi thứ tự, xóa
    (function () {
        var ctx = '${ctx}';
        var MAX_SIZE = 5 * 1024 * 1024;
        var MAX_COUNT = 10;

        var form = document.getElementById('productForm');
        var grid = document.getElementById('galGrid');
        var addBtn = document.getElementById('galAdd');
        var fileInput = document.getElementById('galleryFile');
        var hint = document.getElementById('galHint');
        var defaultHint = hint.textContent;
        var uploading = false;

        function resolve(v) {
            v = (v || '').trim();
            if (!v) return '';
            if (/^https?:\/\//i.test(v)) return v;
            if (v.charAt(0) === '/') return ctx + v;
            return ctx + '/static/assets/images/' + v;
        }

        function setMsg(message, type) {
            hint.textContent = message;
            hint.className = 'hint' + (type ? ' ' + type : '');
        }

        function items() { return Array.prototype.slice.call(grid.querySelectorAll('.gal-item')); }

        // Cập nhật số thứ tự, khóa nút ‹ › ở đầu/cuối, ẩn nút thêm khi đủ ảnh
        function refresh() {
            var list = items();
            list.forEach(function (it, i) {
                it.querySelector('.gal-num').textContent = i + 1;
                it.querySelector('[data-act="left"]').disabled = (i === 0);
                it.querySelector('[data-act="right"]').disabled = (i === list.length - 1);
            });
            addBtn.style.display = list.length >= MAX_COUNT ? 'none' : '';
        }

        function buildTools(item) {
            var tools = document.createElement('div');
            tools.className = 'gal-tools';
            [['left', '‹', 'Dời sang trái'], ['right', '›', 'Dời sang phải'], ['del', '×', 'Xóa ảnh']].forEach(function (b) {
                var btn = document.createElement('button');
                btn.type = 'button';
                btn.className = 'gal-btn' + (b[0] === 'del' ? ' del' : '');
                btn.setAttribute('data-act', b[0]);
                btn.setAttribute('aria-label', b[2]);
                btn.textContent = b[1];
                tools.appendChild(btn);
            });
            item.appendChild(tools);
        }

        function addItem(fileName) {
            var item = document.createElement('div');
            item.className = 'gal-item';

            var input = document.createElement('input');
            input.type = 'hidden';
            input.name = 'galleryImages';
            input.value = fileName;

            var im = document.createElement('img');
            im.alt = '';
            im.src = resolve(fileName);
            im.onerror = function () { item.classList.add('broken'); };

            var num = document.createElement('span');
            num.className = 'gal-num';

            item.appendChild(input);
            item.appendChild(im);
            item.appendChild(num);
            buildTools(item);
            grid.insertBefore(item, addBtn);
        }

        // Ảnh đã có sẵn khi mở trang sửa: gắn đường dẫn ảnh
        items().forEach(function (it) {
            var im = it.querySelector('img');
            var v = it.querySelector('input[name="galleryImages"]').value;
            im.src = resolve(v);
            im.onerror = function () { it.classList.add('broken'); };
        });

        // Đổi thứ tự / xóa
        grid.addEventListener('click', function (e) {
            var btn = e.target.closest('.gal-btn');
            if (!btn) return;
            var item = btn.closest('.gal-item');
            var act = btn.getAttribute('data-act');
            if (act === 'del') {
                item.remove();
            } else if (act === 'left' && item.previousElementSibling && item.previousElementSibling.classList.contains('gal-item')) {
                grid.insertBefore(item, item.previousElementSibling);
            } else if (act === 'right' && item.nextElementSibling && item.nextElementSibling.classList.contains('gal-item')) {
                grid.insertBefore(item.nextElementSibling, item);
            }
            setMsg(defaultHint, '');
            refresh();
        });

        addBtn.addEventListener('click', function () { fileInput.click(); });

        function uploadOne(file) {
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

        fileInput.addEventListener('change', function () {
            var files = Array.prototype.slice.call(fileInput.files);
            fileInput.value = '';
            if (!files.length) return;

            var room = MAX_COUNT - items().length;
            var notes = [];
            if (files.length > room) {
                notes.push('Chỉ thêm được ' + room + ' ảnh nữa, các ảnh dư đã bị bỏ qua.');
                files = files.slice(0, room);
            }

            var valid = files.filter(function (f) {
                if (!isImageFile(f)) { notes.push('"' + f.name + '" không phải file ảnh.'); return false; }
                if (f.size > MAX_SIZE) { notes.push('"' + f.name + '" quá lớn (tối đa 5MB).'); return false; }
                return true;
            });

            if (!valid.length) { setMsg(notes.join(' ') || defaultHint, 'err'); return; }

            uploading = true;
            addBtn.disabled = true;
            var done = 0, failed = 0;
            setMsg('Đang tải ảnh 1/' + valid.length + '...', '');

            // Tải lần lượt từng ảnh để giữ đúng thứ tự đã chọn
            valid.reduce(function (chain, file) {
                return chain.then(function () {
                    return uploadOne(file).then(function (name) {
                        addItem(name);
                        refresh();
                    }).catch(function (err) {
                        failed++;
                        notes.push('"' + file.name + '": ' + err.message);
                    }).then(function () {
                        done++;
                        if (done < valid.length) setMsg('Đang tải ảnh ' + (done + 1) + '/' + valid.length + '...', '');
                    });
                });
            }, Promise.resolve()).then(function () {
                uploading = false;
                addBtn.disabled = false;
                if (notes.length) setMsg(notes.join(' '), 'err');
                else setMsg('Đã tải ' + valid.length + ' ảnh lên thành công.', 'ok');
            });
        });

        // Không cho gửi form khi ảnh đang tải dở
        form.addEventListener('submit', function (e) {
            if (uploading) {
                e.preventDefault();
                setMsg('Ảnh đang tải lên, vui lòng đợi một chút rồi bấm lưu.', 'err');
            }
        });

        refresh();
    })();
</script>
<script src="${ctx}/static/assets/js/custom-select.js"></script>
<%@ include file="../layouts/admin-footer.jsp" %>
