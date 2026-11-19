package com.polysneaker.polysneaker.dto;

import lombok.Getter;
import lombok.Setter;

import java.math.BigDecimal;

@Getter
@Setter
public class LookbookPhotoDto {
    private Integer id;
    private String imageUrl;
    private String caption;
    private Integer productId;
    private String productName;
    private BigDecimal salePrice;
    private BigDecimal originalPrice;
    private Integer discountPercent;

    /** Ảnh có gắn sản phẩm đang bán hay không. */
    public boolean isHasProduct() {
        return productId != null && productName != null;
    }
}