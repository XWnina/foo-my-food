package com.foomyfood.foomyfood.controller;

import com.foomyfood.foomyfood.database.RecipeCollection;
import com.foomyfood.foomyfood.service.MyRecipeCollectionService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/my-recipe-collection")
public class MyRecipeCollectionController {

    @Autowired
    private MyRecipeCollectionService recipeCollectionService;

    // 添加收藏
    @PostMapping("/add")
    public ResponseEntity<?> addFavorite(@RequestBody Map<String, String> body) {
        Long userId = Long.parseLong(body.get("user_id"));
        Long recipeId = body.containsKey("recipe_id") ? Long.parseLong(body.get("recipe_id")) : null;
        Long presetRecipeId = body.containsKey("preset_recipe_id") ? Long.parseLong(body.get("preset_recipe_id")) : null;

        recipeCollectionService.addFavorite(userId, recipeId, presetRecipeId);
        return ResponseEntity.ok().build();
    }

    // 删除收藏
    @PostMapping("/remove")
    public ResponseEntity<?> removeFavorite(@RequestBody Map<String, String> body) {
        Long userId = Long.parseLong(body.get("user_id"));
        Long recipeId = body.containsKey("recipe_id") ? Long.parseLong(body.get("recipe_id")) : null;
        Long presetRecipeId = body.containsKey("preset_recipe_id") ? Long.parseLong(body.get("preset_recipe_id")) : null;

        recipeCollectionService.removeFavorite(userId, recipeId, presetRecipeId);
        return ResponseEntity.ok().build();
    }

    // 获取用户的收藏
    @GetMapping("/user/{userId}")
    public ResponseEntity<?> getUserFavorites(@PathVariable Long userId) {
        return ResponseEntity.ok(recipeCollectionService.getUserFavorites(userId));
    }
    // 获取用户的收藏（包括食谱和预设食谱）
    @GetMapping("/info/{userId}")
    public ResponseEntity<?> getUserFavoritesAll(@PathVariable Long userId) {
        return ResponseEntity.ok(recipeCollectionService.getUserFavoritesAll(userId));
    }
}
