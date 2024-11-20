package com.foomyfood.foomyfood.service;

import java.util.List;
import java.util.Optional;

import com.foomyfood.foomyfood.database.Ingredient;
import com.foomyfood.foomyfood.database.db_service.UserIngredientService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.foomyfood.foomyfood.database.ShoppingList;
import com.foomyfood.foomyfood.database.db_repository.ShoppingListRepository;

@Service
public class MyShoppingListService {

    @Autowired
    private ShoppingListRepository shoppingListRepository;

    @Autowired
    private UserIngredientService userIngredientService;

    // 根据 userId 获取所有项目
    public List<ShoppingList> getItemsByUserId(Long userId) {
        return shoppingListRepository.findByUserId(userId);
    }

    // 根据 foodId 和 userId 获取特定项目
    public Optional<ShoppingList> getItemByIdAndUserId(Long foodId, Long userId) {
        return shoppingListRepository.findByFoodIdAndUserId(foodId, userId);
    }

    // 创建新项目
    public ShoppingList createItem(ShoppingList shoppingList) {
        return shoppingListRepository.save(shoppingList);
    }

    // 更新项目，确保只更新属于该用户的项目
    public ShoppingList updateItem(Long foodId, Long userId, ShoppingList shoppingList) {
        Optional<ShoppingList> existingItem = shoppingListRepository.findByFoodIdAndUserId(foodId, userId);
        if (existingItem.isPresent()) {
            ShoppingList updatedItem = existingItem.get();
            updatedItem.setName(shoppingList.getName());
            updatedItem.setBaseQuantity(shoppingList.getBaseQuantity());
            updatedItem.setUnit(shoppingList.getUnit());
            updatedItem.setIsPurchased(shoppingList.getIsPurchased());
            updatedItem.setCategory(shoppingList.getCategory());
            return shoppingListRepository.save(updatedItem);
        } else {
            throw new RuntimeException("Item with ID " + foodId + " and userId " + userId + " not found");
        }
    }

    // 更新项目的 isPurchased 字段，确保项目属于该用户
    public ShoppingList updateIsPurchased(Long foodId, Long userId, Boolean isPurchased) {
        Optional<ShoppingList> existingItem = shoppingListRepository.findByFoodIdAndUserId(foodId, userId);
        if (existingItem.isPresent()) {
            ShoppingList updatedItem = existingItem.get();
            updatedItem.setIsPurchased(isPurchased);
            return shoppingListRepository.save(updatedItem);
        } else {
            throw new RuntimeException("Item with ID " + foodId + " and userId " + userId + " not found");
        }
    }

    // 删除项目，确保项目属于该用户
    public void deleteItem(Long foodId, Long userId) {
        Optional<ShoppingList> existingItem = shoppingListRepository.findByFoodIdAndUserId(foodId, userId);
        if (existingItem.isPresent()) {
            shoppingListRepository.delete(existingItem.get());
        } else {
            throw new RuntimeException("Item with ID " + foodId + " and userId " + userId + " not found");
        }
    }

    public Optional<Ingredient> checkIfItemExists(Long userId, String name) {
        return userIngredientService.checkUserCreatedIngredient(userId, name);
    }

}