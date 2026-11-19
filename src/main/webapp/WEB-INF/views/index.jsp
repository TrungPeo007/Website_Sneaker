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
                <a href="${ctx}/lookbooks" class="btn-soft">
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

    <!-- ===== 2. SẢN PHẨM (lấy từ database) ===== -->
    <section class="sec" id="flash">
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

    <!-- ===== 3. LOOKBOOK (lấy từ database, dạng giới thiệu nhẹ để kéo người xem bấm vào) ===== -->
    <c:if test="${not empty lookbooks}">
    <section class="sec" id="lookbook">
        <div class="sec-head">
            <div>
                <div class="eyebrow">Phong cách thường nhật</div>
                <h2 class="sec-title">LookBook: Sắc Màu Phố Á Đông</h2>
            </div>
            <a href="${ctx}/lookbooks" class="pill-link">Khám Phá Tất Cả LookBook <svg width="14" height="14"><use href="#ic-arrow"/></svg></a>
        </div>

        <div class="lb-grid">
            <c:forEach var="l" items="${lookbooks}" varStatus="st">

                <%-- Đường dẫn ảnh bìa: http... dùng nguyên; bắt đầu bằng / thì thêm ctx; còn lại coi là tên file --%>
                <c:set var="lsrc" value=""/>
                <c:if test="${not empty l.coverImageUrl}">
                    <c:choose>
                        <c:when test="${fn:startsWith(l.coverImageUrl, 'http')}">
                            <c:set var="lsrc" value="${l.coverImageUrl}"/>
                        </c:when>
                        <c:when test="${fn:startsWith(l.coverImageUrl, '/')}">
                            <c:set var="lsrc" value="${ctx}${l.coverImageUrl}"/>
                        </c:when>
                        <c:otherwise>
                            <c:set var="lsrc" value="${ctx}/static/assets/images/${l.coverImageUrl}"/>
                        </c:otherwise>
                    </c:choose>
                </c:if>

                <%-- Nền dự phòng (hiện khi chưa có ảnh bìa) --%>
                <c:choose>
                    <c:when test="${st.index % 3 == 0}"><c:set var="lg" value="linear-gradient(160deg, #D9A173, #7A4A2A)"/></c:when>
                    <c:when test="${st.index % 3 == 1}"><c:set var="lg" value="linear-gradient(160deg, #EBA77E, #4A3030)"/></c:when>
                    <c:otherwise><c:set var="lg" value="linear-gradient(160deg, #DDA85E, #2E1B10)"/></c:otherwise>
                </c:choose>

                <a href="${ctx}/lookbooks/${l.id}#lbdProducts" class="lb-card" style="--g: ${lg};"
                   aria-label="Xem bộ sưu tập <c:out value='${l.title}'/>">
                    <c:if test="${not empty lsrc}">
                        <img src="<c:out value='${lsrc}'/>" alt="<c:out value='${l.title}'/>"
                             loading="lazy" onerror="this.style.display='none'">
                    </c:if>
                    <div class="lb-info">
                        <span class="lb-tag">
                            <c:choose>
                                <c:when test="${l.photoCount gt 0}">${l.photoCount} ảnh phối đồ</c:when>
                                <c:otherwise>Bộ sưu tập mới</c:otherwise>
                            </c:choose>
                        </span>
                        <h3><c:out value="${l.title}"/></h3>
                        <c:if test="${not empty l.description}">
                            <p class="lb-teaser"><c:out value="${l.description}"/></p>
                        </c:if>
                        <span class="lb-go">Khám phá bộ sưu tập <svg width="14" height="14"><use href="#ic-arrow"/></svg></span>
                    </div>
                </a>
            </c:forEach>
        </div>
    </section>
    </c:if>

    <!-- ===== 3b. NGÀY GIỜ (nằm dưới LookBook) ===== -->
    <section class="sec" id="now">
        <div class="flash-bar">
            <%-- Trái: lịch nhỏ + thứ, ngày (JS điền vào; chữ trong HTML là dự phòng khi chưa có JS) --%>
            <div class="fb-date">
                <div class="fb-cal" aria-hidden="true">
                    <span class="fb-cal-m" id="nowMonth">Tháng</span>
                    <b class="fb-cal-d" id="nowDay">--</b>
                </div>
                <div class="fb-date-txt">
                    <span class="fb-eyebrow">Hôm nay</span>
                    <div class="fb-weekday" id="nowWeekday">--</div>
                    <div class="fb-full" id="nowFull"></div>
                </div>
            </div>

            <%-- Phải: đồng hồ thời gian thực kiểu lật số --%>
            <div class="fb-clock">
                <span class="fb-live"><i></i>Giờ cửa hàng · Việt Nam</span>
                <div class="fb-digits">
                    <div class="fb-unit"><b id="cd-h">--</b><span>Giờ</span></div>
                    <span class="fb-colon" aria-hidden="true"></span>
                    <div class="fb-unit"><b id="cd-m">--</b><span>Phút</span></div>
                    <span class="fb-colon" aria-hidden="true"></span>
                    <div class="fb-unit"><b id="cd-s">--</b><span>Giây</span></div>
                </div>
            </div>
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
    // Đồng hồ thời gian thực (giờ Việt Nam) + thứ, ngày, tháng, năm; cập nhật mỗi giây
    (function () {
        var h = document.getElementById('cd-h');
        var m = document.getElementById('cd-m');
        var s = document.getElementById('cd-s');
        if (!h || !m || !s) return;

        var elMonth = document.getElementById('nowMonth');
        var elDay = document.getElementById('nowDay');
        var elWeekday = document.getElementById('nowWeekday');
        var elFull = document.getElementById('nowFull');

        function two(n) { return (n < 10 ? '0' : '') + n; }

        var timeFmt = null, dateFmt = null;
        try {
            timeFmt = new Intl.DateTimeFormat('en-GB', {
                timeZone: 'Asia/Ho_Chi_Minh', hour: '2-digit', minute: '2-digit',
                second: '2-digit', hourCycle: 'h23'
            });
            dateFmt = new Intl.DateTimeFormat('vi-VN', {
                timeZone: 'Asia/Ho_Chi_Minh', weekday: 'long',
                day: '2-digit', month: '2-digit', year: 'numeric'
            });
        } catch (e) { /* trình duyệt cũ: dùng giờ của máy */ }

        var WEEKDAYS = ['Chủ Nhật', 'Thứ Hai', 'Thứ Ba', 'Thứ Tư', 'Thứ Năm', 'Thứ Sáu', 'Thứ Bảy'];
        var lastDay = '';

        function tick() {
            var now = new Date();
            var hh = now.getHours(), mm = now.getMinutes(), ss = now.getSeconds();
            if (timeFmt) {
                var parts = timeFmt.formatToParts(now);
                for (var i = 0; i < parts.length; i++) {
                    if (parts[i].type === 'hour') hh = parseInt(parts[i].value, 10);
                    else if (parts[i].type === 'minute') mm = parseInt(parts[i].value, 10);
                    else if (parts[i].type === 'second') ss = parseInt(parts[i].value, 10);
                }
            }
            h.textContent = two(hh % 24);
            m.textContent = two(mm);
            s.textContent = two(ss);

            // Ngày chỉ cần vẽ lại khi đổi ngày
            var wd = WEEKDAYS[now.getDay()], dd = two(now.getDate()),
                mo = two(now.getMonth() + 1), yy = String(now.getFullYear());
            if (dateFmt) {
                var d = dateFmt.formatToParts(now);
                for (var j = 0; j < d.length; j++) {
                    if (d[j].type === 'weekday') wd = d[j].value;
                    else if (d[j].type === 'day') dd = d[j].value;
                    else if (d[j].type === 'month') mo = d[j].value;
                    else if (d[j].type === 'year') yy = d[j].value;
                }
            }
            var key = wd + dd + mo + yy;
            if (key !== lastDay) {
                lastDay = key;
                if (elMonth) elMonth.textContent = 'Tháng ' + parseInt(mo, 10);
                if (elDay) elDay.textContent = dd;
                if (elWeekday) elWeekday.textContent = wd;
                if (elFull) elFull.textContent = 'Ngày ' + parseInt(dd, 10) + ' tháng ' + parseInt(mo, 10) + ', năm ' + yy;
            }
        }

        tick();
        setInterval(tick, 500);   // 500ms để giây nhảy đúng nhịp, không bị trễ
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
