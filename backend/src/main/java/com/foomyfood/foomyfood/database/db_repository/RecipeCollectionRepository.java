package com.foomyfood.foomyfood.database.db_repository;

import com.foomyfood.foomyfood.database.RecipeCollection;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface RecipeCollectionRepository extends JpaRepository<RecipeCollection, Long> {
    Optional<RecipeCollection> findByUserIdAndRecipeIdAndPresetRecipeId(Long userId, Long recipeId, Long presetRecipeId);
    List<RecipeCollection> findByUserId(Long userId);

    void deleteByUserIdAndRecipeIdAndPresetRecipeId(Long userId, Long recipeId, Long presetRecipeId);
    void deleteByRecipeId(Long recipeId);
}
