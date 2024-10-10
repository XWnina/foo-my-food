package com.foomyfood.foomyfood.database.repository;
import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.foomyfood.foomyfood.database.UserIngredient;

@Repository
public interface UserIngredientRepository extends JpaRepository<UserIngredient, Long> {
    List<UserIngredient> findAllByUserId(Long userId);
}
