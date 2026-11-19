package com.polysneaker.polysneaker.dto;

import lombok.Getter;
import lombok.Setter;

/** Một ảnh trong form bộ sưu tập. */
@Getter
@Setter
public class LookbookItemForm {
    private String imageUrl;      // tên file ảnh
    private String caption;       // chú thích (tuỳ chọn)
    private Integer productId;    // sản phẩm gắn vào ảnh (tuỳ chọn)
}