package com.foomyfood.foomyfood.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class
PasswordResetService {

    @Autowired
    private EmailService emailService;  // 使用 EmailService 发送邮件

    // 发送重置链接到指定的邮箱
    public void sendResetLink(String email, String resetLink) {
        String subject = "Password Reset Request";
        String text = "Please click the following link to reset your password: " + resetLink;

        // 使用 EmailService 发送邮件
        emailService.sendEmail(email, subject, text);
    }
}
