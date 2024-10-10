package com.foomyfood.foomyfood.database.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

import com.foomyfood.foomyfood.database.User;
import com.foomyfood.foomyfood.database.service.UserService;

@RestController
public class UserController {

    @Autowired
    private UserService userService;

    @PostMapping("/user")
    public User createUser(@RequestBody User user) {
        return userService.createUser(
                user.getFirstName(),
                user.getLastName(),
                user.getUserName(),
                user.getEmailAddress(),
                user.getPhoneNumber(),
                user.getPassword(),
                user.getImageURL(),
                user.getEmailVerificationToken(),
                user.getEmailVerified(),
                user.getSecurityQuestion(),
                user.getSecurityQuestAnswer(),
                user.getLogInStatus()
        );
    }
}
