package com.foomyfood.foomyfood.database;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

@Entity
@Table(name = "ingredients")
public class Ingredient {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long ingredientId;

    @Column(name = "name")
    private String name;

    @Column(name = "category")
    private String category;

    @Column(name = "imageURL")
    private String imageURL;

    @Column(name = "StorageMethod")
    private String StorageMethod;

    @Column(name = "base_quantity")
    private int baseQuantity;

    @Column(name = "unit")
    private String unit;

    @Column(name = "expiration_date")
    private String expirationDate;

    @Column(name = "is_user_created")
    private Boolean isUserCreated;

    @Column(name = "created_by")

    private Long createdBy;

    @Column(name = "calories")
    private int calories;

    @Column(name = "protein")
    private float protein;

    @Column(name = "fat")
    private float fat;

    @Column(name = "carbohydrates")
    private float carbohydrates;

    @Column(name = "fiber")
    private float fiber;

    // Constructors
    public Ingredient() {
    }

    public Ingredient(String name, String category, String imageURL, String StorageMethod, int baseQuantity, String unit, String expirationDate, Boolean isUserCreated, Long createdBy, int calories, float protein, float fat, float carbohydrates, float fiber) {
        this.name = name;
        this.category = category;
        this.imageURL = imageURL;
        this.StorageMethod = StorageMethod;
        this.baseQuantity = baseQuantity;
        this.unit = unit;
        this.expirationDate = expirationDate;
        this.isUserCreated = isUserCreated;
        this.createdBy = createdBy;
        this.calories = calories;
        this.protein = protein;
        this.fat = fat;
        this.carbohydrates = carbohydrates;
        this.fiber = fiber;
    }

    // Getter and setter
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
