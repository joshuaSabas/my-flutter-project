import 'package:flutter/material.dart';
import 'splash_screen.dart';
import 'dashboard_screen.dart'; // 👈 PALITAN ITO! (dati home_screen)
import 'existing_data_screen.dart'; // 👈 DAGDAG ITO!
import 'database/database_helper.dart'; // 👈 DAGDAG ITO!

void main() async {
  // 👇 DAGDAG ITO PARA MA-CHECK ANG DATA
  WidgetsFlutterBinding.ensureInitialized();
  
  // 👇 CHECK IF MAY EXISTING DATA
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
      // 👇 ITO ANG BAGONG LOGIC
      home: hasExistingData 
          ? const ExistingDataScreen()  // MAY DATA, ASK USER
          : const SplashScreen(),       // WALANG DATA, NORMAL FLOW
    );
  }
}
