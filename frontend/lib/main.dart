import 'package:flutter/material.dart';
import 'screens/login_page.dart';
import 'package:provider/provider.dart';
import 'providers/ingredient_provider.dart';
import 'providers/shopping_list_provider.dart'; // 引入 ShoppingListProvider
import 'providers/recipe_provider.dart'; 
import 'package:device_calendar/device_calendar.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => IngredientProvider()),
        ChangeNotifierProvider(create: (context) => ShoppingListProvider()), // 添加 ShoppingListProvider
        ChangeNotifierProvider(create: (context) => RecipeProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Foo my food Demo ',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 30, 108, 168),
        ),
        useMaterial3: true,
      ),
      home: const LoginPage(),
    );
  }
}
