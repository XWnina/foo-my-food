package com.foomyfood.foomyfood.database.db_service;

import java.time.LocalDate;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.Set;

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

    // Get all user ingredients
    public List<UserIngredient> getAllUserIngredients(Long userId) {
        return userIngredientRepository.findAllByUserId(userId);
    }

    // Get user ingredient by user ID and ingredient ID
    public Optional<UserIngredient> getUserIngredient(Long userId, Long ingredientId) {
        return userIngredientRepository.findByUserIdAndIngredientId(userId, ingredientId);
    }

    // Create user ingredient
    public UserIngredient createUserIngredient(Long userId, Long ingredientId, int userQuantity) {
        UserIngredient userIngredient = new UserIngredient(userId, ingredientId, userQuantity);
        return userIngredientRepository.save(userIngredient);
    }

    // Update user ingredient
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

    // Delete user ingredient
    public void deleteUserIngredient(Long userId, Long ingredientId) {
        Optional<UserIngredient> optionalUserIngredient = userIngredientRepository.findByUserIdAndIngredientId(userId, ingredientId);
        optionalUserIngredient.ifPresent(userIngredientRepository::delete);
    }

    // Get user ingredients details
    public List<List<Object>> getUserIngredientsDetails(Long userId) {
        List<UserIngredient> userIngredients = userIngredientRepository.findAllByUserId(userId);
        List<Ingredient> ingredients = ingredientRepository.findAll();

        List<List<Object>> ingredientDetailsList = new ArrayList<>();

        for (Ingredient ingredient : ingredients) {
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
            ingredientDetailsList.add(ingredientDetails);
        }

        return ingredientDetailsList;
    }

    // Get user expiring ingredients by user ID
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

    // Check if user created ingredient exists by user ID and ingredient name
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

    // Get user ingredients by user ID
    public Set<String> getUserIngredientsByUserId(Long userId) {
        List<UserIngredient> userIngredients = userIngredientRepository.findAllByUserId(userId);
        Set<String> ingredientNames = new HashSet<>();

        for (UserIngredient userIngredient : userIngredients) {
            Optional<Ingredient> optionalIngredient = ingredientRepository.findById(userIngredient.getIngredientId());
            optionalIngredient.ifPresent(ingredient -> ingredientNames.add(ingredient.getName().toLowerCase())); // 转换为小写
        }
        return ingredientNames;
    }

    // Get user ingredients with expiration weights by user ID
    public Map<String, Double> getUserIngredientsWithExpirationWeights(Long userId) {
        List<UserIngredient> userIngredients = userIngredientRepository.findAllByUserId(userId);
        Map<String, Double> ingredientWeights = new HashMap<>();

        for (UserIngredient userIngredient : userIngredients) {
            Optional<Ingredient> optionalIngredient = ingredientRepository.findById(userIngredient.getIngredientId());
            if (optionalIngredient.isPresent()) {
                Ingredient ingredient = optionalIngredient.get();
                LocalDate expirationDate = LocalDate.parse(ingredient.getExpirationDate());
                long daysUntilExpiration = ChronoUnit.DAYS.between(LocalDate.now(), expirationDate);

                double weight;
                if (daysUntilExpiration <= 0) {
                    weight = 2.0; // Expired
                } else if (daysUntilExpiration <= 3) {
                    weight = 1.7; // Expire in 3 days
                } else if (daysUntilExpiration <= 5) {
                    weight = 1.5; // Expire in 5 days
                } else if (daysUntilExpiration <= 7) {
                    weight = 1.2; // Expire in 7 days
                } else {
                    weight = 1.0; // Rest
                }

                ingredientWeights.put(ingredient.getName().toLowerCase(), weight);
            }
        }

        return ingredientWeights;
    }
}
