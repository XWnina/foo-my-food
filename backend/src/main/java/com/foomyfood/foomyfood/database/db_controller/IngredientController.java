package com.foomyfood.foomyfood.database.db_controller;

import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

import com.foomyfood.foomyfood.service.GoogleCloudStorageService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import com.foomyfood.foomyfood.database.Ingredient;
import com.foomyfood.foomyfood.database.db_service.IngredientService;
import org.springframework.web.multipart.MultipartFile;

@RestController
@RequestMapping("/api/ingredients")
public class IngredientController {

    @Autowired
    private IngredientService ingredientService;


    @Autowired
    private GoogleCloudStorageService googleCloudStorageService;

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

    // 上传图片到Google Cloud Storage
    @PostMapping("/upload_image")
    public ResponseEntity<Map<String, String>> uploadImage(
            @RequestParam("file") MultipartFile file,
            @RequestParam(value = "oldImageUrl", required = false) String oldImageUrl) {
        try {
            // 1. 如果有旧图片，则删除旧图片
            if (oldImageUrl != null && !oldImageUrl.isEmpty()) {
                googleCloudStorageService.deleteFile(oldImageUrl);
            }

            // 2. 上传新图片
            String imageUrl = googleCloudStorageService.uploadFile(file);

            Map<String, String> response = new HashMap<>();
            response.put("imageUrl", imageUrl);
            return ResponseEntity.ok(response);

        } catch (IOException e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(null);
        }
    }

}
