package com.foomyfood.foomyfood.database.db_service;

import java.util.List;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.foomyfood.foomyfood.database.Recipe;
import com.foomyfood.foomyfood.database.db_repository.CookingHistoryRepository;
import com.foomyfood.foomyfood.database.db_repository.RecipeCollectionRepository;
import com.foomyfood.foomyfood.database.db_repository.RecipeRepository;

@Service
public class RecipeService {

    @Autowired
    private RecipeRepository recipeRepository;
    @Autowired
    private CookingHistoryRepository cookingHistoryRepository;
    @Autowired
    private RecipeCollectionRepository recipeCollectionRepository;

    // Add a new recipe
    public Recipe addRecipe(Recipe recipe) {
        // Ensure that dishName and ingredients are not null
        if (recipe.getDishName() == null || recipe.getDishName().isEmpty()) {
            throw new IllegalArgumentException("Dish name is mandatory.");
        }
        if (recipe.getIngredients() == null || recipe.getIngredients().isEmpty()) {
            throw new IllegalArgumentException("Ingredients are mandatory.");
        }
        return recipeRepository.save(recipe);
    }

    // Get a recipe by ID
    public Optional<Recipe> getRecipeById(Long id) {
        return recipeRepository.findById(id);
    }

    // Get all recipes
    public List<Recipe> getAllRecipes() {
        return recipeRepository.findAll();
    }

    // Update an existing recipe
    public Recipe editRecipe(Long id, Recipe updatedRecipe) {
        return recipeRepository.findById(id).map(recipe -> {
            recipe.setDishName(updatedRecipe.getDishName());
            recipe.setCalories(updatedRecipe.getCalories());
            recipe.setVideoLink(updatedRecipe.getVideoLink());
            recipe.setImageURL(updatedRecipe.getImageURL());
            recipe.setDescription(updatedRecipe.getDescription());
            recipe.setIngredients(String.join(", ", updatedRecipe.getIngredientsAsList()));
            recipe.setLabels(updatedRecipe.getLabels());

            return recipeRepository.save(recipe);
        }).orElseThrow(() -> new RuntimeException("Recipe with ID " + id + " not found"));
    }

    public List<Recipe> getAllRecipesByUserId(Long userId) {
        return recipeRepository.findByUserId(userId);
    }

    // Delete a recipe by ID
    @Transactional
    public void deleteRecipe(Long recipeId) {
        cookingHistoryRepository.deleteByRecipeId(recipeId);
        recipeRepository.deleteById(recipeId);
        recipeCollectionRepository.deleteByRecipeId(recipeId);
    }

    public List<Recipe> getRecipesByUserId(Long userId) {
        return recipeRepository.findByUserId(userId);
    }

    public Recipe getRecipeByIdAsRecipe(Long id) {
        return recipeRepository.findById(id).orElseThrow(() -> new RuntimeException("Recipe with ID " + id + " not found"));
    }
}
