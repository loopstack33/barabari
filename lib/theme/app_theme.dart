import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Central color palette — matches the app icon/logo mark.
class AppColors {
  static const bg = Color(0xFFF6F5F1);
  static const card = Colors.white;
  static const border = Color(0xFFE7E4DC);
  static const ink = Color(0xFF2A2A26);
  static const inkSoft = Color(0xFF6B6A63);
  static const muted = Color(0xFF9A968C);

  static const use = Color(0xFFC1666B);
  static const invest = Color(0xFF2E7D6B);
  static const lifestyle = Color(0xFFB07D3D);
  static const emergency = Color(0xFF3A3A86);
  static const sadaqah = Color(0xFF5C8A62);
}

ThemeData buildAppTheme() {
  final base = ThemeData(
    useMaterial3: true,
    colorSchemeSeed: AppColors.invest,
    scaffoldBackgroundColor: AppColors.bg,
  );

  final textTheme = GoogleFonts.plusJakartaSansTextTheme(base.textTheme).apply(
    bodyColor: AppColors.ink,
    displayColor: AppColors.ink,
  );

  return base.copyWith(
    textTheme: textTheme,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.bg,
      elevation: 0,
      foregroundColor: AppColors.ink,
      titleTextStyle: GoogleFonts.plusJakartaSans(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppColors.ink,
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.card,
      labelTextStyle: WidgetStateProperty.resolveWith(
            (states) => GoogleFonts.plusJakartaSans(
          fontSize: 11,
          fontWeight: states.contains(WidgetState.selected) ? FontWeight.w700 : FontWeight.w500,
          color: states.contains(WidgetState.selected) ? AppColors.invest : AppColors.muted,
        ),
      ),
    ),
    switchTheme: SwitchThemeData(
      trackColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.selected) ? AppColors.invest : AppColors.border,
      ),
    ),
  );
}