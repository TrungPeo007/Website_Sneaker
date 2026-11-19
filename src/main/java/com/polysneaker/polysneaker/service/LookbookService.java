package com.polysneaker.polysneaker.service;

import com.polysneaker.polysneaker.dto.LookbookDto;
import com.polysneaker.polysneaker.dto.LookbookForm;
import com.polysneaker.polysneaker.dto.LookbookItemForm;
import com.polysneaker.polysneaker.dto.LookbookPhotoDto;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowCallbackHandler;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.Set;

/** Bộ sưu tập (Lookbook): bảng Lookbooks + LookbookItems. */
@Service
public class LookbookService {

    public static final int MAX_PHOTOS = 24;

    private static final String LIST_SQL = """
            SELECT l.LookbookId, l.Title, l.Description, l.CoverImageUrl, l.SortOrder, l.IsActive,
                   (SELECT COUNT(*) FROM LookbookItems i WHERE i.LookbookId = l.LookbookId) AS PhotoCount,
                   (SELECT TOP 1 i.ImageUrl FROM LookbookItems i WHERE i.LookbookId = l.LookbookId
                     ORDER BY i.SortOrder, i.LookbookItemId) AS FirstImage
            FROM Lookbooks l
            """;

    private final JdbcTemplate jdbc;

    public LookbookService(JdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    // ---------- Đọc (admin + khách) ----------
    @Transactional(readOnly = true)
    public List<LookbookDto> findAllForAdmin() {
        return jdbc.query(LIST_SQL + " ORDER BY l.SortOrder, l.LookbookId", LookbookService::mapLookbook);
    }

    @Transactional(readOnly = true)
    public List<LookbookDto> findActive() {
        return jdbc.query(LIST_SQL + " WHERE l.IsActive = 1 ORDER BY l.SortOrder, l.LookbookId",
                LookbookService::mapLookbook);
    }

    @Transactional(readOnly = true)
    public Optional<LookbookDto> findActiveById(Integer id) {
        return jdbc.query(LIST_SQL + " WHERE l.IsActive = 1 AND l.LookbookId = ?",
                LookbookService::mapLookbook, id).stream().findFirst();
    }

    /** Các ảnh của bộ sưu tập kèm sản phẩm gắn vào (chỉ sản phẩm đang bán). */
    @Transactional(readOnly = true)
    public List<LookbookPhotoDto> photosOf(Integer lookbookId) {
        return jdbc.query("""
                SELECT i.LookbookItemId, i.ImageUrl, i.Caption,
                       p.ProductId, p.ProductName, p.SalePrice, p.OriginalPrice, p.DiscountPercent
                FROM LookbookItems i
                LEFT JOIN Products p ON p.ProductId = i.ProductId AND p.IsActive = 1
                WHERE i.LookbookId = ?
                ORDER BY i.SortOrder, i.LookbookItemId
                """, (rs, n) -> {
            LookbookPhotoDto d = new LookbookPhotoDto();
            d.setId(rs.getInt("LookbookItemId"));
            d.setImageUrl(rs.getString("ImageUrl"));
            d.setCaption(rs.getString("Caption"));
            int pid = rs.getInt("ProductId");
            if (!rs.wasNull()) {
                d.setProductId(pid);
                d.setProductName(rs.getString("ProductName"));
                d.setSalePrice(rs.getBigDecimal("SalePrice"));
                d.setOriginalPrice(rs.getBigDecimal("OriginalPrice"));
                d.setDiscountPercent(rs.getInt("DiscountPercent"));
            }
            return d;
        }, lookbookId);
    }

    /** Danh sách sản phẩm cho ô chọn "gắn sản phẩm" ở form admin. */
    @Transactional(readOnly = true)
    public List<Map<String, Object>> productOptions() {
        return jdbc.queryForList("""
                SELECT ProductId AS id,
                       CASE WHEN IsActive = 1 THEN ProductName ELSE ProductName + N' (đang ẩn)' END AS name
                FROM Products ORDER BY ProductName
                """);
    }

    // ---------- Form admin ----------
    @Transactional(readOnly = true)
    public LookbookForm toForm(Integer id) {
        List<LookbookForm> rows = jdbc.query("""
                SELECT LookbookId, Title, Description, CoverImageUrl, SortOrder, IsActive
                FROM Lookbooks WHERE LookbookId = ?
                """, (rs, n) -> {
            LookbookForm f = new LookbookForm();
            f.setId(rs.getInt("LookbookId"));
            f.setTitle(rs.getString("Title"));
            f.setDescription(rs.getString("Description"));
            f.setCoverImageUrl(rs.getString("CoverImageUrl"));
            f.setSortOrder(rs.getInt("SortOrder"));
            f.setActive(rs.getBoolean("IsActive"));
            return f;
        }, id);
        if (rows.isEmpty()) {
            throw new IllegalArgumentException("Không tìm thấy bộ sưu tập");
        }
        LookbookForm form = rows.get(0);

        jdbc.query("""
                SELECT ImageUrl, Caption, ProductId FROM LookbookItems
                WHERE LookbookId = ? ORDER BY SortOrder, LookbookItemId
                """, (RowCallbackHandler) rs -> {
            LookbookItemForm it = new LookbookItemForm();
            it.setImageUrl(rs.getString("ImageUrl"));
            it.setCaption(rs.getString("Caption"));
            int pid = rs.getInt("ProductId");
            it.setProductId(rs.wasNull() ? null : pid);
            form.getItems().add(it);
        }, id);
        return form;
    }

    @Transactional(readOnly = true)
    public Map<String, String> validate(LookbookForm f) {
        Map<String, String> errors = new LinkedHashMap<>();

        String title = f.getTitle() == null ? "" : f.getTitle().trim();
        if (title.isEmpty()) {
            errors.put("title", "Vui lòng nhập tên bộ sưu tập.");
        } else if (title.length() > 150) {
            errors.put("title", "Tên bộ sưu tập tối đa 150 ký tự.");
        } else {
            Integer same = f.getId() == null
                    ? jdbc.queryForObject("SELECT COUNT(*) FROM Lookbooks WHERE Title = ?", Integer.class, title)
                    : jdbc.queryForObject("SELECT COUNT(*) FROM Lookbooks WHERE Title = ? AND LookbookId <> ?",
                            Integer.class, title, f.getId());
            if (same != null && same > 0) {
                errors.put("title", "Đã có bộ sưu tập tên \"" + title + "\", hãy đặt tên khác.");
            }
        }

        if (f.getDescription() != null && f.getDescription().trim().length() > 1000) {
            errors.put("description", "Mô tả tối đa 1000 ký tự.");
        }
        if (f.getCoverImageUrl() != null && f.getCoverImageUrl().trim().length() > 500) {
            errors.put("coverImageUrl", "Đường dẫn ảnh bìa quá dài.");
        }
        if (f.getSortOrder() != null && (f.getSortOrder() < 0 || f.getSortOrder() > 9999)) {
            errors.put("sortOrder", "Thứ tự từ 0 đến 9999.");
        }

        int photos = 0;
        for (LookbookItemForm it : f.getItems()) {
            if (it == null || it.getImageUrl() == null || it.getImageUrl().isBlank()) continue;
            photos++;
            if (it.getCaption() != null && it.getCaption().trim().length() > 300) {
                errors.put("caption", "Chú thích ảnh tối đa 300 ký tự.");
            }
        }
        if (photos > MAX_PHOTOS) {
            errors.put("items", "Một bộ sưu tập tối đa " + MAX_PHOTOS + " ảnh.");
        }
        return errors;
    }

    @Transactional
    public void save(LookbookForm f) {
        String title = f.getTitle().trim();
        String desc = blankToNull(f.getDescription());
        String cover = blankToNull(f.getCoverImageUrl());
        int sort = f.getSortOrder() == null ? 0 : f.getSortOrder();

        Integer id = f.getId();
        if (id == null) {
            id = jdbc.queryForObject(
                    "INSERT INTO Lookbooks (Title, Description, CoverImageUrl, SortOrder, IsActive) "
                            + "OUTPUT INSERTED.LookbookId VALUES (?, ?, ?, ?, ?)",
                    new Object[]{title, desc, cover, sort, f.isActive()},
                    new int[]{Types.NVARCHAR, Types.NVARCHAR, Types.NVARCHAR, Types.INTEGER, Types.BIT},
                    Integer.class);
        } else {
            int n = jdbc.update(
                    "UPDATE Lookbooks SET Title = ?, Description = ?, CoverImageUrl = ?, SortOrder = ?, IsActive = ? "
                            + "WHERE LookbookId = ?",
                    new Object[]{title, desc, cover, sort, f.isActive(), id},
                    new int[]{Types.NVARCHAR, Types.NVARCHAR, Types.NVARCHAR, Types.INTEGER, Types.BIT, Types.INTEGER});
            if (n == 0) {
                throw new IllegalArgumentException("Không tìm thấy bộ sưu tập");
            }
            jdbc.update("DELETE FROM LookbookItems WHERE LookbookId = ?", id);   // ghi lại toàn bộ ảnh theo thứ tự mới
        }

        // Ghi các ảnh theo đúng thứ tự trên form (bỏ ảnh trống, trùng; sản phẩm không tồn tại thì bỏ gắn)
        Set<Integer> validProducts = new HashSet<>(jdbc.queryForList("SELECT ProductId FROM Products", Integer.class));
        Set<String> seen = new HashSet<>();
        int order = 1;
        for (LookbookItemForm it : f.getItems()) {
            if (it == null || it.getImageUrl() == null) continue;
            String img = it.getImageUrl().trim();
            if (img.isEmpty() || img.length() > 500 || !seen.add(img)) continue;

            Integer pid = it.getProductId();
            if (pid != null && !validProducts.contains(pid)) pid = null;

            jdbc.update(
                    "INSERT INTO LookbookItems (LookbookId, ProductId, ImageUrl, Caption, SortOrder) VALUES (?, ?, ?, ?, ?)",
                    new Object[]{id, pid, img, blankToNull(it.getCaption()), order++},
                    new int[]{Types.INTEGER, Types.INTEGER, Types.NVARCHAR, Types.NVARCHAR, Types.INTEGER});
        }
    }

    @Transactional
    public void delete(Integer id) {
        jdbc.update("DELETE FROM Lookbooks WHERE LookbookId = ?", id);   // ảnh bị xóa theo (ON DELETE CASCADE)
    }

    // ---------- Tiện ích ----------
    private static LookbookDto mapLookbook(ResultSet rs, int rowNum) throws SQLException {
        LookbookDto d = new LookbookDto();
        d.setId(rs.getInt("LookbookId"));
        d.setTitle(rs.getString("Title"));
        d.setDescription(rs.getString("Description"));
        String cover = rs.getString("CoverImageUrl");
        if (cover == null || cover.isBlank()) {
            cover = rs.getString("FirstImage");        // không có ảnh bìa thì lấy ảnh đầu tiên
        }
        d.setCoverImageUrl(cover);
        d.setSortOrder(rs.getInt("SortOrder"));
        d.setActive(rs.getBoolean("IsActive"));
        d.setPhotoCount(rs.getInt("PhotoCount"));
        return d;
    }

    private static String blankToNull(String s) {
        return (s == null || s.isBlank()) ? null : s.trim();
    }
}