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