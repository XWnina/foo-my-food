package com.foomyfood.foomyfood.controller;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.foomyfood.foomyfood.service.SmartMenuService;

@RestController
public class SmartMenuController {

    @Autowired
    private SmartMenuService smartMenuService;

    @GetMapping("/api/recipes/custom")
    public List<Long> getCustomRecipesByUserIngredients(@RequestParam Long userId) {
        return smartMenuService.findCustomRecipesByUserIngredients(userId);
    }

    @GetMapping("/api/recipes/preset")
    public List<Long> getPresetRecipesByUserIngredients(@RequestParam Long userId) {
        return smartMenuService.findPresetRecipesByUserIngredients(userId);
    }

    @GetMapping("/api/recipes/custom/expiring")
    public List<Long> getCustomRecipesByExpiringIngredients(@RequestParam Long userId) {
        return smartMenuService.findCustomRecipesByExpiringIngredients(userId);
    }

    @GetMapping("/api/recipes/preset/expiring")
    public List<Long> getPresetRecipesByExpiringIngredients(@RequestParam Long userId) {
        return smartMenuService.findPresetRecipesByExpiringIngredients(userId);
    }
}
