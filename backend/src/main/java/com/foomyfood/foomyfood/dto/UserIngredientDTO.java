package com.foomyfood.foomyfood.dto;

import com.foomyfood.foomyfood.database.UserIngredient;
import com.fasterxml.jackson.annotation.JsonProperty;

public class UserIngredientDTO {

    @JsonProperty("userIngredientId")
    private Long userIngredientId;

    @JsonProperty("userId")
    private Long userId; // FK to Users

    @JsonProperty("ingredientId")
    private Long ingredientId; // FK to Ingredients

    @JsonProperty("userQuantity")
    private int userQuantity;

    // Constructor that accepts a UserIngredient entity
    public UserIngredientDTO(UserIngredient userIngredient) {
        this.userIngredientId = userIngredient.getUserIngredientId();
        this.userId = userIngredient.getUserId();
        this.ingredientId = userIngredient.getIngredientId();
        this.userQuantity = userIngredient.getUserQuantity();
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