
package com.polysneaker.polysneaker.controller;

import com.polysneaker.polysneaker.service.Cart;
import com.polysneaker.polysneaker.service.CartService;
import com.polysneaker.polysneaker.service.CurrentUser;
import com.polysneaker.polysneaker.service.ShopException;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/cart")
public class CartApiController {

    private final CartService cartService;

    public CartApiController(CartService cartService) {
        this.cartService = cartService;
    }

    // =====================================================
    // GET: Lấy thông tin giỏ hàng
    // =====================================================

    @GetMapping
    public Map<String, Object> get(
            HttpSession session,
            HttpServletRequest request) {

        CurrentUser user = CurrentUser.from(session);

        if (user == null) {
            return notLoggedIn();
        }

        return payload(
                user.accountId(),
                request.getContextPath(),
                true,
                null
        );
    }

    // =====================================================
    // POST: Thêm sản phẩm vào giỏ hàng
    // =====================================================

    @PostMapping("/add")
    public Map<String, Object> add(
            @RequestParam(name = "productId", required = false)
            Integer productId,

            @RequestParam(name = "size", required = false)
            String size,

            @RequestParam(name = "productDetailId", required = false)
            Integer productDetailId,

            @RequestParam(name = "quantity", defaultValue = "1")
            int quantity,

            HttpSession session,
            HttpServletRequest request) {

        CurrentUser user = CurrentUser.from(session);

        if (user == null) {
            return notLoggedIn();
        }

        try {

            if (productDetailId != null) {

                cartService.add(
                        user.accountId(),
                        productDetailId,
                        quantity
                );

            } else if (productId != null) {

                if (size == null || size.isBlank()) {
                    throw new ShopException("Vui lòng chọn kích thước");
                }

                cartService.addBySize(
                        user.accountId(),
                        productId,
                        size,
                        quantity
                );

            } else {
                throw new ShopException("Thiếu thông tin sản phẩm");
            }

            return payload(
                    user.accountId(),
                    request.getContextPath(),
                    true,
                    "Đã thêm vào giỏ hàng"
            );

        } catch (ShopException e) {

            return payload(
                    user.accountId(),
                    request.getContextPath(),
                    false,
                    e.getMessage()
            );
        }
    }

    // =====================================================
    // POST: Cập nhật số lượng sản phẩm
    // =====================================================

    @PostMapping("/update")
    public Map<String, Object> update(
            @RequestParam("cartItemId") int cartItemId,
            @RequestParam("quantity") int quantity,

            HttpSession session,
            HttpServletRequest request) {

        CurrentUser user = CurrentUser.from(session);

        if (user == null) {
            return notLoggedIn();
        }

        try {

            cartService.setQuantity(
                    user.accountId(),
                    cartItemId,
                    quantity
            );

            return payload(
                    user.accountId(),
                    request.getContextPath(),
                    true,
                    "Đã cập nhật giỏ hàng"
            );

        } catch (ShopException e) {

            return payload(
                    user.accountId(),
                    request.getContextPath(),
                    false,
                    e.getMessage()
            );
        }
    }

    // =====================================================
    // POST: Xóa sản phẩm khỏi giỏ hàng
    // =====================================================

    @PostMapping("/remove")
    public Map<String, Object> remove(
            @RequestParam("cartItemId") int cartItemId,

            HttpSession session,
            HttpServletRequest request) {

        CurrentUser user = CurrentUser.from(session);

        if (user == null) {
            return notLoggedIn();
        }

        try {

            cartService.remove(
                    user.accountId(),
                    cartItemId
            );

            return payload(
                    user.accountId(),
                    request.getContextPath(),
                    true,
                    "Đã xóa sản phẩm khỏi giỏ hàng"
            );

        } catch (ShopException e) {

            return payload(
                    user.accountId(),
                    request.getContextPath(),
                    false,
                    e.getMessage()
            );
        }
    }

    // =====================================================
    // RESPONSE: Khi chưa đăng nhập
    // =====================================================

    private Map<String, Object> notLoggedIn() {

        Map<String, Object> res = new LinkedHashMap<>();

        res.put("ok", false);
        res.put("login", true);
        res.put("message", "Vui lòng đăng nhập để mua hàng");
        res.put("count", 0);
        res.put("subtotal", 0);
        res.put("items", new ArrayList<>());

        return res;
    }

    // =====================================================
    // RESPONSE: Dữ liệu giỏ hàng
    // =====================================================

    private Map<String, Object> payload(
            int accountId,
            String ctx,
            boolean ok,
            String message) {

        Cart cart = cartService.load(accountId);

        List<Map<String, Object>> items = new ArrayList<>();

        for (Map<String, Object> it : cart.items()) {

            long price = numberValue(it.get("SalePrice")).longValue();

            int quantity = numberValue(it.get("Quantity")).intValue();

            Object size = it.get("Size");

            Map<String, Object> item = new LinkedHashMap<>();

            item.put("id", it.get("CartItemId"));
            item.put("productDetailId", it.get("ProductDetailId"));
            item.put("productId", it.get("ProductId"));

            item.put("name", it.get("ProductName"));

            item.put(
                    "image",
                    imageUrl(ctx, it.get("MainImageUrl"))
            );

            item.put("size", formatSize(size));

            item.put("price", price);

            item.put(
                    "originalPrice",
                    numberValue(it.get("OriginalPrice")).longValue()
            );

            item.put("quantity", quantity);

            item.put("stock", it.get("StockQuantity"));

            item.put(
                    "sellable",
                    numberValue(it.get("Sellable")).intValue() == 1
            );

            item.put("lineTotal", price * quantity);

            items.add(item);
        }

        Map<String, Object> res = new LinkedHashMap<>();

        res.put("ok", ok);
        res.put("message", message);
        res.put("login", false);
        res.put("count", cart.totalQuantity());
        res.put("subtotal", cart.subtotal());
        res.put("items", items);

        return res;
    }

    // =====================================================
    // HELPER: Chuyển dữ liệu số an toàn
    // =====================================================

    private static Number numberValue(Object value) {

        if (value instanceof Number number) {
            return number;
        }

        return 0;
    }

    // =====================================================
    // HELPER: Định dạng kích thước
    // =====================================================

    private static String formatSize(Object size) {

        if (size == null) {
            return "";
        }

        if (size instanceof BigDecimal bd) {
            return bd.stripTrailingZeros().toPlainString();
        }

        return size.toString();
    }

    // =====================================================
    // HELPER: Đường dẫn hình ảnh
    // =====================================================

    private static String imageUrl(String ctx, Object value) {

        if (value == null || value.toString().isBlank()) {
            return "";
        }

        String v = value.toString().trim();

        if (v.startsWith("http://") || v.startsWith("https://")) {
            return v;
        }

        if (v.startsWith("/")) {
            return ctx + v;
        }

        return ctx + "/static/assets/images/" + v;
    }
}
