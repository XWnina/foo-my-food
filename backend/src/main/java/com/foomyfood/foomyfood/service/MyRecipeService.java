package com.foomyfood.foomyfood.service;

import com.foomyfood.foomyfood.database.Recipe;
import com.foomyfood.foomyfood.database.db_service.RecipeService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class MyRecipeService {

    @Autowired
    private RecipeService recipeService;

    // 调用原有的 addRecipe 方法
    public Recipe addRecipe(Recipe recipe) {
        return recipeService.addRecipe(recipe);
    }

    // 调用原有的 getAllRecipes 方法
    public List<Recipe> getAllRecipes() {
        return recipeService.getAllRecipes();
    }

}
