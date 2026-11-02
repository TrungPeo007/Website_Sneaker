package com.polysneaker.polysneaker.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

@Entity
@Table(name = "SitePages")
@Getter
@Setter
public class SitePage {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "PageId")
    private Integer id;

    @Column(name = "Slug", nullable = false, length = 100)
    private String slug;

    @Column(name = "Title", nullable = false, length = 200)
    private String title;

    @Column(name = "Content", columnDefinition = "NVARCHAR(MAX)")
    private String content;

    /** SERVICE | POLICY | NONE (không hiện ở footer) */
    @Column(name = "FooterGroup", nullable = false, length = 20)
    private String footerGroup = "POLICY";

    @Column(name = "SortOrder", nullable = false)
    private int sortOrder;

    @Column(name = "IsActive", nullable = false)
    private boolean active = true;

    // Có giá trị mặc định GETDATE() trong DB -> chỉ đọc
    @Column(name = "CreatedAt", insertable = false, updatable = false)
    private LocalDateTime createdAt;

    @Column(name = "UpdatedAt")
    private LocalDateTime updatedAt;

    // Code dùng cho cập nhật ngày gần nhất
    public String getLastChangeDate() {
        LocalDateTime t = updatedAt != null ? updatedAt : createdAt;
        return t == null ? "" : t.format(DateTimeFormatter.ofPattern("dd/MM/yyyy"));
    }

    // Code dùng cho cập nhật thời gian gần nhất 
    public String getLastChangeText() {
        LocalDateTime t = updatedAt != null ? updatedAt : createdAt;
        return t == null ? "" : t.format(DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm"));
    }
}