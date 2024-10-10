package com.foomyfood.foomyfood.database.repository;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.foomyfood.foomyfood.database.UserIngredient;

@Repository
public interface UserIngredientRepository extends JpaRepository<UserIngredient, Long> {

    // 根据用户 ID 和食材 ID 查找用户食材
    Optional<UserIngredient> findByUserIdAndIngredientId(Long userId, Long ingredientId);
    
    // 根据用户 ID 查找所有用户食材
    List<UserIngredient> findByUserId(Long userId);
}