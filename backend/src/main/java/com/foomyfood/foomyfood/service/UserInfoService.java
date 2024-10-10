package com.foomyfood.foomyfood.service;

import java.io.File;
import java.io.IOException;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import com.foomyfood.foomyfood.database.User;
import com.foomyfood.foomyfood.database.db_repository.UserRepository;
import com.foomyfood.foomyfood.dto.UserDTO;

@Service
public class UserInfoService {
    @Autowired
    private UserRepository userRepository;

    public UserDTO getUserById(Long userId) {
        User user = userRepository.findById(userId).orElseThrow(() -> new ResourceNotFoundException("User not found"));
        return new UserDTO(user);
    }

    public boolean updateUserProfile(Long userId, String firstName, String lastName, String username, String email, String phoneNumber, MultipartFile avatar) {
        User user = userRepository.findById(userId).orElseThrow(() -> new ResourceNotFoundException("User not found"));

        user.setFirstName(firstName);
        user.setLastName(lastName);
        user.setUserName(username);
        user.setEmailAddress(email);
        user.setPhoneNumber(phoneNumber);

        // 如果有上传头像，保存头像
        if (avatar != null && !avatar.isEmpty()) {

            String avatarUrl = saveAvatar(avatar);
            user.setImageURL(avatarUrl);
        }

        userRepository.save(user);
        return true;
    }

    private String saveAvatar(MultipartFile avatar) {
        // 保存图片逻辑，这里假设保存路径为 "/uploads/avatar/" + 用户ID
        String filePath = "/uploads/avatar/" + avatar.getOriginalFilename();
        // 保存文件到服务器文件系统或云存储
        try {
            avatar.transferTo(new File(filePath));
        } catch (IOException e) {
            throw new RuntimeException("Failed to save avatar", e);
        }
        return filePath;
    }

    public class ResourceNotFoundException extends RuntimeException {
        public ResourceNotFoundException(String message) {
            super(message);
        }

    }
}
