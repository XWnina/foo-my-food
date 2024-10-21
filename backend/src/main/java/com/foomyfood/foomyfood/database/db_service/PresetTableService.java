package com.foomyfood.foomyfood.database.db_service;

import java.util.List;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.foomyfood.foomyfood.database.PresetTable;
import com.foomyfood.foomyfood.database.db_repository.PresetTableRepository;

@Service
public class PresetTableService {

    private final PresetTableRepository presetTableRepository;

    @Autowired
    public PresetTableService(PresetTableRepository presetTableRepository) {
        this.presetTableRepository = presetTableRepository;
    }

    public List<PresetTable> getAllPresets() {
        return presetTableRepository.findAll();
    }

    public Optional<PresetTable> getPresetById(Long id) {
        return presetTableRepository.findById(id);
    }

    public PresetTable createPreset(PresetTable preset) {
        // Check if a preset with the same foodName already exists
        Optional<PresetTable> existingPreset = presetTableRepository.findByName(preset.getName());

        if (existingPreset.isPresent()) {
            // Return the existing preset if a duplicate is found
            return existingPreset.get();
        }

        // Save and return the new preset if it's not a duplicate
        return presetTableRepository.save(preset);
    }

    public PresetTable updatePreset(Long id, PresetTable updatedPreset) {
        return presetTableRepository.findById(id).map(preset -> {
            preset.setName(updatedPreset.getName());
            preset.setCategory(updatedPreset.getCategory());
            preset.setStorageMethod(updatedPreset.getStorageMethod());
            preset.setBaseQuantity(updatedPreset.getBaseQuantity());
            preset.setUnit(updatedPreset.getUnit());
            preset.setExpirationDate(updatedPreset.getExpirationDate());
            preset.setCalories(updatedPreset.getCalories());
            preset.setProtein(updatedPreset.getProtein());
            preset.setFat(updatedPreset.getFat());
            preset.setCarbohydrates(updatedPreset.getCarbohydrates());
            preset.setFiber(updatedPreset.getFiber());
            return presetTableRepository.save(preset);
        }).orElseThrow(() -> new RuntimeException("Preset not found with id " + id));
    }
    public void deletePreset(Long id) {
        presetTableRepository.deleteById(id);
    }

}
