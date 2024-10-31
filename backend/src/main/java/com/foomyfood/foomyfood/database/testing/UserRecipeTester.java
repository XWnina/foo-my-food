package com.foomyfood.foomyfood.database.testing;

import java.util.List;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;

import com.foomyfood.foomyfood.database.UserRecipe;
import com.foomyfood.foomyfood.database.db_service.UserRecipeService;

// @Component
public class UserRecipeTester implements CommandLineRunner {

    @Autowired
    private UserRecipeService userRecipeService;

    @Override
    public void run(String... args) throws Exception {
        // Test user recipe creation
        System.out.println("\n--- Testing UserRecipe Creation ---");
        createTestUserRecipes();

        // Test retrieving all user recipes
        System.out.println("\n--- Testing Retrieving All UserRecipes ---");
        getAllUserRecipes();

        // Test retrieving a specific user recipe by ID
        System.out.println("\n--- Testing Retrieving UserRecipe by ID ---");
        getUserRecipeById(1L); // Assuming ID 1 exists

        // Test updating a user recipe
        System.out.println("\n--- Testing UserRecipe Update ---");
        updateUserRecipe(1L);  // Assuming ID 1 exists

        // Test retrieving updated user recipe by ID
        System.out.println("\n--- Testing Retrieving Updated UserRecipe by ID ---");
        getUserRecipeById(1L);  // Assuming ID 1 exists

        // Test deleting a user recipe
        System.out.println("\n--- Testing UserRecipe Deletion ---");
        deleteUserRecipe(2L);  // Assuming ID 2 exists

        // Test deleting a non-existent user recipe
        System.out.println("\n--- Testing Deleting Non-Existent UserRecipe ---");
        deleteUserRecipe(999L);  // Assuming ID 999 doesn't exist

        // Test retrieving all user recipes after deletion
        System.out.println("\n--- Testing Retrieving All UserRecipes After Deletion ---");
        getAllUserRecipes();
    }

    // Create test user recipes with different scenarios
    private void createTestUserRecipes() {
        // Valid user recipes with all fields filled
        UserRecipe userRecipe1 = userRecipeService.createUserRecipe(new UserRecipe(1L, 1L, 5));
        UserRecipe userRecipe2 = userRecipeService.createUserRecipe(new UserRecipe(2L, 1L, 2));

        // Print created user recipes
        System.out.println("Created UserRecipes:");
        System.out.println(userRecipe1);
        System.out.println(userRecipe2);
    }

    // Retrieve all user recipes
    private void getAllUserRecipes() {
        List<UserRecipe> userRecipes = userRecipeService.getAllUserRecipes();
        if (userRecipes.isEmpty()) {
            System.out.println("No user recipes found.");
        } else {
            System.out.println("All UserRecipes:");
            userRecipes.forEach(System.out::println);
        }
    }

    // Retrieve a user recipe by ID
    private void getUserRecipeById(Long userRecipeId) {
        Optional<UserRecipe> userRecipe = userRecipeService.getUserRecipeById(userRecipeId);
        if (userRecipe.isPresent()) {
            System.out.println("Found UserRecipe: " + userRecipe.get());
        } else {
            System.out.println("No user recipe found with ID: " + userRecipeId);
        }
    }

    // Update a user recipe
    private void updateUserRecipe(Long userRecipeId) {
        UserRecipe updatedUserRecipe = userRecipeService.updateUserRecipe(userRecipeId, new UserRecipe(1L, 1L, 10));
        System.out.println("Updated UserRecipe: " + updatedUserRecipe);
    }

    // Delete a user recipe
    private void deleteUserRecipe(Long userRecipeId) {
        try {
            userRecipeService.deleteUserRecipe(userRecipeId);
            System.out.println("UserRecipe with ID " + userRecipeId + " successfully deleted!");
        } catch (RuntimeException e) {
            System.out.println(e.getMessage());
        }
    }
}
