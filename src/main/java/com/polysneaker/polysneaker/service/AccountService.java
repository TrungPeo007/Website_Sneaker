package com.polysneaker.polysneaker.service;

import com.polysneaker.polysneaker.dto.RegisterForm;
import com.polysneaker.polysneaker.entity.Account;
import com.polysneaker.polysneaker.repository.AccountRepository;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.regex.Pattern;

@Service
public class AccountService {

    private static final Pattern USERNAME = Pattern.compile("^[A-Za-z0-9_.]{3,50}$");
    private static final Pattern EMAIL = Pattern.compile("^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$");

    private final AccountRepository accountRepository;
    private final PasswordEncoder passwordEncoder;

    public AccountService(AccountRepository accountRepository, PasswordEncoder passwordEncoder) {
        this.accountRepository = accountRepository;
        this.passwordEncoder = passwordEncoder;
    }

    /** Kiểm tra form đăng ký. Trả về map lỗi theo từng field (rỗng = hợp lệ). */
    public Map<String, String> validateRegister(RegisterForm form) {
        Map<String, String> errors = new LinkedHashMap<>();

        String username = clean(form.getUsername());
        String email = clean(form.getEmail());
        String password = form.getPassword() == null ? "" : form.getPassword();
        String confirm = form.getConfirmPassword() == null ? "" : form.getConfirmPassword();

        if (!USERNAME.matcher(username).matches()) {
            errors.put("username", "Tên đăng nhập 3-50 ký tự, chỉ gồm chữ, số, dấu _ hoặc .");
        } else if (accountRepository.existsByUsername(username)) {
            errors.put("username", "Tên đăng nhập đã tồn tại");
        }

        if (email.length() > 100 || !EMAIL.matcher(email).matches()) {
            errors.put("email", "Email không hợp lệ");
        } else if (accountRepository.existsByEmail(email)) {
            errors.put("email", "Email đã được sử dụng");
        }

        if (password.length() < 6 || password.length() > 50) {
            errors.put("password", "Mật khẩu từ 6 đến 50 ký tự");
        }

        if (!password.equals(confirm)) {
            errors.put("confirmPassword", "Mật khẩu nhập lại không khớp");
        }

        return errors;
    }

    /** Tạo tài khoản khách hàng. Luôn là CUSTOMER, không ai đăng ký thành ADMIN được. */
    @Transactional
    public Account register(RegisterForm form) {
        Account account = new Account();
        account.setUsername(clean(form.getUsername()));
        account.setEmail(clean(form.getEmail()));
        account.setPassword(passwordEncoder.encode(form.getPassword()));
        account.setRole("CUSTOMER");
        account.setActive(true);
        return accountRepository.save(account);
    }

    /**
     * Đăng nhập.
     * - CUSTOMER: so sánh với hash BCrypt.
     * - ADMIN: mật khẩu lưu chữ thường trong DB thì so sánh thẳng;
     *          nếu DB vẫn đang là hash BCrypt ($2a$...) thì vẫn đăng nhập được bằng matches().
     * Sai thông tin hoặc tài khoản bị khóa thì ném IllegalArgumentException kèm thông báo.
     */
    @Transactional(readOnly = true)
    public Account login(String username, String rawPassword) {
        String invalid = "Sai tên đăng nhập hoặc mật khẩu";

        Account account = accountRepository.findByUsername(clean(username))
                .orElseThrow(() -> new IllegalArgumentException(invalid));

        if (rawPassword == null || !passwordMatches(account, rawPassword)) {
            throw new IllegalArgumentException(invalid);
        }
        if (!account.isActive()) {
            throw new IllegalArgumentException("Tài khoản đã bị khóa");
        }
        return account;
    }

    private boolean passwordMatches(Account account, String rawPassword) {
        String stored = account.getPassword();
        if (stored == null) {
            return false;
        }

        boolean isAdmin = "ADMIN".equals(account.getRole());
        boolean looksLikeBcrypt = stored.startsWith("$2");

        if (isAdmin && !looksLikeBcrypt) {
            return MessageDigest.isEqual(
                    rawPassword.getBytes(StandardCharsets.UTF_8),
                    stored.getBytes(StandardCharsets.UTF_8));
        }
        return passwordEncoder.matches(rawPassword, stored);
    }

    private String clean(String value) {
        return value == null ? "" : value.trim();
    }
}