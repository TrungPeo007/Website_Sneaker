package com.polysneaker.polysneaker.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

// Nếu anh đã có entity Category thì dùng cái cũ, chỉ cần khớp tên field: id, name, parent, active
@Entity
@Table(name = "Categories")
@Getter
@Setter
public class Category {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "CategoryId")
    private Integer id;

    @Column(name = "CategoryName", nullable = false, length = 100)
    private String name;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "ParentId")
    private Category parent;

    @Column(name = "IsActive", nullable = false)
    private boolean active = true;
}