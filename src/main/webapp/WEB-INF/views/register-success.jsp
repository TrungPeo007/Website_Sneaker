<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<!DOCTYPE html>
<html lang="vi">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Đăng ký thành công</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Nunito+Sans:wght@300;400;600;700;800&display=swap"
        rel="stylesheet">
    <link rel="stylesheet" href="${ctx}/static/assets/css/register.css">
    <style>
        /* Style riêng cho trang thành công (dùng thêm lên trên register.css) */
        .ok-wrap { max-width: 520px; margin: 0 auto; text-align: center; }
        .ok-icon {
            width: 72px; height: 72px; margin: 0 auto 18px;
            display: flex; align-items: center; justify-content: center;
            background: #e8f7ee; color: #1a9d55; border-radius: 50%;
            animation: okPop .5s ease both;
        }
        @keyframes okPop { from { transform: scale(.4); opacity: 0; } to { transform: scale(1); opacity: 1; } }
        .ok-info {
            margin: 22px 0; padding: 4px 18px; text-align: left;
            border: 1px solid #eee3d6; background: #fffaf3;
        }
        .ok-row { display: flex; justify-content: space-between; gap: 16px; padding: 12px 0; border-bottom: 1px dashed #eadfce; font-size: 14px; }
        .ok-row:last-child { border-bottom: 0; }
        .ok-row span { color: #8a7f72; }
        .ok-row b { color: #2b2118; word-break: break-all; text-align: right; }
        .ok-actions { display: flex; flex-direction: column; gap: 12px; margin-top: 6px; }
        .ok-actions .btn-login, .ok-actions .btn-register { text-decoration: none; justify-content: center; }
        .ok-warn { margin-top: 14px; font-size: 12.5px; color: #8a7f72; line-height: 1.5; }
    </style>
</head>

<body>
    <!-- ===== Header ===== -->
    <header class="lg-head">
        <div class="container lg-head-inner">
            <div class="lg-brand">
                <a class="logo" href="${ctx}/">
                    <span class="logo-mark">
                        <img src="${ctx}/static/assets/images/logo_poly_store.png" alt="PolySneaker"
                            onerror="this.parentNode.classList.add('no-img'); this.remove();">
                        <svg class="logo-fallback" viewBox="0 0 24 24" fill="#fff" width="24" height="24">
                            <path d="M2 16.5c0-1 .6-1.8 1.5-2.1l4.2-1.4 2.3-3.2c.3-.4.9-.5 1.3-.2l1.6 1.2c.6.5 1.4.8 2.2.9l3.4.5c1.6.2 2.8 1.6 2.8 3.2V17c0 .6-.4 1-1 1H3c-.6 0-1-.4-1-1v-.5z" />
                        </svg>
                    </span>
                </a>
            </div>
            <div class="lg-links">
                <a href="${ctx}/">Về Trang Chủ</a>
                <span class="sep"></span>
                <span class="hotline">Hotline: 1900 8899</span>
            </div>
        </div>
    </header>

    <!-- ===== Nội dung ===== -->
    <main class="lg-main">
        <div class="lg-card" style="grid-template-columns: 1fr; max-width: 520px;">
            <section class="lg-right">
                <div class="ok-wrap">
                    <div class="ok-icon">
                        <svg width="38" height="38" viewBox="0 0 24 24" fill="none" stroke="currentColor"
                            stroke-width="2.6" stroke-linecap="round" stroke-linejoin="round">
                            <polyline points="20 6 9 17 4 12" />
                        </svg>
                    </div>

                    <span class="lg-badge">Hoàn tất</span>
                    <h1 class="lg-title">Đăng ký thành công!</h1>
                    <p class="lg-sub">Chào mừng bạn đến với cộng đồng PolySneaker. Tài khoản của bạn đã sẵn sàng.</p>

                    <div class="ok-info">
                        <div class="ok-row"><span>Tên đăng nhập</span><b><c:out value="${username}" /></b></div>
                        <div class="ok-row"><span>Email</span><b><c:out value="${email}" /></b></div>
                    </div>

                    <div class="ok-actions">
                        <a class="btn-login" href="${ctx}/register/export">
                            Tải thông tin tài khoản (.xlsx)
                        </a>
                        <!-- /register/done xóa thông tin khỏi session rồi chuyển sang trang đăng nhập -->
                        <a class="btn-register" href="${ctx}/register/done">Đăng nhập ngay</a>
                    </div>

                    <p class="ok-warn">File Excel có chứa mật khẩu của bạn. Hãy cất giữ cẩn thận và không chia sẻ cho người khác.</p>
                </div>
            </section>
        </div>
    </main>

    <!-- ===== Footer ===== -->
    <footer class="lg-bottom">
        <div class="container lg-bottom-inner">
            <span>© 2025 PolySneaker. Đẳng cấp tinh gọn, cam kết 100% chính hãng.</span>
        </div>
    </footer>

</body>

</html>
