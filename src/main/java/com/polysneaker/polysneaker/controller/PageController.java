package com.polysneaker.polysneaker.controller;

import com.polysneaker.polysneaker.dto.LookbookDto;
import com.polysneaker.polysneaker.service.LookbookService;
import com.polysneaker.polysneaker.service.ProductService;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

import java.util.List;

@Controller
public class PageController {

    private final ProductService productService;
    private final LookbookService lookbookService;

    public PageController(ProductService productService, LookbookService lookbookService) {
        this.productService = productService;
        this.lookbookService = lookbookService;
    }

    @GetMapping("/")
    public String index(Model model) {
        model.addAttribute("products", productService.findHomeProducts(4));

        // 3 bộ sưu tập đang bật đầu tiên cho mục LookBook ở trang chủ
        List<LookbookDto> lookbooks = lookbookService.findActive();
        model.addAttribute("lookbooks", lookbooks.size() > 3 ? lookbooks.subList(0, 3) : lookbooks);

        return "index";
    }
}