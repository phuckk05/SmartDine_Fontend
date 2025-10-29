package com.smartdine.repository;

import java.time.LocalDateTime;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;

import com.smartdine.models.VerificationCode;

public interface VerificationCodeRepository extends JpaRepository<VerificationCode, Long> {

    Optional<VerificationCode> findByEmailAndCode(String email, String code);

    boolean existsByEmailAndCodeAndExpiresAtAfter(String email, String code, LocalDateTime now);

    @Modifying
    void deleteByEmail(String email);
}
