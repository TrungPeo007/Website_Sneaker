package com.polysneaker.polysneaker.controller;

import com.polysneaker.polysneaker.dto.LoginUser;
import com.polysneaker.polysneaker.dto.RegisterForm;
import com.polysneaker.polysneaker.entity.Account;
import com.polysneaker.polysneaker.service.AccountService;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.util.Map;

@Controller
public class AuthController {

    private final AccountService accountService;

    public AuthController(AccountService accountService) {
        this.accountService = accountService;
    }

    // ---------- LOGIN ----------
    @GetMapping("/login")
    public String loginPage(HttpSession session) {
        if (session.getAttribute(LoginUser.SESSION_KEY) != null) {
            return "redirect:/";
        }
        return "login";
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

            return "ADMIN".equals(account.getRole()) ? "redirect:/admin" : "redirect:/";
        } catch (IllegalArgumentException e) {
            model.addAttribute("error", e.getMessage());
            model.addAttribute("username", username);
            return "login";
        }
    }

    // ---------- REGISTER ----------
    @GetMapping("/register")
    public String registerPage(HttpSession session, Model model) {
        if (session.getAttribute(LoginUser.SESSION_KEY) != null) {
            return "redirect:/";
        }
        model.addAttribute("registerForm", new RegisterForm());
        return "register";
    }

    @PostMapping("/register")
    public String register(@ModelAttribute("registerForm") RegisterForm form,
                           Model model,
                           RedirectAttributes redirectAttributes) {
        Map<String, String> errors = accountService.validateRegister(form);

        if (errors.isEmpty()) {
            try {
                accountService.register(form);
                redirectAttributes.addFlashAttribute("success", "Đăng ký thành công! Hãy đăng nhập.");
                return "redirect:/login";
            } catch (DataIntegrityViolationException e) {
                errors.put("general", "Tên đăng nhập hoặc email đã tồn tại");
            }
        }

        model.addAttribute("errors", errors);
        return "register";
    }

    // ---------- LOGOUT ----------
    @GetMapping("/logout")
    public String logout(HttpSession session) {
        session.invalidate();
        return "redirect:/login";
    }
}