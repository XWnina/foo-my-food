package com.foomyfood.foomyfood.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.stereotype.Service;
import org.springframework.mail.MailException;

@Service
public class CreateAccountEmailService {

    @Autowired
    private JavaMailSender mailSender;

    // 发送创建账户的验证邮件
    public void sendVerificationEmail(String toEmail, String username, String token) {
        try {
            SimpleMailMessage message = new SimpleMailMessage();
            message.setFrom("foomyfood@outlook.com");  // 替换为你自己的发件人邮箱
            message.setTo(toEmail);
            message.setSubject("Account Verification");
            message.setText("Dear " + username + ",\n\n" +
                    "Please verify your account by clicking the link below:\n" +
                    "http://localhost:8081/verify?token=" + token + "\n\n" +
                    "Thank you,\nFOO MY FOOD Team");

            mailSender.send(message);
        } catch (MailException e) {
            throw new RuntimeException("Failed to send verification email to " + toEmail, e);
        }
    }
}
