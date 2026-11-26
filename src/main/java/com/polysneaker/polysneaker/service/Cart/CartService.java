package com.polysneaker.polysneaker.service.Cart;

import com.polysneaker.polysneaker.repository.CartRepository;
import com.polysneaker.polysneaker.service.exception.ShopException;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Collection;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

@Service
public class CartService {

    /** Số lượng tối đa cho mỗi lần thêm/đổi, để chặn số lượng vô lý. */
    private static final int MAX_QUANTITY = 1000;

    private final CartRepository cartRepository;

    public CartService(CartRepository cartRepository) {
        this.cartRepository = cartRepository;
    }

    // =====================================================
    // 1. LẤY GIỎ HÀNG
    // =====================================================

    public Cart load(int accountId) {
        List<Map<String, Object>> items =
                cartRepository.findCartItems(accountId);

        return new Cart(items);
    }

    // Lấy các dòng đã chọn để thanh toán. ids == null: cả giỏ. ids rỗng: không có gì.
    public Cart load(int accountId, Collection<Integer> ids) {
        return new Cart(cartRepository.findCartItems(accountId, ids));
    }

    // "12,15,18" -> {12,15,18}. Trả null nếu không truyền gì (nghĩa là lấy cả giỏ).
    public static Set<Integer> parseIds(String csv) {

        if (csv == null || csv.isBlank()) {
            return null;
        }

        Set<Integer> ids = new LinkedHashSet<>();

        for (String part : csv.split(",")) {
            try {
                ids.add(Integer.parseInt(part.trim()));
            } catch (NumberFormatException ignored) {
                // bỏ qua giá trị rác
            }
            if (ids.size() >= 100) {
                break;
            }
        }

        return ids;
    }

    // Id dòng giỏ hàng của một size, dùng cho "Mua ngay"
    public Integer findCartItemId(int accountId, int productDetailId) {
        return cartRepository.findCartItemId(accountId, productDetailId);
    }

    // =====================================================
    // 2. THÊM SẢN PHẨM THEO PRODUCT DETAIL ID
    // =====================================================

    @Transactional
    public void add(
            int accountId,
            int productDetailId,
            int quantity) {

        if (quantity < 1 || quantity > MAX_QUANTITY) {
            throw new ShopException("Số lượng không hợp lệ");
        }

        Map<String, Object> product =
                cartRepository.findProductDetail(productDetailId);

        if (product == null) {
            throw new ShopException("Sản phẩm không tồn tại");
        }

        int productActive =
                ((Number) product.get("ProductActive")).intValue();

        int detailActive =
                ((Number) product.get("DetailActive")).intValue();

        int stock =
                ((Number) product.get("StockQuantity")).intValue();

        if (productActive != 1 || detailActive != 1) {
            throw new ShopException(
                    "Sản phẩm hiện không còn kinh doanh"
            );
        }

        if (stock <= 0) {
            throw new ShopException("Sản phẩm hiện đã hết hàng");
        }

        Integer currentQuantity =
                cartRepository.findQuantity(accountId, productDetailId);

        int newQuantity = currentQuantity == null
                ? quantity
                : currentQuantity + quantity;

        if (newQuantity > stock) {
            throw new ShopException(
                    "Số lượng vượt quá tồn kho. Hiện còn " + stock
            );
        }

        if (currentQuantity == null) {

            cartRepository.insert(
                    accountId,
                    productDetailId,
                    quantity
            );

        } else {

            cartRepository.updateQuantity(
                    accountId,
                    productDetailId,
                    newQuantity
            );
        }
    }

    // =====================================================
    // 3. THÊM SẢN PHẨM THEO PRODUCT ID VÀ SIZE
    // =====================================================

    @Transactional
    public void addBySize(
            int accountId,
            int productId,
            String size,
            int quantity) {

        if (size == null || size.isBlank()) {
            throw new ShopException("Vui lòng chọn kích thước");
        }

        Integer productDetailId =
                cartRepository.findProductDetailIdBySize(
                        productId,
                        size
                );

        if (productDetailId == null) {
            throw new ShopException(
                    "Không tìm thấy kích thước sản phẩm"
            );
        }

        add(accountId, productDetailId, quantity);
    }

    // =====================================================
    // 4. CẬP NHẬT SỐ LƯỢNG SẢN PHẨM
    // =====================================================

    @Transactional
    public void setQuantity(
            int accountId,
            int cartItemId,
            int quantity) {

        if (quantity < 1 || quantity > MAX_QUANTITY) {
            throw new ShopException("Số lượng không hợp lệ");
        }

        Map<String, Object> item =
                cartRepository.findCartItem(accountId, cartItemId);

        if (item == null) {
            throw new ShopException(
                    "Sản phẩm không tồn tại trong giỏ hàng"
            );
        }

        int stock =
                ((Number) item.get("StockQuantity")).intValue();

        int productActive =
                ((Number) item.get("ProductActive")).intValue();

        int detailActive =
                ((Number) item.get("DetailActive")).intValue();

        if (productActive != 1 || detailActive != 1) {
            throw new ShopException(
                    "Sản phẩm hiện không còn kinh doanh"
            );
        }

        if (stock <= 0) {
            throw new ShopException("Sản phẩm hiện đã hết hàng");
        }

        if (quantity > stock) {
            throw new ShopException(
                    "Số lượng vượt quá tồn kho. Hiện còn " + stock
            );
        }

        cartRepository.updateCartItem(
                accountId,
                cartItemId,
                quantity
        );
    }

    // =====================================================
    // 5. XÓA SẢN PHẨM KHỎI GIỎ HÀNG
    // =====================================================

    @Transactional
    public void remove(int accountId, int cartItemId) {

        int deleted = cartRepository.deleteCartItem(
                accountId,
                cartItemId
        );

        if (deleted == 0) {
            throw new ShopException(
                    "Không tìm thấy sản phẩm trong giỏ hàng"
            );
        }
    }

    // =====================================================
    // 6. XÓA NHIỀU DÒNG (sau khi đặt hàng: chỉ xóa dòng đã thanh toán)
    // =====================================================

    @Transactional
    public void removeMany(int accountId, Collection<Integer> ids) {
        cartRepository.deleteCartItems(accountId, ids);
    }
}