package com.foomyfood.foomyfood.database.db_service;

import java.time.LocalDate;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.foomyfood.foomyfood.database.Ingredient;
import com.foomyfood.foomyfood.database.UserIngredient;
import com.foomyfood.foomyfood.database.db_repository.IngredientRepository;
import com.foomyfood.foomyfood.database.db_repository.UserIngredientRepository;

@Service
public class UserIngredientService {

    @Autowired
    private UserIngredientRepository userIngredientRepository;

    @Autowired
    private IngredientRepository ingredientRepository;

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

    public List<List<Object>> getUserIngredientsDetails(Long userId) {
        // Step 1: Get all ingredientIds for the given userId
        List<UserIngredient> ingredientIds = userIngredientRepository.findAllByUserId(userId);

        // Step 2: Retrieve the details of the ingredients by ingredientIds from ingredients table
        List<Ingredient> ingredients = ingredientRepository.findAll();

        // Step 3: Convert the ingredients into a list of lists
        List<List<Object>> ingredientDetailsList = new ArrayList<>();

        for (Ingredient ingredient : ingredients) {
            // Add ingredient properties to inner list
            List<Object> ingredientDetails = new ArrayList<>();
            ingredientDetails.add(ingredient.getIngredientId());
            ingredientDetails.add(ingredient.getName());
            ingredientDetails.add(ingredient.getStorageMethod());
            ingredientDetails.add(ingredient.getBaseQuantity());
            ingredientDetails.add(ingredient.getCalories());
            ingredientDetails.add(ingredient.getCarbohydrates());
            ingredientDetails.add(ingredient.getCategory());
            ingredientDetails.add(ingredient.getCreatedBy());
            ingredientDetails.add(ingredient.getExpirationDate());
            ingredientDetails.add(ingredient.getFat());
            ingredientDetails.add(ingredient.getFiber());
            ingredientDetails.add(ingredient.getImageURL());
            ingredientDetails.add(ingredient.getIsUserCreated());

            // Add the inner list to the outer list
            ingredientDetailsList.add(ingredientDetails);
        }

        return ingredientDetailsList;  // List of list with ingredient details
    }
    public List<Ingredient> getExpiringIngredients(Long userId) {
        List<UserIngredient> userIngredients = userIngredientRepository.findAllByUserId(userId);
        List<Ingredient> expiringIngredients = new ArrayList<>();

        for (UserIngredient userIngredient : userIngredients) {
            Optional<Ingredient> optionalIngredient = ingredientRepository.findById(userIngredient.getIngredientId());
            if (optionalIngredient.isPresent()) {
                Ingredient ingredient = optionalIngredient.get();
                LocalDate expirationDate = LocalDate.parse(ingredient.getExpirationDate());
                if (ChronoUnit.DAYS.between(LocalDate.now(), expirationDate) <= 3) {
                    expiringIngredients.add(ingredient);
                }
            }
        }
        return expiringIngredients;
    }
    public Optional<Ingredient> checkUserCreatedIngredient(Long userId, String name) {
        List<UserIngredient> userIngredients = userIngredientRepository.findAllByUserId(userId);
        for (UserIngredient userIngredient : userIngredients) {
            Optional<Ingredient> ingredient = ingredientRepository.findById(userIngredient.getIngredientId());
            if (ingredient.isPresent() && ingredient.get().getName().equalsIgnoreCase(name)) {
                return ingredient;
            }
        }
        return Optional.empty();
    }

}
