package com.foomyfood.foomyfood.service;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.foomyfood.foomyfood.database.PresetTable;
import com.foomyfood.foomyfood.database.db_repository.PresetTableRepository;

@Service
public class PresetAddIngredientService {

    private final PresetTableRepository presetTableRepository;

    @Autowired
    public PresetAddIngredientService(PresetTableRepository presetTableRepository) {
        this.presetTableRepository = presetTableRepository;
    }

    public List<PresetTable> getAllPresets() {
        return presetTableRepository.findAll();
    }

    public Optional<PresetTable> getPresetById(Long id) {
        return presetTableRepository.findById(id);
    }

    public List<String> searchPresetsByName(String query) {
        return presetTableRepository.findByNameContainingIgnoreCase(query)
                .stream()
                .map(PresetTable::getName)
                .collect(Collectors.toList());
    }

    public Optional<PresetTable> getPresetByName(String name) {
        return presetTableRepository.findByName(name);
    }

    public PresetTable createPreset(PresetTable preset) {
        return presetTableRepository.save(preset);
    }

    public PresetTable updatePreset(Long id, PresetTable updatedPreset) {
        if (!presetTableRepository.existsById(id)) {
            throw new RuntimeException("Preset not found");
        }
        updatedPreset.setIngredientId(id);
        return presetTableRepository.save(updatedPreset);
    }

    public void deletePreset(Long id) {
        presetTableRepository.deleteById(id);
    }
}
