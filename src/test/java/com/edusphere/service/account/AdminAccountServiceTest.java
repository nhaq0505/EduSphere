package com.edusphere.service.account;

import com.edusphere.entity.account.AccountEvent;
import com.edusphere.entity.account.Roles;
import com.edusphere.entity.account.UserRoles;
import com.edusphere.entity.account.UserRolesPK;
import com.edusphere.entity.account.Users;
import com.edusphere.repository.account.AccountEventRepository;
import com.edusphere.repository.account.RoleRepository;
import com.edusphere.repository.account.UserRepository;
import com.edusphere.repository.account.UserRoleRepository;

import java.util.List;
import java.util.Optional;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

class AdminAccountServiceTest {
    private UserRepository users;
    private UserRoleRepository userRoles;
    private RoleRepository roles;
    private AccountEventRepository events;
    private AdminAccountService service;

    @BeforeEach
    void setUp() {
        users = mock(UserRepository.class);
        userRoles = mock(UserRoleRepository.class);
        roles = mock(RoleRepository.class);
        events = mock(AccountEventRepository.class);
        service = new AdminAccountService(users, userRoles, roles, events);
    }

    @Test
    void administratorCannotChangeOwnRolesOrStatus() {
        assertThrows(IllegalArgumentException.class, () -> service.changeRoles(1, 1, java.util.List.of("STUDENT")));
        assertThrows(IllegalArgumentException.class, () -> service.changeStatus(1, 1, "LOCK", "test"));
        verifyNoInteractions(users, userRoles, events);
    }

    @Test
    void lockRequiresReasonAndWritesAuditEvent() {
        Users target = new Users();
        target.setUserId(2);
        target.setStatus("ACTIVE");
        when(users.findLockedById(2)).thenReturn(Optional.of(target));

        assertThrows(IllegalArgumentException.class, () -> service.changeStatus(1, 2, "LOCK", "  "));
        assertEquals("ACTIVE", target.getStatus());
        verifyNoInteractions(events);

        service.changeStatus(1, 2, "LOCK", "Vi phạm nội quy");
        assertEquals("LOCKED", target.getStatus());
        verify(events).save(any(AccountEvent.class));
    }

    @Test
    void restoreOnlyAcceptsLockedAccount() {
        Users target = new Users();
        target.setUserId(2);
        target.setStatus("PENDING");
        when(users.findLockedById(2)).thenReturn(Optional.of(target));
        assertThrows(IllegalArgumentException.class, () -> service.changeStatus(1, 2, "RESTORE", null));
        target.setStatus("LOCKED");
        service.changeStatus(1, 2, "RESTORE", null);
        assertEquals("ACTIVE", target.getStatus());
        verify(events).save(any(AccountEvent.class));
    }

    @Test
    void addingRoleKeepsExistingRoleAndRecordsChange() {
        Users target = new Users();
        target.setUserId(2);
        when(users.findLockedById(2)).thenReturn(Optional.of(target));
        Roles student = new Roles(1, "STUDENT");
        Roles instructor = new Roles(2, "INSTRUCTOR");
        when(roles.findAll()).thenReturn(List.of(student, instructor));
        UserRoles membership = new UserRoles(new UserRolesPK(2, 1), new java.util.Date());
        membership.setRoles(student);
        when(userRoles.findByUserRolesPK_UserId(2)).thenReturn(List.of(membership));

        service.changeRoles(1, 2, List.of("STUDENT", "INSTRUCTOR"));

        verify(userRoles).save(any(UserRoles.class));
        verify(userRoles, never()).delete(any());
        verify(events).save(any(AccountEvent.class));
    }
}
