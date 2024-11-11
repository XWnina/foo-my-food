package com.foomyfood.foomyfood.controller;

import com.foomyfood.foomyfood.database.User;
import com.foomyfood.foomyfood.database.db_repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Optional;

@RestController
@RequestMapping("/api/user-theme")
public class UserThemeController {

    @Autowired
    private UserRepository userRepository;

    // 获取用户的主题
    @GetMapping("/{id}")
    public ResponseEntity<String> getUserTheme(@PathVariable Long id) {
        Optional<User> userOptional = userRepository.findById(id); // 使用 findById 获取用户
        if (userOptional.isPresent()) {
            User user = userOptional.get();
            String userTheme = user.getUserTheme();
            return ResponseEntity.ok(userTheme);
        } else {
            return ResponseEntity.notFound().build();
        }
    }

    // 更新用户的主题
    @PutMapping("/{id}")
    public ResponseEntity<String> updateUserTheme(@PathVariable Long id, @RequestBody String userTheme) {
        Optional<User> userOptional = userRepository.findById(id); // 使用 findById 获取用户
        if (userOptional.isPresent()) {
            User user = userOptional.get();
            user.setUserTheme(userTheme); // 更新主题
            userRepository.save(user);
            return ResponseEntity.ok("Theme updated successfully");
        } else {
            return ResponseEntity.notFound().build();
        }
    }
}
