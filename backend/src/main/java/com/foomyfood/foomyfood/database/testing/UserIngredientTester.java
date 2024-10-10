package com.foomyfood.foomyfood.database.testing;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;

import com.foomyfood.foomyfood.database.db_service.UserIngredientService;

@Component
public class UserIngredientTester implements CommandLineRunner {

    @Autowired
    private UserIngredientService userIngredientService;

    @Override
    public void run(String... args) throws Exception {
        createTestUserIngredients();
    }

    private void createTestUserIngredients() {
        userIngredientService.createUserIngredient(Long.valueOf(21), Long.valueOf(1), 5);
        userIngredientService.createUserIngredient(Long.valueOf(21), Long.valueOf(2), 10);
        userIngredientService.createUserIngredient(Long.valueOf(21), Long.valueOf(3), 2);
        userIngredientService.createUserIngredient(Long.valueOf(21), Long.valueOf(4), 7);
        userIngredientService.createUserIngredient(Long.valueOf(21), Long.valueOf(5), 1);
        userIngredientService.createUserIngredient(Long.valueOf(21), Long.valueOf(6), 12);
        userIngredientService.createUserIngredient(Long.valueOf(21), Long.valueOf(7), 8);
        userIngredientService.createUserIngredient(Long.valueOf(21), Long.valueOf(8), 4);
        userIngredientService.createUserIngredient(Long.valueOf(21), Long.valueOf(9), 9);
        userIngredientService.createUserIngredient(Long.valueOf(21), Long.valueOf(10), 3);

        System.out.println("Test user ingredients created successfully!");
    }
}
