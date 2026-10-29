package com.polysneaker.polysneaker.service;

import com.polysneaker.polysneaker.entity.Product;
import com.polysneaker.polysneaker.entity.ProductDetail;
import com.polysneaker.polysneaker.repository.ProductRepository;
import org.springframework.dao.DataAccessException;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.Comparator;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;

/**
 * Dữ liệu cho trang chi tiết sản phẩm (phía khách hàng).
 * Tách riêng khỏi ProductService (dùng cho admin) để không đụng vào code đang chạy.
 */
@Service
public class ProductDetailService {

    private final ProductRepository productRepository;
    private final JdbcTemplate jdbcTemplate;

    public ProductDetailService(ProductRepository productRepository, JdbcTemplate jdbcTemplate) {
        this.productRepository = productRepository;
        this.jdbcTemplate = jdbcTemplate;
    }

    /** Lấy sản phẩm đang bán. Không có hoặc đang ẩn thì ném IllegalArgumentException. */
    @Transactional(readOnly = true)
    public Product getActiveProduct(Integer id) {
        Product p = productRepository.findDetailById(id)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy sản phẩm"));
        if (!p.isActive()) {
            throw new IllegalArgumentException("Sản phẩm hiện không được bán");
        }
        return p;
    }

    /** Các size của sản phẩm, xếp từ nhỏ đến lớn. */
    @Transactional(readOnly = true)
    public List<ProductDetail> sizesOf(Product p) {
        List<ProductDetail> sizes = new ArrayList<>(p.getDetails());
        sizes.sort(Comparator.comparing(ProductDetail::getSize));
        return sizes;
    }

    /** Tổng tồn kho của mọi size. */
    public int totalStock(List<ProductDetail> sizes) {
        int total = 0;
        for (ProductDetail d : sizes) {
            Integer stock = d.getStockQuantity();
            total += (stock == null ? 0 : stock);
        }
        return total;
    }

    /** Mô tả sản phẩm: lấy mô tả đầu tiên không trống trong các size (giống cách form admin đang lưu). */
    public String descriptionOf(List<ProductDetail> sizes) {
        for (ProductDetail d : sizes) {
            String desc = d.getDescription();
            if (desc != null && !desc.isBlank()) {
                return desc.trim();
            }
        }
        return null;
    }

    /**
     * Danh sách ảnh: ảnh đại diện đứng đầu, sau đó đến ảnh trong bảng ProductImages (theo SortOrder).
     * Trả về đúng giá trị đang lưu trong DB (tên file hoặc đường dẫn), JSP sẽ tự ghép đường dẫn.
     */
    public List<String> galleryOf(Product p) {
        Set<String> urls = new LinkedHashSet<>();
        String main = p.getMainImageUrl();
        if (main != null && !main.isBlank()) {
            urls.add(main.trim());
        }
        try {
            List<String> extra = jdbcTemplate.queryForList(
                    "SELECT ImageUrl FROM ProductImages WHERE ProductId = ? ORDER BY SortOrder, ImageId",
                    String.class, p.getId());
            for (String u : extra) {
                if (u != null && !u.isBlank()) {
                    urls.add(u.trim());
                }
            }
        } catch (DataAccessException ignored) {
            // Không đọc được ảnh phụ thì chỉ hiện ảnh đại diện
        }
        return new ArrayList<>(urls);
    }
}