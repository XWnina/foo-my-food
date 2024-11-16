import 'package:flutter/material.dart';
import 'screens/login_page.dart';
import 'package:provider/provider.dart';
import 'providers/ingredient_provider.dart';
import 'providers/shopping_list_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/collection_provider.dart'; // 导入 CollectionProvider

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => IngredientProvider()),
        ChangeNotifierProvider(create: (context) => ShoppingListProvider()),
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => CollectionProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'Foo My Food Demo',
      theme: ThemeData(
        scaffoldBackgroundColor: themeProvider.theme.backgroundColor,
        appBarTheme: AppBarTheme(
          color: themeProvider.theme.appBarColor,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: themeProvider.theme.buttonBackgroundColor,
          ),
        ),
      ),
      home: const LoginPage(),
    );
  }
}
