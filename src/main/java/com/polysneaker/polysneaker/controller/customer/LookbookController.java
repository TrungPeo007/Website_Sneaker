package com.polysneaker.polysneaker.controller.customer;

import com.polysneaker.polysneaker.dto.LookbookDto;
import com.polysneaker.polysneaker.service.lookbooks.LookbookService;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;

/** Bộ sưu tập cho khách: /lookbooks và /lookbooks/{id} (không cần đăng nhập). */
@Controller
public class LookbookController {

    private final LookbookService service;

    public LookbookController(LookbookService service) {
        this.service = service;
    }

    @GetMapping("/lookbooks")
    public String list(Model model) {
        model.addAttribute("lookbooks", service.findActive());
        return "lookbooks";
    }

    @GetMapping("/lookbooks/{id}")
    public String detail(@PathVariable Integer id, Model model) {
        LookbookDto lb = service.findActiveById(id).orElse(null);
        if (lb == null) return "redirect:/lookbooks";       // không có hoặc đang ẩn

        model.addAttribute("lookbook", lb);
        model.addAttribute("photos", service.photosOf(id));
        model.addAttribute("others", service.findActive().stream()
                .filter(x -> !x.getId().equals(id))
                .limit(6)
                .toList());
        return "lookbook-detail";
    }
}