package com.edusphere.repository.account;

import com.edusphere.entity.account.AccountEvent;

import org.springframework.data.jpa.repository.JpaRepository;

public interface AccountEventRepository extends JpaRepository<AccountEvent, Long> {
}
