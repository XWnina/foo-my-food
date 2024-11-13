package com.foomyfood.foomyfood.service;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.foomyfood.foomyfood.database.PresetRecipe;
import com.foomyfood.foomyfood.database.db_service.PresetRecipeService;

@Service
public class SmartMenuService {

    @Autowired
    private PresetRecipeService presetRecipeService;

    public List<Map<String, Object>> findRecipesByIngredient(String ingredient) {
        List<PresetRecipe> recipes = presetRecipeService.getAllPresetRecipes();
        List<Map<String, Object>> matchedRecipes = new ArrayList<>();
        
        String lowerCaseIngredient = ingredient.toLowerCase();

        for (PresetRecipe recipe : recipes) {
            List<String> ingredientsList = recipe.getIngredientsAsList();
            
            // Check if the ingredient is in the list of ingredients
            if (ingredientsList.stream().anyMatch(i -> i.toLowerCase().equals(lowerCaseIngredient))) {
                Map<String, Object> recipeInfo = new HashMap<>();
                recipeInfo.put("recipeName", recipe.getDishName());
                recipeInfo.put("ingredients", ingredientsList);
                matchedRecipes.add(recipeInfo);
            }
        }

        return matchedRecipes;
    }
}
