package com.foomyfood.foomyfood.service;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;

import com.foomyfood.foomyfood.database.db_repository.RecipeRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.foomyfood.foomyfood.database.PresetRecipe;
import com.foomyfood.foomyfood.database.Recipe;
import com.foomyfood.foomyfood.database.db_service.PreferredIngredientsService;
import com.foomyfood.foomyfood.database.db_service.PresetRecipeService;
import com.foomyfood.foomyfood.database.db_service.RecipeService;
import com.foomyfood.foomyfood.database.db_service.UserIngredientService;
import org.springframework.transaction.annotation.Transactional;

@Service
public class SmartMenuService {

    @Autowired
    private PresetRecipeService presetRecipeService;

    @Autowired
    private UserIngredientService userIngredientService;

    @Autowired
    private RecipeService recipeService;
    @Autowired
    private RecipeRepository recipeRepository;

    @Autowired
    private PreferredIngredientsService preferredIngredientsService;

    private Map<String, Double> getUserIngredientsWithPreferenceWeights(Long userId) {
        // Fetch preferred ingredients with their cooking counts
        Map<String, Integer> preferredIngredients = preferredIngredientsService.getPreferredIngredientsWithCookCount(userId);

        // Sort preferred ingredients by cooking frequency in descending order
        List<Map.Entry<String, Integer>> sortedPreferredIngredients = preferredIngredients.entrySet().stream()
                .sorted((e1, e2) -> e2.getValue().compareTo(e1.getValue())) // Descending order of frequency
                .collect(Collectors.toList());

        // Assign weights inversely proportional to rank of ingredient
        Map<String, Double> preferredWeights = new HashMap<>();
        for (int i = 0; i < sortedPreferredIngredients.size(); i++) {
            Map.Entry<String, Integer> entry = sortedPreferredIngredients.get(i);
            String ingredient = entry.getKey();
            double weight = 1.0 / (i + 1); // Weight decreases as rank increases
            preferredWeights.put(ingredient.toLowerCase(), weight); // Normalize to lowercase for consistency
            // System.out.println("Ingredient: " + ingredient + ", Rank: " + (i + 1) + ", Weight: " + weight);

        }
        return preferredWeights;
    }

    private double getWeight(Map<String, Double> ingredientWeights, String ingredient, Boolean useExpirationWeight) {
        double weight = ingredientWeights != null ? ingredientWeights.getOrDefault(ingredient.toLowerCase(), 0.0) : 1.0;
        System.out.println("Ingredient: " + ingredient + ", Weight: " + weight);
        return weight;
    }

    // Methods returning detailed recipe information
    public List<Map<String, Object>> findRecipesByIngredientsWithDetails(Long userId, boolean isPresetSource, boolean useExpirationWeight, boolean usePreferenceWeight) {
        Map<String, Double> ingredientWeights;
        Set<String> userIngredients;

        if (useExpirationWeight) {
            ingredientWeights = userIngredientService.getUserIngredientsWithExpirationWeights(userId);
            userIngredients = ingredientWeights.keySet();
        } else if (usePreferenceWeight) {
            ingredientWeights = getUserIngredientsWithPreferenceWeights(userId);
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
        return findRecipesByIngredientsWithDetails(userId, false, false, false);
    }

    public List<Map<String, Object>> findPresetRecipesByUserIngredientsWithDetails(Long userId) {
        return findRecipesByIngredientsWithDetails(userId, true, false, false);
    }

    public List<Map<String, Object>> findCustomRecipesByExpiringIngredientsWithDetails(Long userId) {
        return findRecipesByIngredientsWithDetails(userId, false, true, false);
    }

    public List<Map<String, Object>> findPresetRecipesByExpiringIngredientsWithDetails(Long userId) {
        return findRecipesByIngredientsWithDetails(userId, true, true, false);
    }

    public List<Map<String, Object>> findCustomRecipesByPreferredIngredientsWithDetails(Long userId) {
        return findRecipesByIngredientsWithDetails(userId, false, false, true);
    }

    public List<Map<String, Object>> findPresetRecipesByPreferredIngredientsWithDetails(Long userId) {
        return findRecipesByIngredientsWithDetails(userId, true, false, true);
    }

    // Methods returning only recipe IDs
    public List<Long> findRecipesByIngredients(Long userId, boolean isPresetSource, boolean useExpirationWeight, boolean usePreferenceWeight) {
        List<Map<String, Object>> detailedResults = findRecipesByIngredientsWithDetails(userId, isPresetSource, useExpirationWeight, usePreferenceWeight);
        List<Long> recipeIds = new ArrayList<>();
        for (Map<String, Object> recipe : detailedResults) {
            if (!isPresetSource) {
                recipeIds.add((Long) recipe.get("recipeId"));
            } else {
                recipeIds.add((Long) recipe.get("presetRecipeId"));
            }
        }
        return recipeIds;
    }

    public List<Long> findCustomRecipesByUserIngredients(Long userId) {
        return findRecipesByIngredients(userId, false, false, false);
    }

    public List<Long> findPresetRecipesByUserIngredients(Long userId) {
        return findRecipesByIngredients(userId, true, false, false);
    }

    public List<Long> findCustomRecipesByExpiringIngredients(Long userId) {
        return findRecipesByIngredients(userId, false, true, false);
    }

    public List<Long> findPresetRecipesByExpiringIngredients(Long userId) {
        return findRecipesByIngredients(userId, true, true, false);
    }

    public List<Long> findCustomRecipesWithPreferenceWeights(Long userId) {
        return findRecipesByIngredients(userId, false, false, true);
    }

    public List<Long> findPresetRecipesWithPreferenceWeights(Long userId) {
        return findRecipesByIngredients(userId, true, false, true);
    }

    // Method returning detailed recipe information
    public List<Map<String, Object>> getDetailedRecipeInfo(Long userId, boolean isPresetSource, boolean useExpiration, boolean usePreference) {
        List<Map<String, Object>> recipeDetails = findRecipesByIngredientsWithDetails(userId, isPresetSource, useExpiration, usePreference);
        List<Map<String, Object>> detailedRecipes = new ArrayList<>();
        if (isPresetSource) {
            detailedRecipes = recipeDetails.stream().map(recipe -> {
                Long presetRecipeId = (Long) recipe.get("presetRecipeId");
                Map<String, Object> fullRecipeInfo = new HashMap<>(recipe);

                // Fetch full recipe details from PresetRecipe
                PresetRecipe presetRecipe = presetRecipeService.getPresetRecipeByIdAsPresetRecipe(presetRecipeId);
                if (presetRecipe != null) {
                    fullRecipeInfo.put("description", presetRecipe.getDescription());
                    fullRecipeInfo.put("imageUrl", presetRecipe.getImageURL());
                    fullRecipeInfo.put("calories", presetRecipe.getCalories());
                    fullRecipeInfo.put("labels", presetRecipe.getLabels());
                }

                return fullRecipeInfo;
            }).collect(Collectors.toList());
        } else {
            detailedRecipes = recipeDetails.stream().map(recipe -> {
                Long recipeId = (Long) recipe.get("recipeId");
                Map<String, Object> fullRecipeInfo = new HashMap<>(recipe);

                Recipe Recipe = recipeService.getRecipeByIdAsRecipe(recipeId);
                if (Recipe != null) {
                    fullRecipeInfo.put("description", Recipe.getDescription());
                    fullRecipeInfo.put("imageUrl", Recipe.getImageURL());
                    fullRecipeInfo.put("calories", Recipe.getCalories());
                    fullRecipeInfo.put("labels", Recipe.getLabels());
                }

                return fullRecipeInfo;
            }).collect(Collectors.toList());
        }

        return detailedRecipes;
    }
    @Transactional
    public Recipe copyPresetRecipe(Long userId, Long presetRecipeId) {
        PresetRecipe presetRecipe = presetRecipeService.getPresetRecipeByIdAsPresetRecipe(presetRecipeId);
        Recipe copiedRecipe = new Recipe();
        copiedRecipe.setDishName(presetRecipe.getDishName());
        copiedRecipe.setCalories(presetRecipe.getCalories());
        copiedRecipe.setVideoLink(presetRecipe.getVideoLink());
        copiedRecipe.setImageURL(presetRecipe.getImageURL());
        copiedRecipe.setDescription(presetRecipe.getDescription());
        copiedRecipe.setIngredients(presetRecipe.getIngredients());
        copiedRecipe.setLabels(presetRecipe.getLabels());
        copiedRecipe.setUserId(userId);
        copiedRecipe.setCookCount(0);
        return recipeRepository.save(copiedRecipe);
    }

}
