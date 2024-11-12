package com.foomyfood.foomyfood.database.db_service;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.foomyfood.foomyfood.database.RecipeCollection;
import com.foomyfood.foomyfood.database.db_repository.RecipeCollectionRepository;

@Service
public class RecipeCollectionService {

    private final RecipeCollectionRepository recipeCollectionRepository;

    @Autowired
    public RecipeCollectionService(RecipeCollectionRepository recipeCollectionRepository) {
        this.recipeCollectionRepository = recipeCollectionRepository;
    }

    public List<RecipeCollection> getRecipesByUserId(Long userId) {
        return recipeCollectionRepository.findByUserId(userId);
    }

    public RecipeCollection saveRecipe(RecipeCollection recipeCollection) {
        if ((recipeCollection.getRecipeId() != null && recipeCollection.getPresetRecipeId() != null) ||
            (recipeCollection.getRecipeId() == null && recipeCollection.getPresetRecipeId() == null)) {
            throw new IllegalArgumentException("Exactly one of recipeId or presetRecipeId must be provided.");
        }
        return recipeCollectionRepository.save(recipeCollection);
    }

    @Transactional
    public void deleteRecipe(Long userId, Long recipeId, Long presetRecipeId) {
        recipeCollectionRepository.deleteByUserIdAndRecipeIdAndPresetRecipeId(userId, recipeId, presetRecipeId);
    }
}
