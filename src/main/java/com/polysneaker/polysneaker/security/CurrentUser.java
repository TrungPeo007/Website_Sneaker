package com.polysneaker.polysneaker.security;

import com.polysneaker.polysneaker.dto.LoginUser;
import jakarta.servlet.http.HttpSession;

import java.util.Set;

/**
 * Người đang đăng nhập, lấy từ LoginUser mà AuthController lưu trong session.
 * Muốn cho thêm role nào quản lý voucher/coupon thì thêm vào MANAGER_ROLES.
 */
public record CurrentUser(int accountId, String username, String role) {

    public static final Set<String> MANAGER_ROLES = Set.of("ADMIN", "BOD");

    /** Trả null nếu chưa đăng nhập. */
    public static CurrentUser from(HttpSession session) {
        if (session == null) return null;
        Object o = session.getAttribute(LoginUser.SESSION_KEY);
        if (!(o instanceof LoginUser u) || u.getId() == null || u.getRole() == null) return null;
        return new CurrentUser(u.getId(), u.getUsername(), u.getRole());
    }

    public boolean isManager() {
        return MANAGER_ROLES.contains(role.toUpperCase());
    }
}