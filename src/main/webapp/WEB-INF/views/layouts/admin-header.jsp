<%@ page pageEncoding="UTF-8" %>
<%--
  Đầu trang chung cho mọi trang admin.
  Trước khi include, mỗi trang đặt 3 biến:
    pageTitle  : tiêu đề tab trình duyệt
    adminMenu  : mục sáng lên ở sidebar (dashboard, products, categories, ...)
    pageCss    : (tuỳ chọn) file CSS riêng của trang, nằm trong static/assets/css/
--%>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title><c:out value="${empty pageTitle ? 'Quản trị' : pageTitle}"/> - PolySneaker</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Nunito+Sans:wght@300;400;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${ctx}/static/assets/css/admin.css">
    <c:if test="${not empty pageCss}">
        <link rel="stylesheet" href="${ctx}/static/assets/css/${pageCss}">
    </c:if>
</head>
<body>

<%@ include file="admin-sidebar.jsp" %>

<main class="content">
    <div class="content-in">
