/* =====================================================
   shop.js - Trang danh sách sản phẩm PolySneaker
   ===================================================== */

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

// Sắp xếp + lọc (size, giá, giảm giá) ngay trên trang
(function () {
    var grid = document.getElementById('shopGrid');
    var sortEl = document.getElementById('sbSort');
    if (!grid || !sortEl) return;               // không có sản phẩm thì không có thanh lọc

    var layout = document.getElementById('shopLayout');
    var side = document.getElementById('shopSide');
    var minEl = document.getElementById('sbMin');
    var maxEl = document.getElementById('sbMax');
    var saleEl = document.getElementById('sbSale');
    var resetBtn = document.getElementById('sbReset');
    var countEl = document.getElementById('sbCount');
    var noneEl = document.getElementById('sbNone');
    var chips = Array.prototype.slice.call(document.querySelectorAll('.sb-chip'));
    var cards = Array.prototype.slice.call(grid.querySelectorAll('.p-card'));
    var total = cards.length;

    var flToggle = document.getElementById('flToggle');
    var flBody = document.getElementById('flBody');
    var flList = document.getElementById('flList');
    var flBadge = document.getElementById('flBadge');
    var flClear = document.getElementById('flClear');
    var selSizes = [];                           // các size đang tick, dạng chuỗi: ['40', '42.5']

    cards.forEach(function (c, i) {
        c._i = i;
        c._id = Number(c.getAttribute('data-id')) || 0;
        c._price = Number(c.getAttribute('data-price')) || 0;
        c._rating = Number(c.getAttribute('data-rating')) || 0;
        c._reviews = Number(c.getAttribute('data-reviews')) || 0;
        c._discount = Number(c.getAttribute('data-discount')) || 0;
        c._name = c.getAttribute('data-name') || '';
        c._sizes = (c.getAttribute('data-sizes') || '').split(',').filter(function (s) { return s !== ''; });
    });

    /* ---------- Dựng danh sách size từ các sản phẩm ---------- */
    var sizeCount = {};
    cards.forEach(function (c) {
        c._sizes.forEach(function (s) { sizeCount[s] = (sizeCount[s] || 0) + 1; });
    });
    var allSizes = Object.keys(sizeCount).sort(function (a, b) { return parseFloat(a) - parseFloat(b); });

    if (!allSizes.length) {
        // Chưa sản phẩm nào có size còn hàng -> bỏ cột lọc size
        if (side) side.hidden = true;
        layout.classList.add('no-side');
    } else {
        allSizes.forEach(function (s) {
            var label = document.createElement('label');
            label.className = 'fl-item';
            var cb = document.createElement('input');
            cb.type = 'checkbox';
            cb.value = s;
            var name = document.createElement('span');
            name.textContent = s;
            var cnt = document.createElement('small');
            cnt.textContent = sizeCount[s];
            label.appendChild(cb);
            label.appendChild(name);
            label.appendChild(cnt);
            flList.appendChild(label);
        });

        flList.addEventListener('change', function () {
            selSizes = Array.prototype.slice.call(flList.querySelectorAll('input:checked'))
                .map(function (i) { return i.value; });
            apply();
        });

        flClear.addEventListener('click', function () {
            setSizes([]);
            apply();
        });

        flToggle.addEventListener('click', function () {
            var open = flToggle.getAttribute('aria-expanded') !== 'true';
            flToggle.setAttribute('aria-expanded', open ? 'true' : 'false');
            flBody.hidden = !open;
        });
    }

    function setSizes(list) {
        selSizes = list.slice();
        Array.prototype.slice.call(flList.querySelectorAll('input')).forEach(function (i) {
            i.checked = selSizes.indexOf(i.value) !== -1;
        });
    }

    /* ---------- Sắp xếp ---------- */
    var sorters = {
        'default': function (a, b) { return a._i - b._i; },
        'newest': function (a, b) { return (b._id - a._id) || (a._i - b._i); },
        'price-asc': function (a, b) { return (a._price - b._price) || (a._i - b._i); },
        'price-desc': function (a, b) { return (b._price - a._price) || (a._i - b._i); },
        'name-asc': function (a, b) { return a._name.localeCompare(b._name, 'vi') || (a._i - b._i); },
        'rating': function (a, b) { return (b._rating - a._rating) || (b._reviews - a._reviews) || (a._i - b._i); },
        'discount': function (a, b) { return (b._discount - a._discount) || (a._i - b._i); }
    };

    function num(el) {
        var v = String(el.value).trim();
        if (v === '') return null;
        var n = Number(v);
        return isFinite(n) ? Math.max(0, n) : null;
    }

    function chipNum(v) {
        return (v === '' || v === null || v === undefined) ? null : Number(v);
    }

    // Từ lớn hơn Đến thì đổi chỗ cho hai ô
    function fixRange() {
        var lo = num(minEl), hi = num(maxEl);
        if (lo !== null && hi !== null && lo > hi) {
            minEl.value = hi;
            maxEl.value = lo;
        }
    }

    function syncUrl(sort, lo, hi, saleOnly) {
        var q = new URLSearchParams(window.location.search);
        if (sort !== 'default') q.set('sort', sort); else q.delete('sort');
        if (lo !== null) q.set('min', lo); else q.delete('min');
        if (hi !== null) q.set('max', hi); else q.delete('max');
        if (saleOnly) q.set('sale', '1'); else q.delete('sale');
        if (selSizes.length) q.set('size', selSizes.join(',')); else q.delete('size');
        var qs = q.toString();
        try {
            history.replaceState(null, '', window.location.pathname + (qs ? '?' + qs : '') + window.location.hash);
        } catch (e) { /* trình duyệt không cho đổi địa chỉ thì bỏ qua */ }
    }

    /* ---------- Áp dụng bộ lọc ---------- */
    function apply() {
        var sort = sortEl.value;
        var lo = num(minEl), hi = num(maxEl);
        var saleOnly = saleEl.checked;
        var shown = 0;

        cards.forEach(function (c) {
            var okSize = selSizes.length === 0 || c._sizes.some(function (s) { return selSizes.indexOf(s) !== -1; });
            var ok = okSize
                && (lo === null || c._price >= lo)
                && (hi === null || c._price <= hi)
                && (!saleOnly || c._discount > 0);
            c.hidden = !ok;
            if (ok) shown++;
        });

        // Xếp lại thứ tự thẻ (thẻ giữ nguyên nên nút tim và click vẫn chạy)
        cards.slice().sort(sorters[sort] || sorters['default']).forEach(function (c) {
            grid.insertBefore(c, noneEl);
        });

        noneEl.hidden = shown > 0;
        countEl.innerHTML = (shown === total)
            ? '<b>' + total + '</b> sản phẩm'
            : 'Hiển thị <b>' + shown + '</b> / ' + total + ' sản phẩm';

        chips.forEach(function (ch) {
            var on = chipNum(ch.getAttribute('data-min')) === lo
                && chipNum(ch.getAttribute('data-max')) === hi;
            ch.classList.toggle('on', on);
        });

        if (flBadge) {
            flBadge.textContent = selSizes.length;
            flBadge.hidden = selSizes.length === 0;
            flClear.hidden = selSizes.length === 0;
        }

        resetBtn.hidden = !(lo !== null || hi !== null || saleOnly || sort !== 'default' || selSizes.length);
        syncUrl(sort, lo, hi, saleOnly);
    }

    sortEl.addEventListener('change', apply);
    saleEl.addEventListener('change', apply);

    [minEl, maxEl].forEach(function (el) {
        el.addEventListener('change', function () { fixRange(); apply(); });
        el.addEventListener('keydown', function (e) {
            if (e.key === 'Enter') { e.preventDefault(); fixRange(); apply(); }
        });
    });

    chips.forEach(function (ch) {
        ch.addEventListener('click', function () {
            if (ch.classList.contains('on')) {
                minEl.value = '';
                maxEl.value = '';
            } else {
                minEl.value = ch.getAttribute('data-min');
                maxEl.value = ch.getAttribute('data-max');
            }
            apply();
        });
    });

    resetBtn.addEventListener('click', function () {
        sortEl.value = 'default';
        minEl.value = '';
        maxEl.value = '';
        saleEl.checked = false;
        setSizes([]);
        apply();
    });

    /* ---------- Đọc bộ lọc từ địa chỉ trang ---------- */
    var q = new URLSearchParams(window.location.search);
    if (sorters[q.get('sort')]) sortEl.value = q.get('sort');
    var qMin = Number(q.get('min')), qMax = Number(q.get('max'));
    if (q.get('min') && isFinite(qMin) && qMin >= 0) minEl.value = qMin;
    if (q.get('max') && isFinite(qMax) && qMax >= 0) maxEl.value = qMax;
    saleEl.checked = q.get('sale') === '1';
    if (q.get('size')) {
        setSizes(q.get('size').split(',').filter(function (s) { return sizeCount[s]; }));
    }
    fixRange();

    // Màn hình nhỏ thì thu gọn khung size cho đỡ chiếm chỗ (trừ khi đang lọc theo size)
    if (allSizes.length && window.matchMedia('(max-width: 900px)').matches && !selSizes.length) {
        flToggle.setAttribute('aria-expanded', 'false');
        flBody.hidden = true;
    }

    apply();
})();