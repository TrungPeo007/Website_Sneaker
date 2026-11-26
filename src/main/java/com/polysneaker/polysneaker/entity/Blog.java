package com.polysneaker.polysneaker.entity;

import java.util.Date;

/** Một dòng của bảng dbo.Blogs. */
public class Blog {

    private Integer id;
    private String title;
    private String slug;
    private String summary;
    private String content;
    private String thumbnailUrl;
    private String author;
    private boolean published = true;
    private Date createdAt;
    private Date updatedAt;

    /** Đường dẫn ảnh đã ghép sẵn để JSP dùng thẳng (không lưu DB). */
    private String thumbSrc;

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

    public Date getCreatedAt() { return createdAt; }
    public void setCreatedAt(Date createdAt) { this.createdAt = createdAt; }

    public Date getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Date updatedAt) { this.updatedAt = updatedAt; }

    public String getThumbSrc() { return thumbSrc; }
    public void setThumbSrc(String thumbSrc) { this.thumbSrc = thumbSrc; }
}