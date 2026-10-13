<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>${empty form.id ? 'Thêm sản phẩm' : 'Sửa sản phẩm'}</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Nunito+Sans:wght@300;400;600;700;800&display=swap" rel="stylesheet">

    <style>
        :root {
            --orange: #F7941D; --orange-dark: #E8830C; --amber: #D97706;
            --cream: #FFF6E6; --cream-border: #F8E3BC; --brown: #5C4430; --head: #6E3A12;
            --bg: #FFFBF2; --text: #4A4038; --muted: #9A8C7E;
            --side: #3B2412; --danger: #C2410C;
        }
        * { box-sizing: border-box; }
        body { margin: 0; min-height: 100vh; display: flex; font-family: 'Nunito Sans', Arial, sans-serif; letter-spacing: .1px; color: var(--text); background: var(--bg); -webkit-font-smoothing: antialiased; }
        a { color: inherit; text-decoration: none; }
        button { font-family: inherit; }

        /* Sidebar */
        .side { width: 252px; flex-shrink: 0; position: sticky; top: 0; align-self: flex-start; height: 100vh; display: flex; flex-direction: column; padding: 24px 16px; background: linear-gradient(180deg, var(--side) 0%, #2B190B 100%); color: #F3E4CE; }
        .side-brand { display: flex; align-items: center; gap: 12px; padding: 0 8px 22px; border-bottom: 1px solid rgba(255, 226, 170, .14); }
        .side-logo { width: 38px; height: 38px; border-radius: 50%; border: 1.5px solid rgba(247, 148, 29, .6); background: rgba(247, 148, 29, .14); color: var(--orange); font-weight: 800; font-size: 13px; display: flex; align-items: center; justify-content: center; }
        .side-name { font-weight: 800; font-size: 15px; color: #FFF3DC; line-height: 1.2; }
        .side-role { font-size: 10.5px; font-weight: 700; letter-spacing: 1px; color: #D9A25C; margin-top: 2px; }
        .side-nav { display: flex; flex-direction: column; gap: 4px; margin-top: 22px; }
        .side-nav a { display: flex; align-items: center; gap: 12px; padding: 11px 12px; border-radius: 12px; font-size: 14px; font-weight: 600; color: #E7D2B2; transition: background .15s, color .15s; }
        .side-nav a:hover { background: rgba(255, 226, 170, .08); color: #fff; }
        .side-nav a.active { background: rgba(247, 148, 29, .2); color: #FFB74D; box-shadow: inset 3px 0 0 var(--orange); }
        .side-foot { margin-top: auto; padding: 14px 8px 0; border-top: 1px solid rgba(255, 226, 170, .14); }
        .side-foot a { font-size: 13px; font-weight: 600; color: #D9BC93; padding: 8px 4px; display: block; }
        .side-foot a:hover { color: #fff; }

        /* Nội dung */
        .content { flex: 1; min-width: 0; padding: 48px 40px 64px; }
        .content-in { max-width: 860px; margin: 0 auto; }
        .page-title { font-size: 28px; font-weight: 800; color: var(--head); margin: 0; }
        .page-sub { font-size: 13px; color: var(--muted); margin: 4px 0 24px; }

        .alert { margin-bottom: 16px; padding: 12px 18px; border-radius: 12px; font-size: 13.5px; font-weight: 700; background: #FFE9E0; color: var(--danger); }

        .card { background: #fff; border: 1px solid #FBF0D6; border-radius: 20px; box-shadow: 0 8px 26px rgba(200, 140, 40, .07); padding: 28px; }
        .grid { display: grid; grid-template-columns: 1fr 1fr; gap: 18px 20px; }
        .full { grid-column: 1 / -1; }
        label.f { display: block; font-size: 12.5px; font-weight: 700; color: var(--brown); margin-bottom: 6px; }
        .req { color: var(--danger); }
        input[type=text], input[type=number], select, textarea {
            width: 100%; padding: 11px 14px; border-radius: 12px; border: 1.5px solid var(--cream-border);
            background: var(--cream); font-family: inherit; font-size: 14px; color: var(--text); outline: none; transition: border-color .15s, background .15s;
        }
        textarea { min-height: 96px; resize: vertical; }
        input:focus, select:focus, textarea:focus { border-color: var(--orange); background: #fff; }
        .hint { font-size: 11.5px; color: var(--muted); margin-top: 5px; }

        .check { display: flex; align-items: center; gap: 10px; font-size: 14px; font-weight: 700; color: var(--head); }
        .check input { width: 18px; height: 18px; accent-color: var(--orange); }

        /* Size */
        .sizes-head { display: flex; align-items: center; justify-content: space-between; margin: 6px 0 10px; }
        .sizes-head h3 { margin: 0; font-size: 15px; font-weight: 800; color: var(--head); }
        .size-row { display: grid; grid-template-columns: 1fr 1fr 40px; gap: 10px; margin-bottom: 10px; align-items: center; }
        .btn-sm { height: 36px; padding: 0 16px; border-radius: 10px; border: 1px solid var(--cream-border); background: #fff; color: var(--head); font-size: 13px; font-weight: 700; cursor: pointer; display: inline-flex; align-items: center; transition: background .15s, border-color .15s; }
        .btn-sm:hover { background: var(--cream); border-color: var(--orange); }
        .btn-x { width: 40px; height: 40px; border-radius: 10px; border: 1px solid var(--cream-border); background: #fff; color: #B7894F; font-size: 18px; cursor: pointer; }
        .btn-x:hover { background: #FFEDE5; color: var(--danger); border-color: #F2B79B; }

        /* Xem trước ảnh */
        .preview { margin-top: 10px; height: 150px; border-radius: 14px; background: #FFFBEA; border: 1px dashed var(--cream-border); display: flex; align-items: center; justify-content: center; overflow: hidden; color: var(--muted); font-size: 12px; }
        .preview img { width: 100%; height: 100%; object-fit: contain; display: none; }

        .form-actions { display: flex; justify-content: flex-end; gap: 10px; margin-top: 26px; }
        .btn-save { height: 44px; padding: 0 28px; border: none; border-radius: 999px; background: var(--orange); color: #fff; font-weight: 800; font-size: 14px; cursor: pointer; box-shadow: 0 10px 22px rgba(247, 148, 29, .3); transition: background .15s; }
        .btn-save:hover { background: var(--orange-dark); }
        .btn-cancel { height: 44px; padding: 0 24px; border-radius: 999px; border: 1.5px solid var(--cream-border); background: #fff; color: var(--head); font-weight: 700; font-size: 14px; display: inline-flex; align-items: center; }
        .btn-cancel:hover { background: var(--cream); }

        :focus-visible { outline: 2px solid var(--orange); outline-offset: 2px; }

        @media (max-width: 900px) {
            body { flex-direction: column; }
            .side { width: 100%; height: auto; position: static; padding: 14px 16px; }
            .side-nav, .side-foot { display: none; }
            .content { padding: 28px 18px 48px; }
            .grid { grid-template-columns: 1fr; }
        }
    </style>
</head>
<body>

<aside class="side">
    <div class="side-brand">
        <span class="side-logo">PS</span>
        <div>
            <div class="side-name">PolySneaker</div>
            <div class="side-role">Quản trị viên</div>
        </div>
    </div>
    <nav class="side-nav">
        <a href="${ctx}/admin">Tổng quan</a>
        <a href="${ctx}/admin/banners">Banner</a>
        <a href="${ctx}/admin/products" class="active">Sản phẩm</a>
        <a href="${ctx}/admin/categories">Danh mục</a>
        <a href="${ctx}/admin/images">Hình ảnh</a>
        <a href="${ctx}/admin/blogs">Bài viết</a>
        <a href="${ctx}/admin/orders">Đơn hàng</a>
        <a href="${ctx}/admin/lookbooks">LookBook</a>
        <a href="${ctx}/admin/customers">Khách hàng</a>
    </nav>
    <div class="side-foot"><a href="${ctx}/logout">Đăng xuất</a></div>
</aside>

<main class="content">
    <div class="content-in">

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
                </div>

                <div>
                    <label class="f" for="badge">Nhãn (tuỳ chọn)</label>
                    <input type="text" id="badge" name="badge" maxlength="30" placeholder="VD: Bán chạy, Mới"
                           value="<c:out value='${form.badge}'/>">
                </div>

                <div>
                    <label class="f" for="originalPrice">Giá gốc (₫) <span class="req">*</span></label>
                    <input type="number" id="originalPrice" name="originalPrice" min="0" step="1000" required
                           value="${form.originalPrice}">
                </div>

                <div>
                    <label class="f" for="salePrice">Giá bán (₫) <span class="req">*</span></label>
                    <input type="number" id="salePrice" name="salePrice" min="0" step="1000" required
                           value="${form.salePrice}">
                    <div class="hint">Giá bán không được lớn hơn giá gốc.</div>
                </div>

                <div class="full">
                    <label class="f" for="mainImageUrl">Ảnh đại diện</label>
                    <input type="text" id="mainImageUrl" name="mainImageUrl"
                           placeholder="VD: air_jordan_gold.jpg  hoặc  https://..."
                           value="<c:out value='${form.mainImageUrl}'/>">
                    <div class="hint">Nhập tên file trong thư mục /static/assets/images/ hoặc một đường dẫn đầy đủ.</div>
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

    </div>
</main>

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

    // Xem trước ảnh đại diện
    (function () {
        var input = document.getElementById('mainImageUrl');
        var img = document.getElementById('previewImg');
        var txt = document.getElementById('previewTxt');

        function resolve(v) {
            v = v.trim();
            if (!v) return '';
            if (/^https?:\/\//i.test(v) || v.charAt(0) === '/') return v;
            return '/static/assets/images/' + v;
        }
        function show() {
            var src = resolve(input.value);
            if (!src) { img.style.display = 'none'; txt.style.display = ''; txt.textContent = 'Chưa có ảnh'; return; }
            img.onload = function () { img.style.display = 'block'; txt.style.display = 'none'; };
            img.onerror = function () { img.style.display = 'none'; txt.style.display = ''; txt.textContent = 'Không tải được ảnh: ' + src; };
            img.src = src;
        }
        input.addEventListener('input', show);
        show();
    })();
</script>

</body>
</html>
