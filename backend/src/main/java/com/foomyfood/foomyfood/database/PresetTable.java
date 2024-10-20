package com.foomyfood.foomyfood.database;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

@Entity
@Table(name = "preset_food")
public class PresetTable {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "ingredientId")
    private Long ingredientId;

    @Column(name = "name", nullable = false)
    private String name;

    @Column(name = "category", nullable = false)
    private String category;

    @Column(name = "storageMethod", nullable = false)
    private String storageMethod;

    @Column(name = "baseQuantity", nullable = false)
    private Double baseQuantity;

    @Column(name = "unit", nullable = false)
    private String unit;

    @Column(name = "expirationDate", nullable = false)
    private int expirationDate; // Represents number of days until expiration

    @Column(name = "calories", nullable = false)
    private int calories;

    @Column(name = "protein", nullable = false)
    private Float protein;

    @Column(name = "fat", nullable = false)
    private Float fat;

    @Column(name = "carbohydrates", nullable = false)
    private Float carbohydrates;

    @Column(name = "fiber", nullable = false)
    private Float fiber;

    //Constructors
    public PresetTable() {
    }

    public PresetTable(Long ingredientId, String name, String category, String storageMethod, double baseQuantity,
            String unit, int expirationDate, int calories, float protein, float fat,
            float carbohydrates, float fiber) {
        this.ingredientId = ingredientId;
        this.name = name;
        this.category = category;
        this.storageMethod = storageMethod;
        this.baseQuantity = baseQuantity;
        this.unit = unit;
        this.expirationDate = expirationDate;
        this.calories = calories;
        this.protein = protein;
        this.fat = fat;
        this.carbohydrates = carbohydrates;
        this.fiber = fiber;
    }

    // Getters and Setters
    public Long getIngredientId() {
        return ingredientId;
    }

    public void setIngredientId(Long ingredientId) {
        this.ingredientId = ingredientId;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getCategory() {
        return category;
    }

    public void setCategory(String category) {
        this.category = category;
    }

    public String getStorageMethod() {
        return storageMethod;
    }

    public void setStorageMethod(String storageMethod) {
        this.storageMethod = storageMethod;
    }

    public Double getBaseQuantity() {
        return baseQuantity;
    }

    public void setBaseQuantity(Double baseQuantity) {
        this.baseQuantity = baseQuantity;
    }

    public String getUnit() {
        return unit;
    }

    public void setUnit(String unit) {
        this.unit = unit;
    }

    public int getExpirationDate() {
        return expirationDate;
    }

    public void setExpirationDate(int expirationDate) {
        this.expirationDate = expirationDate;
    }

    public int getCalories() {
        return calories;
    }

    public void setCalories(int calories) {
        this.calories = calories;
    }

    public Float getProtein() {
        return protein;
    }

    public void setProtein(Float protein) {
        this.protein = protein;
    }

    public Float getFat() {
        return fat;
    }

    public void setFat(Float fat) {
        this.fat = fat;
    }

    public Float getCarbohydrates() {
        return carbohydrates;
    }

    public void setCarbohydrates(Float carbohydrates) {
        this.carbohydrates = carbohydrates;
    }

    public Float getFiber() {
        return fiber;
    }

    public void setFiber(Float fiber) {
        this.fiber = fiber;
    }

}
