package com.foomyfood.foomyfood.database.db_controller;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

import com.foomyfood.foomyfood.database.Ingredient;
import com.foomyfood.foomyfood.dto.IngredientDTO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.foomyfood.foomyfood.database.UserIngredient;
import com.foomyfood.foomyfood.database.db_service.IngredientService;
import com.foomyfood.foomyfood.database.db_service.UserIngredientService;

@RestController
@RequestMapping("/api/user_ingredients")
public class UserIngredientController {

    @Autowired
    private UserIngredientService userIngredientService;

    @Autowired
    private IngredientService ingredientService;

    @GetMapping("/{userId}")
    public ResponseEntity<List<UserIngredient>> getAllUserIngredients(@PathVariable Long userId) {
        List<UserIngredient> userIngredients = userIngredientService.getAllUserIngredients(userId);
        System.out.println(userId);
        return ResponseEntity.ok(userIngredients);
    }

    @GetMapping("/{userId}/{ingredientId}")
    public ResponseEntity<UserIngredient> getUserIngredient(@PathVariable Long userId, @PathVariable Long ingredientId) {
        Optional<UserIngredient> userIngredientOptional = userIngredientService.getUserIngredient(userId, ingredientId);
        return userIngredientOptional
                .map(ResponseEntity::ok)
                .orElseGet(() -> new ResponseEntity<>(HttpStatus.NOT_FOUND));
    }

    @PostMapping
    public ResponseEntity<UserIngredient> createUserIngredient(@RequestBody UserIngredient userIngredient) {
        UserIngredient createdUserIngredient = userIngredientService.createUserIngredient(userIngredient.getUserId(),userIngredient.getIngredientId(), userIngredient.getUserQuantity());
        return ResponseEntity.status(HttpStatus.CREATED).body(createdUserIngredient);
    }

    @PutMapping("/{userId}/{ingredientId}")
    public ResponseEntity<UserIngredient> updateUserIngredient(@PathVariable Long userId,
                                                               @PathVariable Long ingredientId,
                                                               @RequestBody UserIngredient userIngredient) {
        try {
            UserIngredient updatedUserIngredient = userIngredientService.updateUserIngredient(userId, ingredientId, userIngredient.getUserQuantity());
            return ResponseEntity.ok(updatedUserIngredient);
        } catch (RuntimeException e) {
            return new ResponseEntity<>(HttpStatus.NOT_FOUND);
        }
    }

    @DeleteMapping("/{userId}/{ingredientId}")
    public ResponseEntity<Void> deleteUserIngredient(@PathVariable Long userId, @PathVariable Long ingredientId) {
        userIngredientService.deleteUserIngredient(userId, ingredientId);
        ingredientService.deleteIngredient(ingredientId);

        return ResponseEntity.noContent().build();
    }
    // 获取即将过期的食材列表
    @GetMapping("/expiring_soon/{userId}")
    public ResponseEntity<List<IngredientDTO>> getExpiringIngredients(@PathVariable Long userId) {
        List<Ingredient> ingredients = userIngredientService.getExpiringIngredients(userId);
        List<IngredientDTO> ingredientDTOs = ingredients.stream().map(IngredientDTO::new).collect(Collectors.toList());
        return ResponseEntity.ok(ingredientDTOs);
    }
}