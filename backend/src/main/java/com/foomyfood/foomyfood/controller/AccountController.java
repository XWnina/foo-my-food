package com.foomyfood.foomyfood.controller;

import com.foomyfood.foomyfood.model.User;
import com.foomyfood.foomyfood.service.CreateAccountEmailService;
import com.foomyfood.foomyfood.service.GoogleCloudStorageService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.UUID;

@RestController
public class AccountController {

    @Autowired
    private CreateAccountEmailService emailService;

    @Autowired
    private GoogleCloudStorageService googleCloudStorageService;  // 注入 GoogleCloudStorageService 实例

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

        String imageUrl = null;

        // 处理文件上传
        if (imageFile != null && !imageFile.isEmpty()) {
            try {
                // 调用Google Cloud Storage服务类，将图片上传到Google Cloud Storage
                imageUrl = googleCloudStorageService.uploadFile(imageFile);
                System.out.println("File uploaded to: " + imageUrl);
            } catch (IOException e) {
                e.printStackTrace();
                return "Failed to upload image.";
            }
        }
        String emailVerificationToken = UUID.randomUUID().toString();

        // 创建并保存 User 对象
        User user = new User();
        user.setFirstName(firstName);
        user.setLastName(lastName);
        user.setUsername(username);
        user.setEmail(email);
        user.setPhone(phone);
        user.setPassword(password);  // 建议加密存储密码，后面有解释
        user.setImageUrl(imageUrl);  // 存储图片 URL
        user.setEmailVerified(false);
        user.setEmailVerificationToken(emailVerificationToken);



        // 打印用户信息以供调试
        System.out.println("User Info: ");
        System.out.println("First Name: " + user.getFirstName());
        System.out.println("Last Name: " + user.getLastName());
        System.out.println("Username: " + user.getUsername());
        System.out.println("Email: " + user.getEmail());
        System.out.println("Phone: " + user.getPhone());
        System.out.println("Password: " + user.getPassword());  // 在生产环境中避免打印密码
        System.out.println("Image URL: " + user.getImageUrl());
        System.out.println("Email Verification Token: " + emailVerificationToken);


        // 调用邮件服务发送验证邮件
        emailService.sendVerificationEmail(email, username, emailVerificationToken);

        return "Account creation initiated successfully. Please check your email for verification.";
    }
}
