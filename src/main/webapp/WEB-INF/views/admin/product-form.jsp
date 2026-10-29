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
                    <input type="file" id="imageFile" accept="image/png,image/jpeg,image/webp,image/gif" hidden>

                    <div class="upload-row">
                        <button type="button" class="btn-browse" id="browseBtn">
                            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="17 8 12 3 7 8"/><line x1="12" y1="3" x2="12" y2="15"/></svg>
                            Chọn ảnh từ máy
                        </button>
                        <button type="button" class="btn-sm" id="clearImg" hidden>Xóa ảnh</button>
                        <span class="file-name" id="fileName">Chưa chọn ảnh</span>
                    </div>
                    <div class="hint" id="uploadHint">Hỗ trợ JPG, PNG, WEBP, GIF, tối đa 5MB.</div>

                    <div class="preview" id="preview">
                        <span id="previewTxt">Chưa có ảnh</span>
                        <img id="previewImg" alt="Xem trước">
                    </div>
                </div>

                <div class="full">
                    <label class="f" for="description">Mô tả</label>
                    <textarea id="description" name="description"><c:out value="${form.description}"/></textarea>
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
            img.onerror = function () { img.style.display = 'none'; txt.style.display = ''; txt.textContent = 'Không tải được ảnh: ' + src; };
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

            if (!/^image\/(png|jpe?g|webp|gif)$/i.test(file.type)) {
                setMsg('Vui lòng chọn file ảnh JPG, PNG, WEBP hoặc GIF.', 'err');
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
</script>

<%@ include file="../layouts/admin-footer.jsp" %>
