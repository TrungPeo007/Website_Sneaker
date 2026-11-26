package com.polysneaker.polysneaker.controller.customer;

import com.polysneaker.polysneaker.entity.SitePage;
import com.polysneaker.polysneaker.service.pages.SitePageService;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;

/** Trang chính sách / dịch vụ: /pages/{slug} (không cần đăng nhập). */
@Controller
public class SitePageController {

    private final SitePageService service;

    public SitePageController(SitePageService service) {
        this.service = service;
    }

    @GetMapping("/pages/{slug}")
    public String show(@PathVariable String slug, Model model) {
        SitePage p = service.findPublic(slug).orElse(null);
        if (p == null) return "redirect:/";      // không có hoặc đang ẩn -> về trang chủ

        model.addAttribute("sitePage", p);
        model.addAttribute("contentHtml", SitePageService.renderHtml(p.getContent()));
        return "site-page";
    }
}