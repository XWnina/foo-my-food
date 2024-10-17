package com.foomyfood.foomyfood.database.testing;

import java.util.Arrays;
import java.util.List;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;

import com.foomyfood.foomyfood.database.Recipe;
import com.foomyfood.foomyfood.database.db_service.RecipeService;

@Component
public class RecipeTester implements CommandLineRunner {

    @Autowired
    private RecipeService recipeService;

    @Override
    public void run(String... args) throws Exception {
        // Test recipe creation with different scenarios
        System.out.println("\n--- Testing Recipe Creation ---");
        createTestRecipes();

        // Test retrieving all recipes
        System.out.println("\n--- Testing Retrieving All Recipes ---");
        getAllRecipes();

        // Test retrieving a specific recipe by ID
        System.out.println("\n--- Testing Retrieving Recipe by ID ---");
        getRecipeById(1L); // Assuming ID 1 exists

        // Test updating a recipe
        System.out.println("\n--- Testing Recipe Update ---");
        updateRecipe(1L);  // Assuming ID 1 exists

        // Test retrieving updated recipe by ID
        System.out.println("\n--- Testing Retrieving Updated Recipe by ID ---");
        getRecipeById(1L);  // Assuming ID 1 exists

        // Test deleting a recipe
        System.out.println("\n--- Testing Recipe Deletion ---");
        deleteRecipe(2L);  // Assuming ID 2 exists

        // Test deleting a non-existent recipe
        System.out.println("\n--- Testing Deleting Non-Existent Recipe ---");
        deleteRecipe(999L);  // Assuming ID 999 doesn't exist

        // Test retrieving all recipes after deletion
        System.out.println("\n--- Testing Retrieving All Recipes After Deletion ---");
        getAllRecipes();
    }

    // Create test recipes with different scenarios
    private void createTestRecipes() {
        // Valid recipes with all fields filled
        Recipe recipe1 = recipeService.addRecipe(new Recipe("Full Recipe", 500, "full-recipe-video.com", "full-recipe.jpg", "Complete recipe",
                Arrays.asList("Ingredient1", "Ingredient2")));

        // Recipe without optional fields
        Recipe recipe2 = recipeService.addRecipe(new Recipe("Minimal Recipe", null, null, null, null,
                Arrays.asList("Ingredient1")));

        // Recipe with only dishName and ingredients (calories defaults to -1, others default to "N/A")
        Recipe recipe3 = recipeService.addRecipe(new Recipe("Simple Recipe", null, null, null, null,
                Arrays.asList("Simple Ingredient1", "Simple Ingredient2")));

        // Print created recipes
        System.out.println("Created Recipes:");
        System.out.println(recipe1);
        System.out.println(recipe2);
        System.out.println(recipe3);
    }

    // Retrieve all recipes
    private void getAllRecipes() {
        List<Recipe> recipes = recipeService.getAllRecipes();
        if (recipes.isEmpty()) {
            System.out.println("No recipes found.");
        } else {
            System.out.println("All Recipes:");
            recipes.forEach(System.out::println);
        }
    }

    // Retrieve a recipe by ID
    private void getRecipeById(Long recipeId) {
        Optional<Recipe> recipe = recipeService.getRecipeById(recipeId);
        if (recipe.isPresent()) {
            System.out.println("Found Recipe: " + recipe.get());
        } else {
            System.out.println("No recipe found with ID: " + recipeId);
        }
    }

    // Update a recipe
    private void updateRecipe(Long recipeId) {
        Recipe updatedRecipe = recipeService.editRecipe(recipeId, new Recipe("Updated Recipe", 600, "updated-recipe-video.com",
                "updated-recipe.jpg", "Updated recipe description",
                Arrays.asList("Updated Ingredient1", "Updated Ingredient2")));
        System.out.println("Updated Recipe: " + updatedRecipe);
    }

    // Delete a recipe
    private void deleteRecipe(Long recipeId) {
        try {
            recipeService.deleteRecipe(recipeId);
            System.out.println("Recipe with ID " + recipeId + " successfully deleted!");
        } catch (RuntimeException e) {
            System.out.println(e.getMessage());
        }
    }
}
