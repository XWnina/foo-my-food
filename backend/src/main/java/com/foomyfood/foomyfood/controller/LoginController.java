package com.foomyfood.foomyfood.controller;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.Map;
import java.util.regex.Pattern;

@RestController
@RequestMapping("/api")
public class LoginController {

    // 邮箱正则表达式，用于判断输入是邮箱还是用户名
    private static final Pattern emailPattern = Pattern.compile("^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9]+\\.[a-zA-Z]+$");

    @PostMapping("/login")
    public ResponseEntity<Map<String, String>> login(@RequestBody Map<String, String> loginRequest) {
        String usernameOrEmail = loginRequest.get("usernameOrEmail");
        String password = loginRequest.get("password");

        // 判断输入的是邮箱还是用户名
        boolean isEmail = emailPattern.matcher(usernameOrEmail).matches();

        // 模拟数据库查询
        if (isEmail) {
            System.out.println("User is trying to log in with an email");

            // 检查是否存在该邮箱
            if (!"foomyfood@outlook.com".equals(usernameOrEmail)) {
                // 如果邮箱不存在，返回邮箱未找到
                return ResponseEntity.status(404).body(Map.of(
                        "status", "error",
                        "message", "Email not found"
                ));
            }

            // 检查密码是否匹配
            if (!"123456".equals(password)) {
                // 如果密码错误
                return ResponseEntity.status(401).body(Map.of(
                        "status", "error",
                        "message", "Incorrect password"
                ));
            }

        } else {
            System.out.println("User is trying to log in with a username");

            // 检查是否存在该用户名
            if (!"foomyfood".equals(usernameOrEmail)) {
                // 如果用户名不存在，返回用户名未找到
                return ResponseEntity.status(404).body(Map.of(
                        "status", "error",
                        "message", "Username not found"
                ));
            }

            // 检查密码是否匹配
            if (!"123456".equals(password)) {
                // 如果密码错误
                return ResponseEntity.status(401).body(Map.of(
                        "status", "error",
                        "message", "Incorrect password"
                ));
            }
        }

        // 如果邮箱或用户名和密码都匹配，返回登录成功
        return ResponseEntity.ok(Map.of(
                "status", "success",
                "message", "Login successful",
                "userId", "123",
                "username", "testuser"
        ));
    }
}
