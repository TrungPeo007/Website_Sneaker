/* =====================================================
   product-detail.js - Trang chi tiết sản phẩm PolySneaker
   ===================================================== */
(function () {
    /* ---------- Thư viện ảnh ---------- */

    var thumbs = Array.prototype.slice.call(document.querySelectorAll('.pd-thumb'));
    var list = document.getElementById('pdThumbList');
    var mainBox = document.getElementById('pdMainBox');
    var mainImg = document.getElementById('pdMain');
    var countEl = document.getElementById('pdCount');
    var idx = 0;

    // Cuộn riêng trong cột ảnh nhỏ, không làm cả trang bị nhảy
    function revealThumb(t) {
        if (!list || !t) return;
        var vertical = getComputedStyle(list).flexDirection === 'column';
        var start = vertical ? t.offsetTop - list.offsetTop : t.offsetLeft - list.offsetLeft;
        var size = vertical ? t.offsetHeight : t.offsetWidth;
        var view = vertical ? list.clientHeight : list.clientWidth;
        var cur = vertical ? list.scrollTop : list.scrollLeft;
        var target = cur;
        if (start < cur) target = start;
        else if (start + size > cur + view) target = start + size - view;
        if (vertical) list.scrollTop = target; else list.scrollLeft = target;
    }

    function selectImage(i) {
        if (!thumbs.length || !mainImg) return;
        idx = (i + thumbs.length) % thumbs.length;
        thumbs.forEach(function (t, k) { t.classList.toggle('on', k === idx); });
        mainImg.style.display = '';
        mainBox.classList.remove('noimg');
        mainImg.src = thumbs[idx].getAttribute('data-src');
        if (countEl) countEl.textContent = (idx + 1) + ' / ' + thumbs.length;
        revealThumb(thumbs[idx]);
    }

    thumbs.forEach(function (t, k) { t.addEventListener('click', function () { selectImage(k); }); });

    function bind(id, step) {
        var el = document.getElementById(id);
        if (el) el.addEventListener('click', function () { selectImage(idx + step); });
    }
    bind('pdPrev', -1);
    bind('pdNext', 1);
    bind('pdMainPrev', -1);
    bind('pdMainNext', 1);

    if (thumbs.length > 1) {
        // Phím ← →
        document.addEventListener('keydown', function (e) {
            var tag = (e.target && e.target.tagName) || '';
            if (tag === 'INPUT' || tag === 'TEXTAREA' || tag === 'SELECT') return;
            if (e.key === 'ArrowLeft') selectImage(idx - 1);
            else if (e.key === 'ArrowRight') selectImage(idx + 1);
        });

        // Vuốt trái/phải trên điện thoại
        var sx = null;
        mainBox.addEventListener('touchstart', function (e) { sx = e.touches[0].clientX; }, { passive: true });
        mainBox.addEventListener('touchend', function (e) {
            if (sx === null) return;
            var dx = e.changedTouches[0].clientX - sx;
            sx = null;
            if (Math.abs(dx) > 40) selectImage(idx + (dx < 0 ? 1 : -1));
        });
    }

    /* ---------- Chọn size / số lượng ---------- */
    var info = document.getElementById('pdInfo');
    var sizeBox = document.getElementById('pdSizes');
    var sizeBtns = Array.prototype.slice.call(sizeBox.querySelectorAll('.pd-size'));
    var sizeLabel = document.getElementById('pdSizeSel');
    var stockEl = document.getElementById('pdStock');
    var qtyEl = document.getElementById('pdQty');
    var msgEl = document.getElementById('pdMsg');
    var selected = null;   // { size: '42', stock: 10 }

    function setMsg(text, type) {
        msgEl.textContent = text || '';
        msgEl.className = 'pd-msg' + (type ? ' ' + type : '');
    }

    function maxQty() { return selected ? Math.max(1, selected.stock) : 99; }

    function clampQty() {
        var v = parseInt(qtyEl.value, 10);
        if (isNaN(v) || v < 1) v = 1;
        if (v > maxQty()) v = maxQty();
        qtyEl.value = v;
        return v;
    }

    sizeBtns.forEach(function (btn) {
        btn.addEventListener('click', function () {
            sizeBtns.forEach(function (b) { b.classList.remove('on'); });
            btn.classList.add('on');
            selected = { size: btn.getAttribute('data-size'), stock: parseInt(btn.getAttribute('data-stock'), 10) || 0 };
            sizeLabel.textContent = '(Size ' + selected.size + ')';
            if (selected.stock <= 5) {
                stockEl.textContent = 'Chỉ còn ' + selected.stock + ' sản phẩm ở size này.';
                stockEl.className = 'pd-stock warn';
            } else {
                stockEl.textContent = 'Còn ' + selected.stock + ' sản phẩm.';
                stockEl.className = 'pd-stock';
            }
            clampQty();
            setMsg('');
        });
    });

    document.getElementById('pdMinus').addEventListener('click', function () { qtyEl.value = (parseInt(qtyEl.value, 10) || 1) - 1; clampQty(); });
    document.getElementById('pdPlus').addEventListener('click', function () { qtyEl.value = (parseInt(qtyEl.value, 10) || 1) + 1; clampQty(); });
    qtyEl.addEventListener('change', clampQty);

    /* ---------- Thông báo nhỏ ---------- */
    var toastEl = document.getElementById('pdToast');
    var toastTimer;
    function toast(text, isErr) {
        toastEl.textContent = text;
        toastEl.className = 'pd-toast show' + (isErr ? ' err' : '');
        clearTimeout(toastTimer);
        toastTimer = setTimeout(function () { toastEl.className = 'pd-toast'; }, 2400);
    }

    /* ---------- Thêm vào giỏ hàng ----------
       TẠM THỜI: lưu giỏ vào trình duyệt (localStorage) để thử giao diện.
       Khi làm giỏ hàng thật, chỉ cần thay thân hàm addToCart bằng
       fetch(ctx + '/cart/add', { method: 'POST', ... }). */
    var CART_KEY = 'polysneaker_cart';

    function addToCart(item) {
        try {
            var cart = JSON.parse(localStorage.getItem(CART_KEY) || '[]');
            var found = null;
            cart.forEach(function (c) { if (c.productId === item.productId && c.size === item.size) found = c; });
            if (found) {
                found.qty = Math.min(found.qty + item.qty, item.stock);
            } else {
                cart.push(item);
            }
            localStorage.setItem(CART_KEY, JSON.stringify(cart));
            document.dispatchEvent(new CustomEvent('cart:changed', { detail: cart }));
            return true;
        } catch (e) {
            return false;
        }
    }

    document.getElementById('pdAdd').addEventListener('click', function () {
        if (!selected) {
            setMsg('Vui lòng chọn size trước khi thêm vào giỏ hàng.', 'err');
            sizeBox.classList.remove('shake');
            void sizeBox.offsetWidth;   // chạy lại hiệu ứng rung
            sizeBox.classList.add('shake');
            return;
        }
        var qty = clampQty();
        var ok = addToCart({
            productId: parseInt(info.getAttribute('data-id'), 10),
            name: info.getAttribute('data-name'),
            image: info.getAttribute('data-image'),
            price: Number(info.getAttribute('data-price')),
            size: selected.size,
            qty: qty,
            stock: selected.stock
        });
        if (ok) {
            setMsg('Đã thêm ' + qty + ' sản phẩm (size ' + selected.size + ') vào giỏ hàng.', 'ok');
            if (window.PolyCart) { window.PolyCart.open(); } else { toast('Đã thêm vào giỏ hàng'); }
        } else {
            setMsg('Không thêm được vào giỏ hàng, vui lòng thử lại.', 'err');
            toast('Không thêm được vào giỏ hàng', true);
        }
    });

    /* ---------- Thẻ sản phẩm gợi ý: bấm để xem chi tiết ---------- */
    document.querySelectorAll('.p-card[data-href]').forEach(function (card) {
        card.addEventListener('click', function (e) {
            if (e.target.closest('button, a')) return;
            window.location.href = card.getAttribute('data-href');
        });
    });
})();


/* =====================================================
   MÔ TẢ SẢN PHẨM - phong cách tạp chí
   ===================================================== */
(function () {
    var sec = document.getElementById('pdDescSec');
    if (!sec) return;

    /* Hiện khi cuộn tới */
    if ('IntersectionObserver' in window) {
        var io = new IntersectionObserver(function (es) {
            es.forEach(function (e) {
                if (e.isIntersecting) { e.target.classList.add('in'); io.unobserve(e.target); }
            });
        }, { threshold: 0.12 });
        io.observe(sec);
    } else {
        sec.classList.add('in');
    }

    /* Chữ nền trôi nhẹ khi cuộn (parallax) */
    var ghost = document.getElementById('pdGhost');
    var reduce = window.matchMedia && matchMedia('(prefers-reduced-motion: reduce)').matches;
    if (ghost && !reduce) {
        var ticking = false;
        window.addEventListener('scroll', function () {
            if (ticking) return;
            ticking = true;
            requestAnimationFrame(function () {
                var r = sec.getBoundingClientRect();
                var p = (window.innerHeight - r.top) / (window.innerHeight + r.height);
                p = Math.max(0, Math.min(1, p));
                ghost.style.transform = 'translateX(' + ((0.5 - p) * 120) + 'px)';
                ticking = false;
            });
        }, { passive: true });
    }

    var raw   = document.getElementById('pdDescRaw');
    var body  = document.getElementById('pdDescBody');
    var lead  = document.getElementById('pdLead');
    var specs = document.getElementById('pdSpecs');
    var paras = document.getElementById('pdParas');
    var btn   = document.getElementById('pdDescToggle');
    if (!raw || !body) return;

    /* Tách mô tả: dòng bắt đầu bằng - • * => thông số; còn lại => văn bản */
    var lines = raw.textContent.replace(/\r/g, '').split('\n');
    var textLines = [], items = [];

    lines.forEach(function (ln) {
        var t = ln.trim();
        if (!t) return;
        var m = t.match(/^[-•*–]\s*(.+)$/);
        if (m) {
            var kv = m[1].match(/^([^:]{2,28}):\s*(.+)$/);
            items.push(kv ? { k: kv[1], v: kv[2] } : { k: '', v: m[1] });
        } else {
            textLines.push(t);
        }
    });

    /* Câu dẫn = dòng chữ đầu tiên */
    if (textLines.length) lead.textContent = textLines.shift();
    else lead.style.display = 'none';

    /* Bảng thông số đánh số */
    if (items.length) {
        items.forEach(function (it, i) {
            var row = document.createElement('div');
            row.className = 'pd-spec';
            row.style.setProperty('--i', i);

            var n = document.createElement('em');
            n.textContent = (i + 1 < 10 ? '0' : '') + (i + 1);
            row.appendChild(n);

            if (it.k) {
                var k = document.createElement('b');
                k.textContent = it.k;
                row.appendChild(k);
            } else {
                row.classList.add('nokey');
            }
            var v = document.createElement('span');
            v.textContent = it.v;
            row.appendChild(v);
            specs.appendChild(row);
        });
    } else {
        specs.style.display = 'none';
    }

    /* Các đoạn còn lại */
    if (textLines.length) {
        textLines.forEach(function (t, i) {
            var p = document.createElement('p');
            p.style.setProperty('--i', i);
            p.textContent = t;
            paras.appendChild(p);
        });
    } else {
        paras.style.display = 'none';
    }

    raw.style.display = 'none';
    body.classList.add('ready');

    /* Xem thêm / Thu gọn */
    var LIMIT = 340;   // px, chiều cao khi thu gọn

    function setup() {
        if (body.classList.contains('open')) return;
        if (body.scrollHeight > LIMIT + 60) {
            body.classList.add('clamp');
            body.style.maxHeight = LIMIT + 'px';
            btn.hidden = false;
        }
    }

    btn.addEventListener('click', function () {
        var open = !body.classList.contains('open');
        body.classList.toggle('open', open);
        body.classList.toggle('clamp', !open);
        body.style.maxHeight = open ? body.scrollHeight + 'px' : LIMIT + 'px';
        btn.classList.toggle('open', open);
        btn.querySelector('.pd-more-txt').textContent = open ? 'Thu gọn' : 'Xem thêm';
        if (!open) sec.scrollIntoView({ behavior: 'smooth', block: 'start' });
    });

    setup();
    window.addEventListener('load', setup);
})();