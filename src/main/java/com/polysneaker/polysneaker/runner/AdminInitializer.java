package com.polysneaker.polysneaker.runner;

import com.polysneaker.polysneaker.repository.AccountRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

/**
 * Trong file SQL, mật khẩu admin đang là chuỗi giữ chỗ (chưa phải BCrypt).
 * Khi app khởi động, nếu mật khẩu admin chưa phải BCrypt thì tự mã hóa
 * bằng app.admin.default-password.
 */
@Component
@RequiredArgsConstructor
public class AdminInitializer implements ApplicationRunner {

    private final AccountRepository accountRepository;
    private final PasswordEncoder passwordEncoder;

    @Value("${app.admin.default-password:Admin@123}")
    private String defaultPassword;

    @Override
    public void run(ApplicationArguments args) {
        accountRepository.findFirstByRole("ADMIN").ifPresent(admin -> {
            if (!admin.getPassword().startsWith("$2")) {
                admin.setPassword(passwordEncoder.encode(defaultPassword));
                accountRepository.save(admin);
            }
        });
    }
}