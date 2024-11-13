package com.foomyfood.foomyfood.service;

import java.util.ArrayList;
import java.util.HashMap;
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

    // Matching recipes by ingredients, with the option to search from preset recipe table or the user's recipes and option to use expiration weight
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

        List<Map<String, Object>> matchedRecipes = new ArrayList<>();

        // Get the recipes and their ingredients
        List<List<String>> recipesIngredients;
        List<String> recipesNames;

        if (isPresetSource) {
            // If the source is preset recipes, get the preset recipes and their ingredients
            List<PresetRecipe> recipes = presetRecipeService.getAllPresetRecipes();
            recipesIngredients = new ArrayList<>();
            recipesNames = new ArrayList<>();
            for (PresetRecipe recipe : recipes) {
                recipesIngredients.add(recipe.getIngredientsAsList());
                recipesNames.add(recipe.getDishName());
            }
        } else {
            // Else, get the user recipes and their ingredients
            List<Recipe> recipes = recipeService.getRecipesByUserId(userId);
            recipesIngredients = new ArrayList<>();
            recipesNames = new ArrayList<>();
            for (Recipe recipe : recipes) {
                recipesIngredients.add(recipe.getIngredientsAsList());
                recipesNames.add(recipe.getDishName());
            }
        }

        // Calculate the ingredient score and percentage for each recipe for sorting
        for (int i = 0; i < recipesIngredients.size(); i++) {
            List<String> recipeIngredients = recipesIngredients.get(i);
            String recipeName = recipesNames.get(i);

            double ingredientScore = 0.0;
            int matchedCount = 0;
            List<String> matchedIngredients = new ArrayList<>();

            for (String ingredient : recipeIngredients) {
                String lowerIngredient = ingredient.toLowerCase();
                if (userIngredients.contains(lowerIngredient)) {
                    double weight = (ingredientWeights != null && ingredientWeights.containsKey(lowerIngredient))
                            ? ingredientWeights.get(lowerIngredient)
                            : 1.0;
                    ingredientScore += weight;
                    matchedCount++;
                    matchedIngredients.add(ingredient);
                }
            }

            // If the recipe has at least one matched ingredient, calculate the percentage
            if (ingredientScore > 0) {
                double ingredientPercentage = (double) matchedCount / recipeIngredients.size();

                Map<String, Object> recipeInfo = new HashMap<>();
                recipeInfo.put("recipeName", recipeName);
                recipeInfo.put("ingredientScore", Math.round(ingredientScore * 100.0) / 100.0); 
                recipeInfo.put("ingredientPercentage", Math.round(ingredientPercentage * 100.0) / 100.0); 
                recipeInfo.put("matchedIngredients", matchedIngredients);
                recipeInfo.put("ingredients", recipeIngredients);
                matchedRecipes.add(recipeInfo);
            }
        }

        // Sort the matched recipes, first by ingredient score, then by ingredient percentage
        matchedRecipes.sort((r1, r2) -> {
            double score1 = (double) r1.get("ingredientScore");
            double score2 = (double) r2.get("ingredientScore");
            int scoreCompare = Double.compare(score2, score1); 
            if (scoreCompare != 0) {
                return scoreCompare;
            }
            double percentage1 = (double) r1.get("ingredientPercentage");
            double percentage2 = (double) r2.get("ingredientPercentage");
            // if the ingredient score is the same, sort by ingredient percentage
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
}
