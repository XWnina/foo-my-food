package com.foomyfood.foomyfood.database.testing;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;

import com.foomyfood.foomyfood.database.PreferredIngredients;
import com.foomyfood.foomyfood.database.db_service.PreferredIngredientsService;

// @Component
public class PreferredIngredientTester implements CommandLineRunner {

    @Autowired
    private PreferredIngredientsService preferredIngredientsService;

    @Override
    public void run(String... args) throws Exception {
        // Test creating and updating preferred ingredients
        System.out.println("\n--- Testing Preferred Ingredients Creation/Update ---");
        testAddOrUpdatePreferredIngredients();

        // Test retrieving all preferred ingredients
        System.out.println("\n--- Testing Retrieving All Preferred Ingredients ---");
        getAllPreferredIngredients();

        // Test retrieving preferred ingredients by user ID
        System.out.println("\n--- Testing Retrieving Preferred Ingredients by User ID ---");
        getPreferredIngredientsByUserId(21L);

        // Test updating the table from recipes
        System.out.println("\n--- Testing Updating Preferred Ingredients from Recipes ---");
        updateFromRecipes();

        // Test retrieving all preferred ingredients after update
        System.out.println("\n--- Retrieving All Preferred Ingredients After Update ---");
        getAllPreferredIngredients();
    }

    // Function to add or update preferred ingredients
    private void testAddOrUpdatePreferredIngredients() {
        // preferredIngredientsService.addOrUpdatePreferredIngredient(21L, "Tomato", 30);
        // preferredIngredientsService.addOrUpdatePreferredIngredient(21L, "Cucumber", 15);
        // preferredIngredientsService.addOrUpdatePreferredIngredient(21L, "Tomato", 20); // Should update total time to 50
        // preferredIngredientsService.addOrUpdatePreferredIngredient(22L, "Apple", 40);
        // System.out.println("Test preferred ingredients created/updated successfully!");
    }

    // Function to retrieve all preferred ingredients
    private void getAllPreferredIngredients() {
        List<PreferredIngredients> preferredIngredients = preferredIngredientsService.getAllPreferredIngredients();
        if (preferredIngredients.isEmpty()) {
            System.out.println("No preferred ingredients found.");
        } else {
            preferredIngredients.forEach(preferredIngredient -> System.out.println(preferredIngredient));
        }
    }

    // Function to retrieve preferred ingredients by user ID
    private void getPreferredIngredientsByUserId(Long userId) {
        List<PreferredIngredients> preferredIngredients = preferredIngredientsService.getPreferredIngredientsByUserId(userId);
        if (preferredIngredients.isEmpty()) {
            System.out.println("No preferred ingredients found for user ID: " + userId);
        } else {
            preferredIngredients.forEach(preferredIngredient -> System.out.println(preferredIngredient));
        }
    }

    // Function to update preferred ingredients table from recipes
    private void updateFromRecipes() {
        preferredIngredientsService.updatePreferredIngredientsFromRecipes();
        System.out.println("Preferred ingredients updated from recipes successfully!");
    }
}
