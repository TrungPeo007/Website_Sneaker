package com.polysneaker.polysneaker.service;

import com.polysneaker.polysneaker.dto.ProductForm;
import com.polysneaker.polysneaker.entity.Category;
import com.polysneaker.polysneaker.entity.Product;
import com.polysneaker.polysneaker.entity.ProductDetail;
import com.polysneaker.polysneaker.repository.CategoryRepository;
import com.polysneaker.polysneaker.repository.ProductRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class ProductService {

    private final ProductRepository productRepository;
    private final CategoryRepository categoryRepository;

    // ---------- Đọc ----------
    @Transactional(readOnly = true)
    public List<Product> findAllForAdmin() {
        return productRepository.findAllForAdmin();
    }

    @Transactional(readOnly = true)
    public List<Product> findHomeProducts(int limit) {
        return productRepository.findForHome(PageRequest.of(0, limit));
    }

    @Transactional(readOnly = true)
    public List<Category> findSelectableCategories() {
        return categoryRepository.findByParentIsNotNullAndActiveTrueOrderByNameAsc();
    }

    @Transactional(readOnly = true)
    public ProductForm toForm(Integer id) {
        Product p = productRepository.findDetailById(id)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy sản phẩm"));

        ProductForm f = new ProductForm();
        f.setId(p.getId());
        f.setName(p.getName());
        f.setCategoryId(p.getCategory().getId());
        f.setMainImageUrl(p.getMainImageUrl());
        f.setOriginalPrice(p.getOriginalPrice());
        f.setSalePrice(p.getSalePrice());
        f.setBadge(p.getBadge());
        f.setActive(p.isActive());
        for (ProductDetail d : p.getDetails()) {
            f.getSizes().add(d.getSize());
            f.getStocks().add(d.getStockQuantity());
            if (f.getDescription() == null) f.setDescription(d.getDescription());
        }
        return f;
    }

    // ---------- Kiểm tra dữ liệu ----------
    @Transactional(readOnly = true)
    public Map<String, String> validate(ProductForm f) {
        Map<String, String> errors = new LinkedHashMap<>();

        if (f.getName() == null || f.getName().isBlank()) {
            errors.put("name", "Vui lòng nhập tên sản phẩm.");
        } else if (f.getName().trim().length() > 200) {
            errors.put("name", "Tên sản phẩm tối đa 200 ký tự.");
        }

        if (f.getCategoryId() == null || !categoryRepository.existsById(f.getCategoryId())) {
            errors.put("categoryId", "Vui lòng chọn danh mục.");
        }

        if (f.getOriginalPrice() == null || f.getOriginalPrice().signum() < 0) {
            errors.put("originalPrice", "Giá gốc không hợp lệ.");
        }
        if (f.getSalePrice() == null || f.getSalePrice().signum() < 0) {
            errors.put("salePrice", "Giá bán không hợp lệ.");
        }
        if (!errors.containsKey("originalPrice") && !errors.containsKey("salePrice")
                && f.getSalePrice().compareTo(f.getOriginalPrice()) > 0) {
            errors.put("salePrice", "Giá bán không được lớn hơn giá gốc.");
        }

        if (f.getBadge() != null && f.getBadge().trim().length() > 30) {
            errors.put("badge", "Nhãn tối đa 30 ký tự.");
        }

        int validSizes = 0;
        for (int i = 0; i < f.getSizes().size(); i++) {
            BigDecimal size = f.getSizes().get(i);
            if (size == null) continue;               // dòng size để trống -> bỏ qua
            Integer stock = i < f.getStocks().size() ? f.getStocks().get(i) : null;
            if (size.signum() <= 0 || size.compareTo(new BigDecimal("99.9")) > 0) {
                errors.put("sizes", "Size phải lớn hơn 0 và nhỏ hơn 100.");
            } else if (stock != null && stock < 0) {
                errors.put("sizes", "Tồn kho không được âm.");
            }
            validSizes++;
        }
        if (validSizes == 0) {
            errors.put("sizes", "Vui lòng nhập ít nhất 1 size.");
        }
        return errors;
    }

    // ---------- Thêm / Sửa ----------
    @Transactional
    public void save(ProductForm f) {
        Product p = (f.getId() == null)
                ? new Product()
                : productRepository.findDetailById(f.getId())
                        .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy sản phẩm"));

        p.setName(f.getName().trim());
        p.setCategory(categoryRepository.getReferenceById(f.getCategoryId()));
        p.setMainImageUrl(blankToNull(f.getMainImageUrl()));
        p.setOriginalPrice(f.getOriginalPrice());
        p.setSalePrice(f.getSalePrice());
        p.setBadge(blankToNull(f.getBadge()));
        p.setActive(f.isActive());

        // Gom size -> tồn kho (bỏ dòng trống, size trùng thì lấy dòng sau)
        Map<BigDecimal, Integer> wanted = new LinkedHashMap<>();
        for (int i = 0; i < f.getSizes().size(); i++) {
            BigDecimal size = f.getSizes().get(i);
            if (size == null) continue;
            Integer stock = i < f.getStocks().size() ? f.getStocks().get(i) : null;
            wanted.put(size.setScale(1, RoundingMode.HALF_UP), stock == null ? 0 : stock);
        }

        // Xóa size không còn trong form
        p.getDetails().removeIf(d -> !wanted.containsKey(d.getSize().setScale(1, RoundingMode.HALF_UP)));

        // Thêm mới / cập nhật size (giữ nguyên SoldQuantity của size cũ)
        String desc = blankToNull(f.getDescription());
        for (Map.Entry<BigDecimal, Integer> e : wanted.entrySet()) {
            ProductDetail detail = p.getDetails().stream()
                    .filter(d -> d.getSize().compareTo(e.getKey()) == 0)
                    .findFirst()
                    .orElse(null);
            if (detail == null) {
                detail = new ProductDetail();
                detail.setProduct(p);
                detail.setSize(e.getKey());
                p.getDetails().add(detail);
            }
            detail.setStockQuantity(e.getValue());
            detail.setDescription(desc);
        }

        productRepository.save(p);
    }

    // ---------- Xóa ----------
    @Transactional
    public void delete(Integer id) {
        productRepository.deleteById(id);   // size + ảnh phụ bị xóa theo (ON DELETE CASCADE)
    }

    private static String blankToNull(String s) {
        return (s == null || s.isBlank()) ? null : s.trim();
    }
}