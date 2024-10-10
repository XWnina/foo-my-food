package com.foomyfood.foomyfood.database.test_service;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.foomyfood.foomyfood.database.UserIngredient;
import com.foomyfood.foomyfood.database.repository.UserIngredientRepository;

@Service
public class UserIngredientService {

    @Autowired
    private UserIngredientRepository userIngredientRepository;

    // Method to create a new UserIngredient
    public UserIngredient createUserIngredient(Long userId, Long ingredientId, int userQuantity) {
        UserIngredient userIngredient = new UserIngredient(userId, ingredientId, userQuantity);
        return userIngredientRepository.save(userIngredient);
    }

    // Method to save an existing UserIngredient (if you need a general save)
    public UserIngredient saveUserIngredient(UserIngredient userIngredient) {
        return userIngredientRepository.save(userIngredient);
    }

    // Optional: You can add methods to fetch user ingredients by userId or ingredientId if needed
    // e.g. Find all ingredients for a specific user
    public List<UserIngredient> findByUserId(Long userId) {
        return userIngredientRepository.findAllByUserId(userId);
    }
}
