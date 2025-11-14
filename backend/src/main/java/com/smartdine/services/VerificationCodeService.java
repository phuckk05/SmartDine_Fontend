package com.smartdine.services;

import java.time.LocalDateTime;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.smartdine.models.VerificationCode;
import com.smartdine.repository.VerificationCodeRepository;

@Service
public class VerificationCodeService {

    @Autowired
    private VerificationCodeRepository verificationCodeRepository;

    public VerificationCode saveCode(String email, String code, LocalDateTime expiresAt) {
        verificationCodeRepository.deleteByEmail(email);
        VerificationCode verificationCode = new VerificationCode(email, code, expiresAt);
        verificationCode.setCreatedAt(LocalDateTime.now());
        return verificationCodeRepository.save(verificationCode);
    }

    public boolean verifyCode(String email, String code) {
        LocalDateTime now = LocalDateTime.now();
        Optional<VerificationCode> stored = verificationCodeRepository.findByEmailAndCode(email, code);
        if (stored.isPresent() && !stored.get().getExpiresAt().isBefore(now)) {
            verificationCodeRepository.delete(stored.get());
            return true;
        }
        return false;
    }

    public boolean existsValidCode(String email, String code) {
        return verificationCodeRepository.existsByEmailAndCodeAndExpiresAtAfter(email, code, LocalDateTime.now());
    }
}
