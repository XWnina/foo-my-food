package com.foomyfood.foomyfood.database.testing;

import java.util.Scanner;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;

import com.foomyfood.foomyfood.database.db_service.IngredientService;

// @Component
public class DataLoader implements CommandLineRunner {

    @Autowired
    private IngredientService IngredientsService;

    @Override
    public void run(String... args) throws Exception {
        Scanner scanner = new Scanner(System.in);
        int lineCount = 50; 

        System.out.println("Please enter " + lineCount + " lines of vegetable data in the following format:");
        System.out.println("name,category,shelfLife,storageType");

        for (int i = 1; i <= lineCount; i++) {
            System.out.println("Enter data for ingredient " + i + ": ");
            String input = scanner.nextLine();
            String[] data = input.split(",");

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


                // IngredientService.createIngredient(name, category, imageURL, storageMethod, baseQuantity, unit, expirationDate,isUserCreated, createdBy, calories, protein, fat, carbohydrates, fiber);

                System.out.println("Ingredient " + i + " created successfully!");
            } else {
                System.out.println("Invalid input format. Please provide 4 comma-separated values.");
                i--; 
            }
        }

        System.out.println(lineCount + " Ingredients added to the database.");
        scanner.close();
    }
}
