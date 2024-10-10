package com.foomyfood.foomyfood.database.db_repository;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.foomyfood.foomyfood.database.Ingredient;

@Repository
public interface IngredientRepository extends JpaRepository<Ingredient, Long> {

    // Find ingredient by name
    Optional<Ingredient> findByName(String name);

    // Find ingredients by category
    List<Ingredient> findByCategory(String category);

    // Find all ingredients
    @Override
    List<Ingredient> findAll();

}
