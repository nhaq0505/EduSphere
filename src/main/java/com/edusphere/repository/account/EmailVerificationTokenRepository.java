package com.edusphere.repository.account;

import com.edusphere.entity.account.EmailVerificationTokens;
import com.edusphere.entity.account.Users;

import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

@Repository
public interface EmailVerificationTokenRepository extends JpaRepository<EmailVerificationTokens, Integer> {

    Optional<EmailVerificationTokens> findByToken(String token);

    @Transactional
    void deleteByUserId(Users user);
}
