package com.foomyfood.foomyfood.database.initialization;

import java.util.Arrays;
import java.util.HashSet;
import java.util.Set;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;

import com.foomyfood.foomyfood.database.PresetRecipe;
import com.foomyfood.foomyfood.database.db_service.PresetRecipeService;

@Component
public class PresetRecipeInitializer implements CommandLineRunner {

    @Autowired
    private PresetRecipeService presetRecipeService;

    private static final Set<String> VALID_LABELS = new HashSet<>(Arrays.asList(
            "breakfast", "lunch", "dinner", "dessert", "snack", "vegan", "vegetarian"
    ));

    @Override
    public void run(String... args) throws Exception {
        createInitializationPresets();
    }

    private void createInitializationPresets() {
        if (presetRecipeService.getAllPresetRecipes().isEmpty()) {
            presetRecipeService.addPresetRecipe(new PresetRecipe(
                    "Kung Pao Chicken", 
                    220, 
                    null, 
                    null, 
                    "Cut chicken breast into cubes and marinate with salt and cooking wine. Prepare peanuts and bell peppers. Heat oil in a pan, stir-fry the chicken until it changes color, add peanuts and bell peppers, stir evenly, and season to taste.",
                    "chicken breast, peanuts, bell peppers, salt, cooking wine, seasoning",
                    "lunch,dinner"));

            presetRecipeService.addPresetRecipe(new PresetRecipe(
                    "Braised Pork Ribs", 
                    360, 
                    null, 
                    null, 
                    "Blanch the pork ribs to remove blood. Heat oil and sugar in a pan until caramelized, add ribs and stir-fry until colored. Add soy sauce, cooking wine, ginger, and water. Simmer for 40 minutes until tender.",
                    "pork ribs, ginger, soy sauce, cooking wine, sugar",
                    "dinner"));

            presetRecipeService.addPresetRecipe(new PresetRecipe(
                    "Mapo Tofu", 
                    150, 
                    null, 
                    null, 
                    "Cut tofu into cubes and blanch to remove the beany taste. Heat oil, add minced ginger and garlic, stir-fry with chili bean paste until fragrant. Add tofu and stir-fry, add water and bring to a boil, garnish with green onions.",
                    "tofu, ginger, garlic, chili bean paste, green onions",
                    "lunch,dinner,vegetarian"));

            presetRecipeService.addPresetRecipe(new PresetRecipe(
                    "Yu Xiang Shredded Pork", 
                    290, 
                    null, 
                    null, 
                    "Cut pork into thin strips, marinate with salt and cooking wine. Stir-fry ginger and garlic until fragrant, add pork strips and stir-fry until cooked, then add fish-fragrant sauce and mix well.",
                    "pork, ginger, garlic, fish-fragrant sauce",
                    "lunch,dinner"));

            presetRecipeService.addPresetRecipe(new PresetRecipe(
                    "Sweet and Sour Pork", 
                    250, 
                    null, 
                    null, 
                    "Cut pork loin into strips, coat with egg and starch. Deep fry until golden brown. In another pan, mix sugar and vinegar to make sweet and sour sauce, add the pork and stir to coat.",
                    "pork loin, egg, starch, sugar, vinegar",
                    "lunch,dinner"));

            presetRecipeService.addPresetRecipe(new PresetRecipe(
                    "Stir-fried Broccoli", 
                    80, 
                    null, 
                    null, 
                    "Cut broccoli into small florets, blanch and drain. Heat oil, add garlic slices, stir-fry until fragrant, add broccoli and stir-fry with a pinch of salt.",
                    "broccoli, garlic, salt",
                    "lunch,dinner,vegetarian,vegan"));

            presetRecipeService.addPresetRecipe(new PresetRecipe(
                    "Spicy and Sour Shredded Potatoes", 
                    110, 
                    null, 
                    null, 
                    "Cut potatoes into thin strips, rinse to remove starch. Heat oil, add dried chili, stir-fry until fragrant, add potatoes, vinegar, and salt, stir evenly.",
                    "potatoes, dried chili, vinegar, salt",
                    "lunch,dinner,vegetarian,vegan"));

            presetRecipeService.addPresetRecipe(new PresetRecipe(
                    "Egg Fried Rice", 
                    180, 
                    null, 
                    null, 
                    "Beat eggs, heat oil in a pan and cook the eggs until firm. Add cold rice and stir-fry evenly. Season with salt and garnish with green onions.",
                    "eggs, cold rice, salt, green onions",
                    "breakfast,lunch,dinner"));

            presetRecipeService.addPresetRecipe(new PresetRecipe(
                    "Chicken with Mushrooms", 
                    320, 
                    null, 
                    null, 
                    "Combine chicken and mushrooms in a pot, add water, ginger slices, and cooking wine. Simmer over medium heat for 40 minutes, add salt to taste.",
                    "chicken, mushrooms, ginger, cooking wine, salt",
                    "lunch,dinner"));

            presetRecipeService.addPresetRecipe(new PresetRecipe(
                    "Shrimp with Scrambled Eggs", 
                    190, 
                    null, 
                    null, 
                    "Peel shrimp and marinate with a pinch of salt. Beat eggs. Heat oil, pour in eggs, add shrimp, and stir-fry until eggs are set.",
                    "shrimp, eggs, salt",
                    "breakfast,lunch"));

            System.out.println("Initialized preset recipes with Chinese cuisine.");
        } else {
            System.out.println("Preset recipes already initialized, skipping initialization.");
        }
    }

    // Helper method to validate and format labels
    private String validateLabels(String labels) {
        if (labels == null || labels.isEmpty()) {
            return "";
        }

        StringBuilder validLabels = new StringBuilder();
        String[] labelArray = labels.split(",");
        for (String label : labelArray) {
            String trimmedLabel = label.trim().toLowerCase();
            if (VALID_LABELS.contains(trimmedLabel)) {
                if (validLabels.length() > 0) {
                    validLabels.append(",");
                }
                validLabels.append(trimmedLabel);
            }
        }
        return validLabels.toString();
    }
}
