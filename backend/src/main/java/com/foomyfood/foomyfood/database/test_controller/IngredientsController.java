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
    private IngredientsService ingredientService;

    @PostMapping("/ingredient/create")
    public Ingredients createIngredient(@RequestBody Ingredients ingredient) {
        Ingredients newIngredient = new Ingredients();
        newIngredient.setName(ingredient.getName());
        newIngredient.setCategory(ingredient.getCategory());
        newIngredient.setImageURL(ingredient.getImageURL());
        newIngredient.setStorageMethod(ingredient.getStorageMethod());
        newIngredient.setBaseQuantity(ingredient.getBaseQuantity());
        newIngredient.setUnit(ingredient.getUnit());
        newIngredient.setExpirationDate(ingredient.getExpirationDate());
        newIngredient.setIsUserCreated(ingredient.getIsUserCreated());
        newIngredient.setCreatedBy(ingredient.getCreatedBy());
        newIngredient.setCalories(ingredient.getCalories());
        newIngredient.setProtein(ingredient.getProtein());
        newIngredient.setFat(ingredient.getFat());
        newIngredient.setCarbohydrates(ingredient.getCarbohydrates());
        newIngredient.setFiber(ingredient.getFiber());

        return ingredientService.saveIngredient(newIngredient);
    }
}
