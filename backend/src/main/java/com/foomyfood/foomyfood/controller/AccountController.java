package com.foomyfood.foomyfood.controller;

import java.io.IOException;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import com.foomyfood.foomyfood.database.User;
import com.foomyfood.foomyfood.database.db_repository.UserRepository;
import com.foomyfood.foomyfood.service.CreateAccountEmailService;
import com.foomyfood.foomyfood.service.GoogleCloudStorageService;

@RestController
@RequestMapping("/api")
public class AccountController {

    @Autowired
    private CreateAccountEmailService emailService;

    @Autowired
    private GoogleCloudStorageService googleCloudStorageService;

    @Autowired
    private UserRepository userRepository;

    // 创建用户的端点
    @PostMapping("/create-account")
    public ResponseEntity<?> createAccount(
            @RequestParam("firstName") String firstName,
            @RequestParam("lastName") String lastName,
            @RequestParam("userName") String userName,
            @RequestParam("emailAddress") String emailAddress,
            @RequestParam("phoneNumber") String phoneNumber,
            @RequestParam("password") String password,
            @RequestParam(value = "image", required = false) MultipartFile imageFile
    ) {
        try {
            // 检查用户名是否已存在
            Optional<User> existingUser = userRepository.findByUserName(userName);
            if (existingUser.isPresent() && existingUser.get().getEmailVerified()) {
                // 如果用户名已存在并且已经验证，不能覆盖
                return new ResponseEntity<>("Username already exists. Please choose another.", HttpStatus.CONFLICT);
            }

            // 检查邮箱是否已存在
            Optional<User> existingEmail = userRepository.findByEmailAddress(emailAddress);
            if (existingEmail.isPresent() && existingEmail.get().getEmailVerified()) {
                return new ResponseEntity<>("Email already exists. Please use another.", HttpStatus.CONFLICT);
            }

            // 检查电话号码是否已存在
            Optional<User> existingPhone = userRepository.findByPhoneNumber(phoneNumber);
            if (existingPhone.isPresent() && existingPhone.get().getEmailVerified()) {
                return new ResponseEntity<>("Phone number already exists. Please use another.", HttpStatus.CONFLICT);
            }

            // 处理文件上传
            String imageUrl = null;
            if (imageFile != null && !imageFile.isEmpty()) {
                if (imageFile.getSize() > 5242880) { // 限制文件大小为5MB
                    return new ResponseEntity<>("File size exceeds the 5MB limit.", HttpStatus.BAD_REQUEST);
                }
                imageUrl = googleCloudStorageService.uploadFile(imageFile);
            }

            // 生成邮箱验证Token
            String emailVerificationToken = UUID.randomUUID().toString();

            // 如果用户已存在但未验证，使用新的信息覆盖旧数据
            User user = existingUser.orElse(new User());

            // 使用 setter 方法设置每个字段
            user.setFirstName(firstName);
            user.setLastName(lastName);
            user.setUserName(userName);
            user.setEmailAddress(emailAddress);
            user.setPhoneNumber(phoneNumber);
            user.setPassword(password); // 可以用加密后的密码代替
            user.setImageURL(imageUrl);
            user.setEmailVerificationToken(emailVerificationToken);
            user.setEmailVerified(false); // 设置邮箱验证状态为 false

            // 保存用户到数据库
            userRepository.save(user);

            // 发送验证邮件
            emailService.sendVerificationEmail(emailAddress, userName, emailVerificationToken);

            return new ResponseEntity<>("Account creation initiated successfully. Please check your email for verification.", HttpStatus.OK);
        } catch (IOException e) {
            return new ResponseEntity<>("Failed to upload image.", HttpStatus.INTERNAL_SERVER_ERROR);
        } catch (Exception e) {
            return new ResponseEntity<>("An unexpected error occurred: " + e.getMessage(), HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }


    // 新增的 /check-unique 端点，用于检查用户名、邮箱、电话号码的唯一性
    @GetMapping("/check-unique")
    public ResponseEntity<?> checkUnique(
            @RequestParam(value = "userName", required = false) String userName,
            @RequestParam(value = "emailAddress", required = false) String emailAddress,
            @RequestParam(value = "phoneNumber", required = false) String phoneNumber) {

        // 检查用户名是否已存在
        if (userName != null && userRepository.findByUserName(userName).isPresent()) {
            return new ResponseEntity<>("Username already exists.", HttpStatus.CONFLICT);
        }

        // 检查邮箱是否已存在
        if (emailAddress != null && userRepository.findByEmailAddress(emailAddress).isPresent()) {
            return new ResponseEntity<>("Email already exists.", HttpStatus.CONFLICT);
        }

        // 检查电话号码是否已存在
        if (phoneNumber != null && userRepository.findByPhoneNumber(phoneNumber).isPresent()) {
            return new ResponseEntity<>("Phone number already exists.", HttpStatus.CONFLICT);
        }

        return new ResponseEntity<>("Unique", HttpStatus.OK);
    }

    // 新增 API 以检查用户邮箱是否已验证
    @GetMapping("/check-verification-status")
    public ResponseEntity<Map<String, Boolean>> checkVerificationStatus(@RequestParam("emailAddress") String emailAddress) {
        return userRepository.findByEmailAddress(emailAddress)
                .map(user -> new ResponseEntity<>(Map.of("isVerified", user.getEmailVerified()), HttpStatus.OK))
                .orElseGet(() -> new ResponseEntity<>(Map.of("isVerified", false), HttpStatus.NOT_FOUND));
    }
}