import 'package:reading_where/service_locator.dart';
import 'package:flutter/material.dart';
import 'app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  setupServiceLocator();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reading Where',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          background: Colors.grey[50]
        ),
        useMaterial3: true,
        textTheme: const TextTheme(
          bodyMedium: TextStyle(
              fontSize: 18,
              letterSpacing: 1.2
          ),
        ),
        inputDecorationTheme: const InputDecorationTheme(
            hintStyle: TextStyle(
                fontSize: 16,
                letterSpacing: 1.2
            )
        ),
        checkboxTheme: CheckboxThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0),
          ),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
      home: MyHomePage(),
    );
  }
}


