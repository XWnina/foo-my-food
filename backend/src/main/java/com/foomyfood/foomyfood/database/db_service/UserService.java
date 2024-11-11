package com.foomyfood.foomyfood.database.db_service;

import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.foomyfood.foomyfood.database.User;
import com.foomyfood.foomyfood.database.db_repository.UserRepository;

@Service
public class UserService {

    @Autowired
    private UserRepository userRepository;

    // Create a new user
    public User createUser(String firstName, String lastName, String userName, String emailAddress, String phoneNumber, String password, String imageURL, String emailVerificationToken, Boolean emailVerified, String securityQuestion, String securityQuestAnswer, Boolean logInStatus) {
        User user = new User(firstName, lastName, userName, emailAddress, phoneNumber, password, imageURL, emailVerificationToken, emailVerified, securityQuestion, securityQuestAnswer, logInStatus);
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

    // Create a new user with optional fields for expiration time, tracking time, and theme
    public User createUser(String firstName, String lastName, String userName, String emailAddress, String phoneNumber, String password, String imageURL, String emailVerificationToken, Boolean emailVerified, String securityQuestion, String securityQuestAnswer, Boolean logInStatus, Long userIngredientExpirationTime, Long userRecipeTrackingTime, String userTheme) {
        User user = new User(firstName, lastName, userName, emailAddress, phoneNumber, password, imageURL, emailVerificationToken, emailVerified, securityQuestion, securityQuestAnswer, logInStatus);
        user.setUserIngredientExpirationTime(userIngredientExpirationTime);
        user.setUserRecipeTrackingTime(userRecipeTrackingTime);
        user.setUserTheme(userTheme);
        return userRepository.save(user);
    }
    
    // Update an existing user's information with optional parameters for the new fields
    public User updateUser(Long id, String firstName, String lastName, String userName, String emailAddress, String phoneNumber, String password, String imageURL, String emailVerificationToken, Boolean emailVerified, String securityQuestion, String securityQuestAnswer, Long userIngredientExpirationTime, Long userRecipeTrackingTime, String userTheme) {
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
            user.setUserIngredientExpirationTime(userIngredientExpirationTime);
            user.setUserRecipeTrackingTime(userRecipeTrackingTime);
            user.setUserTheme(userTheme);
            return userRepository.save(user); 
        } else {
            throw new RuntimeException("User not found");
        }
    }
}
