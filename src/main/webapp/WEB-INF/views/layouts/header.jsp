<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ taglib uri="jakarta.tags.core" prefix="c" %>
        <c:set var="ctx" value="${pageContext.request.contextPath}" />
        <!DOCTYPE html>
        <html lang="vi">

        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1">
            <title>
                <c:out value="${empty pageTitle ? 'PolySneaker' : pageTitle}" />
            </title>
            <link rel="preconnect" href="https://fonts.googleapis.com">
            <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
            <link
                href="https://fonts.googleapis.com/css2?family=Nunito+Sans:wght@300;400;600;700;800&family=Nunito:wght@600;700;800&display=swap"
                rel="stylesheet">
            <link rel="stylesheet" href="${ctx}/static/assets/css/main.css">

        </head>

        <body>

            <!-- Icon dùng chung cho mọi trang -->
            <svg width="0" height="0" style="position:absolute" aria-hidden="true">
                <symbol id="ic-shoe" viewBox="0 0 24 24">
                    <path fill="currentColor"
                        d="M2 16.5c0-1 .6-1.8 1.5-2.1l4.2-1.4 2.3-3.2c.3-.4.9-.5 1.3-.2l1.6 1.2c.6.5 1.4.8 2.2.9l3.4.5c1.6.2 2.8 1.6 2.8 3.2V17c0 .6-.4 1-1 1H3c-.6 0-1-.4-1-1v-.5z" />
                </symbol>
                <symbol id="ic-arrow" viewBox="0 0 24 24">
                    <g fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round"
                        stroke-linejoin="round">
                        <line x1="5" y1="12" x2="19" y2="12" />
                        <polyline points="12 5 19 12 12 19" />
                    </g>
                </symbol>
                <symbol id="ic-heart" viewBox="0 0 24 24">
                    <path stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"
                        d="M20.8 4.6a5.5 5.5 0 0 0-7.8 0L12 5.7l-1-1.1a5.5 5.5 0 0 0-7.8 7.8l1 1.1L12 21l7.8-7.5 1-1.1a5.5 5.5 0 0 0 0-7.8z" />
                </symbol>
                <symbol id="ic-cart" viewBox="0 0 24 24">
                    <g fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"
                        stroke-linejoin="round">
                        <circle cx="9" cy="21" r="1" />
                        <circle cx="20" cy="21" r="1" />
                        <path d="M1 1h4l2.7 13.4a2 2 0 0 0 2 1.6h9.7a2 2 0 0 0 2-1.6L23 6H6" />
                    </g>
                </symbol>
            </svg>

            <!-- ===== Thanh quảng cáo ===== -->
            <div class="announce-bar">
                <span class="announce-dot"></span>
                <span class="announce-text">Chào đón Bộ Sưu Tập Đỉnh Nhất Châu Á 2026 : Miễn phí gói quà phong cách Châu
                    Á &amp; giao nhanh tận nơi</span>
            </div>

            <!-- ===== Header ===== -->
            <header class="site-header">
                <div class="container header-inner">

                    <a class="logo" href="${ctx}/">
                        <span class="logo-mark">
                            <img src="${ctx}/static/assets/images/logo_poly_store.png" alt="PolySneaker"
                                onerror="this.parentNode.classList.add('no-img'); this.remove();">
                            <svg class="logo-fallback" viewBox="0 0 24 24" fill="#fff" width="24" height="24">
                                <path
                                    d="M2 16.5c0-1 .6-1.8 1.5-2.1l4.2-1.4 2.3-3.2c.3-.4.9-.5 1.3-.2l1.6 1.2c.6.5 1.4.8 2.2.9l3.4.5c1.6.2 2.8 1.6 2.8 3.2V17c0 .6-.4 1-1 1H3c-.6 0-1-.4-1-1v-.5z" />
                            </svg>
                        </span>
                    </a>

                    <nav class="nav">
                        <a href="${ctx}/" class="${activeMenu == 'home' ? 'active' : ''}">Trang Chủ</a>

                        <%-- Sản Phẩm: bấm để mở menu xổ xuống. "Tất cả sản phẩm" cố định, các mục còn lại lấy từ bảng
                            Categories --%>
                            <div class="nav-dd" id="navDd">
                                <a href="${ctx}/shop" class="nav-dd-toggle ${activeMenu == 'shop' ? 'active' : ''}"
                                    id="navDdToggle" data-dropdown role="button" aria-haspopup="true"
                                    aria-expanded="false" aria-controls="navDdMenu">
                                    Sản Phẩm
                                    <svg class="chev" viewBox="0 0 24 24" width="14" height="14" fill="none"
                                        stroke="currentColor" stroke-width="2.5" stroke-linecap="round"
                                        stroke-linejoin="round">
                                        <polyline points="6 9 12 15 18 9" />
                                    </svg>
                                </a>

                                <div class="nav-dd-menu" id="navDdMenu" role="menu" aria-label="Danh mục sản phẩm">
                                    <a href="${ctx}/shop" role="menuitem"
                                        class="${activeMenu == 'shop' and empty param.category ? 'on' : ''}">Tất cả sản
                                        phẩm</a>

                                    <c:if test="${not empty menuCategories}">
                                        <div class="nav-dd-sep" role="separator"></div>
                                        <c:forEach var="mc" items="${menuCategories}">
                                            <a href="${ctx}/shop?category=${mc.id}" role="menuitem"
                                                class="${param.category == mc.id ? 'on' : ''}">
                                                <c:out value="${mc.name}" />
                                            </a>
                                        </c:forEach>
                                    </c:if>
                                </div>
                            </div>

                            <a href="${ctx}/#lookbook" class="${activeMenu == 'lookbook' ? 'active' : ''}">LookBook</a>
                            <a href="${ctx}/#blog" class="${activeMenu == 'blog' ? 'active' : ''}">Blog</a>
                    </nav>

                    <div class="header-actions">

                        <!-- Tìm kiếm: chỉ hiện icon, bấm vào mới mở ô nhập -->
                        <form class="hs" id="hsBox" action="${ctx}/shop" method="get" role="search">
                            <input type="text" name="keyword" id="hsInput"
                                placeholder="Tìm đôi giày yêu thích của bạn..." autocomplete="off" aria-label="Tìm kiếm"
                                tabindex="-1">
                            <button type="button" class="hs-btn" id="hsToggle" aria-label="Tìm kiếm"
                                aria-expanded="false">
                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"
                                    stroke-linecap="round" stroke-linejoin="round">
                                    <circle cx="11" cy="11" r="7.5" />
                                    <line x1="21" y1="21" x2="16.7" y2="16.7" />
                                </svg>
                            </button>
                        </form>

                        <a href="${ctx}/login" class="act-btn" title="Tài khoản" aria-label="Tài khoản">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"
                                stroke-linecap="round" stroke-linejoin="round">
                                <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2" />
                                <circle cx="12" cy="7" r="4" />
                            </svg>
                        </a>

                        <button type="button" class="act-btn" id="cartToggle" title="Giỏ hàng" aria-label="Giỏ hàng"
                            aria-haspopup="dialog" aria-expanded="false">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"
                                stroke-linecap="round" stroke-linejoin="round">
                                <path d="M6 2L3 6v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2V6l-3-4z" />
                                <line x1="3" y1="6" x2="21" y2="6" />
                                <path d="M16 10a4 4 0 0 1-8 0" />
                            </svg>
                            <span class="badge is-empty" id="cartBadge">0</span>
                        </button>
                    </div>

                </div>

                <!-- Sợi chỉ khâu chạy từ giữa lan ra hai mép khi bấm menu -->
                <span class="header-thread" aria-hidden="true"></span>
            </header>
            <%--=====Giỏ hàng trượt từ phải=====--%>
                <div class="cart-overlay" id="cartOverlay"></div>
                <aside class="cart-drawer" id="cartDrawer" data-ctx="${ctx}" role="dialog" aria-modal="true"
                    aria-labelledby="cartTitle" aria-hidden="true">
                    <div class="cart-head">
                        <h2 class="cart-title" id="cartTitle">Giỏ Hàng (0)</h2>
                        <button type="button" class="cart-close" id="cartClose" aria-label="Đóng giỏ hàng">
                            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor"
                                stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                <line x1="18" y1="6" x2="6" y2="18" />
                                <line x1="6" y1="6" x2="18" y2="18" />
                            </svg>
                        </button>
                    </div>

                    <div class="cart-body">
                        <p class="cart-empty">Giỏ hàng của bạn đang trống.</p>
                        <ul class="cart-list" id="cartList"></ul>
                    </div>

                    <div class="cart-foot">
                        <div class="cart-sum"><span>Tạm tính</span><b id="cartTotal">0₫</b></div>
                        <a href="${ctx}/checkout" class="cart-checkout">Thanh toán</a>
                        <button type="button" class="cart-continue" id="cartContinue">Tiếp tục mua sắm</button>
                    </div>
                </aside>
                <script>
                    (function () {
                        var thread = document.querySelector('.header-thread');
                        if (!thread) return;

                        var reduce = window.matchMedia && window.matchMedia('(prefers-reduced-motion: reduce)').matches;

                        // Nút "Sản Phẩm" (data-dropdown) chỉ mở/đóng menu nên không chạy hiệu ứng chuyển trang
                        document.querySelectorAll('.nav a:not([data-dropdown])').forEach(function (a) {
                            a.addEventListener('click', function (e) {
                                // Giữ nguyên Ctrl/Cmd/Shift + click (mở tab mới...)
                                if (e.ctrlKey || e.metaKey || e.shiftKey || e.button !== 0) return;

                                var url = new URL(a.href, location.href);
                                var samePageAnchor = url.pathname === location.pathname && url.hash;

                                // Chạy lại hiệu ứng từ giữa lan ra
                                thread.classList.remove('is-run');
                                void thread.offsetWidth;
                                thread.classList.add('is-run');

                                // Link neo trong cùng trang: chỉ chạy hiệu ứng, không reload
                                if (samePageAnchor) {
                                    setTimeout(function () { thread.classList.remove('is-run'); }, 1200);
                                    return;
                                }

                                // Sang trang khác: chạy chỉ xong rồi mới reload (trang mới có sẵn đường chỉ đầy)
                                e.preventDefault();
                                setTimeout(function () { location.href = a.href; }, reduce ? 0 : 750);
                            });
                        });
                    })();

                    // Tìm kiếm: bấm icon để mở ô nhập; bấm lại (khi đã gõ) để tìm; Esc hoặc bấm ra ngoài để đóng
                    (function () {
                        var box = document.getElementById('hsBox');
                        var input = document.getElementById('hsInput');
                        var btn = document.getElementById('hsToggle');
                        if (!box || !input || !btn) return;

                        function isOpen() { return box.classList.contains('open'); }

                        function openBox() {
                            box.classList.add('open');
                            btn.setAttribute('aria-expanded', 'true');
                            input.tabIndex = 0;
                            setTimeout(function () { input.focus(); }, 80);
                        }

                        function closeBox() {
                            box.classList.remove('open');
                            btn.setAttribute('aria-expanded', 'false');
                            input.tabIndex = -1;
                            input.blur();
                        }

                        btn.addEventListener('click', function () {
                            if (!isOpen()) { openBox(); return; }
                            if (input.value.trim()) box.submit(); else closeBox();
                        });

                        document.addEventListener('keydown', function (e) {
                            if (e.key === 'Escape' && isOpen()) closeBox();
                        });

                        document.addEventListener('click', function (e) {
                            if (isOpen() && !box.contains(e.target) && !input.value.trim()) closeBox();
                        });
                    })();

                    // Menu "Sản Phẩm": bấm để xổ xuống, mũi tên quay lên; bấm ra ngoài / Esc / chọn mục để đóng
                    (function () {
                        var dd = document.getElementById('navDd');
                        var toggle = document.getElementById('navDdToggle');
                        var menu = document.getElementById('navDdMenu');
                        if (!dd || !toggle || !menu) return;

                        function isOpen() { return dd.classList.contains('open'); }

                        // Đặt hộp menu ngay dưới mép header, thẳng hàng với nút "Sản Phẩm" (kể cả khi cuộn / đổi kích thước cửa sổ)
                        function place() {
                            var header = document.querySelector('.site-header');
                            var r = toggle.getBoundingClientRect();
                            var top = header ? header.getBoundingClientRect().bottom : r.bottom;
                            var left = Math.min(r.left, window.innerWidth - menu.offsetWidth - 8);
                            menu.style.top = Math.round(top) + 'px';
                            menu.style.left = Math.max(8, Math.round(left)) + 'px';
                        }

                        function openMenu() {
                            place();
                            dd.classList.add('open');
                            toggle.setAttribute('aria-expanded', 'true');
                        }

                        function closeMenu() {
                            dd.classList.remove('open');
                            toggle.setAttribute('aria-expanded', 'false');
                        }

                        toggle.addEventListener('click', function (e) {
                            e.preventDefault();
                            if (isOpen()) closeMenu(); else openMenu();
                        });

                        // Mũi tên xuống để mở và nhảy vào mục đầu tiên (dùng bàn phím)
                        toggle.addEventListener('keydown', function (e) {
                            if (e.key === 'ArrowDown') {
                                e.preventDefault();
                                if (!isOpen()) openMenu();
                                var first = menu.querySelector('a');
                                if (first) first.focus();
                            } else if (e.key === ' ') {
                                e.preventDefault();
                                if (isOpen()) closeMenu(); else openMenu();
                            }
                        });

                        // Chọn một mục: đóng ngay (việc chuyển trang do script ở trên đảm nhiệm)
                        menu.addEventListener('click', function (e) {
                            if (e.target.closest('a')) closeMenu();
                        });

                        document.addEventListener('click', function (e) {
                            if (isOpen() && !dd.contains(e.target)) closeMenu();
                        });

                        document.addEventListener('keydown', function (e) {
                            if (e.key === 'Escape' && isOpen()) { closeMenu(); toggle.focus(); }
                        });

                        window.addEventListener('resize', function () { if (isOpen()) place(); });
                        window.addEventListener('scroll', function () { if (isOpen()) place(); }, { passive: true });
                    })();

                </script>
                <script src="${ctx}/static/assets/js/cart.js"></script>
                <main class="container">