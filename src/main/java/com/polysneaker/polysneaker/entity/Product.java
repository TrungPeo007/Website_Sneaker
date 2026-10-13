package com.polysneaker.polysneaker.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "Products")
@Getter
@Setter
public class Product {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "ProductId")
    private Integer id;

    @Column(name = "ProductName", nullable = false, length = 200)
    private String name;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "CategoryId")
    private Category category;

    @Column(name = "MainImageUrl", length = 500)
    private String mainImageUrl;

    @Column(name = "OriginalPrice", nullable = false)
    private BigDecimal originalPrice;

    @Column(name = "SalePrice", nullable = false)
    private BigDecimal salePrice;

    // Cột tính tự động trong SQL Server -> chỉ đọc
    @Column(name = "DiscountPercent", insertable = false, updatable = false)
    private Integer discountPercent;

    @Column(name = "Badge", length = 30)
    private String badge;

    @Column(name = "AvgRating", nullable = false)
    private BigDecimal avgRating = BigDecimal.ZERO;

    @Column(name = "ReviewCount", nullable = false)
    private int reviewCount;

    @Column(name = "IsActive", nullable = false)
    private boolean active = true;

    // Có giá trị mặc định GETDATE() trong DB -> chỉ đọc
    @Column(name = "CreatedAt", insertable = false, updatable = false)
    private LocalDateTime createdAt;

    @OneToMany(mappedBy = "product", cascade = CascadeType.ALL, orphanRemoval = true)
    @OrderBy("size ASC")
    private List<ProductDetail> details = new ArrayList<>();

    /** Tổng tồn kho của các size đang bán (dùng cho trang admin) */
    public int getTotalStock() {
        return details.stream()
                .filter(ProductDetail::isActive)
                .mapToInt(ProductDetail::getStockQuantity)
                .sum();
    }

    /** DB chưa có cột SKU nên tạo mã hiển thị từ ProductId, ví dụ PS-007 */
    public String getSku() {
        return id == null ? "" : String.format("PS-%03d", id);
    }
}