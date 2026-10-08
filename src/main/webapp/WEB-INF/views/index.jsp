<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Trang chủ | PolySneaker</title>
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
            --soft: #B77A3E;
        }

        * { box-sizing: border-box; }

        body {
            margin: 0;
            font-family: 'Nunito Sans', Arial, sans-serif;
            font-weight: 400;
            letter-spacing: .1px;
            background: var(--bg);
            color: var(--text);
            -webkit-font-smoothing: antialiased;
            -moz-osx-font-smoothing: grayscale;
            text-rendering: optimizeLegibility;
        }

        a { color: inherit; text-decoration: none; }
        img { display: block; }
        .container { max-width: 1240px; margin: 0 auto; padding: 0 24px; }

        /* ===== Thanh quảng cáo ===== */
        .announce-bar { display: flex; align-items: center; justify-content: center; gap: 10px; padding: 9px 16px; background: #FFF6DC; border-bottom: 1px solid #F6E8C0; text-align: center; }
        .announce-dot { width: 8px; height: 8px; border-radius: 50%; background: #F9A825; flex-shrink: 0; }
        .announce-text { font-size: 13px; font-weight: 600; color: #A8620F; letter-spacing: .2px; }

        /* ===== Header ===== */
        .site-header { background: #fff; border-bottom: 1px solid #F5EEE4; position: sticky; top: 0; z-index: 20; }
        .header-inner { display: flex; align-items: center; gap: 22px; height: 76px; }

        .logo { display: flex; align-items: center; gap: 10px; flex-shrink: 0; }
        .logo-mark { width: 42px; height: 42px; border-radius: 12px; background: var(--orange); display: flex; align-items: center; justify-content: center; }
        .logo-text { display: flex; flex-direction: column; line-height: 1.1; }
        .logo-name { font-weight: 800; font-size: 17px; letter-spacing: .6px; color: var(--brown); }
        .logo-name b { color: var(--orange); font-weight: 800; }
        .logo-sub { font-size: 8.5px; letter-spacing: 1.8px; color: var(--muted); font-weight: 600; margin-top: 3px; }

        .nav { display: flex; align-items: center; gap: 4px; }
        .nav a { display: flex; align-items: center; gap: 6px; padding: 9px 16px; border-radius: 999px; font-weight: 600; font-size: 14px; letter-spacing: .2px; color: var(--brown); transition: background .15s, color .15s; }
        .nav a:hover { background: var(--cream); color: var(--orange); }
        .nav a.active { background: var(--cream); color: var(--orange); }
        .nav .chev { opacity: .6; }

        .header-search { flex: 1; min-width: 200px; max-width: 320px; display: flex; align-items: center; gap: 8px; margin-left: auto; padding: 0 16px; height: 42px; border-radius: 999px; background: var(--cream); border: 1.5px solid var(--cream-border); color: var(--orange); }
        .header-search input { flex: 1; border: none; outline: none; background: transparent; font-family: inherit; font-size: 13px; font-weight: 400; color: var(--text); }
        .header-search input::placeholder { color: #BFA784; font-weight: 400; }

        .header-actions { display: flex; align-items: center; gap: 12px; flex-shrink: 0; }
        .icon-btn { position: relative; width: 42px; height: 42px; border-radius: 12px; border: 1.5px solid var(--cream-border); background: #fff; color: var(--orange); display: flex; align-items: center; justify-content: center; transition: background .15s; }
        .icon-btn:hover { background: var(--cream); }
        .badge { position: absolute; top: -7px; right: -7px; min-width: 19px; height: 19px; padding: 0 5px; border-radius: 999px; background: var(--orange); color: #fff; font-size: 11px; font-weight: 700; display: flex; align-items: center; justify-content: center; border: 2px solid #fff; }
        .account-btn { display: flex; align-items: center; gap: 9px; padding: 5px 16px 5px 5px; border-radius: 999px; background: var(--cream); border: 1.5px solid var(--cream-border); font-weight: 600; font-size: 13.5px; letter-spacing: .2px; color: var(--brown); }
        .account-btn:hover { background: #FFEDCC; }
        .avatar { width: 32px; height: 32px; border-radius: 50%; background: var(--orange); display: flex; align-items: center; justify-content: center; }

        /* ===== Dùng chung cho các section ===== */
        main.container { padding-bottom: 72px; }
        .sec { margin-top: 44px; }
        .sec-head { display: flex; align-items: flex-end; justify-content: space-between; gap: 20px; margin-bottom: 22px; }
        .eyebrow { font-size: 11.5px; font-weight: 800; letter-spacing: .9px; text-transform: uppercase; color: var(--amber); }
        .sec-title { font-size: 26px; font-weight: 800; color: var(--head); margin: 4px 0 0; letter-spacing: .1px; }
        .pill-link { display: inline-flex; align-items: center; gap: 8px; padding: 10px 18px; border-radius: 999px; background: #FFF4D6; border: 1px solid var(--cream-border); color: #8A4B08; font-weight: 700; font-size: 13px; white-space: nowrap; transition: background .15s; }
        .pill-link:hover { background: #FFEBBB; }
        .text-link { display: inline-flex; align-items: center; gap: 8px; color: var(--head); font-weight: 700; font-size: 13.5px; white-space: nowrap; }
        .text-link:hover { color: var(--orange); }

        /* Ảnh có nền dự phòng: chưa có file ảnh vẫn hiện khung đẹp */
        .media { position: relative; overflow: hidden; }
        .media .ph { position: absolute; top: 50%; left: 50%; width: 64px; height: 64px; transform: translate(-50%, -50%); color: rgba(247, 148, 29, .35); }
        .media img { position: relative; z-index: 1; }

        /* ===== 1. Hero ===== */
        .hero-card {
            margin-top: 26px;
            display: grid;
            grid-template-columns: 1.08fr .92fr;
            gap: 44px;
            align-items: center;
            padding: 44px 48px;
            border-radius: 30px;
            background:
                radial-gradient(520px 260px at 92% 100%, rgba(247, 180, 60, .22), transparent 70%),
                linear-gradient(135deg, #FFFFFF 0%, #FFFDF7 55%, #FFF5DC 100%);
            border: 1px solid #FBF0D6;
            box-shadow: 0 18px 50px rgba(230, 160, 50, .12);
        }
        .hero-badges { display: inline-flex; align-items: center; gap: 10px; padding: 6px 8px 6px 10px; border-radius: 999px; background: #FFFAEA; border: 1px solid #F6E3B0; }
        .hero-badges .dot { width: 12px; height: 12px; border-radius: 50%; background: #FBE7A6; }
        .hero-badges .txt { font-size: 11px; font-weight: 700; letter-spacing: .6px; color: #8A4B08; text-transform: uppercase; }
        .hero-badges .new { font-size: 10px; font-weight: 800; padding: 4px 9px; border-radius: 999px; background: #FFDF85; color: #8A4B08; letter-spacing: .4px; }
        .hero-title { font-size: 46px; line-height: 1.1; font-weight: 800; color: var(--head); margin: 18px 0 14px; letter-spacing: -.3px; }
        .hero-title .hl { color: var(--orange); text-decoration: underline wavy #FBD66A; text-decoration-thickness: 2px; text-underline-offset: 7px; }
        .hero-desc { font-size: 14.5px; line-height: 1.65; color: #9B6B3F; max-width: 470px; margin: 0 0 26px; }
        .hero-cta { display: flex; align-items: center; gap: 14px; flex-wrap: wrap; }
        .btn-primary { display: inline-flex; align-items: center; gap: 10px; padding: 15px 26px; border-radius: 999px; background: var(--orange); color: #fff; font-weight: 800; font-size: 12.5px; letter-spacing: .6px; text-transform: uppercase; box-shadow: 0 10px 22px rgba(247, 148, 29, .3); transition: background .15s, transform .15s; }
        .btn-primary:hover { background: var(--orange-dark); transform: translateY(-1px); }
        .btn-soft { display: inline-flex; align-items: center; gap: 9px; padding: 14px 22px; border-radius: 999px; background: #FFF8E4; border: 1.5px solid #F8E3BC; color: var(--head); font-weight: 700; font-size: 13px; transition: background .15s; }
        .btn-soft:hover { background: #FFEFC8; }
        .btn-soft svg { color: var(--amber); }
        .hero-stats { display: flex; gap: 44px; margin-top: 30px; padding-top: 22px; border-top: 1px solid #F3E6CC; max-width: 440px; }
        .hero-stats .num { font-size: 22px; font-weight: 800; color: var(--head); }
        .hero-stats .num.o { color: var(--amber); }
        .hero-stats .cap { font-size: 11px; color: #B98B5E; margin-top: 3px; line-height: 1.35; }

        .hero-visual { background: #fff; border: 1px solid #F8EBD0; border-radius: 26px; padding: 20px; box-shadow: 0 22px 50px rgba(247, 148, 29, .16); }
        .hv-top { display: flex; justify-content: space-between; align-items: center; gap: 10px; }
        .hv-tag { font-size: 10.5px; font-weight: 700; padding: 6px 12px; border-radius: 999px; }
        .hv-tag.w { background: #fff; border: 1px solid #F1E6D0; color: var(--head); }
        .hv-tag.y { background: #FFE9A8; color: #8A4B08; }
        .hv-img { height: 230px; margin: 26px 0 22px; border-radius: 6px; background: linear-gradient(180deg, #EFEDE8 0%, #DAD6CC 100%); }
        .hv-img img { width: 100%; height: 100%; object-fit: cover; }
        .hv-bottom { display: flex; justify-content: space-between; align-items: center; }
        .hv-name { font-size: 12px; font-weight: 700; color: var(--head); }
        .hv-dots { display: flex; gap: 6px; }
        .hv-dots i { width: 8px; height: 8px; border-radius: 50%; background: #F7E2A8; display: block; }
        .hv-dots i.on { background: var(--orange); }

        /* ===== 2. Flash Drop ===== */
        .flash-bar { display: flex; align-items: center; justify-content: space-between; gap: 20px; background: #fff; border: 1px solid #FBF0D6; border-radius: 22px; padding: 18px 24px; box-shadow: 0 8px 28px rgba(200, 140, 40, .08); }
        .flash-left { display: flex; align-items: center; gap: 14px; }
        .flash-ico { width: 44px; height: 44px; border-radius: 14px; background: #FFF1CC; border: 1px solid #F8E3BC; color: var(--orange); display: flex; align-items: center; justify-content: center; flex-shrink: 0; }
        .flash-title { display: flex; align-items: center; gap: 10px; flex-wrap: wrap; font-size: 17px; font-weight: 800; color: var(--head); }
        .flash-title .pill { font-size: 9.5px; font-weight: 800; letter-spacing: .5px; padding: 4px 9px; border-radius: 999px; background: #FFE9A8; color: #8A4B08; }
        .flash-sub { font-size: 11.5px; color: #B98B5E; margin-top: 3px; }
        .flash-right { display: flex; align-items: center; gap: 12px; }
        .flash-right .lbl { font-size: 11px; font-weight: 800; letter-spacing: .5px; color: #8A4B08; text-transform: uppercase; }
        .cd { display: flex; align-items: center; gap: 8px; }
        .cd-box { width: 52px; height: 52px; border-radius: 14px; background: #FFF1CC; border: 1px solid #F8E3BC; display: flex; flex-direction: column; align-items: center; justify-content: center; }
        .cd-box b { font-size: 18px; font-weight: 800; color: var(--head); line-height: 1.1; }
        .cd-box span { font-size: 9.5px; color: #B98B5E; }
        .cd-sep { font-weight: 800; color: #C9A06A; }

        .p-grid { display: grid; grid-template-columns: repeat(4, 1fr); gap: 20px; margin-top: 20px; }
        .p-card { background: #fff; border: 1px solid #FBF0D6; border-radius: 24px; padding: 10px 10px 18px; box-shadow: 0 8px 26px rgba(200, 140, 40, .07); transition: transform .18s, box-shadow .18s; display: flex; flex-direction: column; }
        .p-card:hover { transform: translateY(-4px); box-shadow: 0 16px 36px rgba(200, 140, 40, .14); }
        .p-media { position: relative; height: 180px; border-radius: 16px; background: #FFFBEA; display: flex; align-items: center; justify-content: center; }
        .p-media .ph { position: absolute; top: 50%; left: 50%; width: 56px; height: 56px; transform: translate(-50%, -50%); color: rgba(247, 148, 29, .3); }
        .p-media img { position: relative; z-index: 1; width: 86%; aspect-ratio: 16 / 9; object-fit: cover; }
        .p-tag { position: absolute; z-index: 2; top: 12px; left: 12px; font-size: 9.5px; font-weight: 800; letter-spacing: .4px; padding: 5px 10px; border-radius: 999px; text-transform: uppercase; }
        .p-tag.hot { background: #F9A825; color: #fff; }
        .p-tag.sale { background: #FFE9A8; color: #8A4B08; }
        .heart { position: absolute; z-index: 2; top: 10px; right: 12px; width: 26px; height: 26px; border: none; background: transparent; color: #E0892B; cursor: pointer; display: flex; align-items: center; justify-content: center; padding: 0; }
        .heart svg { fill: transparent; transition: fill .15s; }
        .heart.on svg { fill: #F7941D; }
        .p-body { padding: 14px 10px 0; display: flex; flex-direction: column; flex: 1; }
        .p-brand { font-size: 10px; font-weight: 800; letter-spacing: .7px; text-transform: uppercase; color: var(--soft); }
        .p-name { font-size: 14px; font-weight: 700; color: var(--head); margin: 5px 0 6px; line-height: 1.35; }
        .rate { display: flex; align-items: center; gap: 6px; font-size: 11.5px; color: var(--muted); }
        .stars { font-size: 13px; letter-spacing: 1px; background: linear-gradient(90deg, #F5A623 var(--rate), #E7DCC8 var(--rate)); -webkit-background-clip: text; background-clip: text; color: transparent; -webkit-text-fill-color: transparent; }
        .p-foot { display: flex; align-items: flex-end; justify-content: space-between; margin-top: auto; padding-top: 22px; }
        .price { font-size: 20px; font-weight: 800; color: var(--head); letter-spacing: -.2px; }
        .old { font-size: 11.5px; color: #B7894F; text-decoration: line-through; margin-top: 2px; }
        .cart-btn { width: 40px; height: 40px; border: none; border-radius: 13px; background: #FFEFC2; color: var(--amber); display: flex; align-items: center; justify-content: center; cursor: pointer; transition: background .15s; }
        .cart-btn:hover { background: #FFE19A; }

        /* ===== 3. LookBook ===== */
        .lb-grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 20px; }
        .lb-card { position: relative; height: 350px; border-radius: 26px; overflow: hidden; background: var(--g); display: block; }
        .lb-card img { position: absolute; inset: 0; width: 100%; height: 100%; object-fit: cover; transition: transform .5s; }
        .lb-card:hover img { transform: scale(1.04); }
        .lb-card::after { content: ""; position: absolute; inset: 0; z-index: 2; background: linear-gradient(to top, rgba(45, 22, 6, .82) 0%, rgba(45, 22, 6, .4) 32%, rgba(45, 22, 6, 0) 60%); }
        .lb-info { position: absolute; z-index: 3; left: 20px; right: 20px; bottom: 20px; color: #fff; }
        .lb-tag { display: inline-block; font-size: 9.5px; font-weight: 800; letter-spacing: .6px; text-transform: uppercase; padding: 5px 11px; border-radius: 999px; background: #FFF1CC; color: #8A4B08; }
        .lb-info h3 { font-size: 18px; font-weight: 800; margin: 10px 0 5px; letter-spacing: .1px; }
        .lb-info p { font-size: 12px; margin: 0; opacity: .9; line-height: 1.45; }

        /* ===== 4. Blog ===== */
        .b-grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 20px; }
        .b-card { background: #fff; border: 1px solid #FBF0D6; border-radius: 26px; padding: 14px 14px 20px; box-shadow: 0 8px 26px rgba(200, 140, 40, .07); transition: transform .18s, box-shadow .18s; display: flex; flex-direction: column; }
        .b-card:hover { transform: translateY(-4px); box-shadow: 0 16px 36px rgba(200, 140, 40, .14); }
        .b-img { height: 260px; border-radius: 16px; background: linear-gradient(135deg, #F6EEDF, #E8DAC2); }
        .b-img img { width: 100%; height: 100%; object-fit: cover; }
        .b-tag { position: absolute; z-index: 2; top: 10px; left: 10px; font-size: 10px; font-weight: 800; letter-spacing: .5px; text-transform: uppercase; padding: 5px 11px; border-radius: 999px; background: #fff; color: var(--head); }
        .b-body { padding: 0 6px; display: flex; flex-direction: column; flex: 1; }
        .b-meta { font-size: 11px; color: #C08A52; margin: 12px 0 10px; }
        .b-title { font-size: 14.5px; font-weight: 800; color: var(--head); line-height: 1.45; margin: 0 0 8px; }
        .b-desc { font-size: 12px; color: #B79A7E; line-height: 1.55; margin: 0 0 14px; }
        .b-read { margin-top: auto; padding-top: 14px; border-top: 1px solid #F8EEDA; font-size: 12.5px; font-weight: 700; color: var(--head); display: inline-flex; align-items: center; gap: 8px; }
        .b-card:hover .b-read { color: var(--orange); }

        /* ===== 5. Đăng ký thành viên / Voucher ===== */
        .vc-card {
            display: grid;
            grid-template-columns: 1fr 300px;
            gap: 40px;
            align-items: center;
            padding: 44px 48px;
            border-radius: 30px;
            background:
                radial-gradient(420px 220px at 100% 0%, rgba(255, 255, 255, .7), transparent 70%),
                linear-gradient(135deg, #FFF3CF 0%, #FFEDBD 50%, #FFF6DC 100%);
            border: 1px solid #FBE6B0;
            box-shadow: 0 16px 44px rgba(230, 160, 50, .12);
        }
        .vc-badge { display: inline-flex; align-items: center; gap: 8px; padding: 6px 14px 6px 10px; border-radius: 999px; background: #fff; border: 1px solid #F6E3B0; font-size: 11.5px; font-weight: 700; color: #8A4B08; }
        .vc-badge svg { color: var(--amber); }
        .vc-title { font-size: 28px; line-height: 1.2; font-weight: 800; color: var(--head); margin: 16px 0 12px; letter-spacing: .1px; }
        .vc-title .amt { display: inline-block; color: var(--orange); text-decoration: underline; text-decoration-thickness: 2px; text-underline-offset: 6px; text-decoration-color: #F9C25A; }
        .vc-desc { font-size: 13.5px; line-height: 1.65; color: #9B6B3F; max-width: 520px; margin: 0 0 22px; }
        .vc-form { display: flex; align-items: center; gap: 10px; flex-wrap: wrap; }
        .vc-form input { flex: 1; min-width: 200px; max-width: 280px; height: 44px; padding: 0 20px; border-radius: 999px; border: 1.5px solid #F6E3B0; background: #fff; font-family: inherit; font-size: 13px; color: var(--text); outline: none; transition: border-color .15s; }
        .vc-form input:focus { border-color: var(--orange); }
        .vc-form input::placeholder { color: #BFA784; }
        .vc-btn { height: 44px; padding: 0 24px; border: none; border-radius: 999px; background: #F5A00F; color: #fff; font-family: inherit; font-weight: 800; font-size: 13px; cursor: pointer; box-shadow: 0 8px 18px rgba(245, 160, 15, .28); transition: background .15s, transform .15s; }
        .vc-btn:hover { background: var(--orange-dark); transform: translateY(-1px); }

        .vc-coupon { background: #fff; border: 1px solid #F8EBD0; border-radius: 22px; padding: 22px 20px 18px; text-align: center; box-shadow: 0 14px 34px rgba(230, 160, 50, .14); }
        .vc-gift { width: 46px; height: 46px; margin: 0 auto 12px; border-radius: 50%; background: #FFEFC2; color: var(--amber); display: flex; align-items: center; justify-content: center; }
        .vc-lbl { font-size: 10.5px; font-weight: 800; letter-spacing: .7px; text-transform: uppercase; color: #8A4B08; }
        .vc-code { margin: 12px 0 12px; padding: 13px 10px; border-radius: 12px; background: #FFF9E4; border: 1px dashed #F1D690; font-size: 17px; font-weight: 800; letter-spacing: 1.2px; color: var(--head); }
        .vc-note { font-size: 11px; color: #B98B5E; }

        /* ===== 6. Cam kết dịch vụ ===== */
        .feat-row { display: grid; grid-template-columns: repeat(4, 1fr); gap: 28px; margin-top: 52px; padding: 0 6px; }
        .feat { display: flex; align-items: flex-start; gap: 14px; }
        .feat-ico { width: 44px; height: 44px; border-radius: 14px; background: #FFF4D6; border: 1px solid #F8E3BC; color: var(--amber); display: flex; align-items: center; justify-content: center; flex-shrink: 0; }
        .feat-title { font-size: 14px; font-weight: 800; color: var(--head); margin: 0 0 4px; }
        .feat-desc { font-size: 11.5px; line-height: 1.5; color: #C08A52; margin: 0; }

        /* ===== 7. Footer ===== */
        .site-footer { background: #FFF9E6; border-top: 1px solid #F6E8C0; padding: 44px 0 0; }
        .ft-grid { display: grid; grid-template-columns: 1.5fr 1fr 1fr 1.1fr; gap: 40px; }
        .ft-logo { display: inline-flex; align-items: center; gap: 8px; }
        .ft-logo-mark { width: 34px; height: 34px; border-radius: 9px; background: var(--orange); display: flex; align-items: center; justify-content: center; }
        .ft-logo-name { font-weight: 800; font-size: 15px; letter-spacing: .5px; color: var(--brown); line-height: 1; }
        .ft-logo-name b { color: var(--orange); font-weight: 800; }
        .ft-logo-sub { display: block; font-size: 6.5px; letter-spacing: 1.6px; color: var(--muted); font-weight: 600; margin-top: 3px; }
        .ft-about { font-size: 12.5px; line-height: 1.6; color: #A8620F; margin: 16px 0 20px; max-width: 290px; }
        .ft-news-lbl { font-size: 12px; font-weight: 800; letter-spacing: .3px; text-transform: uppercase; color: var(--head); margin-bottom: 10px; }
        .ft-form { display: flex; align-items: center; gap: 8px; background: #fff; border: 1px solid #F6E3B0; border-radius: 999px; padding: 4px 4px 4px 16px; max-width: 320px; }
        .ft-form input { flex: 1; min-width: 0; border: none; outline: none; background: transparent; font-family: inherit; font-size: 12px; color: var(--text); }
        .ft-form input::placeholder { color: #BFA784; }
        .ft-form button { height: 34px; padding: 0 18px; border: none; border-radius: 999px; background: #F5A00F; color: #fff; font-family: inherit; font-weight: 800; font-size: 12px; cursor: pointer; transition: background .15s; }
        .ft-form button:hover { background: var(--orange-dark); }

        .ft-col h4 { font-size: 14px; font-weight: 800; color: var(--head); margin: 0 0 16px; }
        .ft-col ul { list-style: none; margin: 0; padding: 0; display: flex; flex-direction: column; gap: 11px; }
        .ft-col li a { font-size: 12px; color: #A8620F; transition: color .15s; }
        .ft-col li a:hover { color: var(--orange); }
        .ft-contact li { display: flex; align-items: center; gap: 10px; font-size: 12px; color: #A8620F; }
        .ft-contact li svg { color: var(--orange); flex-shrink: 0; }
        .ft-contact li b { font-weight: 800; color: var(--head); }

        .ft-bottom { display: flex; align-items: center; justify-content: space-between; gap: 16px; flex-wrap: wrap; margin-top: 34px; padding: 18px 0 22px; border-top: 1px solid #F6E8C0; font-size: 11px; color: #B98B5E; }
        .ft-bottom nav { display: flex; gap: 26px; flex-wrap: wrap; }
        .ft-bottom nav a:hover { color: var(--orange); }

        /* ===== Responsive ===== */
        @media (max-width: 1100px) {
            .header-search { max-width: 220px; min-width: 150px; }
            .nav a { padding: 9px 11px; }
            .hero-card { padding: 34px 30px; gap: 28px; }
            .hero-title { font-size: 40px; }
            .p-grid { grid-template-columns: repeat(2, 1fr); }
            .vc-card { padding: 36px 32px; grid-template-columns: 1fr 270px; gap: 28px; }
            .feat-row { grid-template-columns: repeat(2, 1fr); }
            .ft-grid { grid-template-columns: 1fr 1fr; }
        }
        @media (max-width: 900px) {
            .nav, .header-search { display: none; }
            .header-actions { margin-left: auto; }
            .hero-card { grid-template-columns: 1fr; }
            .flash-bar { flex-direction: column; align-items: flex-start; }
            .lb-grid, .b-grid { grid-template-columns: 1fr; }
            .lb-card { height: 320px; }
            .sec-head { flex-direction: column; align-items: flex-start; }
            .vc-card { grid-template-columns: 1fr; }
        }
        @media (max-width: 600px) {
            .announce-text { font-size: 12px; }
            .account-btn { font-size: 0; gap: 0; padding: 5px; }
            .hero-title { font-size: 32px; }
            .hero-stats { gap: 22px; }
            .p-grid { grid-template-columns: 1fr; }
            .flash-right { flex-wrap: wrap; }
            .vc-card { padding: 28px 20px; }
            .vc-title { font-size: 23px; }
            .vc-form input { max-width: none; }
            .feat-row { grid-template-columns: 1fr; }
            .ft-grid { grid-template-columns: 1fr; gap: 30px; }
            .ft-bottom { flex-direction: column; align-items: flex-start; }
        }
    </style>
</head>
<body>

<!-- Icon giày dùng lại nhiều lần -->
<svg width="0" height="0" style="position:absolute" aria-hidden="true">
    <symbol id="ic-shoe" viewBox="0 0 24 24"><path fill="currentColor" d="M2 16.5c0-1 .6-1.8 1.5-2.1l4.2-1.4 2.3-3.2c.3-.4.9-.5 1.3-.2l1.6 1.2c.6.5 1.4.8 2.2.9l3.4.5c1.6.2 2.8 1.6 2.8 3.2V17c0 .6-.4 1-1 1H3c-.6 0-1-.4-1-1v-.5z"/></symbol>
    <symbol id="ic-arrow" viewBox="0 0 24 24"><g fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><line x1="5" y1="12" x2="19" y2="12"/><polyline points="12 5 19 12 12 19"/></g></symbol>
    <symbol id="ic-heart" viewBox="0 0 24 24"><path stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" d="M20.8 4.6a5.5 5.5 0 0 0-7.8 0L12 5.7l-1-1.1a5.5 5.5 0 0 0-7.8 7.8l1 1.1L12 21l7.8-7.5 1-1.1a5.5 5.5 0 0 0 0-7.8z"/></symbol>
    <symbol id="ic-cart" viewBox="0 0 24 24"><g fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="9" cy="21" r="1"/><circle cx="20" cy="21" r="1"/><path d="M1 1h4l2.7 13.4a2 2 0 0 0 2 1.6h9.7a2 2 0 0 0 2-1.6L23 6H6"/></g></symbol>
</svg>

<!-- ===== Thanh quảng cáo ===== -->
<div class="announce-bar">
    <span class="announce-dot"></span>
    <span class="announce-text">Chào đón Bộ Sưu Tập Mùa Thu 2025: Miễn phí gói quà phong cách Châu Á &amp; giao nhanh tận nơi</span>
</div>

<!-- ===== Header ===== -->
<header class="site-header">
    <div class="container header-inner">

        <!-- Logo -->
        <a class="logo" href="${ctx}/">
            <span class="logo-mark">
                <svg viewBox="0 0 24 24" fill="#fff" width="24" height="24"><path d="M2 16.5c0-1 .6-1.8 1.5-2.1l4.2-1.4 2.3-3.2c.3-.4.9-.5 1.3-.2l1.6 1.2c.6.5 1.4.8 2.2.9l3.4.5c1.6.2 2.8 1.6 2.8 3.2V17c0 .6-.4 1-1 1H3c-.6 0-1-.4-1-1v-.5z"/></svg>
            </span>
            <span class="logo-text">
                <span class="logo-name">POLY<b>SNEAKER</b></span>
                <span class="logo-sub">PREMIUM SNEAKER STORE</span>
            </span>
        </a>

        <!-- Menu -->
        <nav class="nav">
            <a href="${ctx}/" class="active">Trang Chủ</a>
            <a href="${ctx}/shop">
                Sản Phẩm
                <svg class="chev" viewBox="0 0 24 24" width="14" height="14" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><polyline points="6 9 12 15 18 9"/></svg>
            </a>
            <a href="#lookbook">
                <svg viewBox="0 0 24 24" width="17" height="17" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20V3H6.5A2.5 2.5 0 0 0 4 5.5v14z"/><path d="M8 7h8M8 11h8"/></svg>
                LookBook
            </a>
            <a href="#blog">
                <svg viewBox="0 0 24 24" width="17" height="17" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M2 4h6a4 4 0 0 1 4 4v13a3 3 0 0 0-3-3H2z"/><path d="M22 4h-6a4 4 0 0 0-4 4v13a3 3 0 0 1 3-3h7z"/></svg>
                Blog
            </a>
        </nav>

        <!-- Tìm kiếm -->
        <form class="header-search" action="${ctx}/shop" method="get">
            <svg viewBox="0 0 24 24" width="17" height="17" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="7"/><line x1="21" y1="21" x2="16.5" y2="16.5"/></svg>
            <input type="text" name="keyword" placeholder="Tìm đôi giày yêu thích của bạn...">
        </form>

        <!-- Yêu thích / Giỏ hàng / Tài khoản -->
        <div class="header-actions">
            <a href="#" class="icon-btn" title="Yêu thích">
                <svg viewBox="0 0 24 24" width="20" height="20" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M20.8 4.6a5.5 5.5 0 0 0-7.8 0L12 5.7l-1-1.1a5.5 5.5 0 0 0-7.8 7.8l1 1.1L12 21l7.8-7.5 1-1.1a5.5 5.5 0 0 0 0-7.8z"/></svg>
            </a>
            <a href="#" class="icon-btn" title="Giỏ hàng">
                <svg viewBox="0 0 24 24" width="20" height="20" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M6 2L3 6v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2V6l-3-4z"/><line x1="3" y1="6" x2="21" y2="6"/><path d="M16 10a4 4 0 0 1-8 0"/></svg>
                <span class="badge">3</span>
            </a>
          <a href="${ctx}/login" class="account-btn">
                <span class="avatar">
                    <svg viewBox="0 0 24 24" width="17" height="17" fill="none" stroke="#fff" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
                </span>
                Tài Khoản
            </a>
        </div>

    </div>
</header>

<main class="container">

    <!-- ===== 1. HERO ===== -->
    <section class="hero-card">
        <div class="hero-left">
            <div class="hero-badges">
                <span class="dot"></span>
                <span class="txt">Phong cách tối giản Châu Á</span>
                <span class="new">NEW 2025</span>
            </div>

            <h1 class="hero-title">
                Nâng Niu <span class="hl">Từng Bước Chân</span><br>
                Nhẹ Nhàng &amp; Tinh Tế
            </h1>

            <p class="hero-desc">
                BST Giày Sneaker phong cách Nhật – Hàn: Thoáng khí, êm ái, mang lại vẻ đẹp thanh lịch thuần khiết cho mỗi ngày năng động.
            </p>

            <div class="hero-cta">
                <a href="${ctx}/shop" class="btn-primary">
                    Khám phá bộ sưu tập
                    <svg width="16" height="16"><use href="#ic-arrow"/></svg>
                </a>
                <a href="#lookbook" class="btn-soft">
                    <svg width="17" height="17" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/></svg>
                    Xem LookBook
                </a>
            </div>

            <div class="hero-stats">
                <div>
                    <div class="num">500+</div>
                    <div class="cap">Mẫu Giày Tinh Tế</div>
                </div>
                <div>
                    <div class="num o">100%</div>
                    <div class="cap">Chính Hãng Ủy Quyền</div>
                </div>
                <div>
                    <div class="num">4.9 / 5</div>
                    <div class="cap">Hài Lòng Từ Khách<br>Hàng</div>
                </div>
            </div>
        </div>

        <div class="hero-visual">
            <div class="hv-top">
                <span class="hv-tag w">Bản Giới Hạn #Spring25</span>
                <span class="hv-tag y">Tiết kiệm 850.000đ</span>
            </div>
            <div class="hv-img media">
                <svg class="ph"><use href="#ic-shoe"/></svg>
                <img src="/static/assets/images/Banner_QuangCao_Giay.png" alt="Poly Amber Soft Runner" onerror="this.style.display='none'">
            </div>
            <div class="hv-bottom">
                <span class="hv-name">Poly Amber Soft Runner</span>
                <span class="hv-dots"><i class="on"></i><i></i><i></i></span>
            </div>
        </div>
    </section>

    <!-- ===== 2. FLASH DROP ===== -->
    <section class="sec" id="flash">
        <div class="flash-bar">
            <div class="flash-left">
                <span class="flash-ico">
                    <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="3.5"/><path d="M12 2v3M12 19v3M2 12h3M19 12h3M4.9 4.9l2.1 2.1M17 17l2.1 2.1M4.9 19.1L7 17M17 7l2.1-2.1"/></svg>
                </span>
                <div>
                    <div class="flash-title">Flash Drop Giới Hạn <span class="pill">SỐ LƯỢNG CÓ HẠN</span></div>
                    <div class="flash-sub">Ưu đãi giảm trực tiếp theo khung giờ vàng trong ngày</div>
                </div>
            </div>
            <div class="flash-right">
                <span class="lbl">Kết thúc sau:</span>
                <div class="cd">
                    <div class="cd-box"><b id="cd-h">08</b><span>Giờ</span></div>
                    <span class="cd-sep">:</span>
                    <div class="cd-box"><b id="cd-m">39</b><span>Phút</span></div>
                    <span class="cd-sep">:</span>
                    <div class="cd-box"><b id="cd-s">39</b><span>Giây</span></div>
                </div>
            </div>
        </div>

        <div class="p-grid">

            <!-- Sản phẩm 1 -->
            <article class="p-card">
                <div class="p-media">
                    <svg class="ph"><use href="#ic-shoe"/></svg>
                    <img src="/static/assets/images/air_jordan_gold.jpg" alt="Air Jordan 1 High OG" onerror="this.style.display='none'">
                    <span class="p-tag hot">Yêu thích</span>
                    <button class="heart" type="button" aria-label="Yêu thích"><svg width="18" height="18"><use href="#ic-heart"/></svg></button>
                </div>
                <div class="p-body">
                    <div class="p-brand">Nike Jordan</div>
                    <div class="p-name">Air Jordan 1 High OG "Amber Gold"</div>
                    <div class="rate"><span class="stars" style="--rate:96%">★★★★★</span> 4.8 (128)</div>
                    <div class="p-foot">
                        <div>
                            <div class="price">3.890.000₫</div>
                            <div class="old">4.990.000₫</div>
                        </div>
                        <button class="cart-btn" type="button" aria-label="Thêm vào giỏ"><svg width="19" height="19"><use href="#ic-cart"/></svg></button>
                    </div>
                </div>
            </article>

            <!-- Sản phẩm 2 -->
            <article class="p-card">
                <div class="p-media">
                    <svg class="ph"><use href="#ic-shoe"/></svg>
                    <img src="/static/assets/images/giay_sneaker_white.jpg" alt="Ultraboost Light Primeknit Beige" onerror="this.style.display='none'">
                    <span class="p-tag sale">-30% giảm</span>
                    <button class="heart" type="button" aria-label="Yêu thích"><svg width="18" height="18"><use href="#ic-heart"/></svg></button>
                </div>
                <div class="p-body">
                    <div class="p-brand">Adidas Running</div>
                    <div class="p-name">Ultraboost Light Primeknit Beige</div>
                    <div class="rate"><span class="stars" style="--rate:100%">★★★★★</span> 5.0 (94)</div>
                    <div class="p-foot">
                        <div>
                            <div class="price">2.950.000₫</div>
                            <div class="old">4.200.000₫</div>
                        </div>
                        <button class="cart-btn" type="button" aria-label="Thêm vào giỏ"><svg width="19" height="19"><use href="#ic-cart"/></svg></button>
                    </div>
                </div>
            </article>

            <!-- Sản phẩm 3 -->
            <article class="p-card">
                <div class="p-media">
                    <svg class="ph"><use href="#ic-shoe"/></svg>
                    <img src="/static/assets/images/new_balance.jpg" alt="New Balance 1906R Soft Vanilla" onerror="this.style.display='none'">
                    <span class="p-tag hot">Bán chạy</span>
                    <button class="heart" type="button" aria-label="Yêu thích"><svg width="18" height="18"><use href="#ic-heart"/></svg></button>
                </div>
                <div class="p-body">
                    <div class="p-brand">New Balance</div>
                    <div class="p-name">New Balance 1906R Soft Vanilla</div>
                    <div class="rate"><span class="stars" style="--rate:80%">★★★★★</span> 4.7 (76)</div>
                    <div class="p-foot">
                        <div>
                            <div class="price">3.450.000₫</div>
                            <div class="old">4.100.000₫</div>
                        </div>
                        <button class="cart-btn" type="button" aria-label="Thêm vào giỏ"><svg width="19" height="19"><use href="#ic-cart"/></svg></button>
                    </div>
                </div>
            </article>

            <!-- Sản phẩm 4 -->
            <article class="p-card">
                <div class="p-media">
                    <svg class="ph"><use href="#ic-shoe"/></svg>
                    <img src="/static/assets/images/dunk_low_sneaker.jpg" alt="Nike Dunk Low Sunburst Amber" onerror="this.style.display='none'">
                    <span class="p-tag sale">-25%</span>
                    <button class="heart" type="button" aria-label="Yêu thích"><svg width="18" height="18"><use href="#ic-heart"/></svg></button>
                </div>
                <div class="p-body">
                    <div class="p-brand">Nike Sportswear</div>
                    <div class="p-name">Nike Dunk Low "Sunburst Amber"</div>
                    <div class="rate"><span class="stars" style="--rate:98%">★★★★★</span> 4.9 (210)</div>
                    <div class="p-foot">
                        <div>
                            <div class="price">2.650.000₫</div>
                            <div class="old">3.500.000₫</div>
                        </div>
                        <button class="cart-btn" type="button" aria-label="Thêm vào giỏ"><svg width="19" height="19"><use href="#ic-cart"/></svg></button>
                    </div>
                </div>
            </article>

        </div>
    </section>

    <!-- ===== 3. LOOKBOOK ===== -->
    <section class="sec" id="lookbook">
        <div class="sec-head">
            <div>
                <div class="eyebrow">Phong cách thường nhật</div>
                <h2 class="sec-title">LookBook: Sắc Màu Phố Á Đông</h2>
            </div>
            <a href="#" class="pill-link">Khám Phá Tất Cả LookBook <svg width="14" height="14"><use href="#ic-arrow"/></svg></a>
        </div>

        <div class="lb-grid">
            <a href="#" class="lb-card" style="--g: linear-gradient(160deg, #D9A173, #7A4A2A);">
                <img src="/static/assets/images/LookBook_sneaker.jpg" alt="Thanh Lịch Phố Harajuku" onerror="this.style.display='none'">
                <div class="lb-info">
                    <span class="lb-tag">Tokyo Minimal</span>
                    <h3>Thanh Lịch Phố Harajuku</h3>
                    <p>Bản phối tone be &amp; trắng ngà dịu dàng cho ngày dạo phố</p>
                </div>
            </a>

            <a href="#" class="lb-card" style="--g: linear-gradient(160deg, #EBA77E, #4A3030);">
                <img src="/static/assets/images/Look_BooK_Collections_2.jpg" alt="Năng Động Buổi Sớm Seoul" onerror="this.style.display='none'">
                <div class="lb-info">
                    <span class="lb-tag">Seoul Runner</span>
                    <h3>Năng Động Buổi Sớm Seoul</h3>
                    <p>Đệm êm phản hồi lực, phong thái thoải mái không gò bó</p>
                </div>
            </a>

            <a href="#" class="lb-card" style="--g: linear-gradient(160deg, #DDA85E, #2E1B10);">
                <img src="/static/assets/images/Crown_Lookbook_-_Sneaker_Range19.jpg" alt="Cân Bằng Giữa Thể Thao và Gu Ăn Mặc" onerror="this.style.display='none'">
                <div class="lb-info">
                    <span class="lb-tag">Daily Court</span>
                    <h3>Cân Bằng Giữa Thể Thao &amp; Gu Ăn Mặc</h3>
                    <p>Bảo vệ mắt cá êm ái, kết hợp quần ống suông tinh tế</p>
                </div>
            </a>
        </div>
    </section>

    <!-- ===== 4. BLOG ===== -->
    <section class="sec" id="blog">
        <div class="sec-head">
            <div>
                <div class="eyebrow">Góc chia sẻ Sneakerhead</div>
                <h2 class="sec-title">PolySneaker Blog &amp; Đời Sống</h2>
            </div>
            <a href="#" class="text-link">Xem thêm bài viết <svg width="14" height="14"><use href="#ic-arrow"/></svg></a>
        </div>

        <div class="b-grid">

            <a href="#" class="b-card">
                <div class="b-img media">
                    <svg class="ph"><use href="#ic-shoe"/></svg>
                <img src="/static/assets/images/white_sneaker.jpg" alt="Chăm sóc giày trắng" onerror="this.style.display='none'" style="width:100%;height:100%;object-fit:cover">
                    <span class="b-tag">Mẹo hay</span>
                </div>
                <div class="b-body">
                    <div class="b-meta">Tháng 10, 2025 • 4 phút đọc</div>
                    <h3 class="b-title">Cách chăm sóc giày trắng và vàng kem luôn giữ form tinh khôi chuẩn Nhật</h3>
                    <p class="b-desc">Những bước vệ sinh nhẹ nhàng bằng bọt tự nhiên không làm xơ vải và biến màu đệm khí.</p>
                    <span class="b-read">Đọc tiếp <svg width="14" height="14"><use href="#ic-arrow"/></svg></span>
                </div>
            </a>

            <a href="#" class="b-card">
                <div class="b-img media">
                    <svg class="ph"><use href="#ic-shoe"/></svg>
                    <img src="/static/assets/images/giay_sneaker_2.jpeg" alt="Tone màu ấm áp và pastel" onerror="this.style.display='none'" style="width:100%;height:100%;object-fit:cover">
                    <span class="b-tag">Xu hướng</span>
                </div>
                <div class="b-body">
                    <div class="b-meta">Tháng 9, 2025 • 6 phút đọc</div>
                    <h3 class="b-title">Sự trở lại của tone màu Ấm Áp &amp; Pastel trong phong cách dạo phố Seoul</h3>
                    <p class="b-desc">Tại sao giới trẻ Đông Á dần chuyển từ gam màu tối sang sắc vàng kem mật ong thanh nhã.</p>
                    <span class="b-read">Đọc tiếp <svg width="14" height="14"><use href="#ic-arrow"/></svg></span>
                </div>
            </a>

            <a href="#" class="b-card">
                <div class="b-img media">
                    <svg class="ph"><use href="#ic-shoe"/></svg>
                    <img src="/static/assets/images/giay_sneaker_xanh_duong.jpg" alt="Chọn size giày chuẩn xác" onerror="this.style.display='none'" style="width:100%;height:100%;object-fit:cover">
                    <span class="b-tag">Hướng dẫn</span>
                </div>
                <div class="b-body">
                    <div class="b-meta">Tháng 9, 2025 • 3 phút đọc</div>
                    <h3 class="b-title">Bí quyết chọn size giày chuẩn xác cho bàn chân người Việt Nam</h3>
                    <p class="b-desc">Đặc điểm mu bàn chân dày và cách chọn form mũi giày không gây cấn đau ngón út.</p>
                    <span class="b-read">Đọc tiếp <svg width="14" height="14"><use href="#ic-arrow"/></svg></span>
                </div>
            </a>

        </div>
    </section>

    <!-- ===== 5. ĐĂNG KÝ THÀNH VIÊN / VOUCHER ===== -->
    <section class="sec" id="member">
        <div class="vc-card">
            <div class="vc-left">
                <span class="vc-badge">
                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="2" y="4" width="20" height="13" rx="2"/><path d="M8 21h8M12 17v4"/></svg>
                    PolySneaker Thành Viên Thân Thiết
                </span>
                <h2 class="vc-title">Đăng Ký Thành Viên, Nhận Ngay Voucher<br><span class="amt">200.000đ</span></h2>
                <p class="vc-desc">Nhận thông báo ưu tiên khi có đợt drop mẫu mới, quà tặng sinh nhật cùng chính sách tích điểm hoàn tiền nhẹ nhàng cho mỗi đơn hàng.</p>
                <form class="vc-form" id="vcForm" action="#" method="post">
                    <input type="text" name="contact" placeholder="Nhập số điện thoại hoặc email..." required>
                    <button type="submit" class="vc-btn">Nhận Voucher Ngay</button>
                </form>
            </div>

            <div class="vc-coupon">
                <div class="vc-gift">
                    <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 12 20 22 4 22 4 12"/><rect x="2" y="7" width="20" height="5"/><line x1="12" y1="22" x2="12" y2="7"/><path d="M12 7H7.5a2.5 2.5 0 0 1 0-5C11 2 12 7 12 7z"/><path d="M12 7h4.5a2.5 2.5 0 0 0 0-5C13 2 12 7 12 7z"/></svg>
                </div>
                <div class="vc-lbl">Mã voucher độc quyền</div>
                <div class="vc-code">POLYKICKS200</div>
                <div class="vc-note">Áp dụng ngay cho đơn hàng từ 1.200.000đ</div>
            </div>
        </div>
    </section>

    <!-- ===== 6. CAM KẾT DỊCH VỤ ===== -->
    <section class="feat-row">
        <div class="feat">
            <span class="feat-ico">
                <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 2l2.4 1.9 3-.2 1 2.8 2.6 1.5-.8 2.9 1.2 2.7-2.2 2 .1 3-2.9.9L14.5 22 12 20.4 9.5 22l-1.7-2.5-2.9-.9.1-3-2.2-2 1.2-2.7-.8-2.9 2.6-1.5 1-2.8 3 .2z"/><polyline points="8.5 12 11 14.5 15.5 9.5"/></svg>
            </span>
            <div>
                <h4 class="feat-title">100% Chính Hãng</h4>
                <p class="feat-desc">Kiểm định tỉ mỉ 2 lớp, cam kết chất lượng từng đường chỉ.</p>
            </div>
        </div>

        <div class="feat">
            <span class="feat-ico">
                <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="17 1 21 5 17 9"/><path d="M3 11V9a4 4 0 0 1 4-4h14"/><polyline points="7 23 3 19 7 15"/><path d="M21 13v2a4 4 0 0 1-4 4H3"/></svg>
            </span>
            <div>
                <h4 class="feat-title">Đổi Trả 30 Ngày</h4>
                <p class="feat-desc">Hỗ trợ đổi size tận nhà nhẹ nhàng, thoải mái và nhanh chóng.</p>
            </div>
        </div>

        <div class="feat">
            <span class="feat-ico">
                <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M4.5 16.5c-1.5 1.3-2 5-2 5s3.7-.5 5-2c.7-.8.7-2.1-.1-2.9a2.2 2.2 0 0 0-2.9-.1z"/><path d="M12 15l-3-3a22 22 0 0 1 2-3.9A12.9 12.9 0 0 1 22 2c0 2.7-.8 7.5-6 11a22.4 22.4 0 0 1-4 2z"/><path d="M9 12H4s.6-3 2-4c1.6-1.1 5 0 5 0"/><path d="M12 15v5s3-.6 4-2c1.1-1.6 0-5 0-5"/></svg>
            </span>
            <div>
                <h4 class="feat-title">Giao Nhanh 2 Giờ</h4>
                <p class="feat-desc">Đóng hộp carton 2 lớp chống va đập, bảo vệ form giày hoàn hảo.</p>
            </div>
        </div>

        <div class="feat">
            <span class="feat-ico">
                <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M3 18v-6a9 9 0 0 1 18 0v6"/><path d="M21 19a2 2 0 0 1-2 2h-1a2 2 0 0 1-2-2v-3a2 2 0 0 1 2-2h3zM3 19a2 2 0 0 0 2 2h1a2 2 0 0 0 2-2v-3a2 2 0 0 0-2-2H3z"/></svg>
            </span>
            <div>
                <h4 class="feat-title">Tư Vấn Tận Tâm</h4>
                <p class="feat-desc">Đội ngũ am hiểu phong cách luôn sẵn sàng tư vấn chọn size vừa vặn.</p>
            </div>
        </div>
    </section>

</main>

<!-- ===== 7. FOOTER ===== -->
<footer class="site-footer">
    <div class="container">
        <div class="ft-grid">

            <!-- Thương hiệu + đăng ký nhận tin -->
            <div class="ft-brand">
                <a class="ft-logo" href="${ctx}/">
                    <span class="ft-logo-mark">
                        <svg viewBox="0 0 24 24" fill="#fff" width="20" height="20"><path d="M2 16.5c0-1 .6-1.8 1.5-2.1l4.2-1.4 2.3-3.2c.3-.4.9-.5 1.3-.2l1.6 1.2c.6.5 1.4.8 2.2.9l3.4.5c1.6.2 2.8 1.6 2.8 3.2V17c0 .6-.4 1-1 1H3c-.6 0-1-.4-1-1v-.5z"/></svg>
                    </span>
                    <span>
                        <span class="ft-logo-name">POLY<b>SNEAKER</b></span>
                        <span class="ft-logo-sub">PREMIUM SNEAKER STORE</span>
                    </span>
                </a>
                <p class="ft-about">Cửa hàng sneaker mang tinh thần tối giản Á Đông. Nơi bạn tìm thấy sự êm ái, phong thái tự tin và nét thẩm mỹ thanh khiết trong từng đôi giày chính hãng.</p>
                <div class="ft-news-lbl">Nhận thông báo giày mới ra mắt</div>
                <form class="ft-form" id="ftForm" action="#" method="post">
                    <input type="email" name="email" placeholder="Email của bạn..." required>
                    <button type="submit">Đăng Ký</button>
                </form>
            </div>

            <!-- Sản phẩm -->
            <div class="ft-col">
                <h4>Sản Phẩm</h4>
                <ul>
                    <li><a href="${ctx}/shop?gender=nam">Giày Sneaker Nam</a></li>
                    <li><a href="${ctx}/shop?gender=nu">Giày Sneaker Nữ</a></li>
                    <li><a href="${ctx}/shop?sort=hot">Bộ Sưu Tập Giày Hot</a></li>
                    <li><a href="#lookbook">LookBook Phong Cách</a></li>
                    <li><a href="${ctx}/shop?cat=phu-kien">Dung Dịch Vệ Sinh Giày</a></li>
                </ul>
            </div>

            <!-- Chăm sóc & hỗ trợ -->
            <div class="ft-col">
                <h4>Chăm Sóc &amp; Hỗ Trợ</h4>
                <ul>
                    <li><a href="#">Tra cứu đơn hàng</a></li>
                    <li><a href="#">Chính sách đổi trả 30 ngày</a></li>
                    <li><a href="#">Bảng quy đổi size chuẩn</a></li>
                    <li><a href="#">Cam kết chính hãng 100%</a></li>
                    <li><a href="#">Câu hỏi thường gặp</a></li>
                </ul>
            </div>

            <!-- Liên hệ -->
            <div class="ft-col">
                <h4>Liên Hệ Cửa Hàng</h4>
                <ul class="ft-contact">
                    <li>
                        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 10c0 7-9 13-9 13S3 17 3 10a9 9 0 0 1 18 0z"/><circle cx="12" cy="10" r="3"/></svg>
                        120 Phố Huế, Hoàn Kiếm, Hà Nội
                    </li>
                    <li>
                        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M22 16.9v3a2 2 0 0 1-2.2 2 19.8 19.8 0 0 1-8.6-3.1 19.5 19.5 0 0 1-6-6 19.8 19.8 0 0 1-3.1-8.7A2 2 0 0 1 4.1 2h3a2 2 0 0 1 2 1.7c.1 1 .4 1.9.7 2.8a2 2 0 0 1-.5 2.1L8.1 9.9a16 16 0 0 0 6 6l1.3-1.3a2 2 0 0 1 2.1-.4c.9.3 1.8.6 2.8.7a2 2 0 0 1 1.7 2z"/></svg>
                        <b>1900 6868</b> (8:00 - 22:00)
                    </li>
                    <li>
                        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="2" y="4" width="20" height="16" rx="2"/><polyline points="22 6 12 13 2 6"/></svg>
                        support@polysneaker.vn
                    </li>
                </ul>
            </div>

        </div>

        <div class="ft-bottom">
            <span>© 2025 PolySneaker Vietnam. Tinh hoa thiết kế phong cách Á Đông.</span>
            <nav>
                <a href="#">Điều khoản sử dụng</a>
                <a href="#">Chính sách bảo mật</a>
                <a href="#">Quy chế hoạt động</a>
            </nav>
        </div>
    </div>
</footer>

<script>
    // Đồng hồ đếm ngược Flash Drop (bắt đầu 08:39:39, hết thì lặp lại)
    (function () {
        var START = 8 * 3600 + 39 * 60 + 39;
        var left = START;
        var h = document.getElementById('cd-h');
        var m = document.getElementById('cd-m');
        var s = document.getElementById('cd-s');
        function two(n) { return (n < 10 ? '0' : '') + n; }
        function render() {
            h.textContent = two(Math.floor(left / 3600));
            m.textContent = two(Math.floor((left % 3600) / 60));
            s.textContent = two(left % 60);
        }
        render();
        setInterval(function () {
            left = left > 0 ? left - 1 : START;
            render();
        }, 1000);
    })();

    // Bấm tim để thích / bỏ thích
    document.querySelectorAll('.heart').forEach(function (btn) {
        btn.addEventListener('click', function (e) {
            e.preventDefault();
            btn.classList.toggle('on');
        });
    });

    // Bấm nút giỏ hàng không bị nhảy trang (chưa có chức năng)
    document.querySelectorAll('.cart-btn').forEach(function (btn) {
        btn.addEventListener('click', function (e) { e.preventDefault(); });
    });

    // Form đăng ký voucher / nhận tin: tạm chặn submit (chưa có backend)
    ['vcForm', 'ftForm'].forEach(function (id) {
        var f = document.getElementById(id);
        if (f) f.addEventListener('submit', function (e) { e.preventDefault(); });
    });
</script>

</body>
</html>
