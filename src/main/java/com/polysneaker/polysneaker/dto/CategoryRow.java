package com.polysneaker.polysneaker.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;

/** Một dòng trong bảng danh mục ở trang admin. */
@Getter
@AllArgsConstructor
public class CategoryRow {
    private Integer id;
    private String name;
    private String description;
    private String parentName;      // tên nhóm cha, null nếu là danh mục gốc
    private boolean active;
    private boolean root;           // true = danh mục gốc (nhóm)
    private int productCount;       // số sản phẩm đang thuộc danh mục
    private int childCount;         // số danh mục con
}