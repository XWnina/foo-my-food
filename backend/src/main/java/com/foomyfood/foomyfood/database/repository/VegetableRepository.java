package com.foomyfood.foomyfood.database.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;  // 引入User实体类

import com.foomyfood.foomyfood.database.Vegetable;

@Repository
public interface VegetableRepository extends JpaRepository<Vegetable, Long> {
    
}

