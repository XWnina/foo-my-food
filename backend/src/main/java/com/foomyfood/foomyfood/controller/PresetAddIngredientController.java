package com.foomyfood.foomyfood.controller;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import com.foomyfood.foomyfood.database.PresetTable;
import com.foomyfood.foomyfood.service.PresetAddIngredientService;

@RestController
@RequestMapping("/api/presetsaddfood")
public class PresetAddIngredientController {

    private final PresetAddIngredientService presetAddIngredientService;

    @Autowired
    public PresetAddIngredientController(PresetAddIngredientService presetAddIngredientService) {
        this.presetAddIngredientService = presetAddIngredientService;
    }

    @GetMapping
    public List<PresetTable> getAllPresets() {
        return presetAddIngredientService.getAllPresets();
    }

    @GetMapping("/{id}")
    public ResponseEntity<PresetTable> getPresetById(@PathVariable Long id) {
        return presetAddIngredientService.getPresetById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @GetMapping("/search")
    public ResponseEntity<List<String>> searchPresets(@RequestParam String query) {
        List<String> results = presetAddIngredientService.searchPresetsByName(query);
        return ResponseEntity.ok(results);
    }

    @GetMapping("/name/{name}")
    public ResponseEntity<Map<String, Object>> getPresetByName(@PathVariable String name) {
        Optional<PresetTable> preset = presetAddIngredientService.getPresetByName(name);
        if (preset.isPresent()) {
            PresetTable presetTable = preset.get();
            Map<String, Object> response = new HashMap<>();
            response.put("name", presetTable.getName());
            response.put("category", presetTable.getCategory());
            response.put("storageMethod", presetTable.getStorageMethod());
            response.put("baseQuantity", presetTable.getBaseQuantity());
            response.put("unit", presetTable.getUnit());
            response.put("expirationDate", presetTable.getFormattedExpirationDate()); // 返回计算后的日期
            response.put("calories", presetTable.getCalories());
            response.put("protein", presetTable.getProtein());
            response.put("fat", presetTable.getFat());
            response.put("carbohydrates", presetTable.getCarbohydrates());
            response.put("fiber", presetTable.getFiber());

            return ResponseEntity.ok(response);
        } else {
            return ResponseEntity.notFound().build();
        }
    }

    @PostMapping
    public PresetTable createPreset(@RequestBody PresetTable preset) {
        return presetAddIngredientService.createPreset(preset);
    }

    @PutMapping("/{id}")
    public ResponseEntity<PresetTable> updatePreset(@PathVariable Long id, @RequestBody PresetTable updatedPreset) {
        try {
            PresetTable updated = presetAddIngredientService.updatePreset(id, updatedPreset);
            return ResponseEntity.ok(updated);
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deletePreset(@PathVariable Long id) {
        presetAddIngredientService.deletePreset(id);
        return ResponseEntity.noContent().build();
    }
}