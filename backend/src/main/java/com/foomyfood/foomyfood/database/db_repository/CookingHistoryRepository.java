package com.foomyfood.foomyfood.database.db_repository;

import java.time.LocalDate;
import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import com.foomyfood.foomyfood.database.CookingHistory;

import jakarta.transaction.Transactional;

@Repository
public interface CookingHistoryRepository extends JpaRepository<CookingHistory, Long> {

    List<CookingHistory> findByUserId(Long userId);

    List<CookingHistory> findByRecipeId(Long recipeId);

    long countByRecipeIdAndCookingDateBetween(Long recipeId, LocalDate startDate, LocalDate endDate);

    @Transactional
    @Modifying
    @Query("DELETE FROM CookingHistory ch WHERE ch.recipe.id = :recipeId")
    void deleteByRecipeId(Long recipeId);
}
