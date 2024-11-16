package com.foomyfood.foomyfood;

import java.util.List;
import java.util.Map;
import java.util.Scanner;

import javax.annotation.PreDestroy;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.autoconfigure.domain.EntityScan;
import org.springframework.data.jpa.repository.config.EnableJpaRepositories;

import com.foomyfood.foomyfood.database.db_service.PresetRecipeService;
import com.foomyfood.foomyfood.database.db_service.RecipeService;
import com.foomyfood.foomyfood.service.SmartMenuService;

@SpringBootApplication(scanBasePackages = "com.foomyfood.foomyfood")
@EntityScan(basePackages = "com.foomyfood.foomyfood")
@EnableJpaRepositories(basePackages = "com.foomyfood.foomyfood.database.db_repository")
public class FoomyfoodApplication implements CommandLineRunner {

    @Autowired
    private SmartMenuService smartMenuService;

    @Autowired
    private PresetRecipeService presetRecipeService;

    @Autowired
    private RecipeService recipeService;

    public static void main(String[] args) {
        SpringApplication.run(FoomyfoodApplication.class, args);
        System.out.println("Backend running ...");
    }

    @Override
    public void run(String... args) throws Exception {
        Scanner scanner = new Scanner(System.in);

        System.out.println("Enter 'st' to run Smart Menu Testing or press Enter to start the basic Spring Boot application:");
        String input = scanner.nextLine().trim();

        if ("st".equalsIgnoreCase(input)) {
            runSmartMenuTesting(scanner);
        } else {
            System.out.println("Starting basic Spring Boot application...");
        }
    }

    private void runSmartMenuTesting(Scanner scanner) {
        System.out.println("Running Smart Menu Testing...");

        System.out.print("Please enter a user ID: ");
        Long userId = scanner.nextLong();
        scanner.nextLine();

        System.out.println("Choose recipe source (1 for user, 2 for preset): ");
        int sourceChoice = scanner.nextInt();
        scanner.nextLine();

        System.out.println("Use expiring ingredients? (yes or no): ");
        boolean useExpiring = scanner.nextLine().equalsIgnoreCase("yes");

        // Step 1: Fetch detailed recipe information
        List<Map<String, Object>> recipeDetails;
        if (sourceChoice == 1) {
            recipeDetails = useExpiring
                    ? smartMenuService.findCustomRecipesByExpiringIngredientsWithDetails(userId)
                    : smartMenuService.findCustomRecipesByUserIngredientsWithDetails(userId);
        } else if (sourceChoice == 2) {
            recipeDetails = useExpiring
                    ? smartMenuService.findPresetRecipesByExpiringIngredientsWithDetails(userId)
                    : smartMenuService.findPresetRecipesByUserIngredientsWithDetails(userId);
        } else {
            System.out.println("Invalid choice. Exiting.");
            return;
        }

        // Step 2: Print details in a human-readable format
        printRecipesInDetails(recipeDetails);

        // Step 3: Print IDs based on conditions
        printRecipeIDs(userId, sourceChoice, useExpiring);

        // Step 4: Test JSON output
        testJsonOutput(userId, sourceChoice == 2, useExpiring);
    }

    private void printRecipesInDetails(List<Map<String, Object>> recipes) {
        if (recipes.isEmpty()) {
            System.out.println("No matching recipes found.");
        } else {
            for (Map<String, Object> recipe : recipes) {
                System.out.println("Recipe ID: " + recipe.get("recipeId"));
                System.out.println("Preset Recipe ID: " + recipe.get("presetRecipeId"));
                System.out.println("Recipe: " + recipe.get("recipeName"));
                System.out.println("Ingredients: " + recipe.get("ingredients"));
                System.out.println("Matched Ingredients: " + recipe.get("matchedIngredients"));
                System.out.println("Score: " + recipe.get("ingredientScore"));
                System.out.println("Percentage: " + recipe.get("ingredientPercentage"));
                System.out.println();
            }
        }
    }

    private void printRecipeIDs(Long userId, int sourceChoice, boolean useExpiring) {
        System.out.println("=====Recipe IDs=====");
        List<Long> recipeIds;
        if (sourceChoice == 1 && !useExpiring) {
            recipeIds = smartMenuService.findCustomRecipesByUserIngredients(userId);
            System.out.println("User Recipe IDs: " + recipeIds);
        } else if (sourceChoice == 1 && useExpiring) {
            recipeIds = smartMenuService.findCustomRecipesByExpiringIngredients(userId);
            System.out.println("User Recipe IDs: " + recipeIds);
        } else if (sourceChoice == 2 && !useExpiring) {
            recipeIds = smartMenuService.findPresetRecipesByUserIngredients(userId);
            System.out.println("Preset Recipe IDs: " + recipeIds);
        } else if (sourceChoice == 2 && useExpiring) {
            recipeIds = smartMenuService.findPresetRecipesByExpiringIngredients(userId);
            System.out.println("Preset Recipe IDs: " + recipeIds);
        }
    }

    private void testJsonOutput(Long userId, boolean isPreset, boolean useExpiring) {
        System.out.println("=====JSON Output=====");
        List<Map<String, Object>> jsonOutput = smartMenuService.getDetailedRecipeInfo(userId, isPreset, useExpiring);
        if (jsonOutput.isEmpty()) {
            System.out.println("No recipes found for the given criteria.");
        } else {
            jsonOutput.forEach(recipe -> System.out.println("Recipe JSON: " + recipe));
        }
        System.out.println("=====End of JSON Test=====");
    }

    @PreDestroy
    public void onShutdown() {
        System.out.println("Backend stopped ...");
    }
}
