package com.polysneaker.polysneaker.controller;
import com.polysneaker.polysneaker.service.AdminOrderService;
import com.polysneaker.polysneaker.service.CurrentUser;
import com.polysneaker.polysneaker.service.ShopException;
import jakarta.servlet.http.HttpSession;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.util.Map;

/**
 * Quản lý đơn hàng (admin). Chỉ role trong CurrentUser.MANAGER_ROLES (ADMIN, BOD).
 * "Thanh toán thành công" -> trừ tồn kho theo số lượng khách đặt (xem AdminOrderService).
 */
@Controller
@RequestMapping("/admin/orders")
public class AdminOrderController {

    private final AdminOrderService service;

    public AdminOrderController(AdminOrderService service) {
        this.service = service;
    }

    private CurrentUser guard(HttpSession session) {
        CurrentUser u = CurrentUser.from(session);
        return (u != null && u.isManager()) ? u : null;
    }

    @GetMapping
    public String list(HttpSession session, Model model) {
        if (guard(session) == null) return "redirect:/login";
        model.addAttribute("orders", service.list());
        model.addAttribute("adminMenu", "orders");
        return "admin/orders";
    }

    @GetMapping("/{id}")
    public String detail(@PathVariable("id") int id, HttpSession session, Model model, RedirectAttributes ra) {
        if (guard(session) == null) return "redirect:/login";
        Map<String, Object> order = service.find(id);
        if (order == null) {
            ra.addFlashAttribute("error", "Không tìm thấy đơn hàng");
            return "redirect:/admin/orders";
        }
        model.addAttribute("order", order);
        model.addAttribute("lines", service.lines(id));
        model.addAttribute("adminMenu", "orders");
        return "admin/order-detail";
    }

    /** Khách đã trả tiền: xác nhận thanh toán và trừ kho. back=list thì quay lại danh sách. */
    @PostMapping("/{id}/paid")
    public String paid(@PathVariable("id") int id,
                       @RequestParam(name = "back", required = false) String back,
                       HttpSession session, RedirectAttributes ra) {
        CurrentUser u = guard(session);
        if (u == null) return "redirect:/login";
        try {
            service.markPaid(u, id);
            ra.addFlashAttribute("success", "Đã xác nhận thanh toán đơn #" + id + " và trừ tồn kho theo số lượng khách đặt");
        } catch (ShopException e) {
            ra.addFlashAttribute("error", e.getMessage());
        }
        return redirect(id, back);
    }

    @PostMapping("/{id}/status")
    public String status(@PathVariable("id") int id,
                         @RequestParam("status") String status,
                         HttpSession session, RedirectAttributes ra) {
        CurrentUser u = guard(session);
        if (u == null) return "redirect:/login";
        try {
            service.advance(u, id, status);
            ra.addFlashAttribute("success", "Đã cập nhật trạng thái đơn #" + id);
        } catch (ShopException e) {
            ra.addFlashAttribute("error", e.getMessage());
        }
        return redirect(id, null);
    }

    @PostMapping("/{id}/cancel")
    public String cancel(@PathVariable("id") int id, HttpSession session, RedirectAttributes ra) {
        CurrentUser u = guard(session);
        if (u == null) return "redirect:/login";
        try {
            service.cancel(u, id);
            ra.addFlashAttribute("success", "Đã hủy đơn #" + id);
        } catch (ShopException e) {
            ra.addFlashAttribute("error", e.getMessage());
        }
        return redirect(id, null);
    }

    private static String redirect(int id, String back) {
        return "list".equals(back) ? "redirect:/admin/orders" : "redirect:/admin/orders/" + id;
    }
}