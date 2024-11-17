package com.foomyfood.foomyfood.database.db_service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.foomyfood.foomyfood.database.PreferredIngredients;
import com.foomyfood.foomyfood.database.Recipe;
import com.foomyfood.foomyfood.database.db_repository.PreferredIngredientsRepository;
import com.foomyfood.foomyfood.database.db_repository.RecipeRepository;

@Service
public class PreferredIngredientsService {

    @Autowired
    private PreferredIngredientsRepository preferredIngredientsRepository;

    @Autowired
    private RecipeRepository recipeRepository;

    public List<PreferredIngredients> getAllPreferredIngredients() {
        return preferredIngredientsRepository.findAll();
    }

    public List<PreferredIngredients> getPreferredIngredientsByUserId(Long userId) {
        return preferredIngredientsRepository.findByUserId(userId);
    }

    public PreferredIngredients getPreferredIngredientByUserIdAndIngredient(Long userId, String ingredient) {
        return preferredIngredientsRepository.findByUserIdAndIngredient(userId, ingredient);
    }

    public PreferredIngredients addOrUpdatePreferredIngredient(Long userId, String ingredient, int cookingTime) {
        PreferredIngredients existing = preferredIngredientsRepository.findByUserIdAndIngredient(userId, ingredient);
        if (existing != null) {
            existing.setTotalCookingCount(existing.getTotalCookingCount() + cookingTime);
            return preferredIngredientsRepository.save(existing);
        } else {
            PreferredIngredients newEntry = new PreferredIngredients(userId, ingredient, cookingTime);
            return preferredIngredientsRepository.save(newEntry);
        }
    }

    public void deletePreferredIngredient(Long id) {
        preferredIngredientsRepository.deleteById(id);
    }

    public void updatePreferredIngredientsFromRecipes() {
        // Step 1: Fetch all recipes
        List<Recipe> recipes = recipeRepository.findAll();

        // Step 2: Aggregate cooking counts for each user and their ingredients
        Map<Long, Map<String, Integer>> userIngredientCookingMap = new HashMap<>();

        for (Recipe recipe : recipes) {
            Long userId = recipe.getUserId();
            int cookCount = recipe.getCookCount();
            List<String> ingredients = recipe.getIngredientsAsList();

            userIngredientCookingMap.putIfAbsent(userId, new HashMap<>());

            for (String ingredient : ingredients) {
                ingredient = ingredient.trim();
                Map<String, Integer> ingredientCookingMap = userIngredientCookingMap.get(userId);

                ingredientCookingMap.put(ingredient,
                        ingredientCookingMap.getOrDefault(ingredient, 0) + cookCount);
            }
        }

        // Step 3: Update the PreferredIngredients table for each user and ingredient
        for (Map.Entry<Long, Map<String, Integer>> userEntry : userIngredientCookingMap.entrySet()) {
            Long userId = userEntry.getKey();
            Map<String, Integer> ingredientCookingMap = userEntry.getValue();

            for (Map.Entry<String, Integer> entry : ingredientCookingMap.entrySet()) {
                String ingredient = entry.getKey();
                int totalCookingCount = entry.getValue();

                // Check if the ingredient already exists for this user
                PreferredIngredients existing = preferredIngredientsRepository.findByUserIdAndIngredient(userId, ingredient);

                if (existing != null) {
                    // Update total cooking time
                    existing.setTotalCookingCount(totalCookingCount);
                    preferredIngredientsRepository.save(existing);
                } else {
                    // Create a new entry
                    PreferredIngredients newEntry = new PreferredIngredients(userId, ingredient, totalCookingCount);
                    preferredIngredientsRepository.save(newEntry);
                }
            }
        }

    }

    public Map<String, Integer> getPreferredIngredientsWithCookCount(Long userId) {
        // Fetch all preferred ingredients for the user
        List<PreferredIngredients> preferredIngredientsList = preferredIngredientsRepository.findByUserId(userId);

        // Create a map of ingredient names and cooking counts
        Map<String, Integer> preferredIngredientsMap = new HashMap<>();
        for (PreferredIngredients preferredIngredient : preferredIngredientsList) {
            String ingredientName = preferredIngredient.getIngredient();
            int cookingCount = preferredIngredient.getTotalCookingCount();
            preferredIngredientsMap.put(ingredientName, cookingCount);
        }

        return preferredIngredientsMap;
    }

}
