package com.polysneaker.polysneaker.repository;

import com.polysneaker.polysneaker.entity.Account;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface AccountRepository extends JpaRepository<Account, Integer> {

    Optional<Account> findByUsername(String username);

    Optional<Account> findFirstByRole(String role);

    boolean existsByUsername(String username);

    boolean existsByEmail(String email);
}