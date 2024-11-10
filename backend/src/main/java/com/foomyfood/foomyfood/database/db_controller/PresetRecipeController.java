package com.foomyfood.foomyfood.database.db_controller;

import java.util.List;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.foomyfood.foomyfood.database.PresetRecipe;
import com.foomyfood.foomyfood.database.db_service.PresetRecipeService;

@RestController
@RequestMapping("/api/preset-recipes")
public class PresetRecipeController {

    @Autowired
    private PresetRecipeService presetRecipeService;

    // Add PresetRecipe
    @PostMapping
    public ResponseEntity<PresetRecipe> addPresetRecipe(@RequestBody PresetRecipe presetRecipe) {
        PresetRecipe createdPreset = presetRecipeService.addPresetRecipe(presetRecipe);
        return ResponseEntity.ok(createdPreset);
    }

    // Get all PresetRecipes
    @GetMapping
    public ResponseEntity<List<PresetRecipe>> getAllPresetRecipes() {
        List<PresetRecipe> presets = presetRecipeService.getAllPresetRecipes();
        return ResponseEntity.ok(presets);
    }

    // Get PresetRecipe by ID
    @GetMapping("/{id}")
    public ResponseEntity<PresetRecipe> getPresetRecipeById(@PathVariable Long id) {
        Optional<PresetRecipe> presetRecipe = presetRecipeService.getPresetRecipeById(id);
        return presetRecipe.map(ResponseEntity::ok)
                           .orElse(ResponseEntity.notFound().build());
    }

    // Delete PresetRecipe by ID
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deletePresetRecipe(@PathVariable Long id) {
        presetRecipeService.deletePresetRecipe(id);
        return ResponseEntity.noContent().build();
    }
}