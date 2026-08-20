import 'package:flutter/material.dart';
import 'splash_screen.dart';
import 'home_screen.dart'; // ← IDAGDAG ITO!

void main() {
  runApp(const FertilizerCalcApp());
}

class FertilizerCalcApp extends StatelessWidget {
  const FertilizerCalcApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FertilizerCalc',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2E7D32),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
