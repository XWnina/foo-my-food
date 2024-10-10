package com.foomyfood.foomyfood.database.test_controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.foomyfood.foomyfood.database.UserIngredient;
import com.foomyfood.foomyfood.database.test_service.UserIngredientService;

@RestController
public class UserIngredientController {

    @Autowired
    private UserIngredientService userIngredientService;

    @PostMapping("/user-ingredient/create")
    public UserIngredient createUserIngredient(
            @RequestParam Long userId,
            @RequestParam Long ingredientId,
            @RequestParam int userQuantity) {
        return userIngredientService.createUserIngredient(userId, ingredientId, userQuantity);
    }

}
