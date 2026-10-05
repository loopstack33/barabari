import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/budget_controller.dart';
import '../theme/app_theme.dart';
import '../theme/app_theme_presets.dart';

class ThemeScreen extends StatelessWidget {
  const ThemeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BudgetController>();

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(title: const Text('App theme')),
      body: Obx(() {
        final active = controller.activeTheme.value;
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Pick a color theme — it applies across the whole app immediately.',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 16),
            ...kThemePresets.map((option) {
              final isActive = option.id == active.id;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _ThemeCard(
                  option: option,
                  isActive: isActive,
                  onTap: () => controller.setTheme(option),
                ),
              );
            }),
          ],
        );
      }),
    );
  }
}

class _ThemeCard extends StatelessWidget {
  const _ThemeCard({required this.option, required this.isActive, required this.onTap});

  final AppThemeOption option;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: option.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive ? option.invest : AppColors.border,
            width: isActive ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            _Swatches(option: option),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    option.name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: option.ink,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    option.isDark ? 'Dark' : 'Light',
                    style: TextStyle(fontSize: 12, color: option.inkSoft),
                  ),
                ],
              ),
            ),
            AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: isActive ? 1 : 0,
              child: Icon(Icons.check_circle, color: option.invest, size: 22),
            ),
          ],
        ),
      ),
    );
  }
}

class _Swatches extends StatelessWidget {
  const _Swatches({required this.option});

  final AppThemeOption option;

  @override
  Widget build(BuildContext context) {
    final colors = [option.use, option.invest, option.lifestyle, option.emergency, option.sadaqah];
    const size = 56.0;
    const dotSize = 20.0;
    const radius = 16.0;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: List.generate(colors.length, (i) {
          final angle = (i / colors.length) * 2 * math.pi;
          return Positioned(
            left: size / 2 + radius * math.cos(angle) - dotSize / 2,
            top: size / 2 + radius * math.sin(angle) - dotSize / 2,
            child: Container(
              width: dotSize,
              height: dotSize,
              decoration: BoxDecoration(
                color: colors[i],
                shape: BoxShape.circle,
                border: Border.all(color: option.card, width: 2),
              ),
            ),
          );
        }),
      ),
    );
  }
}
