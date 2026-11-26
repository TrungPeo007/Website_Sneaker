package com.polysneaker.polysneaker.repository;

import com.polysneaker.polysneaker.entity.Blog;

import java.util.List;
import java.util.Optional;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.stereotype.Repository;

/** Đọc / ghi bảng dbo.Blogs bằng JdbcTemplate (không phụ thuộc cách đặt tên cột của JPA). */
@Repository
public class BlogRepository {

    private static final String CARD_COLS =
            "BlogId, Title, Slug, Summary, ThumbnailUrl, Author, IsPublished, CreatedAt, UpdatedAt";
    private static final String FULL_COLS =
            "BlogId, Title, Slug, Summary, Content, ThumbnailUrl, Author, IsPublished, CreatedAt, UpdatedAt";
    private static final String NEWEST = " ORDER BY CreatedAt DESC, BlogId DESC";

    /** Dùng cho danh sách: không đọc cột Content cho nhẹ. */
    private static final RowMapper<Blog> CARD = (rs, i) -> {
        Blog b = new Blog();
        b.setId(rs.getInt("BlogId"));
        b.setTitle(rs.getString("Title"));
        b.setSlug(rs.getString("Slug"));
        b.setSummary(rs.getString("Summary"));
        b.setThumbnailUrl(rs.getString("ThumbnailUrl"));
        b.setAuthor(rs.getString("Author"));
        b.setPublished(rs.getBoolean("IsPublished"));
        b.setCreatedAt(rs.getTimestamp("CreatedAt"));
        b.setUpdatedAt(rs.getTimestamp("UpdatedAt"));
        return b;
    };

    private static final RowMapper<Blog> FULL = (rs, i) -> {
        Blog b = CARD.mapRow(rs, i);
        b.setContent(rs.getString("Content"));
        return b;
    };

    private final JdbcTemplate jdbc;

    public BlogRepository(JdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    /* ---------- admin ---------- */

    public List<Blog> findAll(String keyword) {
        if (keyword == null || keyword.isBlank()) {
            return jdbc.query("SELECT " + CARD_COLS + " FROM dbo.Blogs" + NEWEST, CARD);
        }
        return jdbc.query("SELECT " + CARD_COLS + " FROM dbo.Blogs WHERE Title LIKE ?" + NEWEST,
                CARD, "%" + keyword.trim() + "%");
    }

    public Optional<Blog> findById(int id) {
        return jdbc.query("SELECT " + FULL_COLS + " FROM dbo.Blogs WHERE BlogId = ?", FULL, id)
                .stream().findFirst();
    }

    public boolean slugExists(String slug, Integer exceptId) {
        Integer n;
        if (exceptId == null) {
            n = jdbc.queryForObject("SELECT COUNT(*) FROM dbo.Blogs WHERE Slug = ?", Integer.class, slug);
        } else {
            n = jdbc.queryForObject("SELECT COUNT(*) FROM dbo.Blogs WHERE Slug = ? AND BlogId <> ?",
                    Integer.class, slug, exceptId);
        }
        return n != null && n > 0;
    }

    /** Thêm bài mới, trả về BlogId vừa tạo. CreatedAt lấy mặc định GETDATE() của DB. */
    public int insert(Blog b) {
        Integer id = jdbc.queryForObject(
                "INSERT INTO dbo.Blogs (Title, Slug, Summary, Content, ThumbnailUrl, Author, IsPublished) "
                        + "OUTPUT INSERTED.BlogId VALUES (?, ?, ?, ?, ?, ?, ?)",
                Integer.class,
                b.getTitle(), b.getSlug(), b.getSummary(), b.getContent(),
                b.getThumbnailUrl(), b.getAuthor(), b.isPublished());
        return id == null ? 0 : id;
    }

    public void update(Blog b) {
        jdbc.update("UPDATE dbo.Blogs SET Title = ?, Slug = ?, Summary = ?, Content = ?, "
                        + "ThumbnailUrl = ?, Author = ?, IsPublished = ?, UpdatedAt = GETDATE() WHERE BlogId = ?",
                b.getTitle(), b.getSlug(), b.getSummary(), b.getContent(),
                b.getThumbnailUrl(), b.getAuthor(), b.isPublished(), b.getId());
    }

    public void setPublished(int id, boolean published) {
        jdbc.update("UPDATE dbo.Blogs SET IsPublished = ?, UpdatedAt = GETDATE() WHERE BlogId = ?", published, id);
    }

    public void delete(int id) {
        jdbc.update("DELETE FROM dbo.Blogs WHERE BlogId = ?", id);
    }

    /* ---------- khách xem (chỉ bài đã đăng) ---------- */

    public int countPublished() {
        Integer n = jdbc.queryForObject("SELECT COUNT(*) FROM dbo.Blogs WHERE IsPublished = 1", Integer.class);
        return n == null ? 0 : n;
    }

    public List<Blog> findPublished(int offset, int limit) {
        return jdbc.query("SELECT " + CARD_COLS + " FROM dbo.Blogs WHERE IsPublished = 1" + NEWEST
                + " OFFSET ? ROWS FETCH NEXT ? ROWS ONLY", CARD, offset, limit);
    }

    public List<Blog> findOtherPublished(int exceptId, int limit) {
        return jdbc.query("SELECT " + CARD_COLS + " FROM dbo.Blogs WHERE IsPublished = 1 AND BlogId <> ?" + NEWEST
                + " OFFSET 0 ROWS FETCH NEXT ? ROWS ONLY", CARD, exceptId, limit);
    }

    public Optional<Blog> findPublishedBySlug(String slug) {
        return jdbc.query("SELECT " + FULL_COLS + " FROM dbo.Blogs WHERE Slug = ? AND IsPublished = 1", FULL, slug)
                .stream().findFirst();
    }
}