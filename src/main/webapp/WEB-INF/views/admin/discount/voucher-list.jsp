<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<%@ taglib uri="jakarta.tags.functions" prefix="fn" %>

<c:set var="ctx" value="${pageContext.request.contextPath}" />
<c:set var="pageTitle" value="Quản lý voucher" />
<c:set var="adminMenu" value="vouchers" />
<c:set var="pageCss" value="admin-vouchers.css" />
<%@ include file="/WEB-INF/views/layouts/admin-header.jsp" %>

        <div class="top">
            <div>
                <h1 class="page-title">Quản lý voucher</h1>
                <p class="page-sub">Tổng cộng ${fn:length(vouchers)} voucher</p>
            </div>
            <a href="${ctx}/admin/vouchers/new" class="btn-add">+ Cấp voucher</a>
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
                <input type="text" id="search" class="search" placeholder="Tìm theo mã, tài khoản hoặc tiêu đề..." autocomplete="off">
            </div>
            <select id="statusFilter" class="dc-filter">
                <option value="">Mọi trạng thái</option>
                <option value="UNUSED">Chưa dùng</option>
                <option value="USED">Đã dùng</option>
                <option value="EXPIRED">Hết hạn</option>
                <option value="REVOKED">Đã thu hồi</option>
            </select>
        </div>

        <div class="card">
            <div class="table-wrap">
                <table>
                    <thead>
                    <tr>
                        <th>Mã</th>
                        <th>Chủ voucher</th>
                        <th>Mức giảm</th>
                        <th>Điều kiện</th>
                        <th>Hạn dùng</th>
                        <th>Trạng thái</th>
                        <th>Thao tác</th>
                    </tr>
                    </thead>
                    <tbody id="rows">
                    <c:forEach var="v" items="${vouchers}">
                        <tr data-search="<c:out value='${fn:toLowerCase(v.Code)} ${fn:toLowerCase(v.OwnerUsername)} ${fn:toLowerCase(v.Title)}'/>"
                            data-status="${v.EffectiveStatus}">
                            <td>
                                <span class="dc-code"><c:out value="${v.Code}"/></span>
                                <span class="dc-sub"><c:out value="${v.Title}"/></span>
                                <c:if test="${not empty v.Reason}"><span class="dc-sub"><c:out value="${v.Reason}"/></span></c:if>
                            </td>
                            <td>
                                <c:out value="${v.OwnerUsername}"/>
                                <c:if test="${not empty v.OwnerFullName}"><span class="dc-sub"><c:out value="${v.OwnerFullName}"/></span></c:if>
                            </td>
                            <td>
                                <c:choose>
                                    <c:when test="${v.DiscountType == 'PERCENT'}">
                                        <span class="num">${v.DiscountValue}%</span>
                                        <c:if test="${not empty v.MaxDiscount}">
                                            <span class="dc-sub">tối đa <fmt:formatNumber value="${v.MaxDiscount}" pattern="#,##0"/>₫</span>
                                        </c:if>
                                    </c:when>
                                    <c:otherwise><span class="num"><fmt:formatNumber value="${v.DiscountValue}" pattern="#,##0"/>₫</span></c:otherwise>
                                </c:choose>
                            </td>
                            <td>Đơn từ <fmt:formatNumber value="${v.MinOrderAmount}" pattern="#,##0"/>₫</td>
                            <td><fmt:formatDate value="${v.ExpiresAt}" pattern="dd/MM/yyyy HH:mm"/></td>
                            <td>
                                <c:choose>
                                    <c:when test="${v.EffectiveStatus == 'UNUSED'}"><span class="dc-pill ok">Chưa dùng</span></c:when>
                                    <c:when test="${v.EffectiveStatus == 'USED'}">
                                        <span class="dc-pill info">Đã dùng</span>
                                        <c:if test="${not empty v.UsedOrderId}"><span class="dc-sub">đơn #${v.UsedOrderId}</span></c:if>
                                    </c:when>
                                    <c:when test="${v.EffectiveStatus == 'EXPIRED'}"><span class="dc-pill off">Hết hạn</span></c:when>
                                    <c:otherwise><span class="dc-pill dark">Đã thu hồi</span></c:otherwise>
                                </c:choose>
                            </td>
                            <td>
                                <div class="actions">
                                    <c:if test="${v.Status == 'UNUSED'}">
                                        <form action="${ctx}/admin/vouchers/${v.VoucherId}/revoke" method="post"
                                              data-confirm="Thu hồi voucher <c:out value='${v.Code}'/>?">
                                            <button type="submit" class="btn-del">Thu hồi</button>
                                        </form>
                                    </c:if>
                                </div>
                            </td>
                        </tr>
                    </c:forEach>
                    </tbody>
                </table>
            </div>

            <c:if test="${empty vouchers}">
                <div class="empty">Chưa có voucher nào. Bấm "Cấp voucher" để tặng voucher cho một khách.</div>
            </c:if>
            <div class="empty" id="noResult" hidden>Không tìm thấy voucher phù hợp.</div>
        </div>

        <p class="note">
            <b>Voucher</b> được cấp riêng cho từng khách (quà sinh nhật, đền bù, khách thân thiết...). Chỉ chủ tài khoản dùng được,
            mỗi voucher dùng một lần. Voucher chưa dùng có thể <b>Thu hồi</b>. Voucher đã hết hạn tự chuyển sang "Hết hạn".
        </p>

<script>
    /* Thu hồi: hỏi xác nhận, dòng trượt đi rồi mới gửi */
    document.addEventListener('submit', function (e) {
        var msg = e.target.getAttribute('data-confirm');
        if (!msg) return;
        e.preventDefault();
        if (!confirm(msg)) return;
        var row = e.target.closest('tr');
        if (row) row.classList.add('leaving');
        setTimeout(function () { e.target.submit(); }, 250);
    });

    /* Thông báo thành công tự tắt sau 4 giây (thông báo lỗi giữ nguyên) */
    document.querySelectorAll('.alert.ok').forEach(function (box) {
        setTimeout(function () { box.classList.add('hide'); }, 4000);
    });

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
    })();
</script>
<%@ include file="/WEB-INF/views/layouts/admin-footer.jsp" %>
