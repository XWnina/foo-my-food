package com.foomyfood.foomyfood.database.db_repository;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.foomyfood.foomyfood.database.ShoppingList;

@Repository
public interface ShoppingListRepository extends JpaRepository<ShoppingList, Long> {

    List<ShoppingList> findByUserId(Long userId);

    Optional<ShoppingList> findByFoodIdAndUserId(Long foodId, Long userId);
}
