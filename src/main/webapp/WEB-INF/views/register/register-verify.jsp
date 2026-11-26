<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Xác thực email</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Nunito+Sans:wght@300;400;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${ctx}/static/assets/css/auth/register.css">
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
            <a href="${ctx}/">Về Trang Chủ</a>
            <span class="sep"></span>
            <span class="hotline">Hotline: 1900 8899</span>
        </div>
    </div>
</header>

<!-- ===== Nội dung ===== -->
<main class="lg-main">
    <div class="lg-card">

        <aside class="lg-left">
            <div class="lg-left-top">
                <span class="vip-pill">Thành viên mới</span>
                <span class="brand-tiny">POLYSNEAKER</span>
            </div>
            <div class="lg-visual">
                <div class="lg-photo">
                    <img src="/static/assets/images/hinh-dong-chu-welcome-dep_075934502.gif" alt="PolySneaker" onerror="this.style.display='none'">
                </div>
                <span class="lg-auth-tag">Chính hãng 100%</span>
            </div>
            <h2 class="lg-quote">“Chỉ còn một bước nữa thôi”</h2>
            <p class="lg-quote-sub">Chúng tôi đã gửi mã gồm 6 chữ số vào email của bạn. Nhập mã để hoàn tất đăng ký.</p>
        </aside>

        <section class="lg-right">
            <span class="lg-badge">Xác thực email</span>
            <h1 class="lg-title">Nhập mã xác thực</h1>
            <p class="lg-sub">Mã đã được gửi tới <b><c:out value="${maskedEmail}"/></b>. Mã có hiệu lực 10 phút.</p>

            <c:if test="${not empty error}">
                <div class="lg-error"><c:out value="${error}"/></div>
            </c:if>
            <c:if test="${not empty info}">
                <div class="lg-error" style="background:#ecfdf3;color:#067647;border-color:#abefc6;"><c:out value="${info}"/></div>
            </c:if>

            <form action="${ctx}/register/verify" method="post" autocomplete="off">
                <div class="group">
                    <label class="fld-label" for="code">Mã xác thực <em>*</em></label>
                    <div class="fld">
                        <input type="text" id="code" name="code" inputmode="numeric" pattern="[0-9]{6}"
                               maxlength="6" placeholder="------" required autofocus
                               style="letter-spacing:8px;font-size:22px;font-weight:800;text-align:center;">
                    </div>
                </div>

                <button type="submit" class="btn-login">Xác Nhận</button>
            </form>

            <div class="divider"><span>không nhận được mã?</span></div>

            <form action="${ctx}/register/resend" method="post">
                <button type="submit" class="btn-register" style="width:100%;cursor:pointer;">Gửi lại mã</button>
            </form>

            <p class="note" style="margin-top:14px;">
                Nhập nhầm email? <a href="${ctx}/register/cancel">Quay lại đăng ký</a>
            </p>
        </section>

    </div>
</main>

<!-- ===== Footer (dùng lại footer của web) ===== -->
<jsp:include page="/WEB-INF/views/layouts/footer.jsp" />

</body>
</html>