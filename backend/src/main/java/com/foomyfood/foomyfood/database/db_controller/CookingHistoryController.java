package com.foomyfood.foomyfood.database.db_controller;

import java.time.LocalDate;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeFormatterBuilder;
import java.time.temporal.ChronoField;

import com.foomyfood.foomyfood.database.CookingHistory;
import com.foomyfood.foomyfood.database.db_service.CookingHistoryService;

@RestController
@RequestMapping("/api/cooking_history")
public class CookingHistoryController {

    @Autowired
    private CookingHistoryService cookingHistoryService;

    // Add a new CookingHistory entry
    @PostMapping
    public ResponseEntity<CookingHistory> addCookingHistory(
            @RequestParam Long userId,
            @RequestParam Long recipeId,
            @RequestParam String cookingDate // Pass date as a string in 'yyyy-MM-dd' format
    ) {
        System.out.println("Received userId: " + userId);
        System.out.println("Received recipeId: " + recipeId);
        System.out.println("Received cookingDate: " + cookingDate);
        DateTimeFormatter formatter = new DateTimeFormatterBuilder()
                .appendPattern("yyyy-MM-dd")
                .optionalStart()
                .appendValue(ChronoField.MONTH_OF_YEAR, 1) // 允许月份和日期的单个数字格式
                .optionalEnd()
                .toFormatter();

        LocalDate date = LocalDate.parse(cookingDate, formatter);
        //LocalDate date = LocalDate.parse(cookingDate);
        CookingHistory cookingHistory = cookingHistoryService.addCookingHistory(userId, recipeId, date);
        return new ResponseEntity<>(cookingHistory, HttpStatus.CREATED);
    }

    // Get all CookingHistory entries for a specific user
    @GetMapping("/user/{userId}")
    public ResponseEntity<List<CookingHistory>> getAllCookingHistoryByUserId(@PathVariable Long userId) {
        List<CookingHistory> cookingHistories = cookingHistoryService.getAllCookingHistoryByUserId(userId);
        return ResponseEntity.ok(cookingHistories);
    }

    // Get all CookingHistory entries for a specific recipe
    @GetMapping("/recipe/{recipeId}")
    public ResponseEntity<List<CookingHistory>> getAllCookingHistoryByRecipeId(@PathVariable Long recipeId) {
        List<CookingHistory> cookingHistories = cookingHistoryService.getAllCookingHistoryByRecipeId(recipeId);
        return ResponseEntity.ok(cookingHistories);
    }

    // Delete a CookingHistory entry by ID
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteCookingHistoryById(@PathVariable Long id) {
        cookingHistoryService.deleteCookingHistoryById(id);
        return ResponseEntity.noContent().build();
    }
    
}
