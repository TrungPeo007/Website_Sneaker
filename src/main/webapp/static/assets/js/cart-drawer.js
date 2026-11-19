/*
 * Giỏ hàng ngăn kéo bên phải (cart drawer) - PolySneaker.
 * Dùng giao diện ngăn kéo trong main.css (class .cart-*), dữ liệu thật lấy từ server qua /api/cart (không dùng localStorage).
 * Nếu header chưa có HTML ngăn kéo thì file này tự dựng, không cần thêm gì vào header.
 *
 * API công khai:  PSCart.open() / close() / refresh() / add(productId, size, qty) / addDetail(productDetailId, qty)
 * Sự kiện:        document 'pscart:change'  { detail: { count, subtotal } }
 * Mở ngăn kéo:    bấm nút có id="cartToggle" hoặc thuộc tính data-cart-open.
 */
(function () {
    'use strict';
    if (window.PSCart) return;

    // ---------- đường dẫn gốc (contextPath) ----------
    var script = document.currentScript;
    var ctx = '';
    if (script && script.getAttribute('data-ctx') !== null) {
        ctx = script.getAttribute('data-ctx');
    } else if (script && script.src) {
        try {
            ctx = new URL(script.src, location.href).pathname.replace(/\/static\/assets\/js\/cart-drawer\.js$/, '');
        } catch (e) { ctx = ''; }
    }

    var overlay, drawer, closeBtn, contBtn, titleEl, listEl, totalEl, checkoutBtn, badge;
    var lastFocus = null;
    var state = { items: [], count: 0, subtotal: 0 };

    // ---------- tiện ích ----------
    function el(tag, cls, text) {
        var e = document.createElement(tag);
        if (cls) e.className = cls;
        if (text !== undefined && text !== null) e.textContent = text;
        return e;
    }
    function money(n) { return Number(n).toLocaleString('vi-VN') + '₫'; }
    function canBuy(it) { return it.sellable && it.quantity <= it.stock; }

    // ---------- dựng ngăn kéo nếu header chưa có ----------
    function ensureDrawer() {
        if (!document.getElementById('cartDrawer')) {
            document.body.insertAdjacentHTML('beforeend',
                '<div class="cart-overlay" id="cartOverlay"></div>' +
                '<aside class="cart-drawer" id="cartDrawer" role="dialog" aria-modal="true" aria-labelledby="cartTitle" aria-hidden="true">' +
                '<div class="cart-head"><h2 class="cart-title" id="cartTitle">Giỏ Hàng (0)</h2>' +
                '<button type="button" class="cart-close" id="cartClose" aria-label="Đóng giỏ hàng">' +
                '<svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">' +
                '<line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg></button></div>' +
                '<div class="cart-body"><p class="cart-empty">Giỏ hàng của bạn đang trống.</p><ul class="cart-list" id="cartList"></ul></div>' +
                '<div class="cart-foot"><div class="cart-sum"><span>Tạm tính</span><b id="cartTotal">0₫</b></div>' +
                '<a href="#" class="cart-checkout">Thanh toán</a>' +
                '<button type="button" class="cart-continue" id="cartContinue">Tiếp tục mua sắm</button></div></aside>');
        }
        overlay = document.getElementById('cartOverlay');
        drawer = document.getElementById('cartDrawer');
        closeBtn = document.getElementById('cartClose');
        contBtn = document.getElementById('cartContinue');
        titleEl = document.getElementById('cartTitle');
        listEl = document.getElementById('cartList');
        totalEl = document.getElementById('cartTotal');
        badge = document.getElementById('cartBadge');
        checkoutBtn = drawer.querySelector('.cart-checkout');
    }

    // ---------- gọi server ----------
    function call(method, path, params, silent) {
        var opt = { method: method, credentials: 'same-origin', headers: { 'Accept': 'application/json' } };
        if (method === 'POST') opt.body = new URLSearchParams(params || {});
        var meta = document.querySelector('meta[name="_csrf"]');
        var metaH = document.querySelector('meta[name="_csrf_header"]');
        if (meta && metaH) opt.headers[metaH.getAttribute('content')] = meta.getAttribute('content');

        return fetch(ctx + path, opt)
            .then(function (r) { return r.json(); })
            .then(function (d) {
                if (d.login) {
                    if (!silent) location.href = ctx + '/login';
                    return d;
                }
                apply(d);
                return d;
            })
            .catch(function () {
                return { ok: false, message: 'Không kết nối được máy chủ' };
            });
    }

    function apply(d) {
        if (!d || !d.items) return;
        state.items = d.items;
        state.count = d.count || 0;
        state.subtotal = d.subtotal || 0;
        render();
        document.dispatchEvent(new CustomEvent('pscart:change', { detail: { count: state.count, subtotal: state.subtotal } }));
    }

    // ---------- vẽ một món hàng ----------
    function line(it) {
        var li = el('li', 'cart-item');

        var thumb = el('div', 'cart-thumb');
        if (it.image) {
            var img = el('img');
            img.src = it.image;
            img.alt = '';
            img.addEventListener('error', function () { img.style.display = 'none'; });
            thumb.appendChild(img);
        }

        var info = el('div', 'cart-info');
        var name = el('a', 'cart-name', it.name);
        name.href = ctx + '/products/' + it.productId;
        info.appendChild(name);
        info.appendChild(el('div', 'cart-size', 'Size ' + it.size));

        if (!it.sellable) {
            var w1 = el('div', 'cart-size', 'Sản phẩm này không còn bán');
            w1.style.color = '#C2410C';
            info.appendChild(w1);
        } else if (it.quantity > it.stock) {
            var w2 = el('div', 'cart-size', 'Chỉ còn ' + it.stock + ' đôi, hãy giảm số lượng');
            w2.style.color = '#C2410C';
            info.appendChild(w2);
        }

        var row = el('div', 'cart-row');
        var qty = el('div', 'cart-qty');
        var minus = el('button', null, '−');
        minus.type = 'button';
        minus.setAttribute('aria-label', 'Giảm số lượng');
        minus.disabled = it.quantity <= 1;
        minus.addEventListener('click', function () { setQty(it.id, it.quantity - 1); });
        var plus = el('button', null, '+');
        plus.type = 'button';
        plus.setAttribute('aria-label', 'Tăng số lượng');
        plus.disabled = it.quantity >= it.stock;
        plus.addEventListener('click', function () { setQty(it.id, it.quantity + 1); });
        qty.appendChild(minus);
        qty.appendChild(el('span', null, String(it.quantity)));
        qty.appendChild(plus);
        row.appendChild(qty);
        row.appendChild(el('span', 'cart-price', money(it.lineTotal)));
        info.appendChild(row);

        var del = el('button', 'cart-del', 'Xóa');
        del.type = 'button';
        del.addEventListener('click', function () { call('POST', '/api/cart/remove', { cartItemId: it.id }); });
        info.appendChild(del);

        li.appendChild(thumb);
        li.appendChild(info);
        return li;
    }

    // ---------- vẽ cả giỏ ----------
    function render() {
        if (!drawer) return;
        titleEl.textContent = 'Giỏ Hàng (' + state.count + ')';

        if (badge) {
            badge.textContent = state.count > 99 ? '99+' : state.count;
            badge.classList.toggle('is-empty', state.count === 0);
        }

        while (listEl.firstChild) listEl.removeChild(listEl.firstChild);
        drawer.classList.toggle('has-items', state.items.length > 0);

        var ids = [], total = 0;
        state.items.forEach(function (it) {
            listEl.appendChild(line(it));
            if (canBuy(it)) { ids.push(it.id); total += it.lineTotal; }
        });
        totalEl.textContent = money(total);

        // Nút Thanh toán đi thẳng tới trang thanh toán với các món mua được
        if (checkoutBtn) {
            if (ids.length) {
                checkoutBtn.href = ctx + '/checkout?items=' + ids.join(',');
                checkoutBtn.style.opacity = '';
                checkoutBtn.style.pointerEvents = '';
            } else {
                checkoutBtn.href = '#';
                checkoutBtn.style.opacity = '.5';
                checkoutBtn.style.pointerEvents = 'none';
            }
        }
    }

    function setQty(id, q) {
        call('POST', '/api/cart/update', { cartItemId: id, quantity: q });
    }

    // ---------- mở / đóng ----------
    function open() {
        lastFocus = document.activeElement;
        drawer.classList.add('open');
        overlay.classList.add('open');
        drawer.setAttribute('aria-hidden', 'false');
        document.body.classList.add('cart-open');
        var t = document.getElementById('cartToggle');
        if (t) t.setAttribute('aria-expanded', 'true');
        call('GET', '/api/cart');
        setTimeout(function () { if (closeBtn) closeBtn.focus(); }, 50);
    }

    function close() {
        drawer.classList.remove('open');
        overlay.classList.remove('open');
        drawer.setAttribute('aria-hidden', 'true');
        document.body.classList.remove('cart-open');
        var t = document.getElementById('cartToggle');
        if (t) t.setAttribute('aria-expanded', 'false');
        if (lastFocus && lastFocus.focus) lastFocus.focus();
    }

    function isOpen() { return drawer.classList.contains('open'); }

    // ---------- API công khai ----------
    function afterAdd(p) {
        return p.then(function (d) {
            if (d && d.ok) open();
            return d;
        });
    }

    window.PSCart = {
        open: function () { if (drawer) open(); },
        close: function () { if (drawer) close(); },
        refresh: function () { return call('GET', '/api/cart'); },
        add: function (productId, size, qty) {
            return afterAdd(call('POST', '/api/cart/add', { productId: productId, size: size, quantity: qty || 1 }));
        },
        addDetail: function (productDetailId, qty) {
            return afterAdd(call('POST', '/api/cart/add', { productDetailId: productDetailId, quantity: qty || 1 }));
        }
    };

    // ---------- trang chi tiết sản phẩm: bắt nút "Thêm vào giỏ hàng" ----------
    var pickedSize = null;
    document.addEventListener('click', function (e) {
        var sizeBtn = e.target.closest ? e.target.closest('.pd-size') : null;
        if (sizeBtn && !sizeBtn.disabled) pickedSize = sizeBtn.getAttribute('data-size');
    }, true);

    document.addEventListener('click', function (e) {
        var add = e.target.closest ? e.target.closest('#pdAdd') : null;
        if (!add) return;
        e.preventDefault();
        e.stopPropagation();

        var msg = document.getElementById('pdMsg');
        function say(t) {
            if (!msg) { alert(t); return; }
            msg.textContent = t;
            setTimeout(function () { if (msg.textContent === t) msg.textContent = ''; }, 3200);
        }
        var info = document.getElementById('pdInfo');
        var productId = info ? info.getAttribute('data-id') : null;
        if (!productId) { say('Không xác định được sản phẩm'); return; }
        if (!pickedSize) { say('Vui lòng chọn size trước khi thêm vào giỏ hàng'); return; }
        var q = parseInt((document.getElementById('pdQty') || {}).value, 10) || 1;

        window.PSCart.add(productId, pickedSize, q).then(function (d) {
            if (d && d.ok === false && !d.login && d.message) say(d.message);
        });
    }, true);

    // ---------- khởi động ----------
    function init() {
        ensureDrawer();

        // nút giỏ hàng ở header
        document.addEventListener('click', function (e) {
            var t = e.target.closest ? e.target.closest('#cartToggle, [data-cart-open]') : null;
            if (t && !t.closest('.cart-drawer')) { e.preventDefault(); e.stopPropagation(); open(); }
        }, true);

        overlay.addEventListener('click', close);
        if (closeBtn) closeBtn.addEventListener('click', close);
        if (contBtn) contBtn.addEventListener('click', close);
        document.addEventListener('keydown', function (e) {
            if (e.key === 'Escape' && isOpen()) close();
        });

        // đồng bộ số trên icon giỏ ngay khi tải trang (im lặng, không chuyển sang trang đăng nhập)
        call('GET', '/api/cart', null, true);
    }

    if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', init);
    else init();
})();