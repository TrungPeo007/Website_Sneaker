<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<%@ taglib uri="jakarta.tags.functions" prefix="fn" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<c:set var="pageTitle" value="Trang chủ" scope="request"/>
<c:set var="activeMenu" value="home" scope="request"/>
<jsp:include page="/WEB-INF/views/layouts/header.jsp"/>

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
                <img src="${ctx}/static/assets/images/Banner_QuangCao_Giay.png" alt="Poly Amber Soft Runner" onerror="this.style.display='none'">
            </div>
            <div class="hv-bottom">
                <span class="hv-name">Poly Amber Soft Runner</span>
                <span class="hv-dots"><i class="on"></i><i></i><i></i></span>
            </div>
        </div>
    </section>

    <!-- ===== 2. FLASH DROP (sản phẩm lấy từ database) ===== -->
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
            <c:forEach var="p" items="${products}">
                <%-- Bấm vào thẻ (hoặc tên sản phẩm) để xem chi tiết: /products/{id} --%>
                <article class="p-card" data-href="${ctx}/products/${p.id}" style="cursor:pointer">
                    <div class="p-media">
                        <svg class="ph"><use href="#ic-shoe"/></svg>

                        <c:if test="${not empty p.mainImageUrl}">
                            <%-- Nếu DB lưu sẵn đường dẫn (http...) thì dùng nguyên; bắt đầu bằng / thì thêm ctx; còn lại coi là tên file --%>
                            <c:choose>
                                <c:when test="${fn:startsWith(p.mainImageUrl, 'http')}">
                                    <c:set var="img" value="${p.mainImageUrl}"/>
                                </c:when>
                                <c:when test="${fn:startsWith(p.mainImageUrl, '/')}">
                                    <c:set var="img" value="${ctx}${p.mainImageUrl}"/>
                                </c:when>
                                <c:otherwise>
                                    <c:set var="img" value="${ctx}/static/assets/images/${p.mainImageUrl}"/>
                                </c:otherwise>
                            </c:choose>
                            <img src="<c:out value='${img}'/>" alt="<c:out value='${p.name}'/>" onerror="this.style.display='none'">
                        </c:if>

                        <c:choose>
                            <c:when test="${not empty p.badge}">
                                <span class="p-tag hot"><c:out value="${p.badge}"/></span>
                            </c:when>
                            <c:when test="${not empty p.discountPercent and p.discountPercent gt 0}">
                                <span class="p-tag sale">-${p.discountPercent}%</span>
                            </c:when>
                        </c:choose>

                        <button class="heart" type="button" aria-label="Yêu thích"><svg width="18" height="18"><use href="#ic-heart"/></svg></button>
                    </div>
                    <div class="p-body">
                        <div class="p-brand"><c:out value="${p.category.name}"/></div>
                        <div class="p-name"><a href="${ctx}/products/${p.id}" style="color:inherit;text-decoration:none"><c:out value="${p.name}"/></a></div>
                        <div class="rate">
                            <span class="stars" style="--rate:${p.avgRating * 20}%">★★★★★</span>
                            <fmt:formatNumber value="${p.avgRating}" minFractionDigits="1" maxFractionDigits="1"/> (${p.reviewCount})
                        </div>
                        <div class="p-foot">
                            <div class="price"><fmt:formatNumber value="${p.salePrice}" type="number" groupingUsed="true"/>₫</div>
                            <c:if test="${p.originalPrice gt p.salePrice}">
                                <div class="old"><fmt:formatNumber value="${p.originalPrice}" type="number" groupingUsed="true"/>₫</div>
                            </c:if>
                        </div>
                    </div>
                </article>
            </c:forEach>

            <c:if test="${empty products}">
                <div class="p-empty">Chưa có sản phẩm nào để hiển thị.</div>
            </c:if>
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
                <img src="${ctx}/static/assets/images/LookBook_sneaker.jpg" alt="Thanh Lịch Phố Harajuku" onerror="this.style.display='none'">
                <div class="lb-info">
                    <span class="lb-tag">Tokyo Minimal</span>
                    <h3>Thanh Lịch Phố Harajuku</h3>
                    <p>Bản phối tone be &amp; trắng ngà dịu dàng cho ngày dạo phố</p>
                </div>
            </a>

            <a href="#" class="lb-card" style="--g: linear-gradient(160deg, #EBA77E, #4A3030);">
                <img src="${ctx}/static/assets/images/Look_BooK_Collections_2.jpg" alt="Năng Động Buổi Sớm Seoul" onerror="this.style.display='none'">
                <div class="lb-info">
                    <span class="lb-tag">Seoul Runner</span>
                    <h3>Năng Động Buổi Sớm Seoul</h3>
                    <p>Đệm êm phản hồi lực, phong thái thoải mái không gò bó</p>
                </div>
            </a>

            <a href="#" class="lb-card" style="--g: linear-gradient(160deg, #DDA85E, #2E1B10);">
                <img src="${ctx}/static/assets/images/Crown_Lookbook_-_Sneaker_Range19.jpg" alt="Cân Bằng Giữa Thể Thao và Gu Ăn Mặc" onerror="this.style.display='none'">
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
                    <img src="${ctx}/static/assets/images/white_sneaker.jpg" alt="Chăm sóc giày trắng" onerror="this.style.display='none'" style="width:100%;height:100%;object-fit:cover">
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
                    <img src="${ctx}/static/assets/images/giay_sneaker_2.jpeg" alt="Tone màu ấm áp và pastel" onerror="this.style.display='none'" style="width:100%;height:100%;object-fit:cover">
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
                    <img src="${ctx}/static/assets/images/giay_sneaker_xanh_duong.jpg" alt="Chọn size giày chuẩn xác" onerror="this.style.display='none'" style="width:100%;height:100%;object-fit:cover">
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

    // Bấm vào thẻ sản phẩm (trừ nút tim) -> sang trang chi tiết
    document.querySelectorAll('.p-card[data-href]').forEach(function (card) {
        card.addEventListener('click', function (e) {
            if (e.target.closest('button, a')) return;
            window.location.href = card.getAttribute('data-href');
        });
    });

    // Form đăng ký voucher: tạm chặn submit (chưa có backend)
    var vcForm = document.getElementById('vcForm');
    if (vcForm) vcForm.addEventListener('submit', function (e) { e.preventDefault(); });
</script>

<script src="${ctx}/static/assets/js/product-card.js"></script>

<jsp:include page="/WEB-INF/views/layouts/footer.jsp"/>
