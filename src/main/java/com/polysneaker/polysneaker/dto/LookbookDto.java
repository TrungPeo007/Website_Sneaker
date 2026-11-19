package com.polysneaker.polysneaker.dto;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class LookbookDto {
    private Integer id;
    private String title;
    private String description;
    private String coverImageUrl;   // đã tính sẵn: ảnh bìa, không có thì ảnh đầu tiên
    private int sortOrder;
    private boolean active;
    private int photoCount;
    private int productCount;       // số sản phẩm thuộc bộ sưu tập (cột "Sản phẩm" ở trang admin)
}