<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>${empty form.id ? 'Thêm danh mục' : 'Sửa danh mục'}</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Nunito+Sans:wght@300;400;600;700;800&display=swap" rel="stylesheet">

    <style>
        :root {
            --orange: #F7941D; --orange-dark: #E8830C; --amber: #D97706;
            --cream: #FFF6E6; --cream-border: #F8E3BC; --brown: #5C4430; --head: #6E3A12;
            --bg: #FFFBF2; --text: #4A4038; --muted: #9A8C7E;
            --side: #3B2412; --danger: #C2410C; --ok: #15803D;
        }
        * { box-sizing: border-box; }
        [hidden] { display: none !important; }
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
        .content-in { max-width: 640px; margin: 0 auto; }
        .page-title { font-size: 28px; font-weight: 800; color: var(--head); margin: 0; }
        .page-sub { font-size: 13px; color: var(--muted); margin: 4px 0 24px; }

        .alert { margin-bottom: 16px; padding: 12px 18px; border-radius: 12px; font-size: 13.5px; font-weight: 700; background: #FFE9E0; color: var(--danger); }

        .card { background: #fff; border: 1px solid #FBF0D6; border-radius: 20px; box-shadow: 0 8px 26px rgba(200, 140, 40, .07); padding: 28px; }
        .field { margin-bottom: 18px; }
        label.f { display: block; font-size: 12.5px; font-weight: 700; color: var(--brown); margin-bottom: 6px; }
        .req { color: var(--danger); }
        .opt { font-weight: 600; color: var(--muted); }
        input[type=text], select, textarea {
            width: 100%; padding: 11px 14px; border-radius: 12px; border: 1.5px solid var(--cream-border);
            background: var(--cream); font-family: inherit; font-size: 14px; color: var(--text); outline: none; transition: border-color .15s, background .15s;
        }
        textarea { min-height: 96px; resize: vertical; }
        input:focus, select:focus, textarea:focus { border-color: var(--orange); background: #fff; }
        select:disabled { opacity: .65; cursor: not-allowed; }
        .hint { font-size: 11.5px; color: var(--muted); margin-top: 5px; line-height: 1.5; }

        .check { display: flex; align-items: center; gap: 10px; font-size: 14px; font-weight: 700; color: var(--head); }
        .check input { width: 18px; height: 18px; accent-color: var(--orange); }

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
        <a href="${ctx}/admin/products">Sản phẩm</a>
        <a href="${ctx}/admin/categories" class="active">Danh mục</a>
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

        <h1 class="page-title">${empty form.id ? 'Thêm danh mục mới' : 'Chỉnh sửa danh mục'}</h1>
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
                       placeholder="VD: Nike Jordan, Adidas Running"
                       value="<c:out value='${form.name}'/>">
            </div>

            <div class="field">
                <label class="f" for="parentId">Thuộc nhóm</label>
                <select id="parentId" name="parentId" ${hasChildren ? 'disabled' : ''}>
                    <option value="">-- Không có (tạo danh mục gốc / nhóm) --</option>
                    <c:forEach var="p" items="${parents}">
                        <option value="${p.id}" ${p.id == form.parentId ? 'selected' : ''}>
                            <c:out value="${p.name}"/>
                        </option>
                    </c:forEach>
                </select>
                <c:choose>
                    <c:when test="${hasChildren}">
                        <div class="hint">Danh mục này đang có danh mục con nên là nhóm gốc, không thể chuyển vào nhóm khác.</div>
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
                    <input type="checkbox" name="active" value="true" ${empty form.id or form.active ? 'checked' : ''}>
                    Hiển thị ngoài cửa hàng
                </label>
                <div class="hint">Bỏ tick để ẩn danh mục khỏi menu và ô chọn danh mục mà không cần xóa.</div>
            </div>

            <div class="form-actions">
                <a href="${ctx}/admin/categories" class="btn-cancel">Hủy</a>
                <button type="submit" class="btn-save">${empty form.id ? 'Thêm danh mục' : 'Lưu thay đổi'}</button>
            </div>
        </form>

    </div>
</main>

</body>
</html>
