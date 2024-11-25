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
import org.springframework.transaction.annotation.Transactional;

import com.foomyfood.foomyfood.database.PresetRecipe;
import com.foomyfood.foomyfood.database.Recipe;
import com.foomyfood.foomyfood.database.db_repository.RecipeRepository;
import com.foomyfood.foomyfood.database.db_service.PreferredIngredientsService;
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
    @Autowired
    private RecipeRepository recipeRepository;

    @Autowired
    private PreferredIngredientsService preferredIngredientsService;

    private Map<String, Double> getUserIngredientsWithPreferenceWeights(Long userId) {
        // Fetch preferred ingredients with their cooking counts
        Map<String, Integer> preferredIngredients = preferredIngredientsService.getPreferredIngredientsWithCookCount(userId);
    
        // Create a map to store the final weights
        Map<String, Double> preferredWeights = new HashMap<>();
    
        // Iterate over the preferred ingredients and assign weights based on cooking counts
        for (Map.Entry<String, Integer> entry : preferredIngredients.entrySet()) {
            String ingredient = entry.getKey().toLowerCase(); // Normalize to lowercase for consistency
            int cookCount = entry.getValue();
    
            // Weight is directly the cooking count
            preferredWeights.put(ingredient, (double) cookCount);
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
            // List<PresetRecipe> recipes = presetRecipeService.getAllPresetRecipes();
            List<PresetRecipe> recipes = filterUniquePresetRecipes(userId);
            System.out.println("================================");
            for (int i = 0; i < recipes.size(); i++) {
                System.out.println(i);
                System.out.println(recipes.get(i).getDishName());
            }
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
                    fullRecipeInfo.put("cookCount", Recipe.getCookCount());
                }

                return fullRecipeInfo;
            }).collect(Collectors.toList());
        }

        return detailedRecipes;
    }

    public List<PresetRecipe> filterUniquePresetRecipes(Long userId) {
        List<Recipe> userRecipes = recipeService.getRecipesByUserId(userId);
        List<PresetRecipe> allPresetRecipes = presetRecipeService.getAllPresetRecipes();
        List<PresetRecipe> uniquePresetRecipes = allPresetRecipes;

        for (int i = 0; i < allPresetRecipes.size(); i++) {
            for (int j = 0; j < userRecipes.size(); j++) {
                String currentUserRecipeName = userRecipes.get(j).getDishName();

                String currentPresetRecipeName = allPresetRecipes.get(i).getDishName();
                String currentUserIngredient = userRecipes.get(j).getIngredients();
                String currentPresetRecipeIngredient = allPresetRecipes.get(i).getIngredients();
                String currentUserRecipeDescription = userRecipes.get(j).getDescription();
                String currentPresetRecipeDescription = allPresetRecipes.get(i).getDescription();

                // System.out.println("Current user recipe name: " + currentUserRecipeName);
                // System.out.println("Current preset recipe name: " + currentPresetRecipeName);
                // System.out.println("Current user recipe ingredient: " + currentUserIngredient);
                // System.out.println("Current preset recipe ingredient: " + currentPresetRecipeIngredient);
                // System.out.println("Current user recipe description: " + currentUserRecipeDescription);
                // System.out.println("Current preset recipe description: " + currentPresetRecipeDescription);
                // System.out.println("================================");
                // System.out.println("================================");
                // If the user recipe's name is null, set it to an empty string
                if (currentUserRecipeDescription == null) {
                    currentUserRecipeDescription = "";
                }
                // If one of the user recipe's name, description, and ingredients dismatch the preset recipe's name, description, and ingredients, add the preset recipe to the list of unique preset recipes
                // if (!(currentUserRecipeName.equals(currentPresetRecipeName)
                //         && currentUserRecipeDescription.equals(currentPresetRecipeDescription)
                //         && currentUserIngredient.equals(currentPresetRecipeIngredient))) {
                //     uniquePresetRecipes.add(allPresetRecipes.get(i));
                //     System.out.println("!!!!!!!!!!!!!!!!!!!!Added preset recipe to unique preset recipes!!!!!!!!!!!!!!!!!!!!");
                //     System.out.println("Current preset recipe name: " + currentPresetRecipeName);
                //     break;
                // }

                if (!currentUserRecipeName.equals(currentPresetRecipeName)) {
                    // System.out.println("NAME MISMATCH");
                    // System.out.println("Current user recipe name: " + currentUserRecipeName);
                    break;
                } else if (!currentUserIngredient.equals(currentPresetRecipeIngredient)) {
                    // System.out.println("INGREDIENT MISMATCH");
                    // System.out.println("Current user recipe name: " + currentUserRecipeName);
                    break;
                } else if (!currentUserRecipeDescription.equals(currentPresetRecipeDescription)) {
                    // System.out.println("DESCRIPTION MISMATCH");
                    // System.out.println("Current user recipe name: " + currentUserRecipeName);
                    break;
                } else {
                    // System.out.println("ALL MATCH DELETE FROM LIST");
                    // uniquePresetRecipes.remove(allPresetRecipes.get(i));
                    break;
                }
            }

        }
        // System.out.println("+++++++++++++++++++++++++++++++");
        // for (int i = 0; i < uniquePresetRecipes.size(); i++) {
        //     System.out.println(i);
        //     System.out.println(uniquePresetRecipes.get(i).getDishName());
        //     System.out.println(uniquePresetRecipes.get(i).getIngredients());
        // }
        return uniquePresetRecipes;
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
