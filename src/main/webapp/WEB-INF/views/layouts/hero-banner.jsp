<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />

<%--
    HERO XOAY GIÀY THEO CUỘN TRANG
    Đặt ở: /WEB-INF/views/layouts/hero-spin.jsp
    Gọi:   <jsp:include page="/WEB-INF/views/layouts/hero-spin.jsp"/>

    ĐỔI GIÀY: tải file .glb của shop về, để ở static/assets/models/shoe.glb rồi sửa thuộc tính src bên dưới.
    (src hiện tại là giày mẫu của model-viewer để xem thử hiệu ứng.)
--%>

<style>
html { overflow-x: clip; }

.hs {
    --hs-top: 108px;                 /* = chiều cao header (header sticky 108px; màn nhỏ 84px) */
    --ink: #0e0906;
    --accent: #F7941D;
    --line: rgba(255, 255, 255, .16);
    --mute: rgba(255, 255, 255, .66);
    position: relative;
    height: 460vh;                   /* độ dài đoạn cuộn: tăng thì xoay chậm hơn */
    width: 100vw;
    margin-left: calc(50% - 50vw);   /* tràn hết chiều ngang, thoát khỏi khung container */
    background: var(--ink);
    color: #fff;
}

.hs-stage {
    position: sticky;
    top: var(--hs-top);
    height: calc(100vh - var(--hs-top));
    min-height: 560px;
    overflow: hidden;
    background:
        radial-gradient(60% 55% at 50% 58%, rgba(247, 148, 29, .20), transparent 72%),
        var(--ink);
}

/* vạch sáng ngang nền giày, như mặt sàn phòng chụp */
.hs-stage::before {
    content: "";
    position: absolute;
    left: 0;
    right: 0;
    top: 74%;
    height: 1px;
    background: var(--line);
}

/* ---------- Giày ---------- */
.hs-model {
    position: absolute;
    left: 50%;
    top: 0;
    width: min(980px, 96vw);
    height: 100%;
    transform: translateX(-50%);
    --poster-color: transparent;
    background: transparent;
    z-index: 2;
    outline: none;
}

.hs-fallback {
    display: none;
    position: absolute;
    left: 50%;
    top: 50%;
    width: min(620px, 80vw);
    transform: translate(-50%, -50%);
    z-index: 2;
    will-change: transform;
}

.hs.no3d .hs-model    { display: none; }
.hs.no3d .hs-fallback { display: block; }

/* ---------- Chữ quảng cáo ---------- */
.hs-panel {
    position: absolute;
    z-index: 3;
    opacity: 0;
    will-change: opacity, transform;
    pointer-events: none;
}

.hs-panel.on { pointer-events: auto; }

.hs-p0 { left: 6vw; bottom: 12%; max-width: 640px; }
.hs-p1 { left: 6vw; top: 16%; width: min(360px, 34vw); }
.hs-p2 { right: 6vw; top: 16%; width: min(360px, 34vw); }

.hs-title {
    margin: 0 0 14px;
    font-size: clamp(40px, 6.4vw, 92px);
    line-height: .98;
    font-weight: 900;
    letter-spacing: -2px;
}

.hs-title em {
    font-style: normal;
    color: var(--accent);
}

.hs-h {
    margin: 0 0 14px;
    font-size: clamp(28px, 3.2vw, 46px);
    line-height: 1.05;
    font-weight: 900;
    letter-spacing: -1px;
}

.hs-sub {
    margin: 0 0 22px;
    max-width: 440px;
    font-size: 15px;
    line-height: 1.65;
    color: var(--mute);
}

.hs-small {
    margin: 0 0 12px;
    font-size: 14px;
    font-weight: 700;
    color: var(--accent);
}

.hs-spec {
    list-style: none;
    margin: 0 0 24px;
    padding: 0;
    border-top: 1px solid var(--line);
}

.hs-spec li {
    display: flex;
    justify-content: space-between;
    gap: 16px;
    padding: 12px 0;
    border-bottom: 1px solid var(--line);
    font-size: 14px;
    color: var(--mute);
}

.hs-spec b {
    color: #fff;
    font-weight: 700;
    text-align: right;
}

.hs-btn {
    display: inline-flex;
    align-items: center;
    gap: 10px;
    height: 52px;
    padding: 0 28px;
    border: 0;
    border-radius: 0;
    background: var(--accent);
    color: #1a0d03;
    font-weight: 800;
    font-size: 14px;
    transition: background .2s, transform .2s;
}

.hs-btn:hover { background: #ffad4d; transform: translateX(4px); }

.hs-btn.line {
    background: transparent;
    color: #fff;
    border: 1px solid var(--line);
    margin-left: 10px;
}

.hs-btn.line:hover { background: rgba(255, 255, 255, .08); transform: none; }

.hs-btn:focus-visible,
.hs-tick:focus-visible {
    outline: 3px solid #fff;
    outline-offset: 3px;
}

/* ---------- Góc xoay hiện số thật ---------- */
.hs-angle {
    position: absolute;
    z-index: 4;
    left: 6vw;
    top: 24px;
    font-size: 13px;
    color: var(--mute);
    font-variant-numeric: tabular-nums;
}

.hs-angle b {
    display: block;
    font-size: 40px;
    line-height: 1;
    font-weight: 900;
    color: #fff;
    letter-spacing: -1px;
}

/* ---------- Thanh tiến trình bên phải: 3 mặt, bấm để nhảy tới ---------- */
.hs-rail {
    position: absolute;
    z-index: 4;
    right: 24px;
    top: 50%;
    transform: translateY(-50%);
    display: flex;
    flex-direction: column;
    gap: 18px;
    align-items: flex-end;
}

.hs-tick {
    display: flex;
    align-items: center;
    gap: 12px;
    padding: 0;
    border: 0;
    background: none;
    color: var(--mute);
    font-family: inherit;
    font-size: 12.5px;
    font-weight: 700;
    cursor: pointer;
}

.hs-tick i {
    display: block;
    width: 26px;
    height: 2px;
    background: var(--line);
    transition: width .3s, background .3s;
}

.hs-tick.on { color: #fff; }
.hs-tick.on i { width: 54px; background: var(--accent); }

/* ---------- Gợi ý cuộn ---------- */
.hs-hint {
    position: absolute;
    z-index: 4;
    left: 50%;
    bottom: 22px;
    transform: translateX(-50%);
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 8px;
    font-size: 12.5px;
    color: var(--mute);
    transition: opacity .3s;
}

.hs-hint::after {
    content: "";
    width: 1px;
    height: 34px;
    background: linear-gradient(var(--accent), transparent);
    animation: hs-drip 1.6s ease-in infinite;
    transform-origin: top;
}

@keyframes hs-drip {
    0%   { transform: scaleY(0); opacity: 1; }
    70%  { transform: scaleY(1); opacity: 1; }
    100% { transform: scaleY(1); opacity: 0; }
}

/* ---------- Màn hình nhỏ ---------- */
@media (max-width: 900px) {
    .hs { --hs-top: 84px; height: 420vh; }
    .hs-model { top: -4%; height: 66%; }
    .hs-stage::before { top: 58%; }

    .hs-p0,
    .hs-p1,
    .hs-p2 {
        left: 20px;
        right: 20px;
        top: auto;
        bottom: 56px;
        width: auto;
        max-width: none;
    }

    .hs-title { font-size: 40px; letter-spacing: -1px; }
    .hs-h { font-size: 28px; }
    .hs-sub { font-size: 14px; margin-bottom: 16px; }
    .hs-spec { display: none; }
    .hs-btn { height: 46px; padding: 0 20px; }
    .hs-rail { display: none; }
    .hs-angle { left: 20px; top: 14px; }
    .hs-angle b { font-size: 28px; }
}

@media (prefers-reduced-motion: reduce) {
    .hs-hint::after { animation: none; }
    .hs-btn { transition: none; }
}
</style>

<!-- ===== 1. HERO: CUỘN ĐỂ XOAY GIÀY ===== -->
<section class="hs" id="hs" aria-label="Giới thiệu giày, cuộn trang để xoay">
    <div class="hs-stage">

        <div class="hs-angle" aria-hidden="true">Góc xoay<b id="hsAngle">000°</b></div>

        <%-- Giày 3D. Muốn dùng giày của shop: đổi src thành ${ctx}/static/assets/models/shoe.glb --%>
        <model-viewer class="hs-model" id="hsModel"
            src="https://modelviewer.dev/shared-assets/models/MaterialsVariantsShoe.glb"
            alt="Giày sneaker xoay 3D"
            camera-orbit="0deg 75deg 125%"
            field-of-view="28deg"
            interpolation-decay="60"
            exposure="1.05"
            shadow-intensity="1.2"
            shadow-softness=".8"
            environment-image="neutral"
            disable-zoom disable-pan disable-tap
            interaction-prompt="none">
        </model-viewer>

        <%-- Dự phòng khi không tải được 3D: ảnh giày xoay lật --%>
        <img class="hs-fallback" id="hsFallback" src="${ctx}/static/assets/images/Banner_QuangCao_Giay.png" alt="Poly Amber Soft Runner" onerror="this.style.display='none'">

        <%-- Mặt 1: chính diện --%>
        <div class="hs-panel hs-p0" data-from="up">
            <p class="hs-small">PolySneaker · Bộ sưu tập Spring 25</p>
            <h2 class="hs-title">Nâng niu <em>từng bước chân.</em></h2>
            <p class="hs-sub">Sneaker phong cách Nhật – Hàn: thoáng khí, êm ái, thanh lịch cho mỗi ngày năng động.</p>
            <a href="${ctx}/shop" class="hs-btn">Khám phá bộ sưu tập</a>
            <a href="${ctx}/lookbooks" class="hs-btn line">Xem LookBook</a>
        </div>

        <%-- Mặt 2: mặt phải --%>
        <div class="hs-panel hs-p1" data-from="left">
            <p class="hs-small">Mặt phải</p>
            <h3 class="hs-h">Đế êm như bước trên mây.</h3>
            <p class="hs-sub">Đệm khí thoáng, giảm lực chấn động cho mỗi bước đi, từ sáng đến tối.</p>
            <ul class="hs-spec">
                <li>Đệm đế <b>Khí êm ái</b></li>
                <li>Thân giày <b>Lưới thoáng khí</b></li>
                <li>Ưu đãi mùa này <b>Tiết kiệm 850.000đ</b></li>
            </ul>
            <a href="${ctx}/shop" class="hs-btn">Mua ngay</a>
        </div>

        <%-- Mặt 3: mặt trái --%>
        <div class="hs-panel hs-p2" data-from="right">
            <p class="hs-small">Mặt trái</p>
            <h3 class="hs-h">Form ôm chân người Việt.</h3>
            <p class="hs-sub">Mũi giày rộng vừa đủ, không cấn ngón út. Chưa vừa thì đổi size tận nhà trong 30 ngày.</p>
            <ul class="hs-spec">
                <li>Chính hãng <b>100% ủy quyền</b></li>
                <li>Đổi trả <b>30 ngày</b></li>
                <li>Giao hàng <b>Nhanh trong 2 giờ</b></li>
            </ul>
            <a href="${ctx}/shop" class="hs-btn">Chọn size của bạn</a>
        </div>

        <div class="hs-rail" role="tablist" aria-label="Chọn mặt giày">
            <button type="button" class="hs-tick on" data-go="0.02"><span>Chính diện</span><i></i></button>
            <button type="button" class="hs-tick" data-go="0.5"><span>Mặt phải</span><i></i></button>
            <button type="button" class="hs-tick" data-go="0.97"><span>Mặt trái</span><i></i></button>
        </div>

        <div class="hs-hint" id="hsHint">Cuộn xuống để xoay giày</div>
    </div>
</section>

<script type="module" src="https://ajax.googleapis.com/ajax/libs/model-viewer/4.0.0/model-viewer.min.js"></script>
<script>
(function () {
    var root = document.getElementById('hs');
    if (!root) return;

    var stage = root.querySelector('.hs-stage');
    var mv = document.getElementById('hsModel');
    var fb = document.getElementById('hsFallback');
    var panels = [].slice.call(root.querySelectorAll('.hs-panel'));
    var ticks = [].slice.call(root.querySelectorAll('.hs-tick'));
    var angleEl = document.getElementById('hsAngle');
    var hint = document.getElementById('hsHint');

    // ====== CHỈNH Ở ĐÂY ======
    // Góc xoay (độ) cho 3 mặt: chính diện -> mặt phải -> mặt trái (cách nhau 180°).
    // Nếu giày xoay ngược hướng hoặc mặt "phải/trái" bị lệch, đổi số này (vd: [0, -90, -270]).
    var ANGLES = [0, 90, 270];
    var PHI    = [75, 82, 82];     // góc nhìn từ trên xuống
    var RAD    = [125, 100, 100];  // độ gần (%, nhỏ hơn = zoom gần hơn)
    // Đoạn cuộn "đứng yên" ở mỗi mặt (0..1); giữa các đoạn là lúc giày xoay
    var HOLDS  = [[0, .14], [.36, .64], [.86, 1]];
    var SMOOTH = .10;              // 0.05 trễ mượt hơn, 0.3 bám sát hơn
    // =========================

    function clamp(v, a, b) { return Math.max(a, Math.min(b, v)); }
    function lerp(a, b, t) { return a + (b - a) * t; }
    function ease(t) { return t < .5 ? 4 * t * t * t : 1 - Math.pow(-2 * t + 2, 3) / 2; }

    // p (0..1) -> vị trí giữa các mặt k (0..2)
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

        if (root.classList.contains('no3d')) {
            fb.style.transform = 'translate(-50%,-50%) perspective(900px) rotateY(' + (theta / 270 * 180) + 'deg)';
        } else if (mv) {
            mv.cameraOrbit = theta + 'deg ' + mix(PHI, k) + 'deg ' + mix(RAD, k) + '%';
        }

        var deg = Math.round(((theta % 360) + 360) % 360);
        angleEl.textContent = ('00' + deg).slice(-3) + '°';

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

    // Bấm vào thanh bên phải: cuộn thẳng tới mặt đó
    ticks.forEach(function (t) {
        t.addEventListener('click', function () {
            var top = parseFloat(getComputedStyle(stage).top) || 0;
            var total = root.offsetHeight - stage.offsetHeight;
            var y = root.getBoundingClientRect().top + window.pageYOffset - top + total * parseFloat(t.getAttribute('data-go'));
            window.scrollTo({ top: y, behavior: 'smooth' });
        });
    });

    // Không tải được 3D (mất mạng, bị chặn CDN...) -> chuyển sang ảnh dự phòng
    function useFallback() { root.classList.add('no3d'); last = -1; }
    if (mv) mv.addEventListener('error', useFallback);
    setTimeout(function () {
        if (!window.customElements || !customElements.get('model-viewer')) useFallback();
    }, 6000);

    render();
    requestAnimationFrame(loop);
})();
</script>
