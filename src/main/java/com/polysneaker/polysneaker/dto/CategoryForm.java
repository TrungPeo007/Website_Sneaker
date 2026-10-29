package com.polysneaker.polysneaker.dto;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class CategoryForm {
    private Integer id;                 // null = thêm mới, có giá trị = sửa
    private String name;
    private Integer parentId;           // null = danh mục gốc (nhóm)
    private String description;
    private boolean active = true;
}