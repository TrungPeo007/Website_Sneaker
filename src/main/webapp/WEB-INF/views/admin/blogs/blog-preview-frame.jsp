<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<c:choose>
    <c:when test="${not empty error}">
        <div class="alert err"><c:out value="${error}"/></div>
    </c:when>
    <c:otherwise>
        <article class="pv-article">
            <p class="pv-meta">
                <c:out value="${empty blog.author ? 'PolySneaker' : blog.author}"/> ·
                <fmt:formatDate value="${blog.createdAt}" pattern="dd/MM/yyyy"/>
            </p>
            <h1><c:out value="${blog.title}"/></h1>
            <c:if test="${not empty blog.summary}">
                <p class="pv-sum"><c:out value="${blog.summary}"/></p>
            </c:if>
            <c:if test="${not empty blog.thumbSrc}">
                <img class="pv-cover" src="<c:out value='${blog.thumbSrc}'/>" alt="" onerror="this.style.display='none'">
            </c:if>
            <div class="pv-content"><c:out value="${contentHtml}" escapeXml="false"/></div>
        </article>
    </c:otherwise>
</c:choose>