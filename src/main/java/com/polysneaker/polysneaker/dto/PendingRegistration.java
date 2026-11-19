package com.polysneaker.polysneaker.dto;

import java.io.Serializable;

/** Thông tin đăng ký đang chờ xác thực email (lưu trong session, chưa vào DB). */
public class PendingRegistration implements Serializable {

    public static final String SESSION_KEY = "pendingRegistration";

    private final String username;
    private final String email;
    private final String password;

    private String code;
    private long expiresAt;
    private long lastSentAt;
    private int attempts;

    public PendingRegistration(String username, String email, String password) {
        this.username = username;
        this.email = email;
        this.password = password;
    }

    public String getUsername() { return username; }
    public String getEmail() { return email; }
    public String getPassword() { return password; }

    public String getCode() { return code; }
    public long getExpiresAt() { return expiresAt; }
    public long getLastSentAt() { return lastSentAt; }
    public int getAttempts() { return attempts; }

    /** Gán mã mới, hiệu lực 10 phút, reset số lần nhập sai. */
    public void renewCode(String newCode) {
        long now = System.currentTimeMillis();
        this.code = newCode;
        this.lastSentAt = now;
        this.expiresAt = now + 10 * 60 * 1000L;
        this.attempts = 0;
    }

    public void increaseAttempts() { this.attempts++; }
}