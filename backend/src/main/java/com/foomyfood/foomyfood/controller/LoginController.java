package com.foomyfood.foomyfood.controller;

import com.foomyfood.foomyfood.database.User;
import com.foomyfood.foomyfood.database.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import com.foomyfood.foomyfood.service.CreateAccountEmailService;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;
import java.util.regex.Pattern;

@RestController
@RequestMapping("/api")
public class LoginController {

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private CreateAccountEmailService emailService;


    // 邮箱正则表达式，用于判断输入是邮箱还是用户名
    private static final Pattern emailPattern = Pattern.compile("^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9]+\\.[a-zA-Z]+$");

    @PostMapping("/login")
    public ResponseEntity<Map<String, String>> login(@RequestBody Map<String, String> loginRequest) {
        String usernameOrEmail = loginRequest.get("usernameOrEmail");
        String password = loginRequest.get("password");

        Optional<User> user;

        // 判断输入的是邮箱还是用户名
        if (emailPattern.matcher(usernameOrEmail).matches()) {
            // 如果输入的是邮箱，查询用户的邮箱地址
            user = userRepository.findByEmailAddress(usernameOrEmail);
            if (user.isEmpty()) {
                // 如果邮箱不存在
                return ResponseEntity.status(404).body(Map.of(
                        "status", "error",
                        "message", "Email not found, please try again or create account."
                ));
            }
        } else {
            // 如果输入的是用户名，查询用户名
            user = userRepository.findByUserName(usernameOrEmail);
            if (user.isEmpty()) {
                // 如果用户名不存在
                return ResponseEntity.status(404).body(Map.of(
                        "status", "error",
                        "message", "Username not found, please try again or create account."
                ));
            }
        }

        // 验证密码是否匹配
        if (!user.get().getPassword().equals(password)) {
            return ResponseEntity.status(401).body(Map.of(
                    "status", "error",
                    "message", "Incorrect password, please try again."
            ));
        }

        // 检查邮箱是否验证
        if (!user.get().getEmailVerified()) {
            try {
                System.out.println("Attempting to send verification email...");
                String emailVerificationToken = UUID.randomUUID().toString();
                System.out.println(user.get().getEmailAddress());
                emailService.sendVerificationEmail(user.get().getEmailAddress(), user.get().getUserName(), emailVerificationToken);
                User updatedUser = user.get();
                updatedUser.setEmailVerificationToken(emailVerificationToken);
                userRepository.save(updatedUser);  // 显式使用 User 类型
                // 保存 token 到数据库
                return ResponseEntity.status(403).body(Map.of(
                        "status", "error",
                        "message", "Email not verified. A new verification email has been sent."
                ));
            } catch (Exception e) {
                System.out.println("Error sending email: " + e.getMessage());
                return ResponseEntity.status(500).body(Map.of(
                        "status", "error",
                        "message", "Failed to send verification email. Please try again later."
                ));
            }
        }


        // 登录成功后更新 logInStatus 为 true
        User loggedInUser = user.get();
        loggedInUser.setLogInStatus(true);
        userRepository.save(loggedInUser);  // 更新用户状态

        // 返回登录成功信息
        return ResponseEntity.ok(Map.of(
                "status", "success",
                "message", "Login successful",
                "userId", loggedInUser.getId().toString(),
                "username", loggedInUser.getUserName()
        ));
    }
}
