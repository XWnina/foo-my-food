package com.foomyfood.foomyfood.database.test_controller;

import java.util.List;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

import com.foomyfood.foomyfood.database.Ingredient;
import com.foomyfood.foomyfood.database.test_service.IngredientService;

@RestController
public class IngredientController {

    @Autowired
    private IngredientService ingredientService;

    // Get all ingredients
    @GetMapping
    public ResponseEntity<List<Ingredient>> getAllIngredients() {
        List<Ingredient> ingredients = ingredientService.getAllIngredients();
        return ResponseEntity.ok(ingredients);
    }

    // Get ingredient by ID
    @GetMapping("/{ingredientId}")
    public ResponseEntity<Ingredient> getIngredientById(@PathVariable Long ingredientId) {
        Optional<Ingredient> ingredientOptional = ingredientService.getIngredientById(ingredientId);
        return ingredientOptional
                .map(ResponseEntity::ok)
                .orElseGet(() -> new ResponseEntity<>(HttpStatus.NOT_FOUND));
    }

    // Create new ingredient
    @PostMapping
    public ResponseEntity<Ingredient> createIngredient(@RequestBody Ingredient ingredient) {
        Ingredient createdIngredient = ingredientService.createIngredient(
                ingredient.getName(),
                ingredient.getCategory(),
                ingredient.getImageURL(),
                ingredient.getStorageMethod(),
                ingredient.getBaseQuantity(),
                ingredient.getUnit(),
                ingredient.getExpirationDate(),
                ingredient.getIsUserCreated(),
                ingredient.getCreatedBy(),
                ingredient.getCalories(),
                ingredient.getProtein(),
                ingredient.getFat(),
                ingredient.getCarbohydrates(),
                ingredient.getFiber()
        );
        return ResponseEntity.status(HttpStatus.CREATED).body(createdIngredient);
    }

    // Update ingredient by ID
    @PutMapping("/{ingredientId}")
    public ResponseEntity<Ingredient> updateIngredient(@PathVariable Long ingredientId, @RequestBody Ingredient ingredient) {
        try {
            Ingredient updatedIngredient = ingredientService.updateIngredient(
                    ingredientId,
                    ingredient.getName(),
                    ingredient.getCategory(),
                    ingredient.getImageURL(),
                    ingredient.getStorageMethod(),
                    ingredient.getBaseQuantity(),
                    ingredient.getUnit(),
                    ingredient.getExpirationDate(),
                    ingredient.getIsUserCreated(),
                    ingredient.getCreatedBy(),
                    ingredient.getCalories(),
                    ingredient.getProtein(),
                    ingredient.getFat(),
                    ingredient.getCarbohydrates(),
                    ingredient.getFiber()
            );
            return ResponseEntity.ok(updatedIngredient);
        } catch (RuntimeException e) {
            return new ResponseEntity<>(HttpStatus.NOT_FOUND);
        }
    }

    // Delete ingredient by ID
    @DeleteMapping("/{ingredientId}")
    public ResponseEntity<Void> deleteIngredient(@PathVariable Long ingredientId) {
        ingredientService.deleteIngredient(ingredientId);
        return ResponseEntity.noContent().build();
    }

    // Get ingredient by name
    @GetMapping("/name/{name}")
    public ResponseEntity<Ingredient> getIngredientByName(@PathVariable String name) {
        Optional<Ingredient> ingredientOptional = ingredientService.getIngredientByName(name);
        return ingredientOptional
                .map(ResponseEntity::ok)
                .orElseGet(() -> new ResponseEntity<>(HttpStatus.NOT_FOUND));
    }
}
