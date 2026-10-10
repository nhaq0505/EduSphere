package com.edusphere.security;

import com.edusphere.entity.Users;
import com.edusphere.entity.Roles;
import com.edusphere.entity.UserRoles;
import com.edusphere.entity.UserRolesPK;
import com.edusphere.repository.UserRepository;
import com.edusphere.repository.UserRoleRepository;
import java.util.Date;
import java.util.List;
import java.util.Optional;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.Test;
import org.springframework.mock.web.MockHttpServletRequest;
import org.springframework.mock.web.MockHttpServletResponse;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

class AccountStateFilterTest {
    @AfterEach
    void clear() { SecurityContextHolder.clearContext(); }

    @Test
    void lockedSessionIsInvalidatedBeforeControllerRuns() throws Exception {
        UserRepository users = mock(UserRepository.class);
        UserRoleRepository userRoles = mock(UserRoleRepository.class);
        Users principalUser = new Users(7, "Học viên", "student@example.com", "ACTIVE", new Date());
        var principal = new CustomUserDetails(principalUser);
        SecurityContextHolder.getContext().setAuthentication(
                new UsernamePasswordAuthenticationToken(principal, null, List.of()));
        Users locked = new Users(7, "Học viên", "student@example.com", "LOCKED", new Date());
        when(users.findById(7)).thenReturn(Optional.of(locked));
        when(userRoles.findByUserRolesPK_UserId(7)).thenReturn(List.of());
        MockHttpServletRequest request = new MockHttpServletRequest("GET", "/EduSphere/my-courses");
        request.setContextPath("/EduSphere");
        request.getSession();
        MockHttpServletResponse response = new MockHttpServletResponse();
        var chain = mock(jakarta.servlet.FilterChain.class);

        new AccountStateFilter(users, userRoles).doFilter(request, response, chain);

        assertEquals("/EduSphere/login?error=locked", response.getRedirectedUrl());
        assertNull(request.getSession(false));
        verifyNoInteractions(chain);
    }

    @Test
    void changedRolesRequireFreshLogin() throws Exception {
        UserRepository users = mock(UserRepository.class);
        UserRoleRepository userRoles = mock(UserRoleRepository.class);
        Users active = new Users(8, "Giảng viên", "teacher@example.com", "ACTIVE", new Date());
        var principal = new CustomUserDetails(active);
        SecurityContextHolder.getContext().setAuthentication(
                new UsernamePasswordAuthenticationToken(principal, null, List.of()));
        when(users.findById(8)).thenReturn(Optional.of(active));
        UserRoles assigned = new UserRoles(new UserRolesPK(8, 2), new Date());
        assigned.setRoles(new Roles(2, "INSTRUCTOR"));
        when(userRoles.findByUserRolesPK_UserId(8)).thenReturn(List.of(assigned));
        MockHttpServletRequest request = new MockHttpServletRequest("GET", "/EduSphere/instructor/courses");
        request.setContextPath("/EduSphere");
        MockHttpServletResponse response = new MockHttpServletResponse();
        var chain = mock(jakarta.servlet.FilterChain.class);

        new AccountStateFilter(users, userRoles).doFilter(request, response, chain);

        assertEquals("/EduSphere/login?error=permissionsChanged", response.getRedirectedUrl());
        verifyNoInteractions(chain);
    }
}
