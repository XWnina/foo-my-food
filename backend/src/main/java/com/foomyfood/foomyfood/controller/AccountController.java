package com.foomyfood.foomyfood.controller;

import com.foomyfood.foomyfood.dto.UserRegistrationRequest;
import com.foomyfood.foomyfood.service.CreateAccountEmailService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.io.IOException;

@RestController
public class AccountController {

    @Autowired
    private CreateAccountEmailService emailService;

    @PostMapping("/create-account")
    public String createAccount(
            @RequestParam("firstName") String firstName,
            @RequestParam("lastName") String lastName,
            @RequestParam("username") String username,
            @RequestParam("email") String email,
            @RequestParam("phone") String phone,
            @RequestParam("password") String password,
            @RequestParam(value = "image", required = false) MultipartFile imageFile // 头像为可选项
    ) {

        // 保存文本字段到数据库或进一步处理
        System.out.println("First Name: " + firstName);
        System.out.println("Last Name: " + lastName);
        System.out.println("Username: " + username);
        System.out.println("Email: " + email);
        System.out.println("Phone: " + phone);

        // 处理文件上传
        if (imageFile != null && !imageFile.isEmpty()) {
            try {
                // 保存图片到服务器
                String filePath = "/path/to/store/images/" + username + ".png";
                imageFile.transferTo(new File(filePath));
                System.out.println("File uploaded to: " + filePath);
            } catch (IOException e) {
                e.printStackTrace();
                return "Failed to upload image.";
            }
        }

        // 调用邮件服务发送验证邮件
        emailService.sendVerificationEmail(email, username);

        return "Account creation initiated. Please check your email for verification.";
    }
}
