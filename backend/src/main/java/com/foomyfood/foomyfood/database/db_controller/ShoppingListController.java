package com.foomyfood.foomyfood.database.db_controller;

import java.util.List;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.foomyfood.foomyfood.database.ShoppingList;
import com.foomyfood.foomyfood.database.db_service.ShoppingListService;

@RestController
@RequestMapping("/api/shopping-list")
public class ShoppingListController {

    @Autowired
    private ShoppingListService shoppingListService;

    @GetMapping
    public List<ShoppingList> getAllItems() {
        return shoppingListService.getAllItems();
    }

    @GetMapping("/user/{userId}")
    public List<ShoppingList> getItemsByUserId(@PathVariable Long userId) {
        return shoppingListService.getItemsByUserId(userId);
    }

    @GetMapping("/{foodId}")
    public ResponseEntity<ShoppingList> getItemById(@PathVariable Long foodId) {
        Optional<ShoppingList> item = shoppingListService.getItemById(foodId);
        return item.map(ResponseEntity::ok).orElseGet(() -> ResponseEntity.notFound().build());
    }

    @PostMapping
    public ShoppingList addItem(@RequestBody ShoppingList shoppingList) {
        return shoppingListService.createItem(shoppingList);
    }

    @PutMapping("/{foodId}")
    public ResponseEntity<ShoppingList> updateItem(@PathVariable Long foodId, @RequestBody ShoppingList shoppingList) {
        try {
            ShoppingList updatedItem = shoppingListService.updateItem(foodId, shoppingList);
            return ResponseEntity.ok(updatedItem);
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }

    @DeleteMapping("/{foodId}")
    public ResponseEntity<Void> deleteItem(@PathVariable Long foodId) {
        shoppingListService.deleteItem(foodId);
        return ResponseEntity.noContent().build();
    }
    @PutMapping("/{foodId}/isPurchased")
    public ResponseEntity<ShoppingList> updateIsPurchased(@PathVariable Long foodId, @RequestBody Boolean isPurchased) {
        try {
            ShoppingList updatedItem = shoppingListService.updateIsPurchased(foodId, isPurchased);
            return ResponseEntity.ok(updatedItem);
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }
}
