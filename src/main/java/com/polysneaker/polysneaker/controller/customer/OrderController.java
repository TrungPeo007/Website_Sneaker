package com.polysneaker.polysneaker.controller.customer;

import com.polysneaker.polysneaker.security.CurrentUser;
import com.polysneaker.polysneaker.service.exception.ShopException;
import com.polysneaker.polysneaker.service.orders.OrderService;

import jakarta.servlet.http.HttpSession;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.util.Map;

/**
 * Đơn hàng của tôi: đặt hàng thành công, danh sách, chi tiết, hủy đơn. Cần đăng nhập.
 * (Thanh toán nằm ở CheckoutController.)
 */
@Controller
public class OrderController {

    private final OrderService orderService;

    public OrderController(OrderService orderService) {
        this.orderService = orderService;
    }

    @GetMapping("/orders/{id}/success")
    public String orderSuccess(@PathVariable("id") int id, HttpSession session, Model model, RedirectAttributes ra) {
        CurrentUser u = CurrentUser.from(session);
        if (u == null) return "redirect:/login";
        Map<String, Object> order = orderService.myOrder(u.accountId(), id);
        if (order == null) {
            ra.addFlashAttribute("error", "Không tìm thấy đơn hàng");
            return "redirect:/orders";
        }
        model.addAttribute("order", order);
        model.addAttribute("lines", orderService.orderLines(id));
        return "order-success";
    }

    @GetMapping("/orders")
    public String orders(HttpSession session, Model model) {
        CurrentUser u = CurrentUser.from(session);
        if (u == null) return "redirect:/login";
        model.addAttribute("orders", orderService.myOrders(u.accountId()));
        return "orders";
    }
    @GetMapping("/orders/{id}")
    public String orderDetail(@PathVariable("id") int id, HttpSession session, Model model, RedirectAttributes ra) {
        CurrentUser u = CurrentUser.from(session);
        if (u == null) return "redirect:/login";
        Map<String, Object> order = orderService.myOrder(u.accountId(), id);
        if (order == null) {
            ra.addFlashAttribute("error", "Không tìm thấy đơn hàng");
            return "redirect:/orders";
        }
        model.addAttribute("order", order);
        model.addAttribute("lines", orderService.orderLines(id));
        return "order-detail";
    }

    @PostMapping("/orders/{id}/cancel")
    public String cancel(@PathVariable("id") int id, HttpSession session, RedirectAttributes ra) {
        CurrentUser u = CurrentUser.from(session);
        if (u == null) return "redirect:/login";
        try {
            orderService.cancel(u.accountId(), id);
            ra.addFlashAttribute("success", "Đã hủy đơn #" + id);
        } catch (ShopException e) {
            ra.addFlashAttribute("error", e.getMessage());
        }
        return "redirect:/orders/" + id;
    }
}