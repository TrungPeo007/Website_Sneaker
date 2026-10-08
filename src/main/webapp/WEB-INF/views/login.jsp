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
    <title>Đăng nhập | PolySneaker</title>
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
            --text: #4A4038;
            --muted: #9A8C7E;
        }

        * { box-sizing: border-box; }

        body {
            margin: 0;
            min-height: 100vh;
            display: flex;
            flex-direction: column;
            font-family: 'Nunito Sans', Arial, sans-serif;
            letter-spacing: .1px;
            color: var(--text);
            background: linear-gradient(180deg, #FFF7E6 0, #FFFBF2 260px);
            -webkit-font-smoothing: antialiased;
            text-rendering: optimizeLegibility;
        }

        a { color: inherit; text-decoration: none; }
        img { display: block; }
        .container { max-width: 1240px; margin: 0 auto; padding: 0 24px; }

        /* ===== Header ===== */
        .lg-head { background: #fff; border-bottom: 1px solid #F5EEE4; }
        .lg-head-inner { display: flex; align-items: center; justify-content: space-between; height: 60px; }
        .lg-brand { display: flex; align-items: center; gap: 12px; }
        .logo { display: flex; align-items: center; gap: 8px; }
        .logo-mark { width: 30px; height: 30px; border-radius: 9px; background: var(--orange); display: flex; align-items: center; justify-content: center; }
        .logo-name { font-weight: 800; font-size: 13px; letter-spacing: .5px; color: var(--brown); }
        .logo-name b { color: var(--orange); font-weight: 800; }
        .brand-text { font-weight: 800; font-size: 15px; color: var(--head); }
        .lg-links { display: flex; align-items: center; gap: 18px; font-size: 12.5px; font-weight: 700; color: var(--brown); }
        .lg-links a, .lg-links span { display: inline-flex; align-items: center; gap: 7px; }
        .lg-links a:hover { color: var(--orange); }
        .lg-links .sep { width: 1px; height: 16px; background: #E8DCC6; }

        /* ===== Thẻ đăng nhập ===== */
        .lg-main { flex: 1; display: flex; align-items: center; justify-content: center; padding: 40px 24px; }
        .lg-card {
            width: 100%;
            max-width: 1000px;
            display: grid;
            grid-template-columns: 1fr 1fr;
            border-radius: 32px;
            overflow: hidden;
            background: #fff;
            border: 1px solid #FBF0D6;
            box-shadow: 0 24px 60px rgba(230, 160, 50, .16);
        }

        /* --- Bên trái --- */
        .lg-left {
            padding: 28px 30px 26px;
            display: flex;
            flex-direction: column;
            background:
                radial-gradient(360px 260px at 0% 0%, rgba(255, 214, 140, .35), transparent 70%),
                linear-gradient(160deg, #FFF3DA 0%, #FFFAF0 55%, #FFFFFF 100%);
        }
        .lg-left-top { display: flex; align-items: center; justify-content: space-between; }
        .vip-pill { font-size: 9.5px; font-weight: 800; letter-spacing: .9px; text-transform: uppercase; padding: 6px 14px; border-radius: 999px; background: #fff; border: 1px solid #F6E3B0; color: #8A4B08; }
        .brand-tiny { font-size: 9.5px; font-weight: 800; letter-spacing: 1.6px; color: #B98B5E; }

        .lg-visual { position: relative; width: 82%; margin: 30px auto 24px; padding: 12px; border-radius: 26px; background: #fff; box-shadow: 0 16px 36px rgba(247, 148, 29, .16); border: 1px solid #F8EBD0; }
        .lg-photo { position: relative; aspect-ratio: 4 / 3; border-radius: 16px; overflow: hidden; background: linear-gradient(135deg, #F6EEDF, #E8DAC2); }
        .lg-photo .ph { position: absolute; top: 50%; left: 50%; width: 64px; height: 64px; transform: translate(-50%, -50%); color: rgba(247, 148, 29, .35); }
        .lg-photo img { position: relative; z-index: 1; width: 100%; height: 100%; object-fit: cover; }
        .lg-auth-tag { position: absolute; z-index: 2; right: 14px; bottom: 14px; display: inline-flex; align-items: center; gap: 6px; font-size: 10px; font-weight: 700; padding: 5px 10px; border-radius: 999px; background: #fff; color: var(--head); box-shadow: 0 4px 12px rgba(0, 0, 0, .08); }
        .lg-auth-tag svg { color: var(--amber); }

        .lg-quote { text-align: center; font-size: 16px; font-weight: 800; color: var(--head); line-height: 1.4; margin: 0 auto 8px; max-width: 280px; }
        .lg-quote-sub { text-align: center; font-size: 11px; line-height: 1.55; color: #9B7A58; margin: 0 auto; max-width: 290px; }

        .lg-perks { display: grid; grid-template-columns: 1fr 1fr; gap: 14px; margin-top: auto; padding: 14px 16px; border-radius: 18px; background: rgba(255, 255, 255, .75); border: 1px solid #F8EBD0; }
        .perk { display: flex; align-items: center; gap: 9px; }
        .perk svg { color: var(--orange); flex-shrink: 0; }
        .perk b { display: block; font-size: 11px; font-weight: 800; color: var(--head); }
        .perk span { display: block; font-size: 10px; color: #B98B5E; margin-top: 1px; }
        .lg-left > .lg-quote-sub + .lg-perks { margin-top: 26px; }

        /* --- Bên phải --- */
        .lg-right { padding: 36px 44px 28px; display: flex; flex-direction: column; }
        .lg-badge { align-self: flex-start; display: inline-flex; align-items: center; gap: 7px; font-size: 9.5px; font-weight: 800; letter-spacing: .8px; text-transform: uppercase; padding: 6px 12px; border-radius: 999px; background: #FFF4D6; border: 1px solid #F6E3B0; color: #8A4B08; }
        .lg-badge svg { color: var(--amber); }
        .lg-title { font-size: 34px; font-weight: 800; color: var(--head); margin: 14px 0 8px; letter-spacing: -.2px; }
        .lg-sub { font-size: 12.5px; line-height: 1.55; color: #9B7A58; margin: 0 0 22px; }

        .lg-error { margin-bottom: 14px; padding: 10px 14px; border-radius: 12px; background: #FFEDE5; border: 1px solid #F8C9B0; color: #B4410C; font-size: 12px; font-weight: 600; }

        .fld-label { display: flex; align-items: center; justify-content: space-between; font-size: 12px; font-weight: 800; color: var(--head); margin-bottom: 8px; }
        .fld-label em { color: var(--orange); font-style: normal; }
        .fld-label a { font-size: 11.5px; font-weight: 700; color: var(--amber); }
        .fld-label a:hover { color: var(--orange); }
        .fld { position: relative; margin-bottom: 18px; }
        .fld > svg.lead { position: absolute; left: 15px; top: 50%; transform: translateY(-50%); color: var(--orange); pointer-events: none; }
        .fld input { width: 100%; height: 46px; padding: 0 44px; border-radius: 14px; border: 1.5px solid transparent; background: #FFF6E6; font-family: inherit; font-size: 13px; color: var(--text); outline: none; transition: border-color .15s, background .15s; }
        .fld input::placeholder { color: #BFA784; }
        .fld input:focus { border-color: var(--orange); background: #fff; }
        .fld input:-webkit-autofill { -webkit-box-shadow: 0 0 0 40px #FFF6E6 inset; -webkit-text-fill-color: var(--text); }
        .eye { position: absolute; right: 8px; top: 50%; transform: translateY(-50%); width: 34px; height: 34px; border: none; background: transparent; color: var(--orange); cursor: pointer; display: flex; align-items: center; justify-content: center; border-radius: 10px; }
        .eye:hover { background: rgba(247, 148, 29, .1); }

        .remember { display: flex; align-items: center; gap: 10px; font-size: 12px; color: #9B7A58; margin: 2px 0 20px; cursor: pointer; user-select: none; }
        .remember input { width: 18px; height: 18px; accent-color: var(--orange); margin: 0; cursor: pointer; }

        .btn-login { width: 100%; height: 50px; border: none; border-radius: 14px; background: linear-gradient(90deg, #F7A416 0%, #B8700C 60%, #7A4A08 100%); color: #fff; font-family: inherit; font-weight: 800; font-size: 14px; letter-spacing: .3px; display: flex; align-items: center; justify-content: center; gap: 8px; cursor: pointer; box-shadow: 0 12px 24px rgba(184, 112, 12, .28); transition: transform .15s, box-shadow .15s; }
        .btn-login:hover { transform: translateY(-1px); box-shadow: 0 16px 28px rgba(184, 112, 12, .34); }

        .divider { position: relative; text-align: center; margin: 22px 0 16px; font-size: 11px; color: #A89680; }
        .divider::before { content: ""; position: absolute; left: 0; right: 0; top: 50%; height: 1px; background: #F3E6CC; }
        .divider span { position: relative; padding: 0 12px; background: #fff; }

        .social { display: grid; grid-template-columns: 1fr 1fr; gap: 12px; }
        .social a { height: 42px; border-radius: 12px; background: #FFF6E6; border: 1px solid #F8E3BC; display: flex; align-items: center; justify-content: center; gap: 9px; font-size: 12.5px; font-weight: 700; color: var(--brown); transition: background .15s; }
        .social a:hover { background: #FFEDCC; }

        .lg-foot { display: flex; align-items: center; justify-content: space-between; gap: 12px; flex-wrap: wrap; margin-top: 24px; font-size: 12px; color: #9B7A58; }
        .lg-foot b { color: var(--head); font-weight: 800; }
        .lg-foot .reg:hover b { color: var(--orange); }
        .gift { display: inline-block; margin-left: 6px; padding: 3px 9px; border-radius: 999px; background: #FFE9A8; color: #8A4B08; font-size: 10.5px; font-weight: 800; }
        .ssl { display: inline-flex; align-items: center; gap: 6px; padding: 6px 12px; border-radius: 999px; background: #F6F1E8; color: #8E7C66; font-size: 9.5px; font-weight: 800; letter-spacing: .5px; text-transform: uppercase; }

        /* ===== Footer ===== */
        .lg-bottom { background: #fff; border-top: 1px solid #F5EEE4; }
        .lg-bottom-inner { display: flex; align-items: center; justify-content: space-between; gap: 16px; flex-wrap: wrap; height: 56px; font-size: 11px; color: #A8620F; }
        .lg-bottom nav { display: flex; align-items: center; gap: 18px; }
        .lg-bottom nav a:hover { color: var(--orange); }
        .lg-bottom .dot { width: 4px; height: 4px; border-radius: 50%; background: #A8620F; }

        /* ===== Responsive ===== */
        @media (max-width: 900px) {
            .lg-card { grid-template-columns: 1fr; max-width: 520px; }
            .lg-left { display: none; }
            .lg-right { padding: 30px 26px 24px; }
        }
        @media (max-width: 520px) {
            .lg-links .hotline { display: none; }
            .lg-links .sep { display: none; }
            .lg-title { font-size: 28px; }
            .lg-bottom-inner { height: auto; padding: 14px 0; flex-direction: column; align-items: flex-start; gap: 8px; }
        }
    </style>
</head>
<body>

<!-- ===== Header ===== -->
<header class="lg-head">
    <div class="container lg-head-inner">
        <div class="lg-brand">
            <a class="logo" href="${ctx}/">
                <span class="logo-mark">
                    <svg viewBox="0 0 24 24" fill="#fff" width="18" height="18"><path d="M2 16.5c0-1 .6-1.8 1.5-2.1l4.2-1.4 2.3-3.2c.3-.4.9-.5 1.3-.2l1.6 1.2c.6.5 1.4.8 2.2.9l3.4.5c1.6.2 2.8 1.6 2.8 3.2V17c0 .6-.4 1-1 1H3c-.6 0-1-.4-1-1v-.5z"/></svg>
                </span>
                <span class="logo-name">POLY<b>SNEAKER</b></span>
            </a>
            <span class="brand-text">PolySneaker</span>
        </div>

        <div class="lg-links">
            <a href="${ctx}/">
                <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><line x1="19" y1="12" x2="5" y2="12"/><polyline points="12 19 5 12 12 5"/></svg>
                Về Trang Chủ
            </a>
            <span class="sep"></span>
            <span class="hotline">
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M3 18v-6a9 9 0 0 1 18 0v6"/><path d="M21 19a2 2 0 0 1-2 2h-1a2 2 0 0 1-2-2v-3a2 2 0 0 1 2-2h3zM3 19a2 2 0 0 0 2 2h1a2 2 0 0 0 2-2v-3a2 2 0 0 0-2-2H3z"/></svg>
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
                <span class="vip-pill">Hội viên thượng hạng</span>
                <span class="brand-tiny">POLYSNEAKER</span>
            </div>

            <div class="lg-visual">
                <div class="lg-photo">
                    <svg class="ph" viewBox="0 0 24 24"><path fill="currentColor" d="M2 16.5c0-1 .6-1.8 1.5-2.1l4.2-1.4 2.3-3.2c.3-.4.9-.5 1.3-.2l1.6 1.2c.6.5 1.4.8 2.2.9l3.4.5c1.6.2 2.8 1.6 2.8 3.2V17c0 .6-.4 1-1 1H3c-.6 0-1-.4-1-1v-.5z"/></svg>
                    <img src="/static/assets/images/model_sneaker_login_images.jpg" alt="PolySneaker" onerror="this.style.display='none'">
                </div>
                <span class="lg-auth-tag">
                    <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="9"/><polyline points="8 12 11 15 16 9"/></svg>
                    Chính hãng 100%
                </span>
            </div>

            <h2 class="lg-quote">“Bước chân thanh lịch, tinh hoa tối giản Á Đông”</h2>
            <p class="lg-quote-sub">Mỗi chuyển động đều là sự tôn vinh của tính cân bằng và độ tinh tế thủ công thượng thừa.</p>

            <div class="lg-perks">
                <div class="perk">
                    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M6 3h12l4 6-10 12L2 9z"/><path d="M2 9h20"/></svg>
                    <div><b>Ưu tiên mở bán</b><span>Hàng phiên bản giới hạn</span></div>
                </div>
                <div class="perk">
                    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="9"/><polygon points="12 7 13.5 10.5 17 11 14.5 13.5 15 17 12 15.3 9 17 9.5 13.5 7 11 10.5 10.5"/></svg>
                    <div><b>Tích điểm PolyPoint</b><span>Đổi quà tặng độc quyền</span></div>
                </div>
            </div>
        </aside>

        <!-- Bên phải: form -->
        <section class="lg-right">
            <span class="lg-badge">
                <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M2 18l2-11 5 5 3-8 3 8 5-5 2 11z"/><line x1="2" y1="21" x2="22" y2="21"/></svg>
                Cửa ngõ phong cách
            </span>
            <h1 class="lg-title">Chào mừng trở lại</h1>
            <p class="lg-sub">Đăng nhập tài khoản PolySneaker để tiếp tục trải nghiệm bộ sưu tập mới nhất.</p>

            <c:if test="${not empty error}">
                <div class="lg-error"><c:out value="${error}"/></div>
            </c:if>

            <form id="loginForm" action="${ctx}/login" method="post" autocomplete="on">
                <label class="fld-label" for="username">Tên đăng nhập <em>*</em></label>
                <div class="fld">
                    <svg class="lead" width="17" height="17" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
                    <input type="text" id="username" name="username" placeholder="Nhập tên đăng nhập hoặc số điện thoại..." autocomplete="username" required>
                </div>

                <div class="fld-label">
                    <label for="password">Mật khẩu bí mật <em>*</em></label>
                    <a href="#">Quên mật khẩu?</a>
                </div>
                <div class="fld">
                    <svg class="lead" width="17" height="17" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="11" width="18" height="11" rx="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/></svg>
                    <input type="password" id="password" name="password" placeholder="••••••••" autocomplete="current-password" required>
                    <button type="button" class="eye" id="togglePw" aria-label="Hiện/ẩn mật khẩu">
                        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/></svg>
                    </button>
                </div>

                <label class="remember">
                    <input type="checkbox" name="remember" checked>
                    Ghi nhớ phiên đăng nhập trên thiết bị này
                </label>

                <button type="submit" class="btn-login">
                    Đăng Nhập Ngay
                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round"><line x1="5" y1="12" x2="19" y2="12"/><polyline points="12 5 19 12 12 19"/></svg>
                </button>
            </form>

            <div class="divider"><span>hoặc tiếp tục với</span></div>

            <div class="social">
                <a href="#">
                    <svg width="18" height="18" viewBox="0 0 24 24"><path fill="#4285F4" d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92a5.06 5.06 0 0 1-2.2 3.32v2.77h3.57c2.08-1.92 3.27-4.74 3.27-8.1z"/><path fill="#34A853" d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84A11 11 0 0 0 12 23z"/><path fill="#FBBC05" d="M5.84 14.1a6.6 6.6 0 0 1 0-4.2V7.07H2.18a11 11 0 0 0 0 9.86l3.66-2.83z"/><path fill="#EA4335" d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1A11 11 0 0 0 2.18 7.07l3.66 2.83C6.71 7.31 9.14 5.38 12 5.38z"/></svg>
                    Google
                </a>
                <a href="#">
                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="5" y="2" width="14" height="20" rx="2"/><line x1="12" y1="18" x2="12.01" y2="18"/></svg>
                    Apple ID
                </a>
            </div>

            <div class="lg-foot">
                <a href="#" class="reg">Chưa có tài khoản? <b>Đăng ký ngay</b><span class="gift">+200K</span></a>
                <span class="ssl">
                    <svg width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="11" width="18" height="11" rx="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/></svg>
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

    // Tạm chặn submit vì chưa có xử lý đăng nhập phía server.
    // Khi làm xong @PostMapping("/login") thì xóa đoạn này.
    document.getElementById('loginForm').addEventListener('submit', function (e) { e.preventDefault(); });
</script>

</body>
</html>
