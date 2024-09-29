package com.foomyfood.foomyfood.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.stereotype.Service;

import java.util.UUID;

@Service
public class CreateAccountEmailService {

    @Autowired
    private JavaMailSender mailSender;

    /**
     * 发送创建账户的验证邮件
     * @param toEmail 接收者的邮箱地址
     * @param username 用户的用户名
     */
    public void sendVerificationEmail(String toEmail, String username) {
        // 生成一个唯一的验证Token
        String verificationToken = generateVerificationToken();

        // 构造验证邮件内容
        SimpleMailMessage message = new SimpleMailMessage();

        // 设置发件人邮箱地址
        message.setFrom("foomyfood@outlook.com");  // 替换为你自己的发件人邮箱

        // 设置接收人、主题和内容
        message.setTo(toEmail);
        message.setSubject("Account Verification");
        message.setText("Dear " + username + ",\n\n" +
                "Please verify your account by clicking the link below:\n" +
                "http://localhost:8080/verify?token=" + verificationToken + "\n\n" +
                "Thank you,\nFOO MY FOOD Team");

        // 发送邮件
        mailSender.send(message);

        // 你可以在此处保存 token 和相关用户信息到数据库，以便后续验证
        saveVerificationToken(username, verificationToken);
    }

    /**
     * 生成唯一的验证Token
     * @return 一个UUID生成的Token字符串
     */
    private String generateVerificationToken() {
        return UUID.randomUUID().toString();
    }

    /**
     * 保存生成的验证Token
     * @param username 用户名
     * @param token 生成的Token
     */
    private void saveVerificationToken(String username, String token) {
        // 在这里添加保存Token到数据库的逻辑
        System.out.println("Saving token for user: " + username + ", token: " + token);
    }
}