package com.foomyfood.foomyfood.controller;

import com.foomyfood.foomyfood.database.User;
import com.foomyfood.foomyfood.database.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;
import java.util.Optional;
import java.util.regex.Pattern;

@RestController
@RequestMapping("/api")
public class LoginController {

    @Autowired
    private UserRepository userRepository;

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
                        "message", "Email not found"
                ));
            }
        } else {
            // 如果输入的是用户名，查询用户名
            user = userRepository.findByUserName(usernameOrEmail);
            if (user.isEmpty()) {
                // 如果用户名不存在
                return ResponseEntity.status(404).body(Map.of(
                        "status", "error",
                        "message", "Username not found"
                ));
            }
        }

        // 验证密码是否匹配
        if (!user.get().getPassword().equals(password)) {
            return ResponseEntity.status(401).body(Map.of(
                    "status", "error",
                    "message", "Incorrect password"
            ));
        }

        // 检查邮箱是否验证
        if (Boolean.FALSE.equals(user.get().getEmailVerified())) {
            return ResponseEntity.status(403).body(Map.of(
                    "status", "error",
                    "message", "Email is not verified. Please verify your email to log in."
            ));
        }

        // 如果邮箱或用户名和密码都匹配，返回登录成功
        return ResponseEntity.ok(Map.of(
                "status", "success",
                "message", "Login successful",
                "userId", user.get().getId().toString(),
                "username", user.get().getUserName()
        ));
    }

}
