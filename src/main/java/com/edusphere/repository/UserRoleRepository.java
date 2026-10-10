package com.edusphere.repository;

import com.edusphere.entity.UserRoles;
import com.edusphere.entity.UserRolesPK;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import org.springframework.data.jpa.repository.EntityGraph;

/**
 * Repository cho bảng user_roles.
 */
@Repository
public interface UserRoleRepository extends JpaRepository<UserRoles, UserRolesPK> {

    /** Lấy tất cả role của một user */
    @EntityGraph(attributePaths = "roles")
    List<UserRoles> findByUserRolesPK_UserId(int userId);
}
