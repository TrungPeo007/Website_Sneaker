<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>

<c:set var="ctx" value="${pageContext.request.contextPath}" />
<c:set var="pageTitle" value="${empty f.id ? 'Thêm coupon' : 'Sửa coupon'}" />
<c:set var="adminMenu" value="coupons" />
<c:set var="pageCss" value="admin-coupon-form.css" />
<%@ include file="/WEB-INF/views/layouts/admin-header.jsp" %>

        <div class="top">
            <div>
                <h1 class="page-title">${empty f.id ? 'Thêm coupon' : 'Sửa coupon'}</h1>
                <p class="page-sub">Mã giảm giá công khai, khách nhập ở bước thanh toán</p>
            </div>
            <a href="${ctx}/admin/coupons" class="btn-edit">&larr; Quay lại</a>
        </div>

        <c:if test="${not empty error}">
            <div class="alert err"><c:out value="${error}"/></div>
        </c:if>

        <form class="card dc-card" method="post" action="${ctx}/admin/coupons/save">
            <input type="hidden" name="id" value="<c:out value='${f.id}'/>">

            <div class="dc-grid">
                <div class="dc-f w4">
                    <label for="code">Mã coupon *</label>
                    <input type="text" id="code" name="code" value="<c:out value='${f.code}'/>" maxlength="30"
                           placeholder="VD: SALE10" style="text-transform:uppercase" ${empty f.id ? '' : 'readonly'} required>
                    <small>Chữ, số, gạch ngang. Không đổi được sau khi tạo.</small>
                </div>
                <div class="dc-f w8">
                    <label for="title">Tiêu đề *</label>
                    <input type="text" id="title" name="title" value="<c:out value='${f.title}'/>" maxlength="200" required>
                </div>
                <div class="dc-f w12">
                    <label for="description">Mô tả</label>
                    <input type="text" id="description" name="description" value="<c:out value='${f.description}'/>" maxlength="500">
                </div>

                <div class="dc-f w3">
                    <label for="type">Loại giảm *</label>
                    <select id="type" name="type" onchange="syncType()">
                        <option value="PERCENT" ${f.type == 'PERCENT' ? 'selected' : ''}>Giảm theo %</option>
                        <option value="AMOUNT"  ${f.type == 'AMOUNT'  ? 'selected' : ''}>Giảm số tiền (VND)</option>
                    </select>
                </div>
                <div class="dc-f w3">
                    <label for="value" id="valueLabel">Mức giảm *</label>
                    <input type="text" id="value" name="value" value="<c:out value='${f.value}'/>" required>
                </div>
                <div class="dc-f w3" id="maxBox">
                    <label for="maxDiscount">Giảm tối đa (VND)</label>
                    <input type="text" id="maxDiscount" name="maxDiscount" value="<c:out value='${f.maxDiscount}'/>">
                    <small>Để trống = không chặn.</small>
                </div>
                <div class="dc-f w3">
                    <label for="minOrder">Đơn tối thiểu (VND)</label>
                    <input type="text" id="minOrder" name="minOrder" value="<c:out value='${f.minOrder}'/>">
                </div>

                <div class="dc-f w3">
                    <label for="usageLimit">Tổng lượt dùng</label>
                    <input type="text" id="usageLimit" name="usageLimit" value="<c:out value='${f.usageLimit}'/>">
                    <small>Để trống = không giới hạn.</small>
                </div>
                <div class="dc-f w3">
                    <label for="perAccountLimit">Lượt / tài khoản *</label>
                    <input type="text" id="perAccountLimit" name="perAccountLimit" value="<c:out value='${f.perAccountLimit}'/>">
                </div>
                <div class="dc-f w3">
                    <label for="startsAt">Bắt đầu</label>
                    <input type="datetime-local" id="startsAt" name="startsAt" value="<c:out value='${f.startsAt}'/>">
                    <small>Để trống = bắt đầu ngay.</small>
                </div>
                <div class="dc-f w3">
                    <label for="expiresAt">Hết hạn</label>
                    <input type="datetime-local" id="expiresAt" name="expiresAt" value="<c:out value='${f.expiresAt}'/>">
                    <small>Để trống = không hết hạn.</small>
                </div>

                <div class="dc-f w12">
                    <label class="dc-check">
                        <input type="checkbox" name="isActive" ${not empty f.isActive ? 'checked' : ''}>
                        <span>Đang bật (khách dùng được)</span>
                    </label>
                </div>
            </div>

            <div class="dc-actions">
                <button type="submit" class="btn-add">Lưu coupon</button>
                <a href="${ctx}/admin/coupons" class="btn-edit">Hủy</a>
            </div>
        </form>

<script>
    function syncType() {
        var pct = document.getElementById('type').value === 'PERCENT';
        document.getElementById('maxBox').style.display = pct ? '' : 'none';
        document.getElementById('valueLabel').textContent = pct ? 'Mức giảm (1-100 %) *' : 'Số tiền giảm (VND) *';
    }
    syncType();
</script>

<%@ include file="/WEB-INF/views/layouts/admin-footer.jsp" %>
