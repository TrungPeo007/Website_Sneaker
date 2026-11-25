<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />

<%--
    HERO XOAY GIÀY THEO CUỘN TRANG (giày tự vẽ bằng SVG, không cần ảnh/3D)
    File: /WEB-INF/views/layouts/hero-banner.jsp
    Gọi trong index.jsp:  <jsp:include page="/WEB-INF/views/layouts/hero-banner.jsp"/>
    Mọi class/id đều có tiền tố "spn" để KHÔNG trùng với main.css (main.css đã có .hs-btn của nút tìm kiếm).
--%>

<style>
html { overflow-x: clip; }

.spn {
    --spn-top: 108px;                /* = chiều cao header (màn nhỏ: 84px) */
    --ink: #0e0906;
    --accent: #F7941D;
    --line: rgba(255, 255, 255, .16);
    --mute: rgba(255, 255, 255, .70);
    position: relative;
    height: 460vh;                   /* độ dài đoạn cuộn: tăng thì xoay chậm hơn */
    width: 100vw;
    margin-left: calc(50% - 50vw);
    background: var(--ink);
    color: #fff;
}

.spn *,
.spn *::before,
.spn *::after { box-sizing: border-box; }

.spn-stage {
    position: sticky;
    top: var(--spn-top);
    height: calc(100vh - var(--spn-top));
    min-height: 560px;
    overflow: hidden;
    background:
        radial-gradient(44% 58% at var(--glow-x, 68%) 54%, rgba(247, 148, 29, .26), transparent 72%),
        var(--ink);
}

/* ---------- Đôi giày xếp lớp ---------- */
.spn-shoe {
    position: absolute;
    left: 68%;                       /* JS đổi vị trí ngang theo từng mặt */
    top: 50%;
    width: min(640px, 76vw);
    aspect-ratio: 2 / 1;
    transform: translate(-50%, -54%);
    perspective: 1600px;
    z-index: 2;
}

.spn-3d {
    position: absolute;
    inset: 0;
    transform-style: preserve-3d;
    will-change: transform;
}

.spn-layer {
    position: absolute;
    inset: 0;
}

.spn-layer svg {
    display: block;
    width: 100%;
    height: 100%;
    overflow: visible;
}

.spn-floor {
    position: absolute;
    left: 8%;
    right: 8%;
    bottom: 2%;
    height: 34px;
    border-radius: 50%;
    background: radial-gradient(ellipse at center, rgba(0, 0, 0, .8), transparent 70%);
    filter: blur(5px);
    will-change: transform;
}

/* ---------- Chữ quảng cáo ---------- */
.spn-panel {
    position: absolute;
    z-index: 3;
    top: 0;
    bottom: 0;
    display: flex;
    flex-direction: column;
    justify-content: center;
    opacity: 0;
    will-change: opacity, transform;
    pointer-events: none;
}

.spn-panel.on { pointer-events: auto; }

.spn-p0 { left: 6vw; width: min(580px, 44vw); }
.spn-p1 { left: 6vw; width: min(380px, 32vw); }
.spn-p2 { right: 6vw; width: min(380px, 32vw); }

.spn-small {
    margin: 0 0 14px;
    font-size: 14px;
    font-weight: 700;
    color: var(--accent);
}

.spn-title {
    margin: 0 0 16px;
    font-size: clamp(36px, 4.8vw, 76px);
    line-height: 1;
    font-weight: 900;
    letter-spacing: -1.5px;
}

.spn-title em {
    display: block;
    font-style: normal;
    color: var(--accent);
}

.spn-h {
    margin: 0 0 14px;
    font-size: clamp(28px, 3vw, 44px);
    line-height: 1.06;
    font-weight: 900;
    letter-spacing: -1px;
}

.spn-sub {
    margin: 0 0 22px;
    font-size: 15px;
    line-height: 1.65;
    color: var(--mute);
}

.spn-spec {
    list-style: none;
    margin: 0 0 26px;
    padding: 0;
    border-top: 1px solid var(--line);
}

.spn-spec li {
    display: flex;
    justify-content: space-between;
    gap: 16px;
    padding: 12px 0;
    border-bottom: 1px solid var(--line);
    font-size: 14px;
    color: var(--mute);
}

.spn-spec b {
    color: #fff;
    font-weight: 700;
    text-align: right;
}

.spn-cta {
    display: flex;
    flex-wrap: wrap;
    gap: 10px;
}

/* Nút: đặt width/height/padding rõ ràng, không dùng lại tên class của main.css */
.spn-cta .spn-btn {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    flex: 0 0 auto;
    width: auto;
    min-width: 0;
    height: 52px;
    padding: 0 28px;
    margin: 0;
    border: 1px solid var(--accent);
    border-radius: 0;
    background: var(--accent);
    color: #1a0d03;
    font-family: inherit;
    font-weight: 800;
    font-size: 14px;
    line-height: 1;
    white-space: nowrap;
    text-decoration: none;
    transition: background .2s, transform .2s;
}

.spn-cta .spn-btn:hover { background: #ffad4d; transform: translateX(4px); }

.spn-cta .spn-btn.line {
    background: transparent;
    color: #fff;
    border-color: rgba(255, 255, 255, .32);
}

.spn-cta .spn-btn.line:hover { background: rgba(255, 255, 255, .1); }

.spn-btn:focus-visible,
.spn-tick:focus-visible {
    outline: 3px solid #fff;
    outline-offset: 3px;
}

/* ---------- Thanh chọn mặt: nằm dưới đáy, không đè chữ ---------- */
.spn-rail {
    position: absolute;
    z-index: 4;
    left: 50%;
    bottom: 24px;
    transform: translateX(-50%);
    display: flex;
    gap: 22px;
}

.spn-tick {
    display: flex;
    flex-direction: column;
    gap: 10px;
    width: 96px;
    padding: 0;
    border: 0;
    background: none;
    color: var(--mute);
    font-family: inherit;
    font-size: 12.5px;
    font-weight: 700;
    text-align: left;
    cursor: pointer;
}

.spn-tick i {
    display: block;
    width: 100%;
    height: 3px;
    background: var(--line);
    position: relative;
    overflow: hidden;
}

.spn-tick i::after {
    content: "";
    position: absolute;
    inset: 0;
    background: var(--accent);
    transform: scaleX(0);
    transform-origin: left;
    transition: transform .4s;
}

.spn-tick.on { color: #fff; }
.spn-tick.on i::after { transform: scaleX(1); }

/* ---------- Gợi ý cuộn ---------- */
.spn-hint {
    position: absolute;
    z-index: 4;
    left: 50%;
    bottom: 84px;
    transform: translateX(-50%);
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 8px;
    font-size: 12.5px;
    color: var(--mute);
    transition: opacity .3s;
    pointer-events: none;
}

.spn-hint::after {
    content: "";
    width: 1px;
    height: 30px;
    background: linear-gradient(var(--accent), transparent);
    animation: spn-drip 1.6s ease-in infinite;
    transform-origin: top;
}

@keyframes spn-drip {
    0%   { transform: scaleY(0); opacity: 1; }
    70%  { transform: scaleY(1); opacity: 1; }
    100% { transform: scaleY(1); opacity: 0; }
}

/* ---------- Màn hình nhỏ ---------- */
@media (max-width: 900px) {
    .spn { --spn-top: 84px; height: 420vh; }
    .spn-shoe { top: 28%; width: min(460px, 90vw); }

    .spn-panel {
        left: 20px;
        right: 20px;
        top: auto;
        bottom: 70px;
        width: auto;
        justify-content: flex-end;
    }

    .spn-title { font-size: 36px; }
    .spn-h { font-size: 28px; }
    .spn-sub { font-size: 14px; margin-bottom: 16px; }
    .spn-spec { display: none; }
    .spn-cta .spn-btn { height: 46px; padding: 0 20px; }
    .spn-tick { width: 70px; }
    .spn-rail { gap: 14px; bottom: 18px; }
    .spn-hint { display: none; }
}

@media (prefers-reduced-motion: reduce) {
    .spn-hint::after { animation: none; }
    .spn-cta .spn-btn { transition: none; }
}
</style>

<%-- ===== Bản vẽ đôi giày (SVG): dùng chung cho mọi lớp ===== --%>
<svg width="0" height="0" style="position:absolute" aria-hidden="true" focusable="false">
    <defs>
        <linearGradient id="spnUp" x1="0" y1="0" x2="0" y2="1">
        <stop offset="0" stop-color="#FFFBF3"/><stop offset="1" stop-color="#E4D8C4"/>
        </linearGradient>
        <linearGradient id="spnMid" x1="0" y1="0" x2="0" y2="1">
        <stop offset="0" stop-color="#FFFFFF"/><stop offset="1" stop-color="#E6DFD2"/>
        </linearGradient>
        <linearGradient id="spnOr" x1="0" y1="0" x2="0" y2="1">
        <stop offset="0" stop-color="#FFB04A"/><stop offset="1" stop-color="#E8780C"/>
        </linearGradient>
        <linearGradient id="spnDark" x1="0" y1="0" x2="0" y2="1">
        <stop offset="0" stop-color="#4a3d35"/><stop offset="1" stop-color="#241c17"/>
        </linearGradient>
        <linearGradient id="spnAO" x1="0" y1="1" x2="0" y2="0">
        <stop offset="0" stop-color="#000" stop-opacity=".38"/><stop offset=".22" stop-color="#000" stop-opacity="0"/>
        </linearGradient>
        <linearGradient id="spnHi" x1="0" y1="0" x2="0" y2="1">
        <stop offset="0" stop-color="#fff" stop-opacity=".55"/><stop offset=".25" stop-color="#fff" stop-opacity="0"/>
        </linearGradient>
        <pattern id="spnMesh" width="8" height="8" patternUnits="userSpaceOnUse" patternTransform="rotate(45)">
        <circle cx="4" cy="4" r="1.15" fill="#5b3a1a" fill-opacity=".28"/>
        </pattern>

        <path id="spnUpper" d="M64 268 C54 224 58 184 72 154 C82 136 106 130 128 138 C156 148 176 172 200 180 C220 186 232 150 244 116 C251 96 272 88 286 100 L330 158 C396 168 462 174 522 182 C618 194 708 206 738 232 C752 244 754 264 750 274 L64 274 Z"/>
        <path id="spnMidP" d="M58 268 C54 298 66 324 100 332 C140 340 200 340 240 340 L540 334 C630 332 712 318 752 290 C762 282 758 274 748 270 C700 264 600 264 540 270 L100 270 C80 270 66 268 58 268 Z"/>
        <path id="spnOut" d="M72 330 C86 338 112 344 150 346 L540 342 C640 340 722 322 754 292 C752 312 716 336 650 346 C620 350 580 352 540 352 L150 352 C104 352 76 346 72 330 Z"/>
        <clipPath id="spnCu"><use href="#spnUpper"/></clipPath>
        <clipPath id="spnCm"><use href="#spnMidP"/></clipPath>
        <%-- Lớp ruột (chỉ có màu, tạo độ dày cho giày) --%>
        <g id="spnSil" transform="translate(0,-10)">
            <use href="#spnOut" fill="#1f1815"/>
            <use href="#spnMidP" fill="#D3CBBD"/>
            <use href="#spnUpper" fill="#C2701F"/>
        </g>
        <g id="spnArt" transform="translate(0,-10)">
        <!-- outsole -->
        <use href="#spnOut" fill="#1f1815"/>
        <!-- midsole -->
        <use href="#spnMidP" fill="url(#spnMid)" stroke="#000" stroke-opacity=".28" stroke-width="1.6"/>
        <g clip-path="url(#spnCm)">
        <!-- heel air window -->
        <rect x="84" y="290" width="140" height="34" rx="17" fill="url(#spnOr)"/>
        <rect x="94" y="295" width="120" height="7" rx="3.5" fill="#fff" fill-opacity=".55"/>
        <!-- midsole line -->
        <path d="M60 312 C200 316 440 314 760 298" fill="none" stroke="#000" stroke-opacity=".12" stroke-width="3"/>
        <rect x="0" y="262" width="800" height="14" fill="#000" fill-opacity=".10"/>
        </g>

        <!-- upper base -->
        <use href="#spnUpper" fill="url(#spnUp)"/>
        <g clip-path="url(#spnCu)">
        <use href="#spnUpper" fill="url(#spnMesh)"/>

        <!-- heel counter -->
        <path d="M56 280 C48 226 54 180 72 148 C84 170 112 196 142 206 C132 230 128 252 134 280 Z" fill="url(#spnOr)"/>
        <!-- toe cap -->
        <path d="M548 184 C640 196 712 210 740 236 L754 280 L574 280 C596 250 586 212 548 184 Z" fill="#EADFCB"/>
        <path d="M548 184 C586 212 596 250 574 280" fill="none" stroke="#000" stroke-opacity=".18" stroke-width="2" stroke-dasharray="5 4"/>
        <!-- side stripe -->
        <path d="M146 268 C250 266 380 238 492 190 L516 200 C400 262 260 292 146 288 Z" fill="url(#spnDark)"/>
        <path d="M72 154 C82 136 106 130 128 138 C156 148 176 172 200 180 C220 186 232 150 244 116" fill="none" stroke="#2b221c" stroke-width="9" stroke-linecap="round" stroke-opacity=".85"/>
        <!-- tongue -->
        <path d="M236 164 C242 120 262 88 284 94 C298 100 308 128 322 158 L338 172 L252 190 Z" fill="url(#spnOr)"/>
        <path d="M256 112 C264 100 276 98 286 106" fill="none" stroke="#fff" stroke-opacity=".7" stroke-width="3" stroke-linecap="round"/>
        <!-- eyestay -->
        <path d="M288 98 L332 156 C398 166 464 172 524 180 L520 198 C458 192 392 186 322 178 L272 116 Z" fill="url(#spnDark)" stroke="#000" stroke-opacity=".3" stroke-width="1.2"/>
        <!-- laces -->
        <g stroke="#FFF8EA" stroke-width="6.5" stroke-linecap="round">
        <path d="M300 112 L284 142"/><path d="M326 142 L310 174"/><path d="M362 158 L352 190"/>
        <path d="M406 164 L398 196"/><path d="M452 170 L448 202"/><path d="M498 176 L496 208"/>
        </g>
        <!-- stitching -->
        <path d="M70 252 C62 214 66 184 78 158" fill="none" stroke="#fff" stroke-opacity=".6" stroke-width="2" stroke-dasharray="5 4"/>
        <!-- shading -->
        <use href="#spnUpper" fill="url(#spnHi)"/>
        <use href="#spnUpper" fill="url(#spnAO)"/>
        </g>
        <use href="#spnUpper" fill="none" stroke="#000" stroke-opacity=".3" stroke-width="1.6"/>
        <!-- pull tab -->
        <path d="M70 156 C58 142 60 122 76 116 L88 128 C80 134 80 142 86 148 Z" fill="url(#spnOr)"/>
        </g>
    </defs>
</svg>

<!-- ===== 1. HERO: CUỘN ĐỂ XOAY GIÀY ===== -->
<section class="spn" id="spn" aria-label="Giới thiệu giày, cuộn trang để xoay">
    <div class="spn-stage">

        <div class="spn-shoe" id="spnShoe" aria-hidden="true">
            <div class="spn-floor" id="spnFloor"></div>
            <div class="spn-3d" id="spn3d"></div>
        </div>

        <%-- Mặt 1: chính diện --%>
        <div class="spn-panel spn-p0" data-from="up">
            <p class="spn-small">PolySneaker · Bộ sưu tập Spring 25</p>
            <h2 class="spn-title">Nâng niu <em>từng bước chân.</em></h2>
            <p class="spn-sub">Sneaker phong cách Nhật – Hàn: thoáng khí, êm ái, thanh lịch cho mỗi ngày năng động.</p>
            <div class="spn-cta">
                <a href="${ctx}/shop" class="spn-btn">Khám phá bộ sưu tập</a>
                <a href="${ctx}/lookbooks" class="spn-btn line">Xem LookBook</a>
            </div>
        </div>

        <%-- Mặt 2: mặt phải --%>
        <div class="spn-panel spn-p1" data-from="left">
            <p class="spn-small">Mặt phải</p>
            <h3 class="spn-h">Đế êm như bước trên mây.</h3>
            <p class="spn-sub">Đệm khí thoáng, giảm lực chấn động cho mỗi bước đi, từ sáng đến tối.</p>
            <ul class="spn-spec">
                <li>Đệm đế <b>Khí êm ái</b></li>
                <li>Thân giày <b>Lưới thoáng khí</b></li>
                <li>Ưu đãi mùa này <b>Tiết kiệm 850.000đ</b></li>
            </ul>
            <div class="spn-cta"><a href="${ctx}/shop" class="spn-btn">Xem chi tiết</a></div>
        </div>

        <%-- Mặt 3: mặt trái --%>
        <div class="spn-panel spn-p2" data-from="right">
            <p class="spn-small">Mặt trái</p>
            <h3 class="spn-h">Form ôm chân người Việt.</h3>
            <p class="spn-sub">Mũi giày rộng vừa đủ, không cấn ngón út. Chưa vừa thì đổi size tận nhà trong 30 ngày.</p>
            <ul class="spn-spec">
                <li>Chính hãng <b>100% ủy quyền</b></li>
                <li>Đổi trả <b>30 ngày</b></li>
                <li>Giao hàng <b>Nhanh trong 2 giờ</b></li>
            </ul>
            <div class="spn-cta"><a href="${ctx}/shop" class="spn-btn">Xem bộ sưu tập</a></div>
        </div>

        <div class="spn-rail" role="tablist" aria-label="Chọn mặt giày">
            <button type="button" class="spn-tick on" data-go="0.02"><i></i><span>Chính diện</span></button>
            <button type="button" class="spn-tick" data-go="0.5"><i></i><span>Mặt phải</span></button>
            <button type="button" class="spn-tick" data-go="0.97"><i></i><span>Mặt trái</span></button>
        </div>

        <div class="spn-hint" id="spnHint">Cuộn xuống để xoay giày</div>
    </div>
</section>

<script>
(function () {
    var root = document.getElementById('spn');
    if (!root) return;

    var stage = root.querySelector('.spn-stage');
    var shoe = document.getElementById('spnShoe');
    var g3d = document.getElementById('spn3d');
    var floor = document.getElementById('spnFloor');
    var panels = [].slice.call(root.querySelectorAll('.spn-panel'));
    var ticks = [].slice.call(root.querySelectorAll('.spn-tick'));
    var hint = document.getElementById('spnHint');

    // ====== CHỈNH Ở ĐÂY ======
    // Góc xoay quanh trục dọc cho 3 mặt: chéo 3/4 -> mặt phải (nhìn ngang) -> mặt trái (xoay thêm 180°)
    var ANGLES = [-35, 0, 180];
    var SHIFT  = [68, 68, 34];     // vị trí ngang của giày (% chiều rộng); mặt trái dạt sang trái nhường chữ bên phải
    var TILT   = -7;               // nghiêng nhẹ từ trên xuống (độ)
    var LAYERS = 22;               // số lớp tạo độ dày; GAP là khoảng cách giữa các lớp (px)
    var GAP    = 5.5;
    // Đoạn cuộn "đứng yên" ở mỗi mặt (0..1); giữa các đoạn là lúc giày xoay
    var HOLDS  = [[0, .14], [.36, .64], [.86, 1]];
    var SMOOTH = .10;              // nhỏ = trễ mượt hơn, lớn = bám sát tay cuộn
    // =========================

    // Dựng các lớp giày: 2 lớp ngoài cùng có đủ chi tiết, lớp giữa chỉ là khối màu
    var html = '';
    for (var i = 0; i < LAYERS; i++) {
        var z = ((i - (LAYERS - 1) / 2) * GAP).toFixed(2);
        var face = (i === 0 || i === LAYERS - 1) ? '#spnArt' : '#spnSil';
        html += '<div class="spn-layer" style="transform:translateZ(' + z + 'px)">' +
                '<svg viewBox="0 0 800 400"><use href="' + face + '"/></svg></div>';
    }
    g3d.innerHTML = html;

    function clamp(v, a, b) { return Math.max(a, Math.min(b, v)); }
    function lerp(a, b, t) { return a + (b - a) * t; }
    function ease(t) { return t < .5 ? 4 * t * t * t : 1 - Math.pow(-2 * t + 2, 3) / 2; }

    function stageAt(p) {
        if (p <= HOLDS[0][1]) return 0;
        if (p < HOLDS[1][0]) return ease((p - HOLDS[0][1]) / (HOLDS[1][0] - HOLDS[0][1]));
        if (p <= HOLDS[1][1]) return 1;
        if (p < HOLDS[2][0]) return 1 + ease((p - HOLDS[1][1]) / (HOLDS[2][0] - HOLDS[1][1]));
        return 2;
    }

    function mix(arr, k) {
        var i = Math.min(Math.floor(k), 1);
        return lerp(arr[i], arr[i + 1], k - i);
    }

    function visibility(p, h) {
        var d = p < h[0] ? h[0] - p : (p > h[1] ? p - h[1] : 0);
        return clamp(1 - d / .10, 0, 1);
    }

    function rawProgress() {
        var top = parseFloat(getComputedStyle(stage).top) || 0;
        var total = root.offsetHeight - stage.offsetHeight;
        var r = root.getBoundingClientRect();
        return clamp((top - r.top) / total, 0, 1);
    }

    var target = rawProgress(), cur = target, last = -1;

    function render() {
        var k = stageAt(cur);
        var theta = mix(ANGLES, k);
        var narrow = window.innerWidth <= 900;

        g3d.style.transform = 'rotateX(' + TILT + 'deg) rotateY(' + theta + 'deg)';
        floor.style.transform = 'scaleX(' + (.45 + .55 * Math.abs(Math.cos(theta * Math.PI / 180))).toFixed(3) + ')';

        var sx = narrow ? 50 : mix(SHIFT, k);
        shoe.style.left = sx + '%';
        stage.style.setProperty('--glow-x', sx + '%');

        for (var i = 0; i < panels.length; i++) {
            var v = visibility(cur, HOLDS[i]);
            var from = panels[i].getAttribute('data-from');
            var off = (1 - v) * 44;
            var tx = from === 'left' ? -off : (from === 'right' ? off : 0);
            var ty = from === 'up' ? off : 0;
            panels[i].style.opacity = v;
            panels[i].style.transform = 'translate(' + tx + 'px,' + ty + 'px)';
            panels[i].classList.toggle('on', v > .6);
        }

        var near = k < .5 ? 0 : (k < 1.5 ? 1 : 2);
        for (var j = 0; j < ticks.length; j++) ticks[j].classList.toggle('on', j === near);
        hint.style.opacity = cur < .04 ? 1 : 0;
    }

    function loop() {
        target = rawProgress();
        cur += (target - cur) * SMOOTH;
        if (Math.abs(target - cur) < .0004) cur = target;
        if (cur !== last) { render(); last = cur; }
        requestAnimationFrame(loop);
    }

    // Bấm thanh bên dưới: cuộn thẳng tới mặt đó
    ticks.forEach(function (t) {
        t.addEventListener('click', function () {
            var top = parseFloat(getComputedStyle(stage).top) || 0;
            var total = root.offsetHeight - stage.offsetHeight;
            var y = root.getBoundingClientRect().top + window.pageYOffset - top + total * parseFloat(t.getAttribute('data-go'));
            window.scrollTo({ top: y, behavior: 'smooth' });
        });
    });

    window.addEventListener('resize', function () { last = -1; });

    render();
    requestAnimationFrame(loop);
})();
</script>
