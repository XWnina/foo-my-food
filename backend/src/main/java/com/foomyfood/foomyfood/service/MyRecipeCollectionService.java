package com.foomyfood.foomyfood.service;

import com.foomyfood.foomyfood.database.RecipeCollection;
import com.foomyfood.foomyfood.database.db_repository.RecipeCollectionRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class MyRecipeCollectionService {

    @Autowired
    private RecipeCollectionRepository recipeCollectionRepository;

    // 添加收藏
    public void addFavorite(Long userId, Long recipeId, Long presetRecipeId) {
        // 检查收藏是否已存在，避免重复
        Optional<RecipeCollection> existingFavorite = recipeCollectionRepository.findByUserIdAndRecipeIdAndPresetRecipeId(userId, recipeId, presetRecipeId);
        if (existingFavorite.isEmpty()) {
            RecipeCollection newFavorite = new RecipeCollection(userId, recipeId, presetRecipeId);
            recipeCollectionRepository.save(newFavorite);
        }
    }

    // 删除收藏
    public void removeFavorite(Long userId, Long recipeId, Long presetRecipeId) {
        Optional<RecipeCollection> favorite = recipeCollectionRepository.findByUserIdAndRecipeIdAndPresetRecipeId(userId, recipeId, presetRecipeId);
        favorite.ifPresent(recipeCollectionRepository::delete);
    }

    // 获取用户的收藏
    public List<RecipeCollection> getUserFavorites(Long userId) {
        return recipeCollectionRepository.findByUserId(userId);
    }
}
