package com.foomyfood.foomyfood.controller;

import java.util.List;
import java.util.Optional;

import com.foomyfood.foomyfood.database.Ingredient;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import com.foomyfood.foomyfood.database.ShoppingList;
import com.foomyfood.foomyfood.service.MyShoppingListService;

@RestController
@RequestMapping("/api/my-shopping-list")
public class MyShoppingListController {

    @Autowired
    private MyShoppingListService myShoppingListService;

    // 获取特定用户的所有项目
    @GetMapping("/user/{userId}")
    public List<ShoppingList> getItemsByUserId(@PathVariable Long userId) {
        return myShoppingListService.getItemsByUserId(userId);
    }

    // 根据 foodId 和 userId 获取单个项目
    @GetMapping("/{foodId}/user/{userId}")
    public ResponseEntity<ShoppingList> getItemByIdAndUserId(
            @PathVariable Long foodId, @PathVariable Long userId) {
        Optional<ShoppingList> item = myShoppingListService.getItemByIdAndUserId(foodId, userId);
        return item.map(ResponseEntity::ok).orElseGet(() -> ResponseEntity.notFound().build());
    }

    // 添加新项目
    @PostMapping
    public ResponseEntity<?> addItem(@RequestBody ShoppingList shoppingList) {
        Optional<Ingredient> existingIngredient = myShoppingListService.checkIfItemExists(shoppingList.getUserId(), shoppingList.getName());
        if (existingIngredient.isPresent()) {
            return ResponseEntity.status(HttpStatus.CONFLICT).body(existingIngredient.get()); // 返回完整的冲突项信息
        }
        ShoppingList createdItem = myShoppingListService.createItem(shoppingList);
        return ResponseEntity.ok(createdItem);
    }



    // 无重复检查的添加方法
    @PostMapping("/force-add")
    public ResponseEntity<ShoppingList> forceAddItem(@RequestBody ShoppingList shoppingList) {
        ShoppingList createdItem = myShoppingListService.createItem(shoppingList);
        return ResponseEntity.ok(createdItem);
    }



    // 更新项目，根据 foodId 和 userId
    @PutMapping("/{foodId}/user/{userId}")
    public ResponseEntity<ShoppingList> updateItem(
            @PathVariable Long foodId, @PathVariable Long userId, @RequestBody ShoppingList shoppingList) {
        try {
            ShoppingList updatedItem = myShoppingListService.updateItem(foodId, userId, shoppingList);
            return ResponseEntity.ok(updatedItem);
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }

    // 更新购买状态
    @PutMapping("/{foodId}/user/{userId}/isPurchased")
    public ResponseEntity<ShoppingList> updateIsPurchased(
            @PathVariable Long foodId, @PathVariable Long userId, @RequestBody Boolean isPurchased) {
        try {
            ShoppingList updatedItem = myShoppingListService.updateIsPurchased(foodId, userId, isPurchased);
            return ResponseEntity.ok(updatedItem);
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }

    // 删除项目
    @DeleteMapping("/{foodId}/user/{userId}")
    public ResponseEntity<Void> deleteItem(@PathVariable Long foodId, @PathVariable Long userId) {
        try {
            myShoppingListService.deleteItem(foodId, userId);
            return ResponseEntity.noContent().build();
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }
}
