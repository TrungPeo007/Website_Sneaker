package com.polysneaker.polysneaker.dto;

import lombok.Getter;
import lombok.Setter;

import java.util.ArrayList;
import java.util.List;

@Getter
@Setter
public class LookbookForm {
    private Integer id;                  // null = thêm mới, có giá trị = sửa
    private String title;
    private String description;
    private String coverImageUrl;        // để trống thì dùng ảnh đầu tiên
    private Integer sortOrder = 0;
    private boolean active = true;
    private List<LookbookItemForm> items = new ArrayList<>();
    private List<Integer> productIds = new ArrayList<>();   // id các sản phẩm thuộc bộ sưu tập (ô tick trong form)
}