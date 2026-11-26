<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<c:set var="pageTitle" scope="request"><c:out value="${sitePage.title}" /> - PolySneaker</c:set>
<c:set var="activeMenu" value="" scope="request" />
<jsp:include page="/WEB-INF/views/layouts/header.jsp" />

<style>
    .sp {
        --o: #F7941D;
        --od: #E8830C;
        --head: #6E3A12;
        --brown: #5C4430;
        --muted: #9A8C7E;
        color: var(--brown);
    }

    .sp *, .sp *::before, .sp *::after { box-sizing: border-box; }

    .sp-crumb { display: flex; flex-wrap: wrap; align-items: center; gap: 6px; margin: 0 0 14px; font-size: 13px; color: var(--muted); }
    .sp-crumb a { color: var(--muted); }
    .sp-crumb a:hover { color: var(--od); }
    .sp-crumb b { color: var(--head); font-weight: 700; }

    .sp-layout { display: grid; grid-template-columns: 250px minmax(0, 1fr); gap: 28px; align-items: start; }

    .sp-nav { padding: 18px 16px; background: #fff; border: 1px solid #FBF0D6; border-radius: 18px; box-shadow: 0 8px 26px rgba(200, 140, 40, .06); }
    .sp-nav h4 { margin: 0 0 8px; padding: 0 10px; font-size: 11.5px; font-weight: 800; letter-spacing: .8px; text-transform: uppercase; color: #D97706; }
    .sp-nav h4 + ul { margin-bottom: 16px; }
    .sp-nav ul { list-style: none; margin: 0; padding: 0; }
    .sp-nav ul:last-child { margin-bottom: 0; }
    .sp-nav a { display: block; padding: 9px 10px; border-radius: 10px; font-size: 14px; font-weight: 600; color: var(--brown); transition: background .15s, color .15s; }
    .sp-nav a:hover { background: #FFF3DE; color: var(--od); }
    .sp-nav a.on { background: #FFEBC9; color: #D97706; font-weight: 800; }

    .sp-card { padding: 30px 34px; background: #fff; border: 1px solid #FBF0D6; border-radius: 22px; box-shadow: 0 8px 26px rgba(200, 140, 40, .06); }
    .sp-body { font-size: 15px; line-height: 1.75; color: #4A4038; }
    .sp-body h2 { margin: 28px 0 10px; font-size: 20px; font-weight: 800; color: var(--head); }
    .sp-body h2:first-child { margin-top: 0; }
    .sp-body p { margin: 0 0 14px; }
    .sp-body ul { margin: 0 0 16px; padding-left: 22px; }
    .sp-body li { margin-bottom: 6px; }
    .sp-updated { margin: 16px 4px 0; font-size: 12.5px; color: var(--muted); }

    @media (max-width: 900px) {
        .sp-layout { grid-template-columns: minmax(0, 1fr); gap: 18px; }
        .sp-card { padding: 22px 20px; }
    }
</style>

<section class="sec sp">

    <nav class="sp-crumb" aria-label="Điều hướng">
        <a href="${ctx}/">Trang chủ</a><span>/</span>
        <b><c:out value="${sitePage.title}" /></b>
    </nav>

    <div class="sec-head">
        <div>
            <div class="eyebrow">
                <c:choose>
                    <c:when test="${sitePage.footerGroup == 'SERVICE'}">Dịch vụ</c:when>
                    <c:when test="${sitePage.footerGroup == 'POLICY'}">Chính sách</c:when>
                    <c:otherwise>Thông tin</c:otherwise>
                </c:choose>
            </div>
            <h1 class="sec-title"><c:out value="${sitePage.title}" /></h1>
        </div>
    </div>

    <div class="sp-layout">

        <%-- Menu các trang chính sách khác --%>
        <c:if test="${not empty footerServicePages or not empty footerPolicyPages}">
            <aside class="sp-nav">
                <c:if test="${not empty footerServicePages}">
                    <h4>Dịch vụ</h4>
                    <ul>
                        <c:forEach var="p" items="${footerServicePages}">
                            <li><a href="${ctx}/pages/${p.slug}" class="${p.slug == sitePage.slug ? 'on' : ''}"><c:out value="${p.title}" /></a></li>
                        </c:forEach>
                    </ul>
                </c:if>
                <c:if test="${not empty footerPolicyPages}">
                    <h4>Chính sách</h4>
                    <ul>
                        <c:forEach var="p" items="${footerPolicyPages}">
                            <li><a href="${ctx}/pages/${p.slug}" class="${p.slug == sitePage.slug ? 'on' : ''}"><c:out value="${p.title}" /></a></li>
                        </c:forEach>
                    </ul>
                </c:if>
            </aside>
        </c:if>

        <div>
            <article class="sp-card">
                <%-- contentHtml đã được escape ở server nên in thẳng ra, không dùng c:out --%>
                <div class="sp-body">${contentHtml}</div>
            </article>
            <p class="sp-updated">Cập nhật lần cuối: ${sitePage.lastChangeDate}</p>
        </div>
    </div>
</section>

<jsp:include page="/WEB-INF/views/layouts/footer.jsp" />