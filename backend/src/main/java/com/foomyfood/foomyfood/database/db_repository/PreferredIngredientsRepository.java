package com.foomyfood.foomyfood.database.db_repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.foomyfood.foomyfood.database.PreferredIngredients;

@Repository
public interface PreferredIngredientsRepository extends JpaRepository<PreferredIngredients, Long> {

    List<PreferredIngredients> findByUserId(Long userId);

    PreferredIngredients findByUserIdAndIngredient(Long userId, String ingredient);
}
