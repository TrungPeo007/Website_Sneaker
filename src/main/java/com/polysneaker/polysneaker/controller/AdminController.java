package com.polysneaker.polysneaker.controller;

import com.polysneaker.polysneaker.dto.LoginUser;
import com.polysneaker.polysneaker.dto.ProductForm;
import com.polysneaker.polysneaker.service.ProductService;
import jakarta.servlet.http.HttpSession;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.util.Map;

@Controller
public class AdminController {

    // Đổi 2 dòng này cho khớp vị trí file JSP của anh
    private static final String VIEW_LIST = "admin/products";
    private static final String VIEW_FORM = "admin/product-form";

    private final ProductService productService;

    public AdminController(ProductService productService) {
        this.productService = productService;
    }
    private String guard(HttpSession session) {
        Object o = session.getAttribute(LoginUser.SESSION_KEY);
        if (!(o instanceof LoginUser user)) return "redirect:/login";
        if (!"ADMIN".equals(user.getRole())) return "redirect:/";   // nếu LoginUser là record: user.role()
        return null;
    }

    // ---------- Danh sách ----------
    @GetMapping({"/admin", "/admin/products"})
    public String list(HttpSession session, Model model) {
        String g = guard(session);
        if (g != null) return g;
        model.addAttribute("products", productService.findAllForAdmin());
        return VIEW_LIST;
    }

    // ---------- Thêm mới ----------
    @GetMapping("/admin/products/new")
    public String createForm(HttpSession session, Model model) {
        String g = guard(session);
        if (g != null) return g;
        model.addAttribute("form", new ProductForm());
        model.addAttribute("categories", productService.findSelectableCategories());
        return VIEW_FORM;
    }

    // ---------- Sửa ----------
    @GetMapping("/admin/products/{id}/edit")
    public String editForm(@PathVariable Integer id, HttpSession session,
                           Model model, RedirectAttributes ra) {
        String g = guard(session);
        if (g != null) return g;
        try {
            model.addAttribute("form", productService.toForm(id));
        } catch (IllegalArgumentException e) {
            ra.addFlashAttribute("error", e.getMessage());
            return "redirect:/admin/products";
        }
        model.addAttribute("categories", productService.findSelectableCategories());
        return VIEW_FORM;
    }

    // ---------- Lưu (thêm hoặc sửa) ----------
    @PostMapping("/admin/products/save")
    public String save(@ModelAttribute("form") ProductForm form, HttpSession session,
                       Model model, RedirectAttributes ra) {
        String g = guard(session);
        if (g != null) return g;

        Map<String, String> errors = productService.validate(form);
        if (errors.isEmpty()) {
            try {
                productService.save(form);
                ra.addFlashAttribute("success",
                        form.getId() == null ? "Đã thêm sản phẩm mới." : "Đã cập nhật sản phẩm.");
                return "redirect:/admin/products";
            } catch (DataIntegrityViolationException | IllegalArgumentException e) {
                errors.put("general", "Không lưu được sản phẩm, vui lòng kiểm tra lại dữ liệu.");
            }
        }
        model.addAttribute("error", errors.values().iterator().next());
        model.addAttribute("categories", productService.findSelectableCategories());
        return VIEW_FORM;
    }

    // ---------- Xóa ----------
    @PostMapping("/admin/products/{id}/delete")
    public String delete(@PathVariable Integer id, HttpSession session, RedirectAttributes ra) {
        String g = guard(session);
        if (g != null) return g;
        try {
            productService.delete(id);
            ra.addFlashAttribute("success", "Đã xóa sản phẩm.");
        } catch (Exception e) {
            ra.addFlashAttribute("error", "Không xóa được sản phẩm này.");
        }
        return "redirect:/admin/products";
    }
}