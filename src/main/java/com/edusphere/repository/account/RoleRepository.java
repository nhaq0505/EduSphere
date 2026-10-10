package com.edusphere.repository.account;

import com.edusphere.entity.account.Roles;

import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

/**
 * Repository cho bảng roles.
 */
@Repository
public interface RoleRepository extends JpaRepository<Roles, Integer> {

    /** Tìm role theo tên (ví dụ: "STUDENT", "INSTRUCTOR", "ADMINISTRATOR") */
    Optional<Roles> findByRoleName(String roleName);
}
