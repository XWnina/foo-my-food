package com.foomyfood.foomyfood.controller;

import com.foomyfood.foomyfood.service.CreateAccountEmailService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class VerificationController {

    @Autowired
    private CreateAccountEmailService emailService;

    @GetMapping("/verify")
    public String verifyAccount(@RequestParam("token") String token) {
        // 这里你可以根据token从数据库中查找用户并验证
        // 验证成功后，激活账户
        System.out.println("Verifying token: " + token);

        // 返回验证成功的页面或消息
        return "Account verified successfully!";
    }
}
