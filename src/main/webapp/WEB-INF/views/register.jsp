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
            --danger: #D8502A;
            --ok: #3E9B5F;
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
        .lg-head-inner { display: flex; align-items: center; justify-content: space-between; height: 84px; }
        .lg-brand { display: flex; align-items: center; gap: 12px; }
        .logo { display: flex; align-items: center; gap: 10px; flex-shrink: 0; }
        .logo-mark { height: 64px; min-width: 64px; display: flex; align-items: center; justify-content: center; flex-shrink: 0; }
        .logo-mark img { height: 100%; width: auto; max-width: 240px; object-fit: contain; border-radius: 10px; }
        .logo-fallback { display: none; }
        .logo-mark.no-img { width: 64px; background: var(--orange); border-radius: 16px; }
        .logo-mark.no-img .logo-fallback { display: block; width: 32px; height: 32px; }
        .lg-links { display: flex; align-items: center; gap: 18px; font-size: 12.5px; font-weight: 700; color: var(--brown); }
        .lg-links a, .lg-links span { display: inline-flex; align-items: center; gap: 7px; }
        .lg-links a:hover { color: var(--orange); }
        .lg-links .sep { width: 1px; height: 16px; background: #E8DCC6; }

        /* ===== Thẻ đăng ký ===== */
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

        .lg-quote { text-align: center; font-size: 16px; font-weight: 800; color: var(--head); line-height: 1.4; margin: 0 auto 8px; max-width: 290px; }
        .lg-quote-sub { text-align: center; font-size: 11px; line-height: 1.55; color: #9B7A58; margin: 0 auto; max-width: 290px; }

        .lg-perks { display: grid; grid-template-columns: 1fr 1fr; gap: 14px; margin-top: 26px; padding: 14px 16px; border-radius: 18px; background: rgba(255, 255, 255, .75); border: 1px solid #F8EBD0; }
        .lg-left .lg-perks { margin-top: auto; }
        .perk { display: flex; align-items: center; gap: 9px; }
        .perk svg { color: var(--orange); flex-shrink: 0; }
        .perk b { display: block; font-size: 11px; font-weight: 800; color: var(--head); }
        .perk span { display: block; font-size: 10px; color: #B98B5E; margin-top: 1px; }

        /* --- Bên phải --- */
        .lg-right { padding: 34px 44px 26px; display: flex; flex-direction: column; }
        .lg-badge { align-self: flex-start; display: inline-flex; align-items: center; gap: 7px; font-size: 9.5px; font-weight: 800; letter-spacing: .8px; text-transform: uppercase; padding: 6px 12px; border-radius: 999px; background: #FFF4D6; border: 1px solid #F6E3B0; color: #8A4B08; }
        .lg-badge svg { color: var(--amber); }
        .lg-title { font-size: 32px; font-weight: 800; color: var(--head); margin: 14px 0 8px; letter-spacing: -.2px; }
        .lg-sub { font-size: 12.5px; line-height: 1.55; color: #9B7A58; margin: 0 0 20px; }

        .lg-error { margin-bottom: 14px; padding: 10px 14px; border-radius: 12px; background: #FFEDE5; border: 1px solid #F8C9B0; color: #B4410C; font-size: 12px; font-weight: 600; }

        .group { margin-bottom: 15px; }
        .fld-label { display: flex; align-items: center; justify-content: space-between; font-size: 12px; font-weight: 800; color: var(--head); margin-bottom: 7px; }
        .fld-label em { color: var(--orange); font-style: normal; }
        .fld { position: relative; }
        .fld > svg.lead { position: absolute; left: 15px; top: 50%; transform: translateY(-50%); color: var(--orange); pointer-events: none; }
        .fld input { width: 100%; height: 46px; padding: 0 44px; border-radius: 14px; border: 1.5px solid transparent; background: #FFF6E6; font-family: inherit; font-size: 13px; color: var(--text); outline: none; transition: border-color .15s, background .15s; }
        .fld input::placeholder { color: #BFA784; }
        .fld input:focus { border-color: var(--orange); background: #fff; }
        .fld input:-webkit-autofill { -webkit-box-shadow: 0 0 0 40px #FFF6E6 inset; -webkit-text-fill-color: var(--text); }
        .group.bad .fld input { border-color: var(--danger); background: #fff; }
        .group.good .fld input { border-color: #BFE3CB; background: #fff; }
        .msg { display: none; margin: 6px 0 0 4px; font-size: 11.5px; font-weight: 600; color: var(--danger); }
        .group.bad .msg { display: block; }
        .eye { position: absolute; right: 8px; top: 50%; transform: translateY(-50%); width: 34px; height: 34px; border: none; background: transparent; color: var(--orange); cursor: pointer; display: flex; align-items: center; justify-content: center; border-radius: 10px; }
        .eye:hover { background: rgba(247, 148, 29, .1); }

        /* Thanh đo độ mạnh mật khẩu */
        .meter { display: flex; align-items: center; gap: 6px; margin-top: 9px; }
        .meter i { flex: 0 0 auto; width: calc((100% - 120px) / 4); min-width: 28px; height: 4px; border-radius: 4px; background: #F1E6D0; transition: background .2s; }
        .meter .lvl { margin-left: 6px; font-size: 11px; font-weight: 700; color: #A89680; white-space: nowrap; }
        .meter[data-s="1"] i:nth-child(-n+1) { background: #E5603C; }
        .meter[data-s="2"] i:nth-child(-n+2) { background: #F2A33A; }
        .meter[data-s="3"] i:nth-child(-n+3) { background: #C9C23A; }
        .meter[data-s="4"] i:nth-child(-n+4) { background: var(--ok); }

        .btn-login { width: 100%; height: 50px; margin-top: 6px; border: none; border-radius: 14px; background: linear-gradient(90deg, #F7A416 0%, #B8700C 60%, #7A4A08 100%); color: #fff; font-family: inherit; font-weight: 800; font-size: 14px; letter-spacing: .3px; display: flex; align-items: center; justify-content: center; gap: 8px; cursor: pointer; box-shadow: 0 12px 24px rgba(184, 112, 12, .28); transition: transform .15s, box-shadow .15s; }
        .btn-login:hover { transform: translateY(-1px); box-shadow: 0 16px 28px rgba(184, 112, 12, .34); }

        .note { margin: 12px 0 0; text-align: center; font-size: 11px; line-height: 1.55; color: #A89680; }
        .note a { color: var(--amber); font-weight: 700; }
        .note a:hover { color: var(--orange); }

        .divider { position: relative; text-align: center; margin: 18px 0 14px; font-size: 11px; color: #A89680; }
        .divider::before { content: ""; position: absolute; left: 0; right: 0; top: 50%; height: 1px; background: #F3E6CC; }
        .divider span { position: relative; padding: 0 12px; background: #fff; }

        .btn-register { width: 100%; height: 48px; border-radius: 14px; border: 1.5px solid var(--orange); background: #fff; color: var(--head); font-family: inherit; font-weight: 800; font-size: 14px; letter-spacing: .3px; display: flex; align-items: center; justify-content: center; gap: 9px; cursor: pointer; transition: background .15s, transform .15s, box-shadow .15s; }
        .btn-register svg { color: var(--orange); }
        .btn-register:hover { background: #FFF6E6; transform: translateY(-1px); box-shadow: 0 10px 22px rgba(247, 148, 29, .16); }

        .lg-foot { display: flex; align-items: center; justify-content: center; margin-top: 18px; }
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
            .logo-mark img { max-width: 150px; }
            .lg-title { font-size: 27px; }
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
            <img src="/static/assets/images/logo_poly_store.png" alt="PolySneaker" onerror="this.parentNode.classList.add('no-img'); this.remove();">
            <svg class="logo-fallback" viewBox="0 0 24 24" fill="#fff" width="24" height="24"><path d="M2 16.5c0-1 .6-1.8 1.5-2.1l4.2-1.4 2.3-3.2c.3-.4.9-.5 1.3-.2l1.6 1.2c.6.5 1.4.8 2.2.9l3.4.5c1.6.2 2.8 1.6 2.8 3.2V17c0 .6-.4 1-1 1H3c-.6 0-1-.4-1-1v-.5z"/></svg>
        </span>
    </a>
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
                <span class="vip-pill">Thành viên mới</span>
                <span class="brand-tiny">POLYSNEAKER</span>
            </div>

            <div class="lg-visual">
                <div class="lg-photo">
                    <svg class="ph" viewBox="0 0 24 24"><path fill="currentColor" d="M2 16.5c0-1 .6-1.8 1.5-2.1l4.2-1.4 2.3-3.2c.3-.4.9-.5 1.3-.2l1.6 1.2c.6.5 1.4.8 2.2.9l3.4.5c1.6.2 2.8 1.6 2.8 3.2V17c0 .6-.4 1-1 1H3c-.6 0-1-.4-1-1v-.5z"/></svg>
                    <img src="/static/assets/images/hinh-dong-chu-welcome-dep_075934502.gif" alt="PolySneaker" onerror="this.style.display='none'">
                </div>
                <span class="lg-auth-tag">
                    <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="9"/><polyline points="8 12 11 15 16 9"/></svg>
                    Chính hãng 100%
                </span>
            </div>

            <h2 class="lg-quote">“Gia nhập cộng đồng yêu giày tối giản Á Đông”</h2>
            <p class="lg-quote-sub">Tạo tài khoản chỉ mất một phút để nhận ưu đãi chào mừng và theo dõi những mẫu giày mới nhất.</p>

            <div class="lg-perks">
                <div class="perk">
                    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 12 20 22 4 22 4 12"/><rect x="2" y="7" width="20" height="5"/><line x1="12" y1="22" x2="12" y2="7"/><path d="M12 7H7.5a2.5 2.5 0 0 1 0-5C11 2 12 7 12 7z"/><path d="M12 7h4.5a2.5 2.5 0 0 0 0-5C13 2 12 7 12 7z"/></svg>
                    <div><b>Voucher chào mừng</b><span>Giảm 200.000đ đơn đầu</span></div>
                </div>
                <div class="perk">
                    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="9"/><polygon points="12 7 13.5 10.5 17 11 14.5 13.5 15 17 12 15.3 9 17 9.5 13.5 7 11 10.5 10.5"/></svg>
                    <div><b>Tích điểm PolyPoint</b><span>Đổi quà tặng độc quyền</span></div>
                </div>
            </div>
        </aside>

        <!-- Bên phải: form đăng ký -->
        <section class="lg-right">
            <span class="lg-badge">
                <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><line x1="19" y1="8" x2="19" y2="14"/><line x1="22" y1="11" x2="16" y2="11"/></svg>
                Bắt đầu hành trình
            </span>
            <h1 class="lg-title">Tạo tài khoản mới</h1>
            <p class="lg-sub">Điền thông tin bên dưới để trở thành thành viên PolySneaker.</p>

            <c:if test="${not empty error}">
                <div class="lg-error"><c:out value="${error}"/></div>
            </c:if>

            <form id="regForm" action="${ctx}/register" method="post" autocomplete="on" novalidate>

                <!-- Tên đăng nhập -->
                <div class="group" id="g-username">
                    <label class="fld-label" for="username">Tên đăng nhập <em>*</em></label>
                    <div class="fld">
                        <svg class="lead" width="17" height="17" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
                        <input type="text" id="username" name="username" placeholder="Từ 4 đến 20 ký tự, không dấu..." autocomplete="username" value="<c:out value='${param.username}'/>">
                    </div>
                    <div class="msg" id="m-username"></div>
                </div>

                <!-- Email -->
                <div class="group" id="g-email">
                    <label class="fld-label" for="email">Email <em>*</em></label>
                    <div class="fld">
                        <svg class="lead" width="17" height="17" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="2" y="4" width="20" height="16" rx="2"/><polyline points="22 6 12 13 2 6"/></svg>
                        <input type="email" id="email" name="email" placeholder="vidu@email.com" autocomplete="email" value="<c:out value='${param.email}'/>">
                    </div>
                    <div class="msg" id="m-email"></div>
                </div>

                <!-- Mật khẩu -->
                <div class="group" id="g-password">
                    <label class="fld-label" for="password">Mật khẩu <em>*</em></label>
                    <div class="fld">
                        <svg class="lead" width="17" height="17" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="11" width="18" height="11" rx="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/></svg>
                        <input type="password" id="password" name="password" placeholder="Ít nhất 6 ký tự" autocomplete="new-password">
                        <button type="button" class="eye" data-target="password" aria-label="Hiện/ẩn mật khẩu">
                            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/></svg>
                        </button>
                    </div>
                    <div class="meter" id="meter" data-s="0"><i></i><i></i><i></i><i></i><span class="lvl" id="lvl"></span></div>
                    <div class="msg" id="m-password"></div>
                </div>

                <!-- Xác nhận mật khẩu -->
                <div class="group" id="g-confirm">
                    <label class="fld-label" for="confirm">Xác nhận mật khẩu <em>*</em></label>
                    <div class="fld">
                        <svg class="lead" width="17" height="17" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/><polyline points="9 12 11 14 15 10"/></svg>
                        <input type="password" id="confirm" name="confirmPassword" placeholder="Nhập lại mật khẩu" autocomplete="new-password">
                        <button type="button" class="eye" data-target="confirm" aria-label="Hiện/ẩn mật khẩu">
                            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/></svg>
                        </button>
                    </div>
                    <div class="msg" id="m-confirm"></div>
                </div>

                <button type="submit" class="btn-login">
                    Tạo Tài Khoản
                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round"><line x1="5" y1="12" x2="19" y2="12"/><polyline points="12 5 19 12 12 19"/></svg>
                </button>

                <p class="note">Bằng việc đăng ký, bạn đồng ý với <a href="#">Điều khoản sử dụng</a> và <a href="#">Chính sách bảo mật</a> của PolySneaker.</p>
            </form>

            <div class="divider"><span>đã có tài khoản?</span></div>

            <a href="${ctx}/login" class="btn-register">
                <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><path d="M15 3h4a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2h-4"/><polyline points="10 17 15 12 10 7"/><line x1="15" y1="12" x2="3" y2="12"/></svg>
                Đăng Nhập
            </a>

            <div class="lg-foot">
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
            if (!/^[A-Za-z0-9_]{4,20}$/.test(v)) return setState('username', false, 'Từ 4 đến 20 ký tự, chỉ gồm chữ không dấu, số và dấu gạch dưới (_).');
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