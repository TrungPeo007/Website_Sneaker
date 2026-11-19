package com.polysneaker.polysneaker.interceptor;

import com.polysneaker.polysneaker.dto.LoginUser;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import org.springframework.stereotype.Component;
import org.springframework.web.servlet.HandlerInterceptor;

import java.io.IOException;
import java.net.URI;

/**
 * Chặn người chưa đăng nhập vào /cart, /checkout, /orders.
 * Lưu lại trang đang muốn vào để đăng nhập xong quay lại đúng chỗ.
 */
@Component
public class LoginRequiredInterceptor implements HandlerInterceptor {

    public static final String RETURN_URL = "RETURN_URL";
    public static final String LOGIN_NOTICE = "LOGIN_NOTICE";

    @Override
    public boolean preHandle(HttpServletRequest req, HttpServletResponse res, Object handler)
            throws IOException {

        HttpSession session = req.getSession(false);
        if (session != null && session.getAttribute(LoginUser.SESSION_KEY) != null) {
            return true;
        }

        // Gọi bằng fetch/AJAX thì trả 401 để JS tự chuyển trang, không redirect
        boolean ajax = "XMLHttpRequest".equals(req.getHeader("X-Requested-With"))
                || String.valueOf(req.getHeader("Accept")).contains("application/json");
        if (ajax) {
            res.sendError(HttpServletResponse.SC_UNAUTHORIZED);
            return false;
        }

        HttpSession s = req.getSession(true);

        // GET: quay lại chính trang này. POST (vd. Thêm vào giỏ): quay lại trang khách đang đứng.
        String back;
        if ("GET".equals(req.getMethod())) {
            String path = req.getRequestURI().substring(req.getContextPath().length());
            String qs = req.getQueryString();
            back = qs == null ? path : path + "?" + qs;
        } else {
            back = fromReferer(req);
        }
        if (back != null) {
            s.setAttribute(RETURN_URL, back);
        }

        s.setAttribute(LOGIN_NOTICE, "Vui lòng đăng nhập để mua hàng.");
        res.sendRedirect(req.getContextPath() + "/login");
        return false;
    }

    /** Lấy lại trang khách đang đứng từ header Referer (chỉ nhận trang cùng website). */
    private static String fromReferer(HttpServletRequest req) {
        String ref = req.getHeader("Referer");
        if (ref == null) {
            return null;
        }
        try {
            URI uri = URI.create(ref);
            if (uri.getHost() == null || !uri.getHost().equalsIgnoreCase(req.getServerName())) {
                return null;
            }
            String path = uri.getRawPath();
            String ctx = req.getContextPath();
            if (path == null || !path.startsWith(ctx)) {
                return null;
            }
            path = path.substring(ctx.length());
            if (path.isEmpty() || !path.startsWith("/") || path.startsWith("//")) {
                return null;
            }
            return uri.getRawQuery() == null ? path : path + "?" + uri.getRawQuery();
        } catch (IllegalArgumentException e) {
            return null;
        }
    }
}