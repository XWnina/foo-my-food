package com.foomyfood.foomyfood.database.testing;

import java.util.List;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;

import com.foomyfood.foomyfood.database.PresetTable;
import com.foomyfood.foomyfood.database.db_service.PresetTableService;

// @Component
public class PresetTableTester implements CommandLineRunner {

    @Autowired
    private PresetTableService presetTableService;

    @Override
    public void run(String... args) throws Exception {
        // Test preset creation with different scenarios
        System.out.println("\n--- Testing Preset Creation ---");
        createTestPresets();

        // Test retrieving all presets
        System.out.println("\n--- Testing Retrieving All Presets ---");
        getAllPresets();

        // Test retrieving a specific preset by ID
        System.out.println("\n--- Testing Retrieving Preset by ID ---");
        getPresetById(1L); // Assuming ID 1 exists

        // Test updating a preset
        System.out.println("\n--- Testing Preset Update ---");
        updatePreset(1L);  // Assuming ID 1 exists

        // Test retrieving updated preset by ID
        System.out.println("\n--- Testing Retrieving Updated Preset by ID ---");
        getPresetById(1L);  // Assuming ID 1 exists

        // Test deleting a preset
        System.out.println("\n--- Testing Preset Deletion ---");
        deletePreset(2L);  // Assuming ID 2 exists

        // Test deleting a non-existent preset
        System.out.println("\n--- Testing Deleting Non-Existent Preset ---");
        deletePreset(999L);  // Assuming ID 999 doesn't exist

        // Test retrieving all presets after deletion
        System.out.println("\n--- Testing Retrieving All Presets After Deletion ---");
        getAllPresets();
    }

    // Create test presets with different scenarios
    private void createTestPresets() {
        // Valid presets with all fields filled
        PresetTable preset1 = presetTableService.createPreset(
                new PresetTable(null, "Apple", "Fruit", "Refrigerated", 1, "kg", 7, 52, 0.3f, 0.2f, 14.0f, 2.4f)
        );

        // Preset with minimal details (optional fields set to default)
        PresetTable preset2 = presetTableService.createPreset(
                new PresetTable(null, "Banana", "Fruit", "Room Temperature", 1, "kg", 5, 96, 1.3f, 0.3f, 22.8f, 2.6f)
        );

        // Preset with only name and category filled, using default values for others
        PresetTable preset3 = presetTableService.createPreset(
                new PresetTable(null, "Carrot", "Vegetable", "Refrigerated", 1, "kg", 14, 41, 0.9f, 0.2f, 9.6f, 2.8f)
        );

        // Print created presets
        System.out.println("Created Presets:");
        System.out.println(preset1);
        System.out.println(preset2);
        System.out.println(preset3);
    }

    // Retrieve all presets
    private void getAllPresets() {
        List<PresetTable> presets = presetTableService.getAllPresets();
        if (presets.isEmpty()) {
            System.out.println("No presets found.");
        } else {
            System.out.println("All Presets:");
            presets.forEach(System.out::println);
        }
    }

    // Retrieve a preset by ID
    private void getPresetById(Long presetId) {
        Optional<PresetTable> preset = presetTableService.getPresetById(presetId);
        if (preset.isPresent()) {
            System.out.println("Found Preset: " + preset.get());
        } else {
            System.out.println("No preset found with ID: " + presetId);
        }
    }

    // Update a preset
    private void updatePreset(Long presetId) {
        PresetTable updatedPreset = presetTableService.updatePreset(presetId,
                new PresetTable(null, "Updated Apple", "Fruit", "Refrigerated", 1, "kg", 10, 55, 0.5f, 0.3f, 15.0f, 3.0f)
        );
        System.out.println("Updated Preset: " + updatedPreset);
    }

    // Delete a preset
    private void deletePreset(Long presetId) {
        try {
            presetTableService.deletePreset(presetId);
            System.out.println("Preset with ID " + presetId + " successfully deleted!");
        } catch (RuntimeException e) {
            System.out.println(e.getMessage());
        }
    }
}
