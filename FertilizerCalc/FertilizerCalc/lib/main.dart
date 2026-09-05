import 'package:flutter/material.dart';
import 'splash_screen.dart';
import 'dashboard_screen.dart';
import 'existing_data_screen.dart';
import 'database/database_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final db = DatabaseHelper();
  final hasData = await db.hasExistingData();
  
  runApp(FertilizerCalcApp(hasExistingData: hasData));
}

class FertilizerCalcApp extends StatelessWidget {
  final bool hasExistingData;
  
  const FertilizerCalcApp({super.key, required this.hasExistingData});

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
      home: hasExistingData 
          ? const ExistingDataScreen()
          : const SplashScreen(),
    );
  }
}
