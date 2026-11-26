package com.polysneaker.polysneaker.service.pages;

import com.polysneaker.polysneaker.dto.SitePageForm;
import com.polysneaker.polysneaker.entity.SitePage;
import org.springframework.dao.DataAccessException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.util.HtmlUtils;

import java.text.Normalizer;
import java.time.LocalDateTime;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Optional;

import com.polysneaker.polysneaker.repository.SitePageRepository;

@Service
public class SitePageService {

    public static final String GROUP_SERVICE = "SERVICE";
    public static final String GROUP_POLICY = "POLICY";
    public static final String GROUP_NONE = "NONE";

    private static final long CACHE_MS = 30_000;

    private final SitePageRepository repo;

    // Footer có mặt ở mọi trang nên lưu tạm danh sách link, tránh hỏi database mỗi lần tải trang
    private volatile List<SitePage> footerCache;
    private volatile long footerCachedAt;

    public SitePageService(SitePageRepository repo) {
        this.repo = repo;
    }

    // ---------- Footer / trang khách ----------
    public List<SitePage> footerPages(String group) {
        return footerAll().stream().filter(p -> group.equals(p.getFooterGroup())).toList();
    }

    private List<SitePage> footerAll() {
        List<SitePage> cached = footerCache;
        if (cached != null && System.currentTimeMillis() - footerCachedAt < CACHE_MS) {
            return cached;
        }
        try {
            List<SitePage> fresh = repo.findByActiveTrueOrderBySortOrderAscIdAsc().stream()
                    .filter(p -> !GROUP_NONE.equals(p.getFooterGroup()))
                    .toList();
            footerCache = fresh;
            footerCachedAt = System.currentTimeMillis();
            return fresh;
        } catch (DataAccessException e) {
            return List.of();   // chưa tạo bảng hoặc lỗi database thì footer trống chứ không làm hỏng cả trang
        }
    }

    @Transactional(readOnly = true)
    public Optional<SitePage> findPublic(String slug) {
        if (slug == null || slug.isBlank()) return Optional.empty();
        return repo.findBySlugAndActiveTrue(slug.trim().toLowerCase(Locale.ROOT));
    }

    // ---------- Admin ----------
    @Transactional(readOnly = true)
    public List<SitePage> findAllForAdmin() {
        return repo.findAllByOrderBySortOrderAscIdAsc();
    }

    @Transactional(readOnly = true)
    public SitePageForm toForm(Integer id) {
        SitePage p = repo.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy trang"));
        SitePageForm f = new SitePageForm();
        f.setId(p.getId());
        f.setTitle(p.getTitle());
        f.setSlug(p.getSlug());
        f.setContent(p.getContent());
        f.setFooterGroup(p.getFooterGroup());
        f.setSortOrder(p.getSortOrder());
        f.setActive(p.isActive());
        return f;
    }

    @Transactional(readOnly = true)
    public Map<String, String> validate(SitePageForm f) {
        Map<String, String> errors = new LinkedHashMap<>();

        String title = f.getTitle() == null ? "" : f.getTitle().trim();
        if (title.isEmpty()) {
            errors.put("title", "Vui lòng nhập tiêu đề trang.");
        } else if (title.length() > 200) {
            errors.put("title", "Tiêu đề tối đa 200 ký tự.");
        }

        String slug = resolveSlug(f);
        if (slug.isEmpty()) {
            errors.put("slug", "Không tạo được đường dẫn, hãy nhập đường dẫn gồm chữ không dấu hoặc số.");
        } else if (slug.length() > 100) {
            errors.put("slug", "Đường dẫn tối đa 100 ký tự.");
        } else {
            boolean taken = f.getId() == null
                    ? repo.existsBySlug(slug)
                    : repo.existsBySlugAndIdNot(slug, f.getId());
            if (taken) {
                errors.put("slug", "Đường dẫn \"" + slug + "\" đã được trang khác dùng, hãy đổi tên khác.");
            }
        }

        String group = f.getFooterGroup();
        if (!GROUP_SERVICE.equals(group) && !GROUP_POLICY.equals(group) && !GROUP_NONE.equals(group)) {
            errors.put("footerGroup", "Vị trí hiển thị ở footer không hợp lệ.");
        }

        if (f.getSortOrder() != null && (f.getSortOrder() < 0 || f.getSortOrder() > 9999)) {
            errors.put("sortOrder", "Thứ tự từ 0 đến 9999.");
        }

        if (f.getContent() == null || f.getContent().isBlank()) {
            errors.put("content", "Vui lòng nhập nội dung trang.");
        } else if (f.getContent().length() > 100_000) {
            errors.put("content", "Nội dung quá dài (tối đa 100.000 ký tự).");
        }
        return errors;
    }

    @Transactional
    public void save(SitePageForm f) {
        SitePage p = (f.getId() == null)
                ? new SitePage()
                : repo.findById(f.getId()).orElseThrow(() -> new IllegalArgumentException("Không tìm thấy trang"));

        p.setTitle(f.getTitle().trim());
        p.setSlug(resolveSlug(f));
        p.setContent(f.getContent().replace("\r\n", "\n").replace('\r', '\n').strip());
        p.setFooterGroup(f.getFooterGroup());
        p.setSortOrder(f.getSortOrder() == null ? 0 : f.getSortOrder());
        p.setActive(f.isActive());
        p.setUpdatedAt(LocalDateTime.now());
        repo.save(p);
        footerCache = null;     // footer đọc lại danh sách mới
    }

    @Transactional
    public void delete(Integer id) {
        repo.deleteById(id);
        footerCache = null;
    }

    // ---------- Tiện ích ----------
    /** Đường dẫn lấy từ ô "đường dẫn", để trống thì lấy từ tiêu đề. */
    private static String resolveSlug(SitePageForm f) {
        String src = (f.getSlug() != null && !f.getSlug().isBlank()) ? f.getSlug() : f.getTitle();
        return slugify(src);
    }

    /** "Chính sách bảo mật" -> "chinh-sach-bao-mat" */
    public static String slugify(String s) {
        if (s == null) return "";
        String t = Normalizer.normalize(s.trim(), Normalizer.Form.NFD)
                .replaceAll("\\p{M}+", "")
                .replace('đ', 'd').replace('Đ', 'D')
                .toLowerCase(Locale.ROOT)
                .replaceAll("[^a-z0-9]+", "-")
                .replaceAll("^-+|-+$", "");
        return t;
    }

    /**
     * Chuyển nội dung admin nhập thành HTML an toàn.
     * "## " đầu dòng = tiêu đề mục, "- " đầu dòng = gạch đầu dòng, dòng trống = ngắt đoạn.
     * Mọi chữ đều được escape nên không chèn được mã HTML/JavaScript.
     */
    public static String renderHtml(String raw) {
        if (raw == null || raw.isBlank()) return "";
        StringBuilder out = new StringBuilder();
        StringBuilder para = new StringBuilder();
        boolean inList = false;

        for (String line : raw.replace("\r\n", "\n").replace('\r', '\n').split("\n", -1)) {
            String t = line.strip();
            boolean heading = t.startsWith("## ");
            boolean bullet = t.startsWith("- ") || t.startsWith("* ");

            if (!bullet && inList) {
                out.append("</ul>");
                inList = false;
            }
            if ((t.isEmpty() || heading || bullet) && para.length() > 0) {
                out.append("<p>").append(para).append("</p>");
                para.setLength(0);
            }
            if (t.isEmpty()) continue;

            if (heading) {
                out.append("<h2>").append(HtmlUtils.htmlEscape(t.substring(3).strip())).append("</h2>");
            } else if (bullet) {
                if (!inList) {
                    out.append("<ul>");
                    inList = true;
                }
                out.append("<li>").append(HtmlUtils.htmlEscape(t.substring(2).strip())).append("</li>");
            } else {
                if (para.length() > 0) para.append("<br>");
                para.append(HtmlUtils.htmlEscape(t));
            }
        }
        if (inList) out.append("</ul>");
        if (para.length() > 0) out.append("<p>").append(para).append("</p>");
        return out.toString();
    }
}