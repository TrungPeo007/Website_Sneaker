<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Đặt hàng thành công #${order.OrderId} - PolySneaker</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Nunito+Sans:wght@400;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${ctx}/static/assets/css/checkout.css">
</head>
<body class="co-body">
    <header class="co-top">
        <a class="co-brand" href="${ctx}/">Poly<b>Sneaker</b></a>
        <a class="co-back" href="${ctx}/shop">Tiếp tục mua sắm</a>
    </header>

    <main class="co-main" style="max-width:760px;margin:32px auto;">
        <div class="co-col">
            <div class="co-alert ok">
                Đặt hàng thành công! Mã đơn hàng của bạn là <strong>#<c:out value="${order.OrderId}" /></strong>.
            </div>

            <h2 class="co-h">Thông tin đơn hàng</h2>
            <p><strong>Người nhận:</strong> <c:out value="${order.ReceiverName}" /></p>
            <p><strong>Số điện thoại:</strong> <c:out value="${order.Phone}" /></p>
            <p><strong>Địa chỉ:</strong> <c:out value="${order.Address}" /></p>
            <p><strong>Trạng thái:</strong> <c:out value="${order.Status}" /> (<c:out value="${order.PaymentStatus}" />)</p>
            <p><strong>Tổng thanh toán:</strong>
                <strong><fmt:formatNumber value="${order.TotalAmount}" pattern="#,##0" />₫</strong>
            </p>

            <a class="co-btn" href="${ctx}/shop" style="display:inline-block;text-decoration:none;margin-top:16px;">
                Về cửa hàng
            </a>
        </div>
    </main>
</body>
</html>