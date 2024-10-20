package com.foomyfood.foomyfood.database.db_controller;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.foomyfood.foomyfood.database.PresetTable;
import com.foomyfood.foomyfood.database.db_service.PresetTableService;

@RestController
@RequestMapping("/api/presets")
public class PresetTableController {

    private final PresetTableService presetTableService;

    @Autowired
    public PresetTableController(PresetTableService presetTableService) {
        this.presetTableService = presetTableService;
    }

    @GetMapping
    public List<PresetTable> getAllPresets() {
        return presetTableService.getAllPresets();
    }

    @GetMapping("/{id}")
    public ResponseEntity<PresetTable> getPresetById(@PathVariable Long id) {
        return presetTableService.getPresetById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping
    public PresetTable createPreset(@RequestBody PresetTable preset) {
        return presetTableService.createPreset(preset);
    }

    @PutMapping("/{id}")
    public ResponseEntity<PresetTable> updatePreset(@PathVariable Long id, @RequestBody PresetTable updatedPreset) {
        try {
            PresetTable updated = presetTableService.updatePreset(id, updatedPreset);
            return ResponseEntity.ok(updated);
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deletePreset(@PathVariable Long id) {
        presetTableService.deletePreset(id);
        return ResponseEntity.noContent().build();
    }
}
