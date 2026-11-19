package com.polysneaker.polysneaker.controller;

import com.polysneaker.polysneaker.service.Cart;
import com.polysneaker.polysneaker.service.CartService;
import com.polysneaker.polysneaker.service.CurrentUser;
import com.polysneaker.polysneaker.service.DiscountService.DiscountException;
import com.polysneaker.polysneaker.service.OrderService;
import com.polysneaker.polysneaker.service.ShopException;
import jakarta.servlet.http.HttpSession;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * Thanh toán (checkout). Cần đăng nhập.
 * /checkout?items=12,15 : thanh toán đúng các dòng giỏ hàng được chọn (không có items thì lấy cả giỏ).
 * Đặt hàng xong chuyển sang /orders/{id}/success (trang đặt hàng thành công).
 */
@Controller
public class CheckoutController {

    private final CartService cartService;
    private final OrderService orderService;

    public CheckoutController(CartService cartService, OrderService orderService) {
        this.cartService = cartService;
        this.orderService = orderService;
    }

    @GetMapping("/checkout")
    public String checkoutPage(@RequestParam(name = "items", required = false) String items,
                               HttpSession session, Model model, RedirectAttributes ra) {
        CurrentUser u = CurrentUser.from(session);
        if (u == null) return "redirect:/login";

        Cart cart = cartService.load(u.accountId(), CartService.parseIds(items));
        if (cart.items().isEmpty()) {
            ra.addFlashAttribute("error", "Chưa có sản phẩm nào để thanh toán");
            return "redirect:/cart";
        }
        fill(model, cart, orderService.checkoutForm(u.accountId()));
        return "checkout";
    }

    @PostMapping("/checkout")
    public String checkout(@RequestParam Map<String, String> p, HttpSession session,
                           Model model, RedirectAttributes ra) {
        CurrentUser u = CurrentUser.from(session);
        if (u == null) return "redirect:/login";

        Set<Integer> ids = CartService.parseIds(p.get("items"));
        try {
            int orderId = orderService.placeOrder(u.accountId(), ids, p);
            return "redirect:/orders/" + orderId + "/success";
        } catch (ShopException | DiscountException e) {
            Cart cart = cartService.load(u.accountId(), ids);
            if (cart.items().isEmpty()) {
                ra.addFlashAttribute("error", e.getMessage());
                return "redirect:/cart";
            }
            model.addAttribute("error", e.getMessage());
            fill(model, cart, p);
            return "checkout";
        }
    }

    private void fill(Model model, Cart cart, Map<String, String> form) {
        List<String> ids = new ArrayList<>();
        for (Map<String, Object> it : cart.items()) ids.add(String.valueOf(it.get("CartItemId")));
        model.addAttribute("items", cart.items());
        model.addAttribute("itemIds", String.join(",", ids));
        model.addAttribute("subtotal", cart.subtotal());
        model.addAttribute("f", form);
    }
}