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

    // create a user
    public User createUser(String firstName, String lastName, String userName, String emailAddress, String phoneNumber, String password, String imageURL, String emailVerificationToken, Boolean emailVerified) {
        User user = new User(firstName, lastName, userName, emailAddress, phoneNumber, password, imageURL, emailVerificationToken, emailVerified);
        return userRepository.save(user);
    }

    // find the user data row via the table id
    public Optional<User> getUserById(Long id) {
        return userRepository.findById(id);
    }

    // find the user id via unique username
    public Optional<User> getUserByUserName(String userName) {
        return userRepository.findByUserName(userName);
    }

    // delete a user
    public void deleteUser(Long id) {
        userRepository.deleteById(id);
    }

    // update a user info
    public User updateUser(Long id, String firstName, String lastName, String userName, String emailAddress, String phoneNumber, String password, String imageURL, String emailVerificationToken, Boolean emailVerified) {
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
            return userRepository.save(user); 
        } else {
            throw new RuntimeException("用户未找到");
        }
    }
}
