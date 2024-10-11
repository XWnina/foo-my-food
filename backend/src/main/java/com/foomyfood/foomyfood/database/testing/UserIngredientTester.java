package com.foomyfood.foomyfood.database.testing;

import java.util.List;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;

import com.foomyfood.foomyfood.database.UserIngredient;
import com.foomyfood.foomyfood.database.db_service.UserIngredientService;

//@Component
public class UserIngredientTester implements CommandLineRunner {

    @Autowired
    private UserIngredientService userIngredientService;

    @Override
    public void run(String... args) throws Exception {
        // Test creating user ingredients
        System.out.println("\n--- Testing UserIngredient Creation ---");
        createTestUserIngredients();

        // Test retrieving all user ingredients for a user
        System.out.println("\n--- Testing Retrieving All UserIngredients ---");
        getAllUserIngredients(1L);

        // Test retrieving a specific user ingredient by userId and ingredientId
        System.out.println("\n--- Testing Retrieving UserIngredient by ID ---");
        getUserIngredientById(1L, 1L);

        // Test updating a user ingredient
        System.out.println("\n--- Testing UserIngredient Update ---");
        updateUserIngredient(1L, 1L);

        // Test retrieving updated user ingredient by userId and ingredientId
        System.out.println("\n--- Testing Retrieving Updated UserIngredient by ID ---");
        getUserIngredientById(1L, 1L);

        // Test deleting a user ingredient
        System.out.println("\n--- Testing UserIngredient Deletion ---");
        deleteUserIngredient(1L, 2L);

        // Test retrieving all user ingredients after deletion
        System.out.println("\n--- Retrieving All UserIngredients After Deletion ---");
        getAllUserIngredients(1L);
    }

    // Function to create test user ingredients
    private void createTestUserIngredients() {
        userIngredientService.createUserIngredient(1L, 1L, 500);
        userIngredientService.createUserIngredient(1L, 2L, 1000);
        userIngredientService.createUserIngredient(1L, 3L, 200);
        System.out.println("Test user ingredients created successfully!");
    }

    // Function to retrieve all user ingredients for a specific user
    private void getAllUserIngredients(Long userId) {
        List<UserIngredient> userIngredients = userIngredientService.getAllUserIngredients(userId);
        if (userIngredients.isEmpty()) {
            System.out.println("No user ingredients found.");
        } else {
            userIngredients.forEach(userIngredient -> System.out.println(userIngredient));
        }
    }

    // Function to retrieve a specific user ingredient by userId and ingredientId
    private void getUserIngredientById(Long userId, Long ingredientId) {
        Optional<UserIngredient> userIngredient = userIngredientService.getUserIngredient(userId, ingredientId);
        if (userIngredient.isPresent()) {
            System.out.println("Found UserIngredient: " + userIngredient.get());
        } else {
            System.out.println("No user ingredient found with userId: " + userId + " and ingredientId: " + ingredientId);
        }
    }

    // Function to update a user ingredient by userId and ingredientId
    private void updateUserIngredient(Long userId, Long ingredientId) {
        UserIngredient updatedUserIngredient = userIngredientService.updateUserIngredient(userId, ingredientId, 600);
        System.out.println("Updated UserIngredient: " + updatedUserIngredient);
    }

    // Function to delete a user ingredient by userId and ingredientId
    private void deleteUserIngredient(Long userId, Long ingredientId) {
        userIngredientService.deleteUserIngredient(userId, ingredientId);
        System.out.println("User ingredient with userId " + userId + " and ingredientId " + ingredientId + " deleted successfully!");
    }
}
