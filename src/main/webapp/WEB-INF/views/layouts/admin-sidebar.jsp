<%@ page pageEncoding="UTF-8" %>
<%-- Thanh bên trái của trang admin: logo, menu, đăng xuất. Mục sáng lên theo biến adminMenu --%>
<aside class="side">
    <div class="side-brand">
        <span class="side-logo">PS</span>
        <div>
            <div class="side-name">PolySneaker</div>
            <div class="side-role">Quản trị viên</div>
        </div>
    </div>
    <nav class="side-nav">
        <a href="${ctx}/admin" class="${adminMenu == 'dashboard' ? 'active' : ''}">Tổng quan</a>
        <a href="${ctx}/admin/banners" class="${adminMenu == 'banners' ? 'active' : ''}">Banner</a>
        <a href="${ctx}/admin/products" class="${adminMenu == 'products' ? 'active' : ''}">Sản phẩm</a>
        <a href="${ctx}/admin/categories" class="${adminMenu == 'categories' ? 'active' : ''}">Danh mục</a>
        <a href="${ctx}/admin/images" class="${adminMenu == 'images' ? 'active' : ''}">Hình ảnh</a>
        <a href="${ctx}/admin/blogs" class="${adminMenu == 'blogs' ? 'active' : ''}">Bài viết</a>
        <a href="${ctx}/admin/orders" class="${adminMenu == 'orders' ? 'active' : ''}">Đơn hàng</a>
        <a href="${ctx}/admin/lookbooks" class="${adminMenu == 'lookbooks' ? 'active' : ''}">LookBook</a>
        <a href="${ctx}/admin/customers" class="${adminMenu == 'customers' ? 'active' : ''}">Khách hàng</a>
    </nav>
    <div class="side-foot"><a href="${ctx}/logout">Đăng xuất</a></div>
</aside>
