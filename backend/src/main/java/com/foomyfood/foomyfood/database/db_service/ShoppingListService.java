package com.foomyfood.foomyfood.database.db_service;

import java.util.List;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.foomyfood.foomyfood.database.ShoppingList;
import com.foomyfood.foomyfood.database.db_repository.ShoppingListRepository;

@Service
public class ShoppingListService {

    @Autowired
    private ShoppingListRepository shoppingListRepository;

    public List<ShoppingList> getAllItems() {
        return shoppingListRepository.findAll();
    }

    public List<ShoppingList> getItemsByUserId(Long userId) {
        return shoppingListRepository.findByUserId(userId);
    }

    
    public Optional<ShoppingList> getItemById(Long foodId) {
        return shoppingListRepository.findById(foodId);
    }

    public ShoppingList createItem(ShoppingList shoppingList) {
        return shoppingListRepository.save(shoppingList);
    }

    public ShoppingList updateItem(Long foodId, ShoppingList shoppingList) {
        Optional<ShoppingList> existingItem = shoppingListRepository.findById(foodId);
        if (existingItem.isPresent()) {
            ShoppingList updatedItem = existingItem.get();
            updatedItem.setUserId(shoppingList.getUserId());
            updatedItem.setName(shoppingList.getName());
            updatedItem.setBaseQuantity(shoppingList.getBaseQuantity());
            updatedItem.setUnit(shoppingList.getUnit());
            updatedItem.setIsPurchased(shoppingList.getIsPurchased());
            return shoppingListRepository.save(updatedItem);
        } else {
            throw new RuntimeException("Item with ID " + foodId + " not found");
        }
    }
    public ShoppingList updateIsPurchased(Long foodId, Boolean isPurchased) {
        Optional<ShoppingList> existingItem = shoppingListRepository.findById(foodId);
        if (existingItem.isPresent()) {
            ShoppingList updatedItem = existingItem.get();

            // 更新 isPurchased 字段
            updatedItem.setIsPurchased(isPurchased);

            return shoppingListRepository.save(updatedItem);
        } else {
            throw new RuntimeException("Item with ID " + foodId + " not found");
        }
    }

    public void deleteItem(Long foodId) {
        shoppingListRepository.deleteById(foodId);
    }
}
