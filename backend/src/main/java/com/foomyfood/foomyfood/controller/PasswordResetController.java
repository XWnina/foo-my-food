package com.foomyfood.foomyfood.controller;

import com.foomyfood.foomyfood.service.PasswordResetService;
import com.foomyfood.foomyfood.model.dto.PasswordResetRequest;
import com.foomyfood.foomyfood.model.dto.ResetPasswordRequest;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/password-reset")
public class PasswordResetController {

    @Autowired
    private PasswordResetService passwordResetService;

    @PostMapping("/send-link")
    public ResponseEntity<String> sendResetLink(@RequestBody PasswordResetRequest request) {
        passwordResetService.sendResetLink(request.getEmail());
        return ResponseEntity.ok("Password reset link has been sent to your email.");
    }

    @PostMapping("/reset")
    public ResponseEntity<String> resetPassword(@RequestBody ResetPasswordRequest request) {
        passwordResetService.resetPassword(request.getToken(), request.getNewPassword());
        return ResponseEntity.ok("Password has been successfully reset.");
    }
}
