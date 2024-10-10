package com.foomyfood.foomyfood.service;

import com.foomyfood.foomyfood.database.User;
import com.foomyfood.foomyfood.database.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class PasswordResetService {

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private EmailService emailService;  // 假设你有 EmailService 发送邮件

    // 发送重置链接到邮箱
    public void sendResetLink(String email, String resetLink) {
        // 发送重置密码的链接到用户邮箱
        String subject = "Password Reset Request";
        String text = "Please click the link below to reset your password:\n" + resetLink;
        emailService.sendEmail(email, subject, text);
    }

    // 重置密码，不需要 token
    public void resetPassword(String newPassword) {
        // 假设你有用户登录逻辑，或者根据前端传递的用户信息找到用户
        // 例如，使用某种方式获取当前用户
        User user = getCurrentUser();  // 你需要自定义的逻辑，获取当前需要重置密码的用户

        if (user != null) {
            // 更新用户密码
            user.setPassword(newPassword);  // 此处假设密码不需要加密
            userRepository.save(user);  // 保存新的密码到数据库中
        } else {
            throw new RuntimeException("User not found.");
        }
    }

    // 示例方法：假设你有某种方式获取当前用户
    private User getCurrentUser() {
        // 此处你可以用实际逻辑，如从登录上下文或传入的用户信息中获取当前用户
        // 例如，Spring Security中可以从认证信息中获取当前用户
        // 这里只是举例，具体实现可能不同
        return userRepository.findByUserName("exampleUserName").orElse(null);  // 使用用户名示例
    }
}
