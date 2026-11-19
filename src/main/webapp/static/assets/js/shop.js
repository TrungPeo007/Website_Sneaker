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

    var reduce = window.matchMedia && matchMedia('(prefers-reduced-motion: reduce)').matches;
    var EASE = 'cubic-bezier(.2,.8,.2,1)';

    var layout = document.getElementById('shopLayout');
    var side = document.getElementById('shopSide');
    var minEl = document.getElementById('sbMin');
    var maxEl = document.getElementById('sbMax');
    var saleEl = document.getElementById('sbSale');
    var resetBtn = document.getElementById('sbReset');
    var countEl = document.getElementById('sbCount');
    var noneEl = document.getElementById('sbNone');
    var tagsEl = document.getElementById('sbTags');
    var lineEl = document.getElementById('sbLine');
    var sliderEl = document.getElementById('sbSlider');
    var sLo = document.getElementById('sbLo');
    var sHi = document.getElementById('sbHi');
    var readoutEl = document.getElementById('sbReadout');
    var chips = Array.prototype.slice.call(document.querySelectorAll('.sb-chip'));
    var cards = Array.prototype.slice.call(grid.querySelectorAll('.p-card'));
    var total = cards.length;

    var flToggle = document.getElementById('flToggle');
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

    function fmt(n) {
        return Number(n).toLocaleString('vi-VN') + '₫';
    }

    /* ---------- Ô "Sắp xếp" tuỳ biến (thay cho danh sách mặc định của trình duyệt) ---------- */
    var ddWrap = document.createElement('div');
    ddWrap.className = 'dd';

    var ddBtn = document.createElement('button');
    ddBtn.type = 'button';
    ddBtn.className = 'dd-btn';
    ddBtn.setAttribute('aria-haspopup', 'listbox');
    ddBtn.setAttribute('aria-expanded', 'false');
    ddBtn.setAttribute('aria-label', 'Sắp xếp sản phẩm');
    var ddVal = document.createElement('span');
    ddVal.className = 'dd-val';
    var ddIco = document.createElement('i');
    ddIco.className = 'dd-ico';
    ddBtn.appendChild(ddVal);
    ddBtn.appendChild(ddIco);

    var ddMenu = document.createElement('ul');
    ddMenu.className = 'dd-menu';
    ddMenu.setAttribute('role', 'listbox');
    ddMenu.setAttribute('aria-label', 'Sắp xếp sản phẩm');

    var ddAct = 0;
    var ddItems = Array.prototype.slice.call(sortEl.options).map(function (o, i) {
        var li = document.createElement('li');
        li.className = 'dd-opt';
        li.id = 'ddo' + i;
        li.setAttribute('role', 'option');
        li.setAttribute('data-value', o.value);
        li.style.setProperty('--i', i);
        var em = document.createElement('em');
        em.textContent = (i + 1 < 10 ? '0' : '') + (i + 1);
        var sp = document.createElement('span');
        sp.textContent = o.textContent;
        var u = document.createElement('u');
        li.appendChild(em);
        li.appendChild(sp);
        li.appendChild(u);
        li.addEventListener('mouseenter', function () { ddSetActive(i); });
        li.addEventListener('click', function () { ddChoose(i); });
        ddMenu.appendChild(li);
        return li;
    });

    ddWrap.appendChild(ddBtn);
    ddWrap.appendChild(ddMenu);
    sortEl.classList.add('dd-native');
    sortEl.tabIndex = -1;
    sortEl.setAttribute('aria-hidden', 'true');
    sortEl.parentNode.insertBefore(ddWrap, sortEl.nextSibling);

    function ddIndex() {
        for (var i = 0; i < ddItems.length; i++) {
            if (ddItems[i].getAttribute('data-value') === sortEl.value) return i;
        }
        return 0;
    }

    function ddSetActive(i) {
        ddAct = i;
        ddItems.forEach(function (li, k) { li.classList.toggle('act', k === i); });
        ddBtn.setAttribute('aria-activedescendant', 'ddo' + i);
    }

    function ddOpen() {
        ddWrap.classList.add('open');
        ddBtn.setAttribute('aria-expanded', 'true');
        ddSetActive(ddIndex());
    }

    function ddClose() {
        if (!ddWrap.classList.contains('open')) return;
        ddWrap.classList.remove('open');
        ddBtn.setAttribute('aria-expanded', 'false');
        ddItems.forEach(function (li) { li.classList.remove('act'); });
    }

    function ddChoose(i) {
        var v = ddItems[i].getAttribute('data-value');
        ddClose();
        if (sortEl.value !== v) {
            sortEl.value = v;
            sortEl.dispatchEvent(new Event('change'));
        }
    }

    // Cập nhật chữ trên nút + dấu chọn theo giá trị hiện tại của select
    function syncSortUI() {
        var idx = ddIndex();
        ddVal.innerHTML = '';
        var n = document.createElement('em');
        n.textContent = ddItems[idx].firstChild.textContent;
        ddVal.appendChild(n);
        ddVal.appendChild(document.createTextNode(ddItems[idx].children[1].textContent));
        ddItems.forEach(function (li, k) {
            li.classList.toggle('on', k === idx);
            li.setAttribute('aria-selected', k === idx ? 'true' : 'false');
        });
        ddBtn.classList.toggle('set', sortEl.value !== 'default');
        ddVal.classList.remove('bump');
        void ddVal.offsetWidth;          // chạy lại hiệu ứng đổi chữ
        ddVal.classList.add('bump');
    }

    ddBtn.addEventListener('click', function () {
        if (ddWrap.classList.contains('open')) ddClose(); else ddOpen();
    });

    ddBtn.addEventListener('keydown', function (e) {
        var open = ddWrap.classList.contains('open');
        var n = ddItems.length;
        if (e.key === 'ArrowDown' || e.key === 'ArrowUp') {
            e.preventDefault();
            if (!open) { ddOpen(); return; }
            ddSetActive((ddAct + (e.key === 'ArrowDown' ? 1 : -1) + n) % n);
        } else if (e.key === 'Home' && open) {
            e.preventDefault(); ddSetActive(0);
        } else if (e.key === 'End' && open) {
            e.preventDefault(); ddSetActive(n - 1);
        } else if ((e.key === 'Enter' || e.key === ' ') && open) {
            e.preventDefault(); ddChoose(ddAct);
        } else if (e.key === 'Escape' && open) {
            e.preventDefault(); ddClose();
        } else if (e.key === 'Tab' && open) {
            ddClose();
        }
    });

    document.addEventListener('click', function (e) {
        if (!ddWrap.contains(e.target)) ddClose();
    });

    /* ---------- Thanh trượt giá: mốc cao nhất lấy theo sản phẩm thật ---------- */
    var priceMax = 0;
    cards.forEach(function (c) { if (c._price > priceMax) priceMax = c._price; });
    priceMax = Math.ceil(priceMax / 100000) * 100000;
    if (priceMax <= 0) priceMax = 1000000;
    sLo.max = priceMax;
    sHi.max = priceMax;

    function syncSlider(lo, hi) {
        var a = lo === null ? 0 : Math.min(lo, priceMax);
        var b = hi === null ? priceMax : Math.min(hi, priceMax);
        sLo.value = a;
        sHi.value = b;
        sliderEl.style.setProperty('--a', (a / priceMax * 100) + '%');
        sliderEl.style.setProperty('--b', (b / priceMax * 100) + '%');
        // Hai núm chồng nhau ở cuối thì núm "từ" nổi lên để còn kéo được
        sLo.style.zIndex = a > priceMax / 2 ? 3 : 2;
        sHi.style.zIndex = a > priceMax / 2 ? 2 : 3;
        readoutEl.innerHTML = '<b>' + fmt(a) + '</b><i></i><b>' + fmt(b) + (b >= priceMax ? '+' : '') + '</b>';
    }

    function onSlide(which) {
        var lo = Number(sLo.value), hi = Number(sHi.value);
        if (which === 'lo' && lo > hi) { lo = hi; sLo.value = lo; }
        if (which === 'hi' && hi < lo) { hi = lo; sHi.value = hi; }
        minEl.value = lo > 0 ? lo : '';
        maxEl.value = hi < priceMax ? hi : '';
        apply();
    }
    sLo.addEventListener('input', function () { onSlide('lo'); });
    sHi.addEventListener('input', function () { onSlide('hi'); });

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
        allSizes.forEach(function (s, i) {
            var label = document.createElement('label');
            label.className = 'fl-item';
            label.style.setProperty('--i', i);
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
            Array.prototype.slice.call(flList.querySelectorAll('input')).forEach(function (i) {
                i.parentNode.classList.toggle('on', i.checked);
            });
            apply();
        });

        flClear.addEventListener('click', function () {
            setSizes([]);
            apply();
        });

        flToggle.addEventListener('click', function () {
            var open = flToggle.getAttribute('aria-expanded') !== 'true';
            flToggle.setAttribute('aria-expanded', open ? 'true' : 'false');
        });
    }

    function setSizes(list) {
        selSizes = list.slice();
        Array.prototype.slice.call(flList.querySelectorAll('input')).forEach(function (i) {
            var on = selSizes.indexOf(i.value) !== -1;
            i.checked = on;
            i.parentNode.classList.toggle('on', on);
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

    /* ---------- Hiệu ứng thẻ: trượt về vị trí mới (FLIP) + hiện dần thẻ mới ---------- */
    var canAnimate = !reduce && typeof Element.prototype.animate === 'function' && total <= 80;

    function capture() {
        var map = new Map();
        if (!canAnimate) return map;
        cards.forEach(function (c) { if (!c.hidden) map.set(c, c.getBoundingClientRect()); });
        return map;
    }

    function play(first, initial) {
        if (!canAnimate) return;
        var enter = 0;
        cards.forEach(function (c) {
            if (c.hidden) return;
            var f = first.get(c);
            if (f && !initial) {
                var l = c.getBoundingClientRect();
                var dx = f.left - l.left, dy = f.top - l.top;
                if (dx || dy) {
                    c.animate(
                        [{ transform: 'translate(' + dx + 'px,' + dy + 'px)' }, { transform: 'none' }],
                        { duration: 520, easing: EASE }
                    );
                }
            } else {
                c.animate(
                    [{ opacity: 0, transform: 'translateY(26px) scale(.96)' }, { opacity: 1, transform: 'none' }],
                    { duration: 560, delay: Math.min(enter++, 12) * 45, easing: EASE, fill: 'backwards' }
                );
            }
        });
    }

    /* ---------- Số đếm chạy ---------- */
    var shownNow = total, countTok = 0;
    function tweenCount(b, from, to) {
        var tok = ++countTok;
        if (!b || reduce || from === to) { if (b) b.textContent = to; return; }
        var t0 = performance.now(), dur = 420;
        (function step(t) {
            if (tok !== countTok) return;
            var k = Math.min(1, (t - t0) / dur);
            b.textContent = Math.round(from + (to - from) * (1 - Math.pow(1 - k, 3)));
            if (k < 1) requestAnimationFrame(step);
        })(t0);
    }

    /* ---------- Thẻ "đang lọc": bấm để gỡ ---------- */
    var tagMap = {};
    function renderTags(lo, hi, saleOnly) {
        if (!tagsEl) return;
        var want = [];

        selSizes.forEach(function (s) {
            want.push({
                key: 'size-' + s, text: 'Size ' + s,
                off: function () { setSizes(selSizes.filter(function (x) { return x !== s; })); apply(); }
            });
        });
        if (lo !== null || hi !== null) {
            var t = (lo !== null && hi !== null) ? fmt(lo) + ' – ' + fmt(hi)
                : (lo !== null ? 'Từ ' + fmt(lo) : 'Đến ' + fmt(hi));
            want.push({ key: 'price', text: t, off: function () { minEl.value = ''; maxEl.value = ''; apply(); } });
        }
        if (saleOnly) {
            want.push({ key: 'sale', text: 'Đang giảm giá', off: function () { saleEl.checked = false; apply(); } });
        }

        var keys = {};
        want.forEach(function (w) {
            keys[w.key] = true;
            var el = tagMap[w.key];
            if (!el) {
                el = document.createElement('button');
                el.type = 'button';
                el.className = 'sb-tag';
                el.setAttribute('aria-label', 'Gỡ bộ lọc ' + w.text);
                var sp = document.createElement('span');
                var x = document.createElement('i');
                el.appendChild(sp);
                el.appendChild(x);
                tagsEl.appendChild(el);
                tagMap[w.key] = el;
            }
            el.firstChild.textContent = w.text;
            el.onclick = w.off;
        });

        Object.keys(tagMap).forEach(function (k) {
            if (keys[k]) return;
            var el = tagMap[k];
            delete tagMap[k];
            el.classList.add('out');
            el.onclick = null;
            setTimeout(function () { if (el.parentNode) el.parentNode.removeChild(el); }, 260);
        });

        if (want.length) {
            tagsEl.hidden = false;
        } else {
            setTimeout(function () { if (!Object.keys(tagMap).length) tagsEl.hidden = true; }, 270);
        }
    }

    /* ---------- Áp dụng bộ lọc ---------- */
    function apply(initial) {
        var sort = sortEl.value;
        var lo = num(minEl), hi = num(maxEl);
        var saleOnly = saleEl.checked;
        var shown = 0;

        syncSortUI();
        var first = capture();

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
        play(first, initial);

        countEl.innerHTML = (shown === total)
            ? '<b>' + total + '</b> sản phẩm'
            : 'Hiển thị <b>' + shown + '</b> / ' + total + ' sản phẩm';
        tweenCount(countEl.querySelector('b'), shownNow, shown);
        shownNow = shown;

        if (lineEl) lineEl.style.transform = 'scaleX(' + (total ? shown / total : 1) + ')';

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

        syncSlider(lo, hi);
        renderTags(lo, hi, saleOnly);

        resetBtn.hidden = !(lo !== null || hi !== null || saleOnly || sort !== 'default' || selSizes.length);
        syncUrl(sort, lo, hi, saleOnly);
    }

    sortEl.addEventListener('change', function () { apply(); });
    saleEl.addEventListener('change', function () { apply(); });

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
    }

    apply(true);
})();