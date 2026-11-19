package com.polysneaker.polysneaker.dto;

import java.io.Serializable;
import java.time.LocalDateTime;

/** Thông tin tài khoản vừa đăng ký, giữ tạm trong session để khách tải file Excel. */
public class RegisteredInfo implements Serializable {

    public static final String SESSION_KEY = "registeredInfo";

    private final String username;
    private final String email;
    private final String password;
    private final LocalDateTime registeredAt;

    public RegisteredInfo(String username, String email, String password) {
        this.username = username;
        this.email = email;
        this.password = password;
        this.registeredAt = LocalDateTime.now();
    }

    public String getUsername() { return username; }
    public String getEmail() { return email; }
    public String getPassword() { return password; }
    public LocalDateTime getRegisteredAt() { return registeredAt; }
}