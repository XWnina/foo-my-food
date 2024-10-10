package com.foomyfood.foomyfood.database;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

@Entity
@Table(name = "user_ingredients")
public class UserIngredient {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long userIngredientId;

    @Column(name = "user_id")
    private Long userId; // FK to Users table

    @Column(name = "ingredient_id")
    private Long ingredientId; // FK to Ingredients table

    @Column(name = "user_quantity")
    private int userQuantity;

    // Constructors
    public UserIngredient() {
    }

    public UserIngredient(Long userId, Long ingredientId, int userQuantity) {
        this.userId = userId;
        this.ingredientId = ingredientId;
        this.userQuantity = userQuantity;
    }

    // Getters and Setters
    public Long getUserIngredientId() {
        return userIngredientId;
    }

    public void setUserIngredientId(Long userIngredientId) {
        this.userIngredientId = userIngredientId;
    }

    public Long getUserId() {
        return userId;
    }

    public void setUserId(Long userId) {
        this.userId = userId;
    }

    public Long getIngredientId() {
        return ingredientId;
    }

    public void setIngredientId(Long ingredientId) {
        this.ingredientId = ingredientId;
    }

    public int getUserQuantity() {
        return userQuantity;
    }

    public void setUserQuantity(int userQuantity) {
        this.userQuantity = userQuantity;
    }
}


