<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.functions" prefix="fn" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Quản lý danh mục</title>
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
        .content-in { max-width: 1100px; margin: 0 auto; }
        .top { display: flex; align-items: flex-end; justify-content: space-between; gap: 16px; flex-wrap: wrap; margin-bottom: 22px; }
        .page-title { font-size: 28px; font-weight: 800; color: var(--head); margin: 0; }
        .page-sub { font-size: 13px; color: var(--muted); margin: 4px 0 0; }
        .btn-add { height: 44px; padding: 0 24px; border: none; border-radius: 999px; background: var(--orange); color: #fff; font-weight: 800; font-size: 14px; display: inline-flex; align-items: center; gap: 8px; box-shadow: 0 10px 22px rgba(247, 148, 29, .3); transition: background .15s; }
        .btn-add:hover { background: var(--orange-dark); }

        .alert { margin-bottom: 16px; padding: 12px 18px; border-radius: 12px; font-size: 13.5px; font-weight: 700; }
        .alert.err { background: #FFE9E0; color: var(--danger); }
        .alert.ok { background: #E7F6EC; color: var(--ok); }

        .tools { display: flex; gap: 10px; margin-bottom: 14px; }
        .search { width: 100%; max-width: 340px; padding: 10px 14px; border-radius: 12px; border: 1.5px solid var(--cream-border); background: var(--cream); font-family: inherit; font-size: 14px; color: var(--text); outline: none; transition: border-color .15s, background .15s; }
        .search:focus { border-color: var(--orange); background: #fff; }

        .card { background: #fff; border: 1px solid #FBF0D6; border-radius: 20px; box-shadow: 0 8px 26px rgba(200, 140, 40, .07); overflow: hidden; }
        .table-wrap { overflow-x: auto; }
        table { width: 100%; border-collapse: collapse; min-width: 760px; }
        th { text-align: left; font-size: 11.5px; font-weight: 800; letter-spacing: .6px; text-transform: uppercase; color: var(--muted); padding: 14px 16px; background: #FFFAEF; border-bottom: 1px solid #F8EEDA; }
        td { padding: 14px 16px; border-bottom: 1px solid #FBF3E1; font-size: 14px; vertical-align: middle; }
        tr:last-child td { border-bottom: none; }
        tbody tr:hover { background: #FFFCF5; }
        tr.is-root td { background: #FFFAEF; }
        tr.is-root:hover td { background: #FFF6E3; }

        .c-name { font-weight: 800; color: var(--head); display: flex; align-items: center; gap: 8px; }
        tr.is-child .c-name { padding-left: 26px; font-weight: 700; }
        .tree { color: #D9B98A; font-weight: 400; }
        .tag { display: inline-block; padding: 2px 9px; border-radius: 999px; background: #FFEBC9; color: var(--amber); font-size: 10.5px; font-weight: 800; }
        .c-desc { color: var(--muted); font-size: 13px; max-width: 300px; }
        .num { font-weight: 700; color: var(--head); }

        .status { display: inline-block; padding: 4px 12px; border-radius: 999px; font-size: 12px; font-weight: 800; }
        .status.on { background: #E7F6EC; color: var(--ok); }
        .status.off { background: #F3EEE6; color: var(--muted); }

        .actions { display: flex; gap: 8px; align-items: center; }
        .btn-edit, .btn-del { height: 36px; padding: 0 16px; border-radius: 10px; font-size: 13px; font-weight: 700; cursor: pointer; display: inline-flex; align-items: center; transition: background .15s, border-color .15s, color .15s; }
        .btn-edit { border: 1px solid var(--cream-border); background: #fff; color: var(--head); }
        .btn-edit:hover { background: var(--cream); border-color: var(--orange); }
        .btn-del { border: 1px solid #F2B79B; background: #fff; color: var(--danger); }
        .btn-del:hover { background: #FFEDE5; }
        .actions form { margin: 0; }

        .empty { padding: 54px 20px; text-align: center; color: var(--muted); font-size: 14px; }
        .note { margin-top: 14px; font-size: 12.5px; color: var(--muted); line-height: 1.6; }

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

        <div class="top">
            <div>
                <h1 class="page-title">Quản lý danh mục</h1>
                <p class="page-sub">Tổng cộng ${fn:length(rows)} danh mục</p>
            </div>
            <a href="${ctx}/admin/categories/new" class="btn-add">+ Thêm danh mục</a>
        </div>

        <c:if test="${not empty success}">
            <div class="alert ok"><c:out value="${success}"/></div>
        </c:if>
        <c:if test="${not empty error}">
            <div class="alert err"><c:out value="${error}"/></div>
        </c:if>

        <div class="tools">
            <input type="text" id="search" class="search" placeholder="Tìm theo tên danh mục...">
        </div>

        <div class="card">
            <div class="table-wrap">
                <table>
                    <thead>
                    <tr>
                        <th>Danh mục</th>
                        <th>Mô tả</th>
                        <th>Nội dung</th>
                        <th>Trạng thái</th>
                        <th>Thao tác</th>
                    </tr>
                    </thead>
                    <tbody id="rows">
                    <c:forEach var="r" items="${rows}">
                        <tr class="${r.root ? 'is-root' : 'is-child'}"
                            data-search="<c:out value='${fn:toLowerCase(r.name)}'/>">
                            <td>
                                <div class="c-name">
                                    <c:if test="${not r.root}"><span class="tree">└</span></c:if>
                                    <span><c:out value="${r.name}"/></span>
                                    <c:if test="${r.root}"><span class="tag">Nhóm</span></c:if>
                                </div>
                            </td>
                            <td class="c-desc">
                                <c:choose>
                                    <c:when test="${empty r.description}">—</c:when>
                                    <c:otherwise><c:out value="${r.description}"/></c:otherwise>
                                </c:choose>
                            </td>
                            <td>
                                <c:choose>
                                    <c:when test="${r.root}"><span class="num">${r.childCount}</span> danh mục con</c:when>
                                    <c:otherwise><span class="num">${r.productCount}</span> sản phẩm</c:otherwise>
                                </c:choose>
                            </td>
                            <td>
                                <c:choose>
                                    <c:when test="${r.active}"><span class="status on">Đang hiện</span></c:when>
                                    <c:otherwise><span class="status off">Đã ẩn</span></c:otherwise>
                                </c:choose>
                            </td>
                            <td>
                                <div class="actions">
                                    <a href="${ctx}/admin/categories/${r.id}/edit" class="btn-edit">Sửa</a>
                                    <form action="${ctx}/admin/categories/${r.id}/delete" method="post"
                                          class="js-delete" data-name="<c:out value='${r.name}'/>">
                                        <button type="submit" class="btn-del">Xóa</button>
                                    </form>
                                </div>
                            </td>
                        </tr>
                    </c:forEach>
                    </tbody>
                </table>
            </div>

            <c:if test="${empty rows}">
                <div class="empty">Chưa có danh mục nào. Bấm "Thêm danh mục" để tạo danh mục đầu tiên.</div>
            </c:if>
            <div class="empty" id="noResult" hidden>Không tìm thấy danh mục phù hợp.</div>
        </div>

        <p class="note">
            <b>Nhóm</b> (danh mục gốc, ví dụ Shoes) dùng để gom các danh mục con. Sản phẩm chỉ được gắn vào <b>danh mục con</b>
            (ví dụ Nike Jordan), và các danh mục con đang hiện sẽ xuất hiện trong menu "Sản Phẩm" ngoài cửa hàng.
            Danh mục đang có sản phẩm hoặc danh mục con thì không xóa được, hãy chuyển sản phẩm đi hoặc chuyển sang "Đã ẩn".
        </p>

    </div>
</main>

<script>
    // Hỏi xác nhận trước khi xóa
    document.addEventListener('submit', function (e) {
        var form = e.target;
        if (!form.classList.contains('js-delete')) return;
        var name = form.getAttribute('data-name') || 'danh mục này';
        if (!confirm('Xóa danh mục "' + name + '"?')) {
            e.preventDefault();
        }
    });

    // Lọc nhanh theo tên
    (function () {
        var input = document.getElementById('search');
        var rows = document.querySelectorAll('#rows tr');
        var noResult = document.getElementById('noResult');

        input.addEventListener('input', function () {
            var q = input.value.trim().toLowerCase();
            var shown = 0;
            rows.forEach(function (tr) {
                var match = !q || tr.getAttribute('data-search').indexOf(q) !== -1;
                tr.hidden = !match;
                if (match) shown++;
            });
            noResult.hidden = shown > 0 || rows.length === 0;
        });
    })();
</script>

</body>
</html>
