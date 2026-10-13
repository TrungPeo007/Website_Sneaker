package com.polysneaker.polysneaker.repository;

import com.polysneaker.polysneaker.entity.Category;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface CategoryRepository extends JpaRepository<Category, Integer> {

    // Danh mục con (ParentId khác NULL) đang hiển thị -> dùng cho ô chọn danh mục
    List<Category> findByParentIsNotNullAndActiveTrueOrderByNameAsc();
}