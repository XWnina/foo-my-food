package com.foomyfood.foomyfood.database;

import java.util.Scanner;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;

import com.foomyfood.foomyfood.database.test_service.IngredientsService;

@Component
public class DataLoader implements CommandLineRunner {

    @Autowired
    private IngredientsService IngredientsService;

    @Override
    public void run(String... args) throws Exception {
        Scanner scanner = new Scanner(System.in);
        int lineCount = 50;  // 设置输入行数

        System.out.println("Please enter " + lineCount + " lines of vegetable data in the following format:");
        System.out.println("name,category,shelfLife,storageType");

        for (int i = 1; i <= lineCount; i++) {
            System.out.println("Enter data for ingredient " + i + ": ");
            String input = scanner.nextLine();
            String[] data = input.split(",");

            if (data.length == 4) {
                String name = data[0];
                String category = data[1];
                String shelfLife = data[2];
                String storageType = data[3];

                IngredientsService.createIngredients(name, category, shelfLife, storageType);

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
