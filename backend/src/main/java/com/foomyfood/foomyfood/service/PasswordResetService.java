package com.foomyfood.foomyfood.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class PasswordResetService {

    @Autowired
    private EmailService emailService;

    @Autowired
    private TokenService tokenService;

    public void sendResetLink(String email) {
        String token = tokenService.generateToken(email);
        String resetLink = "https://your-frontend-app.com/set_password?token=" + token;
        emailService.sendEmail(email, "Password Reset Request",
                "Click the following link to reset your password: " + resetLink);
    }

    public void resetPassword(String token, String newPassword) {
        String email = tokenService.validateToken(token);
        // 在这里更新密码
    }
}
