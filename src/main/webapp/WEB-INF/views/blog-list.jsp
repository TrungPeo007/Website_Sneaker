<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<%@ taglib uri="jakarta.tags.functions" prefix="fn" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<c:set var="pageTitle" value="Blog" scope="request"/>
<c:set var="activeMenu" value="blog" scope="request"/>
<jsp:include page="/WEB-INF/views/layouts/header.jsp"/>
<link rel="stylesheet" href="${ctx}/static/assets/css/blog.css">


<section class="bg-wrap">
    <header class="bg-hero">
        <h1>Blog PolySneaker</h1>
        <p>Hướng dẫn chọn giày, cách phối đồ và tin mới từ cửa hàng.</p>
    </header>

    <c:choose>
        <c:when test="${empty blogs}">
            <p class="bg-empty">Chưa có bài viết nào được đăng. Anh/chị quay lại sau nhé.</p>
        </c:when>
        <c:otherwise>
            <div class="bg-grid">
                <c:forEach var="b" items="${blogs}" varStatus="st">
                    <article class="bg-card ${st.first and currentPage == 0 ? 'is-feature' : ''}">
                        <a class="bg-media" href="${ctx}/blog/${b.slug}" tabindex="-1" aria-hidden="true">
                            <c:choose>
                                <c:when test="${not empty b.thumbSrc}"><img src="${b.thumbSrc}" alt="" loading="lazy"></c:when>
                                <c:otherwise><span class="bg-noimg">PS</span></c:otherwise>
                            </c:choose>
                        </a>
                        <div class="bg-body">
                            <p class="bg-meta">
                                <fmt:formatDate value="${b.createdAt}" pattern="dd/MM/yyyy"/>
                                - <c:out value="${empty b.author ? 'PolySneaker' : b.author}"/>
                            </p>
                            <h2><a href="${ctx}/blog/${b.slug}"><c:out value="${b.title}"/></a></h2>
                            <c:if test="${not empty b.summary}"><p class="bg-sum"><c:out value="${b.summary}"/></p></c:if>
                            <a class="bg-more" href="${ctx}/blog/${b.slug}">Đọc bài viết</a>
                        </div>
                    </article>
                </c:forEach>
            </div>

            <c:if test="${totalPages > 1}">
                <nav class="bg-pager" aria-label="Phân trang">
                    <c:if test="${currentPage > 0}"><a href="${ctx}/blog?page=${currentPage - 1}">Trang trước</a></c:if>
                    <c:forEach begin="0" end="${totalPages - 1}" var="i">
                        <a href="${ctx}/blog?page=${i}" class="${i == currentPage ? 'is-current' : ''}"
                           <c:if test="${i == currentPage}">aria-current="page"</c:if>>${i + 1}</a>
                    </c:forEach>
                    <c:if test="${currentPage < totalPages - 1}"><a href="${ctx}/blog?page=${currentPage + 1}">Trang sau</a></c:if>
                </nav>
            </c:if>
        </c:otherwise>
    </c:choose>
</section>

<jsp:include page="/WEB-INF/views/layouts/footer.jsp"/>
