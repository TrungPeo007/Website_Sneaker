<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ taglib uri="jakarta.tags.core" prefix="c" %>
        <c:set var="ctx" value="${pageContext.request.contextPath}" />
        <!DOCTYPE html>
        <html lang="vi">

        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1">
            <title>Register</title>
            <link rel="preconnect" href="https://fonts.googleapis.com">
            <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
            <link href="https://fonts.googleapis.com/css2?family=Nunito+Sans:wght@300;400;600;700;800&display=swap"
                rel="stylesheet">
            <link rel="stylesheet" href="${ctx}/static/assets/css/register.css">
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
                            <span class="vip-pill">Thành viên mới</span>
                            <span class="brand-tiny">POLYSNEAKER</span>
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

                        <h2 class="lg-quote">“Gia nhập cộng đồng yêu giày tối giản Á Đông”</h2>
                        <p class="lg-quote-sub">Tạo tài khoản chỉ mất một phút để nhận ưu đãi chào mừng và theo dõi
                            những mẫu giày mới nhất.</p>

                        <div class="lg-perks">
                            <div class="perk">
                                <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor"
                                    stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                    <polyline points="20 12 20 22 4 22 4 12" />
                                    <rect x="2" y="7" width="20" height="5" />
                                    <line x1="12" y1="22" x2="12" y2="7" />
                                    <path d="M12 7H7.5a2.5 2.5 0 0 1 0-5C11 2 12 7 12 7z" />
                                    <path d="M12 7h4.5a2.5 2.5 0 0 0 0-5C13 2 12 7 12 7z" />
                                </svg>
                                <div><b>Voucher chào mừng</b><span>Giảm 200.000đ đơn đầu</span></div>
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

                    <!-- Bên phải: form đăng ký -->
                    <section class="lg-right">
                        <span class="lg-badge">
                            <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor"
                                stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                <path d="M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2" />
                                <circle cx="9" cy="7" r="4" />
                                <line x1="19" y1="8" x2="19" y2="14" />
                                <line x1="22" y1="11" x2="16" y2="11" />
                            </svg>
                            Bắt đầu hành trình
                        </span>
                        <h1 class="lg-title">Tạo tài khoản mới</h1>
                        <p class="lg-sub">Điền thông tin bên dưới để trở thành thành viên PolySneaker.</p>

                        <c:if test="${not empty error}">
                            <div class="lg-error">
                                <c:out value="${error}" />
                            </div>
                        </c:if>
                        <c:if test="${not empty errors}">
                            <div class="lg-error">
                                <c:forEach items="${errors}" var="e">
                                    <div>
                                        <c:out value="${e.value}" />
                                    </div>
                                </c:forEach>
                            </div>
                        </c:if>

                        <form id="regForm" action="${ctx}/register" method="post" autocomplete="on" novalidate>

                            <!-- Tên đăng nhập -->
                            <div class="group" id="g-username">
                                <label class="fld-label" for="username">Tên đăng nhập <em>*</em></label>
                                <div class="fld">
                                    <svg class="lead" width="17" height="17" viewBox="0 0 24 24" fill="none"
                                        stroke="currentColor" stroke-width="2" stroke-linecap="round"
                                        stroke-linejoin="round">
                                        <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2" />
                                        <circle cx="12" cy="7" r="4" />
                                    </svg>
                                   <input type="text" id="username" name="username" placeholder="Nhập tên đăng nhập" autocomplete="username" value="<c:out value='${param.username}'/>">
                                </div>
                                <div class="msg" id="m-username"></div>
                            </div>

                            <!-- Email -->
                            <div class="group" id="g-email">
                                <label class="fld-label" for="email">Email <em>*</em></label>
                                <div class="fld">
                                    <svg class="lead" width="17" height="17" viewBox="0 0 24 24" fill="none"
                                        stroke="currentColor" stroke-width="2" stroke-linecap="round"
                                        stroke-linejoin="round">
                                        <rect x="2" y="4" width="20" height="16" rx="2" />
                                        <polyline points="22 6 12 13 2 6" />
                                    </svg>
                                    <input type="email" id="email" name="email" placeholder="vidu@email.com"
                                        autocomplete="email" value="<c:out value='${param.email}'/>">
                                </div>
                                <div class="msg" id="m-email"></div>
                            </div>

                            <!-- Mật khẩu -->
                            <div class="group" id="g-password">
                                <label class="fld-label" for="password">Mật khẩu <em>*</em></label>
                                <div class="fld">
                                    <svg class="lead" width="17" height="17" viewBox="0 0 24 24" fill="none"
                                        stroke="currentColor" stroke-width="2" stroke-linecap="round"
                                        stroke-linejoin="round">
                                        <rect x="3" y="11" width="18" height="11" rx="2" />
                                        <path d="M7 11V7a5 5 0 0 1 10 0v4" />
                                    </svg>
                                    <input type="password" id="password" name="password" placeholder="Ít nhất 6 ký tự"
                                        autocomplete="new-password">
                                    <button type="button" class="eye" data-target="password"
                                        aria-label="Hiện/ẩn mật khẩu">
                                        <svg width="18" height="18" viewBox="0 0 24 24" fill="none"
                                            stroke="currentColor" stroke-width="2" stroke-linecap="round"
                                            stroke-linejoin="round">
                                            <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z" />
                                            <circle cx="12" cy="12" r="3" />
                                        </svg>
                                    </button>
                                </div>
                                <div class="meter" id="meter" data-s="0"><i></i><i></i><i></i><i></i><span class="lvl"
                                        id="lvl"></span></div>
                                <div class="msg" id="m-password"></div>
                            </div>

                            <!-- Xác nhận mật khẩu -->
                            <div class="group" id="g-confirm">
                                <label class="fld-label" for="confirm">Xác nhận mật khẩu <em>*</em></label>
                                <div class="fld">
                                    <svg class="lead" width="17" height="17" viewBox="0 0 24 24" fill="none"
                                        stroke="currentColor" stroke-width="2" stroke-linecap="round"
                                        stroke-linejoin="round">
                                        <path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z" />
                                        <polyline points="9 12 11 14 15 10" />
                                    </svg>
                                    <input type="password" id="confirm" name="confirmPassword"
                                        placeholder="Nhập lại mật khẩu" autocomplete="new-password">
                                    <button type="button" class="eye" data-target="confirm"
                                        aria-label="Hiện/ẩn mật khẩu">
                                        <svg width="18" height="18" viewBox="0 0 24 24" fill="none"
                                            stroke="currentColor" stroke-width="2" stroke-linecap="round"
                                            stroke-linejoin="round">
                                            <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z" />
                                            <circle cx="12" cy="12" r="3" />
                                        </svg>
                                    </button>
                                </div>
                                <div class="msg" id="m-confirm"></div>
                            </div>

                            <button type="submit" class="btn-login">
                                Tạo Tài Khoản
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor"
                                    stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round">
                                    <line x1="5" y1="12" x2="19" y2="12" />
                                    <polyline points="12 5 19 12 12 19" />
                                </svg>
                            </button>

                            <p class="note">Bằng việc đăng ký, bạn đồng ý với <a href="#">Điều khoản sử dụng</a> và <a
                                    href="#">Chính sách bảo mật</a> của PolySneaker.</p>
                        </form>

                        <div class="divider"><span>đã có tài khoản?</span></div>

                        <a href="${ctx}/login" class="btn-register">
                            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor"
                                stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round">
                                <path d="M15 3h4a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2h-4" />
                                <polyline points="10 17 15 12 10 7" />
                                <line x1="15" y1="12" x2="3" y2="12" />
                            </svg>
                            Đăng Nhập
                        </a>

                        <div class="lg-foot">
                            <span class="ssl">
                                <svg width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="currentColor"
                                    stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round">
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
                (function () {
                    // Đặt true khi đã làm xong @PostMapping("/register") để form gửi lên server thật
                    var BACKEND_READY = true;

                    var form = document.getElementById('regForm');
                    var f = {
                        username: document.getElementById('username'),
                        email: document.getElementById('email'),
                        password: document.getElementById('password'),
                        confirm: document.getElementById('confirm')
                    };

                    function setState(key, ok, text) {
                        var g = document.getElementById('g-' + key);
                        var m = document.getElementById('m-' + key);
                        g.classList.toggle('bad', !ok);
                        g.classList.toggle('good', ok && f[key].value !== '');
                        m.textContent = ok ? '' : text;
                        return ok;
                    }

                    function checkUsername() {
                        var v = f.username.value.trim();
                        if (v === '') return setState('username', false, 'Vui lòng nhập tên đăng nhập.');
                        if (v.length > 50) return setState('username', false, 'Tên đăng nhập tối đa 50 ký tự.');
                        return setState('username', true, '');
                    }

                    function checkEmail() {
                        var v = f.email.value.trim();
                        if (v === '') return setState('email', false, 'Vui lòng nhập email.');
                        if (!/^[^\s@]+@[^\s@]+\.[^\s@]{2,}$/.test(v)) return setState('email', false, 'Email chưa đúng định dạng (ví dụ: ten@email.com).');
                        return setState('email', true, '');
                    }

                    function strength(p) {
                        var s = 0;
                        if (p.length >= 6) s++;
                        if (p.length >= 10) s++;
                        if (/[a-z]/.test(p) && /[A-Z]/.test(p)) s++;
                        if (/\d/.test(p) && /[^A-Za-z0-9]/.test(p)) s++;
                        return p.length === 0 ? 0 : Math.max(1, s);
                    }

                    function updateMeter() {
                        var s = strength(f.password.value);
                        var names = ['', 'Yếu', 'Trung bình', 'Khá', 'Mạnh'];
                        document.getElementById('meter').setAttribute('data-s', s);
                        document.getElementById('lvl').textContent = names[s];
                    }

                    function checkPassword() {
                        var v = f.password.value;
                        updateMeter();
                        if (v === '') return setState('password', false, 'Vui lòng nhập mật khẩu.');
                        if (v.length < 6) return setState('password', false, 'Mật khẩu cần có ít nhất 6 ký tự.');
                        return setState('password', true, '');
                    }

                    function checkConfirm() {
                        var v = f.confirm.value;
                        if (v === '') return setState('confirm', false, 'Vui lòng nhập lại mật khẩu.');
                        if (v !== f.password.value) return setState('confirm', false, 'Mật khẩu xác nhận chưa trùng khớp.');
                        return setState('confirm', true, '');
                    }

                    // Kiểm tra ngay khi rời ô; ô nào đã báo lỗi thì kiểm tra lại liên tục khi gõ
                    function bind(el, fn, key) {
                        el.addEventListener('blur', fn);
                        el.addEventListener('input', function () {
                            if (document.getElementById('g-' + key).classList.contains('bad') || key === 'password') fn();
                        });
                    }
                    bind(f.username, checkUsername, 'username');
                    bind(f.email, checkEmail, 'email');
                    bind(f.password, checkPassword, 'password');
                    bind(f.confirm, checkConfirm, 'confirm');
                    f.password.addEventListener('input', function () {
                        if (f.confirm.value !== '') checkConfirm();
                    });

                    // Hiện / ẩn mật khẩu
                    document.querySelectorAll('.eye').forEach(function (btn) {
                        btn.addEventListener('click', function () {
                            var input = document.getElementById(btn.getAttribute('data-target'));
                            input.type = input.type === 'password' ? 'text' : 'password';
                        });
                    });

                    form.addEventListener('submit', function (e) {
                        var results = [checkUsername(), checkEmail(), checkPassword(), checkConfirm()];
                        var ok = results.every(function (r) { return r; });
                        if (!ok) {
                            e.preventDefault();
                            var firstBad = form.querySelector('.group.bad input');
                            if (firstBad) firstBad.focus();
                            return;
                        }
                        if (!BACKEND_READY) {
                            e.preventDefault();
                            alert('Thông tin hợp lệ! (Bản giao diện: chưa có xử lý đăng ký phía server)');
                        }
                    });
                })();
            </script>

        </body>

        </html>