package com.foomyfood.foomyfood.dto;

import com.foomyfood.foomyfood.database.Ingredient;
import com.fasterxml.jackson.annotation.JsonProperty;

public class IngredientDTO {

    @JsonProperty("ingredientId")
    private Long ingredientId;

    @JsonProperty("name")
    private String name;

    @JsonProperty("category")
    private String category;

    @JsonProperty("imageURL")
    private String imageURL;

    @JsonProperty("StorageMethod")
    private String StorageMethod;

    @JsonProperty("baseQuantity")
    private int baseQuantity;

    @JsonProperty("unit")
    private String unit;

    @JsonProperty("expirationDate")
    private String expirationDate;

    @JsonProperty("isUserCreated")
    private Boolean isUserCreated;

    @JsonProperty("createdBy")
    private Long createdBy; // FK to Users

    @JsonProperty("calories")
    private int calories;

    @JsonProperty("protein")
    private float protein;

    @JsonProperty("fat")
    private float fat;

    @JsonProperty("carbohydrates")
    private float carbohydrates;

    @JsonProperty("fiber")
    private float fiber;

    // Constructor that accepts an Ingredient entity
    public IngredientDTO(Ingredient ingredient) {
        this.ingredientId = ingredient.getIngredientId();
        this.name = ingredient.getName();
        this.category = ingredient.getCategory();
        this.imageURL = ingredient.getImageURL();
        this.StorageMethod = ingredient.getStorageMethod();
        this.baseQuantity = ingredient.getBaseQuantity();
        this.unit = ingredient.getUnit();
        this.expirationDate = ingredient.getExpirationDate();
        this.isUserCreated = ingredient.getIsUserCreated();
        this.createdBy = ingredient.getCreatedBy();
        this.calories = ingredient.getCalories();
        this.protein = ingredient.getProtein();
        this.fat = ingredient.getFat();
        this.carbohydrates = ingredient.getCarbohydrates();
        this.fiber = ingredient.getFiber();
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
    public String getImageURL() {
        return imageURL;
    }

    public void setImageURL(String imageURL) {
        this.imageURL = imageURL;
    }

    public String getStorageMethod() {
        return StorageMethod;
    }

    public void setStorageMethod(String StorageMethod) {
        this.StorageMethod = StorageMethod;
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

    public String getExpirationDate() {
        return expirationDate;
    }

    public void setExpirationDate(String expirationDate) {
        this.expirationDate = expirationDate;
    }

    public Boolean getIsUserCreated() {
        return isUserCreated;
    }

    public void setIsUserCreated(Boolean isUserCreated) {
        this.isUserCreated = isUserCreated;
    }

    public Long getCreatedBy() {
        return createdBy;
    }

    public void setCreatedBy(Long createdBy) {
        this.createdBy = createdBy;
    }

    public int getCalories() {
        return calories;
    }

    public void setCalories(int calories) {
        this.calories = calories;
    }

    public float getProtein() {
        return protein;
    }

    public void setProtein(float protein) {
        this.protein = protein;
    }

    public float getFat() {
        return fat;
    }

    public void setFat(float fat) {
        this.fat = fat;
    }

    public float getCarbohydrates() {
        return carbohydrates;
    }

    public void setCarbohydrates(float carbohydrates) {
        this.carbohydrates = carbohydrates;
    }

    public float getFiber() {
        return fiber;
    }

    public void setFiber(float fiber) {
        this.fiber = fiber;
    }
}