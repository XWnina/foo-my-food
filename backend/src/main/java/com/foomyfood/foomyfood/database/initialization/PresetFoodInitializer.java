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

    // Create test presets with different scenarios
    private void createInitializationPresets() {
        presetTableService.createPreset(new PresetTable(null, "Apple", "Fruits", "Refrigerator", 1, "kg", 30, 52, 0.3f, 0.2f, 14.0f, 2.4f));
        presetTableService.createPreset(new PresetTable(null, "Banana", "Fruits", "Room Temperature", 1, "kg", 7, 96, 1.3f, 0.3f, 22.8f, 2.6f));
        presetTableService.createPreset(new PresetTable(null, "Carrot", "Vegetables", "Refrigerator", 1, "kg", 28, 82, 1.8f, 0.4f, 19.2f, 5.6f));
        presetTableService.createPreset(new PresetTable(null, "Chicken Breast", "Meat", "Freezer", 1, "kg", 180, 165, 31.0f, 3.6f, 0.0f, 0.0f));
        presetTableService.createPreset(new PresetTable(null, "Milk", "Dairy", "Refrigerator", 1, "kg", 10, 42, 3.4f, 1.0f, 5.0f, 0.0f));
        presetTableService.createPreset(new PresetTable(null, "Rice", "Grains", "Pantry", 1, "kg", 365, 130, 2.7f, 0.3f, 28.0f, 0.4f));
        presetTableService.createPreset(new PresetTable(null, "Cinnamon", "Spices", "Pantry", 1, "kg", 365, 247, 4.0f, 1.2f, 80.6f, 53.1f));
        presetTableService.createPreset(new PresetTable(null, "Orange Juice", "Beverages", "Refrigerator", 1, "kg", 7, 45, 0.7f, 0.2f, 10.4f, 0.2f));
        presetTableService.createPreset(new PresetTable(null, "Broccoli", "Vegetables", "Refrigerator", 1, "kg", 7, 34, 2.8f, 0.4f, 6.6f, 2.6f));
        presetTableService.createPreset(new PresetTable(null, "Strawberry", "Fruits", "Refrigerator", 1, "kg", 5, 32, 0.7f, 0.3f, 7.7f, 2.0f));
        presetTableService.createPreset(new PresetTable(null, "Beef Steak", "Meat", "Freezer", 1, "kg", 365, 250, 26.1f, 15.0f, 0.0f, 0.0f));
        presetTableService.createPreset(new PresetTable(null, "Cheese", "Dairy", "Refrigerator", 1, "kg", 30, 402, 25.0f, 33.0f, 1.3f, 0.0f));
        presetTableService.createPreset(new PresetTable(null, "Wheat Flour", "Grains", "Pantry", 1, "kg", 365, 364, 10.0f, 1.0f, 76.3f, 2.7f));
        presetTableService.createPreset(new PresetTable(null, "Pepper", "Spices", "Pantry", 1, "kg", 365, 251, 10.4f, 3.3f, 63.8f, 26.5f));
        presetTableService.createPreset(new PresetTable(null, "Tea", "Beverages", "Pantry", 1, "kg", 365, 1, 0.0f, 0.0f, 0.0f, 0.0f));
        presetTableService.createPreset(new PresetTable(null, "Potato", "Vegetables", "Pantry", 1, "kg", 30, 77, 2.0f, 0.1f, 17.5f, 2.2f));
        presetTableService.createPreset(new PresetTable(null, "Grapes", "Fruits", "Refrigerator", 1, "kg", 7, 69, 0.7f, 0.2f, 18.1f, 0.9f));
        presetTableService.createPreset(new PresetTable(null, "Pork Loin", "Meat", "Freezer", 1, "kg", 180, 242, 27.3f, 14.0f, 0.0f, 0.0f));
        presetTableService.createPreset(new PresetTable(null, "Yogurt", "Dairy", "Refrigerator", 1, "kg", 14, 59, 10.0f, 0.4f, 3.6f, 0.0f));
        presetTableService.createPreset(new PresetTable(null, "Oats", "Grains", "Pantry", 1, "kg", 180, 389, 16.9f, 6.9f, 66.3f, 10.6f));
        presetTableService.createPreset(new PresetTable(null, "Paprika", "Spices", "Pantry", 1, "kg", 365, 282, 14.1f, 13.0f, 54.0f, 34.9f));
        presetTableService.createPreset(new PresetTable(null, "Coffee", "Beverages", "Pantry", 1, "kg", 365, 2, 0.1f, 0.0f, 0.0f, 0.0f));
        presetTableService.createPreset(new PresetTable(null, "Tomato", "Vegetables", "Refrigerator", 1, "kg", 7, 18, 0.9f, 0.2f, 3.9f, 1.2f));
        presetTableService.createPreset(new PresetTable(null, "Pear", "Fruits", "Refrigerator", 1, "kg", 14, 57, 0.4f, 0.1f, 15.2f, 3.1f));
        presetTableService.createPreset(new PresetTable(null, "Salmon", "Meat", "Freezer", 1, "kg", 180, 208, 20.4f, 13.0f, 0.0f, 0.0f));
        presetTableService.createPreset(new PresetTable(null, "Butter", "Dairy", "Refrigerator", 1, "kg", 30, 717, 0.9f, 81.0f, 0.1f, 0.0f));
        presetTableService.createPreset(new PresetTable(null, "Barley", "Grains", "Pantry", 1, "kg", 365, 354, 12.5f, 2.3f, 73.5f, 17.3f));
        presetTableService.createPreset(new PresetTable(null, "Thyme", "Spices", "Pantry", 1, "kg", 365, 276, 9.1f, 7.4f, 63.9f, 37.0f));
        presetTableService.createPreset(new PresetTable(null, "Beer", "Beverages", "Refrigerator", 1, "kg", 30, 43, 0.5f, 0.0f, 3.6f, 0.0f));
        presetTableService.createPreset(new PresetTable(null, "Cucumber", "Vegetables", "Refrigerator", 1, "kg", 7, 16, 0.7f, 0.1f, 3.6f, 0.5f));
        presetTableService.createPreset(new PresetTable(null, "Peach", "Fruits", "Refrigerator", 1, "kg", 14, 39, 0.9f, 0.3f, 9.5f, 1.5f));
        presetTableService.createPreset(new PresetTable(null, "Lamb", "Meat", "Freezer", 1, "kg", 180, 294, 25.6f, 20.0f, 0.0f, 0.0f));
        presetTableService.createPreset(new PresetTable(null, "Sour Cream", "Dairy", "Refrigerator", 1, "kg", 14, 193, 2.4f, 19.0f, 3.0f, 0.0f));
        presetTableService.createPreset(new PresetTable(null, "Quinoa", "Grains", "Pantry", 1, "kg", 365, 368, 14.1f, 6.1f, 64.2f, 7.0f));
        presetTableService.createPreset(new PresetTable(null, "Nutmeg", "Spices", "Pantry", 1, "kg", 365, 525, 5.8f, 36.3f, 49.3f, 28.4f));
        presetTableService.createPreset(new PresetTable(null, "Blueberries", "Fruits", "Refrigerator", 1, "kg", 7, 57, 0.7f, 0.3f, 14.5f, 2.4f));
        presetTableService.createPreset(new PresetTable(null, "Duck Breast", "Meat", "Freezer", 1, "kg", 365, 337, 19.0f, 28.0f, 0.0f, 0.0f));
        presetTableService.createPreset(new PresetTable(null, "Feta Cheese", "Dairy", "Refrigerator", 1, "kg", 30, 264, 14.0f, 21.0f, 4.0f, 0.0f));
        presetTableService.createPreset(new PresetTable(null, "Millet", "Grains", "Pantry", 1, "kg", 365, 378, 11.0f, 4.2f, 72.9f, 8.5f));
        presetTableService.createPreset(new PresetTable(null, "Curry Powder", "Spices", "Pantry", 1, "kg", 365, 325, 12.7f, 14.0f, 58.2f, 53.2f));
        presetTableService.createPreset(new PresetTable(null, "Lemonade", "Beverages", "Refrigerator", 1, "kg", 7, 40, 0.3f, 0.1f, 10.0f, 0.1f));
        presetTableService.createPreset(new PresetTable(null, "Zucchini", "Vegetables", "Refrigerator", 1, "kg", 7, 17, 1.2f, 0.2f, 3.1f, 1.1f));
        presetTableService.createPreset(new PresetTable(null, "Kiwi", "Fruits", "Refrigerator", 1, "kg", 7, 61, 1.1f, 0.5f, 14.7f, 3.0f));
        presetTableService.createPreset(new PresetTable(null, "Ham", "Meat", "Refrigerator", 1, "kg", 14, 145, 16.0f, 10.0f, 0.0f, 0.0f));
        presetTableService.createPreset(new PresetTable(null, "Rye", "Grains", "Pantry", 1, "kg", 365, 338, 10.0f, 2.7f, 75.9f, 15.1f));
        presetTableService.createPreset(new PresetTable(null, "Ginger", "Spices", "Pantry", 1, "kg", 365, 80, 1.8f, 0.8f, 17.8f, 2.0f));
        presetTableService.createPreset(new PresetTable(null, "Smoothie", "Beverages", "Refrigerator", 1, "kg", 5, 60, 1.0f, 0.3f, 14.0f, 1.5f));
        presetTableService.createPreset(new PresetTable(null, "Eggplant", "Vegetables", "Refrigerator", 1, "kg", 7, 25, 1.0f, 0.2f, 5.7f, 3.0f));
        presetTableService.createPreset(new PresetTable(null, "Plum", "Fruits", "Refrigerator", 1, "kg", 7, 46, 0.7f, 0.3f, 11.4f, 1.4f));
        presetTableService.createPreset(new PresetTable(null, "Venison", "Meat", "Freezer", 1, "kg", 365, 158, 24.0f, 3.2f, 0.0f, 0.0f));
        presetTableService.createPreset(new PresetTable(null, "Parmesan", "Dairy", "Refrigerator", 1, "kg", 60, 431, 38.0f, 29.0f, 3.2f, 0.0f));
        presetTableService.createPreset(new PresetTable(null, "Buckwheat", "Grains", "Pantry", 1, "kg", 365, 343, 13.3f, 3.4f, 71.5f, 10.0f));
        presetTableService.createPreset(new PresetTable(null, "Allspice", "Spices", "Pantry", 1, "kg", 365, 263, 6.1f, 8.7f, 72.1f, 21.6f));
        presetTableService.createPreset(new PresetTable(null, "Hot Chocolate", "Beverages", "Pantry", 1, "kg", 365, 89, 2.4f, 3.0f, 15.0f, 1.0f));
        presetTableService.createPreset(new PresetTable(null, "Radish", "Vegetables", "Refrigerator", 1, "kg", 14, 16, 0.7f, 0.1f, 3.4f, 1.6f));
        presetTableService.createPreset(new PresetTable(null, "Blackberries", "Fruits", "Refrigerator", 1, "kg", 5, 43, 1.4f, 0.5f, 9.6f, 5.3f));
        presetTableService.createPreset(new PresetTable(null, "Rabbit", "Meat", "Freezer", 1, "kg", 365, 173, 25.0f, 8.0f, 0.0f, 0.0f));
        presetTableService.createPreset(new PresetTable(null, "Mozzarella", "Dairy", "Refrigerator", 1, "kg", 14, 280, 22.0f, 17.0f, 2.2f, 0.0f));
        presetTableService.createPreset(new PresetTable(null, "Spelt", "Grains", "Pantry", 1, "kg", 365, 338, 14.6f, 2.4f, 70.2f, 10.7f));
        presetTableService.createPreset(new PresetTable(null, "Cloves", "Spices", "Pantry", 1, "kg", 365, 274, 5.4f, 13.0f, 65.0f, 34.2f));
        presetTableService.createPreset(new PresetTable(null, "Energy Drink", "Beverages", "Refrigerator", 1, "kg", 60, 45, 0.0f, 0.0f, 11.0f, 0.0f));
        presetTableService.createPreset(new PresetTable(null, "Onion", "Vegetables", "Room Temperature", 1, "kg", 30, 40, 1.1f, 0.1f, 9.3f, 1.7f));
        presetTableService.createPreset(new PresetTable(null, "Cantaloupe", "Fruits", "Refrigerator", 1, "kg", 5, 34, 0.8f, 0.2f, 8.2f, 0.9f));
        presetTableService.createPreset(new PresetTable(null, "Tofu", "Dairy", "Refrigerator", 1, "kg", 14, 76, 8.0f, 4.8f, 1.9f, 0.3f));
        presetTableService.createPreset(new PresetTable(null, "Cream Cheese", "Dairy", "Refrigerator", 1, "kg", 14, 342, 6.2f, 34.0f, 4.1f, 0.0f));
        presetTableService.createPreset(new PresetTable(null, "Spinach", "Vegetables", "Refrigerator", 1, "kg", 7, 23, 2.9f, 0.4f, 3.6f, 2.2f));
        presetTableService.createPreset(new PresetTable(null, "Pineapple", "Fruits", "Refrigerator", 1, "kg", 5, 50, 0.5f, 0.1f, 13.1f, 1.4f));
        presetTableService.createPreset(new PresetTable(null, "Sausage", "Meat", "Freezer", 1, "kg", 180, 301, 13.0f, 27.0f, 1.0f, 0.0f));
        presetTableService.createPreset(new PresetTable(null, "Ricotta", "Dairy", "Refrigerator", 1, "kg", 14, 174, 11.3f, 13.0f, 3.0f, 0.0f));
        presetTableService.createPreset(new PresetTable(null, "Brown Rice", "Grains", "Pantry", 1, "kg", 365, 111, 2.6f, 0.9f, 23.0f, 1.8f));

    }
}
