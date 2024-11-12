package com.foomyfood.foomyfood.database.testing;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;

import com.foomyfood.foomyfood.database.RecipeCollection;
import com.foomyfood.foomyfood.database.db_service.RecipeCollectionService;

//@Component
public class RecipeCollectionTester implements CommandLineRunner {

    @Autowired
    private RecipeCollectionService recipeCollectionService;

    @Override
    public void run(String... args) throws Exception {
        Long userId = 5L;
        Long recipeId = 5L;
        Long presetRecipeId = null;

        System.out.println("\n--- Testing Save Recipe ---");
        testSaveRecipe(userId, recipeId, presetRecipeId);

        System.out.println("\n--- Testing Duplicate Save ---");
        testDuplicateSave(userId, recipeId, presetRecipeId);

        System.out.println("\n--- Testing Get Recipes By User ID ---");
        testGetRecipesByUserId(userId);

        System.out.println("\n--- Testing Delete Recipe ---");
        testDeleteRecipe(userId, recipeId, presetRecipeId);

        userId = 5L;
        recipeId = null;
        presetRecipeId = 5L;

        testSaveRecipe(userId, recipeId, presetRecipeId);
    }

    private void testSaveRecipe(Long userId, Long recipeId, Long presetRecipeId) {
        RecipeCollection recipe = new RecipeCollection(userId, recipeId, presetRecipeId);
        RecipeCollection savedRecipe = recipeCollectionService.saveRecipe(recipe);
        System.out.println("Saved Recipe: " + savedRecipe);
    }

    private void testDuplicateSave(Long userId, Long recipeId, Long presetRecipeId) {
        RecipeCollection duplicateRecipe = new RecipeCollection(userId, recipeId, presetRecipeId);
        try {
            RecipeCollection savedDuplicate = recipeCollectionService.saveRecipe(duplicateRecipe);
            System.out.println("Duplicate Recipe Saved (unexpected): " + savedDuplicate);
        } catch (Exception e) {
            System.out.println("Duplicate Recipe Save Failed (expected): " + e.getMessage());
        }
    }

    private void testGetRecipesByUserId(Long userId) {
        List<RecipeCollection> recipes = recipeCollectionService.getRecipesByUserId(userId);
        if (recipes.isEmpty()) {
            System.out.println("No recipes found for User ID: " + userId);
        } else {
            recipes.forEach(recipe -> System.out.println("Recipe for User ID " + userId + ": " + recipe));
        }
    }

    private void testDeleteRecipe(Long userId, Long recipeId, Long presetRecipeId) {
        recipeCollectionService.deleteRecipe(userId, recipeId, presetRecipeId);
        System.out.println("Deleted Recipe for User ID: " + userId + ", Recipe ID: " + recipeId + ", Preset Recipe ID: " + presetRecipeId);
    }
}
