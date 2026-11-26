<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<%@ taglib uri="jakarta.tags.functions" prefix="fn" %>

<c:set var="pageTitle" value="Quản lý đơn hàng" />
<c:set var="adminMenu" value="orders" />
<c:set var="pageCss" value="admin-orders.css" />
<%@ include file="../layouts/admin-header.jsp" %>

        <div class="top">
            <div>
                <h1 class="page-title">Quản lý đơn hàng</h1>
                <p class="page-sub">Tổng cộng ${fn:length(orders)} đơn hàng</p>
            </div>
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
                <input type="text" id="search" class="search" placeholder="Tìm theo mã đơn, người nhận, SĐT hoặc trạng thái..." autocomplete="off">
            </div>
        </div>

        <div class="card">
            <div class="table-wrap">
                <table>
                    <thead>
                    <tr>
                        <th>Mã đơn</th>
                        <th>Người nhận</th>
                        <th>Tổng tiền</th>
                        <th>Thanh toán</th>
                        <th>Trạng thái</th>
                        <th>Ngày tạo</th>
                        <th>Thao tác</th>
                    </tr>
                    </thead>
                    <tbody id="rows">
                    <c:forEach var="o" items="${orders}">
                        <c:set var="oid" value="${o.OrderId}" />
                        <c:set var="st" value="${o.Status}" />
                        <c:set var="paySt" value="${o.PaymentStatus}" />
                        <c:set var="searchBlob" value="#${oid} ${o.ReceiverName} ${o.Phone} ${paySt} ${st}" />
                        <tr data-search="<c:out value='${fn:toLowerCase(searchBlob)}'/>">
                            <td><strong>#<c:out value="${oid}"/></strong></td>
                            <td>
                                <div><c:out value="${o.ReceiverName}"/></div>
                                <small class="sub-text"><c:out value="${o.Phone}"/></small>
                            </td>
                            <td>
                                <strong><fmt:formatNumber value="${o.TotalAmount}" pattern="#,##0"/>₫</strong>
                            </td>
                            <td>
                                <c:choose>
                                    <c:when test="${paySt eq 'PAID'}">
                                        <span class="status on">PAID</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="status off"><c:out value="${paySt}"/></span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td>
                                <span class="tag st-${fn:toLowerCase(st)}"><c:out value="${st}"/></span>
                            </td>
                            <td>
                                <c:out value="${o.CreatedAt}"/>
                            </td>
                            <td>
                                <div class="actions">
                                    <a href="${ctx}/admin/orders/${oid}" class="btn-edit">Chi tiết</a>

                                    <c:if test="${paySt eq 'UNPAID' and st ne 'CANCELLED'}">
                                        <form action="${ctx}/admin/orders/${oid}/paid" method="post"
                                              class="js-paid" data-id="${oid}">
                                            <input type="hidden" name="back" value="list">
                                            <button type="submit" class="btn-edit">Thanh toán thành công</button>
                                        </form>
                                    </c:if>

                                    <c:if test="${st ne 'CANCELLED' and st ne 'COMPLETED'}">
                                        <form action="${ctx}/admin/orders/${oid}/cancel" method="post"
                                              class="js-cancel" data-id="${oid}">
                                            <button type="submit" class="btn-del">Hủy đơn</button>
                                        </form>
                                    </c:if>
                                </div>
                            </td>
                        </tr>
                    </c:forEach>
                    </tbody>
                </table>
            </div>

            <c:if test="${empty orders}">
                <div class="empty">Chưa có đơn hàng nào.</div>
            </c:if>
            <div class="empty" id="noResult" hidden>Không tìm thấy đơn hàng phù hợp.</div>
        </div>

        <p class="note">
            Bấm <b>Thanh toán thành công</b> sẽ đánh dấu đơn đã thanh toán (<code>PAID</code>) và tự động trừ tồn kho
            theo đúng số lượng từng size khách đặt. Nếu hủy đơn đã thanh toán, hệ thống sẽ hoàn lại tồn kho và nhả mã giảm giá.
        </p>

<script>
    document.addEventListener('submit', function (e) {
        var form = e.target;
        if (form.classList.contains('js-cancel')) {
            var id = form.getAttribute('data-id') || '';
            if (!confirm('Hủy đơn hàng #' + id + '?')) {
                e.preventDefault();
            }
        } else if (form.classList.contains('js-paid')) {
            var paidId = form.getAttribute('data-id') || '';
            if (!confirm('Xác nhận thanh toán và trừ tồn kho cho đơn #' + paidId + '?')) {
                e.preventDefault();
            }
        }
    });
    (function () {
        var input = document.getElementById('search');
        var rows = document.querySelectorAll('#rows tr');
        var noResult = document.getElementById('noResult');

        input.addEventListener('input', function () {
            var q = input.value.trim().toLowerCase();
            var shown = 0;
            rows.forEach(function (tr) {
                var match = !q || tr.getAttribute('data-search').indexOf(q) !== -1;
                tr.hidden = !match;
                if (match) shown++;
            });
            noResult.hidden = shown > 0 || rows.length === 0;
        });
    })();
</script>

<%@ include file="../layouts/admin-footer.jsp" %>