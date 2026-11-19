package com.polysneaker.polysneaker.service;

import com.polysneaker.polysneaker.dto.ProductForm;
import com.polysneaker.polysneaker.entity.Category;
import com.polysneaker.polysneaker.entity.Product;
import com.polysneaker.polysneaker.entity.ProductDetail;
import com.polysneaker.polysneaker.repository.CategoryRepository;
import com.polysneaker.polysneaker.repository.ProductRepository;
import org.springframework.data.domain.PageRequest;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

@Service
public class ProductService {

    private static final int MAX_GALLERY = 10;   // [ẢNH PHỤ]

    private final ProductRepository productRepository;
    private final CategoryRepository categoryRepository;
    private final JdbcTemplate jdbcTemplate;     // [ẢNH PHỤ]

    public ProductService(ProductRepository productRepository,
                          CategoryRepository categoryRepository,
                          JdbcTemplate jdbcTemplate) {
        this.productRepository = productRepository;
        this.categoryRepository = categoryRepository;
        this.jdbcTemplate = jdbcTemplate;
    }

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
        // Giá bán bằng giá gốc nghĩa là không giảm giá -> để trống ô "Giá bán" khi sửa
        boolean noDiscount = p.getSalePrice() == null
                || p.getSalePrice().compareTo(p.getOriginalPrice()) == 0;
        f.setSalePrice(noDiscount ? null : p.getSalePrice());
        f.setBadge(p.getBadge());
        f.setActive(p.isActive());
        for (ProductDetail d : p.getDetails()) {
            f.getSizes().add(d.getSize());
            f.getStocks().add(d.getStockQuantity());
            if (f.getDescription() == null) f.setDescription(d.getDescription());
            // [CHẤT LIỆU] lấy giá trị đầu tiên có chữ trong các size
            if (isBlank(f.getMaterial())) f.setMaterial(d.getMaterial());
            if (isBlank(f.getSpecifications())) f.setSpecifications(d.getSpecifications());
        }
        // [ẢNH PHỤ] nạp ảnh phụ đã lưu lên form (bỏ ảnh trùng với ảnh đại diện)
        f.setGalleryImages(loadGallery(p.getId(), p.getMainImageUrl()));
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

        // Giá gốc bắt buộc
        if (f.getOriginalPrice() == null || f.getOriginalPrice().signum() < 0) {
            errors.put("originalPrice", "Giá gốc không hợp lệ.");
        }
        // Giá bán không bắt buộc: để trống = không giảm giá. Nếu có nhập thì phải hợp lệ.
        if (f.getSalePrice() != null && f.getSalePrice().signum() < 0) {
            errors.put("salePrice", "Giá bán không hợp lệ.");
        }
        if (!errors.containsKey("originalPrice") && !errors.containsKey("salePrice")
                && f.getSalePrice() != null
                && f.getSalePrice().compareTo(f.getOriginalPrice()) > 0) {
            errors.put("salePrice", "Giá bán không được lớn hơn giá gốc.");
        }

        if (f.getBadge() != null && f.getBadge().trim().length() > 30) {
            errors.put("badge", "Nhãn tối đa 30 ký tự.");
        }

        // [CHẤT LIỆU] giới hạn độ dài (cột Material trong database dài tối đa 500 ký tự)
        if (f.getMaterial() != null && f.getMaterial().trim().length() > 500) {
            errors.put("material", "Chất liệu tối đa 500 ký tự.");
        }
        if (f.getSpecifications() != null && f.getSpecifications().length() > 20_000) {
            errors.put("specifications", "Thông số kỹ thuật quá dài (tối đa 20.000 ký tự).");
        }

        // [ẢNH PHỤ] tối đa 10 ảnh
        if (f.getGalleryImages() != null) {
            long count = f.getGalleryImages().stream().filter(s -> s != null && !s.isBlank()).count();
            if (count > MAX_GALLERY) {
                errors.put("galleryImages", "Chỉ được tối đa " + MAX_GALLERY + " ảnh phụ.");
            }
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
        // Không nhập giá bán -> sản phẩm không giảm giá -> giá bán = giá gốc
        p.setSalePrice(f.getSalePrice() != null ? f.getSalePrice() : f.getOriginalPrice());
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
        String material = blankToNull(f.getMaterial());               // [CHẤT LIỆU]
        String specs = blankToNull(f.getSpecifications());            // [CHẤT LIỆU]
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
            detail.setMaterial(material);                              // [CHẤT LIỆU]
            detail.setSpecifications(specs);                           // [CHẤT LIỆU]
        }

        Product saved = productRepository.save(p);

        // [ẢNH PHỤ] đặt SAU khi lưu: sản phẩm mới chỉ có id sau bước này.
        // Cùng một transaction nên nếu lỗi thì cả sản phẩm lẫn ảnh đều được hoàn tác.
        replaceGallery(saved.getId(), f.getGalleryImages(), saved.getMainImageUrl());
    }

    // ---------- Xóa ----------
    @Transactional
    public void delete(Integer id) {
        productRepository.deleteById(id);   // size + ảnh phụ bị xóa theo (ON DELETE CASCADE)
    }

    // ---------- [ẢNH PHỤ] đọc / ghi bảng ProductImages ----------
    private List<String> loadGallery(Integer productId, String mainImage) {
        String main = mainImage == null ? "" : mainImage.trim();
        List<String> out = new ArrayList<>();
        List<String> rows = jdbcTemplate.queryForList(
                "SELECT ImageUrl FROM ProductImages WHERE ProductId = ? ORDER BY SortOrder, ImageId",
                String.class, productId);
        for (String u : rows) {
            if (u == null || u.isBlank()) continue;
            String v = u.trim();
            if (!v.equals(main)) out.add(v);
        }
        return out;
    }

    /** Ghi lại toàn bộ ảnh phụ theo đúng thứ tự trên form: xóa hết cũ rồi chèn lại. */
    private void replaceGallery(Integer productId, List<String> names, String mainImage) {
        jdbcTemplate.update("DELETE FROM ProductImages WHERE ProductId = ?", productId);
        if (names == null) return;

        Set<String> seen = new HashSet<>();
        if (mainImage != null && !mainImage.isBlank()) {
            seen.add(mainImage.trim());                // không lặp lại ảnh đại diện
        }
        int order = 1;
        for (String n : names) {
            if (n == null) continue;
            String v = n.trim();
            if (v.isEmpty() || v.length() > 500 || !seen.add(v)) continue;   // bỏ trống, quá dài, trùng
            jdbcTemplate.update(
                    "INSERT INTO ProductImages (ProductId, ImageUrl, SortOrder) VALUES (?, ?, ?)",
                    productId, v, order++);
        }
    }

    private static boolean isBlank(String s) {
        return s == null || s.isBlank();
    }

    private static String blankToNull(String s) {
        return (s == null || s.isBlank()) ? null : s.trim();
    }
}