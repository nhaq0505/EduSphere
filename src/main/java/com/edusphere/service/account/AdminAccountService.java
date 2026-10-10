package com.edusphere.service.account;

import com.edusphere.dto.account.AdminUserView;
import com.edusphere.entity.account.AccountEvent;
import com.edusphere.entity.account.Roles;
import com.edusphere.entity.account.UserRoles;
import com.edusphere.entity.account.UserRolesPK;
import com.edusphere.entity.account.Users;
import com.edusphere.repository.account.AccountEventRepository;
import com.edusphere.repository.account.RoleRepository;
import com.edusphere.repository.account.UserRepository;
import com.edusphere.repository.account.UserRoleRepository;

import java.util.Date;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class AdminAccountService {
    private static final Set<String> ALLOWED_ROLES = Set.of("STUDENT", "INSTRUCTOR", "ADMINISTRATOR");
    private final UserRepository users;
    private final UserRoleRepository userRoles;
    private final RoleRepository roles;
    private final AccountEventRepository events;

    public AdminAccountService(UserRepository users, UserRoleRepository userRoles,
                               RoleRepository roles, AccountEventRepository events) {
        this.users = users;
        this.userRoles = userRoles;
        this.roles = roles;
        this.events = events;
    }

    @Transactional(readOnly = true)
    public Page<AdminUserView> search(String query, int page, Integer actorId) {
        String q = query == null ? "" : query.trim();
        return users.searchForAdministration(q, PageRequest.of(Math.max(0, page), 20,
                        Sort.by(Sort.Direction.DESC, "createdAt")))
                .map(user -> new AdminUserView(user.getUserId(), user.getFullName(),
                        user.getEmail(), user.getStatus(), roleNames(user.getUserId()),
                        user.getUserId().equals(actorId)));
    }

    @Transactional
    public void changeRoles(Integer actorId, Integer targetId, List<String> requestedRoles) {
        Users target = target(actorId, targetId);
        if (requestedRoles == null || requestedRoles.isEmpty()) {
            throw new IllegalArgumentException("Tài khoản cần ít nhất một vai trò.");
        }
        Set<String> wanted = new HashSet<>(requestedRoles);
        if (!ALLOWED_ROLES.containsAll(wanted)) {
            throw new IllegalArgumentException("Vai trò không hợp lệ.");
        }
        Map<String, Roles> available = new HashMap<>();
        roles.findAll().forEach(role -> available.put(role.getRoleName(), role));
        if (!available.keySet().containsAll(wanted)) {
            throw new IllegalStateException("Thiếu vai trò trong cơ sở dữ liệu.");
        }
        List<UserRoles> current = userRoles.findByUserRolesPK_UserId(targetId);
        Set<String> existing = new HashSet<>();
        Users actor = users.getReferenceById(actorId);
        for (UserRoles membership : current) {
            String name = membership.getRoles().getRoleName();
            existing.add(name);
            if (!wanted.contains(name)) {
                userRoles.delete(membership);
                events.save(new AccountEvent(target, actor, membership.getRoles(), "ROLE_REVOKED", null));
            }
        }
        for (String name : wanted) {
            if (!existing.contains(name)) {
                Roles role = available.get(name);
                userRoles.save(new UserRoles(new UserRolesPK(targetId, role.getRoleId()), new Date()));
                events.save(new AccountEvent(target, actor, role, "ROLE_GRANTED", null));
            }
        }
        target.setUpdatedAt(new Date());
    }

    @Transactional
    public void changeStatus(Integer actorId, Integer targetId, String action, String reason) {
        Users target = target(actorId, targetId);
        String normalized = reason == null ? "" : reason.trim();
        if (normalized.length() > 1000) throw new IllegalArgumentException("Lý do tối đa 1000 ký tự.");
        String eventAction;
        if ("LOCK".equals(action) && "ACTIVE".equals(target.getStatus())) {
            if (normalized.isEmpty()) throw new IllegalArgumentException("Cần nhập lý do khóa tài khoản.");
            eventAction = "LOCKED";
            target.setStatus("LOCKED");
        } else if ("RESTORE".equals(action) && "LOCKED".equals(target.getStatus())) {
            eventAction = "RESTORED";
            target.setStatus("ACTIVE");
        } else {
            throw new IllegalArgumentException("Không thể đổi trạng thái tài khoản này.");
        }
        target.setUpdatedAt(new Date());
        events.save(new AccountEvent(target, users.getReferenceById(actorId), null,
                eventAction, normalized.isEmpty() ? null : normalized));
    }

    private Users target(Integer actorId, Integer targetId) {
        if (actorId.equals(targetId)) throw new IllegalArgumentException("Không thể sửa vai trò hoặc khóa tài khoản của chính mình.");
        return users.findLockedById(targetId)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy tài khoản."));
    }

    private Set<String> roleNames(Integer userId) {
        Set<String> names = new HashSet<>();
        userRoles.findByUserRolesPK_UserId(userId).forEach(role -> names.add(role.getRoles().getRoleName()));
        return names;
    }
}
