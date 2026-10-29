package com.polysneaker.polysneaker.dto;

import java.io.Serializable;

/** Thông tin tối thiểu lưu trong session sau khi đăng nhập (không chứa mật khẩu). */
public class LoginUser implements Serializable {

    public static final String SESSION_KEY = "loginUser";

    private final Integer id;
    private final String username;
    private final String role;

    public LoginUser(Integer id, String username, String role) {
        this.id = id;
        this.username = username;
        this.role = role;
    }

    public Integer getId() { return id; }
    public String getUsername() { return username; }
    public String getRole() { return role; }
}