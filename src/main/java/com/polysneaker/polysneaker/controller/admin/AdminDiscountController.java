package com.polysneaker.polysneaker.controller.admin;

import com.polysneaker.polysneaker.security.CurrentUser;
import com.polysneaker.polysneaker.service.discount.DiscountService;
import com.polysneaker.polysneaker.service.discount.DiscountService.DiscountException;

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

/** Trang quản lý coupon + voucher. Chỉ role trong CurrentUser.MANAGER_ROLES (ADMIN, BOD) vào được. */
@Controller
@RequestMapping("/admin")
public class AdminDiscountController {

    private static final String VIEW = "admin/discount/";
    private final DiscountService service;

    public AdminDiscountController(DiscountService service) {
        this.service = service;
    }

    private CurrentUser guard(HttpSession session) {
        CurrentUser u = CurrentUser.from(session);
        return (u != null && u.isManager()) ? u : null;
    }

    // ------------------------------------------------------------ COUPON

    @GetMapping("/coupons")
    public String couponList(@RequestParam(name = "q", required = false) String q,
                             @RequestParam(name = "status", required = false) String status,
                             HttpSession session, Model model) {
        if (guard(session) == null) return "redirect:/login";
        model.addAttribute("coupons", service.listCoupons(q, status));
        model.addAttribute("q", q);
        model.addAttribute("status", status);
        model.addAttribute("adminMenu", "coupons");
        return VIEW + "coupon-list";
    }

    @GetMapping("/coupons/new")
    public String couponNew(HttpSession session, Model model) {
        if (guard(session) == null) return "redirect:/login";
        model.addAttribute("f", service.newCouponForm());
        model.addAttribute("adminMenu", "coupons");
        return VIEW + "coupon-form";
    }

    @GetMapping("/coupons/{id}/edit")
    public String couponEdit(@PathVariable("id") int id, HttpSession session, Model model, RedirectAttributes ra) {
        if (guard(session) == null) return "redirect:/login";
        Map<String, String> f = service.couponForm(id);
        if (f == null) {
            ra.addFlashAttribute("error", "Không tìm thấy coupon");
            return "redirect:/admin/coupons";
        }
        model.addAttribute("f", f);
        model.addAttribute("adminMenu", "coupons");
        return VIEW + "coupon-form";
    }

    @PostMapping("/coupons/save")
    public String couponSave(@RequestParam Map<String, String> p, HttpSession session,
                             Model model, RedirectAttributes ra) {
        CurrentUser u = guard(session);
        if (u == null) return "redirect:/login";
        try {
            service.saveCoupon(p, u);
            ra.addFlashAttribute("success", "Đã lưu coupon");
            return "redirect:/admin/coupons";
        } catch (DiscountException e) {
            model.addAttribute("error", e.getMessage());
            model.addAttribute("f", p);
            model.addAttribute("adminMenu", "coupons");
            return VIEW + "coupon-form";
        }
    }

    @PostMapping("/coupons/{id}/toggle")
    public String couponToggle(@PathVariable("id") int id, HttpSession session, RedirectAttributes ra) {
        CurrentUser u = guard(session);
        if (u == null) return "redirect:/login";
        try {
            service.toggleCoupon(id, u);
            ra.addFlashAttribute("success", "Đã đổi trạng thái coupon");
        } catch (DiscountException e) {
            ra.addFlashAttribute("error", e.getMessage());
        }
        return "redirect:/admin/coupons";
    }

    @PostMapping("/coupons/{id}/delete")
    public String couponDelete(@PathVariable("id") int id, HttpSession session, RedirectAttributes ra) {
        CurrentUser u = guard(session);
        if (u == null) return "redirect:/login";
        try {
            service.deleteCoupon(id, u);
            ra.addFlashAttribute("success", "Đã xóa coupon");
        } catch (DiscountException e) {
            ra.addFlashAttribute("error", e.getMessage());
        }
        return "redirect:/admin/coupons";
    }

    @GetMapping("/coupons/{id}/usages")
    public String couponUsages(@PathVariable("id") int id, HttpSession session, Model model, RedirectAttributes ra) {
        if (guard(session) == null) return "redirect:/login";
        Map<String, Object> info = service.couponInfo(id);
        if (info == null) {
            ra.addFlashAttribute("error", "Không tìm thấy coupon");
            return "redirect:/admin/coupons";
        }
        model.addAttribute("coupon", info);
        model.addAttribute("usages", service.couponUsages(id));
        model.addAttribute("adminMenu", "coupons");
        return VIEW + "coupon-usages";
    }

    // ------------------------------------------------------------ VOUCHER

    @GetMapping("/vouchers")
    public String voucherList(@RequestParam(name = "q", required = false) String q,
                              @RequestParam(name = "status", required = false) String status,
                              HttpSession session, Model model) {
        if (guard(session) == null) return "redirect:/login";
        model.addAttribute("vouchers", service.listVouchers(q, status));
        model.addAttribute("q", q);
        model.addAttribute("status", status);
        model.addAttribute("adminMenu", "vouchers");
        return VIEW + "voucher-list";
    }

    @GetMapping("/vouchers/new")
    public String voucherNew(HttpSession session, Model model) {
        if (guard(session) == null) return "redirect:/login";
        model.addAttribute("f", service.newVoucherForm());
        model.addAttribute("adminMenu", "vouchers");
        return VIEW + "voucher-form";
    }

    @PostMapping("/vouchers/issue")
    public String voucherIssue(@RequestParam Map<String, String> p, HttpSession session,
                               Model model, RedirectAttributes ra) {
        CurrentUser u = guard(session);
        if (u == null) return "redirect:/login";
        try {
            service.issueVoucher(p, u);
            ra.addFlashAttribute("success", "Đã cấp voucher");
            return "redirect:/admin/vouchers";
        } catch (DiscountException e) {
            model.addAttribute("error", e.getMessage());
            model.addAttribute("f", p);
            model.addAttribute("adminMenu", "vouchers");
            return VIEW + "voucher-form";
        }
    }

    @PostMapping("/vouchers/{id}/revoke")
    public String voucherRevoke(@PathVariable("id") int id, HttpSession session, RedirectAttributes ra) {
        CurrentUser u = guard(session);
        if (u == null) return "redirect:/login";
        try {
            service.revokeVoucher(id, u);
            ra.addFlashAttribute("success", "Đã thu hồi voucher");
        } catch (DiscountException e) {
            ra.addFlashAttribute("error", e.getMessage());
        }
        return "redirect:/admin/vouchers";
    }
}