<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />

</main>

<%-- Icon riêng của footer (ic-shoe lấy từ header). Ẩn hoàn toàn, chỉ để <use> gọi ra --%>
<svg width="0" height="0" style="position:absolute" aria-hidden="true">
    <symbol id="ic-pin" viewBox="0 0 24 24">
        <g fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <path d="M21 10c0 7-9 13-9 13S3 17 3 10a9 9 0 0 1 18 0z" />
            <circle cx="12" cy="10" r="3" />
        </g>
    </symbol>
    <symbol id="ic-phone" viewBox="0 0 24 24">
        <path fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"
            d="M22 16.9v3a2 2 0 0 1-2.2 2 19.8 19.8 0 0 1-8.6-3.1 19.5 19.5 0 0 1-6-6 19.8 19.8 0 0 1-3.1-8.7A2 2 0 0 1 4.1 2h3a2 2 0 0 1 2 1.7c.1 1 .4 1.9.7 2.8a2 2 0 0 1-.5 2.1L8.1 9.9a16 16 0 0 0 6 6l1.3-1.3a2 2 0 0 1 2.1-.4c.9.3 1.8.6 2.8.7a2 2 0 0 1 1.7 2z" />
    </symbol>
    <symbol id="ic-mail" viewBox="0 0 24 24">
        <g fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <rect x="2" y="4" width="20" height="16" rx="2" />
            <polyline points="22 6 12 13 2 6" />
        </g>
    </symbol>
</svg>

<footer class="site-footer">
    <div class="container">
        <div class="ft-grid">

            <%-- Thương hiệu: logo giống header --%>
            <div class="ft-brand">
                <a class="ft-logo" href="${ctx}/">
                    <span class="ft-logo-mark">
                        <img src="${ctx}/static/assets/images/logo_poly_store.png" alt="PolySneaker"
                             onerror="this.parentNode.classList.add('no-img'); this.remove();">
                        <svg class="logo-fallback" width="20" height="20" aria-hidden="true"><use href="#ic-shoe"/></svg>
                    </span>
                    <span>
                        <span class="ft-logo-name">POLY<b>SNEAKER</b></span>
                        <span class="ft-logo-sub">PREMIUM SNEAKER STORE</span>
                    </span>
                </a>
                <p class="ft-about">Cửa hàng sneaker mang tinh thần tối giản Á Đông. Giày chính hãng, êm ái và đầy phong thái.</p>
            </div>

            <%-- Dịch Vụ: các trang admin đặt ở nhóm "Dịch Vụ" --%>
            <div class="ft-col">
                <h4>Dịch Vụ</h4>
                <ul>
                    <c:forEach var="p" items="${footerServicePages}">
                        <li><a href="${ctx}/pages/${p.slug}"><c:out value="${p.title}"/></a></li>
                    </c:forEach>
                </ul>
            </div>

            <%-- Chính Sách: các trang admin đặt ở nhóm "Chính Sách" --%>
            <div class="ft-col">
                <h4>Chính Sách</h4>
                <ul>
                    <c:forEach var="p" items="${footerPolicyPages}">
                        <li><a href="${ctx}/pages/${p.slug}"><c:out value="${p.title}"/></a></li>
                    </c:forEach>
                </ul>
            </div>

            <%-- Liên Hệ Cửa Hàng (icon lấy từ symbol trong header.jsp) --%>
            <div class="ft-col">
                <h4>Liên Hệ Cửa Hàng</h4>
                <ul class="ft-contact">
                    <li>
                        <svg width="16" height="16" aria-hidden="true"><use href="#ic-pin"/></svg>
                       21 Khu Phố Hoàng Mai Hà Nội
                    </li>
                    <li>
                        <svg width="16" height="16" aria-hidden="true"><use href="#ic-phone"/></svg>
                        <b>1900 3256</b> (8:00 - 22:00)
                    </li>
                    <li>
                        <svg width="16" height="16" aria-hidden="true"><use href="#ic-mail"/></svg>
                        polysneakervietnam@gmail.com
                    </li>
                </ul>
            </div>

        </div>

        <div class="ft-bottom">
            <span>© 2026 POLY SNEAKER . ALL RIGHTS RESERVED</span>
        </div>
    </div>
</footer>

</body>
</html>