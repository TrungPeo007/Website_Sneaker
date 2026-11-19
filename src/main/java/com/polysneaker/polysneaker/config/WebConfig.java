package com.polysneaker.polysneaker.config;

import com.polysneaker.polysneaker.interceptor.LoginRequiredInterceptor;

import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.InterceptorRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

/**
 * Đăng ký interceptor bắt đăng nhập cho các trang mua hàng.
 */
@Configuration
public class WebConfig implements WebMvcConfigurer {

    private final LoginRequiredInterceptor loginRequired;

    public WebConfig(LoginRequiredInterceptor loginRequired) {
        this.loginRequired = loginRequired;
    }

    @Override
    public void addInterceptors(InterceptorRegistry registry) {
        registry.addInterceptor(loginRequired)
                .addPathPatterns("/cart/**", "/checkout/**", "/orders/**");
    }
}