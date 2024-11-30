import 'package:flutter/material.dart';

import 'calculator_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculator',
      theme: ThemeData.light(),
      debugShowCheckedModeBanner: false, // Disable the debug banner
      home: const CalculatorScreen(),
    );
  }
}
