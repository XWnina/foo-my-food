import 'package:flutter/material.dart';
import 'screens/login_page.dart';
import 'screens/login_page.dart';
import 'package:provider/provider.dart';
import 'providers/ingredient_provider.dart';
import 'package:device_calendar/device_calendar.dart';
void main() {
   runApp(
    ChangeNotifierProvider(
      create: (context) => IngredientProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Foo my food Demo ',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 30, 108, 168)),
        useMaterial3: true,
      ),
      home: const LoginPage(),
    );
  }
}
