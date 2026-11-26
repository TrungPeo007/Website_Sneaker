package com.polysneaker.polysneaker.service.blog;

import com.polysneaker.polysneaker.repository.BlogRepository;
import com.polysneaker.polysneaker.util.SlugUtil;
import com.polysneaker.polysneaker.dto.BlogForm;
import com.polysneaker.polysneaker.entity.Blog;

import java.util.List;
import java.util.NoSuchElementException;
import java.util.Optional;

import org.springframework.stereotype.Service;

@Service
public class BlogService {

    /** Số bài mỗi trang ở /blog. */
    public static final int PAGE_SIZE = 9;

    private final BlogRepository repo;

    public BlogService(BlogRepository repo) {
        this.repo = repo;
    }

    /* ---------- admin ---------- */

    public List<Blog> adminList(String keyword) {
        return repo.findAll(keyword);
    }

    public Blog get(int id) {
        return repo.findById(id).orElseThrow(() -> new NoSuchElementException("Không tìm thấy bài viết."));
    }

    /** Thêm mới (form.id == null) hoặc cập nhật. Lỗi nhập liệu ném IllegalArgumentException có câu báo lỗi. */
    public int save(BlogForm f) {
        String title = clean(f.getTitle());
        if (title == null) throw new IllegalArgumentException("Vui lòng nhập tiêu đề bài viết.");
        if (title.length() > 200) throw new IllegalArgumentException("Tiêu đề tối đa 200 ký tự.");

        String summary = clean(f.getSummary());
        if (summary != null && summary.length() > 500) throw new IllegalArgumentException("Mô tả ngắn tối đa 500 ký tự.");

        String author = clean(f.getAuthor());
        if (author != null && author.length() > 100) throw new IllegalArgumentException("Tên tác giả tối đa 100 ký tự.");

        String thumb = clean(f.getThumbnailUrl());
        if (thumb != null && thumb.length() > 500) throw new IllegalArgumentException("Đường dẫn ảnh đại diện quá dài.");

        String content = (f.getContent() == null || f.getContent().isBlank()) ? null : f.getContent().strip();
        if (f.isPublished() && content == null) {
            throw new IllegalArgumentException("Bài đã đăng thì phải có nội dung. Hãy nhập nội dung hoặc bỏ chọn \"Đăng bài\" để lưu nháp.");
        }

        Integer id = f.getId();
        Blog old = (id == null) ? null : get(id);

        Blog b = new Blog();
        b.setId(id);
        b.setTitle(title);
        b.setSlug(resolveSlug(f.getSlug(), title, id, old));
        b.setSummary(summary);
        b.setContent(content);
        b.setThumbnailUrl(thumb);
        b.setAuthor(author);
        b.setPublished(f.isPublished());

        if (id == null) {
            return repo.insert(b);
        }
        repo.update(b);
        return id;
    }

    /** Đảo trạng thái đăng / nháp. Trả về trạng thái mới (true = đang đăng). */
    public boolean togglePublished(int id) {
        Blog b = get(id);
        boolean now = !b.isPublished();
        if (now && (b.getContent() == null || b.getContent().isBlank())) {
            throw new IllegalArgumentException("Bài chưa có nội dung nên chưa thể đăng. Hãy mở bài ra và nhập nội dung.");
        }
        repo.setPublished(id, now);
        return now;
    }

    public void delete(int id) {
        repo.delete(id);
    }

    /* ---------- khách xem ---------- */

    public int totalPages() {
        return (repo.countPublished() + PAGE_SIZE - 1) / PAGE_SIZE;
    }

    public List<Blog> publishedPage(int page) {
        return repo.findPublished(page * PAGE_SIZE, PAGE_SIZE);
    }

    public Optional<Blog> publishedBySlug(String slug) {
        return repo.findPublishedBySlug(slug);
    }

    /** n bài mới nhất đã đăng (dùng cho mục Blog ở trang chủ). */
    public List<Blog> latest(int n) {
        return repo.findPublished(0, n);
    }

    /** "Bài viết khác" ở cuối trang chi tiết. */
    public List<Blog> others(int exceptId, int n) {
        return repo.findOtherPublished(exceptId, n);
    }

    /* ---------- nội bộ ---------- */

    private String resolveSlug(String typedSlug, String title, Integer id, Blog old) {
        String typed = SlugUtil.slugify(typedSlug);
        if (!typed.isEmpty()) {
            if (repo.slugExists(typed, id)) {
                throw new IllegalArgumentException("Đường dẫn \"" + typed + "\" đã có bài khác dùng, hãy đổi đường dẫn khác.");
            }
            return typed;
        }
        if (old != null) {
            return old.getSlug(); // sửa bài mà để trống slug: giữ link cũ
        }
        String base = SlugUtil.slugify(title);
        if (base.isEmpty()) base = "bai-viet";
        String candidate = base;
        int n = 2;
        while (repo.slugExists(candidate, id)) {
            candidate = base + "-" + n++;
        }
        return candidate;
    }

    private static String clean(String s) {
        if (s == null) return null;
        String t = s.strip();
        return t.isEmpty() ? null : t;
    }
}