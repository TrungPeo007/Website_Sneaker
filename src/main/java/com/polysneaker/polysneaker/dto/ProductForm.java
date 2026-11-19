package com.polysneaker.polysneaker.dto;

import lombok.Getter;
import lombok.Setter;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

@Getter
@Setter
public class ProductForm {
    private Integer id;                 // null = thêm mới, có giá trị = sửa
    private String name;
    private Integer categoryId;
    private String mainImageUrl;        // tên file ảnh trong /static/assets/images
    private BigDecimal originalPrice;
    private BigDecimal salePrice;
    private String badge;
    private boolean active = true;
    private String description;
    private String material;            // chất liệu
    private String specifications;      // thông số kỹ thuật (mỗi dòng một thông số)
    private List<BigDecimal> sizes = new ArrayList<>();
    private List<Integer> stocks = new ArrayList<>();
    private List<String> galleryImages = new ArrayList<>();
}