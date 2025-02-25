import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sodexo_flutter_lunch_app/pages/main_screen_page.dart';
import 'providers/lunch_app_state.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => LunchAppState(),
      child: MaterialApp(
        title: 'SDX Restaurant Menus',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.black,
            brightness: Brightness.dark,
          ),
        ),
        home: const MainScreen(),
      ),
    );
  }
}
