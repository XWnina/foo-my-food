package com.foomyfood.foomyfood.database.db_service;

import java.util.List;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.foomyfood.foomyfood.database.Ingredient;
import com.foomyfood.foomyfood.database.db_repository.IngredientRepository;

@Service
public class IngredientService {

    @Autowired
    private IngredientRepository ingredientRepository;

    // Get all ingredients
    public List<Ingredient> getAllIngredients() {
        return ingredientRepository.findAll();
    }

    // Get ingredient by ID
    public Optional<Ingredient> getIngredientById(Long ingredientId) {
        return ingredientRepository.findById(ingredientId);
    }

    // Create new ingredient
    public Ingredient createIngredient(String name, String category, String imageURL, String storageMethod, int baseQuantity,
                                       String unit, String expirationDate, Boolean isUserCreated, Long createdBy, int calories,
                                       float protein, float fat, float carbohydrates, float fiber) {
        Ingredient ingredient = new Ingredient(name, category, imageURL, storageMethod, baseQuantity, unit, expirationDate,
                                               isUserCreated, createdBy, calories, protein, fat, carbohydrates, fiber);
        return ingredientRepository.save(ingredient);
    }

    // Update ingredient
    public Ingredient updateIngredient(Long ingredientId, String name, String category, String imageURL, String storageMethod,
                                       int baseQuantity, String unit, String expirationDate, Boolean isUserCreated, Long createdBy,
                                       int calories, float protein, float fat, float carbohydrates, float fiber) {
        Optional<Ingredient> optionalIngredient = ingredientRepository.findById(ingredientId);
        if (optionalIngredient.isPresent()) {
            Ingredient ingredient = optionalIngredient.get();
            ingredient.setName(name);
            ingredient.setCategory(category);
            ingredient.setImageURL(imageURL);
            ingredient.setStorageMethod(storageMethod);
            ingredient.setBaseQuantity(baseQuantity);
            ingredient.setUnit(unit);
            ingredient.setExpirationDate(expirationDate);
            ingredient.setIsUserCreated(isUserCreated);
            ingredient.setCreatedBy(createdBy);
            ingredient.setCalories(calories);
            ingredient.setProtein(protein);
            ingredient.setFat(fat);
            ingredient.setCarbohydrates(carbohydrates);
            ingredient.setFiber(fiber);
            return ingredientRepository.save(ingredient);
        } else {
            throw new RuntimeException("Ingredient not found with id " + ingredientId);
        }
    }

    // Delete ingredient
    public void deleteIngredient(Long ingredientId) {
        ingredientRepository.deleteById(ingredientId);
    }

    // Get ingredient by name
    public Optional<Ingredient> getIngredientByName(String name) {
        return ingredientRepository.findByName(name);
    }
    
}
