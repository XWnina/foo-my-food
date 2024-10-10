package com.foomyfood.foomyfood.controller;

import com.foomyfood.foomyfood.database.Ingredient;
import com.foomyfood.foomyfood.service.IngredientService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/api/ingredients")
public class IngredientController {

    @Autowired
    private IngredientService ingredientService;

    // 获取所有食材
    @GetMapping
    public ResponseEntity<List<Ingredient>> getAllIngredients() {
        List<Ingredient> ingredients = ingredientService.getAllIngredients();
        return ResponseEntity.ok(ingredients);
    }

    // 根据 ID 获取食材
    @GetMapping("/{ingredientId}")
    public ResponseEntity<Ingredient> getIngredientById(@PathVariable Long ingredientId) {
        Optional<Ingredient> ingredientOptional = ingredientService.getIngredientById(ingredientId);
        return ingredientOptional
                .map(ResponseEntity::ok)
                .orElseGet(() -> new ResponseEntity<>(HttpStatus.NOT_FOUND));
    }

    // 创建新食材
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

    // 更新食材信息
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

    // 删除食材
    @DeleteMapping("/{ingredientId}")
    public ResponseEntity<Void> deleteIngredient(@PathVariable Long ingredientId) {
        ingredientService.deleteIngredient(ingredientId);
        return ResponseEntity.noContent().build();
    }

    // 根据名称查找食材
    @GetMapping("/name/{name}")
    public ResponseEntity<Ingredient> getIngredientByName(@PathVariable String name) {
        Optional<Ingredient> ingredientOptional = ingredientService.getIngredientByName(name);
        return ingredientOptional
                .map(ResponseEntity::ok)
                .orElseGet(() -> new ResponseEntity<>(HttpStatus.NOT_FOUND));
    }
}