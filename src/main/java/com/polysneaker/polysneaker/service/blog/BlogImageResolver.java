package com.polysneaker.polysneaker.service.blog;

import com.polysneaker.polysneaker.entity.Blog;

import java.util.Collection;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

/**
 * Đổi tên file ảnh lưu trong DB thành đường dẫn dùng được trên trang.
 * Thư mục ảnh đặt trong application.properties:  polysneaker.upload.base-url=/uploads/
 */
@Component
public class BlogImageResolver {

    private final String baseUrl;

    public BlogImageResolver(@Value("${polysneaker.upload.base-url:/uploads/}") String baseUrl) {
        String b = baseUrl.trim();
        if (!b.startsWith("/")) b = "/" + b;
        if (!b.endsWith("/")) b = b + "/";
        this.baseUrl = b;
    }

    /** Tiền tố dùng cho ảnh chỉ có tên file, ví dụ "/shop/uploads/". */
    public String base(String ctx) {
        return ctx + baseUrl;
    }

    public String resolve(String file, String ctx) {
        if (file == null || file.isBlank()) return "";
        String f = file.trim();
        if (f.startsWith("http://") || f.startsWith("https://")) return f;
        if (f.startsWith("/")) return ctx + f;
        return ctx + baseUrl + f;
    }

    public void decorate(Blog b, String ctx) {
        b.setThumbSrc(resolve(b.getThumbnailUrl(), ctx));
    }

    public void decorate(Collection<Blog> list, String ctx) {
        for (Blog b : list) decorate(b, ctx);
    }
}