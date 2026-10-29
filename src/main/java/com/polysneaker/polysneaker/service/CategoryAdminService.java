package com.polysneaker.polysneaker.service;

import com.polysneaker.polysneaker.dto.CategoryForm;
import com.polysneaker.polysneaker.dto.CategoryRow;
import com.polysneaker.polysneaker.entity.Category;
import com.polysneaker.polysneaker.repository.CategoryRepository;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * Quản lý danh mục cho trang admin. Cấu trúc 2 cấp:
 *   Nhóm (gốc, parent = null)  ->  Danh mục con (ví dụ Nike Jordan, Adidas Running)
 * Sản phẩm chỉ gắn vào danh mục con.
 */
@Service
public class CategoryAdminService {

    private static final Comparator<Category> BY_NAME =
            Comparator.comparing(Category::getName, String.CASE_INSENSITIVE_ORDER);

    private final CategoryRepository categoryRepository;
    private final JdbcTemplate jdbcTemplate;

    public CategoryAdminService(CategoryRepository categoryRepository, JdbcTemplate jdbcTemplate) {
        this.categoryRepository = categoryRepository;
        this.jdbcTemplate = jdbcTemplate;
    }

    // ---------- Danh sách (nhóm gốc, dưới mỗi nhóm là các danh mục con) ----------
    @Transactional(readOnly = true)
    public List<CategoryRow> listRows() {
        List<Category> all = categoryRepository.findAll();

        // Số sản phẩm theo từng danh mục
        Map<Integer, Integer> productCounts = new HashMap<>();
        jdbcTemplate.query("SELECT CategoryId, COUNT(*) AS Cnt FROM Products GROUP BY CategoryId",
                rs -> { productCounts.put(rs.getInt("CategoryId"), rs.getInt("Cnt")); });

        // Số danh mục con theo từng nhóm
        Map<Integer, Integer> childCounts = new HashMap<>();
        for (Category c : all) {
            if (c.getParent() != null) {
                childCounts.merge(c.getParent().getId(), 1, Integer::sum);
            }
        }

        List<Category> roots = new ArrayList<>();
        Map<Integer, List<Category>> childrenOf = new LinkedHashMap<>();
        for (Category c : all) {
            if (c.getParent() == null) {
                roots.add(c);
            } else {
                childrenOf.computeIfAbsent(c.getParent().getId(), k -> new ArrayList<>()).add(c);
            }
        }
        roots.sort(BY_NAME);

        List<CategoryRow> rows = new ArrayList<>();
        Set<Integer> added = new HashSet<>();
        for (Category root : roots) {
            rows.add(toRow(root, null, productCounts, childCounts));
            added.add(root.getId());

            // Copy sang ArrayList để sort được, kể cả khi nhóm chưa có danh mục con (List.of() là list chỉ đọc)
            List<Category> kids = new ArrayList<>(childrenOf.getOrDefault(root.getId(), List.of()));
            kids.sort(BY_NAME);
            for (Category kid : kids) {
                rows.add(toRow(kid, root.getName(), productCounts, childCounts));
                added.add(kid.getId());
            }
        }
        // Phòng trường hợp dữ liệu có cấp sâu hơn 2: vẫn hiện nốt ở cuối danh sách
        for (Category c : all) {
            if (!added.contains(c.getId())) {
                rows.add(toRow(c, c.getParent() == null ? null : c.getParent().getName(), productCounts, childCounts));
            }
        }
        return rows;
    }

    private CategoryRow toRow(Category c, String parentName,
                              Map<Integer, Integer> productCounts, Map<Integer, Integer> childCounts) {
        return new CategoryRow(
                c.getId(),
                c.getName(),
                c.getDescription(),
                parentName,
                c.isActive(),
                c.getParent() == null,
                productCounts.getOrDefault(c.getId(), 0),
                childCounts.getOrDefault(c.getId(), 0));
    }

    // ---------- Dữ liệu cho form ----------
    @Transactional(readOnly = true)
    public CategoryForm toForm(Integer id) {
        Category c = categoryRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy danh mục"));
        CategoryForm f = new CategoryForm();
        f.setId(c.getId());
        f.setName(c.getName());
        f.setParentId(c.getParent() == null ? null : c.getParent().getId());
        f.setDescription(c.getDescription());
        f.setActive(c.isActive());
        return f;
    }

    /** Các nhóm gốc để chọn làm "Thuộc nhóm" (bỏ chính danh mục đang sửa). */
    @Transactional(readOnly = true)
    public List<Category> parentOptions(Integer excludeId) {
        List<Category> roots = new ArrayList<>(categoryRepository.findByParentIsNullOrderByNameAsc());
        if (excludeId != null) {
            roots.removeIf(c -> excludeId.equals(c.getId()));
        }
        return roots;
    }

    @Transactional(readOnly = true)
    public boolean hasChildren(Integer id) {
        return id != null && categoryRepository.countByParentId(id) > 0;
    }

    // ---------- Kiểm tra dữ liệu ----------
    @Transactional(readOnly = true)
    public Map<String, String> validate(CategoryForm f) {
        Map<String, String> errors = new LinkedHashMap<>();

        String name = f.getName() == null ? "" : f.getName().trim();
        if (name.isEmpty()) {
            errors.put("name", "Vui lòng nhập tên danh mục.");
        } else if (name.length() > 100) {
            errors.put("name", "Tên danh mục tối đa 100 ký tự.");
        } else {
            boolean duplicated = (f.getId() == null)
                    ? categoryRepository.existsByNameIgnoreCase(name)
                    : categoryRepository.existsByNameIgnoreCaseAndIdNot(name, f.getId());
            if (duplicated) {
                errors.put("name", "Tên danh mục này đã tồn tại.");
            }
        }

        if (f.getDescription() != null && f.getDescription().trim().length() > 500) {
            errors.put("description", "Mô tả tối đa 500 ký tự.");
        }

        if (f.getParentId() != null) {
            if (f.getId() != null && f.getParentId().equals(f.getId())) {
                errors.put("parentId", "Danh mục không thể thuộc chính nó.");
            } else {
                Category parent = categoryRepository.findById(f.getParentId()).orElse(null);
                if (parent == null) {
                    errors.put("parentId", "Nhóm đã chọn không tồn tại.");
                } else if (parent.getParent() != null) {
                    errors.put("parentId", "Chỉ được chọn danh mục gốc (nhóm) làm nhóm cha.");
                } else if (f.getId() != null && hasChildren(f.getId())) {
                    errors.put("parentId", "Danh mục này đang có danh mục con nên không thể chuyển vào nhóm khác.");
                }
            }
        }
        return errors;
    }

    // ---------- Thêm / Sửa ----------
    @Transactional
    public void save(CategoryForm f) {
        Category c = (f.getId() == null)
                ? new Category()
                : categoryRepository.findById(f.getId())
                        .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy danh mục"));

        c.setName(f.getName().trim());
        c.setDescription(blankToNull(f.getDescription()));
        c.setParent(f.getParentId() == null ? null : categoryRepository.getReferenceById(f.getParentId()));
        c.setActive(f.isActive());
        categoryRepository.save(c);
    }

    // ---------- Xóa ----------
    /** Không xóa được khi còn danh mục con hoặc còn sản phẩm: ném IllegalStateException kèm lý do. */
    @Transactional
    public void delete(Integer id) {
        Category c = categoryRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy danh mục"));

        long children = categoryRepository.countByParentId(id);
        if (children > 0) {
            throw new IllegalStateException("Danh mục \"" + c.getName() + "\" đang có " + children
                    + " danh mục con. Hãy xóa hoặc chuyển các danh mục con trước.");
        }

        Integer products = jdbcTemplate.queryForObject(
                "SELECT COUNT(*) FROM Products WHERE CategoryId = ?", Integer.class, id);
        if (products != null && products > 0) {
            throw new IllegalStateException("Danh mục \"" + c.getName() + "\" đang có " + products
                    + " sản phẩm. Hãy chuyển các sản phẩm sang danh mục khác, hoặc tắt hiển thị danh mục thay vì xóa.");
        }

        categoryRepository.delete(c);
    }

    private static String blankToNull(String s) {
        return (s == null || s.isBlank()) ? null : s.trim();
    }
}