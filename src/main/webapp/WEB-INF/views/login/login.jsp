<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ taglib uri="jakarta.tags.core" prefix="c" %>
        <c:set var="ctx" value="${pageContext.request.contextPath}" />
        <%-- Đổi 1 chỗ này nếu thư mục ảnh của anh khác (ví dụ ${ctx}/assets/images) --%>
            <c:set var="img" value="${ctx}/static/assets/images" />
            <!DOCTYPE html>
            <html lang="vi">

            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1">
                <title>Login </title>
                <link rel="preconnect" href="https://fonts.googleapis.com">
                <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
                <link href="https://fonts.googleapis.com/css2?family=Nunito+Sans:wght@300;400;600;700;800&display=swap"
                    rel="stylesheet">
                <link rel="stylesheet" href="${ctx}/static/assets/css/auth/login.css">
            </head>

            <body>

                <!-- ===== Header ===== -->
                <header class="lg-head">
                    <div class="container lg-head-inner">
                        <div class="lg-brand">
                            <a class="logo" href="${ctx}/">
                                <span class="logo-mark">
                                    <img src="/static/assets/images/logo_poly_store.png" alt="PolySneaker"
                                        onerror="this.parentNode.classList.add('no-img'); this.remove();">
                                    <svg class="logo-fallback" viewBox="0 0 24 24" fill="#fff" width="24" height="24">
                                        <path
                                            d="M2 16.5c0-1 .6-1.8 1.5-2.1l4.2-1.4 2.3-3.2c.3-.4.9-.5 1.3-.2l1.6 1.2c.6.5 1.4.8 2.2.9l3.4.5c1.6.2 2.8 1.6 2.8 3.2V17c0 .6-.4 1-1 1H3c-.6 0-1-.4-1-1v-.5z" />
                                    </svg>
                                </span>
                            </a>
                        </div>
                        <div class="lg-links">
                            <a href="${ctx}/">
                                <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor"
                                    stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round">
                                    <line x1="19" y1="12" x2="5" y2="12" />
                                    <polyline points="12 19 5 12 12 5" />
                                </svg>
                                Về Trang Chủ
                            </a>
                            <span class="sep"></span>
                            <span class="hotline">
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor"
                                    stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                    <path d="M3 18v-6a9 9 0 0 1 18 0v6" />
                                    <path
                                        d="M21 19a2 2 0 0 1-2 2h-1a2 2 0 0 1-2-2v-3a2 2 0 0 1 2-2h3zM3 19a2 2 0 0 0 2 2h1a2 2 0 0 0 2-2v-3a2 2 0 0 0-2-2H3z" />
                                </svg>
                                Hotline: 1900 8899
                            </span>
                        </div>
                    </div>
                </header>

                <!-- ===== Nội dung ===== -->
                <main class="lg-main">
                    <div class="lg-card">

                        <!-- Bên trái: hình + slogan -->
                        <aside class="lg-left">
                            <div class="lg-left-top">
                                <span class="brand-tiny">#PolySneaker</span>
                            </div>
                            <div class="lg-visual">
                                <div class="lg-photo">
                                    <svg class="ph" viewBox="0 0 24 24">
                                        <path fill="currentColor"
                                            d="M2 16.5c0-1 .6-1.8 1.5-2.1l4.2-1.4 2.3-3.2c.3-.4.9-.5 1.3-.2l1.6 1.2c.6.5 1.4.8 2.2.9l3.4.5c1.6.2 2.8 1.6 2.8 3.2V17c0 .6-.4 1-1 1H3c-.6 0-1-.4-1-1v-.5z" />
                                    </svg>
                                    <img src="/static/assets/images/hinh-dong-chu-welcome-dep_075934502.gif"
                                        alt="PolySneaker" onerror="this.style.display='none'">
                                </div>
                                <span class="lg-auth-tag">
                                    <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor"
                                        stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round">
                                        <circle cx="12" cy="12" r="9" />
                                        <polyline points="8 12 11 15 16 9" />
                                    </svg>
                                    Chính hãng 100%
                                </span>
                            </div>

                            <h2 class="lg-quote">“Bước chân thanh lịch, tinh hoa tối giản Á Đông”</h2>
                            <p class="lg-quote-sub">Mỗi chuyển động đều là sự tôn vinh của tính cân bằng và độ tinh tế
                                thủ công thượng thừa.</p>

                            <div class="lg-perks">
                                <div class="perk">
                                    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor"
                                        stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                        <path d="M6 3h12l4 6-10 12L2 9z" />
                                        <path d="M2 9h20" />
                                    </svg>
                                    <div><b>Ưu tiên mở bán</b><span>Hàng phiên bản giới hạn</span></div>
                                </div>
                                <div class="perk">
                                    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor"
                                        stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                        <circle cx="12" cy="12" r="9" />
                                        <polygon
                                            points="12 7 13.5 10.5 17 11 14.5 13.5 15 17 12 15.3 9 17 9.5 13.5 7 11 10.5 10.5" />
                                    </svg>
                                    <div><b>Tích điểm PolyPoint</b><span>Đổi quà tặng độc quyền</span></div>
                                </div>
                            </div>
                        </aside>

                        <!-- Bên phải: form -->
                        <section class="lg-right">
                            <span class="lg-badge">
                                <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor"
                                    stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                    <path d="M2 18l2-11 5 5 3-8 3 8 5-5 2 11z" />
                                    <line x1="2" y1="21" x2="22" y2="21" />
                                </svg>
                                Cửa ngõ phong cách
                            </span>
                            <h1 class="lg-title">Chào mừng trở lại</h1>
                            <p class="lg-sub">Đăng nhập tài khoản PolySneaker để tiếp tục trải nghiệm bộ sưu tập mới
                                nhất.</p>

                            <%-- Thông báo thành công (từ flash attribute sau khi đăng ký xong) --%>
                                <c:if test="${not empty success}">
                                    <div class="lg-error"
                                        style="background:#ecfdf3;color:#067647;border-color:#abefc6;">
                                        <c:out value="${success}" />
                                    </div>
                                </c:if>

                                <c:if test="${not empty error}">
                                    <div class="lg-error">
                                        <c:out value="${error}" />
                                    </div>
                                </c:if>
                                <c:if test="${not empty info}">
                                    <div class="...class giống khối success/error đang có...">${info}</div>
                                </c:if>
                                <form id="loginForm" action="${ctx}/login" method="post" autocomplete="on">
                                    <label class="fld-label" for="username">Tên đăng nhập <em>*</em></label>
                                    <div class="fld">
                                        <svg class="lead" width="17" height="17" viewBox="0 0 24 24" fill="none"
                                            stroke="currentColor" stroke-width="2" stroke-linecap="round"
                                            stroke-linejoin="round">
                                            <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2" />
                                            <circle cx="12" cy="7" r="4" />
                                        </svg>
                                        <input type="text" id="username" name="username"
                                            placeholder="Nhập tên đăng nhập hoặc số điện thoại..."
                                            autocomplete="username" value="<c:out value='${username}'/>" required>
                                    </div>

                                    <div class="fld-label">
                                        <label for="password">Mật khẩu bí mật <em>*</em></label>
                                        <a href="#">Quên mật khẩu?</a>
                                    </div>
                                    <div class="fld">
                                        <svg class="lead" width="17" height="17" viewBox="0 0 24 24" fill="none"
                                            stroke="currentColor" stroke-width="2" stroke-linecap="round"
                                            stroke-linejoin="round">
                                            <rect x="3" y="11" width="18" height="11" rx="2" />
                                            <path d="M7 11V7a5 5 0 0 1 10 0v4" />
                                        </svg>
                                        <input type="password" id="password" name="password" placeholder="••••••••"
                                            autocomplete="current-password" required>
                                        <button type="button" class="eye" id="togglePw" aria-label="Hiện/ẩn mật khẩu">
                                            <svg width="18" height="18" viewBox="0 0 24 24" fill="none"
                                                stroke="currentColor" stroke-width="2" stroke-linecap="round"
                                                stroke-linejoin="round">
                                                <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z" />
                                                <circle cx="12" cy="12" r="3" />
                                            </svg>
                                        </button>
                                    </div>

                                    <label class="remember">
                                        <input type="checkbox" name="remember" checked>
                                        Ghi nhớ phiên đăng nhập trên thiết bị này
                                    </label>

                                    <button type="submit" class="btn-login">
                                        Đăng Nhập Ngay
                                        <svg width="16" height="16" viewBox="0 0 24 24" fill="none"
                                            stroke="currentColor" stroke-width="2.4" stroke-linecap="round"
                                            stroke-linejoin="round">
                                            <line x1="5" y1="12" x2="19" y2="12" />
                                            <polyline points="12 5 19 12 12 19" />
                                        </svg>
                                    </button>
                                </form>

                                <div class="divider"><span>hoặc tiếp tục với</span></div>

                                <div class="social">
                                    <a href="#">
                                        <svg width="18" height="18" viewBox="0 0 24 24">
                                            <path fill="#4285F4"
                                                d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92a5.06 5.06 0 0 1-2.2 3.32v2.77h3.57c2.08-1.92 3.27-4.74 3.27-8.1z" />
                                            <path fill="#34A853"
                                                d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84A11 11 0 0 0 12 23z" />
                                            <path fill="#FBBC05"
                                                d="M5.84 14.1a6.6 6.6 0 0 1 0-4.2V7.07H2.18a11 11 0 0 0 0 9.86l3.66-2.83z" />
                                            <path fill="#EA4335"
                                                d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1A11 11 0 0 0 2.18 7.07l3.66 2.83C6.71 7.31 9.14 5.38 12 5.38z" />
                                        </svg>
                                        Google
                                    </a>
                                    <a href="#">
                                        <svg width="16" height="16" viewBox="0 0 24 24" fill="none"
                                            stroke="currentColor" stroke-width="2" stroke-linecap="round"
                                            stroke-linejoin="round">
                                            <rect x="5" y="2" width="14" height="20" rx="2" />
                                            <line x1="12" y1="18" x2="12.01" y2="18" />
                                        </svg>
                                        Apple ID
                                    </a>
                                </div>

                                <!-- Nút đăng ký tài khoản -->
                                <div class="reg-wrap">
                                    <span class="reg-text">Chưa có tài khoản PolySneaker?</span>
                                    <a href="${ctx}/register" class="btn-register">
                                        <svg width="18" height="18" viewBox="0 0 24 24" fill="none"
                                            stroke="currentColor" stroke-width="2.2" stroke-linecap="round"
                                            stroke-linejoin="round">
                                            <path d="M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2" />
                                            <circle cx="9" cy="7" r="4" />
                                            <line x1="19" y1="8" x2="19" y2="14" />
                                            <line x1="22" y1="11" x2="16" y2="11" />
                                        </svg>
                                        Đăng Ký Tài Khoản
                                        <span class="gift">+200K</span>
                                    </a>
                                </div>

                                <div class="lg-foot">
                                    <span class="ssl">
                                        <svg width="11" height="11" viewBox="0 0 24 24" fill="none"
                                            stroke="currentColor" stroke-width="2.4" stroke-linecap="round"
                                            stroke-linejoin="round">
                                            <rect x="3" y="11" width="18" height="11" rx="2" />
                                            <path d="M7 11V7a5 5 0 0 1 10 0v4" />
                                        </svg>
                                        Mã hóa 256-bit SSL
                                    </span>
                                </div>
                        </section>

                    </div>
                </main>

                <!-- ===== Footer ===== -->
                <footer class="lg-bottom">
                    <div class="container lg-bottom-inner">
                        <span>© 2025 PolySneaker. Đẳng cấp tinh gọn, cam kết 100% chính hãng.</span>
                        <nav>
                            <a href="#">Bảo mật thông tin</a>
                            <i class="dot"></i>
                            <a href="#">Hỗ trợ trực tuyến</a>
                        </nav>
                    </div>
                </footer>

                <script>
                    // Hiện / ẩn mật khẩu
                    (function () {
                        var pw = document.getElementById('password');
                        document.getElementById('togglePw').addEventListener('click', function () {
                            pw.type = pw.type === 'password' ? 'text' : 'password';
                        });
                    })();
                </script>

            </body>

            </html>