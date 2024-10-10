package com.foomyfood.foomyfood.controller;

import com.foomyfood.foomyfood.database.User;
import com.foomyfood.foomyfood.database.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.Optional;

@RestController
public class VerificationController {

    @Autowired
    private UserRepository userRepository;


    @GetMapping("/verify")
    public ResponseEntity<String> verifyAccount(@RequestParam("token") String token) {
        // 根据 emailVerificationToken 查找用户
        Optional<User> userOptional = userRepository.findByEmailVerificationToken(token);

        // 如果用户不存在，返回错误信息
        if (userOptional.isEmpty()) {
            return new ResponseEntity<>("Invalid verification token.", HttpStatus.BAD_REQUEST);
        }

        User user = userOptional.get();

        // 检查邮箱是否已经验证过
        if (user.getEmailVerified()) {
            return new ResponseEntity<>("Your email is already verified.", HttpStatus.BAD_REQUEST);
        }

        // 验证成功，更新邮箱验证状态并删除验证 token
        user.setEmailVerified(true);
        user.setEmailVerificationToken(null); // 删除 token
        userRepository.save(user);

        return new ResponseEntity<>("Email verified successfully!", HttpStatus.OK);
    }

}
