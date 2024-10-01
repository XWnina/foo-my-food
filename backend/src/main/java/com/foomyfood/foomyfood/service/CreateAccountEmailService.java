package com.foomyfood.foomyfood.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.stereotype.Service;

@Service
public class CreateAccountEmailService {

    @Autowired
    private JavaMailSender mailSender;

    /**
     * 发送创建账户的验证邮件
     * @param toEmail 接收者的邮箱地址
     * @param username 用户的用户名
     * @param token 验证 token
     */
    public void sendVerificationEmail(String toEmail, String username, String token) {
        // 构造验证邮件内容
        SimpleMailMessage message = new SimpleMailMessage();

        // 设置发件人邮箱地址
        message.setFrom("foomyfood@outlook.com");  // 替换为你自己的发件人邮箱

        // 设置接收人、主题和内容
        message.setTo(toEmail);
        message.setSubject("Account Verification");
        message.setText("Dear " + username + ",\n\n" +
                "Please verify your account by clicking the link below:\n" +
                "http://localhost:8080/verify?token=" + token + "\n\n" +
                "Thank you,\nFOO MY FOOD Team");

        // 发送邮件
        mailSender.send(message);
    }
}