package com.edusphere.repository;

import com.edusphere.entity.Users;
import jakarta.persistence.LockModeType;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.Optional;

/**
 * Repository cho bảng users.
 */
@Repository
public interface UserRepository extends JpaRepository<Users, Integer> {

    /** Tìm user theo email (dùng cho login, check duplicate) */
    Optional<Users> findByEmail(String email);

    /** Kiểm tra email đã tồn tại chưa (dùng khi đăng ký) */
    boolean existsByEmail(String email);

    @Query("select u from Users u where :q = '' or lower(u.email) like lower(concat('%', :q, '%')) or lower(u.fullName) like lower(concat('%', :q, '%'))")
    Page<Users> searchForAdministration(@Param("q") String q, Pageable pageable);

    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query("select u from Users u where u.userId = :id")
    Optional<Users> findLockedById(@Param("id") Integer id);
}
