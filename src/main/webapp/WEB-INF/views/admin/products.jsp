<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Admin</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Nunito+Sans:wght@300;400;600;700;800&display=swap" rel="stylesheet">

    <style>
        :root {
            --orange: #F7941D;
            --orange-dark: #E8830C;
            --amber: #D97706;
            --cream: #FFF6E6;
            --cream-border: #F8E3BC;
            --brown: #5C4430;
            --head: #6E3A12;
            --bg: #FFFBF2;
            --text: #4A4038;
            --muted: #9A8C7E;
            --side: #3B2412;
            --side-2: #4A2F18;
            --danger: #C2410C;
            --ok-bg: #E4F2E6;
            --ok-tx: #2F7D4A;
        }

        * { box-sizing: border-box; }

        body {
            margin: 0;
            min-height: 100vh;
            display: flex;
            font-family: 'Nunito Sans', Arial, sans-serif;
            letter-spacing: .1px;
            color: var(--text);
            background: var(--bg);
            -webkit-font-smoothing: antialiased;
            text-rendering: optimizeLegibility;
        }

        a { color: inherit; text-decoration: none; }
        button { font-family: inherit; }

        /* ===== Sidebar ===== */
        .side {
            width: 252px;
            flex-shrink: 0;
            min-height: 100vh;
            position: sticky;
            top: 0;
            align-self: flex-start;
            height: 100vh;
            display: flex;
            flex-direction: column;
            padding: 24px 16px;
            background: linear-gradient(180deg, var(--side) 0%, #2B190B 100%);
            color: #F3E4CE;
        }
        .side-brand { display: flex; align-items: center; gap: 12px; padding: 0 8px 22px; border-bottom: 1px solid rgba(255, 226, 170, .14); }
        .side-logo { width: 38px; height: 38px; border-radius: 50%; border: 1.5px solid rgba(247, 148, 29, .6); background: rgba(247, 148, 29, .14); color: var(--orange); font-weight: 800; font-size: 13px; display: flex; align-items: center; justify-content: center; flex-shrink: 0; }
        .side-name { font-weight: 800; font-size: 15px; color: #FFF3DC; line-height: 1.2; }
        .side-role { font-size: 10.5px; font-weight: 700; letter-spacing: 1px; color: #D9A25C; margin-top: 2px; }

        .side-nav { display: flex; flex-direction: column; gap: 4px; margin-top: 22px; }
        .side-nav a { display: flex; align-items: center; gap: 12px; padding: 11px 12px; border-radius: 12px; font-size: 14px; font-weight: 600; color: #E7D2B2; transition: background .15s, color .15s; }
        .side-nav a svg { width: 18px; height: 18px; flex-shrink: 0; opacity: .85; }
        .side-nav a:hover { background: rgba(255, 226, 170, .08); color: #fff; }
        .side-nav a.active { background: rgba(247, 148, 29, .2); color: #FFB74D; box-shadow: inset 3px 0 0 var(--orange); }
        .side-nav a.active svg { opacity: 1; }

        .side-foot { margin-top: auto; padding: 14px 8px 0; border-top: 1px solid rgba(255, 226, 170, .14); }
        .side-foot a { display: flex; align-items: center; gap: 10px; font-size: 13px; font-weight: 600; color: #D9BC93; padding: 8px 4px; }
        .side-foot a:hover { color: #fff; }

        /* ===== Nội dung ===== */
        .content { flex: 1; min-width: 0; padding: 48px 40px 64px; }
        .content-in { max-width: 1100px; margin: 0 auto; }

        .page-head { display: flex; align-items: center; justify-content: space-between; gap: 20px; flex-wrap: wrap; margin-bottom: 26px; }
        .page-title { font-size: 28px; font-weight: 800; color: var(--head); margin: 0; letter-spacing: -.1px; }
        .page-sub { font-size: 13px; color: var(--muted); margin: 4px 0 0; }

        .btn-add { display: inline-flex; align-items: center; gap: 8px; height: 44px; padding: 0 22px; border: none; border-radius: 999px; background: var(--orange); color: #fff; font-weight: 800; font-size: 13.5px; cursor: pointer; box-shadow: 0 10px 22px rgba(247, 148, 29, .3); transition: background .15s, transform .15s; }
        .btn-add:hover { background: var(--orange-dark); transform: translateY(-1px); }

        /* Thông báo (flash) */
        .alert { margin-bottom: 16px; padding: 12px 18px; border-radius: 12px; font-size: 13.5px; font-weight: 700; }
        .alert.ok { background: var(--ok-bg); color: var(--ok-tx); }
        .alert.err { background: #FFE9E0; color: var(--danger); }

        /* Thanh công cụ */
        .toolbar { display: flex; align-items: center; justify-content: space-between; gap: 14px; flex-wrap: wrap; margin-bottom: 14px; }
        .search { flex: 1; min-width: 220px; max-width: 360px; display: flex; align-items: center; gap: 10px; height: 44px; padding: 0 18px; border-radius: 999px; background: var(--cream); border: 1.5px solid var(--cream-border); color: var(--orange); }
        .search svg { width: 18px; height: 18px; flex-shrink: 0; }
        .search input { flex: 1; min-width: 0; border: none; outline: none; background: transparent; font-family: inherit; font-size: 13.5px; color: var(--text); }
        .search input::placeholder { color: #BFA784; }
        .search:focus-within { border-color: var(--orange); background: #fff; }
        .count { font-size: 12.5px; color: var(--muted); font-weight: 600; }

        /* Bảng */
        .table-wrap { background: #fff; border: 1px solid #FBF0D6; border-radius: 20px; box-shadow: 0 8px 26px rgba(200, 140, 40, .07); overflow-x: auto; }
        table { width: 100%; border-collapse: collapse; min-width: 820px; }
        thead th { text-align: left; font-size: 12.5px; font-weight: 700; color: var(--brown); padding: 14px 16px; background: var(--cream); white-space: nowrap; }
        tbody td { padding: 16px; font-size: 14px; border-top: 1px solid #F8EEDA; vertical-align: middle; }
        tbody tr:hover { background: #FFFCF5; }
        .p-name { font-weight: 700; color: var(--head); }
        .sku { font-family: 'SFMono-Regular', Consolas, 'Courier New', monospace; font-size: 13px; color: var(--brown); }
        .num { font-variant-numeric: tabular-nums; white-space: nowrap; }
        .price { font-weight: 700; color: var(--head); }
        .stock.low { color: var(--danger); font-weight: 800; }

        .chip { display: inline-block; padding: 3px 11px; border-radius: 999px; font-size: 11.5px; font-weight: 700; }
        .chip.on { background: var(--ok-bg); color: var(--ok-tx); }
        .chip.off { background: #F1ECE3; color: #8E7C66; }
        .chip.out { background: #FFE9A8; color: #8A4B08; }

        .actions { display: flex; justify-content: flex-end; gap: 8px; }
        .actions form { margin: 0; }
        .btn-sm { height: 34px; padding: 0 16px; border-radius: 10px; border: 1px solid var(--cream-border); background: #fff; color: var(--head); font-size: 13px; font-weight: 700; cursor: pointer; transition: background .15s, border-color .15s, color .15s; display: inline-flex; align-items: center; }
        .btn-sm:hover { background: var(--cream); border-color: var(--orange); color: var(--orange-dark); }
        .btn-sm.del { color: #B7894F; }
        .btn-sm.del:hover { background: #FFEDE5; border-color: #F2B79B; color: var(--danger); }

        .empty { display: none; text-align: center; padding: 48px 16px; color: var(--muted); font-size: 14px; }
        .empty b { display: block; color: var(--head); font-size: 16px; margin-bottom: 4px; }

        .menu-btn { display: none; }

        :focus-visible { outline: 2px solid var(--orange); outline-offset: 2px; }

        /* ===== Popup xác nhận đăng xuất ===== */
        .modal-bg { display: none; position: fixed; inset: 0; z-index: 100; align-items: center; justify-content: center; padding: 20px; background: rgba(43, 25, 11, .55); }
        .modal-bg.show { display: flex; }
        .modal { width: 100%; max-width: 380px; padding: 28px 26px 22px; text-align: center; background: #fff; border: 1px solid #FBF0D6; border-radius: 22px; box-shadow: 0 24px 60px rgba(43, 25, 11, .35); }
        .modal-ico { width: 52px; height: 52px; margin: 0 auto 14px; border-radius: 50%; background: var(--cream); color: var(--orange); display: flex; align-items: center; justify-content: center; }
        .modal h3 { margin: 0 0 6px; font-size: 19px; font-weight: 800; color: var(--head); }
        .modal p { margin: 0 0 22px; font-size: 13.5px; line-height: 1.5; color: var(--muted); }
        .modal-actions { display: flex; gap: 10px; }
        .modal-actions .btn-sm, .modal-actions .btn-yes { flex: 1; height: 42px; justify-content: center; }
        .btn-yes { display: inline-flex; align-items: center; border: none; border-radius: 10px; background: var(--orange); color: #fff; font-size: 13.5px; font-weight: 800; cursor: pointer; box-shadow: 0 8px 18px rgba(247, 148, 29, .28); transition: background .15s; }
        .btn-yes:hover { background: var(--orange-dark); }

        /* ===== Responsive ===== */
        @media (max-width: 900px) {
            body { flex-direction: column; }
            .side { width: 100%; height: auto; min-height: 0; position: static; padding: 14px 16px; flex-direction: row; align-items: center; justify-content: space-between; flex-wrap: wrap; }
            .side-brand { border: none; padding: 0; }
            .menu-btn { display: inline-flex; align-items: center; justify-content: center; width: 40px; height: 40px; border-radius: 12px; border: 1px solid rgba(255, 226, 170, .25); background: transparent; color: #FFE2AA; cursor: pointer; }
            .side-nav, .side-foot { display: none; width: 100%; }
            .side.open .side-nav { display: flex; margin-top: 14px; }
            .side.open .side-foot { display: block; margin-top: 8px; }
            .content { padding: 28px 18px 48px; }
        }
    </style>
</head>
<body>

<!-- ===== Sidebar ===== -->
<aside class="side" id="side">
    <div class="side-brand">
        <span class="side-logo">PS</span>
        <div>
            <div class="side-name">PolySneaker</div>
            <div class="side-role">Quản trị viên</div>
        </div>
    </div>

    <button class="menu-btn" type="button" id="menuBtn" aria-label="Mở menu">
        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round"><line x1="4" y1="7" x2="20" y2="7"/><line x1="4" y1="12" x2="20" y2="12"/><line x1="4" y1="17" x2="20" y2="17"/></svg>
    </button>

    <nav class="side-nav">
        <a href="${ctx}/admin">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="3" width="7" height="9" rx="1.5"/><rect x="14" y="3" width="7" height="5" rx="1.5"/><rect x="14" y="12" width="7" height="9" rx="1.5"/><rect x="3" y="16" width="7" height="5" rx="1.5"/></svg>
            Tổng quan
        </a>
        <a href="${ctx}/admin/banners">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="2" y="4" width="20" height="14" rx="2"/><path d="M8 21h8M12 18v3"/></svg>
            Banner
        </a>
        <a href="${ctx}/admin/products" class="active">
            <svg viewBox="0 0 24 24" fill="currentColor"><path d="M2 16.5c0-1 .6-1.8 1.5-2.1l4.2-1.4 2.3-3.2c.3-.4.9-.5 1.3-.2l1.6 1.2c.6.5 1.4.8 2.2.9l3.4.5c1.6.2 2.8 1.6 2.8 3.2V17c0 .6-.4 1-1 1H3c-.6 0-1-.4-1-1v-.5z"/></svg>
            Sản phẩm
        </a>
        <a href="${ctx}/admin/categories">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M20.6 13.4l-7.2 7.2a2 2 0 0 1-2.8 0L3 13V3h10l7.6 7.6a2 2 0 0 1 0 2.8z"/><circle cx="7.5" cy="7.5" r="1.2"/></svg>
            Danh mục
        </a>
        <a href="${ctx}/admin/images">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="3" width="18" height="18" rx="2"/><circle cx="8.5" cy="8.5" r="1.5"/><polyline points="21 15 16 10 5 21"/></svg>
            Hình ảnh
        </a>
        <a href="${ctx}/admin/blogs">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M2 4h6a4 4 0 0 1 4 4v13a3 3 0 0 0-3-3H2z"/><path d="M22 4h-6a4 4 0 0 0-4 4v13a3 3 0 0 1 3-3h7z"/></svg>
            Bài viết
        </a>
        <a href="${ctx}/admin/orders">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M6 2L3 6v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2V6l-3-4z"/><line x1="3" y1="6" x2="21" y2="6"/><path d="M16 10a4 4 0 0 1-8 0"/></svg>
            Đơn hàng
        </a>
        <a href="${ctx}/admin/lookbooks">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20V3H6.5A2.5 2.5 0 0 0 4 5.5v14z"/><path d="M8 7h8M8 11h8"/></svg>
            LookBook
        </a>
        <a href="${ctx}/admin/customers">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.9M16 3.1a4 4 0 0 1 0 7.8"/></svg>
            Khách hàng
        </a>
    </nav>

    <div class="side-foot">
        <a href="${ctx}/logout" id="logoutBtn">
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"/><polyline points="16 17 21 12 16 7"/><line x1="21" y1="12" x2="9" y2="12"/></svg>
            Đăng xuất
        </a>
    </div>
</aside>

<!-- ===== Nội dung ===== -->
<main class="content">
    <div class="content-in">

        <div class="page-head">
            <div>
                <h1 class="page-title">Quản lý sản phẩm</h1>
                <p class="page-sub">Thêm, chỉnh sửa và theo dõi tồn kho các mẫu giày trong cửa hàng.</p>
            </div>
            <a href="${ctx}/admin/products/new" class="btn-add">
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.6" stroke-linecap="round"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
                Thêm sản phẩm
            </a>
        </div>

        <%-- Thông báo từ controller (RedirectAttributes: success / error) --%>
        <c:if test="${not empty success}">
            <div class="alert ok"><c:out value="${success}"/></div>
        </c:if>
        <c:if test="${not empty error}">
            <div class="alert err"><c:out value="${error}"/></div>
        </c:if>

        <div class="toolbar">
            <label class="search">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="7"/><line x1="21" y1="21" x2="16.5" y2="16.5"/></svg>
                <input type="text" id="q" placeholder="Tìm theo tên hoặc mã SKU..." aria-label="Tìm sản phẩm">
            </label>
            <span class="count" id="count"></span>
        </div>

        <div class="table-wrap">
            <table>
                <thead>
                <tr>
                    <th>Tên sản phẩm</th>
                    <th>SKU</th>
                    <th>Danh mục</th>
                    <th>Giá bán</th>
                    <th>Tồn kho</th>
                    <th>Trạng thái</th>
                    <th></th>
                </tr>
                </thead>
                <tbody id="rows">
                <c:forEach var="p" items="${products}">
                    <tr>
                        <td class="p-name"><c:out value="${p.name}"/></td>
                        <td class="sku"><c:out value="${p.sku}"/></td>
                        <td><c:out value="${p.category.name}"/></td>
                        <td class="num price"><fmt:formatNumber value="${p.salePrice}" type="number" groupingUsed="true"/>₫</td>
                        <td class="num stock ${p.totalStock le 5 ? 'low' : ''}">${p.totalStock}</td>
                        <td>
                            <c:choose>
                                <c:when test="${not p.active}"><span class="chip off">Đã ẩn</span></c:when>
                                <c:when test="${p.totalStock le 0}"><span class="chip out">Hết hàng</span></c:when>
                                <c:otherwise><span class="chip on">Đang bán</span></c:otherwise>
                            </c:choose>
                        </td>
                        <td>
                            <div class="actions">
                                <a class="btn-sm" href="${ctx}/admin/products/${p.id}/edit">Sửa</a>
                                <form action="${ctx}/admin/products/${p.id}/delete" method="post"
                                      onsubmit="return confirm('Xóa sản phẩm này?');">
                                    <button class="btn-sm del" type="submit">Xóa</button>
                                </form>
                            </div>
                        </td>
                    </tr>
                </c:forEach>
                </tbody>
            </table>
            <div class="empty" id="empty"><b>Không tìm thấy sản phẩm</b>Thử tìm bằng tên khác hoặc mã SKU khác.</div>
        </div>

    </div>
</main>

<!-- ===== Popup xác nhận đăng xuất ===== -->
<div class="modal-bg" id="logoutModal" role="dialog" aria-modal="true" aria-labelledby="logoutTitle">
    <div class="modal">
        <div class="modal-ico">
            <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"/><polyline points="16 17 21 12 16 7"/><line x1="21" y1="12" x2="9" y2="12"/></svg>
        </div>
        <h3 id="logoutTitle">Bạn có muốn đăng xuất?</h3>
        <p>Phiên làm việc của quản trị viên sẽ kết thúc và bạn sẽ quay về trang đăng nhập.</p>
        <div class="modal-actions">
            <button type="button" class="btn-sm" id="logoutNo">Không</button>
            <a href="${ctx}/logout" class="btn-yes" id="logoutYes" style="justify-content:center;">Có, đăng xuất</a>
        </div>
    </div>
</div>

<script>
    // Mở / đóng menu trên màn hình nhỏ
    (function () {
        var side = document.getElementById('side');
        document.getElementById('menuBtn').addEventListener('click', function () {
            side.classList.toggle('open');
        });
    })();

    // Popup xác nhận đăng xuất
    (function () {
        var modal = document.getElementById('logoutModal');
        function open(e) { e.preventDefault(); modal.classList.add('show'); }
        function close() { modal.classList.remove('show'); }

        document.getElementById('logoutBtn').addEventListener('click', open);
        document.getElementById('logoutNo').addEventListener('click', close);
        modal.addEventListener('click', function (e) { if (e.target === modal) close(); }); // bấm ra ngoài thì đóng
        document.addEventListener('keydown', function (e) { if (e.key === 'Escape') close(); });
    })();

    // Lọc nhanh theo tên / SKU ngay trên bảng
    (function () {
        var input = document.getElementById('q');
        var rows = Array.prototype.slice.call(document.querySelectorAll('#rows tr'));
        var count = document.getElementById('count');
        var empty = document.getElementById('empty');

        function update() {
            var kw = input.value.trim().toLowerCase();
            var shown = 0;
            rows.forEach(function (r) {
                var hit = kw === '' || r.textContent.toLowerCase().indexOf(kw) !== -1;
                r.style.display = hit ? '' : 'none';
                if (hit) shown++;
            });
            count.textContent = shown + ' sản phẩm';
            empty.style.display = shown === 0 ? 'block' : 'none';
        }
        input.addEventListener('input', update);
        update();
    })();
</script>

</body>
</html>
