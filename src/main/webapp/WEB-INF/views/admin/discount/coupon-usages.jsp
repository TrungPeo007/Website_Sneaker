<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<%@ taglib uri="jakarta.tags.functions" prefix="fn" %>

<c:set var="ctx" value="${pageContext.request.contextPath}" />
<c:set var="pageTitle" value="Lượt dùng coupon" />
<c:set var="adminMenu" value="coupons" />
<c:set var="pageCss" value="admin-coupon-usages.css" />
<%@ include file="/WEB-INF/views/layouts/admin-header.jsp" %>

        <div class="top">
            <div>
                <h1 class="page-title">Lượt dùng coupon <span class="dc-code"><c:out value="${coupon.Code}"/></span></h1>
                <p class="page-sub">
                    Đã dùng ${coupon.UsedCount}<c:if test="${not empty coupon.UsageLimit}"> / ${coupon.UsageLimit}</c:if> lượt
                </p>
            </div>
            <a href="${ctx}/admin/coupons" class="btn-edit">&larr; Quay lại</a>
        </div>

        <div class="card">
            <div class="table-wrap">
                <table>
                    <thead>
                    <tr>
                        <th>#</th>
                        <th>Tài khoản</th>
                        <th>Đơn hàng</th>
                        <th>Số tiền giảm</th>
                        <th>Thời gian</th>
                    </tr>
                    </thead>
                    <tbody>
                    <c:forEach var="u" items="${usages}">
                        <tr>
                            <td>${u.UsageId}</td>
                            <td><c:out value="${u.Username}"/></td>
                            <td>#${u.OrderId}</td>
                            <td><span class="num"><fmt:formatNumber value="${u.DiscountAmount}" pattern="#,##0"/>₫</span></td>
                            <td><fmt:formatDate value="${u.UsedAt}" pattern="dd/MM/yyyy HH:mm"/></td>
                        </tr>
                    </c:forEach>
                    </tbody>
                </table>
            </div>
            <c:if test="${empty usages}">
                <div class="empty">Chưa có lượt dùng nào.</div>
            </c:if>
        </div>

<%@ include file="/WEB-INF/views/layouts/admin-footer.jsp" %>
