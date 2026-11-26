<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<%@ taglib uri="jakarta.tags.functions" prefix="fn" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<c:set var="pageTitle" value="${blog.title}" scope="request"/>
<c:set var="activeMenu" value="blog" scope="request"/>
<jsp:include page="/WEB-INF/views/layouts/header.jsp"/>
<link rel="stylesheet" href="${ctx}/static/assets/css/blog.css">


<c:if test="${preview}">
    <div class="bg-preview">
        Đây là bản xem trước<c:if test="${not blog.published}">, bài đang ở dạng nháp nên khách chưa thấy</c:if>.
        <a href="${ctx}/admin/blogs/${blog.id}/edit">Quay lại chỉnh sửa</a>
    </div>
</c:if>

<article class="bg-article-wrap">
    <nav class="bg-crumb" aria-label="Vị trí trang">
        <a href="${ctx}/">Trang chủ</a> / <a href="${ctx}/blog">Blog</a>
    </nav>

    <header class="bg-article-head">
        <h1><c:out value="${blog.title}"/></h1>
        <p class="bg-meta">
            <fmt:formatDate value="${blog.createdAt}" pattern="dd/MM/yyyy"/>
            - <c:out value="${empty blog.author ? 'PolySneaker' : blog.author}"/>
        </p>
        <c:if test="${not empty blog.summary}"><p class="bg-lead"><c:out value="${blog.summary}"/></p></c:if>
    </header>

    <c:if test="${not empty blog.thumbSrc}">
        <figure class="bg-cover"><img src="${blog.thumbSrc}" alt="<c:out value='${blog.title}'/>"></figure>
    </c:if>

    <%-- contentHtml đã được escape ở BlogContentRenderer nên in thẳng ra được --%>
    <div class="bg-article">${contentHtml}</div>
</article>

<c:if test="${not empty others}">
    <section class="bg-others">
        <h2>Bài viết khác</h2>
        <div class="bg-others-grid">
            <c:forEach var="o" items="${others}">
                <a class="bg-other" href="${ctx}/blog/${o.slug}">
                    <span class="bg-other-img">
                        <c:choose>
                            <c:when test="${not empty o.thumbSrc}"><img src="${o.thumbSrc}" alt="" loading="lazy"></c:when>
                            <c:otherwise><span class="bg-noimg">PS</span></c:otherwise>
                        </c:choose>
                    </span>
                    <span class="bg-other-title"><c:out value="${o.title}"/></span>
                    <span class="bg-meta"><fmt:formatDate value="${o.createdAt}" pattern="dd/MM/yyyy"/></span>
                </a>
            </c:forEach>
        </div>
    </section>
</c:if>

<jsp:include page="/WEB-INF/views/layouts/footer.jsp"/>
