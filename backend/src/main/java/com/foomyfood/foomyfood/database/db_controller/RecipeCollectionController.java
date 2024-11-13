package com.foomyfood.foomyfood.database.db_controller;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.foomyfood.foomyfood.database.RecipeCollection;
import com.foomyfood.foomyfood.database.db_service.RecipeCollectionService;

@RestController
@RequestMapping("/api/recipe-collection")
public class RecipeCollectionController {

    private final RecipeCollectionService recipeCollectionService;

    @Autowired
    public RecipeCollectionController(RecipeCollectionService recipeCollectionService) {
        this.recipeCollectionService = recipeCollectionService;
    }

    @GetMapping("/user/{userId}")
    public List<RecipeCollection> getRecipesByUserId(@PathVariable Long userId) {
        return recipeCollectionService.getRecipesByUserId(userId);
    }

    @PostMapping
    public ResponseEntity<RecipeCollection> saveRecipe(@RequestBody RecipeCollection recipeCollection) {
        try {
            RecipeCollection savedRecipe = recipeCollectionService.saveRecipe(recipeCollection);
            return ResponseEntity.ok(savedRecipe);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(null);
        }
    }

    @DeleteMapping("/user/{userId}/recipe/{recipeId}/preset-recipe/{presetRecipeId}")
    public ResponseEntity<Void> deleteRecipe(
            @PathVariable Long userId,
            @PathVariable Long recipeId,
            @PathVariable Long presetRecipeId) {
        recipeCollectionService.deleteRecipe(userId, recipeId, presetRecipeId);
        return ResponseEntity.noContent().build();
    }
}
