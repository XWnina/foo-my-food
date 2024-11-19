package com.foomyfood.foomyfood.controller;

import java.util.List;
import java.util.Map;

import com.foomyfood.foomyfood.database.db_repository.RecipeRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import com.foomyfood.foomyfood.database.Recipe;
import com.foomyfood.foomyfood.service.SmartMenuService;

@RestController
public class SmartMenuController {


    @Autowired
    private SmartMenuService smartMenuService;
    @Autowired
    private RecipeRepository recipeRepository;

//    @GetMapping("/api/recipes/custom")
//    public List<Long> getCustomRecipesByUserIngredients(@RequestParam Long userId) {
//        return smartMenuService.findCustomRecipesByUserIngredients(userId);
//    }
    @GetMapping("/api/recipes/custom")
    public List<Map<String, Object>> getCustomRecipesByUserIngredients(@RequestParam Long userId) {
        return smartMenuService.getDetailedRecipeInfo(userId, false, false, false);
    }

    @GetMapping("/api/recipes/preset")
    public List<Map<String, Object>> getPresetRecipesByUserIngredients(@RequestParam Long userId) {
        return smartMenuService.getDetailedRecipeInfo(userId, true, false, false);
    }

//    @GetMapping("/api/recipes/custom/expiring")
//    public List<Long> getCustomRecipesByExpiringIngredients(@RequestParam Long userId) {
//        return smartMenuService.findCustomRecipesByExpiringIngredients(userId);
//    }
//
//    @GetMapping("/api/recipes/preset/expiring")
//    public List<Long> getPresetRecipesByExpiringIngredients(@RequestParam Long userId) {
//        return smartMenuService.findPresetRecipesByExpiringIngredients(userId);
//    }
    ////
//    @GetMapping("/api/recipes/preset")
//    public List<Long> getPresetRecipesByUserIngredients(@RequestParam Long userId) {
//        return smartMenuService.findPresetRecipesByUserIngredients(userId);
//    }

    @GetMapping("/api/recipes/custom/expiring")
    public List<Map<String, Object>> getCustomRecipesByExpiringIngredients(@RequestParam Long userId) {
        return smartMenuService.getDetailedRecipeInfo(userId, false, true, false);
    }

    @GetMapping("/api/recipes/preset/expiring")
    public List<Map<String, Object>> getPresetRecipesByExpiringIngredients(@RequestParam Long userId) {
        return smartMenuService.getDetailedRecipeInfo(userId, true, true, false);
    }

    @GetMapping("/api/recipes/custom/preference")
    public List<Map<String, Object>> getCustomRecipesByUserIngredientsWithPreferenceWeights(@RequestParam Long userId) {
        return smartMenuService.getDetailedRecipeInfo(userId, false, false, true);
    }

    @GetMapping("/api/recipes/preset/preference")
    public List<Map<String, Object>> getPresetRecipesByUserIngredientsWithPreferenceWeights(@RequestParam Long userId) {
        return smartMenuService.getDetailedRecipeInfo(userId, true, false, true);
    }
    @PostMapping("/api/recipes/copy")
    public ResponseEntity<Recipe> copyPresetRecipe(@RequestParam Long userId, @RequestParam Long presetRecipeId) {
        System.out.println(presetRecipeId);
        try {
            Recipe copiedRecipe = smartMenuService.copyPresetRecipe(userId, presetRecipeId);

            return ResponseEntity.ok(copiedRecipe);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(null);
        }
    }
}
