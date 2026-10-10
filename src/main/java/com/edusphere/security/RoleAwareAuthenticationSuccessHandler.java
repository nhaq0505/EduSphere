package com.edusphere.security;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.springframework.security.core.Authentication;
import org.springframework.security.web.authentication.SavedRequestAwareAuthenticationSuccessHandler;
import org.springframework.stereotype.Component;

import java.io.IOException;

@Component
public class RoleAwareAuthenticationSuccessHandler extends SavedRequestAwareAuthenticationSuccessHandler {

    @Override
    public void onAuthenticationSuccess(HttpServletRequest request, HttpServletResponse response,
                                        Authentication authentication) throws IOException, ServletException {
        try {
            super.onAuthenticationSuccess(request, response, authentication);
        } finally {
            HttpSession session = request.getSession(false);
            if (session != null) {
                session.removeAttribute("postLoginCourseId");
            }
        }
    }

    @Override
    protected String determineTargetUrl(HttpServletRequest request, HttpServletResponse response,
                                        Authentication authentication) {
        HttpSession session = request.getSession(false);
        if (session != null && session.getAttribute("postLoginCourseId") instanceof Integer courseId
                && courseId > 0) {
            return "/courses/" + courseId;
        }
        return RoleLandingPage.forUser(authentication);
    }
}
