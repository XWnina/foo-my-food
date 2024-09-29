package com.foomyfood.foomyfood.controller;

import com.foomyfood.foomyfood.dto.UserRegistrationRequest;
import com.foomyfood.foomyfood.service.CreateAccountEmailService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class AccountController {

    @Autowired
    private CreateAccountEmailService emailService;

    @PostMapping("/create-account")
    public String createAccount(@RequestBody UserRegistrationRequest request) {
        // 假设你有一个用户注册的请求
        String email = request.getEmail();
        String username = request.getUsername();

        // 调用邮箱验证服务发送验证邮件
        emailService.sendVerificationEmail(email, username);

        return "Account creation initiated. Please check your email for verification.";
    }
}
