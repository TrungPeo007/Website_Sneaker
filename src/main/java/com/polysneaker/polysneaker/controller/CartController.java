package com.polysneaker.polysneaker.controller;

import com.polysneaker.polysneaker.service.Cart;
import com.polysneaker.polysneaker.service.CartService;
import com.polysneaker.polysneaker.service.CurrentUser;
import com.polysneaker.polysneaker.service.ShopException;
import jakarta.servlet.http.HttpSession;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

/** Giỏ hàng của khách: xem, thêm, đổi số lượng, xóa. Cần đăng nhập (LoginRequiredInterceptor chặn trước). */
@Controller
@RequestMapping("/cart")
public class CartController {

    private final CartService cartService;

    public CartController(CartService cartService) {
        this.cartService = cartService;
    }

    @GetMapping
    public String cart(HttpSession session, Model model) {
        CurrentUser u = CurrentUser.from(session);
        if (u == null) return "redirect:/login";
        Cart cart = cartService.load(u.accountId());
        model.addAttribute("items", cart.items());
        model.addAttribute("subtotal", cart.subtotal());
        model.addAttribute("totalQuantity", cart.totalQuantity());
        return "cart";
    }

    /**
     * Form "Thêm vào giỏ" gửi productDetailId (id của size đã chọn) + quantity.
     * buyNow có giá trị thì chuyển sang thanh toán, chỉ với dòng vừa thêm.
     */
    @PostMapping("/add")
    public String add(@RequestParam("productDetailId") int productDetailId,
                      @RequestParam(name = "quantity", defaultValue = "1") int quantity,
                      @RequestParam(name = "buyNow", required = false) String buyNow,
                      HttpSession session, RedirectAttributes ra) {
        CurrentUser u = CurrentUser.from(session);
        if (u == null) return "redirect:/login";
        try {
            cartService.add(u.accountId(), productDetailId, quantity);

            if (buyNow != null) {
                Integer cartItemId = cartService.findCartItemId(u.accountId(), productDetailId);
                if (cartItemId != null) {
                    return "redirect:/checkout?items=" + cartItemId;
                }
            }
            ra.addFlashAttribute("success", "Đã thêm vào giỏ hàng");
        } catch (ShopException e) {
            ra.addFlashAttribute("error", e.getMessage());
        }
        return "redirect:/cart";
    }

    @PostMapping("/update")
    public String update(@RequestParam("cartItemId") int cartItemId,
                         @RequestParam("quantity") int quantity,
                         HttpSession session, RedirectAttributes ra) {
        CurrentUser u = CurrentUser.from(session);
        if (u == null) return "redirect:/login";
        try {
            cartService.setQuantity(u.accountId(), cartItemId, quantity);
        } catch (ShopException e) {
            ra.addFlashAttribute("error", e.getMessage());
        }
        return "redirect:/cart";
    }

    @PostMapping("/remove")
    public String remove(@RequestParam("cartItemId") int cartItemId, HttpSession session, RedirectAttributes ra) {
        CurrentUser u = CurrentUser.from(session);
        if (u == null) return "redirect:/login";
        try {
            cartService.remove(u.accountId(), cartItemId);
        } catch (ShopException e) {
            ra.addFlashAttribute("error", e.getMessage());
        }
        return "redirect:/cart";
    }
}