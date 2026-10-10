package com.edusphere.repository.account;

import com.edusphere.entity.account.PasswordResetTokens;
import com.edusphere.entity.account.Users;

import java.util.Date;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

@Repository
public interface PasswordResetTokenRepository extends JpaRepository<PasswordResetTokens, Integer> {

    Optional<PasswordResetTokens> findByToken(String token);

    @Transactional
    void deleteByUserId(Users user);

    /** Tìm OTP còn hiệu lực (chưa dùng, chưa hết hạn) của user */
    @Query("SELECT p FROM PasswordResetTokens p WHERE p.userId = :user AND p.usedAt IS NULL AND p.expiresAt > :now")
    Optional<PasswordResetTokens> findLatestValidByUserId(@Param("user") Users user,
                                                           @Param("now") Date now);

    default Optional<PasswordResetTokens> findLatestValidByUserId(Users user) {
        return findLatestValidByUserId(user, new Date());
    }
}
