package com.edusphere.dto;

import java.util.Set;
import lombok.Getter;

@Getter
public class AdminUserView {
    private final Integer userId;
    private final String fullName;
    private final String email;
    private final String status;
    private final Set<String> roles;
    private final boolean student;
    private final boolean instructor;
    private final boolean administrator;
    private final boolean self;

    public AdminUserView(Integer userId, String fullName, String email, String status,
                         Set<String> roles, boolean self) {
        this.userId = userId;
        this.fullName = fullName;
        this.email = email;
        this.status = status;
        this.roles = roles;
        this.student = roles.contains("STUDENT");
        this.instructor = roles.contains("INSTRUCTOR");
        this.administrator = roles.contains("ADMINISTRATOR");
        this.self = self;
    }
}
