package com.foomyfood.foomyfood.database.db_service;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.foomyfood.foomyfood.database.CookingHistory;
import com.foomyfood.foomyfood.database.Recipe;
import com.foomyfood.foomyfood.database.db_repository.CookingHistoryRepository;
import com.foomyfood.foomyfood.database.db_repository.RecipeRepository;

@Service
public class CookingHistoryService {

    @Autowired
    private CookingHistoryRepository cookingHistoryRepository;

    @Autowired
    private RecipeRepository recipeRepository;

    // Add a new CookingHistory entry
//    public CookingHistory addCookingHistory(Long userId, Long recipeId, LocalDate cookingDate) {
//        Optional<Recipe> recipe = recipeRepository.findById(recipeId);
//        if (recipe.isPresent()) {
//            CookingHistory cookingHistory = new CookingHistory(userId, recipe.get(), cookingDate);
//            return cookingHistoryRepository.save(cookingHistory);
//        } else {
//            throw new IllegalArgumentException("Recipe not found with id: " + recipeId);
//        }
//    }
    public CookingHistory addCookingHistory(Long userId, Long recipeId, LocalDate cookingDate) {
        Optional<Recipe> recipe = recipeRepository.findById(recipeId);
        if (recipe.isPresent()) {
            CookingHistory cookingHistory = new CookingHistory(userId, recipe.get(), cookingDate);
            cookingHistory = cookingHistoryRepository.save(cookingHistory);

            // 更新菜谱的制作总次数
            Recipe updatedRecipe = recipe.get();
            updatedRecipe.setCookCount(updatedRecipe.getCookCount() + 1);
            recipeRepository.save(updatedRecipe);

            return cookingHistory;
        } else {
            throw new IllegalArgumentException("Recipe not found with id: " + recipeId);
        }
    }
    // Retrieve all CookingHistory entries by user ID
    public List<CookingHistory> getAllCookingHistoryByUserId(Long userId) {
        return cookingHistoryRepository.findByUserId(userId);
    }

    // Retrieve all CookingHistory entries by recipe ID
    public List<CookingHistory> getAllCookingHistoryByRecipeId(Long recipeId) {
        return cookingHistoryRepository.findByRecipeId(recipeId);
    }

    // Delete a CookingHistory entry by ID
    public void deleteCookingHistoryById(Long id) {
        cookingHistoryRepository.deleteById(id);
    }

    // Method to count how many times a recipe was cooked in the past 'days' days
    public long countCooksInPastDays(int days, Long recipeId) {
        LocalDate startDate = LocalDate.now().minusDays(days-1); // Calculate the start date
        LocalDate endDate = LocalDate.now(); // Include the current date

        // System.out.println(LocalDate.now());
        // System.out.println(startDate);
        // System.out.println(endDate);
        return cookingHistoryRepository.countByRecipeIdAndCookingDateBetween(recipeId, startDate, endDate);

    }



}
