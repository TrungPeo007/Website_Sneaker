/* Giỏ hàng trượt từ bên phải.
   - Đọc giỏ từ localStorage ('polysneaker_cart') do trang chi tiết sản phẩm ghi vào.
   - Cập nhật số trên icon giỏ hàng ở header.
   - Vẽ danh sách sản phẩm trong ngăn kéo, cho tăng/giảm/xóa.
   Sau này làm giỏ hàng thật (server) thì chỉ cần thay read() và write(). */
(function () {
    'use strict';

    var KEY = 'polysneaker_cart';

    var drawer = document.getElementById('cartDrawer');
    if (!drawer) return;

    var overlay  = document.getElementById('cartOverlay');
    var toggle   = document.getElementById('cartToggle');
    var closeBtn = document.getElementById('cartClose');
    var contBtn  = document.getElementById('cartContinue');
    var titleEl  = document.getElementById('cartTitle');
    var listEl   = document.getElementById('cartList');
    var totalEl  = document.getElementById('cartTotal');
    var badge    = document.getElementById('cartBadge');
    var ctx      = drawer.getAttribute('data-ctx') || '';
    var lastFocus = null;

    var nf = new Intl.NumberFormat('vi-VN');
    function money(n) { return nf.format(n || 0) + '₫'; }

    /* ---------- Dữ liệu giỏ ---------- */
    function read() {
        try {
            var raw = JSON.parse(localStorage.getItem(KEY) || '[]');
            if (!Array.isArray(raw)) return [];
            return raw.map(function (c) {
                return {
                    productId: parseInt(c.productId, 10) || 0,
                    name: String(c.name || ''),
                    image: String(c.image || ''),
                    price: Number(c.price) || 0,
                    size: String(c.size || ''),
                    qty: Math.max(1, parseInt(c.qty, 10) || 1),
                    stock: parseInt(c.stock, 10) || 0
                };
            });
        } catch (e) {
            return [];
        }
    }

    function write(cart) {
        try { localStorage.setItem(KEY, JSON.stringify(cart)); } catch (e) { /* bỏ qua */ }
        document.dispatchEvent(new CustomEvent('cart:changed', { detail: cart }));
    }

    function indexOf(cart, id, size) {
        for (var i = 0; i < cart.length; i++) {
            if (cart[i].productId === id && cart[i].size === size) return i;
        }
        return -1;
    }

    function changeQty(id, size, delta) {
        var cart = read();
        var i = indexOf(cart, id, size);
        if (i < 0) return;
        var max = cart[i].stock > 0 ? cart[i].stock : 99;
        cart[i].qty = Math.min(max, Math.max(1, cart[i].qty + delta));
        write(cart);
    }

    function removeItem(id, size) {
        var cart = read();
        var i = indexOf(cart, id, size);
        if (i < 0) return;
        cart.splice(i, 1);
        write(cart);
    }

    /* ---------- Vẽ giao diện ---------- */
    function el(tag, cls, text) {
        var e = document.createElement(tag);
        if (cls) e.className = cls;
        if (text != null) e.textContent = text;
        return e;
    }

    function safeSrc(s) {
        return /^(https?:\/\/|\/(?!\/))/.test(s);
    }

    function buildItem(c) {
        var li = el('li', 'cart-item');

        var thumb = el('div', 'cart-thumb');
        if (safeSrc(c.image)) {
            var img = document.createElement('img');
            img.src = c.image;
            img.alt = '';
            img.onerror = function () { img.style.display = 'none'; };
            thumb.appendChild(img);
        }
        li.appendChild(thumb);

        var info = el('div', 'cart-info');

        var name = el('a', 'cart-name', c.name);
        name.href = ctx + '/products/' + c.productId;
        info.appendChild(name);
        info.appendChild(el('div', 'cart-size', 'Size ' + c.size));

        var row = el('div', 'cart-row');

        var qty = el('div', 'cart-qty');
        var minus = el('button', null, '−');
        minus.type = 'button';
        minus.setAttribute('aria-label', 'Giảm số lượng');
        minus.addEventListener('click', function () { changeQty(c.productId, c.size, -1); });
        var num = el('span', null, String(c.qty));
        var plus = el('button', null, '+');
        plus.type = 'button';
        plus.setAttribute('aria-label', 'Tăng số lượng');
        plus.addEventListener('click', function () { changeQty(c.productId, c.size, 1); });
        qty.appendChild(minus);
        qty.appendChild(num);
        qty.appendChild(plus);
        row.appendChild(qty);

        row.appendChild(el('div', 'cart-price', money(c.price * c.qty)));
        info.appendChild(row);

        var del = el('button', 'cart-del', 'Xóa');
        del.type = 'button';
        del.addEventListener('click', function () { removeItem(c.productId, c.size); });
        info.appendChild(del);

        li.appendChild(info);
        return li;
    }

    function render() {
        var cart = read();
        var count = 0, total = 0;
        cart.forEach(function (c) { count += c.qty; total += c.qty * c.price; });

        badge.textContent = count > 99 ? '99+' : String(count);
        badge.classList.toggle('is-empty', count === 0);
        titleEl.textContent = 'Giỏ Hàng (' + count + ')';
        totalEl.textContent = money(total);
        drawer.classList.toggle('has-items', cart.length > 0);

        listEl.textContent = '';
        cart.forEach(function (c) { listEl.appendChild(buildItem(c)); });
    }

    /* ---------- Mở / đóng ---------- */
    function open() {
        if (drawer.classList.contains('open')) return;
        render();
        lastFocus = document.activeElement;
        drawer.classList.add('open');
        overlay.classList.add('open');
        drawer.setAttribute('aria-hidden', 'false');
        document.body.classList.add('cart-open');
        if (toggle) toggle.setAttribute('aria-expanded', 'true');
        setTimeout(function () { closeBtn.focus(); }, 60);
    }

    function close() {
        if (!drawer.classList.contains('open')) return;
        drawer.classList.remove('open');
        overlay.classList.remove('open');
        drawer.setAttribute('aria-hidden', 'true');
        document.body.classList.remove('cart-open');
        if (toggle) toggle.setAttribute('aria-expanded', 'false');
        if (lastFocus && lastFocus.focus) lastFocus.focus();
    }

    if (toggle) toggle.addEventListener('click', open);
    closeBtn.addEventListener('click', close);
    overlay.addEventListener('click', close);
    if (contBtn) contBtn.addEventListener('click', close);
    document.addEventListener('keydown', function (e) {
        if (e.key === 'Escape') close();
    });

    // Giỏ đổi (trang chi tiết thêm hàng, hoặc tab khác sửa giỏ) -> cập nhật số + danh sách
    document.addEventListener('cart:changed', render);
    window.addEventListener('storage', function (e) { if (e.key === KEY) render(); });
    window.addEventListener('pageshow', render);   // quay lại bằng nút Back

    window.PolyCart = { open: open, close: close };
    render();
})();