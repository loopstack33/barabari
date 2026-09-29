import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'controllers/budget_controller.dart';
import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Get.put(BudgetController());
  runApp(const SalaryTrackerApp());
}

class SalaryTrackerApp extends StatelessWidget {
  const SalaryTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Salary Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF2E7D6B),
        scaffoldBackgroundColor: const Color(0xFFF6F5F1),
      ),
      home: const HomeScreen(),
    );
  }
}
