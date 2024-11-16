package com.foomyfood.foomyfood.service;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.foomyfood.foomyfood.database.PresetRecipe;
import com.foomyfood.foomyfood.database.Recipe;
import com.foomyfood.foomyfood.database.db_service.PresetRecipeService;
import com.foomyfood.foomyfood.database.db_service.RecipeService;
import com.foomyfood.foomyfood.database.db_service.UserIngredientService;

@Service
public class SmartMenuService {

    @Autowired
    private PresetRecipeService presetRecipeService;

    @Autowired
    private UserIngredientService userIngredientService;

    @Autowired
    private RecipeService recipeService;

    // Methods returning only recipe IDs
    public List<Long> findRecipesByIngredients(Long userId, boolean isPresetSource, boolean useExpirationWeight) {
        List<Map<String, Object>> detailedResults = findRecipesByIngredientsWithDetails(userId, isPresetSource, useExpirationWeight);
        List<Long> recipeIds = new ArrayList<>();
        for (Map<String, Object> recipe : detailedResults) {
            if (!isPresetSource) {
                recipeIds.add((Long) recipe.get("recipeId"));
            }else {
                recipeIds.add((Long) recipe.get("presetRecipeId"));
            }
        }
        return recipeIds;
    }

    public List<Long> findCustomRecipesByUserIngredients(Long userId) {
        return findRecipesByIngredients(userId, false, false);
    }

    public List<Long> findPresetRecipesByUserIngredients(Long userId) {
        return findRecipesByIngredients(userId, true, false);
    }

    public List<Long> findCustomRecipesByExpiringIngredients(Long userId) {
        return findRecipesByIngredients(userId, false, true);
    }

    public List<Long> findPresetRecipesByExpiringIngredients(Long userId) {
        return findRecipesByIngredients(userId, true, true);
    }

    // Methods returning detailed recipe information
    public List<Map<String, Object>> findRecipesByIngredientsWithDetails(Long userId, boolean isPresetSource, boolean useExpirationWeight) {
        Map<String, Double> ingredientWeights;
        Set<String> userIngredients;

        if (useExpirationWeight) {
            ingredientWeights = userIngredientService.getUserIngredientsWithExpirationWeights(userId);
            userIngredients = ingredientWeights.keySet();
        } else {
            ingredientWeights = null;
            userIngredients = userIngredientService.getUserIngredientsByUserId(userId);
        }

        List<List<String>> recipesIngredients;
        List<String> recipesNames;
        List<Long> recipeIds;

        if (isPresetSource) {
            List<PresetRecipe> recipes = presetRecipeService.getAllPresetRecipes();
            recipesIngredients = new ArrayList<>();
            recipesNames = new ArrayList<>();
            recipeIds = new ArrayList<>();
            for (PresetRecipe recipe : recipes) {
                recipesIngredients.add(recipe.getIngredientsAsList());
                recipesNames.add(recipe.getDishName());
                recipeIds.add(recipe.getId());
            }
        } else {
            List<Recipe> recipes = recipeService.getRecipesByUserId(userId);
            recipesIngredients = new ArrayList<>();
            recipesNames = new ArrayList<>();
            recipeIds = new ArrayList<>();
            for (Recipe recipe : recipes) {
                recipesIngredients.add(recipe.getIngredientsAsList());
                recipesNames.add(recipe.getDishName());
                recipeIds.add(recipe.getId());
            }
        }

        List<Map<String, Object>> matchedRecipes = new ArrayList<>();

        for (int i = 0; i < recipesNames.size(); i++) {
            String recipeName = recipesNames.get(i);
            List<String> recipeIngredients = recipesIngredients.get(i);
            Long recipeId = recipeIds.get(i);

            Set<String> matchedIngredients = new HashSet<>();
            double ingredientScore = 0.0;
            int matchedCount = 0;

            for (String currentRecipeIngredient : recipeIngredients) {
                for (String currentUserIngredient : userIngredients) {
                    if (currentRecipeIngredient.trim().equalsIgnoreCase(currentUserIngredient)) {
                        matchedIngredients.add(currentUserIngredient);
                        double weight = getWeight(ingredientWeights, currentUserIngredient, useExpirationWeight);
                        ingredientScore += weight;
                        matchedCount++;
                    }
                }
            }

            if (!matchedIngredients.isEmpty()) {
                Map<String, Object> recipeInfo = new HashMap<>();
                if (isPresetSource) {
                    recipeInfo.put("presetRecipeId", recipeId);
                } else {
                    recipeInfo.put("recipeId", recipeId);
                }
                recipeInfo.put("recipeName", recipeName);
                recipeInfo.put("ingredientScore", Math.round(ingredientScore * 100.0) / 100.0);
                double ingredientPercentage = (double) matchedCount / recipeIngredients.size();
                recipeInfo.put("ingredientPercentage", Math.round(ingredientPercentage * 100.0) / 100.0);
                recipeInfo.put("matchedIngredients", matchedIngredients);
                recipeInfo.put("ingredients", recipeIngredients);
                matchedRecipes.add(recipeInfo);
            }
        }

        matchedRecipes.sort((r1, r2) -> {
            double score1 = (double) r1.get("ingredientScore");
            double score2 = (double) r2.get("ingredientScore");
            int scoreCompare = Double.compare(score2, score1);
            if (scoreCompare != 0) {
                return scoreCompare;
            }
            double percentage1 = (double) r1.get("ingredientPercentage");
            double percentage2 = (double) r2.get("ingredientPercentage");
            return Double.compare(percentage2, percentage1);
        });

        return matchedRecipes;
    }

    public List<Map<String, Object>> findCustomRecipesByUserIngredientsWithDetails(Long userId) {
        return findRecipesByIngredientsWithDetails(userId, false, false);
    }

    public List<Map<String, Object>> findPresetRecipesByUserIngredientsWithDetails(Long userId) {
        return findRecipesByIngredientsWithDetails(userId, true, false);
    }

    public List<Map<String, Object>> findCustomRecipesByExpiringIngredientsWithDetails(Long userId) {
        return findRecipesByIngredientsWithDetails(userId, false, true);
    }

    public List<Map<String, Object>> findPresetRecipesByExpiringIngredientsWithDetails(Long userId) {
        return findRecipesByIngredientsWithDetails(userId, true, true);
    }

    private double getWeight(Map<String, Double> ingredientWeights, String ingredient, Boolean useExpirationWeight) {
        if (useExpirationWeight && ingredientWeights != null) {
            return ingredientWeights.get(ingredient);
        } else {
            return 1.0;
        }
    }

    public List<Map<String, Object>> getDetailedRecipeInfo(Long userId, boolean isPresetSource, boolean useExpiration) {
        List<Map<String, Object>> recipeDetails = findRecipesByIngredientsWithDetails(userId, isPresetSource, useExpiration);

        List<Map<String, Object>> detailedRecipes = recipeDetails.stream().map(recipe -> {
            Long recipeId = (Long) recipe.get("recipeId");
            Long presetRecipeId = (Long) recipe.get("presetRecipeId");
            Map<String, Object> fullRecipeInfo = new HashMap<>(recipe);

            if (isPresetSource) {
                // Fetch full recipe details from PresetRecipe
                PresetRecipe presetRecipe = presetRecipeService.getPresetRecipeByIdAsPresetRecipe(presetRecipeId);
                if (presetRecipe != null) {
                    fullRecipeInfo.put("description", presetRecipe.getDescription());
                    fullRecipeInfo.put("imageUrl", presetRecipe.getImageURL());
                    fullRecipeInfo.put("calories", presetRecipe.getCalories());
                    fullRecipeInfo.put("labels", presetRecipe.getLabels());
                }
            } else {
                // Fetch full recipe details from Recipe
                Recipe userRecipe = recipeService.getRecipeByIdAsRecipe(recipeId);
                if (userRecipe != null) {
                    fullRecipeInfo.put("description", userRecipe.getDescription());
                    fullRecipeInfo.put("imageUrl", userRecipe.getImageURL());
                    fullRecipeInfo.put("calories", userRecipe.getCalories());
                    fullRecipeInfo.put("labels", userRecipe.getLabels());
                }
            }
            return fullRecipeInfo;
        }).collect(Collectors.toList());

        return detailedRecipes;
    }
}
