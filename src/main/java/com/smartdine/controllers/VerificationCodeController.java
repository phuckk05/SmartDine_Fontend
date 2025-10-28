package com.smartdine.controllers;

import java.time.LocalDateTime;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.fasterxml.jackson.annotation.JsonFormat;
import com.smartdine.models.VerificationCode;
import com.smartdine.services.VerificationCodeService;

@RestController
@RequestMapping("/api/verification-codes")
public class VerificationCodeController {

    @Autowired
    private VerificationCodeService verificationCodeService;

    @PostMapping
    public ResponseEntity<?> createCode(@RequestBody CreateVerificationCodeRequest request) {
        try {
            if (request.email == null || request.code == null || request.expiresAt == null) {
                return ResponseEntity.badRequest().body("email, code và expiresAt là bắt buộc");
            }
            VerificationCode verificationCode = verificationCodeService.saveCode(request.email, request.code,
                    request.expiresAt);
            return ResponseEntity.ok(verificationCode);
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.internalServerError().body("Lỗi: " + e.getMessage());
        }
    }

    @PostMapping("/verify")
    public ResponseEntity<?> verifyCode(@RequestBody VerifyCodeRequest request) {
        if (request.email == null || request.code == null) {
            return ResponseEntity.badRequest().body("email và code là bắt buộc");
        }
        boolean isValid = verificationCodeService.verifyCode(request.email, request.code);
        if (isValid) {
            return ResponseEntity.ok().body("Code hợp lệ");
        }
        return ResponseEntity.badRequest().body("Code không hợp lệ hoặc đã hết hạn");
    }

    static class CreateVerificationCodeRequest {
        public String email;
        public String code;
        public LocalDateTime expiresAt;
    }

    static class VerifyCodeRequest {
        public String email;
        public String code;
    }
}
