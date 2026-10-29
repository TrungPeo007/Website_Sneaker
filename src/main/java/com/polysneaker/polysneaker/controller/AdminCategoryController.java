package com.polysneaker.polysneaker.controller;

import com.polysneaker.polysneaker.dto.CategoryForm;
import com.polysneaker.polysneaker.dto.LoginUser;
import com.polysneaker.polysneaker.entity.Category;
import com.polysneaker.polysneaker.service.CategoryAdminService;
import jakarta.servlet.http.HttpSession;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.util.List;
import java.util.Map;

/** Quản lý danh mục: /admin/categories (chỉ ADMIN). */
@Controller
public class AdminCategoryController {

    private static final String VIEW_LIST = "admin/categories";
    private static final String VIEW_FORM = "admin/category-form";

    private final CategoryAdminService categoryService;

    public AdminCategoryController(CategoryAdminService categoryService) {
        this.categoryService = categoryService;
    }

    /** Chưa đăng nhập -> /login ; không phải ADMIN -> trang chủ ; hợp lệ -> null */
    private String guard(HttpSession session) {
        Object o = session.getAttribute(LoginUser.SESSION_KEY);
        if (!(o instanceof LoginUser user)) return "redirect:/login";
        if (!"ADMIN".equals(user.getRole())) return "redirect:/";   // nếu LoginUser là record: user.role()
        return null;
    }

    /** Đưa dữ liệu dùng chung cho form (các nhóm cha, có danh mục con hay không). */
    private void fillFormModel(Model model, CategoryForm form) {
        model.addAttribute("form", form);
        model.addAttribute("parents", categoryService.parentOptions(form.getId()));
        model.addAttribute("hasChildren", categoryService.hasChildren(form.getId()));
    }

    // ---------- Danh sách ----------
    @GetMapping("/admin/categories")
    public String list(HttpSession session, Model model) {
        String g = guard(session);
        if (g != null) return g;
        model.addAttribute("rows", categoryService.listRows());
        return VIEW_LIST;
    }

    // ---------- Thêm mới ----------
    @GetMapping("/admin/categories/new")
    public String createForm(HttpSession session, Model model) {
        String g = guard(session);
        if (g != null) return g;

        CategoryForm form = new CategoryForm();
        // Chỉ có đúng một nhóm (ví dụ "Shoes") thì chọn sẵn, vì sản phẩm chỉ gắn vào danh mục con
        List<Category> roots = categoryService.parentOptions(null);
        if (roots.size() == 1) {
            form.setParentId(roots.get(0).getId());
        }
        fillFormModel(model, form);
        return VIEW_FORM;
    }

    // ---------- Sửa ----------
    @GetMapping("/admin/categories/{id}/edit")
    public String editForm(@PathVariable Integer id, HttpSession session,
                           Model model, RedirectAttributes ra) {
        String g = guard(session);
        if (g != null) return g;
        try {
            fillFormModel(model, categoryService.toForm(id));
        } catch (IllegalArgumentException e) {
            ra.addFlashAttribute("error", e.getMessage());
            return "redirect:/admin/categories";
        }
        return VIEW_FORM;
    }

    // ---------- Lưu (thêm hoặc sửa) ----------
    @PostMapping("/admin/categories/save")
    public String save(@ModelAttribute("form") CategoryForm form, HttpSession session,
                       Model model, RedirectAttributes ra) {
        String g = guard(session);
        if (g != null) return g;

        Map<String, String> errors = categoryService.validate(form);
        if (errors.isEmpty()) {
            try {
                categoryService.save(form);
                ra.addFlashAttribute("success",
                        form.getId() == null ? "Đã thêm danh mục mới." : "Đã cập nhật danh mục.");
                return "redirect:/admin/categories";
            } catch (DataIntegrityViolationException | IllegalArgumentException e) {
                errors.put("general", "Không lưu được danh mục, vui lòng kiểm tra lại dữ liệu.");
            }
        }
        model.addAttribute("error", errors.values().iterator().next());
        fillFormModel(model, form);
        return VIEW_FORM;
    }

    // ---------- Xóa ----------
    @PostMapping("/admin/categories/{id}/delete")
    public String delete(@PathVariable Integer id, HttpSession session, RedirectAttributes ra) {
        String g = guard(session);
        if (g != null) return g;
        try {
            categoryService.delete(id);
            ra.addFlashAttribute("success", "Đã xóa danh mục.");
        } catch (IllegalStateException | IllegalArgumentException e) {
            ra.addFlashAttribute("error", e.getMessage());          // còn sản phẩm / danh mục con...
        } catch (DataIntegrityViolationException e) {
            ra.addFlashAttribute("error", "Không xóa được danh mục này vì đang được sử dụng.");
        }
        return "redirect:/admin/categories";
    }
}