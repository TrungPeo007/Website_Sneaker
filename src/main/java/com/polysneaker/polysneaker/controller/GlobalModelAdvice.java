package com.polysneaker.polysneaker.controller;

import com.polysneaker.polysneaker.entity.Category;
import com.polysneaker.polysneaker.repository.CategoryRepository;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ModelAttribute;

import java.util.List;

/** Đưa dữ liệu dùng chung cho header (menu "Sản Phẩm") vào mọi trang. */
@ControllerAdvice
public class GlobalModelAdvice {

    private final CategoryRepository categoryRepository;

    public GlobalModelAdvice(CategoryRepository categoryRepository) {
        this.categoryRepository = categoryRepository;
    }

    // Tên "menuCategories" khớp với header.jsp
    @ModelAttribute("menuCategories")
    public List<Category> menuCategories(HttpServletRequest request) {
        // Trang admin dùng sidebar riêng, không có header cửa hàng nên khỏi truy vấn
        String path = request.getRequestURI();
        if (path.startsWith(request.getContextPath() + "/admin")) {
            return List.of();
        }
        return categoryRepository.findByParentIsNotNullAndActiveTrueOrderByNameAsc();
    }
}