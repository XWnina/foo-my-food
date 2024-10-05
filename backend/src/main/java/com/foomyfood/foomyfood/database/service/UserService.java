package com.foomyfood.foomyfood.database.service;

import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.foomyfood.foomyfood.database.User;
import com.foomyfood.foomyfood.database.repository.UserRepository;

@Service
public class UserService {

    @Autowired
    private UserRepository userRepository;

    // Create a new user
    public User createUser(String firstName, String lastName, String userName, String emailAddress, String phoneNumber, String password, String imageURL, String emailVerificationToken, Boolean emailVerified, String securityQuestion, String securityQuestAnswer) {
        User user = new User(firstName, lastName, userName, emailAddress, phoneNumber, password, imageURL, emailVerificationToken, emailVerified, securityQuestion, securityQuestAnswer);
        return userRepository.save(user);
    }

    // Find user by ID
    public Optional<User> getUserById(Long id) {
        return userRepository.findById(id);
    }

    // Find user by unique username
    public Optional<User> getUserByUserName(String userName) {
        return userRepository.findByUserName(userName);
    }

    // Delete user by ID
    public void deleteUser(Long id) {
        userRepository.deleteById(id);
    }

    // Update an existing user's information
    public User updateUser(Long id, String firstName, String lastName, String userName, String emailAddress, String phoneNumber, String password, String imageURL, String emailVerificationToken, Boolean emailVerified, String securityQuestion, String securityQuestAnswer) {
        Optional<User> optionalUser = userRepository.findById(id);
        
        if (optionalUser.isPresent()) {
            User user = optionalUser.get();
            user.setFirstName(firstName);
            user.setLastName(lastName);
            user.setUserName(userName);
            user.setEmailAddress(emailAddress);
            user.setPhoneNumber(phoneNumber);
            user.setPassword(password);
            user.setImageURL(imageURL);
            user.setEmailVerificationToken(emailVerificationToken);
            user.setEmailVerified(emailVerified);
            user.setSecurityQuestion(securityQuestion);
            user.setSecurityQuestAnswer(securityQuestAnswer);
            return userRepository.save(user); 
        } else {
            throw new RuntimeException("User not found");
        }
    }
}
