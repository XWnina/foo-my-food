package com.foomyfood.foomyfood.database.db_controller;

import java.util.List;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.foomyfood.foomyfood.database.Recipe;
import com.foomyfood.foomyfood.database.db_service.RecipeService;

@RestController
@RequestMapping("/api/recipes")
public class RecipeController {

    @Autowired
    private RecipeService recipeService;

    // Add a new recipe
    @PostMapping
    public ResponseEntity<Recipe> addRecipe(@RequestBody Recipe recipe) {
        // Ensure that dishName and ingredients are not null
        if (recipe.getDishName() == null || recipe.getDishName().isEmpty()) {
            return ResponseEntity.badRequest().body(null); // Dish name is required
        }
        if (recipe.getIngredients() == null || recipe.getIngredients().isEmpty()) {
            return ResponseEntity.badRequest().body(null); // Ingredients are required
        }

        Recipe createdRecipe = recipeService.addRecipe(recipe);
        return ResponseEntity.ok(createdRecipe);
    }

    // Get a recipe by ID
    @GetMapping("/{id}")
    public ResponseEntity<Recipe> getRecipeById(@PathVariable Long id) {
        Optional<Recipe> recipe = recipeService.getRecipeById(id);
        return recipe.map(ResponseEntity::ok)
                     .orElse(ResponseEntity.notFound().build());
    }

    // Get all recipes
    @GetMapping
    public ResponseEntity<List<Recipe>> getAllRecipes() {
        List<Recipe> recipes = recipeService.getAllRecipes();
        return ResponseEntity.ok(recipes);
    }

    // Update a recipe by ID
    @PutMapping("/{id}")
    public ResponseEntity<Recipe> updateRecipe(@PathVariable Long id, @RequestBody Recipe updatedRecipe) {
        // Ensure that dishName and ingredients are not null
        if (updatedRecipe.getDishName() == null || updatedRecipe.getDishName().isEmpty()) {
            return ResponseEntity.badRequest().body(null); // Dish name is required
        }
        if (updatedRecipe.getIngredients() == null || updatedRecipe.getIngredients().isEmpty()) {
            return ResponseEntity.badRequest().body(null); // Ingredients are required
        }

        Recipe updated = recipeService.editRecipe(id, updatedRecipe);
        return ResponseEntity.ok(updated);
    }

    // Delete a recipe by ID
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteRecipe(@PathVariable Long id) {
        recipeService.deleteRecipe(id);
        return ResponseEntity.noContent().build();
    }
}
