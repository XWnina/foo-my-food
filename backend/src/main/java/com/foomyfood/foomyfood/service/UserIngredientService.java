package com.foomyfood.foomyfood.service;

import com.foomyfood.foomyfood.database.UserIngredient;
import com.foomyfood.foomyfood.database.repository.UserIngredientRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class UserIngredientService {

    @Autowired
    private UserIngredientRepository userIngredientRepository;

    // Create a new user ingredient
    public UserIngredient createUserIngredient(Long userId, Long ingredientId, int userQuantity) {
        UserIngredient userIngredient = new UserIngredient(userId, ingredientId, userQuantity);
        return userIngredientRepository.save(userIngredient);
    }

    // Get all user ingredients by user ID
    public List<UserIngredient> getAllUserIngredients(Long userId) {
        return userIngredientRepository.findByUserId(userId);
    }

    // Find user ingredient by user ID and ingredient ID
    public Optional<UserIngredient> getUserIngredient(Long userId, Long ingredientId) {
        return userIngredientRepository.findByUserIdAndIngredientId(userId, ingredientId);
    }

    // Update an existing user ingredient
    public UserIngredient updateUserIngredient(Long userId, Long ingredientId, int userQuantity) {
        Optional<UserIngredient> optionalUserIngredient = userIngredientRepository.findByUserIdAndIngredientId(userId, ingredientId);
        
        if (optionalUserIngredient.isPresent()) {
            UserIngredient userIngredient = optionalUserIngredient.get();
            userIngredient.setUserQuantity(userQuantity);
            return userIngredientRepository.save(userIngredient);
        } else {
            throw new RuntimeException("UserIngredient not found");
        }
    }

    // Delete user ingredient by user ID and ingredient ID
    public void deleteUserIngredient(Long userId, Long ingredientId) {
        userIngredientRepository.deleteById(userIngredientRepository.findByUserIdAndIngredientId(userId, ingredientId)
            .orElseThrow(() -> new RuntimeException("UserIngredient not found")).getUserIngredientId());
    }

    public UserIngredient createUserIngredient(UserIngredient userIngredientDTO) {
        return userIngredientDTO;
    }
}