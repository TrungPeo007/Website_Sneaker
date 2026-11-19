package com.polysneaker.polysneaker.controller;

import com.polysneaker.polysneaker.dto.LoginUser;
import com.polysneaker.polysneaker.dto.LookbookForm;
import com.polysneaker.polysneaker.service.LookbookService;
import jakarta.servlet.http.HttpSession;
import org.springframework.dao.DataAccessException;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.util.Map;

@Controller
public class AdminLookbookController {

    private static final String VIEW_LIST = "admin/lookbooks";
    private static final String VIEW_FORM = "admin/lookbook-form";

    private final LookbookService service;

    public AdminLookbookController(LookbookService service) {
        this.service = service;
    }

    private String guard(HttpSession session) {
        Object o = session.getAttribute(LoginUser.SESSION_KEY);
        if (!(o instanceof LoginUser user)) return "redirect:/login";
        if (!"ADMIN".equals(user.getRole())) return "redirect:/";   // nếu LoginUser là record: user.role()
        return null;
    }

    // ---------- Danh sách ----------
    @GetMapping("/admin/lookbooks")
    public String list(HttpSession session, Model model) {
        String g = guard(session);
        if (g != null) return g;
        model.addAttribute("lookbooks", service.findAllForAdmin());
        return VIEW_LIST;
    }

    // ---------- Thêm mới ----------
    @GetMapping("/admin/lookbooks/new")
    public String createForm(HttpSession session, Model model) {
        String g = guard(session);
        if (g != null) return g;
        model.addAttribute("form", new LookbookForm());
        model.addAttribute("productOptions", service.productOptions());
        return VIEW_FORM;
    }

    // ---------- Sửa ----------
    @GetMapping("/admin/lookbooks/{id}/edit")
    public String editForm(@PathVariable Integer id, HttpSession session,
                           Model model, RedirectAttributes ra) {
        String g = guard(session);
        if (g != null) return g;
        try {
            model.addAttribute("form", service.toForm(id));
        } catch (IllegalArgumentException e) {
            ra.addFlashAttribute("error", e.getMessage());
            return "redirect:/admin/lookbooks";
        }
        model.addAttribute("productOptions", service.productOptions());
        return VIEW_FORM;
    }

    // ---------- Lưu (thêm hoặc sửa) ----------
    @PostMapping("/admin/lookbooks/save")
    public String save(@ModelAttribute("form") LookbookForm form, HttpSession session,
                       Model model, RedirectAttributes ra) {
        String g = guard(session);
        if (g != null) return g;

        Map<String, String> errors = service.validate(form);
        if (errors.isEmpty()) {
            try {
                service.save(form);
                ra.addFlashAttribute("success",
                        form.getId() == null ? "Đã thêm bộ sưu tập mới." : "Đã cập nhật bộ sưu tập.");
                return "redirect:/admin/lookbooks";
            } catch (DataAccessException | IllegalArgumentException e) {
                errors.put("general", "Không lưu được bộ sưu tập, vui lòng kiểm tra lại dữ liệu.");
            }
        }
        model.addAttribute("error", errors.values().iterator().next());
        model.addAttribute("productOptions", service.productOptions());
        return VIEW_FORM;
    }

    // ---------- Xóa ----------
    @PostMapping("/admin/lookbooks/{id}/delete")
    public String delete(@PathVariable Integer id, HttpSession session, RedirectAttributes ra) {
        String g = guard(session);
        if (g != null) return g;
        try {
            service.delete(id);
            ra.addFlashAttribute("success", "Đã xóa bộ sưu tập.");
        } catch (Exception e) {
            ra.addFlashAttribute("error", "Không xóa được bộ sưu tập này.");
        }
        return "redirect:/admin/lookbooks";
    }
}