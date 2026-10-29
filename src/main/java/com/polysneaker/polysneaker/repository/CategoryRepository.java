package com.polysneaker.polysneaker.repository;

import com.polysneaker.polysneaker.entity.Category;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface CategoryRepository extends JpaRepository<Category, Integer> {

    // Danh mục con (ParentId khác NULL) đang hiển thị -> dùng cho ô chọn danh mục của sản phẩm và menu
    List<Category> findByParentIsNotNullAndActiveTrueOrderByNameAsc();

    // Danh mục gốc (nhóm) -> dùng cho ô "Thuộc nhóm" khi thêm/sửa danh mục
    List<Category> findByParentIsNullOrderByNameAsc();

    // Kiểm tra trùng tên (không phân biệt hoa thường)
    boolean existsByNameIgnoreCase(String name);

    boolean existsByNameIgnoreCaseAndIdNot(String name, Integer id);

    // Đếm danh mục con của một danh mục
    long countByParentId(Integer parentId);
}