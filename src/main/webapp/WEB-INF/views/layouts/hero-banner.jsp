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

/* ---------- Ảnh giày thật ---------- */
.spn-shoe {
    position: absolute;
    left: 68%;                       /* JS đổi vị trí ngang theo từng mặt */
    top: 50%;
    width: min(700px, 52vw);
    aspect-ratio: 952 / 503;         /* tỉ lệ ảnh shoe-right.png (rộng / cao); đổi nếu ảnh của anh khác tỉ lệ */
    transform: translate(-50%, -50%);
    perspective: 1600px;
    z-index: 2;
}

.spn-img {
    position: absolute;
    inset: 0;
    width: 100%;
    height: 100%;
    object-fit: contain;
    user-select: none;
    -webkit-user-drag: none;
    will-change: transform, filter;
}

.spn-floor {
    position: absolute;
    left: 6%;
    right: 6%;
    bottom: -2%;
    height: 36px;
    border-radius: 50%;
    background: radial-gradient(ellipse at center, rgba(0, 0, 0, .8), transparent 70%);
    filter: blur(6px);
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

<!-- ===== 1. HERO: CUỘN ĐỂ XOAY GIÀY ===== -->
<section class="spn" id="spn" aria-label="Giới thiệu giày, cuộn trang để xoay">
    <div class="spn-stage">

        <div class="spn-shoe" id="spnShoe">
            <div class="spn-floor" id="spnFloor"></div>
            <img class="spn-img" id="spnImgA" src="${ctx}/static/assets/images/shoe-right.png" alt="Giày sneaker" draggable="false">
            <img class="spn-img" id="spnImgB" alt="" aria-hidden="true" draggable="false" style="visibility:hidden">
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
    var imgA = document.getElementById('spnImgA');
    var imgB = document.getElementById('spnImgB');
    var floor = document.getElementById('spnFloor');
    var panels = [].slice.call(root.querySelectorAll('.spn-panel'));
    var ticks = [].slice.call(root.querySelectorAll('.spn-tick'));
    var hint = document.getElementById('spnHint');

    // ====== CHỈNH Ở ĐÂY ======
    // --- Nguồn ảnh ---
    // Cách 1 (đơn giản): ảnh giày đã TÁCH NỀN (PNG trong suốt). RIGHT = giày quay mặt phải, LEFT = mặt trái.
    // Chưa có ảnh mặt trái thì để LEFT = '' , em tự lật ngược ảnh RIGHT để xem thử.
    var IMG_RIGHT = '${ctx}/static/assets/images/shoe-right.png';
    var IMG_LEFT  = '';
    // Cách 2 (mượt nhất): bộ ảnh xoay 360° đã tách nền. Đặt SEQ_COUNT > 0 để dùng, ví dụ 36 ảnh:
    //   static/assets/images/spin/shoe-000.webp ... shoe-035.webp  (ảnh 000 = giày quay mặt phải, xoay đều cả vòng)
    var SEQ_DIR = '${ctx}/static/assets/images/spin/shoe-';
    var SEQ_EXT = 'webp';
    var SEQ_COUNT = 0;

    // Góc xoay cho 3 mặt: hơi chéo -> mặt phải -> mặt trái (xoay thêm 180°)
    var ANGLES = [-20, 0, 180];
    var SHIFT  = [70, 70, 32];     // vị trí ngang của giày (% chiều rộng); mặt trái dạt sang trái nhường chữ bên phải
    // Đoạn cuộn "đứng yên" ở mỗi mặt (0..1); giữa các đoạn là lúc giày xoay
    var HOLDS  = [[0, .14], [.36, .64], [.86, 1]];
    var SMOOTH = .10;              // nhỏ = trễ mượt hơn, lớn = bám sát tay cuộn
    // =========================

    // Chuẩn bị ảnh
    var seqMode = SEQ_COUNT > 0;
    var seqFrames = [];
    if (seqMode) {
        for (var n = 0; n < SEQ_COUNT; n++) {
            var im = new Image();
            im.src = SEQ_DIR + ('00' + n).slice(-3) + '.' + SEQ_EXT;
            seqFrames.push(im.src);
        }
        imgA.src = seqFrames[0];
        imgB.style.display = 'none';
    } else if (IMG_LEFT) {
        imgB.src = IMG_LEFT;
    } else {
        imgB.src = IMG_RIGHT;      // dùng ảnh phải, lật gương làm mặt trái
    }

    function drawShoe(theta) {
        floor.style.transform = 'scaleX(' + (.45 + .55 * Math.abs(Math.cos(theta * Math.PI / 180))).toFixed(3) + ')';

        if (seqMode) {
            var d = ((theta % 360) + 360) % 360;
            var idx = Math.round(d / 360 * SEQ_COUNT) % SEQ_COUNT;
            if (imgA.getAttribute('data-i') != idx) { imgA.src = seqFrames[idx]; imgA.setAttribute('data-i', idx); }
            return;
        }

        // 2 ảnh: ảnh phải quay dần tới cạnh (90°) rồi ảnh trái quay từ cạnh ra, như một vòng xoay
        var onB = theta > 90;
        var local = onB ? theta - 180 : theta;                 // -90..90
        var dim = 1 - .4 * Math.abs(Math.sin(local * Math.PI / 180));
        var f = 'drop-shadow(0 30px 40px rgba(0,0,0,.55)) brightness(' + dim.toFixed(3) + ')';
        var el = onB ? imgB : imgA, other = onB ? imgA : imgB;
        other.style.visibility = 'hidden';
        el.style.visibility = 'visible';
        el.style.filter = f;
        el.style.transform = (onB && !IMG_LEFT ? 'rotateY(' + local + 'deg) scaleX(-1)' : 'rotateY(' + local + 'deg)');
    }

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

        drawShoe(theta);

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
