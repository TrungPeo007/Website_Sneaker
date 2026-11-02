<%@ page pageEncoding="UTF-8" %>
    <%-- Thanh bên trái của trang admin: logo, menu, đăng xuất. Mục sáng lên theo biến adminMenu --%>
        <aside class="side">
            <div class="side-brand">
                <span class="side-logo">PS</span>
                <div>
                    <div class="side-name">PolySneaker</div>
                    <div class="side-role">Quản trị viên</div>
                </div>
            </div>
            <nav class="side-nav">
                <a href="${ctx}/admin" class="${adminMenu == 'dashboard' ? 'active' : ''}">Tổng Quan</a>
                <a href="${ctx}/admin/banners" class="${adminMenu == 'banners' ? 'active' : ''}">Banner</a>
                <a href="${ctx}/admin/products" class="${adminMenu == 'products' ? 'active' : ''}">Sản Phẩm</a>
                <a href="${ctx}/admin/categories" class="${adminMenu == 'categories' ? 'active' : ''}">Danh Mục</a>
                <a href="${ctx}/admin/blogs" class="${adminMenu == 'blogs' ? 'active' : ''}">Bài Viết</a>
                <a href="${ctx}/admin/orders" class="${adminMenu == 'orders' ? 'active' : ''}">Đơn Hàng</a>
                <a href="${ctx}/admin/lookbooks" class="${adminMenu == 'lookbooks' ? 'active' : ''}">Bộ Sưu Tập</a>
                <a href="${ctx}/admin/pages" class="${adminMenu == 'pages' ? 'active' : ''}">Trang Nội Dung</a>
            </nav>
            <div class="side-foot">
                <a href="${ctx}/logout" id="logoutLink" class="logout-link">
                    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"
                        stroke-linecap="round" stroke-linejoin="round">
                        <path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4" />
                        <polyline points="16 17 21 12 16 7" />
                        <line x1="21" y1="12" x2="9" y2="12" />
                    </svg>
                    <span>Đăng xuất</span>
                </a>
            </div>
        </aside>

        <%-- Popup xác nhận đăng xuất --%>
            <div class="logout-modal" id="logoutModal" aria-hidden="true">
                <div class="logout-box" role="dialog" aria-modal="true" aria-labelledby="logoutTitle">
                    <div class="logout-icon">!</div>
                    <h3 id="logoutTitle">Đăng xuất?</h3>
                    <p>Bạn có chắc chắn muốn đăng xuất khỏi trang quản trị không?</p>
                    <div class="logout-actions">
                        <button type="button" class="logout-btn cancel" id="logoutCancel">Ở lại</button>
                        <a href="${ctx}/logout" class="logout-btn confirm">Đăng xuất</a>
                    </div>
                </div>
            </div>

            <style>
                .logout-modal {
                    position: fixed;
                    inset: 0;
                    z-index: 9999;
                    display: none;
                    align-items: center;
                    justify-content: center;
                    background: rgba(0, 0, 0, .45);
                }

                .logout-modal.show {
                    display: flex;
                    animation: lgFade .15s ease;
                }

                .logout-box {
                    width: 90%;
                    max-width: 380px;
                    padding: 28px 24px 22px;
                    background: #fff;
                    border-radius: 14px;
                    text-align: center;
                    box-shadow: 0 20px 50px rgba(0, 0, 0, .25);
                    animation: lgPop .18s ease;
                }

                .logout-icon {
                    width: 52px;
                    height: 52px;
                    margin: 0 auto 12px;
                    border-radius: 50%;
                    background: #fff1e6;
                    color: #f26b1d;
                    font-size: 28px;
                    font-weight: 700;
                    line-height: 52px;
                }

                .logout-box h3 {
                    margin: 0 0 6px;
                    font-size: 20px;
                    color: #222;
                }

                .logout-box p {
                    margin: 0 0 20px;
                    font-size: 14px;
                    color: #666;
                }

                .logout-actions {
                    display: flex;
                    gap: 10px;
                }

                .logout-btn {
                    flex: 1;
                    padding: 10px 0;
                    border: 0;
                    border-radius: 8px;
                    font-size: 14px;
                    font-weight: 600;
                    cursor: pointer;
                    text-decoration: none;
                    text-align: center;
                    transition: transform .15s, box-shadow .25s, background .25s;
                }

                .logout-btn:hover {
                    transform: translateY(-1px);
                }

                .logout-btn:active {
                    transform: scale(.95);
                }

                .logout-btn.cancel {
                    background: #eee;
                    color: #333;
                }

                .logout-btn.cancel:hover {
                    background: #e0e0e0;
                }

                .logout-btn.confirm {
                    background: #f26b1d;
                    color: #fff;
                }

                .logout-btn.confirm:hover {
                    background: #d95a10;
                    box-shadow: 0 6px 16px rgba(242, 107, 29, .4);
                }

                .logout-btn.confirm.loading {
                    pointer-events: none;
                    opacity: .85;
                }

                .logout-btn.confirm.loading::after {
                    content: "";
                    display: inline-block;
                    width: 12px;
                    height: 12px;
                    margin-left: 8px;
                    vertical-align: -1px;
                    border: 2px solid rgba(255, 255, 255, .5);
                    border-top-color: #fff;
                    border-radius: 50%;
                    animation: lgSpin .6s linear infinite;
                }

                @keyframes lgFade {
                    from {
                        opacity: 0;
                    }

                    to {
                        opacity: 1;
                    }
                }

                @keyframes lgPop {
                    from {
                        transform: scale(.92);
                        opacity: 0;
                    }

                    to {
                        transform: scale(1);
                        opacity: 1;
                    }
                }

                @keyframes lgSpin {
                    to {
                        transform: rotate(360deg);
                    }
                }

                /* Nút Đăng xuất ở sidebar */
                .side-foot .logout-link {
                    position: relative;
                    z-index: 0;
                    overflow: hidden;
                    display: flex;
                    align-items: center;
                    justify-content: center;
                    gap: 10px;
                    padding: 11px 16px;
                    border-radius: 10px;
                    border: 1px solid rgba(242, 107, 29, .55);
                    color: #f26b1d;
                    font-weight: 600;
                    text-decoration: none;
                    background: transparent;
                    transition: color .3s, transform .2s, box-shadow .3s;
                }

                /* nền cam tràn từ trái sang */
                .side-foot .logout-link::before {
                    content: "";
                    position: absolute;
                    inset: 0;
                    z-index: -1;
                    background: linear-gradient(90deg, #f26b1d, #ff9a4d);
                    transform: translateX(-101%);
                    transition: transform .4s cubic-bezier(.7, 0, .2, 1);
                }

                /* vệt sáng quét ngang */
                .side-foot .logout-link::after {
                    content: "";
                    position: absolute;
                    top: 0;
                    left: -60%;
                    width: 40%;
                    height: 100%;
                    background: linear-gradient(90deg, transparent, rgba(255, 255, 255, .45), transparent);
                    transform: skewX(-20deg);
                }

                .side-foot .logout-link svg {
                    transition: transform .3s;
                }

                .side-foot .logout-link:hover {
                    color: #fff;
                    transform: translateY(-2px);
                    box-shadow: 0 8px 20px rgba(242, 107, 29, .35);
                }

                .side-foot .logout-link:hover::before {
                    transform: translateX(0);
                }

                .side-foot .logout-link:hover::after {
                    left: 130%;
                    transition: left .6s ease .15s;
                }

                .side-foot .logout-link:hover svg {
                    transform: translateX(4px);
                }

                .side-foot .logout-link:active {
                    transform: translateY(0) scale(.96);
                }
            </style>

            <script>
                (function () {
                    var modal = document.getElementById('logoutModal');
                    var link = document.getElementById('logoutLink');
                    var cancel = document.getElementById('logoutCancel');
                    var confirmBtn = modal.querySelector('.logout-btn.confirm');

                    function open() { modal.classList.add('show'); modal.setAttribute('aria-hidden', 'false'); }
                    function close() { modal.classList.remove('show'); modal.setAttribute('aria-hidden', 'true'); }

                    link.addEventListener('click', function (e) { e.preventDefault(); open(); });
                    cancel.addEventListener('click', close);
                    modal.addEventListener('click', function (e) { if (e.target === modal) close(); });
                    document.addEventListener('keydown', function (e) { if (e.key === 'Escape') close(); });

                    // Bấm xác nhận: hiện vòng xoay một chút rồi mới đăng xuất
                    confirmBtn.addEventListener('click', function (e) {
                        e.preventDefault();
                        confirmBtn.classList.add('loading');
                        confirmBtn.firstChild.textContent = 'Đang đăng xuất';
                        setTimeout(function () { window.location.href = confirmBtn.href; }, 700);
                    });
                })();
            </script>