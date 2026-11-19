package com.polysneaker.polysneaker.repository;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.Collection;
import java.util.List;
import java.util.Map;

@Repository
public class CartRepository {

    private final JdbcTemplate jdbcTemplate;

    public CartRepository(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    private static final String CART_SELECT = """
            SELECT
                ci.CartItemId,
                ci.ProductDetailId,
                ci.Quantity,
                p.ProductId,
                p.ProductName,
                p.MainImageUrl,
                pd.Size,
                pd.StockQuantity,
                p.SalePrice,
                p.OriginalPrice,
                CASE WHEN p.IsActive = 1 AND pd.IsActive = 1 THEN 1 ELSE 0 END AS Sellable
            FROM dbo.CartItems ci
            JOIN dbo.ProductDetails pd
                ON pd.ProductDetailId = ci.ProductDetailId
            JOIN dbo.Products p
                ON p.ProductId = pd.ProductId
            WHERE ci.AccountId = ?
            """;

    // Lấy các dòng giỏ hàng. ids == null: cả giỏ. ids rỗng: không có gì. Có ids: chỉ các dòng đó.
    public List<Map<String, Object>> findCartItems(int accountId, Collection<Integer> ids) {

        if (ids != null && ids.isEmpty()) {
            return List.of();
        }

        StringBuilder sql = new StringBuilder(CART_SELECT);
        List<Object> args = new ArrayList<>();
        args.add(accountId);

        if (ids != null) {
            sql.append(" AND ci.CartItemId IN (").append(placeholders(ids.size())).append(")");
            args.addAll(ids);
        }
        sql.append(" ORDER BY ci.CartItemId");

        return jdbcTemplate.queryForList(sql.toString(), args.toArray());
    }

    public List<Map<String, Object>> findCartItems(int accountId) {
        return findCartItems(accountId, null);
    }

    // Một dòng giỏ hàng (kèm tồn kho và trạng thái bán). IsActive trả về 1/0 để ép Number được.
    public Map<String, Object> findCartItem(int accountId, int cartItemId) {

        List<Map<String, Object>> rows = jdbcTemplate.queryForList(
            """
            SELECT
                ci.CartItemId,
                ci.ProductDetailId,
                ci.Quantity,
                pd.StockQuantity,
                CASE WHEN pd.IsActive = 1 THEN 1 ELSE 0 END AS DetailActive,
                CASE WHEN p.IsActive = 1 THEN 1 ELSE 0 END AS ProductActive
            FROM dbo.CartItems ci
            JOIN dbo.ProductDetails pd
                ON pd.ProductDetailId = ci.ProductDetailId
            JOIN dbo.Products p
                ON p.ProductId = pd.ProductId
            WHERE ci.CartItemId = ?
              AND ci.AccountId = ?
            """,
            cartItemId,
            accountId
        );

        return rows.isEmpty() ? null : rows.get(0);
    }

    // Tìm thông tin ProductDetail. IsActive trả về 1/0 (cột BIT của SQL Server trả về Boolean, không ép Number được).
    public Map<String, Object> findProductDetail(int productDetailId) {

        List<Map<String, Object>> rows = jdbcTemplate.queryForList(
            """
            SELECT
                pd.ProductDetailId,
                pd.ProductId,
                pd.Size,
                pd.StockQuantity,
                CASE WHEN pd.IsActive = 1 THEN 1 ELSE 0 END AS DetailActive,
                CASE WHEN p.IsActive = 1 THEN 1 ELSE 0 END AS ProductActive
            FROM dbo.ProductDetails pd
            JOIN dbo.Products p
                ON p.ProductId = pd.ProductId
            WHERE pd.ProductDetailId = ?
            """,
            productDetailId
        );

        return rows.isEmpty() ? null : rows.get(0);
    }

    // Tìm id của size theo (sản phẩm + size). Size không phải số thì coi như không tìm thấy.
    public Integer findProductDetailIdBySize(int productId, String size) {

        BigDecimal sizeValue;
        try {
            sizeValue = new BigDecimal(size.trim());
        } catch (NumberFormatException | NullPointerException e) {
            return null;
        }

        List<Integer> rows = jdbcTemplate.query(
            """
            SELECT ProductDetailId
            FROM dbo.ProductDetails
            WHERE ProductId = ?
              AND Size = ?
            """,
            (rs, rowNum) -> rs.getInt("ProductDetailId"),
            productId,
            sizeValue
        );

        return rows.isEmpty() ? null : rows.get(0);
    }

    // Tìm số lượng hiện tại trong giỏ
    public Integer findQuantity(int accountId, int productDetailId) {

        List<Integer> rows = jdbcTemplate.query(
            """
            SELECT Quantity
            FROM dbo.CartItems
            WHERE AccountId = ?
              AND ProductDetailId = ?
            """,
            (rs, rowNum) -> rs.getInt("Quantity"),
            accountId,
            productDetailId
        );

        return rows.isEmpty() ? null : rows.get(0);
    }

    // Lấy id dòng giỏ hàng theo (tài khoản + size), dùng cho "Mua ngay"
    public Integer findCartItemId(int accountId, int productDetailId) {

        List<Integer> rows = jdbcTemplate.query(
            """
            SELECT CartItemId
            FROM dbo.CartItems
            WHERE AccountId = ?
              AND ProductDetailId = ?
            """,
            (rs, rowNum) -> rs.getInt("CartItemId"),
            accountId,
            productDetailId
        );

        return rows.isEmpty() ? null : rows.get(0);
    }

    // Thêm sản phẩm
    public void insert(int accountId, int productDetailId, int quantity) {

        jdbcTemplate.update(
            """
            INSERT INTO dbo.CartItems
                (AccountId, ProductDetailId, Quantity)
            VALUES (?, ?, ?)
            """,
            accountId,
            productDetailId,
            quantity
        );
    }

    // Cập nhật số lượng theo (tài khoản + size)
    public void updateQuantity(
            int accountId,
            int productDetailId,
            int quantity) {

        jdbcTemplate.update(
            """
            UPDATE dbo.CartItems
            SET Quantity = ?
            WHERE AccountId = ?
              AND ProductDetailId = ?
            """,
            quantity,
            accountId,
            productDetailId
        );
    }

    // Cập nhật số lượng theo dòng giỏ hàng
    public int updateCartItem(int accountId, int cartItemId, int quantity) {

        return jdbcTemplate.update(
            """
            UPDATE dbo.CartItems
            SET Quantity = ?
            WHERE CartItemId = ?
              AND AccountId = ?
            """,
            quantity,
            cartItemId,
            accountId
        );
    }

    // Xóa 1 dòng, trả về số dòng đã xóa (0 nếu không có)
    public int deleteCartItem(int accountId, int cartItemId) {

        return jdbcTemplate.update(
            """
            DELETE FROM dbo.CartItems
            WHERE CartItemId = ?
              AND AccountId = ?
            """,
            cartItemId,
            accountId
        );
    }

    // Xóa nhiều dòng (sau khi đặt hàng: chỉ xóa các dòng đã thanh toán)
    public int deleteCartItems(int accountId, Collection<Integer> ids) {

        if (ids == null || ids.isEmpty()) {
            return 0;
        }

        List<Object> args = new ArrayList<>();
        args.add(accountId);
        args.addAll(ids);

        return jdbcTemplate.update(
            "DELETE FROM dbo.CartItems WHERE AccountId = ? AND CartItemId IN ("
                + placeholders(ids.size()) + ")",
            args.toArray()
        );
    }

    private static String placeholders(int n) {
        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < n; i++) {
            sb.append(i == 0 ? "?" : ",?");
        }
        return sb.toString();
    }
}