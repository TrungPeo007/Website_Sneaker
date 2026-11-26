package com.polysneaker.polysneaker.controller.admin;

import com.polysneaker.polysneaker.dto.LoginUser;
import com.polysneaker.polysneaker.dto.SitePageForm;
import com.polysneaker.polysneaker.service.pages.SitePageService;

import jakarta.servlet.http.HttpSession;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.util.Map;

@Controller
public class AdminSitePageController {

    private static final String VIEW_LIST = "admin/pages";
    private static final String VIEW_FORM = "admin/page-form";

    private final SitePageService service;

    public AdminSitePageController(SitePageService service) {
        this.service = service;
    }

    private String guard(HttpSession session) {
        Object o = session.getAttribute(LoginUser.SESSION_KEY);
        if (!(o instanceof LoginUser user)) return "redirect:/login";
        if (!"ADMIN".equals(user.getRole())) return "redirect:/";   // nếu LoginUser là record: user.role()
        return null;
    }

    // ---------- Danh sách ----------
    @GetMapping("/admin/pages")
    public String list(HttpSession session, Model model) {
        String g = guard(session);
        if (g != null) return g;
        model.addAttribute("pages", service.findAllForAdmin());
        return VIEW_LIST;
    }

    // ---------- Thêm mới (có thể chọn sẵn cột footer: ?group=SERVICE | POLICY | NONE) ----------
    @GetMapping("/admin/pages/new")
    public String createForm(@RequestParam(required = false) String group,
                             HttpSession session, Model model) {
        String g = guard(session);
        if (g != null) return g;

        SitePageForm form = new SitePageForm();
        if (SitePageService.GROUP_SERVICE.equals(group)
                || SitePageService.GROUP_POLICY.equals(group)
                || SitePageService.GROUP_NONE.equals(group)) {
            form.setFooterGroup(group);
        }
        model.addAttribute("form", form);
        return VIEW_FORM;
    }

    // ---------- Sửa ----------
    @GetMapping("/admin/pages/{id}/edit")
    public String editForm(@PathVariable Integer id, HttpSession session,
                           Model model, RedirectAttributes ra) {
        String g = guard(session);
        if (g != null) return g;
        try {
            model.addAttribute("form", service.toForm(id));
        } catch (IllegalArgumentException e) {
            ra.addFlashAttribute("error", e.getMessage());
            return "redirect:/admin/pages";
        }
        return VIEW_FORM;
    }

    // ---------- Lưu (thêm hoặc sửa) ----------
    @PostMapping("/admin/pages/save")
    public String save(@ModelAttribute("form") SitePageForm form, HttpSession session,
                       Model model, RedirectAttributes ra) {
        String g = guard(session);
        if (g != null) return g;

        Map<String, String> errors = service.validate(form);
        if (errors.isEmpty()) {
            try {
                service.save(form);
                ra.addFlashAttribute("success",
                        form.getId() == null ? "Đã thêm trang mới." : "Đã lưu nội dung trang.");
                return "redirect:/admin/pages";
            } catch (DataIntegrityViolationException | IllegalArgumentException e) {
                errors.put("general", "Không lưu được trang, vui lòng kiểm tra lại dữ liệu.");
            }
        }
        model.addAttribute("error", errors.values().iterator().next());
        return VIEW_FORM;
    }

    // ---------- Xóa ----------
    @PostMapping("/admin/pages/{id}/delete")
    public String delete(@PathVariable Integer id, HttpSession session, RedirectAttributes ra) {
        String g = guard(session);
        if (g != null) return g;
        try {
            service.delete(id);
            ra.addFlashAttribute("success", "Đã xóa trang.");
        } catch (Exception e) {
            ra.addFlashAttribute("error", "Không xóa được trang này.");
        }
        return "redirect:/admin/pages";
    }
}