package com.foomyfood.foomyfood.database.test_service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.foomyfood.foomyfood.database.Ingredients;
import com.foomyfood.foomyfood.database.repository.IngredientsRepository;

@Service
public class IngredientsService {

    @Autowired
    private IngredientsRepository IngredientRepository;

    public Ingredients createIngredient(String name, String category, String imageURL, String StorageMethod, int baseQuantity, String unit, String expirationDate, Boolean isUserCreated, Long createdBy, int calories, float protein, float fat, float carbohydrates, float fiber) {
        Ingredients item = new Ingredients(name, category, imageURL, StorageMethod, baseQuantity, unit, expirationDate, isUserCreated, createdBy, calories, protein, fat, carbohydrates, fiber);
        return IngredientRepository.save(item);
    }

    public Ingredients saveIngredient(Ingredients ingredient) {
        return IngredientRepository.save(ingredient);
    }
}
