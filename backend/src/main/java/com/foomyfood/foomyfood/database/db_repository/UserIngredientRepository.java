package com.foomyfood.foomyfood.database.db_repository;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.foomyfood.foomyfood.database.UserIngredient;

@Repository
public interface UserIngredientRepository extends JpaRepository<UserIngredient, Long> {

    // Find all UserIngredients by userId
    List<UserIngredient> findAllByUserId(Long userId);

    // Find a specific UserIngredient by userId and ingredientId
    Optional<UserIngredient> findByUserIdAndIngredientId(Long userId, Long ingredientId);

    // Query by ingredientId
    List<UserIngredient> findByIngredientId(Long ingredientId);
    
}
