package com.foomyfood.foomyfood.controller;

import com.foomyfood.foomyfood.service.GoogleCloudStorageService;
import com.foomyfood.foomyfood.database.Recipe;
import com.foomyfood.foomyfood.database.db_service.RecipeService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/api/myrecipes")
public class MyRecipeController {

    @Autowired
    private RecipeService recipeService;

    @Autowired
    private GoogleCloudStorageService googleCloudStorageService;

    // 获取某个用户的所有配方
    @GetMapping("/user/{userId}")
    public ResponseEntity<List<Recipe>> getAllRecipesByUser() {
        List<Recipe> recipes = recipeService.getAllRecipes();
        return ResponseEntity.ok(recipes);
    }

    // 添加新配方
    @PostMapping
    public ResponseEntity<Recipe> addRecipe(@RequestBody Recipe recipe) {
        Recipe createdRecipe = recipeService.addRecipe(recipe);
        return ResponseEntity.ok(createdRecipe);
    }

    // 根据ID获取配方
    @GetMapping("/id/{id}")
    public ResponseEntity<Recipe> getRecipeById(@PathVariable Long id) {
        Optional<Recipe> recipe = recipeService.getRecipeById(id);
        // 打印当前所有食谱ID
        List<Recipe> allRecipes = recipeService.getAllRecipes();
        System.out.println("Current recipes in database:");
        allRecipes.forEach(r -> System.out.println("Recipe ID: " + r.getId() + ", Name: " + r.getDishName()));
        return recipe.map(ResponseEntity::ok).orElse(ResponseEntity.notFound().build());
    }

    // 更新配方
    @PutMapping("/id/{id}")
    public ResponseEntity<Recipe> updateRecipe(@PathVariable Long id, @RequestBody Recipe updatedRecipe) {
        Recipe updated = recipeService.editRecipe(id, updatedRecipe);
        return ResponseEntity.ok(updated);
    }

    // 删除配方
    @DeleteMapping("/id/{id}")
    public ResponseEntity<Void> deleteRecipe(@PathVariable Long id) {
        recipeService.deleteRecipe(id);
        return ResponseEntity.noContent().build();
    }

    // 上传图片
    @PostMapping("/upload_image")
    public ResponseEntity<Map<String, String>> uploadImage(@RequestParam("file") MultipartFile file) {
        try {
            // 使用注入的实例调用非静态方法
            String imageUrl = googleCloudStorageService.uploadFile(file);
            Map<String, String> response = new HashMap<>();
            response.put("imageUrl", imageUrl);
            return ResponseEntity.ok(response);
        } catch (IOException e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(null);
        }
    }
}
