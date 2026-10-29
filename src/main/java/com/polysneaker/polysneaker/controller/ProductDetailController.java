package com.polysneaker.polysneaker.controller;

import com.polysneaker.polysneaker.entity.Product;
import com.polysneaker.polysneaker.entity.ProductDetail;
import com.polysneaker.polysneaker.service.ProductDetailService;
import com.polysneaker.polysneaker.service.ProductService;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;

import java.util.List;
import java.util.Objects;

/** Trang chi tiết sản phẩm cho khách: /products/{id} (không cần đăng nhập). */
@Controller
public class ProductDetailController {

    private final ProductDetailService detailService;
    private final ProductService productService;

    public ProductDetailController(ProductDetailService detailService, ProductService productService) {
        this.detailService = detailService;
        this.productService = productService;
    }

    @GetMapping("/products/{id}")
    public String detail(@PathVariable Integer id, Model model) {
        Product product;
        try {
            product = detailService.getActiveProduct(id);
        } catch (IllegalArgumentException e) {
            return "redirect:/";           // không có hoặc đã ẩn -> về trang chủ
        }

        List<ProductDetail> sizes = detailService.sizesOf(product);

        model.addAttribute("product", product);
        model.addAttribute("sizes", sizes);
        model.addAttribute("totalStock", detailService.totalStock(sizes));
        model.addAttribute("gallery", detailService.galleryOf(product));
        model.addAttribute("description", detailService.descriptionOf(sizes));

        // Gợi ý "Có thể bạn cũng thích": sản phẩm trang chủ, bỏ chính nó, lấy 4 cái
        List<Product> related = productService.findHomeProducts(8).stream()
                .filter(x -> !Objects.equals(x.getId(), id))
                .limit(4)
                .toList();
        model.addAttribute("related", related);

        return "product-detail";            
    }
}