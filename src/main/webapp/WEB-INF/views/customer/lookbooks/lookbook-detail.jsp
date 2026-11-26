<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<%@ taglib uri="jakarta.tags.functions" prefix="fn" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<c:set var="pageTitle" scope="request"><c:out value="${lookbook.title}" /> - Bộ sưu tập - PolySneaker</c:set>
<c:set var="activeMenu" value="lookbook" scope="request" />
<jsp:include page="/WEB-INF/views/layouts/header.jsp" />

<style>
    .lbd {
        --o: #F7941D;
        --od: #E8830C;
        --head: #6E3A12;
        --brown: #5C4430;
        --muted: #9A8C7E;
        --ease: cubic-bezier(.22, .8, .3, 1);
        color: var(--brown);
    }

    .lbd *, .lbd *::before, .lbd *::after { box-sizing: border-box; border-radius: 0 !important; }

    .lbd-crumb { display: flex; flex-wrap: wrap; align-items: center; gap: 6px; margin: 0 0 14px; font-size: 13px; color: var(--muted); }
    .lbd-crumb a { color: var(--muted); }
    .lbd-crumb a:hover { color: var(--od); }
    .lbd-crumb b { color: var(--head); font-weight: 700; }

    .lbd-hero { margin: 8px 0 34px; max-width: 760px; }
    .lbd-hero p { margin: 12px 0 0; font-size: 15px; line-height: 1.75; color: #8B6B4A; }

    .lbd-tags { display: flex; flex-wrap: wrap; gap: 10px; margin-top: 18px; }
    .lbd-tag {
        display: inline-flex; align-items: center; gap: 8px;
        padding: 7px 14px; border-left: 3px solid var(--o);
        background: #FFF3DD; color: #D97706;
        font-size: 12px; font-weight: 800; letter-spacing: .6px; text-transform: uppercase;
        transition: background .2s, color .2s;
    }
    a.lbd-tag:hover { background: var(--o); color: #fff; }

    /* ----- Tiêu đề từng phần ----- */
    .lbd-head { display: flex; align-items: flex-end; justify-content: space-between; gap: 16px; margin: 0 0 24px; }
    .lbd-head h2 { position: relative; margin: 0; padding-bottom: 12px; font-size: 26px; font-weight: 800; letter-spacing: -.2px; color: var(--head); }
    .lbd-head h2::after { content: ""; position: absolute; left: 0; bottom: 0; width: 48px; height: 3px; background: var(--o); transition: width .5s var(--ease); }
    .lbd-head:hover h2::after { width: 96px; }
    .lbd-head span { font-size: 13px; font-weight: 700; color: var(--muted); }

    .lbd-block { margin-bottom: 64px; scroll-margin-top: 96px; }   /* nhảy tới đúng phần sản phẩm, không bị header che */
    html { scroll-behavior: smooth; }

    /* vừa nhảy tới phần sản phẩm (từ nút "Xem" ở trang danh sách) thì tiêu đề nháy nhẹ */
    #lbdProducts:target .lbd-head h2::after { width: 120px; background: var(--od); }
    #lbdProducts:target .lbd-head h2 { animation: lbdPulse 1.2s ease; }
    @keyframes lbdPulse { 0% { transform: translateX(-14px); opacity: 0; } 100% { transform: none; opacity: 1; } }

    /* ----- Lưới sản phẩm thuộc bộ sưu tập ----- */
    .lbp-grid { display: grid; grid-template-columns: repeat(4, minmax(0, 1fr)); gap: 26px 22px; }

    .lbp {
        position: relative; display: flex; flex-direction: column;
        background: #fff; border: 1px solid #F3E6CB;
        transition: transform .35s var(--ease), box-shadow .35s var(--ease), border-color .3s;
    }

    .lbp:hover { transform: translateY(-6px); border-color: var(--o); box-shadow: 0 22px 40px -16px rgba(110, 58, 18, .3); }

    .lbp-img { position: relative; display: block; aspect-ratio: 1 / 1; overflow: hidden; background: linear-gradient(135deg, #F6EEDF, #E8DAC2); }
    .lbp-img img { position: absolute; inset: 0; width: 100%; height: 100%; object-fit: cover; transition: transform .9s var(--ease); }
    .lbp:hover .lbp-img img { transform: scale(1.08); }

    .lbp-badges { position: absolute; top: 0; left: 0; z-index: 2; display: flex; flex-direction: column; align-items: flex-start; gap: 4px; }
    .lbp-badge { padding: 5px 10px; background: var(--head); color: #fff; font-size: 10.5px; font-weight: 800; letter-spacing: .8px; text-transform: uppercase; }
    .lbp-sale { padding: 5px 10px; background: #E5484D; color: #fff; font-size: 11.5px; font-weight: 800; }

    /* thanh "Xem sản phẩm" trượt lên khi hover */
    .lbp-cta {
        position: absolute; left: 0; right: 0; bottom: 0; z-index: 2;
        display: flex; align-items: center; justify-content: space-between;
        padding: 13px 16px; background: var(--o); color: #fff;
        font-size: 12px; font-weight: 800; letter-spacing: 1px; text-transform: uppercase;
        transform: translateY(101%); transition: transform .45s var(--ease);
    }
    .lbp:hover .lbp-cta { transform: translateY(0); }

    .lbp-body { display: grid; gap: 8px; padding: 16px 16px 18px; }
    .lbp-name {
        font-size: 14.5px; font-weight: 800; line-height: 1.4; color: var(--head);
        display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical; overflow: hidden;
        min-height: 2.8em;
    }
    .lbp-name a:hover { color: var(--od); }
    .lbp-price { display: flex; align-items: baseline; flex-wrap: wrap; gap: 8px; }
    .lbp-price b { font-size: 16px; font-weight: 800; color: var(--od); }
    .lbp-price s { font-size: 12.5px; color: var(--muted); }

    /* ----- Ảnh phối đồ (kiểu tạp chí) ----- */
    .lbd-grid { columns: 3 280px; column-gap: 22px; }

    .lbd-item {
        break-inside: avoid; margin: 0 0 22px; overflow: hidden;
        background: #fff; border: 1px solid #F3E6CB;
        transition: transform .35s var(--ease), box-shadow .35s var(--ease), border-color .3s;
    }
    .lbd-item:hover { transform: translateY(-4px); border-color: var(--o); box-shadow: 0 20px 40px -16px rgba(110, 58, 18, .3); }

    .lbd-pic { position: relative; display: block; width: 100%; padding: 0; border: none; background: #F7F3EA; cursor: zoom-in; overflow: hidden; }
    .lbd-pic img { display: block; width: 100%; height: auto; transition: transform .9s var(--ease); }
    .lbd-item:hover .lbd-pic img { transform: scale(1.05); }

    .lbd-cap { padding: 14px 18px 4px; font-size: 14px; line-height: 1.6; color: var(--brown); }

    .lbd-prod {
        display: grid; gap: 3px; margin: 12px 14px 14px; padding: 12px 14px;
        background: #FFF6E6; border-left: 3px solid var(--o);
        transition: background .2s, padding .3s var(--ease);
    }
    .lbd-item .lbd-cap + .lbd-prod { margin-top: 10px; }
    .lbd-prod:hover { background: #FFEBC9; padding-left: 20px; }
    .lbd-prod-name { font-size: 13.5px; font-weight: 800; color: var(--head); line-height: 1.4; }
    .lbd-prod-price { font-size: 14px; font-weight: 800; color: var(--od); }
    .lbd-prod-price s { margin-left: 6px; font-size: 12px; font-weight: 600; color: var(--muted); }
    .lbd-prod-go { font-size: 12px; font-weight: 700; color: var(--head); }
    .lbd-prod:hover .lbd-prod-go { color: var(--od); }

    .lbd-empty { padding: 40px 16px; text-align: center; color: var(--muted); border: 1.5px dashed #F2D9A8; background: #FFFDF8; }

    /* ----- Bộ sưu tập khác ----- */
    .lbd-more { margin-top: 20px; }
    .lbd-more h2 { margin: 0 0 14px; font-size: 20px; font-weight: 800; color: var(--head); }
    .lbd-chips { display: flex; flex-wrap: wrap; gap: 10px; }
    .lbd-chip { position: relative; overflow: hidden; padding: 11px 20px; border: 1.5px solid #F2D9A8; background: #fff; font-size: 13px; font-weight: 800; letter-spacing: .5px; text-transform: uppercase; color: var(--head); transition: color .3s, border-color .3s; }
    .lbd-chip::before { content: ""; position: absolute; inset: 0; z-index: 0; background: var(--o); transform: scaleX(0); transform-origin: left; transition: transform .45s var(--ease); }
    .lbd-chip span { position: relative; z-index: 1; }
    .lbd-chip:hover { color: #fff; border-color: var(--o); }
    .lbd-chip:hover::before { transform: scaleX(1); }

    /* ----- Xem ảnh lớn ----- */
    .lbd-box { position: fixed; inset: 0; z-index: 200; display: none; align-items: center; justify-content: center; padding: 24px; background: rgba(24, 14, 6, .9); }
    .lbd-box.open { display: flex; animation: lbdFade .25s ease; }
    .lbd-box figure { margin: 0; max-width: min(1000px, 100%); text-align: center; }
    .lbd-box img { display: block; max-width: 100%; max-height: 80vh; margin: 0 auto; background: #fff; }
    .lbd-box figcaption { margin-top: 12px; font-size: 14px; line-height: 1.6; color: #F3E4CE; }
    .lbd-x, .lbd-nav { position: absolute; border: none; background: rgba(255, 255, 255, .16); color: #fff; cursor: pointer; display: flex; align-items: center; justify-content: center; transition: background .2s; }
    .lbd-x:hover, .lbd-nav:hover { background: var(--o); }
    .lbd-x { top: 18px; right: 18px; width: 44px; height: 44px; font-size: 24px; }
    .lbd-nav { top: 50%; width: 48px; height: 48px; margin-top: -24px; font-size: 26px; }
    .lbd-nav.prev { left: 18px; }
    .lbd-nav.next { right: 18px; }

    @keyframes lbdFade { from { opacity: 0; } to { opacity: 1; } }

    /* ----- Hiệu ứng xuất hiện khi cuộn tới (chỉ bật khi JS chạy được) ----- */
    .lbd.is-js [data-reveal] {
        opacity: 0; transform: translate3d(0, 28px, 0);
        transition: opacity .8s ease var(--d, 0s), transform .9s var(--ease) var(--d, 0s), box-shadow .35s var(--ease), border-color .3s;
    }
    .lbd.is-js [data-reveal].is-in { opacity: 1; transform: none; }
    .lbd.is-js [data-reveal].is-in:hover { transform: translateY(-6px); }

    @media (prefers-reduced-motion: reduce) {
        .lbd-item, .lbd-pic img, .lbp, .lbp-img img, .lbp-cta, .lbd-chip::before { transition: none !important; }
        .lbd-box.open { animation: none; }
    }

    @media (max-width: 1100px) { .lbp-grid { grid-template-columns: repeat(3, minmax(0, 1fr)); } }
    @media (max-width: 800px) { .lbp-grid { grid-template-columns: repeat(2, minmax(0, 1fr)); gap: 18px 14px; } .lbd-head h2 { font-size: 22px; } }
    @media (max-width: 420px) { .lbp-body { padding: 12px; } .lbp-name { font-size: 13.5px; } }
</style>

<section class="sec lbd" id="lbdRoot">

    <nav class="lbd-crumb" aria-label="Điều hướng">
        <a href="${ctx}/">Trang chủ</a><span>/</span>
        <a href="${ctx}/lookbooks">Bộ sưu tập</a><span>/</span>
        <b><c:out value="${lookbook.title}" /></b>
    </nav>

    <header class="lbd-hero">
        <div class="eyebrow">Bộ sưu tập</div>
        <h1 class="sec-title"><c:out value="${lookbook.title}" /></h1>
        <c:if test="${not empty lookbook.description}">
            <p><c:out value="${lookbook.description}" /></p>
        </c:if>
        <div class="lbd-tags">
            <c:if test="${not empty products}">
                <a class="lbd-tag" href="#lbdProducts">${fn:length(products)} sản phẩm</a>
            </c:if>
            <c:if test="${lookbook.photoCount gt 0}">
                <a class="lbd-tag" href="#lbdPhotos">${lookbook.photoCount} ảnh</a>
            </c:if>
        </div>
    </header>

    <%-- ===== SẢN PHẨM THUỘC BỘ SƯU TẬP ===== --%>
    <c:if test="${not empty products}">
        <div class="lbd-block" id="lbdProducts">
            <div class="lbd-head">
                <h2>Sản phẩm trong bộ sưu tập</h2>
                <span>${fn:length(products)} sản phẩm</span>
            </div>

            <div class="lbp-grid">
                <c:forEach var="pr" items="${products}" varStatus="ps">
                    <c:set var="prc" value="" />
                    <c:if test="${not empty pr.mainImageUrl}">
                        <c:choose>
                            <c:when test="${fn:startsWith(pr.mainImageUrl, 'http')}">
                                <c:set var="prc" value="${pr.mainImageUrl}" />
                            </c:when>
                            <c:when test="${fn:startsWith(pr.mainImageUrl, '/')}">
                                <c:set var="prc" value="${ctx}${pr.mainImageUrl}" />
                            </c:when>
                            <c:otherwise>
                                <c:set var="prc" value="${ctx}/static/assets/images/${pr.mainImageUrl}" />
                            </c:otherwise>
                        </c:choose>
                    </c:if>

                    <article class="lbp" data-reveal style="--d: ${(ps.index % 4) * 0.08}s">
                        <a class="lbp-img" href="${ctx}/products/${pr.productId}" aria-label="Xem <c:out value='${pr.productName}'/>">
                            <c:if test="${not empty prc}">
                                <img src="<c:out value='${prc}'/>" alt="<c:out value='${pr.productName}'/>"
                                     loading="lazy" onerror="this.style.display='none'">
                            </c:if>
                            <span class="lbp-badges">
                                <c:if test="${not empty pr.badge}"><span class="lbp-badge"><c:out value="${pr.badge}" /></span></c:if>
                                <c:if test="${pr.discountPercent gt 0}"><span class="lbp-sale">-${pr.discountPercent}%</span></c:if>
                            </span>
                            <span class="lbp-cta">Xem sản phẩm <span aria-hidden="true">→</span></span>
                        </a>
                        <div class="lbp-body">
                            <h3 class="lbp-name"><a href="${ctx}/products/${pr.productId}"><c:out value="${pr.productName}" /></a></h3>
                            <div class="lbp-price">
                                <b><fmt:formatNumber value="${pr.salePrice}" type="number" groupingUsed="true" />₫</b>
                                <c:if test="${pr.originalPrice gt pr.salePrice}">
                                    <s><fmt:formatNumber value="${pr.originalPrice}" type="number" groupingUsed="true" />₫</s>
                                </c:if>
                            </div>
                        </div>
                    </article>
                </c:forEach>
            </div>
        </div>
    </c:if>

    <%-- ===== ẢNH PHỐI ĐỒ ===== --%>
    <div class="lbd-block" id="lbdPhotos">
        <c:if test="${not empty photos}">
            <div class="lbd-head">
                <h2>Ảnh phối đồ</h2>
                <span>${fn:length(photos)} ảnh</span>
            </div>
        </c:if>

        <c:choose>
            <c:when test="${not empty photos}">
                <div class="lbd-grid">
                    <c:forEach var="ph" items="${photos}" varStatus="st">
                        <c:choose>
                            <c:when test="${fn:startsWith(ph.imageUrl, 'http')}">
                                <c:set var="psrc" value="${ph.imageUrl}" />
                            </c:when>
                            <c:when test="${fn:startsWith(ph.imageUrl, '/')}">
                                <c:set var="psrc" value="${ctx}${ph.imageUrl}" />
                            </c:when>
                            <c:otherwise>
                                <c:set var="psrc" value="${ctx}/static/assets/images/${ph.imageUrl}" />
                            </c:otherwise>
                        </c:choose>

                        <figure class="lbd-item" data-reveal>
                            <button type="button" class="lbd-pic" data-i="${st.index}"
                                    data-src="<c:out value='${psrc}'/>" data-cap="<c:out value='${ph.caption}'/>"
                                    aria-label="Xem ảnh ${st.index + 1}">
                                <img src="<c:out value='${psrc}'/>" alt="<c:out value='${ph.caption}'/>"
                                     loading="lazy" onerror="this.closest('.lbd-item').style.display='none'">
                            </button>

                            <c:if test="${not empty ph.caption}">
                                <figcaption class="lbd-cap"><c:out value="${ph.caption}" /></figcaption>
                            </c:if>

                            <c:if test="${ph.hasProduct}">
                                <a class="lbd-prod" href="${ctx}/products/${ph.productId}">
                                    <span class="lbd-prod-name"><c:out value="${ph.productName}" /></span>
                                    <span class="lbd-prod-price">
                                        <fmt:formatNumber value="${ph.salePrice}" type="number" groupingUsed="true" />₫
                                        <c:if test="${ph.originalPrice gt ph.salePrice}">
                                            <s><fmt:formatNumber value="${ph.originalPrice}" type="number" groupingUsed="true" />₫</s>
                                        </c:if>
                                    </span>
                                    <span class="lbd-prod-go">Xem sản phẩm →</span>
                                </a>
                            </c:if>
                        </figure>
                    </c:forEach>
                </div>
            </c:when>
            <c:when test="${empty products}">
                <p class="lbd-empty">Bộ sưu tập này chưa có ảnh hay sản phẩm nào.</p>
            </c:when>
        </c:choose>
    </div>

    <c:if test="${not empty others}">
        <div class="lbd-more">
            <h2>Bộ sưu tập khác</h2>
            <div class="lbd-chips">
                <c:forEach var="o" items="${others}">
                    <a class="lbd-chip" href="${ctx}/lookbooks/${o.id}"><span><c:out value="${o.title}" /></span></a>
                </c:forEach>
            </div>
        </div>
    </c:if>
</section>

<%-- Xem ảnh lớn --%>
<div class="lbd-box" id="lbdBox" role="dialog" aria-modal="true" aria-label="Xem ảnh">
    <button type="button" class="lbd-x" id="lbdClose" aria-label="Đóng">×</button>
    <button type="button" class="lbd-nav prev" id="lbdPrev" aria-label="Ảnh trước">‹</button>
    <figure>
        <img id="lbdImg" alt="">
        <figcaption id="lbdCap"></figcaption>
    </figure>
    <button type="button" class="lbd-nav next" id="lbdNext" aria-label="Ảnh sau">›</button>
</div>

<script>
    (function () {
        /* 1. Hiệu ứng xuất hiện khi cuộn tới */
        var root = document.getElementById('lbdRoot');
        var reduce = window.matchMedia && window.matchMedia('(prefers-reduced-motion: reduce)').matches;
        if (root && !reduce && 'IntersectionObserver' in window) {
            var items = root.querySelectorAll('[data-reveal]');
            if (items.length) {
                root.classList.add('is-js');
                var io = new IntersectionObserver(function (entries) {
                    entries.forEach(function (e) {
                        if (e.isIntersecting) { e.target.classList.add('is-in'); io.unobserve(e.target); }
                    });
                }, { threshold: 0.12, rootMargin: '0px 0px -30px 0px' });
                items.forEach(function (el) { io.observe(el); });
            }
        }

        /* 2. Xem ảnh lớn */
        var pics = Array.prototype.slice.call(document.querySelectorAll('.lbd-pic'));
        var box = document.getElementById('lbdBox');
        if (!pics.length || !box) return;

        var img = document.getElementById('lbdImg');
        var cap = document.getElementById('lbdCap');
        var prev = document.getElementById('lbdPrev');
        var next = document.getElementById('lbdNext');
        var idx = 0;

        function show(i) {
            idx = (i + pics.length) % pics.length;
            img.src = pics[idx].getAttribute('data-src');
            cap.textContent = pics[idx].getAttribute('data-cap') || '';
        }

        function open(i) {
            show(i);
            box.classList.add('open');
            document.body.style.overflow = 'hidden';
        }

        function close() {
            box.classList.remove('open');
            document.body.style.overflow = '';
        }

        pics.forEach(function (p, i) { p.addEventListener('click', function () { open(i); }); });
        document.getElementById('lbdClose').addEventListener('click', close);
        prev.addEventListener('click', function () { show(idx - 1); });
        next.addEventListener('click', function () { show(idx + 1); });
        box.addEventListener('click', function (e) { if (e.target === box) close(); });

        if (pics.length < 2) { prev.style.display = 'none'; next.style.display = 'none'; }

        document.addEventListener('keydown', function (e) {
            if (!box.classList.contains('open')) return;
            if (e.key === 'Escape') close();
            else if (e.key === 'ArrowLeft') show(idx - 1);
            else if (e.key === 'ArrowRight') show(idx + 1);
        });
    })();
</script>

<jsp:include page="/WEB-INF/views/layouts/footer.jsp" />
