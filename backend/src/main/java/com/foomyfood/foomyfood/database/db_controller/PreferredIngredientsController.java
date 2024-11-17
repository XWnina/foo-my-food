package com.foomyfood.foomyfood.database.db_controller;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.foomyfood.foomyfood.database.PreferredIngredients;
import com.foomyfood.foomyfood.database.db_service.PreferredIngredientsService;

@RestController
@RequestMapping("/api/preferred-ingredients")
public class PreferredIngredientsController {

    private final PreferredIngredientsService service;

    @Autowired
    public PreferredIngredientsController(PreferredIngredientsService service) {
        this.service = service;
    }

    @GetMapping
    public ResponseEntity<List<PreferredIngredients>> getAllPreferredIngredients() {
        return ResponseEntity.ok(service.getAllPreferredIngredients());
    }

    @GetMapping("/user/{userId}")
    public ResponseEntity<List<PreferredIngredients>> getPreferredIngredientsByUserId(@PathVariable Long userId) {
        return ResponseEntity.ok(service.getPreferredIngredientsByUserId(userId));
    }

    @PostMapping
    public ResponseEntity<PreferredIngredients> addOrUpdatePreferredIngredient(
            @RequestParam Long userId,
            @RequestParam String ingredient,
            @RequestParam int cookingTime) {
        PreferredIngredients updated = service.addOrUpdatePreferredIngredient(userId, ingredient, cookingTime);
        return ResponseEntity.ok(updated);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deletePreferredIngredient(@PathVariable Long id) {
        service.deletePreferredIngredient(id);
        return ResponseEntity.noContent().build();
    }

    // New endpoint to update the preferred ingredients table from recipes
    @PutMapping("/update-from-recipes")
    public ResponseEntity<Void> updatePreferredIngredientsFromRecipes() {
        service.updatePreferredIngredientsFromRecipes();
        return ResponseEntity.noContent().build();
    }
}
