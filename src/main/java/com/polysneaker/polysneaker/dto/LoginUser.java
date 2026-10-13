package com.polysneaker.polysneaker.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;

import java.io.Serializable;

/** Thông tin tối thiểu lưu trong session sau khi đăng nhập (không chứa mật khẩu). */
@Getter
@AllArgsConstructor
public class LoginUser implements Serializable {

    public static final String SESSION_KEY = "loginUser";

    private final Integer id;
    private final String username;
    private final String role;
}