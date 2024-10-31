package com.foomyfood.foomyfood.database;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

@Entity
@Table(name = "user_recipes")
public class UserRecipe {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long userIngredientId;

    @Column(name = "user_id")
    private Long userId; // FK to Users table

    @Column(name = "recipe_id")
    private Long recipeId; // FK to Recipes table

    @Column(name = "user_cooked_times")
    private Integer userCookedTimes;

    // Default constructor
    public UserRecipe() {
    }

    // Parameterized constructor
    public UserRecipe(Long userId, Long recipeId, int userCookedTimes) {
        this.userId = userId;
        this.recipeId = recipeId;
        this.userCookedTimes = userCookedTimes;
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

    public Long getRecipeId() {
        return recipeId;
    }

    public void setRecipeId(Long recipeId) {
        this.recipeId = recipeId;
    }

    public int getUserCookedTimes() {
        return userCookedTimes;
    }

    public void setUserCookedTimes(int userCookedTimes) {
        this.userCookedTimes = userCookedTimes;
    }

    @Override
    public String toString() {
        return "UserRecipe{"
                + "userIngredientId=" + userIngredientId
                + ", userId=" + userId
                + ", recipeId=" + recipeId
                + ", userCookedTimes=" + userCookedTimes
                + '}';
    }
}
