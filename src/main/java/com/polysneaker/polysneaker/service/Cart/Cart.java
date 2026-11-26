
package com.polysneaker.polysneaker.service.Cart;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

public class Cart {

    private final List<Map<String, Object>> items;

    public Cart(List<Map<String, Object>> items) {
        this.items = items != null
                ? items
                : new ArrayList<>();
    }

    // Lấy danh sách sản phẩm
    public List<Map<String, Object>> items() {
        return items;
    }

    // Tổng số lượng sản phẩm
    public int totalQuantity() {
        int total = 0;

        for (Map<String, Object> item : items) {
            Object value = item.get("Quantity");

            if (value instanceof Number quantity) {
                total += quantity.intValue();
            }
        }

        return total;
    }

    // Tổng tiền giỏ hàng
    public long subtotal() {
        long total = 0;

        for (Map<String, Object> item : items) {
            Object priceValue = item.get("SalePrice");
            Object quantityValue = item.get("Quantity");

            if (priceValue instanceof Number price
                    && quantityValue instanceof Number quantity) {

                total += price.longValue() * quantity.intValue();
            }
        }

        return total;
    }
}
