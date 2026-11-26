package com.polysneaker.polysneaker.dto;

import com.polysneaker.polysneaker.entity.Blog;

/** Dữ liệu form thêm / sửa bài viết (model attribute "form"). */
public class BlogForm {

    private Integer id;
    private String title;
    private String slug;
    private String summary;
    private String content;
    private String thumbnailUrl;
    private String author;
    private boolean published = true;

    public static BlogForm from(Blog b) {
        BlogForm f = new BlogForm();
        f.id = b.getId();
        f.title = b.getTitle();
        f.slug = b.getSlug();
        f.summary = b.getSummary();
        f.content = b.getContent();
        f.thumbnailUrl = b.getThumbnailUrl();
        f.author = b.getAuthor();
        f.published = b.isPublished();
        return f;
    }

    public Integer getId() { return id; }
    public void setId(Integer id) { this.id = id; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getSlug() { return slug; }
    public void setSlug(String slug) { this.slug = slug; }

    public String getSummary() { return summary; }
    public void setSummary(String summary) { this.summary = summary; }

    public String getContent() { return content; }
    public void setContent(String content) { this.content = content; }

    public String getThumbnailUrl() { return thumbnailUrl; }
    public void setThumbnailUrl(String thumbnailUrl) { this.thumbnailUrl = thumbnailUrl; }

    public String getAuthor() { return author; }
    public void setAuthor(String author) { this.author = author; }

    public boolean isPublished() { return published; }
    public void setPublished(boolean published) { this.published = published; }
}