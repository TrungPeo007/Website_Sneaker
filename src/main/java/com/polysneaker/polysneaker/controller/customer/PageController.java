package com.polysneaker.polysneaker.controller.customer;

import com.polysneaker.polysneaker.dto.LookbookDto;
import com.polysneaker.polysneaker.entity.Blog;
import com.polysneaker.polysneaker.service.blog.BlogImageResolver;
import com.polysneaker.polysneaker.service.blog.BlogService;
import com.polysneaker.polysneaker.service.lookbooks.LookbookService;
import com.polysneaker.polysneaker.service.products.ProductService;

import jakarta.servlet.http.HttpServletRequest;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

import java.util.List;

@Controller
public class PageController {

    private final ProductService productService;
    private final LookbookService lookbookService;
    private final BlogService blogService;
    private final BlogImageResolver blogImages;

    public PageController(ProductService productService,
                          LookbookService lookbookService,
                          BlogService blogService,
                          BlogImageResolver blogImages) {
        this.productService = productService;
        this.lookbookService = lookbookService;
        this.blogService = blogService;
        this.blogImages = blogImages;
    }

    @GetMapping("/")
    public String index(Model model, HttpServletRequest req) {
        model.addAttribute("products", productService.findHomeProducts(4));

        // 3 bộ sưu tập đang bật đầu tiên cho mục LookBook ở trang chủ
        List<LookbookDto> lookbooks = lookbookService.findActive();
        model.addAttribute("lookbooks", lookbooks.size() > 3 ? lookbooks.subList(0, 3) : lookbooks);

        // 3 bài viết đã đăng mới nhất cho mục Blog ở trang chủ
        List<Blog> latestBlogs = blogService.publishedPage(0);
        if (latestBlogs.size() > 3) {
            latestBlogs = latestBlogs.subList(0, 3);
        }
        blogImages.decorate(latestBlogs, req.getContextPath());
        model.addAttribute("latestBlogs", latestBlogs);

        return "customer/homepage/index";
    }
}