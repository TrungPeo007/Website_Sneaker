package com.polysneaker.polysneaker.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.math.BigDecimal;

@Entity
@Table(name = "ProductDetails")
@Getter
@Setter
public class ProductDetail {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "ProductDetailId")
    private Integer id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "ProductId")
    private Product product;

    @Column(name = "Size", nullable = false, precision = 3, scale = 1)
    private BigDecimal size;

    @Column(name = "Description", columnDefinition = "NVARCHAR(MAX)")
    private String description;

    @Column(name = "StockQuantity", nullable = false)
    private int stockQuantity;

    @Column(name = "SoldQuantity", nullable = false)
    private int soldQuantity;

    @Column(name = "IsActive", nullable = false)
    private boolean active = true;
}