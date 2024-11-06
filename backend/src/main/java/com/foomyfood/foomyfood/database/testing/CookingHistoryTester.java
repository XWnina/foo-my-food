package com.foomyfood.foomyfood.database.testing;

import java.time.LocalDate;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;

import com.foomyfood.foomyfood.database.CookingHistory;
import com.foomyfood.foomyfood.database.db_service.CookingHistoryService;

// @Component
public class CookingHistoryTester implements CommandLineRunner {

    @Autowired
    private CookingHistoryService cookingHistoryService;

    @Override
    public void run(String... args) throws Exception {
        Long userId = 5L; // Replace with the actual user ID if needed
        Long recipeId = 1L; // Recipe ID for which to add daily entries
        LocalDate startDate = LocalDate.of(2024, 5, 1); // Start date: May 1, 2024
        LocalDate endDate = LocalDate.now(); // Current date

        // System.out.println("\n--- Testing Daily Cooking History Creation ---");
        // addDailyCookingHistoryEntries(userId, recipeId, startDate, endDate);

        // Test the countCooksInPastDays method
        System.out.println("\n--- Testing Cooking Count in Past Days ---");
        testCountCooksInPastDays(recipeId, 30); // Check the past 30 days
        testCountCooksInPastDays(recipeId, 7);  // Check the past 7 days
    }

    // Method to add daily cooking history entries from startDate to endDate
    private void addDailyCookingHistoryEntries(Long userId, Long recipeId, LocalDate startDate, LocalDate endDate) {
        LocalDate currentDate = startDate;
        while (!currentDate.isAfter(endDate)) {
            try {
                // Add a cooking history entry for each day
                CookingHistory cookingHistory = cookingHistoryService.addCookingHistory(userId, recipeId, currentDate);
                System.out.println("Added CookingHistory: " + cookingHistory);
            } catch (Exception e) {
                System.out.println("Failed to add CookingHistory for date: " + currentDate);
                e.printStackTrace();
            }
            currentDate = currentDate.plusDays(1); // Move to the next day
        }
        System.out.println("Daily cooking history records added from " + startDate + " to " + endDate);
    }

    // Method to test the countCooksInPastDays functionality
    private void testCountCooksInPastDays(Long recipeId, int days) {
        long cookCount = cookingHistoryService.countCooksInPastDays(days, recipeId);
        System.out.println("The recipe with ID " + recipeId + " was cooked " + cookCount + " times in the past " + days + " days.");
    }
}
