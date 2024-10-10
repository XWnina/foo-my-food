package com.foomyfood.foomyfood.controller;

import java.util.Map;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.foomyfood.foomyfood.database.User;
import com.foomyfood.foomyfood.database.db_repository.UserRepository;

@RestController
@RequestMapping("/api")
public class LogoutController {

    @Autowired
    private UserRepository userRepository;

    @PostMapping("/logout")
    @Transactional  // Ensure that the logout happens in a transactional context
    public ResponseEntity<String> logout(@RequestBody Map<String, Long> request) {
        Long userId = request.get("userId");

        // Check if user exists in the database
        Optional<User> userOptional = userRepository.findById(userId);

        if (userOptional.isEmpty()) {
            // Return 404 if user not found
            return ResponseEntity.status(404).body("User not found.");
        }

        // Get the user from the optional
        User user = userOptional.get();

        // Check if the user is currently logged in
        if (!user.getLogInStatus()) {
            // If the user is not logged in, return a message
            return ResponseEntity.status(400).body("User is already logged out.");
        }

        // Update the user's login status to false (log out the user)
        user.setLogInStatus(false);
        userRepository.save(user);  // Persist the updated user entity

        // Return a success message
        return ResponseEntity.ok("Logout successful.");
    }
}
