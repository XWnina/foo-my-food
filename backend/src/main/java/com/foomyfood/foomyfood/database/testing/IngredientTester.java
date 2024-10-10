package com.foomyfood.foomyfood.database.testing;

import java.util.Scanner;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;

import com.foomyfood.foomyfood.database.db_service.IngredientService;

// @Component
public class IngredientTester implements CommandLineRunner {

    @Autowired
    private IngredientService ingredientService;

    @Override
    public void run(String... args) throws Exception {
        Scanner scanner = new Scanner(System.in);

        System.out.println("Please enter multiple lines of vegetable data in the following format:");
        System.out.println("name,category,imageURL,storageMethod,baseQuantity,unit,expirationDate,isUserCreated,createdBy,calories,protein,fat,carbohydrates,fiber");
        System.out.println("Enter an empty line to finish input.");

        StringBuilder inputBuilder = new StringBuilder();
        while (true) {
            String line = scanner.nextLine();
            if (line.isEmpty()) {
                break; // Exit the loop when the user enters an empty line
            }
            inputBuilder.append(line).append("\n");
        }

        // Split the input by lines
        String[] lines = inputBuilder.toString().split("\n");

        for (String line : lines) {
            String[] data = line.split(",");
            if (data.length == 14) {
                String name = data[0];
                String category = data[1];
                String imageURL = data[2];
                String storageMethod = data[3];
                int baseQuantity = Integer.parseInt(data[4]);
                String unit = data[5];
                String expirationDate = data[6];
                boolean isUserCreated = Boolean.parseBoolean(data[7]);
                long createdBy = Long.parseLong(data[8]);
                int calories = Integer.parseInt(data[9]);
                float protein = Float.parseFloat(data[10]);
                float fat = Float.parseFloat(data[11]);
                float carbohydrates = Float.parseFloat(data[12]);
                float fiber = Float.parseFloat(data[13]);

                ingredientService.createIngredient(
                    name, category, imageURL, storageMethod, baseQuantity, unit, expirationDate, isUserCreated, createdBy, 
                    calories, protein, fat, carbohydrates, fiber
                );

                System.out.println("Ingredient '" + name + "' created successfully!");
            } else {
                System.out.println("Invalid input format for: " + line);
            }
        }

        scanner.close();
    }
}
