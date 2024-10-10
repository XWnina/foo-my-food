package com.foomyfood.foomyfood.database.testing;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;
import com.foomyfood.foomyfood.database.Ingredient;
import com.foomyfood.foomyfood.database.db_service.IngredientService;

import java.util.List;
import java.util.Optional;

// @Component
public class IngredientTester implements CommandLineRunner {

    @Autowired
    private IngredientService ingredientService;

    @Override
    public void run(String... args) throws Exception {
        // Test creating ingredients
        System.out.println("\n--- Testing Ingredient Creation ---");
        createTestIngredients();

        // Test retrieving all ingredients
        System.out.println("\n--- Testing Retrieving All Ingredients ---");
        getAllIngredients();

        // Test retrieving a specific ingredient by ID
        System.out.println("\n--- Testing Retrieving Ingredient by ID ---");
        getIngredientById(1L);

        // Test updating an ingredient
        System.out.println("\n--- Testing Ingredient Update ---");
        updateIngredient(1L);

        // Test retrieving updated ingredient by ID
        System.out.println("\n--- Testing Retrieving Updated Ingredient by ID ---");
        getIngredientById(1L);

        // Test deleting an ingredient
        System.out.println("\n--- Testing Ingredient Deletion ---");
        deleteIngredient(2L);

        // Test retrieving all ingredients after deletion
        System.out.println("\n--- Retrieving All Ingredients After Deletion ---");
        getAllIngredients();
    }

    // Function to create test ingredients
    private void createTestIngredients() {
        ingredientService.createIngredient("Tomato", "Vegetable", "tomato.jpg", "Refrigerate", 100, "kg",
                "2024-10-20", false, 21L, 20, 1.0f, 0.5f, 3.0f, 0.2f);
        ingredientService.createIngredient("Cucumber", "Vegetable", "cucumber.jpg", "Refrigerate", 50, "kg",
                "2024-10-15", false, 21L, 15, 0.8f, 0.3f, 2.5f, 0.4f);
        ingredientService.createIngredient("Apple", "Fruit", "apple.jpg", "Store at room temperature", 200, "kg",
                "2024-11-05", false, 21L, 95, 0.4f, 0.2f, 13.0f, 2.0f);
        ingredientService.createIngredient("Banana", "Fruit", "banana.jpg", "Store at room temperature", 150, "kg",
                "2024-10-25", false, 21L, 89, 1.1f, 0.3f, 22.8f, 2.6f);
        System.out.println("Test ingredients created successfully!");
    }

    // Function to retrieve all ingredients
    private void getAllIngredients() {
        List<Ingredient> ingredients = ingredientService.getAllIngredients();
        if (ingredients.isEmpty()) {
            System.out.println("No ingredients found.");
        } else {
            ingredients.forEach(ingredient -> System.out.println(ingredient));
        }
    }

    // Function to retrieve a specific ingredient by ID
    private void getIngredientById(Long ingredientId) {
        Optional<Ingredient> ingredient = ingredientService.getIngredientById(ingredientId);
        if (ingredient.isPresent()) {
            System.out.println("Found Ingredient: " + ingredient.get());
        } else {
            System.out.println("No ingredient found with ID: " + ingredientId);
        }
    }

    // Function to update an ingredient by ID
    private void updateIngredient(Long ingredientId) {
        Ingredient updatedIngredient = ingredientService.updateIngredient(ingredientId, "Tomato", "Fruit", "tomato_updated.jpg", 
                "Store in a cool place", 150, "kg", "2024-11-01", false, 21L, 25, 1.5f, 0.6f, 5.0f, 0.3f);
        System.out.println("Updated Ingredient: " + updatedIngredient);
    }

    // Function to delete an ingredient by ID
    private void deleteIngredient(Long ingredientId) {
        ingredientService.deleteIngredient(ingredientId);
        System.out.println("Ingredient with ID " + ingredientId + " deleted successfully!");
    }
}
