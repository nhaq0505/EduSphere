package com.edusphere.repository;

import com.edusphere.entity.AccountEvent;
import org.springframework.data.jpa.repository.JpaRepository;

public interface AccountEventRepository extends JpaRepository<AccountEvent, Long> {
}
