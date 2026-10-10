package com.edusphere.security;

import org.springframework.security.core.Authentication;

public final class RoleLandingPage {

    private RoleLandingPage() {
    }

    public static String forUser(Authentication authentication) {
        if (authentication != null) {
            if (hasRole(authentication, "ROLE_ADMINISTRATOR")) {
                return "/admin/courses/review";
            }
            if (hasRole(authentication, "ROLE_INSTRUCTOR")) {
                return "/instructor/courses";
            }
            if (hasRole(authentication, "ROLE_STUDENT")) {
                return "/courses";
            }
        }
        return "/courses";
    }

    private static boolean hasRole(Authentication authentication, String role) {
        return authentication.getAuthorities().stream()
                .anyMatch(authority -> role.equals(authority.getAuthority()));
    }
}
