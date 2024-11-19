package com.foomyfood.foomyfood.database;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

@Entity
@Table(name = "shopping_list")
public class ShoppingList {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "food_id", nullable = false, unique = true)
    private Long foodId;

    @Column(name = "user_id", nullable = false)
    private Long userId;

    @Column(name = "name", nullable = false, length = 100)
    private String name;

    @Column(name = "base_quantity", nullable = false)
    private int baseQuantity;

    @Column(name = "unit", nullable = false, length = 20)
    private String unit;

    @Column(name = "is_purchased", nullable = false)
    private Boolean isPurchased;

    @Column(name = "category", nullable = false)
    private String category;

    // Constructors
    public ShoppingList() {
    }

    public ShoppingList(Long userId, String name, int baseQuantity, String unit, Boolean isPurchased, String category) {
        this.userId = userId;
        this.name = name;
        this.baseQuantity = baseQuantity;
        this.unit = unit;
        this.isPurchased = isPurchased;
        this.category = category;
    }

    // Getters and Setters
    public Long getFoodId() {
        return foodId;
    }

    public Long getUserId() {
        return userId;
    }

    public void setUserId(Long userId) {
        this.userId = userId;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public int getBaseQuantity() {
        return baseQuantity;
    }

    public void setBaseQuantity(int baseQuantity) {
        this.baseQuantity = baseQuantity;
    }

    public String getUnit() {
        return unit;
    }

    public void setUnit(String unit) {
        this.unit = unit;
    }

    public Boolean getIsPurchased() {
        return isPurchased;
    }

    public void setIsPurchased(Boolean isPurchased) {
        this.isPurchased = isPurchased;
    }

    public String getCategory() {
        return category;
    }

    public void setCategory(String category) {
        this.category = category;
    }

}
