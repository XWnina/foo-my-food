package com.foomyfood.foomyfood.service;

import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.foomyfood.foomyfood.database.db_repository.UserRepository;

@Service
public class AccountValidationService {

    @Autowired
    private UserRepository userRepository;

    // 检查用户名、邮箱或电话号码是否已存在
    public Optional<String> checkIfUserExists(String userName, String emailAddress, String phoneNumber) {
        if (userRepository.findByUserName(userName).isPresent()) {
            return Optional.of("Username already exists.");
        }
        if (userRepository.findByEmailAddress(emailAddress).isPresent()) {
            return Optional.of("Email already exists.");
        }
        if (userRepository.findByPhoneNumber(phoneNumber).isPresent()) {
            return Optional.of("Phone number already exists.");
        }
        return Optional.empty();
    }
}

