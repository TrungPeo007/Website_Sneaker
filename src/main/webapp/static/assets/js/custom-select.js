/* =====================================================================
   custom-select.js
   Thay khung xổ xuống mặc định của trình duyệt bằng khung riêng
   (bo góc, đổ bóng, hiệu ứng mở, tick màu cam...).

   - Thẻ <select> gốc vẫn còn (ẩn đi) và vẫn là nơi giữ giá trị,
     nên form gửi dữ liệu y hệt như cũ, không cần sửa controller.
   - Tự áp dụng cho MỌI <select> trong trang. Muốn giữ kiểu mặc định
     cho ô nào thì thêm thuộc tính data-native vào thẻ <select> đó.
   - Hỗ trợ bàn phím: ↑ ↓ Enter Space Esc Home End, gõ chữ để nhảy tới mục.
   ===================================================================== */
(function () {
    'use strict';

    if (window.CustomSelect) return;

    var css = `
.cs { position: relative; width: 100%; }

/* Thẻ select gốc: ẩn nhưng vẫn nằm đúng chỗ để trình duyệt báo lỗi "bắt buộc chọn" */
.cs-native {
    position: absolute !important;
    left: 0 !important;
    top: 0 !important;
    width: 100% !important;
    height: 100% !important;
    margin: 0 !important;
    padding: 0 !important;
    border: 0 !important;
    opacity: 0 !important;
    pointer-events: none !important;
}

.cs-btn {
    width: 100%;
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 10px;
    padding: 11px 14px;
    border-radius: 12px;
    border: 1.5px solid var(--cream-border, #F3E3C3);
    background: var(--cream, #FFF6E3);
    font-family: inherit;
    font-size: 14px;
    color: var(--text, #3B2412);
    text-align: left;
    cursor: pointer;
    outline: none;
    transition: border-color .2s, background .2s, box-shadow .25s cubic-bezier(.22,.8,.3,1);
}

.cs-btn:hover { border-color: #F3C98B; }

.cs.open .cs-btn,
.cs-btn:focus-visible {
    border-color: var(--orange, #F7941D);
    background: #fff;
    box-shadow: 0 0 0 4px rgba(247, 148, 29, .15);
}

.cs-label {
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
}

.cs-btn.is-placeholder .cs-label { color: #BFA784; }

.cs-arrow {
    flex-shrink: 0;
    width: 16px;
    height: 16px;
    color: var(--orange, #F7941D);
    transition: transform .3s cubic-bezier(.22,.8,.3,1);
}

.cs.open .cs-arrow { transform: rotate(180deg); }

.cs.cs-invalid .cs-btn {
    border-color: var(--danger, #D64514);
    box-shadow: 0 0 0 4px rgba(214, 69, 20, .1);
}

.cs.disabled .cs-btn { opacity: .65; cursor: not-allowed; }

/* Nâng cả ô lên trên các ô bên dưới khi đang mở danh sách */
.cs-host-open { position: relative; z-index: 40; }

/* Khung danh sách */
.cs-list {
    position: absolute;
    left: 0;
    right: 0;
    top: calc(100% + 6px);
    z-index: 50;
    margin: 0;
    padding: 6px;
    list-style: none;
    max-height: 260px;
    overflow-y: auto;
    background: #fff;
    border: 1.5px solid var(--cream-border, #F3E3C3);
    border-radius: 14px;
    box-shadow: 0 18px 40px rgba(122, 78, 24, .16);
    scrollbar-width: thin;
    scrollbar-color: #F3C98B transparent;
    transform-origin: top center;
    visibility: hidden;
    opacity: 0;
    transform: translateY(-6px) scale(.98);
    pointer-events: none;
    transition: opacity .18s, transform .22s cubic-bezier(.22,.8,.3,1), visibility 0s .22s;
}

.cs.up .cs-list {
    top: auto;
    bottom: calc(100% + 6px);
    transform-origin: bottom center;
    transform: translateY(6px) scale(.98);
}

.cs.open .cs-list {
    visibility: visible;
    opacity: 1;
    transform: none;
    pointer-events: auto;
    transition-delay: 0s;
}

.cs-opt {
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 10px;
    padding: 10px 12px;
    border-radius: 10px;
    font-size: 14px;
    color: var(--text, #3B2412);
    cursor: pointer;
    transition: background .15s, color .15s, padding .2s cubic-bezier(.22,.8,.3,1);
}

.cs-opt.is-active { background: var(--cream, #FFF6E3); padding-left: 16px; }

.cs-opt.is-selected {
    background: #FFF3DC;
    color: var(--amber, #C46A00);
    font-weight: 800;
}

.cs-opt.is-selected::after {
    content: "\\2713";
    color: var(--orange, #F7941D);
    font-weight: 800;
}

.cs-opt.is-placeholder { color: #BFA784; }
.cs-opt.is-disabled { opacity: .45; cursor: not-allowed; }

@media (prefers-reduced-motion: reduce) {
    .cs *, .cs-list { transition: none !important; }
}
`;

    var styleEl = document.createElement('style');
    styleEl.id = 'custom-select-style';
    styleEl.textContent = css;
    document.head.appendChild(styleEl);

    var counter = 0;

    function enhance(select) {
        if (!select || select.getAttribute('data-cs-done')) return;
        if (select.multiple || select.hasAttribute('data-native')) return;
        select.setAttribute('data-cs-done', '1');
        counter++;

        var wrap = document.createElement('div');
        wrap.className = 'cs';
        select.parentNode.insertBefore(wrap, select);
        wrap.appendChild(select);
        select.classList.add('cs-native');
        select.tabIndex = -1;

        var btn = document.createElement('button');
        btn.type = 'button';
        btn.className = 'cs-btn';
        btn.setAttribute('aria-haspopup', 'listbox');
        btn.setAttribute('aria-expanded', 'false');

        var label = document.createElement('span');
        label.className = 'cs-label';
        btn.appendChild(label);
        btn.insertAdjacentHTML('beforeend',
            '<svg class="cs-arrow" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" ' +
            'stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><polyline points="6 9 12 15 18 9"/></svg>');

        var list = document.createElement('ul');
        list.className = 'cs-list';
        list.setAttribute('role', 'listbox');
        list.id = (select.id || 'cs' + counter) + '-list';
        btn.setAttribute('aria-controls', list.id);

        wrap.appendChild(btn);
        wrap.appendChild(list);

        var host = wrap.parentElement;
        var items = [];
        var active = -1;
        var typed = '';
        var typedTimer = null;

        function build() {
            list.innerHTML = '';
            items = [];
            Array.prototype.forEach.call(select.options, function (o, i) {
                var li = document.createElement('li');
                li.className = 'cs-opt';
                li.setAttribute('role', 'option');
                li.setAttribute('data-index', i);
                li.textContent = o.textContent.trim();
                if (o.value === '') li.classList.add('is-placeholder');
                if (o.disabled) li.classList.add('is-disabled');
                list.appendChild(li);
                items.push(li);
            });
        }

        function sync() {
            var o = select.options[select.selectedIndex];
            label.textContent = o ? o.textContent.trim() : '';
            btn.classList.toggle('is-placeholder', !o || o.value === '');
            items.forEach(function (li, i) {
                var on = (i === select.selectedIndex);
                li.classList.toggle('is-selected', on);
                li.setAttribute('aria-selected', on ? 'true' : 'false');
            });
            btn.disabled = select.disabled;
            wrap.classList.toggle('disabled', select.disabled);
            if (o && o.value !== '') wrap.classList.remove('cs-invalid');
        }

        function setActive(i, scroll) {
            if (active >= 0 && items[active]) items[active].classList.remove('is-active');
            active = i;
            if (i >= 0 && items[i]) {
                items[i].classList.add('is-active');
                if (scroll) items[i].scrollIntoView({ block: 'nearest' });
            }
        }

        function isOpen() { return wrap.classList.contains('open'); }

        function open() {
            if (select.disabled || isOpen()) return;
            // Không đủ chỗ phía dưới thì mở lên phía trên
            var r = btn.getBoundingClientRect();
            var below = window.innerHeight - r.bottom;
            wrap.classList.toggle('up', below < 280 && r.top > below);
            wrap.classList.add('open');
            host.classList.add('cs-host-open');
            btn.setAttribute('aria-expanded', 'true');
            setActive(select.selectedIndex, true);
        }

        function close(focusBtn) {
            if (!isOpen()) return;
            wrap.classList.remove('open');
            host.classList.remove('cs-host-open');
            btn.setAttribute('aria-expanded', 'false');
            setActive(-1);
            if (focusBtn) btn.focus();
        }

        function choose(i) {
            var o = select.options[i];
            if (!o || o.disabled) return;
            var changed = (select.selectedIndex !== i);
            select.selectedIndex = i;
            if (changed) select.dispatchEvent(new Event('change', { bubbles: true }));
            sync();
            close(true);
        }

        function move(dir) {
            var i = active;
            do { i += dir; } while (i >= 0 && i < items.length && select.options[i].disabled);
            if (i >= 0 && i < items.length) setActive(i, true);
        }

        btn.addEventListener('click', function () {
            if (isOpen()) close(); else open();
        });

        list.addEventListener('mousedown', function (e) { e.preventDefault(); });
        list.addEventListener('mousemove', function (e) {
            var li = e.target.closest('.cs-opt');
            if (li) setActive(+li.getAttribute('data-index'));
        });
        list.addEventListener('click', function (e) {
            var li = e.target.closest('.cs-opt');
            if (li) choose(+li.getAttribute('data-index'));
        });

        btn.addEventListener('keydown', function (e) {
            var k = e.key;

            if (!isOpen()) {
                if (k === 'ArrowDown' || k === 'ArrowUp' || k === 'Enter' || k === ' ') {
                    e.preventDefault();
                    open();
                }
                return;
            }

            if (k === 'ArrowDown') { e.preventDefault(); move(1); }
            else if (k === 'ArrowUp') { e.preventDefault(); move(-1); }
            else if (k === 'Home') { e.preventDefault(); setActive(0, true); }
            else if (k === 'End') { e.preventDefault(); setActive(items.length - 1, true); }
            else if (k === 'Enter' || k === ' ') { e.preventDefault(); if (active >= 0) choose(active); }
            else if (k === 'Escape') { e.preventDefault(); close(true); }
            else if (k === 'Tab') { close(); }
            else if (k.length === 1) {
                // Gõ chữ để nhảy tới mục bắt đầu bằng chữ đó
                typed += k.toLowerCase();
                clearTimeout(typedTimer);
                typedTimer = setTimeout(function () { typed = ''; }, 700);
                for (var i = 0; i < items.length; i++) {
                    if (!select.options[i].disabled && items[i].textContent.toLowerCase().indexOf(typed) === 0) {
                        setActive(i, true);
                        break;
                    }
                }
            }
        });

        document.addEventListener('mousedown', function (e) {
            if (!wrap.contains(e.target)) close();
        });

        // Giá trị bị đổi từ nơi khác (reset form, code khác...) thì cập nhật lại nhãn
        select.addEventListener('change', sync);
        select.addEventListener('focus', function () { if (!select.disabled) btn.focus(); });
        select.addEventListener('invalid', function () { wrap.classList.add('cs-invalid'); });
        if (select.form) {
            select.form.addEventListener('reset', function () { setTimeout(sync, 0); });
        }

        build();
        sync();

        wrap._cs = { rebuild: function () { build(); sync(); } };
    }

    function enhanceAll(root) {
        Array.prototype.forEach.call((root || document).querySelectorAll('select'), enhance);
    }

    // Dùng khi JavaScript khác thêm/bớt <option> trong select lúc trang đang chạy
    function refresh(select) {
        var wrap = select && select.closest('.cs');
        if (wrap && wrap._cs) wrap._cs.rebuild();
    }

    window.CustomSelect = { enhance: enhance, enhanceAll: enhanceAll, refresh: refresh };
    enhanceAll(document);
})();