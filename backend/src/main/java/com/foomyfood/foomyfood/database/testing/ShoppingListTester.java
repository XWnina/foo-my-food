package com.foomyfood.foomyfood.database.testing;

import java.util.List;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;

import com.foomyfood.foomyfood.database.ShoppingList;
import com.foomyfood.foomyfood.database.db_service.ShoppingListService;

// @Component
public class ShoppingListTester implements CommandLineRunner {

    @Autowired
    private ShoppingListService shoppingListService;

    @Override
    public void run(String... args) throws Exception {
        // Test item creation with different scenarios
        System.out.println("\n--- Testing Shopping List Item Creation ---");
        createTestItems();

        // Test retrieving all items
        System.out.println("\n--- Testing Retrieving All Items ---");
        getAllItems();

        // Test retrieving a specific item by ID
        System.out.println("\n--- Testing Retrieving Item by ID ---");
        getItemById(1L); // Assuming ID 1 exists

        // Test updating an item
        System.out.println("\n--- Testing Item Update ---");
        updateItem(1L);  // Assuming ID 1 exists

        // Test retrieving updated item by ID
        System.out.println("\n--- Testing Retrieving Updated Item by ID ---");
        getItemById(1L);  // Assuming ID 1 exists

        // Test deleting an item
        System.out.println("\n--- Testing Item Deletion ---");
        deleteItem(2L);  // Assuming ID 2 exists

        // Test deleting a non-existent item
        System.out.println("\n--- Testing Deleting Non-Existent Item ---");
        deleteItem(999L);  // Assuming ID 999 doesn't exist

        // Test retrieving all items after deletion
        System.out.println("\n--- Testing Retrieving All Items After Deletion ---");
        getAllItems();
    }

    // Create test items with different scenarios
    private void createTestItems() {
        // Valid items with all fields filled
        ShoppingList item1 = shoppingListService.createItem(
                new ShoppingList(1L, "Milk", 2, "liters", false)
        );

        // Item with minimal details
        ShoppingList item2 = shoppingListService.createItem(
                new ShoppingList(1L, "Bread", 1, "loaf", true)
        );

        // Item with only userId and name filled
        ShoppingList item3 = shoppingListService.createItem(
                new ShoppingList(2L, "Eggs", 12, "pcs", false)
        );

        // Print created items
        System.out.println("Created Items:");
        System.out.println(item1);
        System.out.println(item2);
        System.out.println(item3);
    }

    // Retrieve all items
    private void getAllItems() {
        List<ShoppingList> items = shoppingListService.getAllItems();
        if (items.isEmpty()) {
            System.out.println("No items found.");
        } else {
            System.out.println("All Items:");
            items.forEach(System.out::println);
        }
    }

    // Retrieve an item by ID
    private void getItemById(Long itemId) {
        Optional<ShoppingList> item = shoppingListService.getItemById(itemId);
        if (item.isPresent()) {
            System.out.println("Found Item: " + item.get());
        } else {
            System.out.println("No item found with ID: " + itemId);
        }
    }

    // Update an item
    private void updateItem(Long itemId) {
        ShoppingList updatedItem = shoppingListService.updateItem(itemId,
                new ShoppingList(1L, "Updated Milk", 3, "liters", true)
        );
        System.out.println("Updated Item: " + updatedItem);
    }

    // Delete an item
    private void deleteItem(Long itemId) {
        try {
            shoppingListService.deleteItem(itemId);
            System.out.println("Item with ID " + itemId + " successfully deleted!");
        } catch (RuntimeException e) {
            System.out.println(e.getMessage());
        }
    }
}
