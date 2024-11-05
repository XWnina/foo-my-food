package com.foomyfood.foomyfood.controller;

import java.util.List;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
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
    public ShoppingList addItem(@RequestBody ShoppingList shoppingList) {
        return myShoppingListService.createItem(shoppingList);
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
