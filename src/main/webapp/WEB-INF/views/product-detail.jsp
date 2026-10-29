<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ taglib uri="jakarta.tags.core" prefix="c" %>
        <%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
            <%@ taglib uri="jakarta.tags.functions" prefix="fn" %>
                <c:set var="ctx" value="${pageContext.request.contextPath}" />
                <c:set var="pageTitle" scope="request">
                    <c:out value="${product.name}" /> - PolySneaker
                </c:set>
                <c:set var="activeMenu" value="" scope="request" />
                <jsp:include page="/WEB-INF/views/layouts/header.jsp" />

                <%-- Ảnh đầu tiên (ảnh đại diện) dùng cho khung ảnh lớn --%>
                    <c:set var="firstSrc" value="" />
                    <c:if test="${not empty gallery}">
                        <c:set var="g0" value="${gallery[0]}" />
                        <c:choose>
                            <c:when test="${fn:startsWith(g0, 'http')}">
                                <c:set var="firstSrc" value="${g0}" />
                            </c:when>
                            <c:when test="${fn:startsWith(g0, '/')}">
                                <c:set var="firstSrc" value="${ctx}${g0}" />
                            </c:when>
                            <c:otherwise>
                                <c:set var="firstSrc" value="${ctx}/static/assets/images/${g0}" />
                            </c:otherwise>
                        </c:choose>
                    </c:if>

                    <style>
                        .pd {
                            --o: #F7941D;
                            --od: #E8830C;
                            --cream: #FFF6E6;
                            --line: #F8E3BC;
                            --brown: #5C4430;
                            --head: #6E3A12;
                            --muted: #9A8C7E;
                            --danger: #C2410C;
                            --ok: #15803D;
                            padding: 8px 0 28px;
                            color: var(--brown);
                        }

                        .pd *,
                        .pd *::before,
                        .pd *::after {
                            box-sizing: border-box;
                        }

                        .pd-crumb {
                            display: flex;
                            flex-wrap: wrap;
                            align-items: center;
                            gap: 6px;
                            margin: 6px 0 18px;
                            font-size: 13px;
                            color: var(--muted);
                        }

                        .pd-crumb a {
                            color: var(--muted);
                            text-decoration: none;
                        }

                        .pd-crumb a:hover {
                            color: var(--od);
                        }

                        .pd-crumb b {
                            color: var(--head);
                            font-weight: 700;
                        }

                        .pd-top {
                            display: grid;
                            grid-template-columns: minmax(0, 1.3fr) minmax(0, 1fr);
                            gap: 36px;
                            align-items: start;
                        }

                        /* Thư viện ảnh: cột ảnh nhỏ cao đúng bằng ảnh lớn */
                        .pd-gallery {
                            display: grid;
                            grid-template-columns: 112px minmax(0, 1fr);
                            gap: 12px;
                        }

                        .pd-gallery.single {
                            grid-template-columns: minmax(0, 1fr);
                        }

                        /* Cột ảnh nhỏ bám theo chiều cao ảnh lớn, không làm ảnh lớn cao thêm */
                        .pd-thumbs-col {
                            position: relative;
                            min-width: 0;
                        }

                        .pd-thumbs {
                            position: absolute;
                            inset: 0;
                            display: flex;
                            flex-direction: column;
                            gap: 8px;
                        }

                        /* Mũi tên: thanh phẳng, không viền, không bo góc */
                        .pd-arrow {
                            flex-shrink: 0;
                            height: 34px;
                            border: none;
                            border-radius: 0;
                            background: #F6F0E4;
                            color: var(--head);
                            cursor: pointer;
                            display: flex;
                            align-items: center;
                            justify-content: center;
                            transition: background .15s, color .15s;
                        }

                        .pd-arrow:hover {
                            background: #F0E6D2;
                            color: var(--o);
                        }

                        .pd-thumb-list {
                            flex: 1;
                            min-height: 0;
                            display: flex;
                            flex-direction: column;
                            gap: 8px;
                            overflow-y: auto;
                            scrollbar-width: none;
                        }

                        .pd-thumb-list::-webkit-scrollbar {
                            display: none;
                        }

                        /* Ảnh nhỏ: ô vuông, không viền; ảnh đang chọn sáng rõ, ảnh khác mờ nhẹ */
                        .pd-thumb {
                            flex-shrink: 0;
                            width: 100%;
                            aspect-ratio: 1 / 1;
                            padding: 0;
                            border: none;
                            border-radius: 0;
                            background: transparent;
                            cursor: pointer;
                            opacity: .5;
                            transition: opacity .15s;
                        }

                        .pd-thumb img {
                            width: 100%;
                            height: 100%;
                            object-fit: contain;
                            display: block;
                            mix-blend-mode: multiply;
                        }

                        .pd-thumb:hover {
                            opacity: .85;
                        }

                        .pd-thumb.on {
                            opacity: 1;
                        }

                        .pd-thumb:focus-visible {
                            outline: 2px solid var(--o);
                            outline-offset: 2px;
                        }

                        /* Ảnh lớn: ô vuông, lấp đầy cột, không viền, không bo góc */
                        .pd-main {
                            position: relative;
                            aspect-ratio: 1 / 1;
                            border: none;
                            border-radius: 0;
                            background: transparent;
                            overflow: hidden;
                            display: flex;
                            align-items: center;
                            justify-content: center;
                        }

                        .pd-main img {
                            position: relative;
                            z-index: 1;
                            width: 100%;
                            height: 100%;
                            object-fit: contain;
                            mix-blend-mode: multiply;
                        }

                        .pd-main .none {
                            display: none;
                            position: absolute;
                            color: var(--muted);
                            font-size: 13px;
                        }

                        .pd-main.noimg .none {
                            display: block;
                        }

                        /* chỉ hiện khi không có ảnh hoặc ảnh lỗi */
                        .pd-flag {
                            position: absolute;
                            top: 14px;
                            left: 14px;
                            z-index: 2;
                            padding: 5px 12px;
                            border-radius: 999px;
                            background: var(--o);
                            color: #fff;
                            font-size: 12px;
                            font-weight: 800;
                        }

                        .pd-flag.sale {
                            background: var(--danger);
                        }

                        /* Thông tin */
                        .pd-title {
                            margin: 0 0 8px;
                            font-size: 26px;
                            line-height: 1.25;
                            font-weight: 800;
                            color: var(--head);
                            text-transform: uppercase;
                        }

                        .pd-sub {
                            display: flex;
                            flex-wrap: wrap;
                            align-items: center;
                            gap: 14px;
                            font-size: 13px;
                            color: var(--muted);
                        }

                        .pd-price-row {
                            display: flex;
                            flex-wrap: wrap;
                            align-items: baseline;
                            gap: 12px;
                            margin: 14px 0 6px;
                        }

                        .pd-price {
                            font-size: 32px;
                            font-weight: 800;
                            color: var(--od);
                        }

                        .pd-old {
                            font-size: 16px;
                            color: var(--muted);
                            text-decoration: line-through;
                        }

                        .pd-off {
                            padding: 3px 10px;
                            border-radius: 999px;
                            background: #FFE9E0;
                            color: var(--danger);
                            font-size: 12px;
                            font-weight: 800;
                        }

                        .pd-vat {
                            font-size: 12.5px;
                            color: var(--muted);
                        }

                        .pd-meta {
                            margin: 14px 0 4px;
                            padding: 14px 0;
                            border-top: 1px solid #F8EEDA;
                            border-bottom: 1px solid #F8EEDA;
                            display: grid;
                            gap: 6px;
                            font-size: 14px;
                        }

                        .pd-meta span {
                            color: var(--muted);
                            display: inline-block;
                            min-width: 110px;
                        }

                        .pd-meta>div {
                            display: flex;
                            align-items: baseline;
                        }

                        .pd-meta b {
                            color: var(--head);
                            font-weight: 700;
                        }

                        .pd-meta .ok {
                            color: var(--ok);
                        }

                        .pd-meta .out {
                            color: var(--danger);
                        }

                        .pd-label {
                            margin: 18px 0 10px;
                            font-size: 14px;
                            font-weight: 800;
                            color: var(--head);
                            display: flex;
                            align-items: baseline;
                            gap: 10px;
                        }

                        .pd-label small {
                            font-size: 12.5px;
                            font-weight: 600;
                            color: var(--muted);
                        }

                        .pd-sizes {
                            display: flex;
                            flex-wrap: wrap;
                            gap: 10px;
                        }

                        .pd-size {
                            min-width: 52px;
                            height: 44px;
                            padding: 0 14px;
                            border: 1.5px solid var(--line);
                            border-radius: 12px;
                            background: #fff;
                            color: var(--head);
                            font: inherit;
                            font-weight: 700;
                            font-size: 14px;
                            cursor: pointer;
                            transition: border-color .15s, background .15s, color .15s;
                        }

                        .pd-size:hover:not(:disabled) {
                            border-color: var(--o);
                        }

                        .pd-size.on {
                            border-color: var(--o);
                            background: var(--o);
                            color: #fff;
                        }

                        .pd-size:disabled {
                            color: #C9BDAE;
                            background: #F7F2EA;
                            text-decoration: line-through;
                            cursor: not-allowed;
                        }

                        .pd-sizes.shake {
                            animation: pd-shake .4s;
                        }

                        @keyframes pd-shake {
                            25% {
                                transform: translateX(-6px);
                            }

                            75% {
                                transform: translateX(6px);
                            }
                        }

                        .pd-stock {
                            margin-top: 10px;
                            font-size: 13px;
                            color: var(--muted);
                            min-height: 18px;
                        }

                        .pd-stock.warn {
                            color: var(--danger);
                            font-weight: 700;
                        }

                        .pd-buy {
                            display: flex;
                            flex-wrap: wrap;
                            gap: 14px;
                            margin-top: 20px;
                            align-items: center;
                        }

                        .pd-qty {
                            display: inline-flex;
                            align-items: center;
                            border: 1.5px solid var(--line);
                            border-radius: 999px;
                            overflow: hidden;
                            background: #fff;
                        }

                        .pd-qty button {
                            width: 42px;
                            height: 46px;
                            border: none;
                            background: transparent;
                            font-size: 20px;
                            color: var(--head);
                            cursor: pointer;
                        }

                        .pd-qty button:hover {
                            background: var(--cream);
                        }

                        .pd-qty input {
                            width: 48px;
                            height: 46px;
                            border: none;
                            text-align: center;
                            font: inherit;
                            font-weight: 800;
                            color: var(--head);
                            background: transparent;
                            outline: none;
                            -moz-appearance: textfield;
                        }

                        .pd-qty input::-webkit-outer-spin-button,
                        .pd-qty input::-webkit-inner-spin-button {
                            -webkit-appearance: none;
                            margin: 0;
                        }

                        .pd-add {
                            flex: 1;
                            min-width: 220px;
                            height: 50px;
                            padding: 0 28px;
                            border: none;
                            border-radius: 999px;
                            background: var(--o);
                            color: #fff;
                            font: inherit;
                            font-size: 15px;
                            font-weight: 800;
                            cursor: pointer;
                            display: inline-flex;
                            align-items: center;
                            justify-content: center;
                            gap: 10px;
                            box-shadow: 0 12px 24px rgba(247, 148, 29, .3);
                            transition: background .15s, transform .1s;
                        }

                        .pd-add:hover:not(:disabled) {
                            background: var(--od);
                        }

                        .pd-add:active:not(:disabled) {
                            transform: translateY(1px);
                        }

                        .pd-add:disabled {
                            background: #D9CFC2;
                            box-shadow: none;
                            cursor: not-allowed;
                        }

                        .pd-msg {
                            margin-top: 12px;
                            font-size: 13px;
                            font-weight: 700;
                            min-height: 18px;
                        }

                        .pd-msg.err {
                            color: var(--danger);
                        }

                        .pd-msg.ok {
                            color: var(--ok);
                        }

                        .pd-perks {
                            margin-top: 22px;
                            display: grid;
                            grid-template-columns: repeat(3, 1fr);
                            gap: 10px;
                        }

                        .pd-perk {
                            padding: 12px;
                            border-radius: 14px;
                            background: var(--cream);
                            border: 1px solid var(--line);
                            font-size: 12.5px;
                            color: var(--brown);
                            line-height: 1.4;
                        }

                        .pd-perk b {
                            display: block;
                            color: var(--head);
                            font-size: 13px;
                            margin-bottom: 2px;
                        }

                        /* Mô tả + gợi ý */
                        .pd-sec {
                            margin-top: 44px;
                        }

                        .pd-sec h2 {
                            margin: 0 0 14px;
                            font-size: 22px;
                            font-weight: 800;
                            color: var(--head);
                        }

                        .pd-desc {
                            padding: 22px 24px;
                            border: 1px solid #FBF0D6;
                            border-radius: 18px;
                            background: #fff;
                            font-size: 14.5px;
                            line-height: 1.7;
                            white-space: pre-line;
                            box-shadow: 0 8px 26px rgba(200, 140, 40, .06);
                        }

                        .pd-desc.empty {
                            color: var(--muted);
                        }

                        .pd-toast {
                            position: fixed;
                            left: 50%;
                            bottom: 28px;
                            z-index: 9999;
                            transform: translate(-50%, 20px);
                            opacity: 0;
                            pointer-events: none;
                            padding: 13px 22px;
                            border-radius: 999px;
                            background: #3B2412;
                            color: #fff;
                            font-weight: 700;
                            font-size: 14px;
                            box-shadow: 0 14px 30px rgba(0, 0, 0, .25);
                            transition: opacity .2s, transform .2s;
                        }

                        .pd-toast.show {
                            opacity: 1;
                            transform: translate(-50%, 0);
                        }

                        .pd-toast.err {
                            background: var(--danger);
                        }

                        @media (max-width: 900px) {
                            .pd-top {
                                grid-template-columns: 1fr;
                                gap: 24px;
                            }

                            .pd-gallery {
                                grid-template-columns: 1fr;
                            }

                            .pd-thumbs-col {
                                order: 2;
                            }

                            .pd-thumbs {
                                position: static;
                                flex-direction: row;
                                align-items: center;
                            }

                            .pd-thumb-list {
                                flex-direction: row;
                                overflow-x: auto;
                                overflow-y: hidden;
                            }

                            .pd-thumb {
                                width: 72px;
                            }

                            .pd-arrow {
                                width: 32px;
                                height: 72px;
                            }

                            .pd-title {
                                font-size: 21px;
                            }

                            .pd-perks {
                                grid-template-columns: 1fr;
                            }
                        }
                    </style>

                    <section class="pd">

                        <nav class="pd-crumb" aria-label="Điều hướng">
                            <a href="${ctx}/">Trang chủ</a><span>/</span>
                            <c:if test="${not empty product.category}">
                                <span>
                                    <c:out value="${product.category.name}" />
                                </span><span>/</span>
                            </c:if>
                            <b>
                                <c:out value="${product.name}" />
                            </b>
                        </nav>

                        <div class="pd-top">

                            <%--=====Ảnh=====--%>
                                <div class="pd-gallery ${not empty gallery ? '' : 'single'}">

                                    <c:if test="${not empty gallery}">
                                        <div class="pd-thumbs-col">
                                            <div class="pd-thumbs">
                                                <button type="button" class="pd-arrow" id="pdPrev"
                                                    aria-label="Ảnh trước">
                                                    <svg width="18" height="18" viewBox="0 0 24 24" fill="none"
                                                        stroke="currentColor" stroke-width="2.2" stroke-linecap="round"
                                                        stroke-linejoin="round">
                                                        <polyline points="18 15 12 9 6 15" />
                                                    </svg>
                                                </button>
                                                <div class="pd-thumb-list" id="pdThumbList">
                                                    <c:forEach var="g" items="${gallery}" varStatus="st">
                                                        <c:choose>
                                                            <c:when test="${fn:startsWith(g, 'http')}">
                                                                <c:set var="gsrc" value="${g}" />
                                                            </c:when>
                                                            <c:when test="${fn:startsWith(g, '/')}">
                                                                <c:set var="gsrc" value="${ctx}${g}" />
                                                            </c:when>
                                                            <c:otherwise>
                                                                <c:set var="gsrc"
                                                                    value="${ctx}/static/assets/images/${g}" />
                                                            </c:otherwise>
                                                        </c:choose>
                                                        <button type="button" class="pd-thumb ${st.first ? 'on' : ''}"
                                                            data-src="<c:out value='${gsrc}'/>"
                                                            aria-label="Ảnh ${st.index + 1}">
                                                            <img src="<c:out value='${gsrc}'/>" alt=""
                                                                onerror="this.style.display='none'">
                                                        </button>
                                                    </c:forEach>
                                                </div>
                                                <button type="button" class="pd-arrow" id="pdNext" aria-label="Ảnh sau">
                                                    <svg width="18" height="18" viewBox="0 0 24 24" fill="none"
                                                        stroke="currentColor" stroke-width="2.2" stroke-linecap="round"
                                                        stroke-linejoin="round">
                                                        <polyline points="6 9 12 15 18 9" />
                                                    </svg>
                                                </button>
                                            </div>
                                        </div>
                                    </c:if>

                                    <div class="pd-main ${empty firstSrc ? 'noimg' : ''}">
                                        <span class="none">Chưa có ảnh sản phẩm</span>
                                        <c:if test="${not empty firstSrc}">
                                            <img id="pdMain" src="<c:out value='${firstSrc}'/>"
                                                alt="<c:out value='${product.name}'/>"
                                                onerror="this.style.display='none'; this.parentNode.classList.add('noimg')">
                                        </c:if>
                                        <c:choose>
                                            <c:when test="${not empty product.badge}">
                                                <span class="pd-flag">
                                                    <c:out value="${product.badge}" />
                                                </span>
                                            </c:when>
                                            <c:when
                                                test="${not empty product.discountPercent and product.discountPercent gt 0}">
                                                <span class="pd-flag sale">-${product.discountPercent}%</span>
                                            </c:when>
                                        </c:choose>
                                    </div>
                                </div>

                                <%--=====Thông tin + mua hàng=====--%>
                                    <div class="pd-info" id="pdInfo" data-id="${product.id}"
                                        data-name="<c:out value='${product.name}'/>" data-price="${product.salePrice}"
                                        data-image="<c:out value='${firstSrc}'/>">

                                        <h1 class="pd-title">
                                            <c:out value="${product.name}" />
                                        </h1>

                                        <div class="pd-sub">
                                            <div class="rate">
                                                <span class="stars"
                                                    style="--rate:${product.avgRating * 20}%">★★★★★</span>
                                                <fmt:formatNumber value="${product.avgRating}" minFractionDigits="1"
                                                    maxFractionDigits="1" /> (${product.reviewCount} đánh giá)
                                            </div>
                                        </div>

                                        <div class="pd-price-row">
                                            <span class="pd-price">
                                                <fmt:formatNumber value="${product.salePrice}" type="number"
                                                    groupingUsed="true" />₫
                                            </span>
                                            <c:if test="${product.originalPrice gt product.salePrice}">
                                                <span class="pd-old">
                                                    <fmt:formatNumber value="${product.originalPrice}" type="number"
                                                        groupingUsed="true" />₫
                                                </span>
                                                <span class="pd-off">-${product.discountPercent}%</span>
                                            </c:if>
                                            <span class="pd-vat">(Đã bao gồm VAT)</span>
                                        </div>

                                        <div class="pd-meta">
                                            <div><span>Mã sản phẩm</span><b>PS-
                                                    <fmt:formatNumber value="${product.id}" pattern="0000" />
                                                </b></div>
                                            <c:if test="${not empty product.category}">
                                                <div><span>Danh mục</span><b>
                                                        <c:out value="${product.category.name}" />
                                                    </b></div>
                                            </c:if>
                                            <div><span>Tình trạng</span>
                                                <c:choose>
                                                    <c:when test="${totalStock gt 0}"><b class="ok">Còn hàng</b>
                                                    </c:when>
                                                    <c:otherwise><b class="out">Hết hàng</b></c:otherwise>
                                                </c:choose>
                                            </div>
                                        </div>

                                        <div class="pd-label">Chọn size <small id="pdSizeSel">(chưa chọn)</small></div>
                                        <div class="pd-sizes" id="pdSizes">
                                            <c:forEach var="d" items="${sizes}">
                                                <button type="button" class="pd-size"
                                                    data-size="<fmt:formatNumber value='${d.size}' pattern='#.#'/>"
                                                    data-stock="${d.stockQuantity}" ${d.stockQuantity le 0 ? 'disabled'
                                                    : '' }>
                                                    <fmt:formatNumber value="${d.size}" pattern="#.#" />
                                                </button>
                                            </c:forEach>
                                            <c:if test="${empty sizes}"><span class="pd-vat">Sản phẩm chưa có
                                                    size.</span></c:if>
                                        </div>
                                        <div class="pd-stock" id="pdStock">Vui lòng chọn size để xem số lượng còn lại.
                                        </div>

                                        <div class="pd-buy">
                                            <div class="pd-qty">
                                                <button type="button" id="pdMinus" aria-label="Giảm">−</button>
                                                <input type="number" id="pdQty" value="1" min="1" max="99"
                                                    inputmode="numeric" aria-label="Số lượng">
                                                <button type="button" id="pdPlus" aria-label="Tăng">+</button>
                                            </div>
                                            <button type="button" class="pd-add" id="pdAdd" ${totalStock le 0
                                                ? 'disabled' : '' }>
                                                <svg width="20" height="20" viewBox="0 0 24 24" fill="none"
                                                    stroke="currentColor" stroke-width="2.2" stroke-linecap="round"
                                                    stroke-linejoin="round" aria-hidden="true">
                                                    <circle cx="9" cy="21" r="1" />
                                                    <circle cx="20" cy="21" r="1" />
                                                    <path
                                                        d="M1 1h4l2.7 13.4a2 2 0 0 0 2 1.6h9.7a2 2 0 0 0 2-1.6L23 6H6" />
                                                </svg>
                                                <c:choose>
                                                    <c:when test="${totalStock le 0}">Hết hàng</c:when>
                                                    <c:otherwise>Thêm vào giỏ hàng</c:otherwise>
                                                </c:choose>
                                            </button>
                                        </div>
                                        <div class="pd-msg" id="pdMsg" role="status"></div>

                                        <div class="pd-perks">
                                            <div class="pd-perk"><b>100% chính hãng</b>Kiểm định kỹ 2 lớp trước khi
                                                giao.</div>
                                            <div class="pd-perk"><b>Đổi trả 30 ngày</b>Hỗ trợ đổi size nhanh chóng.
                                            </div>
                                            <div class="pd-perk"><b>Giao nhanh 2 giờ</b>Đóng hộp 2 lớp chống va đập.
                                            </div>
                                        </div>
                                    </div>
                        </div>

                        <%--=====Mô tả=====--%>
                            <div class="pd-sec">
                                <h2>Mô tả sản phẩm</h2>
                                <c:choose>
                                    <c:when test="${not empty description}">
                                        <div class="pd-desc">
                                            <c:out value="${description}" />
                                        </div>
                                    </c:when>
                                    <c:otherwise>
                                        <div class="pd-desc empty">Sản phẩm chưa có mô tả.</div>
                                    </c:otherwise>
                                </c:choose>
                            </div>

                            <%--=====Gợi ý=====--%>
                                <c:if test="${not empty related}">
                                    <div class="pd-sec">
                                        <h2>Có thể bạn cũng thích</h2>
                                        <div class="p-grid">
                                            <c:forEach var="p" items="${related}">
                                                <article class="p-card" data-href="${ctx}/products/${p.id}"
                                                    style="cursor:pointer">
                                                    <div class="p-media">
                                                        <svg class="ph">
                                                            <use href="#ic-shoe" />
                                                        </svg>
                                                        <c:if test="${not empty p.mainImageUrl}">
                                                            <c:choose>
                                                                <c:when test="${fn:startsWith(p.mainImageUrl, 'http')}">
                                                                    <c:set var="img" value="${p.mainImageUrl}" />
                                                                </c:when>
                                                                <c:when test="${fn:startsWith(p.mainImageUrl, '/')}">
                                                                    <c:set var="img" value="${ctx}${p.mainImageUrl}" />
                                                                </c:when>
                                                                <c:otherwise>
                                                                    <c:set var="img"
                                                                        value="${ctx}/static/assets/images/${p.mainImageUrl}" />
                                                                </c:otherwise>
                                                            </c:choose>
                                                            <img src="<c:out value='${img}'/>"
                                                                alt="<c:out value='${p.name}'/>"
                                                                onerror="this.style.display='none'">
                                                        </c:if>
                                                        <c:choose>
                                                            <c:when test="${not empty p.badge}"><span class="p-tag hot">
                                                                    <c:out value="${p.badge}" />
                                                                </span></c:when>
                                                            <c:when
                                                                test="${not empty p.discountPercent and p.discountPercent gt 0}">
                                                                <span class="p-tag sale">-${p.discountPercent}%</span>
                                                            </c:when>
                                                        </c:choose>
                                                    </div>
                                                    <div class="p-body">
                                                        <div class="p-brand">
                                                            <c:out value="${p.category.name}" />
                                                        </div>
                                                        <div class="p-name"><a href="${ctx}/products/${p.id}"
                                                                style="color:inherit;text-decoration:none">
                                                                <c:out value="${p.name}" />
                                                            </a></div>
                                                        <div class="rate">
                                                            <span class="stars"
                                                                style="--rate:${p.avgRating * 20}%">★★★★★</span>
                                                            <fmt:formatNumber value="${p.avgRating}"
                                                                minFractionDigits="1" maxFractionDigits="1" />
                                                            (${p.reviewCount})
                                                        </div>
                                                        <div class="p-foot">
                                                            <div>
                                                                <div class="price">
                                                                    <fmt:formatNumber value="${p.salePrice}"
                                                                        type="number" groupingUsed="true" />₫
                                                                </div>
                                                                <c:if test="${p.originalPrice gt p.salePrice}">
                                                                    <div class="old">
                                                                        <fmt:formatNumber value="${p.originalPrice}"
                                                                            type="number" groupingUsed="true" />₫
                                                                    </div>
                                                                </c:if>
                                                            </div>
                                                        </div>
                                                    </div>
                                                </article>
                                            </c:forEach>
                                        </div>
                                    </div>
                                </c:if>
                    </section>

                    <div class="pd-toast" id="pdToast" role="status"></div>

                    <script>
                        (function () {
                            /* ---------- Thư viện ảnh ---------- */
                            var thumbs = Array.prototype.slice.call(document.querySelectorAll('.pd-thumb'));
                            var mainImg = document.getElementById('pdMain');
                            var idx = 0;

                            function selectImage(i) {
                                if (!thumbs.length || !mainImg) return;
                                idx = (i + thumbs.length) % thumbs.length;
                                thumbs.forEach(function (t, k) { t.classList.toggle('on', k === idx); });
                                mainImg.style.display = '';
                                mainImg.parentNode.classList.remove('noimg');
                                mainImg.src = thumbs[idx].getAttribute('data-src');
                                thumbs[idx].scrollIntoView({ block: 'nearest', inline: 'nearest' });
                            }
                            thumbs.forEach(function (t, k) { t.addEventListener('click', function () { selectImage(k); }); });
                            var prev = document.getElementById('pdPrev');
                            var next = document.getElementById('pdNext');
                            if (prev) prev.addEventListener('click', function () { selectImage(idx - 1); });
                            if (next) next.addEventListener('click', function () { selectImage(idx + 1); });

                            /* ---------- Chọn size / số lượng ---------- */
                            var info = document.getElementById('pdInfo');
                            var sizeBox = document.getElementById('pdSizes');
                            var sizeBtns = Array.prototype.slice.call(sizeBox.querySelectorAll('.pd-size'));
                            var sizeLabel = document.getElementById('pdSizeSel');
                            var stockEl = document.getElementById('pdStock');
                            var qtyEl = document.getElementById('pdQty');
                            var msgEl = document.getElementById('pdMsg');
                            var selected = null;   // { size: '42', stock: 10 }

                            function setMsg(text, type) {
                                msgEl.textContent = text || '';
                                msgEl.className = 'pd-msg' + (type ? ' ' + type : '');
                            }

                            function maxQty() { return selected ? Math.max(1, selected.stock) : 99; }

                            function clampQty() {
                                var v = parseInt(qtyEl.value, 10);
                                if (isNaN(v) || v < 1) v = 1;
                                if (v > maxQty()) v = maxQty();
                                qtyEl.value = v;
                                return v;
                            }

                            sizeBtns.forEach(function (btn) {
                                btn.addEventListener('click', function () {
                                    sizeBtns.forEach(function (b) { b.classList.remove('on'); });
                                    btn.classList.add('on');
                                    selected = { size: btn.getAttribute('data-size'), stock: parseInt(btn.getAttribute('data-stock'), 10) || 0 };
                                    sizeLabel.textContent = '(Size ' + selected.size + ')';
                                    if (selected.stock <= 5) {
                                        stockEl.textContent = 'Chỉ còn ' + selected.stock + ' sản phẩm ở size này.';
                                        stockEl.className = 'pd-stock warn';
                                    } else {
                                        stockEl.textContent = 'Còn ' + selected.stock + ' sản phẩm.';
                                        stockEl.className = 'pd-stock';
                                    }
                                    clampQty();
                                    setMsg('');
                                });
                            });

                            document.getElementById('pdMinus').addEventListener('click', function () { qtyEl.value = (parseInt(qtyEl.value, 10) || 1) - 1; clampQty(); });
                            document.getElementById('pdPlus').addEventListener('click', function () { qtyEl.value = (parseInt(qtyEl.value, 10) || 1) + 1; clampQty(); });
                            qtyEl.addEventListener('change', clampQty);

                            /* ---------- Thông báo nhỏ ---------- */
                            var toastEl = document.getElementById('pdToast');
                            var toastTimer;
                            function toast(text, isErr) {
                                toastEl.textContent = text;
                                toastEl.className = 'pd-toast show' + (isErr ? ' err' : '');
                                clearTimeout(toastTimer);
                                toastTimer = setTimeout(function () { toastEl.className = 'pd-toast'; }, 2400);
                            }

                            /* ---------- Thêm vào giỏ hàng ----------
                               TẠM THỜI: lưu giỏ vào trình duyệt (localStorage) để thử giao diện.
                               Khi làm giỏ hàng thật, chỉ cần thay thân hàm addToCart bằng
                               fetch('${ctx}/cart/add', { method: 'POST', ... }). */
                            var CART_KEY = 'polysneaker_cart';

                            function addToCart(item) {
                                try {
                                    var cart = JSON.parse(localStorage.getItem(CART_KEY) || '[]');
                                    var found = null;
                                    cart.forEach(function (c) { if (c.productId === item.productId && c.size === item.size) found = c; });
                                    if (found) {
                                        found.qty = Math.min(found.qty + item.qty, item.stock);
                                    } else {
                                        cart.push(item);
                                    }
                                    localStorage.setItem(CART_KEY, JSON.stringify(cart));
                                    document.dispatchEvent(new CustomEvent('cart:changed', { detail: cart }));
                                    return true;
                                } catch (e) {
                                    return false;
                                }
                            }

                            document.getElementById('pdAdd').addEventListener('click', function () {
                                if (!selected) {
                                    setMsg('Vui lòng chọn size trước khi thêm vào giỏ hàng.', 'err');
                                    sizeBox.classList.remove('shake');
                                    void sizeBox.offsetWidth;   // chạy lại hiệu ứng rung
                                    sizeBox.classList.add('shake');
                                    return;
                                }
                                var qty = clampQty();
                                var ok = addToCart({
                                    productId: parseInt(info.getAttribute('data-id'), 10),
                                    name: info.getAttribute('data-name'),
                                    image: info.getAttribute('data-image'),
                                    price: Number(info.getAttribute('data-price')),
                                    size: selected.size,
                                    qty: qty,
                                    stock: selected.stock
                                });
                                if (ok) {
                                    setMsg('Đã thêm ' + qty + ' sản phẩm (size ' + selected.size + ') vào giỏ hàng.', 'ok');
                                    if (window.PolyCart) { window.PolyCart.open(); } else { toast('Đã thêm vào giỏ hàng'); }
                                } else {
                                    setMsg('Không thêm được vào giỏ hàng, vui lòng thử lại.', 'err');
                                    toast('Không thêm được vào giỏ hàng', true);
                                }
                            });

                            /* ---------- Thẻ sản phẩm gợi ý: bấm để xem chi tiết ---------- */
                            document.querySelectorAll('.p-card[data-href]').forEach(function (card) {
                                card.addEventListener('click', function (e) {
                                    if (e.target.closest('button, a')) return;
                                    window.location.href = card.getAttribute('data-href');
                                });
                            });
                        })();
                    </script>

                    <jsp:include page="/WEB-INF/views/layouts/footer.jsp" />