package com.foomyfood.foomyfood.database.db_repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.foomyfood.foomyfood.database.Recipe;

@Repository
public interface RecipeRepository extends JpaRepository<Recipe, Long> {
}
