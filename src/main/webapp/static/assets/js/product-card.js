// Thẻ sản phẩm: rê chuột ra thì ảnh sáng lại bằng vòng tròn lan ra từ chỗ chuột rời thẻ
(function () {
    var cards = document.querySelectorAll('.p-card');
    if (!cards.length) return;

    // Máy cảm ứng không có "rê chuột" nên bỏ qua
    if (window.matchMedia && !window.matchMedia('(hover: hover)').matches) return;

    cards.forEach(function (card) {
        card.addEventListener('mouseenter', function () {
            clearTimeout(card._leaveTimer);
            card.classList.remove('is-leave');
        });

        card.addEventListener('mouseleave', function (e) {
            var box = card.getBoundingClientRect();
            var x = Math.max(0, Math.min(box.width,  e.clientX - box.left));
            var y = Math.max(0, Math.min(box.height, e.clientY - box.top));
            card.style.setProperty('--cx', x + 'px');
            card.style.setProperty('--cy', y + 'px');

            card.classList.remove('is-leave');
            void card.offsetWidth;              // chạy lại animation
            card.classList.add('is-leave');

            clearTimeout(card._leaveTimer);
            card._leaveTimer = setTimeout(function () { card.classList.remove('is-leave'); }, 800);
        });
    });
})();