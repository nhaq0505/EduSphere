package com.edusphere.repository.account;

import com.edusphere.entity.account.UserRoles;
import com.edusphere.entity.account.UserRolesPK;

import java.util.List;

import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

/**
 * Repository cho bảng user_roles.
 */
@Repository
public interface UserRoleRepository extends JpaRepository<UserRoles, UserRolesPK> {

    /** Lấy tất cả role của một user */
    @EntityGraph(attributePaths = "roles")
    List<UserRoles> findByUserRolesPK_UserId(int userId);
}
