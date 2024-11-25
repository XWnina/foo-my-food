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
        // printPresetRecipeInfo();
    }

    private void createInitializationPresets() {
        if (presetRecipeService.getAllPresetRecipes().isEmpty()) {
            presetRecipeService.addPresetRecipe(new PresetRecipe(
                    "Kung Pao Chicken",
                    220,
                    null,
                    null,
                    "Cut chicken breast into cubes and marinate with salt and cooking wine. Prepare peanuts and bell pepper. Heat oil in a pan, stir-fry the chicken until it changes color, add peanuts and bell pepper, stir evenly, and season to taste.",
                    "chicken breast, peanut, bell pepper",
                    "lunch, dinner"));

            presetRecipeService.addPresetRecipe(new PresetRecipe(
                    "Braised Pork Ribs",
                    360,
                    null,
                    null,
                    "Blanch the pork rib to remove blood. Heat oil and sugar in a pan until caramelized, add rib and stir-fry until colored. Add soy sauce, cooking wine, ginger, and water. Simmer for 40 minutes until tender.",
                    "pork rib, ginger",
                    "dinner"));

            presetRecipeService.addPresetRecipe(new PresetRecipe(
                    "Mapo Tofu",
                    150,
                    null,
                    null,
                    "Cut tofu into cubes and blanch to remove the beany taste. Heat oil, add minced ginger and garlic, stir-fry with chili bean paste until fragrant. Add tofu and stir-fry, add water and bring to a boil, garnish with green onion.",
                    "tofu, ginger, garlic, chili bean paste, green onion",
                    "lunch, dinner, vegetarian"));

            presetRecipeService.addPresetRecipe(new PresetRecipe(
                    "Yu Xiang Shredded Pork",
                    290,
                    null,
                    null,
                    "Cut pork into thin strips, marinate with salt and cooking wine. Stir-fry ginger and garlic until fragrant, add pork strip and stir-fry until cooked, then add fish-fragrant sauce and mix well.",
                    "pork, ginger, garlic, fish-fragrant sauce",
                    "lunch, dinner"));

            presetRecipeService.addPresetRecipe(new PresetRecipe(
                    "Sweet and Sour Pork",
                    250,
                    null,
                    null,
                    "Cut pork into strips, coat with egg and starch. Deep fry until golden brown. In another pan, mix sugar and vinegar to make sweet and sour sauce, add the pork and stir to coat.",
                    "pork, egg, starch, vinegar",
                    "lunch, dinner"));

            presetRecipeService.addPresetRecipe(new PresetRecipe(
                    "Stir-fried Broccoli",
                    80,
                    null,
                    null,
                    "Cut broccoli into small florets, blanch and drain. Heat oil, add garlic slice, stir-fry until fragrant, add broccoli and stir-fry with a pinch of salt.",
                    "broccoli, garlic",
                    "lunch, dinner, vegetarian, vegan"));

            presetRecipeService.addPresetRecipe(new PresetRecipe(
                    "Spicy and Sour Shredded Potatoes",
                    110,
                    null,
                    null,
                    "Cut potato into thin strips, rinse to remove starch. Heat oil, add dried chili, stir-fry until fragrant, add potato, and vinegar, stir evenly.",
                    "potato, dried chili, vinegar",
                    "lunch, dinner, vegetarian, vegan"));

            presetRecipeService.addPresetRecipe(new PresetRecipe(
                    "Egg Fried Rice",
                    180,
                    null,
                    null,
                    "Beat egg, heat oil in a pan and cook the egg until firm. Add cold rice and stir-fry evenly. Season with salt and garnish with green onion.",
                    "egg, cold rice, green onion",
                    "breakfast, lunch, dinner"));

            presetRecipeService.addPresetRecipe(new PresetRecipe(
                    "Chicken with Mushrooms",
                    320,
                    null,
                    null,
                    "Combine chicken and mushroom in a pot, add water, ginger slice, and cooking wine. Simmer over medium heat for 40 minutes, add salt to taste.",
                    "chicken, mushroom, ginger",
                    "lunch, dinner"));

            presetRecipeService.addPresetRecipe(new PresetRecipe(
                    "Shrimp with Scrambled Egg",
                    190,
                    null,
                    null,
                    "Peel shrimp and marinate with a pinch of salt. Beat egg. Heat oil, pour in egg, add shrimp, and stir-fry until egg is set.",
                    "shrimp, egg",
                    "breakfast, lunch"));

            presetRecipeService.addPresetRecipe(new PresetRecipe(
                    "Tomato Scrambled Egg",
                    180,
                    null,
                    null,
                    "Cut tomato into small wedges. Beat egg with a pinch of salt. Heat oil in a pan, pour in egg, cook until halfway done, add tomato, and stir-fry until combined and tomato is soft.",
                    "tomato, egg",
                    "breakfast, lunch, dinner"));

            presetRecipeService.addPresetRecipe(new PresetRecipe(
                    "Tomato Egg Soup",
                    90,
                    null,
                    null,
                    "Cut tomato into small pieces. Boil water, add tomato and simmer until soft. Beat egg and slowly pour into the soup while stirring gently. Season with salt and garnish with green onion.",
                    "tomato, egg, water",
                    "lunch, dinner, vegetarian"));

            presetRecipeService.addPresetRecipe(new PresetRecipe(
                    "Beef Stir-fry with Bell Peppers",
                    230,
                    null,
                    null,
                    "Slice beef thinly, marinate with soy sauce, cornstarch, and a pinch of sugar. Stir-fry sliced bell peppers until tender, set aside. Stir-fry beef until just cooked, mix with bell peppers and serve.",
                    "beef, bell pepper, soy sauce, cornstarch, sugar",
                    "lunch, dinner"));

            presetRecipeService.addPresetRecipe(new PresetRecipe(
                    "Spicy Sichuan Noodles",
                    350,
                    null,
                    null,
                    "Cook noodles until tender and drain. Prepare a sauce with soy sauce, vinegar, chili oil, minced garlic, and sugar. Mix the sauce with noodles and garnish with chopped peanuts and green onion.",
                    "noodles, soy sauce, vinegar, chili oil, garlic, peanuts, green onion",
                    "lunch, dinner, vegetarian"));

            presetRecipeService.addPresetRecipe(new PresetRecipe(
                    "Cucumber Salad",
                    50,
                    null,
                    null,
                    "Slice cucumber thinly, sprinkle with salt, and let sit for 10 minutes. Mix with soy sauce, vinegar, garlic, and a drizzle of sesame oil. Chill before serving.",
                    "cucumber, garlic, soy sauce, vinegar, sesame oil",
                    "snack, lunch, dinner, vegetarian, vegan"));

            presetRecipeService.addPresetRecipe(new PresetRecipe(
                    "Peking Duck Wraps",
                    400,
                    null,
                    null,
                    "Slice roasted Peking duck thinly. Prepare thin pancakes and add slices of duck, cucumber, and green onion. Drizzle with hoisin sauce and wrap tightly.",
                    "Peking duck, cucumber, green onion, hoisin sauce, pancake",
                    "lunch, dinner"));

            presetRecipeService.addPresetRecipe(new PresetRecipe(
                    "Spinach and Garlic Stir-fry",
                    70,
                    null,
                    null,
                    "Heat oil in a pan, add minced garlic, and stir-fry until fragrant. Add spinach and stir-fry until wilted. Season with salt and serve.",
                    "spinach, garlic, salt",
                    "lunch, dinner, vegetarian, vegan"));

            presetRecipeService.addPresetRecipe(new PresetRecipe(
                    "Hot and Sour Soup",
                    120,
                    null,
                    null,
                    "Boil chicken or vegetable stock. Add tofu, shiitake mushrooms, and bamboo shoots. Season with soy sauce, vinegar, white pepper, and chili oil. Thicken with cornstarch slurry and garnish with green onion.",
                    "tofu, shiitake mushroom, bamboo shoot, soy sauce, vinegar, chili oil, cornstarch, green onion",
                    "lunch, dinner, vegetarian"));

            presetRecipeService.addPresetRecipe(new PresetRecipe(
                    "Chinese Scallion Pancakes",
                    180,
                    null,
                    null,
                    "Make dough with flour and water, roll it out and sprinkle with chopped scallions. Roll the dough into a spiral, flatten, and pan-fry until crispy and golden.",
                    "flour, water, scallion, salt",
                    "breakfast, snack, vegetarian"));

            presetRecipeService.addPresetRecipe(new PresetRecipe(
                    "Sesame Chicken",
                    250,
                    null,
                    null,
                    "Cut chicken into bite-sized pieces, coat with cornstarch, and deep fry until crispy. In a pan, mix soy sauce, vinegar, sugar, and sesame oil to make a sauce. Add chicken and toss to coat, sprinkle with sesame seeds.",
                    "chicken, soy sauce, vinegar, sugar, sesame oil, sesame seeds",
                    "lunch, dinner"));

            presetRecipeService.addPresetRecipe(new PresetRecipe(
                    "Chinese Eggplant with Garlic Sauce",
                    150,
                    null,
                    null,
                    "Cut eggplant into strips. Stir-fry until soft, set aside. In a pan, heat oil and fry minced garlic, add soy sauce, vinegar, and a pinch of sugar. Add eggplant and toss well.",
                    "eggplant, garlic, soy sauce, vinegar, sugar",
                    "lunch, dinner, vegetarian, vegan"));

            presetRecipeService.addPresetRecipe(new PresetRecipe(
                    "Chinese Beef Dumplings",
                    200,
                    null,
                    null,
                    "Prepare dumpling wrappers. Mix ground beef with minced ginger, garlic, and soy sauce. Wrap the filling in dumpling wrappers and steam or boil until cooked.",
                    "ground beef, ginger, garlic, soy sauce, dumpling wrapper",
                    "lunch, dinner"));

            presetRecipeService.addPresetRecipe(new PresetRecipe(
                    "Honey Walnut Shrimp",
                    380,
                    null,
                    null,
                    "Coat shrimp with cornstarch and deep fry until golden. In another pan, make a sauce with honey, mayonnaise, and lemon juice. Toss the shrimp in the sauce and top with candied walnuts.",
                    "shrimp, cornstarch, honey, mayonnaise, lemon juice, walnut",
                    "lunch, dinner"));

            presetRecipeService.addPresetRecipe(new PresetRecipe(
                    "Steamed Fish with Ginger and Soy Sauce",
                    210,
                    null,
                    null,
                    "Place fish fillet on a plate, top with ginger slices. Steam for 10 minutes. Heat soy sauce and pour over the fish. Garnish with scallion and serve.",
                    "fish fillet, ginger, soy sauce, scallion",
                    "lunch, dinner"));

            System.out.println("Initialized preset recipes with Chinese cuisine.");
        } else {
            System.out.println("Preset recipes already initialized, skipping initialization.");
        }
    }

    private void printPresetRecipeInfo() {
        System.out.println("Database Preset Recipes:");
        presetRecipeService.getAllPresetRecipes().forEach(recipe -> {
            System.out.println("Recipe Name: " + recipe.getDishName());
            System.out.println("Calories: " + recipe.getCalories());
            System.out.println("Labels: " + recipe.getLabels());
            System.out.println("Ingredients: " + recipe.getIngredients());
            System.out.println("Instructions: " + recipe.getDescription());
            System.out.println("-----------------------------------");
        });
    }
}
