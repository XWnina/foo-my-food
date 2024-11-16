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

//    @GetMapping("/api/recipes/custom")
//    public List<Long> getCustomRecipesByUserIngredients(@RequestParam Long userId) {
//        return smartMenuService.findCustomRecipesByUserIngredients(userId);
//    }
    @GetMapping("/api/recipes/custom")
    public List<Map<String,Object>> getCustomRecipesByUserIngredients(@RequestParam Long userId) {
        return smartMenuService.getDetailedRecipeInfo(userId,false,false);
    }
    @GetMapping("/api/recipes/preset")
    public List<Map<String,Object>> getPresetRecipesByUserIngredients(@RequestParam Long userId) {
        return smartMenuService.getDetailedRecipeInfo(userId,true,false);
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
    public List<Map<String,Object>> getCustomRecipesByExpiringIngredients(@RequestParam Long userId) {
        return smartMenuService.getDetailedRecipeInfo(userId,false,true);
    }

    @GetMapping("/api/recipes/preset/expiring")
    public List<Map<String,Object>>getPresetRecipesByExpiringIngredients(@RequestParam Long userId) {
        return smartMenuService.getDetailedRecipeInfo(userId,true,true);
    }
}
