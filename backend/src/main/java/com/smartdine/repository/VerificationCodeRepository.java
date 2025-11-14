package com.smartdine.repository;

import java.time.LocalDateTime;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;

import com.smartdine.models.VerificationCode;

public interface VerificationCodeRepository extends JpaRepository<VerificationCode, Long> {

    Optional<VerificationCode> findByEmailAndCode(String email, String code);

    boolean existsByEmailAndCodeAndExpiresAtAfter(String email, String code, LocalDateTime now);

    void deleteByEmail(String email);
}
