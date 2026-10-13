package com.polysneaker.polysneaker.dto;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class RegisterForm {
    private String username;
    private String email;
    private String password;
    private String confirmPassword;
}