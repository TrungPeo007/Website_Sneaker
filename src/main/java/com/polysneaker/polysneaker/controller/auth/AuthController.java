package com.polysneaker.polysneaker.controller.auth;

import com.polysneaker.polysneaker.dto.LoginUser;
import com.polysneaker.polysneaker.dto.PendingRegistration;
import com.polysneaker.polysneaker.dto.RegisterForm;
import com.polysneaker.polysneaker.dto.RegisteredInfo;
import com.polysneaker.polysneaker.entity.Account;
import com.polysneaker.polysneaker.interceptor.LoginRequiredInterceptor;
import com.polysneaker.polysneaker.service.account.AccountExportService;
import com.polysneaker.polysneaker.service.account.AccountService;
import com.polysneaker.polysneaker.service.mail.EmailService;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.http.ContentDisposition;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.mail.MailException;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.SecureRandom;
import java.util.Map;

@Controller
public class AuthController {

    private static final Logger log = LoggerFactory.getLogger(AuthController.class);
    private static final long RESEND_COOLDOWN_MS = 60_000L;
    private static final int MAX_ATTEMPTS = 5;
    private static final SecureRandom RANDOM = new SecureRandom();

    // Tên view = đường dẫn tính từ /WEB-INF/views/, bỏ đuôi .jsp
    private static final String VIEW_LOGIN = "login/login";
    private static final String VIEW_REGISTER = "register/register";
    private static final String VIEW_REGISTER_VERIFY = "register/register-verify";
    private static final String VIEW_REGISTER_SUCCESS = "register/register-success";

    private final AccountService accountService;
    private final EmailService emailService;
    private final AccountExportService exportService;

    public AuthController(AccountService accountService,
                          EmailService emailService,
                          AccountExportService exportService) {
        this.accountService = accountService;
        this.emailService = emailService;
        this.exportService = exportService;
    }

    // ---------- LOGIN ----------
    @GetMapping("/login")
    public String loginPage(HttpSession session, Model model) {
        if (session.getAttribute(LoginUser.SESSION_KEY) != null) {
            return "redirect:/";
        }
        // Thông báo "Vui lòng đăng nhập để mua hàng" do interceptor để lại
        Object notice = session.getAttribute(LoginRequiredInterceptor.LOGIN_NOTICE);
        if (notice != null) {
            model.addAttribute("info", notice);
            session.removeAttribute(LoginRequiredInterceptor.LOGIN_NOTICE);
        }
        return VIEW_LOGIN;
    }

    @PostMapping("/login")
    public String login(@RequestParam(defaultValue = "") String username,
                        @RequestParam(defaultValue = "") String password,
                        HttpServletRequest request,
                        Model model) {
        try {
            Account account = accountService.login(username, password);

            HttpSession session = request.getSession(true);
            request.changeSessionId(); // chống session fixation
            session.setAttribute(LoginUser.SESSION_KEY,
                    new LoginUser(account.getId(), account.getUsername(), account.getRole()));

            // Lấy trang đang định vào (nếu có) rồi xóa khỏi session
            String back = (String) session.getAttribute(LoginRequiredInterceptor.RETURN_URL);
            session.removeAttribute(LoginRequiredInterceptor.RETURN_URL);

            if ("ADMIN".equals(account.getRole())) {
                return "redirect:/admin";
            }
            // Chỉ chấp nhận đường dẫn nội bộ, tránh bị chuyển sang web lạ
            if (back != null && back.startsWith("/") && !back.startsWith("//")) {
                return "redirect:" + back;
            }
            return "redirect:/";
        } catch (IllegalArgumentException e) {
            model.addAttribute("error", e.getMessage());
            model.addAttribute("username", username);
            return VIEW_LOGIN;
        }
    }

    // ---------- REGISTER (bước 1: nhập thông tin, gửi OTP) ----------
    @GetMapping("/register")
    public String registerPage(HttpSession session, Model model) {
        if (session.getAttribute(LoginUser.SESSION_KEY) != null) {
            return "redirect:/";
        }
        model.addAttribute("registerForm", new RegisterForm());
        return VIEW_REGISTER;
    }

    @PostMapping("/register")
    public String register(@ModelAttribute("registerForm") RegisterForm form,
                           HttpSession session,
                           Model model) {
        Map<String, String> errors = accountService.validateRegister(form);

        if (errors.isEmpty()) {
            PendingRegistration pending = new PendingRegistration(
                    form.getUsername().trim(), form.getEmail().trim(), form.getPassword());
            pending.renewCode(generateCode());

            try {
                emailService.sendRegisterCode(pending.getEmail(), pending.getUsername(), pending.getCode());
                session.setAttribute(PendingRegistration.SESSION_KEY, pending);
                return "redirect:/register/verify";
            } catch (MailException e) {
                log.error("Gửi mail OTP thất bại", e);
                errors.put("general", "Không gửi được email xác thực. Hãy kiểm tra lại địa chỉ email hoặc thử lại sau.");
            }
        }
        model.addAttribute("errors", errors);
        return VIEW_REGISTER;
    }

    // ---------- REGISTER (bước 2: nhập OTP) ----------
    @GetMapping("/register/verify")
    public String verifyPage(HttpSession session, Model model) {
        PendingRegistration pending = (PendingRegistration) session.getAttribute(PendingRegistration.SESSION_KEY);
        if (pending == null) {
            return "redirect:/register";
        }
        model.addAttribute("maskedEmail", maskEmail(pending.getEmail()));
        return VIEW_REGISTER_VERIFY;
    }

    @PostMapping("/register/verify")
    public String verify(@RequestParam(defaultValue = "") String code,
                         HttpSession session,
                         Model model,
                         RedirectAttributes redirectAttributes) {
        PendingRegistration pending = (PendingRegistration) session.getAttribute(PendingRegistration.SESSION_KEY);
        if (pending == null) {
            return "redirect:/register";
        }
        model.addAttribute("maskedEmail", maskEmail(pending.getEmail()));

        if (System.currentTimeMillis() > pending.getExpiresAt()) {
            model.addAttribute("error", "Mã đã hết hạn. Hãy bấm \"Gửi lại mã\".");
            return VIEW_REGISTER_VERIFY;
        }
        if (pending.getAttempts() >= MAX_ATTEMPTS) {
            session.removeAttribute(PendingRegistration.SESSION_KEY);
            redirectAttributes.addFlashAttribute("error", "Bạn đã nhập sai quá nhiều lần. Vui lòng đăng ký lại.");
            return "redirect:/register";
        }

        boolean match = MessageDigest.isEqual(
                code.trim().getBytes(StandardCharsets.UTF_8),
                pending.getCode().getBytes(StandardCharsets.UTF_8));
        if (!match) {
            pending.increaseAttempts();
            int left = MAX_ATTEMPTS - pending.getAttempts();
            model.addAttribute("error", "Mã không đúng. Còn " + left + " lần thử.");
            return VIEW_REGISTER_VERIFY;
        }

        // Mã đúng -> tạo tài khoản thật
        RegisterForm form = new RegisterForm();
        form.setUsername(pending.getUsername());
        form.setEmail(pending.getEmail());
        form.setPassword(pending.getPassword());
        form.setConfirmPassword(pending.getPassword());

        try {
            accountService.register(form);
        } catch (DataIntegrityViolationException e) {
            // Trong lúc chờ mã có người khác đã lấy mất username/email
            session.removeAttribute(PendingRegistration.SESSION_KEY);
            redirectAttributes.addFlashAttribute("error", "Tên đăng nhập hoặc email đã tồn tại.");
            return "redirect:/register";
        }

        // Tài khoản đã lưu vào DB -> gửi email xác nhận (lỗi mail không làm hỏng đăng ký)
        try {
            emailService.sendRegisterSuccess(pending.getEmail(), pending.getUsername());
        } catch (Exception e) {
            log.error("Gửi mail xác nhận đăng ký thất bại", e);
        }

        // Giữ tạm thông tin để khách tải file Excel ở trang kế tiếp
        session.setAttribute(RegisteredInfo.SESSION_KEY,
                new RegisteredInfo(pending.getUsername(), pending.getEmail(), pending.getPassword()));
        session.removeAttribute(PendingRegistration.SESSION_KEY);
        return "redirect:/register/success";
    }

    @PostMapping("/register/resend")
    public String resend(HttpSession session, RedirectAttributes redirectAttributes) {
        PendingRegistration pending = (PendingRegistration) session.getAttribute(PendingRegistration.SESSION_KEY);
        if (pending == null) {
            return "redirect:/register";
        }

        long wait = RESEND_COOLDOWN_MS - (System.currentTimeMillis() - pending.getLastSentAt());
        if (wait > 0) {
            redirectAttributes.addFlashAttribute("error",
                    "Vui lòng đợi " + (wait / 1000 + 1) + " giây rồi gửi lại.");
            return "redirect:/register/verify";
        }

        pending.renewCode(generateCode());
        try {
            emailService.sendRegisterCode(pending.getEmail(), pending.getUsername(), pending.getCode());
            redirectAttributes.addFlashAttribute("info", "Đã gửi lại mã mới vào email của bạn.");
        } catch (MailException e) {
            log.error("Gửi lại mail OTP thất bại", e);
            redirectAttributes.addFlashAttribute("error", "Không gửi được email, thử lại sau.");
        }
        return "redirect:/register/verify";
    }

    /** Khách muốn đổi email / nhập lại thông tin. */
    @GetMapping("/register/cancel")
    public String cancel(HttpSession session) {
        session.removeAttribute(PendingRegistration.SESSION_KEY);
        return "redirect:/register";
    }

    // ---------- REGISTER (bước 3: tải file Excel thông tin tài khoản) ----------
    @GetMapping("/register/success")
    public String success(HttpSession session, Model model) {
        RegisteredInfo info = (RegisteredInfo) session.getAttribute(RegisteredInfo.SESSION_KEY);
        if (info == null) {
            return "redirect:/login";
        }
        model.addAttribute("username", info.getUsername());
        model.addAttribute("email", info.getEmail());
        return VIEW_REGISTER_SUCCESS;
    }

    @GetMapping("/register/export")
    public ResponseEntity<byte[]> export(HttpSession session) {
        RegisteredInfo info = (RegisteredInfo) session.getAttribute(RegisteredInfo.SESSION_KEY);
        if (info == null) {
            return ResponseEntity.status(403).build();
        }
        try {
            byte[] data = exportService.buildXlsx(info);
            return ResponseEntity.ok()
                    .header(HttpHeaders.CONTENT_DISPOSITION,
                            ContentDisposition.attachment()
                                    .filename("PolySneaker-tai-khoan.xlsx", StandardCharsets.UTF_8)
                                    .build().toString())
                    .header(HttpHeaders.CACHE_CONTROL, "no-store")
                    .contentType(MediaType.parseMediaType(
                            "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"))
                    .body(data);
        } catch (Exception e) {
            log.error("Xuất file Excel thất bại", e);
            return ResponseEntity.internalServerError().build();
        }
    }

    /** Khách đã lưu xong file -> xóa thông tin khỏi session rồi về trang đăng nhập. */
    @GetMapping("/register/done")
    public String done(HttpSession session, RedirectAttributes redirectAttributes) {
        session.removeAttribute(RegisteredInfo.SESSION_KEY);
        redirectAttributes.addFlashAttribute("success", "Đăng ký thành công! Hãy đăng nhập.");
        return "redirect:/login";
    }

    // ---------- LOGOUT ----------
    @GetMapping("/logout")
    public String logout(HttpSession session) {
        session.invalidate();
        return "redirect:/login";
    }

    // ---------- helpers ----------
    private static String generateCode() {
        return String.format("%06d", RANDOM.nextInt(1_000_000));
    }

    private static String maskEmail(String email) {
        int at = email.indexOf('@');
        if (at <= 1) return email;
        return email.charAt(0) + "***" + email.substring(at);
    }
}