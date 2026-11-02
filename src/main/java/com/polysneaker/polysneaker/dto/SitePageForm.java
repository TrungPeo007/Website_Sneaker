package com.polysneaker.polysneaker.dto;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class SitePageForm {
    private Integer id;                     // null = thêm mới, có giá trị = sửa
    private String title;
    private String slug;                    // để trống thì tự tạo từ tiêu đề
    private String content;
    private String footerGroup = "POLICY";  // SERVICE | POLICY | NONE
    private Integer sortOrder = 0;
    private boolean active = true;
}