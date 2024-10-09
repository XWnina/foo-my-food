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

    // 验证重置链接的有效性（去除 token 验证）
    @GetMapping("/set_password")
    public ResponseEntity<String> resetWithoutToken() {
        // 返回 HTML 页面，提示用户返回 App 重置密码
        return ResponseEntity.ok()
                .header("Content-Type", "text/html")
                .body("<html><body><h1>Password Reset</h1>" +
                        "<p>Please return to the app to reset your password.</p></body></html>");
    }

    // 发送重置链接
    @PostMapping("/send-link")
    public ResponseEntity<String> sendResetLink(@RequestBody PasswordResetRequest request) {
        // 查找用户是否存在
        Optional<User> user = userRepository.findByEmailAddress(request.getEmail());

        if (user.isPresent()) {
            // 生成重置密码链接并发送到用户邮箱（不再生成 token）
            String resetLink = "http://localhost:8081/api/password-reset/set_password";
            passwordResetService.sendResetLink(request.getEmail(),resetLink);
            return ResponseEntity.ok("Password reset link has been sent to your email.");
        } else {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body("User not found.");
        }
    }
    // 重置密码
    @PostMapping("/reset")
    public ResponseEntity<String> resetPassword(@RequestBody ResetPasswordRequest request) {
        passwordResetService.resetPassword(request.getNewPassword());
        return ResponseEntity.ok("Password has been successfully reset.");
    }

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


}
