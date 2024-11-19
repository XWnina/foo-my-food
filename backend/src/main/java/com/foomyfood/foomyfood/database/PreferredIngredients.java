package com.foomyfood.foomyfood.database;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

@Entity
@Table(name = "preferred_ingredients")
public class PreferredIngredients {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "user_id", nullable = false)
    private Long userId;

    @Column(name = "ingredient", nullable = false)
    private String ingredient;

    @Column(name = "total_cooking_time", nullable = false)
    private int totalCookingCount = 0;

    // Constructors
    public PreferredIngredients() {}

    public PreferredIngredients(Long userId, String ingredient, int totalCookingCount) {
        this.userId = userId;
        this.ingredient = ingredient;
        this.totalCookingCount = totalCookingCount;
    }

    // Getters and Setters
    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public Long getUserId() {
        return userId;
    }

    public void setUserId(Long userId) {
        this.userId = userId;
    }

    public String getIngredient() {
        return ingredient;
    }

    public void setIngredient(String ingredient) {
        this.ingredient = ingredient;
    }

    public int getTotalCookingCount() {
        return totalCookingCount;
    }

    public void setTotalCookingCount(int totalCookingCount) {
        this.totalCookingCount = totalCookingCount;
    }

    @Override
    public String toString() {
        return "PreferredIngredients{" +
                "id=" + id +
                ", userId=" + userId +
                ", ingredient='" + ingredient + '\'' +
                ", totalCookingCount=" + totalCookingCount +
                '}';
    }
}
