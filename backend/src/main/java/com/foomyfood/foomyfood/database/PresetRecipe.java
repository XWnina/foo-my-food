package com.foomyfood.foomyfood.database;

import java.util.Arrays;
import java.util.List;
import java.util.stream.Collectors;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import jakarta.persistence.UniqueConstraint;

@Entity
@Table(name = "preset_recipe", uniqueConstraints = {
    @UniqueConstraint(columnNames = {"dish_name", "calories", "ingredients"})
})
public class PresetRecipe {

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

    public PresetRecipe() {
    }

    public PresetRecipe(String dishName, Integer calories, String videoLink, String imageURL, String description, String ingredients, String labels) {
        this.dishName = dishName;
        this.calories = calories;
        this.videoLink = videoLink;
        this.imageURL = imageURL;
        this.description = description;
        this.ingredients = ingredients;
        this.labels = labels;
    }

    // Getters and Setters
    public Long getId() {
        return id;
    }

    public String getDishName() {
        return dishName;
    }

    public Integer getCalories() {
        return calories;
    }

    public String getVideoLink() {
        return videoLink;
    }

    public String getImageURL() {
        return imageURL;
    }

    public String getDescription() {
        return description;
    }

    public String getIngredients() {
        return ingredients;
    }

    public String getLabels() {
        return labels;
    }

    public void setDishName(String dishName) {
        this.dishName = dishName;
    }

    public void setCalories(Integer calories) {
        this.calories = calories;
    }

    public void setVideoLink(String videoLink) {
        this.videoLink = videoLink;
    }

    public void setImageURL(String imageURL) {
        this.imageURL = imageURL;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public void setIngredients(String ingredients) {
        this.ingredients = ingredients;
    }

    public void setLabels(String labels) {
        this.labels = labels;
    }

    public List<String> getIngredientsAsList() {
        return Arrays.stream(ingredients.split(","))
                .map(String::trim)
                .collect(Collectors.toList());
    }

}
