package com.edusphere.config;

import com.edusphere.entity.account.Roles;
import com.edusphere.entity.account.UserRoles;
import com.edusphere.entity.account.UserRolesPK;
import com.edusphere.entity.account.Users;
import com.edusphere.repository.account.RoleRepository;
import com.edusphere.repository.account.UserRepository;
import com.edusphere.repository.account.UserRoleRepository;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.util.Date;

/**
 * Tự động tạo tài khoản admin mặc định khi app khởi động lần đầu.
 * Chỉ tạo nếu email chưa tồn tại trong database.
 *
 * Tài khoản: admin@edusphere.vn / Admin@123456
 */
@Component
public class AdminDataInitializer implements ApplicationRunner {

    private static final Logger log = LoggerFactory.getLogger(AdminDataInitializer.class);

    private static final String ADMIN_EMAIL    = "admin@edusphere.vn";
    private static final String ADMIN_PASSWORD = "Admin@123456";
    private static final String ADMIN_NAME     = "Quản trị viên";

    private final UserRepository     userRepository;
    private final RoleRepository     roleRepository;
    private final UserRoleRepository userRoleRepository;
    private final PasswordEncoder    passwordEncoder;

    public AdminDataInitializer(UserRepository userRepository,
                                RoleRepository roleRepository,
                                UserRoleRepository userRoleRepository,
                                PasswordEncoder passwordEncoder) {
        this.userRepository     = userRepository;
        this.roleRepository     = roleRepository;
        this.userRoleRepository = userRoleRepository;
        this.passwordEncoder    = passwordEncoder;
    }

    @Override
    @Transactional
    public void run(ApplicationArguments args) {
        // Bỏ qua nếu email đã tồn tại
        if (userRepository.existsByEmail(ADMIN_EMAIL)) {
            log.info("[AdminInit] Tài khoản {} đã tồn tại, bỏ qua.", ADMIN_EMAIL);
            return;
        }

        // Tạo user
        Users admin = new Users();
        admin.setFullName(ADMIN_NAME);
        admin.setEmail(ADMIN_EMAIL);
        admin.setPasswordHash(passwordEncoder.encode(ADMIN_PASSWORD));
        admin.setStatus("ACTIVE");
        admin.setCreatedAt(new Date());
        admin = userRepository.save(admin);

        // Tìm role ADMINISTRATOR
        Roles adminRole = roleRepository.findByRoleName("ADMINISTRATOR")
                .orElseThrow(() -> new IllegalStateException(
                        "[AdminInit] Role 'ADMINISTRATOR' không tồn tại trong bảng roles! " +
                        "Hãy chạy SQLQuery1.sql trước để seed roles."));

        // Gán role
        UserRolesPK pk = new UserRolesPK(admin.getUserId(), adminRole.getRoleId());
        UserRoles userRole = new UserRoles(pk, new Date());
        userRoleRepository.save(userRole);

        log.info("╔══════════════════════════════════════════════╗");
        log.info("║  [AdminInit] Đã tạo tài khoản admin          ║");
        log.info("║  Email   : {}              ║", ADMIN_EMAIL);
        log.info("║  Password: {}                  ║", ADMIN_PASSWORD);
        log.info("╚══════════════════════════════════════════════╝");
    }
}
