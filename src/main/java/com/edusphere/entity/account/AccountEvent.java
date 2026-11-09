package com.edusphere.entity.account;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;

import java.time.LocalDateTime;

@Entity
@Table(name = "account_events")
public class AccountEvent {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "event_id")
    private Long eventId;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "user_id")
    private Users user;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "actor_id")
    private Users actor;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "role_id")
    private Roles role;

    @Column(name = "action", nullable = false, length = 30)
    private String action;

    @Column(name = "reason", length = 1000, columnDefinition = "nvarchar(1000)")
    private String reason;

    @Column(name = "created_at", nullable = false)
    private LocalDateTime createdAt;

    protected AccountEvent() {}

    public AccountEvent(Users user, Users actor, Roles role, String action, String reason) {
        this.user = user;
        this.actor = actor;
        this.role = role;
        this.action = action;
        this.reason = reason;
        this.createdAt = LocalDateTime.now();
    }
}
