package com.foomyfood.foomyfood.database;

import java.util.Arrays;
import java.util.List;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

@Entity
@Table(name = "recipes")
public class Recipe {
    // Dish names and ingredient list should not be empty
    // Default calories is set to -1 (to show un-set)
    // Default video link, image URL, and description is set to "N/A"
    // Ingredients are stored as a comma-separated string

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "dish_name", nullable = false)
    private String dishName;

    @Column(name = "calories")
    private Integer calories;

    @Column(name = "video_link")
    private String videoLink;

    @Column(name = "image_url")
    private String imageURL;

    @Column(name = "description")
    private String description;

    @Column(name = "ingredients", nullable = false)
    private String ingredients;

    @Column(name = "labels")
    private String labels = "";

    @Column(name = "user_cooked_times")
    private Integer userCookedTimes;

    @Column(name = "user_id")
    private Long userId;

    // Getters and Setters
    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getDishName() {
        return dishName;
    }

    public void setDishName(String dishName) {
        this.dishName = dishName;
    }

    public Integer getCalories() {
        return calories;
    }

    public void setCalories(Integer calories) {
        this.calories = calories;
    }

    public String getVideoLink() {
        return videoLink;
    }

    public void setVideoLink(String videoLink) {
        this.videoLink = videoLink;
    }

    public String getImageURL() {
        return imageURL;
    }

    public void setImageURL(String imageURL) {
        this.imageURL = imageURL;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getIngredients() {
        return ingredients;
    }

    public void setIngredients(String ingredients) {
        this.ingredients = ingredients;
    }

    public String getLabels() {
        return labels;
    }

    public void setLabels(String labels) {
        this.labels = labels;
    }

    public Integer getUserCookedTimes() {
        return userCookedTimes;
    }

    public Long getUserId() {
        return userId;
    }

    public void setUserId(Long userId) {
        this.userId = userId;
    }

    public void getRecipeById(Long userId) {
        this.userId = userId;
    }

    public void setUserCookedTimes(Integer userCookedTimes) {
        this.userCookedTimes = userCookedTimes;
    }

    public List<String> getIngredientsAsList() {
        return Arrays.asList(ingredients.split(","));
    }

    public List<String> getLabelsAsList() {
        return Arrays.asList(labels.split(","));
    }

    public void setIngredientsAsList(List<String> ingredients) {
        this.ingredients = String.join(", ", ingredients);
    }

