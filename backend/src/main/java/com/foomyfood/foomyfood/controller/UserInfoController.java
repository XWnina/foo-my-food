package com.foomyfood.foomyfood.controller;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import com.foomyfood.foomyfood.database.User;
import com.foomyfood.foomyfood.database.db_repository.UserRepository;
import com.foomyfood.foomyfood.service.GoogleCloudStorageService;

@RestController
@RequestMapping("/api/user")
public class UserInfoController {

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private GoogleCloudStorageService googleCloudStorageService;

    @GetMapping(value = "/{userId}", produces = "application/json")
    public ResponseEntity<User> getUserProfile(@PathVariable Long userId) {
        Optional<User> userOptional = userRepository.findById(userId);
        if (userOptional.isPresent()) {
            User user = userOptional.get();
            return ResponseEntity.ok(user); // 返回 JSON 格式的 User 实体，包含 avatarUrl
        } else {
            return new ResponseEntity<>(HttpStatus.NOT_FOUND);
        }
    }

    @PostMapping("/{userId}/update")
    public ResponseEntity<?> updateUserProfile(
            @PathVariable Long userId,
            @RequestParam("firstName") String firstName,
            @RequestParam("lastName") String lastName,
            @RequestParam("userName") String userName,
            @RequestParam("emailAddress") String emailAddress,
            @RequestParam("phoneNumber") String phoneNumber,
            @RequestParam(value = "avatar", required = false) MultipartFile avatar) {

        try {
            Optional<User> userOptional = userRepository.findById(userId);
            if (userOptional.isPresent()) {
                User user = userOptional.get();

                // 检查用户名是否唯一
                Optional<User> existingUserByUsername = userRepository.findByUserName(userName);
                if (existingUserByUsername.isPresent() && !existingUserByUsername.get().getId().equals(userId)) {
                    return new ResponseEntity<>("Username already taken", HttpStatus.CONFLICT);
                }

                // 检查邮箱是否唯一
                Optional<User> existingUserByEmail = userRepository.findByEmailAddress(emailAddress);
                if (existingUserByEmail.isPresent() && !existingUserByEmail.get().getId().equals(userId)) {
                    return new ResponseEntity<>("Email address already taken", HttpStatus.CONFLICT);
                }

                // 检查电话号码是否唯一
                Optional<User> existingUserByPhone = userRepository.findByPhoneNumber(phoneNumber);
                if (existingUserByPhone.isPresent() && !existingUserByPhone.get().getId().equals(userId)) {
                    return new ResponseEntity<>("Phone number already taken", HttpStatus.CONFLICT);
                }

                // 更新用户信息
                user.setFirstName(firstName);
                user.setLastName(lastName);
                user.setUserName(userName);
                user.setEmailAddress(emailAddress);
                user.setPhoneNumber(phoneNumber);

                // 如果有上传头像，处理头像
                if (avatar != null && !avatar.isEmpty()) {
                    // 检查是否已有头像URL
                    if (user.getImageURL() != null && !user.getImageURL().isEmpty()) {
                        // 删除之前的头像
                        googleCloudStorageService.deleteFile(user.getImageURL());
                    }
                    String avatarUrl = googleCloudStorageService.uploadFile(avatar);
                    user.setImageURL(avatarUrl); // 更新用户头像URL
                }

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
    @PutMapping("{userId}/tracking-days")
    public ResponseEntity<?> updateUserTrackingDays(
            @PathVariable Long userId,
            @RequestBody Map<String, Integer> request) {
        Integer trackingDays = request.get("trackingDays");
        if (trackingDays == null) {
            return new ResponseEntity<>("trackingDays parameter is missing", HttpStatus.BAD_REQUEST);
        }
        Optional<User> userOptional = userRepository.findById(userId);
        if (userOptional.isPresent()) {
            User user = userOptional.get();
            user.setUserRecipeTrackingTime(Long.valueOf(trackingDays));
            userRepository.save(user);
            return new ResponseEntity<>("Tracking days updated successfully", HttpStatus.OK);
        } else {
            return new ResponseEntity<>("User not found", HttpStatus.NOT_FOUND);
        }
    }
    // 在 UserInfoController 中，确保是 @GetMapping
    @GetMapping("/{userId}/tracking-days")  // 使用 @GetMapping 而不是 @PostMapping 或 @PutMapping
    public ResponseEntity<Map<String, Integer>> getUserTrackingDays(@PathVariable Long userId) {
        Optional<User> userOptional = userRepository.findById(userId);
        if (userOptional.isPresent()) {
            Long trackingDays = userOptional.get().getUserRecipeTrackingTime();
            Map<String, Integer> response = new HashMap<>();
            response.put("trackingDays", Math.toIntExact(trackingDays != null ? trackingDays : 30)); // 提供默认值
            return ResponseEntity.ok(response);
        } else {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(null);
        }
    }
    @PutMapping("/{userId}/ingredient-tracking-days")
    public ResponseEntity<?> updateUserIngredientTrackingDays(
            @PathVariable Long userId,
            @RequestBody Map<String, Integer> request) {
        Integer ingredientTrackingDays = request.get("ingredientTrackingDays");
        if (ingredientTrackingDays == null) {
            return new ResponseEntity<>("ingredientTrackingDays parameter is missing", HttpStatus.BAD_REQUEST);
        }
        Optional<User> userOptional = userRepository.findById(userId);
        if (userOptional.isPresent()) {
            User user = userOptional.get();
            user.setUserIngredientExpirationTime(Long.valueOf(ingredientTrackingDays));
            userRepository.save(user);
            return new ResponseEntity<>("Ingredient tracking days updated successfully", HttpStatus.OK);
        } else {
            return new ResponseEntity<>("User not found", HttpStatus.NOT_FOUND);
        }
    }

    @GetMapping("/{userId}/ingredient-tracking-days")
    public ResponseEntity<Map<String, Integer>> getUserIngredientTrackingDays(@PathVariable Long userId) {
        Optional<User> userOptional = userRepository.findById(userId);
        if (userOptional.isPresent()) {
            Long ingredientTrackingDays = userOptional.get().getUserIngredientExpirationTime();
            Map<String, Integer> response = new HashMap<>();
            response.put("ingredientTrackingDays", Math.toIntExact(ingredientTrackingDays != null ? ingredientTrackingDays : 3)); // 提供默认值
            return ResponseEntity.ok(response);
        } else {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(null);
        }
    }




}
