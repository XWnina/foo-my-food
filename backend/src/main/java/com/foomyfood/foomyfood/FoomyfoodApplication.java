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

import com.foomyfood.foomyfood.service.SmartMenuService;

@SpringBootApplication(scanBasePackages = "com.foomyfood.foomyfood")
@EntityScan(basePackages = "com.foomyfood.foomyfood")
@EnableJpaRepositories(basePackages = "com.foomyfood.foomyfood.database.db_repository")
public class FoomyfoodApplication implements CommandLineRunner {

    @Autowired
    private SmartMenuService smartMenuService;

    public static void main(String[] args) {
        SpringApplication.run(FoomyfoodApplication.class, args);
        System.out.println("Backend running ...");
    }

    @Override
    public void run(String... args) throws Exception {
        // 检查命令行参数，决定是否启用交互模式
        if (args.length > 0 && args[0].equalsIgnoreCase("interactive")) {
            startInteractiveMode();
        } else {
            System.out.println("Running in standard mode. Use '/api/smartmenu/find-by-ingredient' endpoint for REST queries.");
        }
    }

    private void startInteractiveMode() {
        Scanner scanner = new Scanner(System.in);

        System.out.print("Please enter an ingredient to search in preset recipes: ");
        String ingredient = scanner.nextLine();

        List<Map<String, Object>> matchedRecipes = smartMenuService.findRecipesByIngredient(ingredient);
        if (matchedRecipes.isEmpty()) {
            System.out.println("No recipes found containing the ingredient: " + ingredient);
        } else {
            for (Map<String, Object> recipeInfo : matchedRecipes) {
                System.out.println("Recipe: " + recipeInfo.get("recipeName"));
                System.out.println("Ingredients: " + recipeInfo.get("ingredients"));
            }
        }
        scanner.close();
    }

    @PreDestroy
    public void onShutdown() {
        System.out.println("Backend stopped ...");
    }
}
