// package com.foomyfood.foomyfood;

// import java.util.List;
// import java.util.Map;
// import java.util.Scanner;

// import javax.annotation.PreDestroy;

// import org.springframework.beans.factory.annotation.Autowired;
// import org.springframework.boot.CommandLineRunner;
// import org.springframework.boot.SpringApplication;
// import org.springframework.boot.autoconfigure.SpringBootApplication;
// import org.springframework.boot.autoconfigure.domain.EntityScan;
// import org.springframework.data.jpa.repository.config.EnableJpaRepositories;

// import com.foomyfood.foomyfood.service.SmartMenuService;

// @SpringBootApplication(scanBasePackages = "com.foomyfood.foomyfood")
// @EntityScan(basePackages = "com.foomyfood.foomyfood")
// @EnableJpaRepositories(basePackages = "com.foomyfood.foomyfood.database.db_repository")
// public class FoomyfoodApplication implements CommandLineRunner {

//     @Autowired
//     private SmartMenuService smartMenuService;

//     public static void main(String[] args) {
//         SpringApplication.run(FoomyfoodApplication.class, args);
//         System.out.println("Backend running ...");
//     }

//     @Override
//     public void run(String... args) throws Exception {
//         Scanner scanner = new Scanner(System.in);

//         System.out.print("Please enter a user ID: ");
//         Long userId = scanner.nextLong();
//         scanner.nextLine();  // Consume newline

//         System.out.println("Choose recipe source (1 for user, 2 for preset): ");
//         int sourceChoice = scanner.nextInt();
//         scanner.nextLine();  // Consume newline

//         System.out.println("Use expiring ingredients? (yes or no): ");
//         boolean useExpiring = scanner.nextLine().equalsIgnoreCase("yes");

//         List<Map<String, Object>> recipes;

//         if (sourceChoice == 1) {
//             if (useExpiring) {
//                 recipes = smartMenuService.findCustomRecipesByExpiringIngredients(userId);
//             } else {
//                 recipes = smartMenuService.findCustomRecipesByUserIngredients(userId);
//             }
//         } else if (sourceChoice == 2) {
//             if (useExpiring) {
//                 recipes = smartMenuService.findPresetRecipesByExpiringIngredients(userId);
//             } else {
//                 recipes = smartMenuService.findPresetRecipesByUserIngredients(userId);
//             }
//         } else {
//             System.out.println("Invalid choice. Exiting.");
//             return;
//         }

//         printRecipes(recipes);
//     }

//     private void printRecipes(List<Map<String, Object>> recipes) {
//         if (recipes.isEmpty()) {
//             System.out.println("No matching recipes found.");
//         } else {
//             for (Map<String, Object> recipe : recipes) {
//                 System.out.println("Recipe: " + recipe.get("recipeName"));
//                 System.out.println("Ingredient Score: " + recipe.get("ingredientScore"));
//                 System.out.println("Ingredient Percentage: " + recipe.get("ingredientPercentage"));
//                 System.out.println("Matched Ingredients: " + recipe.get("matchedIngredients"));
//                 System.out.println("Ingredients: " + recipe.get("ingredients"));
//                 System.out.println();
//             }
//         }
//     }

//     @PreDestroy
//     public void onShutdown() {
//         System.out.println("Backend stopped ...");
//     }
// }

package com.foomyfood.foomyfood;

import javax.annotation.PreDestroy;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.autoconfigure.domain.EntityScan;
import org.springframework.data.jpa.repository.config.EnableJpaRepositories;


@SpringBootApplication(scanBasePackages = "com.foomyfood.foomyfood")
@EntityScan(basePackages = "com.foomyfood.foomyfood")
@EnableJpaRepositories(basePackages = "com.foomyfood.foomyfood.database.db_repository")
public class FoomyfoodApplication {



	public static void main(String[] args) {
		SpringApplication.run(FoomyfoodApplication.class, args);
		System.out.println("Backend running ...");
	}
	@PreDestroy
	public void onShutdown() {
		System.out.println("Backend stopped ...");
	}

}
