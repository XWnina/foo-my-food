package com.foomyfood.foomyfood.controller;

import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.foomyfood.foomyfood.service.SmartMenuService;

@RestController
@RequestMapping("/api/smartmenu")
public class SmartMenuController {

    @Autowired
    private SmartMenuService smartMenuService;

    // API Endpoint to find recipes by ingredient
    @GetMapping("/find-by-ingredient")
    public List<Map<String, Object>> findRecipesByIngredient(@RequestParam String ingredient) {
        return smartMenuService.findRecipesByIngredient(ingredient);
    }
}
