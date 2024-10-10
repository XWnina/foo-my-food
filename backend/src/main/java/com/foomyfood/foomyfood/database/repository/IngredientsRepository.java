package com.foomyfood.foomyfood.database.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository; 

import com.foomyfood.foomyfood.database.Ingredients;

@Repository
public interface IngredientsRepository extends JpaRepository<Ingredients, Long> {
    
}

