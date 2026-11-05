package com.edusphere.service.account;

import com.edusphere.entity.account.PasswordResetTokens;
import com.edusphere.entity.account.Users;
import com.edusphere.repository.account.PasswordResetTokenRepository;
import com.edusphere.repository.account.UserRepository;

import java.security.SecureRandom;
import java.util.Date;
import java.util.Optional;

import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * Flow quên mật khẩu bằng OTP:
 * 1. User nhập email → gửi OTP 6 số về mail
 * 2. User nhập OTP → xác thực → được phép đặt mật khẩu mới
 * 3. User nhập mật khẩu mới → lưu DB, đánh dấu token đã dùng
 */
@Service
public class PasswordResetService {

    private final UserRepository userRepository;
    private final PasswordResetTokenRepository passwordResetTokenRepository;
    private final PasswordEncoder passwordEncoder;
    private final EmailService emailService;

    private static final SecureRandom SECURE_RANDOM = new SecureRandom();
    // OTP hết hạn sau 10 phút
    private static final long OTP_EXPIRY_MS = 10L * 60 * 1000;

    public PasswordResetService(UserRepository userRepository,
                                PasswordResetTokenRepository passwordResetTokenRepository,
                                PasswordEncoder passwordEncoder,
                                EmailService emailService) {
        this.userRepository = userRepository;
        this.passwordResetTokenRepository = passwordResetTokenRepository;
        this.passwordEncoder = passwordEncoder;
        this.emailService = emailService;
    }

    /**
     * BƯỚC 1 — Nhận email, tạo OTP, gửi mail.
     * Luôn trả về thành công dù email có tồn tại hay không (bảo mật).
     */
    @Transactional
    public void processForgotPassword(String email) {
        Optional<Users> userOpt = userRepository.findByEmail(email.toLowerCase().trim());
        if (userOpt.isEmpty()) return; // Không tiết lộ email có tồn tại không

        Users user = userOpt.get();
        if (!"ACTIVE".equals(user.getStatus())) return;

        // Xóa OTP cũ nếu có
        passwordResetTokenRepository.deleteByUserId(user);

        // Tạo OTP 6 số ngẫu nhiên duy nhất (tránh va chạm ràng buộc UNIQUE(token))
        String otp = generateUniqueOtp();
        Date expiresAt = new Date(System.currentTimeMillis() + OTP_EXPIRY_MS);

        PasswordResetTokens token = new PasswordResetTokens(otp, expiresAt, user);
        passwordResetTokenRepository.save(token);

        // Gửi OTP qua email (async)
        emailService.sendPasswordResetOtpEmail(user.getEmail(), user.getFullName(), otp);
    }

    /**
     * BƯỚC 2 — Xác thực OTP.
     * Trả về email của user nếu OTP đúng (để dùng ở bước 3).
     *
     * @throws IllegalArgumentException nếu OTP sai/hết hạn/đã dùng
     */
    @Transactional
    public String verifyResetOtp(String email, String otp) {
        Users user = userRepository.findByEmail(email.toLowerCase().trim())
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy tài khoản."));
        if (!"ACTIVE".equals(user.getStatus())) {
            throw new IllegalArgumentException("Tài khoản không thể đặt lại mật khẩu.");
        }

        PasswordResetTokens token = passwordResetTokenRepository
                .findByToken(otp.trim())
                .orElseThrow(() -> new IllegalArgumentException("Mã OTP không đúng."));

        // Kiểm tra OTP thuộc đúng user này
        if (!token.getUserId().getUserId().equals(user.getUserId())) {
            throw new IllegalArgumentException("Mã OTP không hợp lệ.");
        }

        if (token.getUsedAt() != null) {
            throw new IllegalArgumentException("Mã OTP này đã được sử dụng.");
        }

        if (token.getExpiresAt().before(new Date())) {
            throw new IllegalArgumentException("Mã OTP đã hết hạn. Vui lòng yêu cầu mã mới.");
        }

        // Đánh dấu OTP đã xác thực (nhưng chưa dùng xong — chờ bước đặt mật khẩu)
        // Lưu verified time tạm bằng cách để nguyên, controller sẽ dùng session

        return user.getEmail();
    }

    /**
     * BƯỚC 3 — Đặt mật khẩu mới sau khi OTP đã xác thực.
     *
     * @throws IllegalArgumentException nếu password không hợp lệ hoặc không khớp
     */
    @Transactional
    public void resetPassword(String email, String newPassword, String confirmPassword) {
        if (newPassword == null || newPassword.isBlank() || newPassword.length() < 8 || newPassword.length() > 100) {
            throw new IllegalArgumentException("Mật khẩu phải có độ dài từ 8 đến 100 ký tự.");
        }

        if (!newPassword.equals(confirmPassword)) {
            throw new IllegalArgumentException("Mật khẩu xác nhận không khớp.");
        }

        Users user = userRepository.findByEmail(email.toLowerCase().trim())
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy tài khoản."));
        if (!"ACTIVE".equals(user.getStatus())) {
            throw new IllegalArgumentException("Tài khoản không thể đặt lại mật khẩu.");
        }

        // Tìm OTP token còn hiệu lực (chưa dùng)
        PasswordResetTokens token = passwordResetTokenRepository
                .findLatestValidByUserId(user)
                .orElseThrow(() -> new IllegalArgumentException("Phiên đặt lại mật khẩu đã hết hạn."));

        // Cập nhật mật khẩu
        user.setPasswordHash(passwordEncoder.encode(newPassword));
        user.setUpdatedAt(new Date());
        userRepository.save(user);

        // Đánh dấu token đã dùng
        token.setUsedAt(new Date());
        passwordResetTokenRepository.save(token);
    }

    /**
     * Gửi lại OTP mới.
     */
    @Transactional
    public void resendResetOtp(String email) {
        processForgotPassword(email);
    }

    /**
     * Sinh mã OTP 6 số duy nhất không trùng lặp với các token đang có trong database.
     */
    private String generateUniqueOtp() {
        String otp;
        int attempts = 0;
        do {
            otp = String.valueOf(100000 + SECURE_RANDOM.nextInt(900000));
            attempts++;
            if (attempts > 50) {
                throw new IllegalStateException("Không thể tạo mã OTP duy nhất, vui lòng thử lại sau.");
            }
        } while (passwordResetTokenRepository.findByToken(otp).isPresent());
        return otp;
    }
}
