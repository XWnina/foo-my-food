package com.foomyfood.foomyfood.service;

import com.foomyfood.foomyfood.database.Ingredient;
import com.foomyfood.foomyfood.database.repository.IngredientRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;
import java.util.Optional;
import java.io.File;
import java.io.IOException;

@Service
public class IngredientService {

    @Autowired
    private IngredientRepository ingredientRepository;

    // Create a new ingredient
    public Ingredient createIngredient(String name, String category,String imageURL,String StorageMethod,int baseQuantity, String unit, String expirationDate, Boolean isUserCreated, Long createdBy, int calories, float protein, float fat, float carbohydrates, float fiber) {
        Ingredient ingredient = new Ingredient(name, category,imageURL,StorageMethod, baseQuantity, unit, expirationDate, isUserCreated, createdBy, calories, protein, fat, carbohydrates, fiber);
        return ingredientRepository.save(ingredient);
    }

    // Get all ingredients
    public List<Ingredient> getAllIngredients() {
        return ingredientRepository.findAll();
    }

    // Find ingredient by ID
    public Optional<Ingredient> getIngredientById(Long id) {
        return ingredientRepository.findById(id);
    }

    // Update an existing ingredient
    public Ingredient updateIngredient(Long id, String name, String category,  String imageURL,String StorageMethod,int baseQuantity, String unit, String expirationDate, Boolean isUserCreated, Long createdBy, int calories, float protein, float fat, float carbohydrates, float fiber) {
        Optional<Ingredient> optionalIngredient = ingredientRepository.findById(id);
        
        if (optionalIngredient.isPresent()) {
            Ingredient ingredient = optionalIngredient.get();
            ingredient.setName(name);
            ingredient.setCategory(category);
            ingredient.setImageURL(imageURL);
            ingredient.setStorageMethod(StorageMethod);
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
            throw new RuntimeException("Ingredient not found");
        }
    }

    // Delete ingredient by ID
    public void deleteIngredient(Long id) {
        ingredientRepository.deleteById(id);
    }

    // Find ingredient by name
    public Optional<Ingredient> getIngredientByName(String name) {
        return ingredientRepository.findByName(name);
    }

}