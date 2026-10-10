package com.edusphere.security;

import com.edusphere.repository.account.UserRepository;
import com.edusphere.repository.account.UserRoleRepository;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.Set;
import java.util.stream.Collectors;

import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

@Component
public class AccountStateFilter extends OncePerRequestFilter {
    private final UserRepository users;
    private final UserRoleRepository userRoles;

    public AccountStateFilter(UserRepository users, UserRoleRepository userRoles) {
        this.users = users;
        this.userRoles = userRoles;
    }

    @Override
    protected boolean shouldNotFilter(HttpServletRequest request) {
        String path = request.getRequestURI().substring(request.getContextPath().length());
        return path.startsWith("/assets/") || path.equals("/favicon.ico");
    }

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response,
                                    FilterChain chain) throws ServletException, IOException {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth != null && auth.getPrincipal() instanceof CustomUserDetails principal) {
            String status = users.findById(principal.getUserId()).map(u -> u.getStatus()).orElse("LOCKED");
            Set<String> actualRoles = userRoles.findByUserRolesPK_UserId(principal.getUserId()).stream()
                    .map(role -> "ROLE_" + role.getRoles().getRoleName()).collect(Collectors.toSet());
            Set<String> sessionRoles = principal.getAuthorities().stream()
                    .map(a -> a.getAuthority()).collect(Collectors.toSet());
            if (!"ACTIVE".equals(status) || !actualRoles.equals(sessionRoles)) {
                SecurityContextHolder.clearContext();
                if (request.getSession(false) != null) request.getSession(false).invalidate();
                response.sendRedirect(request.getContextPath() + "/login?error="
                        + ("LOCKED".equals(status) ? "locked" : "permissionsChanged"));
                return;
            }
        }
        chain.doFilter(request, response);
    }
}
