package com.foomyfood.foomyfood.controller;

import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.foomyfood.foomyfood.service.SmartMenuService;

@RestController
public class SmartMenuController {

    @Autowired
    private SmartMenuService smartMenuService;

    // Searching from user recipes with all user ingredients
    @GetMapping("/api/recipes/custom")
    public List<Map<String, Object>> getCustomRecipesByUserIngredients(@RequestParam Long userId) {
        return smartMenuService.findCustomRecipesByUserIngredients(userId);
    }

    // Searching from preset recipes with all user ingredients
    @GetMapping("/api/recipes/preset")
    public List<Map<String, Object>> getPresetRecipesByUserIngredients(@RequestParam Long userId) {
        return smartMenuService.findPresetRecipesByUserIngredients(userId);
    }

    // Searching from user recipes with user's expiring ingredients
    @GetMapping("/api/recipes/custom/expiring")
    public List<Map<String, Object>> getCustomRecipesByExpiringIngredients(@RequestParam Long userId) {
        return smartMenuService.findCustomRecipesByExpiringIngredients(userId);
    }

    // Searching from preset recipes with user's expiring ingredients
    @GetMapping("/api/recipes/preset/expiring")
    public List<Map<String, Object>> getPresetRecipesByExpiringIngredients(@RequestParam Long userId) {
        return smartMenuService.findPresetRecipesByExpiringIngredients(userId);
    }
}
