package com.polysneaker.polysneaker.controller.admin;

import com.polysneaker.polysneaker.service.blog.BlogContentRenderer;
import com.polysneaker.polysneaker.service.blog.BlogImageResolver;
import com.polysneaker.polysneaker.service.blog.BlogService;
import com.polysneaker.polysneaker.dto.BlogForm;
import com.polysneaker.polysneaker.dto.LoginUser;
import com.polysneaker.polysneaker.entity.Blog;

import java.util.List;
import java.util.NoSuchElementException;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;

/**
 * Trang quản trị bài viết: /admin/blogs/**. Chỉ tài khoản ADMIN đã đăng nhập
 * mới vào được (kiểm tra bằng guard giống AdminLookbookController).
 */
@Controller
@RequestMapping("/admin/blogs")
public class AdminBlogController {

    private final BlogService service;
    private final BlogImageResolver images;
    private final BlogContentRenderer renderer;

    public AdminBlogController(BlogService service, BlogImageResolver images, BlogContentRenderer renderer) {
        this.service = service;
        this.images = images;
        this.renderer = renderer;
    }

    private String guard(HttpSession session) {
        Object o = session.getAttribute(LoginUser.SESSION_KEY);
        if (!(o instanceof LoginUser user))
            return "redirect:/login";
        if (!"ADMIN".equals(user.getRole()))
            return "redirect:/"; // nếu LoginUser là record: user.role()
        return null;
    }

    @GetMapping
    public String list(@RequestParam(name = "q", required = false) String q, HttpSession session,
            Model model, HttpServletRequest req) {
        String g = guard(session);
        if (g != null)
            return g;
        List<Blog> blogs = service.adminList(q);
        images.decorate(blogs, req.getContextPath());
        model.addAttribute("blogs", blogs);
        model.addAttribute("q", q == null ? "" : q);
        model.addAttribute("adminMenu", "blogs");
        return "admin/blogs";
    }

    @GetMapping("/new")
    public String create(HttpSession session, Model model, HttpServletRequest req) {
        String g = guard(session);
        if (g != null)
            return g;
        return showForm(model, new BlogForm(), req);
    }

    @GetMapping("/{id}/edit")
    public String edit(@PathVariable("id") int id, HttpSession session, Model model,
            HttpServletRequest req, RedirectAttributes ra) {
        String g = guard(session);
        if (g != null)
            return g;
        try {
            return showForm(model, BlogForm.from(service.get(id)), req);
        } catch (NoSuchElementException ex) {
            ra.addFlashAttribute("error", ex.getMessage());
            return "redirect:/admin/blogs";
        }
    }

    @PostMapping("/save")
    public String save(@ModelAttribute("form") BlogForm form, HttpSession session, Model model,
            HttpServletRequest req, RedirectAttributes ra) {
        String g = guard(session);
        if (g != null)
            return g;
        boolean isNew = form.getId() == null;
        try {
            service.save(form);
            ra.addFlashAttribute("success", isNew ? "Đã thêm bài viết." : "Đã lưu bài viết.");
            return "redirect:/admin/blogs";
        } catch (IllegalArgumentException | NoSuchElementException ex) {
            model.addAttribute("error", ex.getMessage());
            return showForm(model, form, req);
        }
    }

    @PostMapping("/{id}/toggle")
    public String toggle(@PathVariable("id") int id, HttpSession session, RedirectAttributes ra) {
        String g = guard(session);
        if (g != null)
            return g;
        try {
            boolean now = service.togglePublished(id);
            ra.addFlashAttribute("success", now ? "Đã đăng bài viết." : "Đã chuyển bài viết về nháp.");
        } catch (IllegalArgumentException | NoSuchElementException ex) {
            ra.addFlashAttribute("error", ex.getMessage());
        }
        return "redirect:/admin/blogs";
    }

    @PostMapping("/{id}/delete")
    public String delete(@PathVariable("id") int id, HttpSession session, RedirectAttributes ra) {
        String g = guard(session);
        if (g != null)
            return g;
        service.delete(id);
        ra.addFlashAttribute("success", "Đã xóa bài viết.");
        return "redirect:/admin/blogs";
    }

    /** Xem bài đúng như khách thấy, kể cả bài nháp. */
    @GetMapping("/{id}/preview")
    public String preview(@PathVariable("id") int id, HttpSession session, Model model,
            HttpServletRequest req, RedirectAttributes ra) {
        String g = guard(session);
        if (g != null)
            return g;
        String ctx = req.getContextPath();
        try {
            Blog blog = service.get(id);
            images.decorate(blog, ctx);
            List<Blog> others = service.others(id, 3);
            images.decorate(others, ctx);
            model.addAttribute("blog", blog);
            model.addAttribute("contentHtml", renderer.toHtml(blog.getContent(), ctx));
            model.addAttribute("others", others);
            model.addAttribute("preview", true);
            return "blog-detail";
        } catch (NoSuchElementException ex) {
            ra.addFlashAttribute("error", ex.getMessage());
            return "redirect:/admin/blogs";
        }
    }

    /**
     * Bản xem trước gọn để nhúng trong khung (iframe) ở trang quản trị, không dùng
     * giao diện khách.
     */
    @GetMapping("/{id}/preview-frame")
    public String previewFrame(@PathVariable("id") int id, HttpSession session,
            Model model, HttpServletRequest req) {
        String g = guard(session);
        if (g != null)
            return g;
        String ctx = req.getContextPath();
        try {
            Blog blog = service.get(id);
            images.decorate(blog, ctx);
            model.addAttribute("blog", blog);
            model.addAttribute("contentHtml", renderer.toHtml(blog.getContent(), ctx));
        } catch (NoSuchElementException ex) {
            model.addAttribute("error", ex.getMessage());
        }
        return "admin/blog-preview-frame";
    }

    private String showForm(Model model, BlogForm form, HttpServletRequest req) {
        String ctx = req.getContextPath();
        model.addAttribute("form", form);
        model.addAttribute("thumbSrc", images.resolve(form.getThumbnailUrl(), ctx));
        model.addAttribute("imgBase", images.base(ctx));
        model.addAttribute("adminMenu", "blogs");
        return "admin/blog-form";
    }
}