package com.foomyfood.foomyfood.database;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import jakarta.persistence.UniqueConstraint;

@Entity
@Table(
    name = "recipe_collection",
    uniqueConstraints = {@UniqueConstraint(columnNames = {"user_id", "recipe_id", "preset_recipe_id"})}
)
public class RecipeCollection {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "user_id", nullable = false)
    private Long userId;

    @Column(name = "recipe_id")
    private Long recipeId;

    @Column(name = "preset_recipe_id")
    private Long presetRecipeId;

    // Constructors
    public RecipeCollection() {
    }

    public RecipeCollection(Long userId, Long recipeId, Long presetRecipeId) {
        this.userId = userId;
        this.recipeId = recipeId;
        this.presetRecipeId = presetRecipeId;
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

    public Long getRecipeId() {
        return recipeId;
    }

    public void setRecipeId(Long recipeId) {
        this.recipeId = recipeId;
    }

    public Long getPresetRecipeId() {
        return presetRecipeId;
    }

    public void setPresetRecipeId(Long presetRecipeId) {
        this.presetRecipeId = presetRecipeId;
    }
}
