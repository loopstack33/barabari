import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'controllers/budget_controller.dart';
import 'screens/splash_screen.dart';

void main() {
  Get.put(BudgetController());
  runApp(const BarabriApp());
}

class BarabriApp extends StatelessWidget {
  const BarabriApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Barabri',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF2E7D6B),
        scaffoldBackgroundColor: const Color(0xFFF6F5F1),
      ),
      home: const SplashScreen(),
    );
  }
}
