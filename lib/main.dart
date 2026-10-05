import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'controllers/budget_controller.dart';
import 'screens/splash_screen.dart';
import 'theme/app_theme.dart';

void main() {
  Get.put(BudgetController());
  runApp(const BarabriApp());
}

class BarabriApp extends StatelessWidget {
  const BarabriApp({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BudgetController>();
    // Obx here makes the whole app rebuild when the theme changes, so every
    // AppColors.* getter re-reads the newly active preset.
    return Obx(
      () => GetMaterialApp(
        title: 'Barabri',
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(controller.activeTheme.value),
        home: const SplashScreen(),
      ),
    );
  }
}
