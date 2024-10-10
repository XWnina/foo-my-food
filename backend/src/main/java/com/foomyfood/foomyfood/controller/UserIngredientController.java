package com.foomyfood.foomyfood.controller;

import com.foomyfood.foomyfood.database.UserIngredient;
import com.foomyfood.foomyfood.service.UserIngredientService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/api/user-ingredients")
public class UserIngredientController {

    @Autowired
    private UserIngredientService userIngredientService;

    // 根据用户 ID 获取所有用户食材
    @GetMapping("/{userId}")
    public ResponseEntity<List<UserIngredient>> getAllUserIngredients(@PathVariable Long userId) {
        List<UserIngredient> userIngredients = userIngredientService.getAllUserIngredients(userId);
        return ResponseEntity.ok(userIngredients);
    }

    // 根据用户 ID 和食材 ID 获取用户食材
    @GetMapping("/{userId}/{ingredientId}")
    public ResponseEntity<UserIngredient> getUserIngredient(@PathVariable Long userId, @PathVariable Long ingredientId) {
        Optional<UserIngredient> userIngredientOptional = userIngredientService.getUserIngredient(userId, ingredientId);
        return userIngredientOptional
                .map(ResponseEntity::ok)
                .orElseGet(() -> new ResponseEntity<>(HttpStatus.NOT_FOUND));
    }

    // 创建新用户食材
    @PostMapping
    public ResponseEntity<UserIngredient> createUserIngredient(@RequestBody UserIngredient userIngredient) {
        UserIngredient createdUserIngredient = userIngredientService.createUserIngredient(userIngredient);
        return ResponseEntity.status(HttpStatus.CREATED).body(createdUserIngredient);
    }

    // 更新用户食材信息
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

    // 删除用户食材
    @DeleteMapping("/{userId}/{ingredientId}")
    public ResponseEntity<Void> deleteUserIngredient(@PathVariable Long userId, @PathVariable Long ingredientId) {
        userIngredientService.deleteUserIngredient(userId, ingredientId);
        return ResponseEntity.noContent().build();
    }
}