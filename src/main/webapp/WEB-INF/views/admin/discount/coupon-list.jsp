<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<%@ taglib uri="jakarta.tags.functions" prefix="fn" %>

<c:set var="ctx" value="${pageContext.request.contextPath}" />
<c:set var="pageTitle" value="Quản lý coupon" />
<c:set var="adminMenu" value="coupons" />
<c:set var="pageCss" value="admin-coupons.css" />
<%@ include file="/WEB-INF/views/layouts/admin-header.jsp" %>

        <div class="top">
            <div>
                <h1 class="page-title">Quản lý coupon</h1>
                <p class="page-sub">Tổng cộng ${fn:length(coupons)} coupon</p>
            </div>
            <a href="${ctx}/admin/coupons/new" class="btn-add">+ Thêm coupon</a>
        </div>

        <c:if test="${not empty success}">
            <div class="alert ok"><c:out value="${success}"/></div>
        </c:if>
        <c:if test="${not empty error}">
            <div class="alert err"><c:out value="${error}"/></div>
        </c:if>

        <div class="tools">
            <div class="search-box">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">
                    <circle cx="11" cy="11" r="7"></circle>
                    <line x1="21" y1="21" x2="16.65" y2="16.65"></line>
                </svg>
                <input type="text" id="search" class="search" placeholder="Tìm theo mã hoặc tiêu đề..." autocomplete="off">
            </div>
            <select id="statusFilter" class="dc-filter">
                <option value="">Mọi trạng thái</option>
                <option value="ACTIVE">Đang dùng</option>
                <option value="UPCOMING">Chưa tới giờ</option>
                <option value="EXPIRED">Hết hạn</option>
                <option value="USED_UP">Hết lượt</option>
                <option value="DISABLED">Đã tắt</option>
            </select>
        </div>

        <div class="card">
            <div class="table-wrap">
                <table>
                    <thead>
                    <tr>
                        <th>Mã</th>
                        <th>Mức giảm</th>
                        <th>Điều kiện</th>
                        <th>Lượt dùng</th>
                        <th>Hiệu lực</th>
                        <th>Trạng thái</th>
                        <th>Thao tác</th>
                    </tr>
                    </thead>
                    <tbody id="rows">
                    <c:forEach var="cp" items="${coupons}">
                        <tr data-search="<c:out value='${fn:toLowerCase(cp.Code)} ${fn:toLowerCase(cp.Title)}'/>"
                            data-status="${cp.EffectiveStatus}">
                            <td>
                                <span class="dc-code"><c:out value="${cp.Code}"/></span>
                                <span class="dc-sub"><c:out value="${cp.Title}"/></span>
                            </td>
                            <td>
                                <c:choose>
                                    <c:when test="${cp.DiscountType == 'PERCENT'}">
                                        <span class="num">${cp.DiscountValue}%</span>
                                        <c:if test="${not empty cp.MaxDiscount}">
                                            <span class="dc-sub">tối đa <fmt:formatNumber value="${cp.MaxDiscount}" pattern="#,##0"/>₫</span>
                                        </c:if>
                                    </c:when>
                                    <c:otherwise><span class="num"><fmt:formatNumber value="${cp.DiscountValue}" pattern="#,##0"/>₫</span></c:otherwise>
                                </c:choose>
                            </td>
                            <td>
                                Đơn từ <fmt:formatNumber value="${cp.MinOrderAmount}" pattern="#,##0"/>₫
                                <span class="dc-sub">${cp.PerAccountLimit} lần / tài khoản</span>
                            </td>
                          <td>
    <c:if test="${not empty cp.UsageLimit and cp.UsageLimit gt 0}">
        <fmt:formatNumber var="pct" value="${cp.UsedCount * 100 / cp.UsageLimit}" maxFractionDigits="0" groupingUsed="false" />
        <c:set var="barW" value="${pct ge 100 ? 100 : pct}" />
        <c:set var="barStyle" value="width:${barW}%" />
    </c:if>
    <span class="num">${cp.UsedCount}</span> /
    <c:choose><c:when test="${empty cp.UsageLimit}">không giới hạn</c:when><c:otherwise>${cp.UsageLimit}</c:otherwise></c:choose>
    <c:if test="${not empty cp.UsageLimit and cp.UsageLimit gt 0}">
        <span class="cp-bar ${pct ge 100 ? 'full' : ''}"><i style="${barStyle}"></i></span>
    </c:if>
</td>
                            <td>
                                <fmt:formatDate value="${cp.StartsAt}" pattern="dd/MM/yyyy HH:mm"/>
                                <span class="dc-sub">
                                    <c:choose>
                                        <c:when test="${empty cp.ExpiresAt}">không hết hạn</c:when>
                                        <c:otherwise>đến <fmt:formatDate value="${cp.ExpiresAt}" pattern="dd/MM/yyyy HH:mm"/></c:otherwise>
                                    </c:choose>
                                </span>
                            </td>
                            <td>
                                <c:choose>
                                    <c:when test="${cp.EffectiveStatus == 'ACTIVE'}"><span class="dc-pill ok">Đang dùng</span></c:when>
                                    <c:when test="${cp.EffectiveStatus == 'UPCOMING'}"><span class="dc-pill info">Chưa tới giờ</span></c:when>
                                    <c:when test="${cp.EffectiveStatus == 'EXPIRED'}"><span class="dc-pill off">Hết hạn</span></c:when>
                                    <c:when test="${cp.EffectiveStatus == 'USED_UP'}"><span class="dc-pill warn">Hết lượt</span></c:when>
                                    <c:otherwise><span class="dc-pill dark">Đã tắt</span></c:otherwise>
                                </c:choose>
                            </td>
                            <td>
                                <div class="actions">
                                    <a href="${ctx}/admin/coupons/${cp.CouponId}/edit" class="btn-edit">Sửa</a>
                                    <a href="${ctx}/admin/coupons/${cp.CouponId}/usages" class="btn-edit">Lượt dùng</a>
                                    <form action="${ctx}/admin/coupons/${cp.CouponId}/toggle" method="post">
                                        <button type="submit" class="btn-edit">${cp.IsActive ? 'Tắt' : 'Bật'}</button>
                                    </form>
                                    <form action="${ctx}/admin/coupons/${cp.CouponId}/delete" method="post"
                                          data-confirm="Xóa coupon <c:out value='${cp.Code}'/>?">
                                        <button type="submit" class="btn-del">Xóa</button>
                                    </form>
                                </div>
                            </td>
                        </tr>
                    </c:forEach>
                    </tbody>
                </table>
            </div>

            <c:if test="${empty coupons}">
                <div class="empty">Chưa có coupon nào. Bấm "Thêm coupon" để tạo mã giảm giá đầu tiên.</div>
            </c:if>
            <div class="empty" id="noResult" hidden>Không tìm thấy coupon phù hợp.</div>
        </div>

        <p class="note">
            <b>Coupon</b> là mã giảm giá công khai: ai biết mã đều nhập được ở bước thanh toán, trong giới hạn tổng lượt dùng
            và số lần mỗi tài khoản được dùng. Coupon đã có người dùng thì không xóa được, hãy bấm <b>Tắt</b> để ngừng áp dụng.
            Muốn tặng riêng cho một khách, hãy dùng mục <b>Voucher</b>.
        </p>

<script>
    /* Xóa: hỏi xác nhận, dòng trượt đi rồi mới gửi */
    document.addEventListener('submit', function (e) {
        var msg = e.target.getAttribute('data-confirm');
        if (!msg) return;
        e.preventDefault();
        if (!confirm(msg)) return;
        var row = e.target.closest('tr');
        if (row) row.classList.add('leaving');
        setTimeout(function () { e.target.submit(); }, 250);
    });

    /* Thông báo thành công tự tắt sau 4 giây (lỗi thì giữ lại) */
    document.querySelectorAll('.alert.ok').forEach(function (box) {
        setTimeout(function () { box.classList.add('hide'); }, 4000);
    });

    /* Tìm kiếm + lọc */
    (function () {
        var input = document.getElementById('search');
        var status = document.getElementById('statusFilter');
        var rows = document.querySelectorAll('#rows tr');
        var noResult = document.getElementById('noResult');

        function run() {
            var q = input.value.trim().toLowerCase();
            var st = status.value;
            var shown = 0;
            rows.forEach(function (tr) {
                var match = (!q || tr.getAttribute('data-search').indexOf(q) !== -1)
                         && (!st || tr.getAttribute('data-status') === st);
                tr.hidden = !match;
                if (match) {
                    tr.style.animationDelay = Math.min(shown * 25, 300) + 'ms';
                    shown++;
                }
            });
            noResult.hidden = shown > 0 || rows.length === 0;
        }
        input.addEventListener('input', run);
        status.addEventListener('change', run);

        /* Phím tắt "/" nhảy vào ô tìm kiếm */
        document.addEventListener('keydown', function (e) {
            if (e.key === '/' && !/INPUT|TEXTAREA|SELECT/.test(document.activeElement.tagName)) {
                e.preventDefault();
                input.focus();
            }
        });
    })();

    /* Dropdown tự vẽ cho ô lọc trạng thái (select gốc vẫn còn, bị ẩn, vẫn bắn sự kiện change) */
    (function () {
        var sel = document.getElementById('statusFilter');
        var wrap = document.createElement('div');
        wrap.className = 'cp-select';
        sel.parentNode.insertBefore(wrap, sel);
        wrap.appendChild(sel);
        sel.classList.add('cp-native');

        var btn = document.createElement('button');
        btn.type = 'button';
        btn.className = 'cp-trigger';
        btn.innerHTML = '<span class="cp-label"></span>'
            + '<svg class="cp-chev" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round"><polyline points="6 9 12 15 18 9"></polyline></svg>';
        var menu = document.createElement('ul');
        menu.className = 'cp-menu';
        wrap.appendChild(btn);
        wrap.appendChild(menu);

        var label = btn.querySelector('.cp-label');
        var items = [];
        var hi = 0;

        Array.prototype.forEach.call(sel.options, function (o, i) {
            var li = document.createElement('li');
            li.className = 'cp-opt';
            li.setAttribute('data-v', o.value);
            li.style.setProperty('--i', i);
            li.textContent = o.text;
            li.addEventListener('click', function () { pick(i); });
            menu.appendChild(li);
            items.push(li);
        });

        function render() {
            label.textContent = sel.options[sel.selectedIndex].text;
            items.forEach(function (li, i) { li.classList.toggle('sel', i === sel.selectedIndex); });
            wrap.classList.toggle('active', sel.value !== '');
        }
        function mark(n) {
            hi = Math.max(0, Math.min(items.length - 1, n));
            items.forEach(function (li, i) { li.classList.toggle('hover', i === hi); });
            items[hi].scrollIntoView({ block: 'nearest' });
        }
        function open()  { wrap.classList.add('open'); mark(sel.selectedIndex); }
        function close() { wrap.classList.remove('open'); }
        function pick(i) {
            sel.selectedIndex = i;
            sel.dispatchEvent(new Event('change', { bubbles: true }));
            close();
            btn.focus();
        }

        btn.addEventListener('click', function () {
            if (wrap.classList.contains('open')) close(); else open();
        });
        btn.addEventListener('keydown', function (e) {
            var isOpen = wrap.classList.contains('open');
            if (e.key === 'ArrowDown' || e.key === 'ArrowUp') {
                e.preventDefault();
                if (!isOpen) { open(); return; }
                mark(hi + (e.key === 'ArrowDown' ? 1 : -1));
            } else if (e.key === 'Enter' && isOpen) {
                e.preventDefault();
                pick(hi);
            } else if (e.key === 'Escape' || e.key === 'Tab') {
                close();
            }
        });
        document.addEventListener('click', function (e) {
            if (!wrap.contains(e.target)) close();
        });

        sel.addEventListener('change', render);
        render();
    })();
</script>

<%@ include file="/WEB-INF/views/layouts/admin-footer.jsp" %>