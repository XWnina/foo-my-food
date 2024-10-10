package com.foomyfood.foomyfood.database.test_controller;


import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

import com.foomyfood.foomyfood.database.Ingredients;
import com.foomyfood.foomyfood.database.test_service.IngredientsService;

@RestController
public class IngredientsController {

    @Autowired
    private IngredientsService IngredientsService;

    @PostMapping("/ingredient creation")
    public Ingredients createIngredient(@RequestBody Ingredients ingredient) {
        return IngredientsService.createIngredients(ingredient.getName(), ingredient.getCategory(), ingredient.getShelfLife(), ingredient.getStorageType());
    }
}

