package com.edusphere.controller.account;

import com.edusphere.dto.account.ChangePasswordRequest;
import com.edusphere.dto.account.ForgotPasswordRequest;
import com.edusphere.security.CustomUserDetails;
import com.edusphere.service.account.PasswordResetService;
import com.edusphere.service.account.ProfileService;

import jakarta.servlet.http.HttpSession;
import jakarta.validation.Valid;

import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

@Controller
public class PasswordController {

    private static final String SESSION_RESET_EMAIL          = "resetPasswordEmail";
    private static final String SESSION_RESET_OTP_VERIFIED   = "resetOtpVerified";
    private static final String SESSION_RESET_VERIFIED_EMAIL = "resetOtpVerifiedEmail";

    private final PasswordResetService passwordResetService;
    private final ProfileService profileService;

    public PasswordController(PasswordResetService passwordResetService,
                              ProfileService profileService) {
        this.passwordResetService = passwordResetService;
        this.profileService = profileService;
    }

    // ===== BƯỚC 1 — NHẬP EMAIL =====

    @GetMapping("/forgot-password")
    public String showForgotPage(Model model, HttpSession session) {
        session.removeAttribute(SESSION_RESET_OTP_VERIFIED);
        session.removeAttribute(SESSION_RESET_VERIFIED_EMAIL);
        model.addAttribute("forgotPasswordRequest", new ForgotPasswordRequest());
        return "auth/forgot-password";
    }

    @PostMapping("/forgot-password")
    public String processForgot(@Valid @ModelAttribute("forgotPasswordRequest") ForgotPasswordRequest req,
                                BindingResult bindingResult,
                                HttpSession session) {
        // Xóa hoàn toàn trạng thái xác thực cũ để chống tái sử dụng
        session.removeAttribute(SESSION_RESET_OTP_VERIFIED);
        session.removeAttribute(SESSION_RESET_VERIFIED_EMAIL);
        session.removeAttribute(SESSION_RESET_EMAIL);

        if (bindingResult.hasErrors()) return "auth/forgot-password";

        String email = req.getEmail().toLowerCase().trim();
        passwordResetService.processForgotPassword(email);
        session.setAttribute(SESSION_RESET_EMAIL, email);
        return "redirect:/forgot-password/verify-otp";
    }

    // ===== BƯỚC 2 — NHẬP OTP =====

    @GetMapping("/forgot-password/verify-otp")
    public String showResetOtpPage(HttpSession session, Model model) {
        String email = (String) session.getAttribute(SESSION_RESET_EMAIL);
        if (email == null) return "redirect:/forgot-password";
        model.addAttribute("maskedEmail", maskEmail(email));
        return "auth/forgot-password-otp";
    }

    @PostMapping("/forgot-password/verify-otp")
    public String processResetOtp(@RequestParam("otp") String otp,
                                  HttpSession session,
                                  Model model) {
        String email = (String) session.getAttribute(SESSION_RESET_EMAIL);
        if (email == null) return "redirect:/forgot-password";

        try {
            String verifiedEmail = passwordResetService.verifyResetOtp(email, otp);
            String normalizedEmail = (verifiedEmail != null ? verifiedEmail : email).toLowerCase().trim();
            session.setAttribute(SESSION_RESET_OTP_VERIFIED, true);
            session.setAttribute(SESSION_RESET_VERIFIED_EMAIL, normalizedEmail);
            return "redirect:/reset-password";
        } catch (IllegalArgumentException e) {
            session.removeAttribute(SESSION_RESET_OTP_VERIFIED);
            session.removeAttribute(SESSION_RESET_VERIFIED_EMAIL);
            model.addAttribute("errorMessage", e.getMessage());
            model.addAttribute("maskedEmail", maskEmail(email));
            return "auth/forgot-password-otp";
        }
    }

    @PostMapping("/forgot-password/resend-otp")
    public String resendResetOtp(HttpSession session, RedirectAttributes ra) {
        // Xóa hoàn toàn trạng thái xác thực cũ khi gửi lại OTP
        session.removeAttribute(SESSION_RESET_OTP_VERIFIED);
        session.removeAttribute(SESSION_RESET_VERIFIED_EMAIL);

        String email = (String) session.getAttribute(SESSION_RESET_EMAIL);
        if (email == null) return "redirect:/forgot-password";
        passwordResetService.resendResetOtp(email);
        ra.addFlashAttribute("successMessage", "Đã gửi lại mã OTP mới.");
        return "redirect:/forgot-password/verify-otp";
    }

    // ===== BƯỚC 3 — ĐẶT MẬT KHẨU MỚI =====

    @GetMapping("/reset-password")
    public String showResetPasswordPage(HttpSession session) {
        Boolean verified = (Boolean) session.getAttribute(SESSION_RESET_OTP_VERIFIED);
        String verifiedEmail = (String) session.getAttribute(SESSION_RESET_VERIFIED_EMAIL);
        String sessionEmail = (String) session.getAttribute(SESSION_RESET_EMAIL);

        if (verified == null || !verified || verifiedEmail == null || sessionEmail == null
                || !verifiedEmail.equalsIgnoreCase(sessionEmail)) {
            return "redirect:/forgot-password";
        }
        return "auth/reset-password";
    }

    @PostMapping("/reset-password")
    public String processResetPassword(@RequestParam(value = "newPassword", required = false) String newPassword,
                                       @RequestParam(value = "confirmPassword", required = false) String confirmPassword,
                                       HttpSession session,
                                       Model model,
                                       RedirectAttributes ra) {
        Boolean verified = (Boolean) session.getAttribute(SESSION_RESET_OTP_VERIFIED);
        String verifiedEmail = (String) session.getAttribute(SESSION_RESET_VERIFIED_EMAIL);
        String sessionEmail = (String) session.getAttribute(SESSION_RESET_EMAIL);

        if (verified == null || !verified || verifiedEmail == null || sessionEmail == null
                || !verifiedEmail.equalsIgnoreCase(sessionEmail)) {
            return "redirect:/forgot-password";
        }

        if (newPassword == null || newPassword.isBlank() || newPassword.length() < 8 || newPassword.length() > 100) {
            model.addAttribute("errorMessage", "Mật khẩu phải có độ dài từ 8 đến 100 ký tự.");
            return "auth/reset-password";
        }

        try {
            passwordResetService.resetPassword(verifiedEmail, newPassword, confirmPassword);
            session.removeAttribute(SESSION_RESET_EMAIL);
            session.removeAttribute(SESSION_RESET_OTP_VERIFIED);
            session.removeAttribute(SESSION_RESET_VERIFIED_EMAIL);
            ra.addFlashAttribute("successMessage", "Đặt lại mật khẩu thành công! Vui lòng đăng nhập.");
            return "redirect:/login";
        } catch (IllegalArgumentException e) {
            model.addAttribute("errorMessage", e.getMessage());
            return "auth/reset-password";
        }
    }

    // ===== ĐỔI MẬT KHẨU (đã đăng nhập) =====

    @GetMapping("/change-password")
    public String showChangePasswordPage(Model model) {
        model.addAttribute("changePasswordRequest", new ChangePasswordRequest());
        return "auth/change-password";
    }

    @PostMapping("/change-password")
    public String processChangePassword(
            @Valid @ModelAttribute("changePasswordRequest") ChangePasswordRequest request,
            BindingResult bindingResult,
            @AuthenticationPrincipal CustomUserDetails currentUser,
            Model model,
            RedirectAttributes ra) {

        if (bindingResult.hasErrors()) return "auth/change-password";

        try {
            profileService.changePassword(currentUser.getUserId(), request);
            ra.addFlashAttribute("successMessage", "Đổi mật khẩu thành công!");
            return "redirect:/profile";
        } catch (IllegalArgumentException e) {
            model.addAttribute("errorMessage", e.getMessage());
            return "auth/change-password";
        }
    }

    // ===== HELPER =====

    private String maskEmail(String email) {
        if (email == null || !email.contains("@")) return email;
        String[] parts = email.split("@");
        int show = Math.min(3, parts[0].length());
        return parts[0].substring(0, show) + "***@" + parts[1];
    }
}
