package com.foomyfood.foomyfood.service;

import com.foomyfood.foomyfood.database.RecipeCollection;
import com.foomyfood.foomyfood.database.db_repository.PresetRecipeRepository;
import com.foomyfood.foomyfood.database.db_repository.RecipeCollectionRepository;
import com.foomyfood.foomyfood.database.db_repository.RecipeRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Objects;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
public class MyRecipeCollectionService {

    @Autowired
    private RecipeCollectionRepository recipeCollectionRepository;
    @Autowired
    private RecipeRepository recipeRepository;

    @Autowired
    private PresetRecipeRepository presetRecipeRepository;

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
    // 获取用户的所有收藏（只返回一个食谱或预设食谱，不同时返回）
    public List<Object> getUserFavoritesAll(Long userId) {
        List<RecipeCollection> userFavorites = recipeCollectionRepository.findByUserId(userId);

        // 获取所有食谱和预设食谱信息，确保每个收藏项只返回一个类型
        List<Object> favorites = userFavorites.stream()
                .map(favorite -> {
                    if (favorite.getRecipeId() != null) {
                        // 如果 recipeId 存在，则返回 Recipe 对象
                        return recipeRepository.findById(favorite.getRecipeId()).orElse(null);
                    } else if (favorite.getPresetRecipeId() != null) {
                        // 如果 presetRecipeId 存在，则返回 PresetRecipe 对象
                        return presetRecipeRepository.findById(favorite.getPresetRecipeId()).orElse(null);
                    } else {
                        return null;  // 如果两者都不存在，返回 null
                    }
                })
                .filter(Objects::nonNull)  // 过滤掉 null 值
                .collect(Collectors.toList());

        return favorites;
    }

}
