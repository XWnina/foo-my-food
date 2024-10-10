package com.foomyfood.foomyfood.database.testing;

import java.util.Scanner;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;

import com.foomyfood.foomyfood.database.db_service.IngredientService;

@Component
public class IngredientTester implements CommandLineRunner {

    @Autowired
    private IngredientService IngredientService;

    @Override
    public void run(String... args) throws Exception {
        Scanner scanner = new Scanner(System.in);

        System.out.println("Please enter a line of vegetable data in the following format:");
        System.out.println("name,category,imageURL,storageMethod,baseQuantity,unit,expirationDate,isUserCreated,createdBy,calories,protein,fat,carbohydrates,fiber");

        String input = scanner.nextLine();
        String[] data = input.split(",");

        if (data.length == 14) {
            String name = data[0];
            String category = data[1];
            String imageURL = data[2];
            String storageMethod = data[3];
            int baseQuantity = Integer.parseInt(data[4]); // Convert string to int
            String unit = data[5];
            String expirationDate = data[6];
            boolean isUserCreated = Boolean.parseBoolean(data[7]); // Convert string to boolean
            long createdBy = Long.parseLong(data[8]); // Convert string to long
            int calories = Integer.parseInt(data[9]); // Convert string to int
            float protein = Float.parseFloat(data[10]); // Convert string to float
            float fat = Float.parseFloat(data[11]); // Convert string to float
            float carbohydrates = Float.parseFloat(data[12]); // Convert string to float
            float fiber = Float.parseFloat(data[13]); // Convert string to float

            IngredientService.createIngredient(name, category, imageURL, storageMethod, baseQuantity, unit, expirationDate, isUserCreated, createdBy, calories, protein, fat, carbohydrates, fiber);

            System.out.println("Ingredient '" + name + "' created successfully!");
        } else {
            System.out.println("Invalid input format. Please provide 14 comma-separated values.");
        }

        scanner.close();
    }
}
