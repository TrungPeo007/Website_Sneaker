<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<%@ taglib uri="jakarta.tags.functions" prefix="fn" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<c:set var="pageTitle" value="Bộ sưu tập" scope="request" />
<c:set var="activeMenu" value="lookbook" scope="request" />
<jsp:include page="/WEB-INF/views/layouts/header.jsp" />

<style>
    .lk {
        --o: #F7941D;
        --od: #E8830C;
        --am: #D97706;
        --head: #6E3A12;
        --brown: #5C4430;
        --muted: #9A8C7E;
        --ease: cubic-bezier(.22, .8, .3, 1);
        --slant: 9%;                 /* độ xéo của ảnh */
        color: var(--brown);
        overflow-x: clip;
    }

    .lk *, .lk *::before, .lk *::after { box-sizing: border-box; border-radius: 0 !important; }

    /* ----- Thanh tiến độ cuộn ----- */
    .lk-progress {
        position: fixed; top: 0; left: 0; z-index: 90;
        width: 100%; height: 3px; background: var(--o);
        transform: scaleX(0); transform-origin: left; pointer-events: none;
    }

    /* ----- Đầu trang ----- */
    .lk-hero { max-width: 700px; margin-bottom: 40px; }
    .lk-hero p { margin: 14px 0 0; font-size: 15.5px; line-height: 1.75; color: #8B6B4A; }

    .lk-rule { display: block; width: 72px; height: 3px; margin-top: 22px; background: var(--o); transform-origin: left; }

    .lk-total {
        display: inline-flex; align-items: center; margin-top: 20px;
        padding: 7px 18px 7px 14px; border-left: 3px solid var(--o);
        background: #FFF3DD; color: var(--am);
        font-size: 12.5px; font-weight: 800; letter-spacing: .6px; text-transform: uppercase;
        transform: skewX(-12deg);
    }

    /* ----- Dải chữ chạy (marquee) nằm xéo ----- */
    .lk-marq-wrap { overflow: hidden; padding: 34px 0; margin: 0 0 60px; }
    .lk-marq {
        display: flex; overflow: hidden; width: 104%; margin-left: -2%;
        background: var(--o); color: #fff;
        transform: rotate(-1.6deg);
        box-shadow: 0 18px 34px -14px rgba(247, 148, 29, .55);
    }
    .lk-marq-track { display: flex; flex: none; min-width: 100%; animation: lkMarq 30s linear infinite; }
    .lk-marq:hover .lk-marq-track { animation-play-state: paused; }
    .lk-marq-track span {
        flex: none; padding: 15px 26px;
        font-size: 15px; font-weight: 800; letter-spacing: 3px; text-transform: uppercase; white-space: nowrap;
    }
    .lk-marq-track span:nth-child(even) { color: transparent; -webkit-text-stroke: 1.2px #fff; }
    .lk-marq-track span i { font-style: normal; opacity: .6; padding-left: 26px; }

    @keyframes lkMarq { from { transform: translateX(0); } to { transform: translateX(-100%); } }

    /* ----- Danh sách ----- */
    .lk-list { display: grid; gap: 130px; padding-bottom: 30px; }

    .lk-row {
        --rot: -2.2deg;
        --bx: 22px;
        --by: 22px;
        position: relative;
        display: grid;
        grid-template-columns: minmax(0, 1.15fr) minmax(0, .85fr);
        gap: 80px;
        align-items: center;
    }

    .lk-row.rev { --rot: 2.2deg; --bx: -22px; grid-template-columns: minmax(0, .85fr) minmax(0, 1.15fr); }
    .lk-row.rev .lk-media { order: 2; }

    /* ----- Ảnh xéo ----- */
    .lk-media {
        position: relative;
        display: block;
        aspect-ratio: 4 / 3;
        margin: 0 22px 22px 0;
        transform: translate3d(calc(var(--mx, 0) * 12px), calc(var(--my, 0) * 9px), 0) rotate(var(--rot));
        transition: transform .9s var(--ease), filter .6s;
        filter: drop-shadow(0 30px 28px rgba(110, 58, 18, .26));
        will-change: transform;
    }

    .lk-row.rev .lk-media { margin: 0 0 22px 22px; }

    .lk-row:hover .lk-media {
        --rot: 0deg;
        filter: drop-shadow(0 40px 36px rgba(110, 58, 18, .34));
    }

    /* khối cam lệch phía sau ảnh, trượt ra thêm khi hover */
    .lk-media::before {
        content: "";
        position: absolute; inset: 0; z-index: 0;
        background: linear-gradient(135deg, var(--o), #FFC067);
        clip-path: polygon(var(--slant) 0, 100% 0, calc(100% - var(--slant)) 100%, 0 100%);
        transform: translate3d(var(--bx), var(--by), 0);
        transition: transform .8s var(--ease), opacity .6s;
    }

    .lk-row.rev .lk-media::before { clip-path: polygon(0 0, calc(100% - var(--slant)) 0, 100% 100%, var(--slant) 100%); }
    .lk-row:hover .lk-media::before { transform: translate3d(calc(var(--bx) * 1.7), calc(var(--by) * 1.4), 0); }

    /* lớp cắt xéo chứa ảnh */
    .lk-clip {
        position: absolute; inset: 0; z-index: 1; overflow: hidden;
        background: linear-gradient(135deg, #F6EEDF, #E8DAC2);
        clip-path: polygon(var(--slant) 0, 100% 0, calc(100% - var(--slant)) 100%, 0 100%);
        transition: clip-path 1.3s var(--ease);
    }

    .lk-row.rev .lk-clip { clip-path: polygon(0 0, calc(100% - var(--slant)) 0, 100% 100%, var(--slant) 100%); }

    .lk-clip img {
        position: absolute; left: 0; top: -7%;
        width: 100%; height: 114%;
        object-fit: cover;
        scale: 1;
        transform: translate3d(0, var(--py, 0px), 0);        /* parallax khi cuộn */
        transition: scale 1.2s var(--ease);
        will-change: transform;
    }

    .lk-row:hover .lk-clip img { scale: 1.07; }

    .lk-clip::after {
        content: ""; position: absolute; inset: 0; z-index: 2; pointer-events: none;
        background: linear-gradient(to top, rgba(45, 22, 6, .42) 0%, rgba(45, 22, 6, 0) 46%);
    }

    /* vệt sáng quét chéo khi hover */
    .lk-shine {
        position: absolute; top: 0; left: -60%; z-index: 3;
        width: 36%; height: 100%; pointer-events: none;
        background: linear-gradient(100deg, rgba(255, 255, 255, 0), rgba(255, 255, 255, .3), rgba(255, 255, 255, 0));
        transform: skewX(-18deg);
    }

    .lk-row:hover .lk-shine { left: 135%; transition: left 1.1s var(--ease); }

    .lk-ph {
        position: absolute; top: 50%; left: 50%; z-index: 0;
        width: 76px; height: 76px; transform: translate(-50%, -50%);
        color: rgba(247, 148, 29, .4);
    }

    /* nhãn số ảnh: nghiêng, đè lên mép ảnh */
    .lk-count {
        position: absolute; left: -16px; bottom: 30px; z-index: 5;
        padding: 11px 24px 11px 20px;
        border-left: 4px solid var(--o);
        background: #fff; color: var(--head);
        font-size: 12px; font-weight: 800; letter-spacing: 1.2px; text-transform: uppercase;
        transform: skewX(-12deg);
        box-shadow: 0 14px 24px -10px rgba(110, 58, 18, .4);
        transition: padding .45s var(--ease), background .3s, color .3s;
    }

    .lk-row.rev .lk-count { left: auto; right: -16px; border-left: 0; border-right: 4px solid var(--o); }
    .lk-row:hover .lk-count { padding-right: 36px; background: var(--o); color: #fff; }
    .lk-row.rev:hover .lk-count { padding-right: 24px; padding-left: 36px; }

    /* ----- Chữ ----- */
    .lk-text { position: relative; isolation: isolate; padding: 30px 0 30px 8px; }

    /* nền xéo nhạt phía sau chữ, đồng điệu với góc xéo của ảnh */
    .lk-text::before {
        content: ""; position: absolute; z-index: -1; top: 0; bottom: 0; left: -26px; right: -40px;
        background: linear-gradient(90deg, rgba(255, 235, 201, .75), rgba(255, 235, 201, 0));
        transform: skewX(-8deg);
        transition: opacity .6s;
    }

    .lk-row.rev .lk-text::before {
        background: linear-gradient(270deg, rgba(255, 235, 201, .75), rgba(255, 235, 201, 0));
        transform: skewX(8deg);
        left: -40px; right: -26px;
    }

    .lk-no {
        position: absolute; top: -50px; left: -4px;
        font-size: 150px; line-height: 1; font-weight: 800; letter-spacing: -6px;
        color: transparent;
        -webkit-text-stroke: 1.5px rgba(247, 148, 29, .3);
        pointer-events: none; user-select: none;
        transform: translate3d(calc(var(--mx, 0) * -22px), calc(var(--my, 0) * -14px), 0);   /* trôi ngược chiều chuột */
        transition: transform .9s var(--ease), -webkit-text-stroke-color .5s;
    }

    .lk-row:hover .lk-no { -webkit-text-stroke-color: rgba(247, 148, 29, .65); }

    .lk-eyebrow {
        position: relative; display: flex; align-items: center; gap: 14px;
        font-size: 11.5px; font-weight: 800; letter-spacing: 1.6px; text-transform: uppercase; color: var(--am);
    }

    .lk-eyebrow::before {
        content: ""; width: 36px; height: 2px; background: var(--o);
        transform-origin: left; transform: skewX(-30deg);
        transition: transform .5s var(--ease);
    }

    .lk-row:hover .lk-eyebrow::before { transform: skewX(-30deg) scaleX(1.8); }

    .lk-title {
        position: relative; margin: 16px 0 18px;
        font-size: 40px; line-height: 1.15; font-weight: 800; letter-spacing: -.5px; color: var(--head);
    }

    /* gạch chân xéo chạy ra từ trái khi hover */
    .lk-title a {
        padding-bottom: 5px;
        background: linear-gradient(var(--o), var(--o)) 0 100% / 0 4px no-repeat;
        transition: background-size .55s var(--ease), color .2s;
    }

    .lk-row:hover .lk-title a { background-size: 100% 4px; color: var(--od); }

    .lk-desc {
        position: relative; margin: 0 0 34px; padding-left: 18px;
        border-left: 2px solid rgba(247, 148, 29, .4);
        font-size: 15.5px; line-height: 1.85; color: #7D5E40;
        display: -webkit-box; -webkit-line-clamp: 5; -webkit-box-orient: vertical; overflow: hidden;
    }

    /* Nút hình bình hành, nền nâu quét từ trái khi hover */
    .lk-btn {
        position: relative; display: inline-flex; align-items: center; gap: 18px;
        height: 54px; padding: 0 8px 0 30px; overflow: hidden;
        background: var(--o); color: #fff;
        font-size: 13px; font-weight: 800; letter-spacing: 1.2px; text-transform: uppercase;
        transform: skewX(-12deg);
        box-shadow: 0 14px 28px -8px rgba(247, 148, 29, .5);
        transition: transform .3s var(--ease), box-shadow .3s;
    }

    .lk-btn::before {
        content: ""; position: absolute; inset: 0; z-index: 0;
        background: var(--head); transform: scaleX(0); transform-origin: left;
        transition: transform .55s var(--ease);
    }

    .lk-btn span { position: relative; z-index: 1; transform: skewX(12deg); }

    .lk-btn i {
        position: relative; z-index: 1;
        width: 38px; height: 38px; background: rgba(255, 255, 255, .22);
        display: flex; align-items: center; justify-content: center;
        transform: skewX(12deg);
        transition: transform .4s var(--ease), background .3s;
    }

    .lk-btn:hover { transform: skewX(-12deg) translateY(-3px); box-shadow: 0 20px 34px -8px rgba(110, 58, 18, .45); }
    .lk-btn:hover::before { transform: scaleX(1); }
    .lk-btn:hover i { transform: skewX(12deg) translateX(5px); background: var(--o); }
    .lk-btn:focus-visible, .lk-media:focus-visible { outline: 3px solid var(--o); outline-offset: 6px; }

    /* ----- Chưa có bộ sưu tập ----- */
    .lk-empty {
        padding: 80px 20px; text-align: center;
        border: 1.5px dashed #F2D9A8; background: #FFFDF8; color: var(--muted);
    }

    .lk-empty b { display: block; margin-bottom: 6px; font-size: 18px; color: var(--head); }

    /* ----- Hiệu ứng xuất hiện khi cuộn tới (chỉ bật khi JS chạy được) ----- */

    /* ảnh: lưỡi cắt xéo quét ra từ một cạnh */
    .lk.is-js .lk-row:not(.rev) .lk-media:not(.is-in) .lk-clip {
        clip-path: polygon(var(--slant) 0, var(--slant) 0, 0 100%, 0 100%);
    }

    .lk.is-js .lk-row.rev .lk-media:not(.is-in) .lk-clip {
        clip-path: polygon(100% 0, 100% 0, calc(100% - var(--slant)) 100%, calc(100% - var(--slant)) 100%);
    }

    .lk.is-js .lk-media:not(.is-in)::before { opacity: 0; transform: none; }
    .lk.is-js .lk-media.is-in::before { transition-delay: .45s, .45s; }

    .lk.is-js .lk-clip img { scale: 1.2; }
    .lk.is-js .lk-media.is-in .lk-clip img { scale: 1; transition: scale 1.8s var(--ease); }
    .lk.is-js .lk-row:hover .lk-media.is-in .lk-clip img { scale: 1.07; transition: scale 1.2s var(--ease); }

    .lk.is-js .lk-count { opacity: 0; }
    .lk.is-js .lk-media.is-in .lk-count { opacity: 1; transition: opacity .6s ease .9s, padding .45s var(--ease), background .3s, color .3s; }

    /* chữ: từng phần tử hiện lần lượt */
    .lk.is-js .lk-text > :not(.lk-no) {
        opacity: 0; transform: translate3d(0, 28px, 0);
        transition: opacity .8s ease, transform .9s var(--ease);
    }

    .lk.is-js .lk-text.is-in > :not(.lk-no) { opacity: 1; transform: none; }
    .lk.is-js .lk-text.is-in > :nth-child(2) { transition-delay: .3s; }
    .lk.is-js .lk-text.is-in > :nth-child(3) { transition-delay: .4s; }
    .lk.is-js .lk-text.is-in > :nth-child(4) { transition-delay: .5s; }
    .lk.is-js .lk-text.is-in > :nth-child(5) { transition-delay: .6s; }

    /* nút giữ nguyên hiệu ứng skew khi hiện */
    .lk.is-js .lk-text > .lk-btn { transform: skewX(-12deg) translate3d(0, 28px, 0); }
    .lk.is-js .lk-text.is-in > .lk-btn { transform: skewX(-12deg); }
    .lk.is-js .lk-text.is-in > .lk-btn:hover { transform: skewX(-12deg) translateY(-3px); }

    .lk.is-js .lk-no { opacity: 0; transition: opacity 1.2s ease .2s, transform .9s var(--ease), -webkit-text-stroke-color .5s; }
    .lk.is-js .lk-text.is-in .lk-no { opacity: 1; }

    .lk.is-js .lk-text::before { opacity: 0; }
    .lk.is-js .lk-text.is-in::before { opacity: 1; transition-delay: .2s; }

    .lk.is-js .lk-rule { transform: scaleX(0); transition: transform 1s var(--ease) .3s; }
    .lk.is-js .lk-rule.is-in { transform: scaleX(1); }

    @media (prefers-reduced-motion: reduce) {
        .lk *, .lk *::before, .lk *::after { transition: none !important; animation: none !important; }
        .lk-row:hover .lk-clip img { scale: 1; }
        .lk-progress { display: none; }
    }

    /* ----- Màn hình nhỏ ----- */
    @media (max-width: 960px) {
        .lk { --slant: 6%; }
        .lk-list { gap: 96px; }
        .lk-row, .lk-row.rev { --rot: -1.2deg; --bx: 12px; --by: 14px; grid-template-columns: minmax(0, 1fr); gap: 34px; }
        .lk-row.rev { --rot: 1.2deg; --bx: -12px; }
        .lk-row.rev .lk-media { order: 0; margin: 0 14px 14px 0; }
        .lk-media { margin: 0 14px 14px 0; }
        .lk-row.rev .lk-media { margin: 0 0 14px 14px; }
        .lk-text, .lk-row.rev .lk-text { padding: 20px 0 10px; }
        .lk-text::before, .lk-row.rev .lk-text::before { left: -12px; right: -12px; }
        .lk-no { top: -40px; font-size: 96px; }
        .lk-title { font-size: 30px; }
        .lk-count, .lk-row.rev .lk-count { left: -8px; right: auto; border-right: 0; border-left: 4px solid var(--o); }
        .lk.is-js .lk-row.rev .lk-media:not(.is-in) .lk-clip {
            clip-path: polygon(100% 0, 100% 0, calc(100% - var(--slant)) 100%, calc(100% - var(--slant)) 100%);
        }
    }

    @media (max-width: 560px) {
        .lk-hero { margin-bottom: 26px; }
        .lk-marq-wrap { margin-bottom: 44px; }
        .lk-title { font-size: 26px; }
        .lk-desc { font-size: 15px; }
        .lk-btn { height: 50px; padding-left: 24px; }
    }
</style>

<div class="lk-progress" id="lkProgress" aria-hidden="true"></div>

<section class="sec lk" id="lkRoot">

    <header class="lk-hero">
        <div class="eyebrow">Lookbook</div>
        <h1 class="sec-title">Bộ sưu tập</h1>
        <p>Những gợi ý phối đồ từ PolySneaker: chọn một bộ sưu tập để xem từng set đồ và các đôi giày đi kèm.</p>
        <span class="lk-rule" data-reveal-rule></span>
        <c:if test="${not empty lookbooks}">
            <span class="lk-total">${fn:length(lookbooks)} bộ sưu tập</span>
        </c:if>
    </header>

    <c:if test="${not empty lookbooks}">
        <div class="lk-marq-wrap" aria-hidden="true">
            <div class="lk-marq">
                <div class="lk-marq-track">
                    <span>Bộ sưu tập<i>/</i></span><span>Phối đồ<i>/</i></span><span>PolySneaker<i>/</i></span><span>Mùa mới<i>/</i></span>
                    <span>Bộ sưu tập<i>/</i></span><span>Phối đồ<i>/</i></span><span>PolySneaker<i>/</i></span><span>Mùa mới<i>/</i></span>
                </div>
                <div class="lk-marq-track">
                    <span>Bộ sưu tập<i>/</i></span><span>Phối đồ<i>/</i></span><span>PolySneaker<i>/</i></span><span>Mùa mới<i>/</i></span>
                    <span>Bộ sưu tập<i>/</i></span><span>Phối đồ<i>/</i></span><span>PolySneaker<i>/</i></span><span>Mùa mới<i>/</i></span>
                </div>
            </div>
        </div>
    </c:if>

    <c:choose>
        <c:when test="${not empty lookbooks}">
            <div class="lk-list">
                <c:forEach var="l" items="${lookbooks}" varStatus="st">

                    <c:set var="lsrc" value="" />
                    <c:if test="${not empty l.coverImageUrl}">
                        <c:choose>
                            <c:when test="${fn:startsWith(l.coverImageUrl, 'http')}">
                                <c:set var="lsrc" value="${l.coverImageUrl}" />
                            </c:when>
                            <c:when test="${fn:startsWith(l.coverImageUrl, '/')}">
                                <c:set var="lsrc" value="${ctx}${l.coverImageUrl}" />
                            </c:when>
                            <c:otherwise>
                                <c:set var="lsrc" value="${ctx}/static/assets/images/${l.coverImageUrl}" />
                            </c:otherwise>
                        </c:choose>
                    </c:if>

                    <article class="lk-row ${st.index % 2 == 1 ? 'rev' : ''}">

                        <a class="lk-media" href="${ctx}/lookbooks/${l.id}#lbdProducts" data-reveal
                           aria-label="Xem bộ sưu tập <c:out value='${l.title}'/>">
                            <div class="lk-clip">
                                <svg class="lk-ph" aria-hidden="true"><use href="#ic-shoe" /></svg>
                                <c:if test="${not empty lsrc}">
                                    <img src="<c:out value='${lsrc}'/>" alt="<c:out value='${l.title}'/>"
                                         loading="lazy" onerror="this.style.display='none'">
                                </c:if>
                                <span class="lk-shine" aria-hidden="true"></span>
                            </div>
                            <span class="lk-count">${l.photoCount} ảnh</span>
                        </a>

                        <div class="lk-text" data-reveal>
                            <span class="lk-no" aria-hidden="true"><fmt:formatNumber value="${st.count}" pattern="00" /></span>
                            <div class="lk-eyebrow">Lookbook</div>
                            <h2 class="lk-title">
                                <a href="${ctx}/lookbooks/${l.id}#lbdProducts"><c:out value="${l.title}" /></a>
                            </h2>
                            <c:if test="${not empty l.description}">
                                <p class="lk-desc"><c:out value="${l.description}" /></p>
                            </c:if>
                            <a class="lk-btn" href="${ctx}/lookbooks/${l.id}#lbdProducts" aria-label="Xem sản phẩm của bộ sưu tập">
                                <span>Xem</span>
                                <i>
                                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor"
                                         stroke-width="2.6" stroke-linecap="square" stroke-linejoin="miter" aria-hidden="true">
                                        <line x1="5" y1="12" x2="19" y2="12" />
                                        <polyline points="12 5 19 12 12 19" />
                                    </svg>
                                </i>
                            </a>
                        </div>
                    </article>
                </c:forEach>
            </div>
        </c:when>
        <c:otherwise>
            <div class="lk-empty">
                <b>Chưa có bộ sưu tập nào</b>
                Bạn quay lại sau nhé, các set đồ mới sẽ sớm được cập nhật.
            </div>
        </c:otherwise>
    </c:choose>
</section>

<script>
    (function () {
        var root = document.getElementById('lkRoot');
        if (!root) return;

        var reduce = window.matchMedia && window.matchMedia('(prefers-reduced-motion: reduce)').matches;

        /* 1. Thanh tiến độ cuộn */
        var bar = document.getElementById('lkProgress');
        function updateBar() {
            var h = document.documentElement.scrollHeight - window.innerHeight;
            var p = h > 0 ? Math.min(1, Math.max(0, window.scrollY / h)) : 0;
            if (bar) bar.style.transform = 'scaleX(' + p + ')';
        }

        /* 2. Parallax nhẹ cho ảnh */
        var imgs = root.querySelectorAll('.lk-clip img');
        function updateParallax() {
            var vh = window.innerHeight;
            imgs.forEach(function (img) {
                var r = img.parentNode.getBoundingClientRect();
                if (r.bottom < 0 || r.top > vh) return;
                var k = ((r.top + r.height / 2) - vh / 2) / vh;      // -0.5 … 0.5
                img.style.setProperty('--py', (-k * 36).toFixed(1) + 'px');
            });
        }

        var ticking = false;
        function onScroll() {
            if (ticking) return;
            ticking = true;
            requestAnimationFrame(function () {
                updateBar();
                if (!reduce) updateParallax();
                ticking = false;
            });
        }

        window.addEventListener('scroll', onScroll, { passive: true });
        window.addEventListener('resize', onScroll);
        onScroll();

        if (reduce) return;

        /* 3. Ảnh và số trôi nhẹ theo con trỏ chuột (chỉ máy có chuột) */
        if (window.matchMedia && window.matchMedia('(hover: hover) and (pointer: fine)').matches) {
            root.querySelectorAll('.lk-row').forEach(function (row) {
                var raf = 0;
                row.addEventListener('pointermove', function (e) {
                    if (raf) return;
                    raf = requestAnimationFrame(function () {
                        raf = 0;
                        var r = row.getBoundingClientRect();
                        var mx = ((e.clientX - r.left) / r.width - 0.5) * 2;     // -1 … 1
                        var my = ((e.clientY - r.top) / r.height - 0.5) * 2;
                        row.style.setProperty('--mx', mx.toFixed(3));
                        row.style.setProperty('--my', my.toFixed(3));
                    });
                });
                row.addEventListener('pointerleave', function () {
                    row.style.setProperty('--mx', 0);
                    row.style.setProperty('--my', 0);
                });
            });
        }

        /* 4. Hiệu ứng xuất hiện khi cuộn tới.
              Quan sát CẢ HÀNG (không quan sát ảnh): ảnh đang bị clip-path che nên trình duyệt coi như "không nhìn thấy". */
        if (!('IntersectionObserver' in window)) return;

        var items = root.querySelectorAll('.lk-row, [data-reveal-rule]');
        if (!items.length) return;

        root.classList.add('is-js');
        var io = new IntersectionObserver(function (entries) {
            entries.forEach(function (e) {
                if (!e.isIntersecting) return;
                var t = e.target;
                t.classList.add('is-in');
                t.querySelectorAll('[data-reveal]').forEach(function (el) { el.classList.add('is-in'); });
                io.unobserve(t);
            });
        }, { threshold: 0.12, rootMargin: '0px 0px -40px 0px' });

        items.forEach(function (el) { io.observe(el); });

        // Phòng hờ: sau 3 giây mà chưa có hàng nào hiện (trình duyệt lạ) thì hiện hết, tránh trang bị trống
        setTimeout(function () {
            if (root.querySelector('.lk-media.is-in')) return;
            root.querySelectorAll('[data-reveal], [data-reveal-rule]').forEach(function (el) { el.classList.add('is-in'); });
        }, 3000);
    })();
</script>

<jsp:include page="/WEB-INF/views/layouts/footer.jsp" />
