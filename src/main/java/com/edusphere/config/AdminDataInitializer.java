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
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.core.annotation.Order;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.util.Date;

/**
 * Tự động tạo tài khoản admin mặc định khi app khởi động lần đầu.
 * Chỉ tạo nếu email chưa tồn tại trong database.
 */
@Component
@Order(2)
public class AdminDataInitializer implements ApplicationRunner {

    private static final Logger log = LoggerFactory.getLogger(AdminDataInitializer.class);

    private static final String ADMIN_EMAIL    = "admin@edusphere.vn";
    private static final String ADMIN_NAME     = "Quản trị viên";

    @Value("${app.bootstrap.admin-password:Admin@123456}")
    private String adminPassword;

    @Value("${app.bootstrap.demo-accounts:true}")
    private boolean demoAccounts;

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
        if (!adminPassword.isBlank()) {
            initDefaultAdmin();
        }
        if (demoAccounts) {
            initDemoAccounts();
        }
    }

    private void initDefaultAdmin() {
        Roles adminRole = roleRepository.findByRoleName("ADMINISTRATOR")
                .orElse(null);
        if (adminRole == null) {
            log.warn("[AdminInit] Role 'ADMINISTRATOR' không tồn tại trong bảng roles! Hãy chạy SQLQuery1.sql trước để seed roles.");
            return;
        }

        Users admin = userRepository.findByEmail(ADMIN_EMAIL).orElse(null);
        if (admin == null) {
            admin = new Users();
            admin.setFullName(ADMIN_NAME);
            admin.setEmail(ADMIN_EMAIL);
            admin.setPasswordHash(passwordEncoder.encode(adminPassword));
            admin.setStatus("ACTIVE");
            admin.setCreatedAt(new Date());
            admin = userRepository.save(admin);

            UserRolesPK pk = new UserRolesPK(admin.getUserId(), adminRole.getRoleId());
            UserRoles userRole = new UserRoles(pk, new Date());
            userRoleRepository.save(userRole);

            log.info("[AdminInit] Đã tạo tài khoản admin {}", ADMIN_EMAIL);
        } else {
            UserRolesPK pk = new UserRolesPK(admin.getUserId(), adminRole.getRoleId());
            if (!userRoleRepository.existsById(pk)) {
                userRoleRepository.save(new UserRoles(pk, new Date()));
            }
            log.info("[AdminInit] Tài khoản {} đã tồn tại, giữ nguyên mật khẩu và trạng thái.", ADMIN_EMAIL);
        }
    }

    private void initDemoAccounts() {
        createOrUpdateDemoAccount("admin@admin.com", "123", "Demo Administrator", "ADMINISTRATOR");
        createOrUpdateDemoAccount("instructor@instructor.com", "123", "Demo Instructor", "INSTRUCTOR");
        createOrUpdateDemoAccount("student@student.com", "123", "Demo Student", "STUDENT");
    }

    private void createOrUpdateDemoAccount(String email, String password, String name, String roleName) {
        Roles role = roleRepository.findByRoleName(roleName).orElse(null);
        if (role == null) {
            log.warn("[DemoInit] Role '{}' không tồn tại, bỏ qua {}", roleName, email);
            return;
        }

        Users user = userRepository.findByEmail(email).orElse(null);
        if (user == null) {
            user = new Users();
            user.setFullName(name);
            user.setEmail(email);
            user.setPasswordHash(passwordEncoder.encode(password));
            user.setStatus("ACTIVE");
            user.setCreatedAt(new Date());
            user = userRepository.save(user);

            UserRolesPK pk = new UserRolesPK(user.getUserId(), role.getRoleId());
            userRoleRepository.save(new UserRoles(pk, new Date()));
            log.info("[DemoInit] Đã tạo tài khoản demo: {} ({})", email, roleName);
        } else {
            // Bảo toàn mật khẩu và trạng thái tài khoản nếu đã tồn tại trong DB (không ghi đè)
            UserRolesPK pk = new UserRolesPK(user.getUserId(), role.getRoleId());
            if (!userRoleRepository.existsById(pk)) {
                userRoleRepository.save(new UserRoles(pk, new Date()));
                log.info("[DemoInit] Đã gán bổ sung role {} cho tài khoản {}", roleName, email);
            }
        }
    }
}
