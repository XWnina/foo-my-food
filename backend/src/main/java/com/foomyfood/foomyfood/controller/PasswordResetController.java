package com.foomyfood.foomyfood.controller;

import com.foomyfood.foomyfood.service.PasswordResetService;
import com.foomyfood.foomyfood.dto.PasswordResetRequest;
import com.foomyfood.foomyfood.dto.ResetPasswordRequest;
import com.foomyfood.foomyfood.database.repository.UserRepository;
import com.foomyfood.foomyfood.database.User;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Optional;

@RestController
@RequestMapping("/api/password-reset")
public class PasswordResetController {

    @Autowired
    private PasswordResetService passwordResetService;

    @Autowired
    private UserRepository userRepository;

    // 发送重置链接并检查用户名和邮箱
    @PostMapping("/send-link")
    public ResponseEntity<String> sendResetLink(@RequestBody PasswordResetRequest request) {
        Optional<User> user = userRepository.findByEmailAddress(request.getEmail());

        if (user.isPresent()) {
            User foundUser = user.get();
            if (!foundUser.getUserName().equals(request.getUserName())) {
                return ResponseEntity.status(HttpStatus.CONFLICT).body("Username and email do not match.");
            }
            // 生成重置密码链接并发送到用户邮箱（使用 email 作为唯一标识）
            String resetLink = "http://localhost:8081/api/password-reset/set_password";
            passwordResetService.sendResetLink(request.getEmail(), resetLink);
            return ResponseEntity.ok("Password reset link has been sent to your email.");
        } else {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body("User not found.");
        }
    }


    // 验证重置链接的有效性并跳转到重置密码页面
    @GetMapping("/set_password")
    public ResponseEntity<String> showSetPasswordPage() {
        // 返回前端的页面，提示用户返回 App 重置密码（通过 Flutter 重定向）
        // 这里返回简单的 HTML 页面，前端收到请求后将会重定向至 App 进行密码重置
        return ResponseEntity.ok()
                .header("Content-Type", "text/html")
                .body("<html><body><h1>Password Reset</h1>" +
                        "<p>Please return to the app to reset your password.</p></body></html>");
    }

    // 检查验证状态
    @GetMapping("/check-verification")
    public ResponseEntity<String> checkVerificationStatus(@RequestParam("email") String email) {
        Optional<User> userOptional = userRepository.findByEmailAddress(email);

        if (userOptional.isPresent()) {
            User user = userOptional.get();

            // 检查是否已经验证
            if (user.getEmailVerified() != null && user.getEmailVerified()) {
                return ResponseEntity.ok("Verified");
            } else {
                return ResponseEntity.ok("Not Verified");
            }
        } else {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body("User not found.");
        }
    }

    // 重置密码
    @PostMapping("/reset")
    public ResponseEntity<String> resetPassword(@RequestBody ResetPasswordRequest request) {
        Optional<User> userOptional = userRepository.findByEmailAddress(request.getEmail());
        System.out.println(request.getEmail());
        System.out.println(userRepository.findByEmailAddress(request.getEmail()));

        if (userOptional.isPresent()) {
            User user = userOptional.get();
            user.setPassword(request.getNewPassword());  // 更新用户密码
            userRepository.save(user);  // 保存更改
            return ResponseEntity.ok("Password has been successfully reset.");
        } else {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body("User not found.");
        }
    }
}
