<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ taglib uri="jakarta.tags.core" prefix="c" %>

        <c:set var="ctx" value="${pageContext.request.contextPath}" />
        <c:set var="pageTitle" value="Cấp voucher" />
        <c:set var="adminMenu" value="vouchers" />
        <c:set var="pageCss" value="admin-voucher-form.css" />
        <%@ include file="/WEB-INF/views/layouts/admin-header.jsp" %>

            <div class="top">
                <div>
                    <h1 class="page-title">Cấp voucher</h1>
                    <p class="page-sub">Voucher riêng cho một khách, dùng được một lần</p>
                </div>
                <a href="${ctx}/admin/vouchers" class="btn-edit">&larr; Quay lại</a>
            </div>

            <c:if test="${not empty error}">
                <div class="alert err">
                    <c:out value="${error}" />
                </div>
            </c:if>

            <form class="card dc-card" method="post" action="${ctx}/admin/vouchers/issue">
                <div class="dc-grid">
                    <div class="dc-f w4">
                        <label for="username">Tài khoản khách (username) *</label>
                        <input type="text" id="username" name="username" value="<c:out value='${f.username}'/>"
                            required>
                    </div>
                    <div class="dc-f w4">
                        <label for="code">Mã voucher</label>
                        <input type="text" id="code" name="code" value="<c:out value='${f.code}'/>" maxlength="30"
                            style="text-transform:uppercase">
                        <small>Để trống = hệ thống tự sinh.</small>
                    </div>
                    <div class="dc-f w4">
                        <label for="title">Tiêu đề *</label>
                        <input type="text" id="title" name="title" value="<c:out value='${f.title}'/>" maxlength="200"
                            required>
                    </div>
                    <div class="dc-f w12">
                        <label for="reason">Lý do cấp</label>
                        <input type="text" id="reason" name="reason" value="<c:out value='${f.reason}'/>"
                            maxlength="300" placeholder="VD: Quà sinh nhật, đền bù đơn giao trễ...">
                    </div>

                    <div class="dc-f w3">
                        <label for="type">Loại giảm *</label>
                        <select id="type" name="type" onchange="syncType()">
                            <option value="AMOUNT" ${f.type=='AMOUNT' ? 'selected' : '' }>Giảm số tiền (VND)</option>
                            <option value="PERCENT" ${f.type=='PERCENT' ? 'selected' : '' }>Giảm theo %</option>
                        </select>
                    </div>
                    <div class="dc-f w3">
                        <label for="value" id="valueLabel">Mức giảm *</label>
                        <input type="text" id="value" name="value" value="<c:out value='${f.value}'/>" required>
                    </div>
                    <div class="dc-f w3" id="maxBox">
                        <label for="maxDiscount">Giảm tối đa (VND)</label>
                        <input type="text" id="maxDiscount" name="maxDiscount"
                            value="<c:out value='${f.maxDiscount}'/>">
                        <small>Để trống = không chặn.</small>
                    </div>
                    <div class="dc-f w3">
                        <label for="minOrder">Đơn tối thiểu (VND)</label>
                        <input type="text" id="minOrder" name="minOrder" value="<c:out value='${f.minOrder}'/>">
                    </div>

                    <div class="dc-f w6">
                        <label for="startsAt">Bắt đầu</label>
                        <input type="datetime-local" id="startsAt" name="startsAt"
                            value="<c:out value='${f.startsAt}'/>">
                        <small>Để trống = bắt đầu ngay.</small>
                    </div>
                    <div class="dc-f w6">
                        <label for="expiresAt">Hết hạn *</label>
                        <input type="datetime-local" id="expiresAt" name="expiresAt"
                            value="<c:out value='${f.expiresAt}'/>" required>
                    </div>
                </div>

                <div class="dc-actions">
                    <button type="submit" class="btn-add">Cấp voucher</button>
                    <a href="${ctx}/admin/vouchers" class="btn-edit">Hủy</a>
                </div>
            </form>

            <script>
                function syncType() {
                    var pct = document.getElementById('type').value === 'PERCENT';
                    var box = document.getElementById('maxBox');
                    box.style.display = pct ? '' : 'none';
                    if (pct) {
                        box.classList.remove('pop-in');
                        void box.offsetWidth;
                        box.classList.add('pop-in');
                    }
                    document.getElementById('valueLabel').textContent = pct ? 'Mức giảm (1-100 %) *' : 'Số tiền giảm (VND) *';
                }
                syncType();

                /* Nút xoay vòng khi gửi, chống bấm đúp */
                var form = document.querySelector('form.dc-card');
                var btn = form.querySelector('.btn-add');
                form.addEventListener('submit', function () { btn.classList.add('loading'); });
                window.addEventListener('pageshow', function () { btn.classList.remove('loading'); });
            </script>

            <%@ include file="/WEB-INF/views/layouts/admin-footer.jsp" %>