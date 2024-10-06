package com.foomyfood.foomyfood.controller;

import com.foomyfood.foomyfood.database.User;
import com.foomyfood.foomyfood.database.repository.UserRepository;
import com.foomyfood.foomyfood.dto.UserDTO;
import com.foomyfood.foomyfood.service.GoogleCloudStorageService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.Optional;

@RestController
@RequestMapping("/api/user")
public class UserInfoController {

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private GoogleCloudStorageService googleCloudStorageService;

    @GetMapping(value = "/{userId}", produces = "application/json")
    public ResponseEntity<String> getUserProfile(@PathVariable Long userId) {
        Optional<User> userOptional = userRepository.findById(userId);
        if (userOptional.isPresent()) {
            User user = userOptional.get();
            return ResponseEntity.ok(new UserDTO(user).toString()); // 返回 DTO
        } else {
            return new ResponseEntity<>("User not found", HttpStatus.NOT_FOUND);
        }
    }


    // 更新用户信息的端点
    @PostMapping("/{userId}/update")
    public ResponseEntity<?> updateUserProfile(
            @PathVariable Long userId,
            @RequestParam("firstName") String firstName,
            @RequestParam("lastName") String lastName,
            @RequestParam("username") String username,
            @RequestParam("email") String email,
            @RequestParam("phoneNumber") String phoneNumber,
            @RequestParam(value = "avatar", required = false) MultipartFile avatar) {

        try {
            // 检查用户是否存在
            Optional<User> userOptional = userRepository.findById(userId);
            if (userOptional.isPresent()) {
                User user = userOptional.get();

                // 更新用户信息
                user.setFirstName(firstName);
                user.setLastName(lastName);
                user.setUserName(username);
                user.setEmailAddress(email);
                user.setPhoneNumber(phoneNumber);

                // 如果有头像上传，处理头像
                if (avatar != null && !avatar.isEmpty()) {
                    String avatarUrl = googleCloudStorageService.uploadFile(avatar);
                    user.setImageURL(avatarUrl);
                }

                // 保存更新到数据库
                userRepository.save(user);
                return new ResponseEntity<>("Profile updated successfully", HttpStatus.OK);

            } else {
                return new ResponseEntity<>("User not found", HttpStatus.NOT_FOUND);
            }
        } catch (IOException e) {
            return new ResponseEntity<>("Failed to upload avatar", HttpStatus.INTERNAL_SERVER_ERROR);
        } catch (Exception e) {
            return new ResponseEntity<>("An unexpected error occurred: " + e.getMessage(), HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }
}
