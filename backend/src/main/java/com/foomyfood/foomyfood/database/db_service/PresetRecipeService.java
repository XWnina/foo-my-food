package com.foomyfood.foomyfood.database.db_service;

import java.util.List;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.foomyfood.foomyfood.database.PresetRecipe;
import com.foomyfood.foomyfood.database.db_repository.PresetRecipeRepository;

@Service
public class PresetRecipeService {

    @Autowired
    private PresetRecipeRepository presetRecipeRepository;

    // Add PresetRecipe
    public PresetRecipe addPresetRecipe(PresetRecipe presetRecipe) {
        return presetRecipeRepository.save(presetRecipe);
    }

    // Get all PresetRecipes
    public List<PresetRecipe> getAllPresetRecipes() {
        return presetRecipeRepository.findAll();
    }

    // Get PresetRecipe by ID
    public Optional<PresetRecipe> getPresetRecipeById(Long id) {
        return presetRecipeRepository.findById(id);
    }

    // Delete PresetRecipe by ID
    public void deletePresetRecipe(Long id) {
        presetRecipeRepository.deleteById(id);
    }

    //
    public PresetRecipe getPresetRecipeByIdAsPresetRecipe(Long id) {
        return presetRecipeRepository.findById(id).orElseThrow(() -> new RuntimeException("PresetRecipe with ID " + id + " not found"));
    }
}
