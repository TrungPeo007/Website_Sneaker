<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />

</main>
<footer class="site-footer">
    <div class="container">
        <div class="ft-grid">

            <div class="ft-brand">
                <a class="ft-logo" href="${ctx}/">
                    <span class="ft-logo-mark">
                        <img src="${ctx}/static/assets/images/logo.png" alt="PolySneaker" onerror="this.parentNode.classList.add('no-img'); this.remove();">
                        <svg class="logo-fallback" viewBox="0 0 24 24" fill="#fff" width="20" height="20"><path d="M2 16.5c0-1 .6-1.8 1.5-2.1l4.2-1.4 2.3-3.2c.3-.4.9-.5 1.3-.2l1.6 1.2c.6.5 1.4.8 2.2.9l3.4.5c1.6.2 2.8 1.6 2.8 3.2V17c0 .6-.4 1-1 1H3c-.6 0-1-.4-1-1v-.5z"/></svg>
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

            <div class="ft-col">
                <h4>Sản Phẩm</h4>
                <ul>
                    <li><a href="${ctx}/shop?gender=nam">Giày Sneaker Nam</a></li>
                    <li><a href="${ctx}/shop?gender=nu">Giày Sneaker Nữ</a></li>
                    <li><a href="${ctx}/shop?sort=hot">Bộ Sưu Tập Giày Hot</a></li>
                    <li><a href="${ctx}/#lookbook">LookBook Phong Cách</a></li>
                    <li><a href="${ctx}/shop?cat=phu-kien">Dung Dịch Vệ Sinh Giày</a></li>
                </ul>
            </div>

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

            <div class="ft-col">
                <h4>Liên Hệ Cửa Hàng</h4>
                <ul class="ft-contact">
                    <li>
                        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 10c0 7-9 13-9 13S3 17 3 10a9 9 0 0 1 18 0z"/><circle cx="12" cy="10" r="3"/></svg>
                        CVPM Quang Trung QTSC 9 
                    </li>
                    <li>
                        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M22 16.9v3a2 2 0 0 1-2.2 2 19.8 19.8 0 0 1-8.6-3.1 19.5 19.5 0 0 1-6-6 19.8 19.8 0 0 1-3.1-8.7A2 2 0 0 1 4.1 2h3a2 2 0 0 1 2 1.7c.1 1 .4 1.9.7 2.8a2 2 0 0 1-.5 2.1L8.1 9.9a16 16 0 0 0 6 6l1.3-1.3a2 2 0 0 1 2.1-.4c.9.3 1.8.6 2.8.7a2 2 0 0 1 1.7 2z"/></svg>
                        <b>1900 3256</b> (8:00 - 22:00)
                    </li>
                    <li>
                        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="2" y="4" width="20" height="16" rx="2"/><polyline points="22 6 12 13 2 6"/></svg>
                       polysneakervietnam@gmail.com
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
    // Form nhận tin ở footer: tạm chặn submit (chưa có backend)
    var ftForm = document.getElementById('ftForm');
    if (ftForm) ftForm.addEventListener('submit', function (e) { e.preventDefault(); });
</script>

</body>
</html>