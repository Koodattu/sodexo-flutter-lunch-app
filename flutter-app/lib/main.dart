import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/lunch_app_state.dart';
import 'pages/lunch_app_home_page.dart';

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
        title: 'Namer App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.pink,
            brightness: Brightness.dark,
          ),
        ),
        home: const LunchAppHomePage(),
      ),
    );
  }
}
