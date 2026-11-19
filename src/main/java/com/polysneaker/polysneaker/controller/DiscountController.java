package com.polysneaker.polysneaker.controller;

import com.polysneaker.polysneaker.service.CurrentUser;
import com.polysneaker.polysneaker.service.DiscountService;
import com.polysneaker.polysneaker.service.DiscountService.Applied;
import com.polysneaker.polysneaker.service.DiscountService.DiscountException;
import jakarta.servlet.http.HttpSession;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import java.util.LinkedHashMap;
import java.util.Map;

/** Phía khách: xem trước giảm giá ở checkout + trang "Voucher của tôi". */
@Controller
public class DiscountController {

    private final DiscountService service;

    public DiscountController(DiscountService service) {
        this.service = service;
    }

    /**
     * Xem trước số tiền giảm. subtotal ở đây chỉ để HIỂN THỊ; lúc đặt hàng thật,
     * DiscountService.redeem() tính lại từ tiền hàng của server.
     */
    @PostMapping("/api/discount/preview")
    @ResponseBody
    public Map<String, Object> preview(@RequestParam("subtotal") long subtotal,
                                       @RequestParam(name = "coupon", required = false) String coupon,
                                       @RequestParam(name = "voucher", required = false) String voucher,
                                       HttpSession session) {
        Map<String, Object> res = new LinkedHashMap<>();
        CurrentUser u = CurrentUser.from(session);
        if (u == null) {
            res.put("ok", false);
            res.put("message", "Vui lòng đăng nhập để dùng mã giảm giá");
            return res;
        }
        try {
            Applied a = service.preview(u.accountId(), subtotal, coupon, voucher);
            res.put("ok", true);
            res.put("couponDiscount", a.couponDiscount());
            res.put("voucherDiscount", a.voucherDiscount());
            res.put("totalDiscount", a.total());
            res.put("finalAmount", Math.max(0, subtotal - a.total()));
            res.put("message", a.total() > 0 ? "Áp dụng thành công" : "Chưa nhập mã");
        } catch (DiscountException e) {
            res.put("ok", false);
            res.put("message", e.getMessage());
        }
        return res;
    }

    @GetMapping("/my/vouchers")
    public String myVouchers(HttpSession session, Model model) {
        CurrentUser u = CurrentUser.from(session);
        if (u == null) return "redirect:/login";
        model.addAttribute("vouchers", service.myVouchers(u.accountId()));
        return "my-vouchers";
    }
}