package com.foomyfood.foomyfood.service;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Set;

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

    public List<PresetRecipe> filterUserRecipesFromPresetRecipes(Long userId) {
        List<PresetRecipe> presetRecipes = presetRecipeService.getAllPresetRecipes();
        List<Recipe> userRecipes = recipeService.getRecipesByUserId(userId);

        // User recipes are compared with preset recipes
        Iterator<PresetRecipe> presetIterator = presetRecipes.iterator();

        while (presetIterator.hasNext()) {
            PresetRecipe presetRecipe = presetIterator.next();
            for (Recipe userRecipe : userRecipes) {
                // if the dish name and ingredients are the same, remove the item from the preset recipe list
                if (presetRecipe.getDishName().equalsIgnoreCase(userRecipe.getDishName())
                        && presetRecipe.getIngredientsAsList().containsAll(userRecipe.getIngredientsAsList())
                        && userRecipe.getIngredientsAsList().containsAll(presetRecipe.getIngredientsAsList())) {
                    presetIterator.remove();
                    break;
                }
            }
        }

        return presetRecipes;
    }

    public List<Map<String, Object>> findRecipesByIngredients(Long userId, boolean isPresetSource, boolean useExpirationWeight) {
        // If useExpirationWeight is true, get the user ingredients with expiration weights
        Map<String, Double> ingredientWeights;
        Set<String> userIngredients;

        if (useExpirationWeight) {
            ingredientWeights = userIngredientService.getUserIngredientsWithExpirationWeights(userId);
            userIngredients = ingredientWeights.keySet();
        } else {
            ingredientWeights = null;
            userIngredients = userIngredientService.getUserIngredientsByUserId(userId);
        }

        // Get the recipes and their ingredients
        List<List<String>> recipesIngredients; // List of recipes ingredients
        List<String> recipesNames;  // List of recipes names

        if (isPresetSource) {
            List<PresetRecipe> recipes = presetRecipeService.getAllPresetRecipes();
            recipesIngredients = new ArrayList<>();
            recipesNames = new ArrayList<>();
            for (PresetRecipe recipe : recipes) {
                recipesIngredients.add(recipe.getIngredientsAsList());
                recipesNames.add(recipe.getDishName());
            }
        } else {
            List<Recipe> recipes = recipeService.getRecipesByUserId(userId);
            recipesIngredients = new ArrayList<>();
            recipesNames = new ArrayList<>();
            for (Recipe recipe : recipes) {
                recipesIngredients.add(recipe.getIngredientsAsList());
                recipesNames.add(recipe.getDishName());
            }
        }

        List<Map<String, Object>> matchedRecipes = new ArrayList<>();

        // Iterate over each recipe
        for (int i = 0; i < recipesNames.size(); i++) {
            String recipeName = recipesNames.get(i);
            List<String> recipeIngredients = recipesIngredients.get(i);

            Set<String> matchedIngredients = new HashSet<>();  // Store matched ingredients for the current recipe
            double ingredientScore = 0.0;
            int matchedCount = 0;
            // System.out.println("Current Recipe: " + recipeName);
            // System.out.println("Current Recipe Ingredients: " + recipeIngredients);
            // Iterate over each ingredient in the recipe
            for (int j = 0; j < recipeIngredients.size(); j++) {
                // Check if the user has this ingredient
                String currentRecipeIngredient = recipeIngredients.get(j);
                // System.out.println("==================================");
                // System.out.println("Checking for ingredient: " + currentRecipeIngredient);
                for (int k = 0; k < userIngredients.size(); k++) {
                    String currentUserIngredient = userIngredients.toArray()[k].toString();
                    // System.out.println("Checking against user ingredient: " + currentUserIngredient);
                    if (currentRecipeIngredient.trim().equalsIgnoreCase(currentUserIngredient)) {
                        // System.out.println("!!!!!!Match found!");
                        matchedIngredients.add(currentUserIngredient);
                        // Calculate the ingredient score
                        double weight = getWeight(ingredientWeights, currentUserIngredient, useExpirationWeight);
                        // System.out.print("The matched ingredient is: " + currentUserIngredient);
                        // System.out.println(" with weight: " + weight);
                        ingredientScore += weight;
                        // System.out.println("Current ingredient score: " + ingredientScore);
                        matchedCount++;
                        // System.out.println("Current matched count: " + matchedCount);
                    }
                }
            }

            // Only add the recipe if it has at least one matched ingredient
            if (!matchedIngredients.isEmpty()) {

                Map<String, Object> recipeInfo = new HashMap<>();
                recipeInfo.put("recipeName", recipeName);
                recipeInfo.put("ingredientScore", Math.round(ingredientScore * 100.0) / 100.0);
                if (ingredientScore == 0.0) {
                    recipeInfo.put("ingredientPercentage", 0.0);
                } else {
                    double ingredientPercentage = (double) matchedCount / recipeIngredients.size();
                    recipeInfo.put("ingredientPercentage", Math.round(ingredientPercentage * 100.0) / 100.0);
                }
                recipeInfo.put("matchedIngredients", matchedIngredients);
                recipeInfo.put("ingredients", recipeIngredients);
                matchedRecipes.add(recipeInfo);
            }
        }
        // System.out.println("+---------------------------------+");

        // Sort the matched recipes by ingredient score, then by ingredient percentage
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

    // Matching recipes from user recipe, by ingredients in the inventory
    public List<Map<String, Object>> findCustomRecipesByUserIngredients(Long userId) {
        return findRecipesByIngredients(userId, false, false);
    }

    // Matching recipes from preset recipe, by ingredients in the inventory
    public List<Map<String, Object>> findPresetRecipesByUserIngredients(Long userId) {
        return findRecipesByIngredients(userId, true, false);
    }

    // Matching recipes from user recipe, by expiring ingredients
    public List<Map<String, Object>> findCustomRecipesByExpiringIngredients(Long userId) {
        return findRecipesByIngredients(userId, false, true);
    }

    // Matching recipes from preset recipe, by expiring ingredients
    public List<Map<String, Object>> findPresetRecipesByExpiringIngredients(Long userId) {
        return findRecipesByIngredients(userId, true, true);
    }

    private double getWeight(Map<String, Double> ingredientWeights, String ingredient, Boolean useExpirationWeight) {
        if (useExpirationWeight) {
            return ingredientWeights.get(ingredient);
        } else {
            return 1.0;
        }
    }
}
