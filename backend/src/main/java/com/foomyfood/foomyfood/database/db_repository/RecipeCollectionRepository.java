package com.foomyfood.foomyfood.database.db_repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.foomyfood.foomyfood.database.RecipeCollection;

@Repository
public interface RecipeCollectionRepository extends JpaRepository<RecipeCollection, Long> {

    List<RecipeCollection> findByUserId(Long userId);

    void deleteByUserIdAndRecipeIdAndPresetRecipeId(Long userId, Long recipeId, Long presetRecipeId);
}
