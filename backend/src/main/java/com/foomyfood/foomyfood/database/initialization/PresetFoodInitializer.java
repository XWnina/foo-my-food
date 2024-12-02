package com.foomyfood.foomyfood.database.initialization;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;

import com.foomyfood.foomyfood.database.PresetTable;
import com.foomyfood.foomyfood.database.db_service.PresetTableService;

@Component
public class PresetFoodInitializer implements CommandLineRunner {

    @Autowired
    private PresetTableService presetTableService;

    @Override
    public void run(String... args) throws Exception {
        createInitializationPresets();
    }

    private void createInitializationPresets() {
        if (presetTableService.getAllPresets().isEmpty()) {
            // Vegetables (18)
            presetTableService.createPreset(new PresetTable(null, "Carrot", "Vegetables", "Refrigerator", 1, "kg", 28, 82, 1.8f, 0.4f, 19.2f, 5.6f));
            presetTableService.createPreset(new PresetTable(null, "Broccoli", "Vegetables", "Refrigerator", 1, "kg", 7, 34, 2.8f, 0.4f, 6.6f, 2.6f));
            presetTableService.createPreset(new PresetTable(null, "Potato", "Vegetables", "Pantry", 1, "kg", 30, 77, 2.0f, 0.1f, 17.5f, 2.2f));
            presetTableService.createPreset(new PresetTable(null, "Tomato", "Vegetables", "Refrigerator", 1, "kg", 7, 18, 0.9f, 0.2f, 3.9f, 1.2f));
            presetTableService.createPreset(new PresetTable(null, "Cucumber", "Vegetables", "Refrigerator", 1, "kg", 7, 16, 0.7f, 0.1f, 3.6f, 0.5f));
            presetTableService.createPreset(new PresetTable(null, "Spinach", "Vegetables", "Refrigerator", 1, "kg", 7, 23, 2.9f, 0.4f, 3.6f, 2.2f));
            presetTableService.createPreset(new PresetTable(null, "Eggplant", "Vegetables", "Refrigerator", 1, "kg", 14, 25, 1.0f, 0.2f, 5.7f, 3.0f));
            presetTableService.createPreset(new PresetTable(null, "Zucchini", "Vegetables", "Refrigerator", 1, "kg", 14, 17, 1.2f, 0.2f, 3.1f, 1.1f));
            presetTableService.createPreset(new PresetTable(null, "Bell Pepper", "Vegetables", "Refrigerator", 1, "kg", 7, 26, 1.0f, 0.3f, 6.0f, 1.8f));
            presetTableService.createPreset(new PresetTable(null, "Pumpkin", "Vegetables", "Refrigerator", 1, "kg", 30, 26, 1.0f, 0.1f, 6.5f, 0.5f));
            presetTableService.createPreset(new PresetTable(null, "Cauliflower", "Vegetables", "Refrigerator", 1, "kg", 7, 25, 2.0f, 0.3f, 5.0f, 2.1f));
            presetTableService.createPreset(new PresetTable(null, "Sweet Potato", "Vegetables", "Pantry", 1, "kg", 30, 86, 1.6f, 0.1f, 20.1f, 3.0f));
            presetTableService.createPreset(new PresetTable(null, "Beetroot", "Vegetables", "Refrigerator", 1, "kg", 14, 43, 1.6f, 0.2f, 9.6f, 2.8f));
            presetTableService.createPreset(new PresetTable(null, "Garlic", "Vegetables", "Room Temperature", 1, "kg", 90, 149, 6.4f, 0.5f, 33.1f, 2.1f));
            presetTableService.createPreset(new PresetTable(null, "Onion", "Vegetables", "Room Temperature", 1, "kg", 30, 40, 1.1f, 0.1f, 9.3f, 1.7f));
            presetTableService.createPreset(new PresetTable(null, "Asparagus", "Vegetables", "Refrigerator", 1, "kg", 5, 20, 2.2f, 0.1f, 3.9f, 2.0f));
            presetTableService.createPreset(new PresetTable(null, "Celery", "Vegetables", "Refrigerator", 1, "kg", 14, 14, 0.7f, 0.2f, 3.0f, 1.6f));
            presetTableService.createPreset(new PresetTable(null, "Lettuce", "Vegetables", "Refrigerator", 1, "kg", 7, 15, 1.4f, 0.2f, 2.9f, 1.4f));

            // Fruits (16)
            presetTableService.createPreset(new PresetTable(null, "Apple", "Fruits", "Refrigerator", 1, "kg", 30, 52, 0.3f, 0.2f, 14.0f, 2.4f));
            presetTableService.createPreset(new PresetTable(null, "Banana", "Fruits", "Room Temperature", 1, "kg", 7, 96, 1.3f, 0.3f, 22.8f, 2.6f));
            presetTableService.createPreset(new PresetTable(null, "Strawberry", "Fruits", "Refrigerator", 1, "kg", 5, 32, 0.7f, 0.3f, 7.7f, 2.0f));
            presetTableService.createPreset(new PresetTable(null, "Grapes", "Fruits", "Refrigerator", 1, "kg", 7, 69, 0.7f, 0.2f, 18.1f, 0.9f));
            presetTableService.createPreset(new PresetTable(null, "Lemon", "Fruits", "Room Temperature", 1, "kg", 21, 29, 1.1f, 0.3f, 9.3f, 2.8f));
            presetTableService.createPreset(new PresetTable(null, "Mango", "Fruits", "Refrigerator", 1, "kg", 5, 60, 0.8f, 0.4f, 14.0f, 1.6f));
            presetTableService.createPreset(new PresetTable(null, "Papaya", "Fruits", "Refrigerator", 1, "kg", 7, 43, 0.5f, 0.3f, 10.8f, 1.7f));
            presetTableService.createPreset(new PresetTable(null, "Lychee", "Fruits", "Refrigerator", 1, "kg", 7, 66, 0.8f, 0.4f, 16.5f, 1.3f));
            presetTableService.createPreset(new PresetTable(null, "Fig", "Fruits", "Refrigerator", 1, "kg", 5, 74, 0.8f, 0.3f, 19.2f, 2.9f));
            presetTableService.createPreset(new PresetTable(null, "Guava", "Fruits", "Refrigerator", 1, "kg", 7, 68, 2.6f, 0.9f, 14.3f, 5.4f));
            presetTableService.createPreset(new PresetTable(null, "Blueberries", "Fruits", "Refrigerator", 1, "kg", 5, 57, 0.7f, 0.3f, 14.5f, 2.4f));
            presetTableService.createPreset(new PresetTable(null, "Cantaloupe", "Fruits", "Refrigerator", 1, "kg", 5, 34, 0.8f, 0.2f, 8.2f, 0.9f));
            presetTableService.createPreset(new PresetTable(null, "Peach", "Fruits", "Refrigerator", 1, "kg", 14, 39, 0.9f, 0.3f, 9.5f, 1.5f));
            presetTableService.createPreset(new PresetTable(null, "Pineapple", "Fruits", "Refrigerator", 1, "kg", 5, 50, 0.5f, 0.1f, 13.1f, 1.4f));
            presetTableService.createPreset(new PresetTable(null, "Avocado", "Fruits", "Refrigerator", 1, "kg", 5, 160, 15.0f, 7.0f, 9.0f, 2.0f));
            presetTableService.createPreset(new PresetTable(null, "Blackberries", "Fruits", "Refrigerator", 1, "kg", 5, 43, 0.5f, 5.3f, 9.6f, 1.4f));

            // Meat (19)
            presetTableService.createPreset(new PresetTable(null, "Egg", "Meat", "Refrigerator", 12, "pcs", 21, 155, 13.0f, 11.0f, 1.1f, 0.0f));
            presetTableService.createPreset(new PresetTable(null, "Duck Egg", "Meat", "Refrigerator", 12, "pcs", 21, 185, 14.0f, 13.0f, 1.2f, 0.0f));
            presetTableService.createPreset(new PresetTable(null, "Chicken Breast", "Meat", "Freezer", 1, "kg", 180, 165, 31.0f, 3.6f, 0.0f, 0.0f));
            presetTableService.createPreset(new PresetTable(null, "Beef Steak", "Meat", "Freezer", 1, "kg", 365, 250, 26.1f, 15.0f, 0.0f, 0.0f));
            presetTableService.createPreset(new PresetTable(null, "Salmon", "Meat", "Freezer", 1, "kg", 180, 208, 20.4f, 13.0f, 0.0f, 0.0f));
            presetTableService.createPreset(new PresetTable(null, "Pork Loin", "Meat", "Freezer", 1, "kg", 180, 242, 27.3f, 14.0f, 0.0f, 0.0f));
            presetTableService.createPreset(new PresetTable(null, "Duck Breast", "Meat", "Freezer", 1, "kg", 365, 337, 19.0f, 28.0f, 0.0f, 0.0f));
            presetTableService.createPreset(new PresetTable(null, "Lamb", "Meat", "Freezer", 1, "kg", 180, 294, 25.6f, 20.0f, 0.0f, 0.0f));
            presetTableService.createPreset(new PresetTable(null, "Rabbit", "Meat", "Freezer", 1, "kg", 365, 173, 25.0f, 8.0f, 0.0f, 0.0f));
            presetTableService.createPreset(new PresetTable(null, "Sausage", "Meat", "Freezer", 1, "kg", 180, 301, 13.0f, 27.0f, 1.0f, 0.0f));
            presetTableService.createPreset(new PresetTable(null, "Turkey", "Meat", "Freezer", 1, "kg", 180, 135, 30.0f, 1.0f, 0.0f, 0.0f));
            presetTableService.createPreset(new PresetTable(null, "Goose Meat", "Meat", "Freezer", 1, "kg", 180, 161, 23.0f, 7.0f, 0.0f, 0.0f));
            presetTableService.createPreset(new PresetTable(null, "Quail", "Meat", "Freezer", 1, "kg", 180, 123, 19.1f, 5.8f, 0.0f, 0.0f));
            presetTableService.createPreset(new PresetTable(null, "Prawns", "Meat", "Freezer", 1, "kg", 30, 99, 0.3f, 0.0f, 0.2f, 24.0f));
            presetTableService.createPreset(new PresetTable(null, "Squid", "Meat", "Freezer", 1, "kg", 30, 92, 1.4f, 0.0f, 3.1f, 15.6f));
            presetTableService.createPreset(new PresetTable(null, "Quail Meat", "Meat", "Freezer", 1, "kg", 180, 123, 5.8f, 0.0f, 0.0f, 19.1f));
            presetTableService.createPreset(new PresetTable(null, "Kale", "Vegetables", "Refrigerator", 1, "kg", 7, 49, 0.9f, 3.6f, 8.8f, 4.3f));
            presetTableService.createPreset(new PresetTable(null, "Radish", "Vegetables", "Refrigerator", 1, "kg", 14, 16, 0.1f, 1.6f, 3.4f, 0.7f));
            presetTableService.createPreset(new PresetTable(null, "Brussels Sprouts", "Vegetables", "Refrigerator", 1, "kg", 7, 43, 0.3f, 3.8f, 9.0f, 3.4f));

            // Dairy (5)
            presetTableService.createPreset(new PresetTable(null, "Milk", "Dairy", "Refrigerator", 1, "kg", 10, 42, 3.4f, 1.0f, 5.0f, 0.0f));
            presetTableService.createPreset(new PresetTable(null, "Cheese", "Dairy", "Refrigerator", 1, "kg", 30, 402, 25.0f, 33.0f, 1.3f, 0.0f));
            presetTableService.createPreset(new PresetTable(null, "Yogurt", "Dairy", "Refrigerator", 1, "kg", 14, 59, 10.0f, 0.4f, 3.6f, 0.0f));
            presetTableService.createPreset(new PresetTable(null, "Butter", "Dairy", "Refrigerator", 1, "kg", 30, 717, 81.0f, 0.0f, 0.1f, 0.9f));
            presetTableService.createPreset(new PresetTable(null, "Cream Cheese", "Dairy", "Refrigerator", 1, "kg", 14, 342, 34.0f, 0.0f, 4.1f, 6.2f));

            // Grains (4)
            presetTableService.createPreset(new PresetTable(null, "Rice", "Grains", "Pantry", 1, "kg", 365, 130, 2.7f, 0.3f, 28.0f, 0.4f));
            presetTableService.createPreset(new PresetTable(null, "Oats", "Grains", "Pantry", 1, "kg", 180, 389, 16.9f, 6.9f, 66.3f, 10.6f));
            presetTableService.createPreset(new PresetTable(null, "Chia Seeds", "Grains", "Pantry", 1, "kg", 365, 486, 16.5f, 30.7f, 42.1f, 34.4f));
            presetTableService.createPreset(new PresetTable(null, "Millet", "Grains", "Pantry", 1, "kg", 365, 378, 4.2f, 8.5f, 72.9f, 11.0f));

            // Spices (5)
            presetTableService.createPreset(new PresetTable(null, "Cinnamon", "Spices", "Pantry", 1, "kg", 365, 247, 4.0f, 1.2f, 80.6f, 53.1f));
            presetTableService.createPreset(new PresetTable(null, "Pepper", "Spices", "Pantry", 1, "kg", 365, 251, 10.4f, 3.3f, 63.8f, 26.5f));
            presetTableService.createPreset(new PresetTable(null, "Chili Flakes", "Spices", "Pantry", 1, "kg", 365, 282, 12.0f, 14.0f, 56.0f, 34.0f));
            presetTableService.createPreset(new PresetTable(null, "Nutmeg", "Spices", "Pantry", 1, "kg", 365, 525, 5.8f, 36.3f, 49.3f, 28.4f));
            presetTableService.createPreset(new PresetTable(null, "Rosemary", "Spices", "Pantry", 1, "kg", 365, 131, 5.9f, 14.1f, 20.7f, 3.3f));

            // Beverages (3)
            presetTableService.createPreset(new PresetTable(null, "Orange Juice", "Beverages", "Refrigerator", 1, "kg", 7, 45, 0.7f, 0.2f, 10.4f, 0.2f));
            presetTableService.createPreset(new PresetTable(null, "Coffee", "Beverages", "Pantry", 1, "kg", 365, 2, 0.1f, 0.0f, 0.0f, 0.0f));
            presetTableService.createPreset(new PresetTable(null, "Soy Milk", "Beverages", "Refrigerator", 1, "kg", 7, 33, 3.0f, 1.6f, 2.0f, 0.2f));

            System.out.println("Initialized all preset foods.");
        } else {
            System.out.println("Preset foods already initialized, skipping initialization.");
        }
    }

}
