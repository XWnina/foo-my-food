package com.foomyfood.foomyfood.database.db_service;

import java.util.List;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.foomyfood.foomyfood.database.UserIngredient;
import com.foomyfood.foomyfood.database.db_repository.UserIngredientRepository;

@Service
public class UserIngredientService {

    @Autowired
    private UserIngredientRepository userIngredientRepository;

    // Get all user ingredients by userId
    public List<UserIngredient> getAllUserIngredients(Long userId) {
        return userIngredientRepository.findAllByUserId(userId);
    }

    // Get a specific user ingredient by userId and ingredientId
    public Optional<UserIngredient> getUserIngredient(Long userId, Long ingredientId) {
        return userIngredientRepository.findByUserIdAndIngredientId(userId, ingredientId);
    }

    // Create a new user ingredient
    public UserIngredient createUserIngredient(Long userId, Long ingredientId, int userQuantity) {
        UserIngredient userIngredient = new UserIngredient(userId, ingredientId, userQuantity);
        return userIngredientRepository.save(userIngredient);
    }

    // Update an existing user ingredient
    public UserIngredient updateUserIngredient(Long userId, Long ingredientId, int userQuantity) {
        Optional<UserIngredient> optionalUserIngredient = userIngredientRepository.findByUserIdAndIngredientId(userId, ingredientId);
        if (optionalUserIngredient.isPresent()) {
            UserIngredient userIngredient = optionalUserIngredient.get();
            userIngredient.setUserQuantity(userQuantity);
            return userIngredientRepository.save(userIngredient);
        } else {
            throw new RuntimeException("UserIngredient not found for userId " + userId + " and ingredientId " + ingredientId);
        }
    }

    // Delete a user ingredient by userId and ingredientId
    public void deleteUserIngredient(Long userId, Long ingredientId) {
        Optional<UserIngredient> optionalUserIngredient = userIngredientRepository.findByUserIdAndIngredientId(userId, ingredientId);
        if (optionalUserIngredient.isPresent()) {
            userIngredientRepository.delete(optionalUserIngredient.get());
        } else {
            throw new RuntimeException("UserIngredient not found for userId " + userId + " and ingredientId " + ingredientId);
        }
    }
}
