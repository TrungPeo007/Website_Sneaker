package com.polysneaker.polysneaker.controller.customer;

import com.polysneaker.polysneaker.service.blog.BlogContentRenderer;
import com.polysneaker.polysneaker.service.blog.BlogImageResolver;
import com.polysneaker.polysneaker.service.blog.BlogService;
import com.polysneaker.polysneaker.entity.Blog;

import java.util.List;

import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.server.ResponseStatusException;

import jakarta.servlet.http.HttpServletRequest;

/** Trang blog cho khách: /blog và /blog/{slug}. Chỉ hiện bài đã đăng. */
@Controller
public class BlogController {

    private final BlogService service;
    private final BlogImageResolver images;
    private final BlogContentRenderer renderer;

    public BlogController(BlogService service, BlogImageResolver images, BlogContentRenderer renderer) {
        this.service = service;
        this.images = images;
        this.renderer = renderer;
    }

    @GetMapping("/blog")
    public String list(@RequestParam(name = "page", defaultValue = "0") int page, Model model, HttpServletRequest req) {
        int totalPages = service.totalPages();
        int current = Math.max(0, Math.min(page, Math.max(totalPages - 1, 0)));

        List<Blog> blogs = service.publishedPage(current);
        images.decorate(blogs, req.getContextPath());

        model.addAttribute("blogs", blogs);
        model.addAttribute("currentPage", current);
        model.addAttribute("totalPages", totalPages);
        return "blog-list";
    }

    @GetMapping("/blog/{slug}")
    public String detail(@PathVariable("slug") String slug, Model model, HttpServletRequest req) {
        String ctx = req.getContextPath();
        Blog blog = service.publishedBySlug(slug)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Không tìm thấy bài viết"));
        images.decorate(blog, ctx);
        List<Blog> others = service.others(blog.getId(), 3);
        images.decorate(others, ctx);

        model.addAttribute("blog", blog);
        model.addAttribute("contentHtml", renderer.toHtml(blog.getContent(), ctx));
        model.addAttribute("others", others);
        model.addAttribute("preview", false);
        return "blog-detail";
    }
}