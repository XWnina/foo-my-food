package com.foomyfood.foomyfood.database.db_repository;

import java.time.LocalDate;
import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.foomyfood.foomyfood.database.CookingHistory;

@Repository
public interface CookingHistoryRepository extends JpaRepository<CookingHistory, Long> {
    List<CookingHistory> findByUserId(Long userId);
    List<CookingHistory> findByRecipeId(Long recipeId);
    long countByRecipeIdAndCookingDateBetween(Long recipeId, LocalDate startDate, LocalDate endDate);
}

