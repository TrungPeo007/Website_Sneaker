package com.polysneaker.polysneaker.controller;

import com.polysneaker.polysneaker.repository.CategoryRepository;
import com.polysneaker.polysneaker.repository.ProductRepository;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;

@Controller
public class ShopController {

    private final ProductRepository productRepository;
    private final CategoryRepository categoryRepository;

    public ShopController(ProductRepository productRepository, CategoryRepository categoryRepository) {
        this.productRepository = productRepository;
        this.categoryRepository = categoryRepository;
    }

    @GetMapping("/shop")
    public String shop(@RequestParam(required = false) Integer category,
                       @RequestParam(required = false) String keyword,
                       Model model) {
        String kw = keyword == null ? "" : keyword.trim();

        model.addAttribute("activeMenu", "shop");   // để header tô sáng mục "Sản Phẩm"
        model.addAttribute("products", productRepository.search(category, kw));
        model.addAttribute("keyword", kw);
        if (category != null) {
            categoryRepository.findById(category)
                    .ifPresent(c -> model.addAttribute("currentCategory", c));
        }
        return "shop";  
    }
}