import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_theme_presets.dart';

/// Runtime-switchable color accessor. Every screen reads colors through
/// these getters (e.g. AppColors.ink), so swapping the active preset with
/// [AppColors.setTheme] re-colors the whole app the next time it rebuilds —
/// no need to thread the theme through every widget individually.
///
/// IMPORTANT: because these are getters, not compile-time constants, any
/// TextStyle/BoxDecoration/etc. that reads an AppColors.* value cannot be
/// `const` — it must be a plain (non-const) literal so it re-evaluates
/// whenever the app rebuilds after a theme change.
class AppColors {
  AppColors._();

  static AppThemeOption _current = kThemeBarabri;

  static void setTheme(AppThemeOption theme) => _current = theme;
  static AppThemeOption get current => _current;

  static Color get bg => _current.bg;
  static Color get card => _current.card;
  static Color get border => _current.border;
  static Color get ink => _current.ink;
  static Color get inkSoft => _current.inkSoft;
  static Color get muted => _current.muted;

  static Color get use => _current.use;
  static Color get invest => _current.invest;
  static Color get lifestyle => _current.lifestyle;
  static Color get emergency => _current.emergency;
  static Color get sadaqah => _current.sadaqah;
}

ThemeData buildAppTheme(AppThemeOption option) {
  AppColors.setTheme(option);

  final base = ThemeData(
    useMaterial3: true,
    brightness: option.isDark ? Brightness.dark : Brightness.light,
    colorSchemeSeed: option.invest,
    scaffoldBackgroundColor: option.bg,
  );

  final textTheme = GoogleFonts.plusJakartaSansTextTheme(base.textTheme).apply(
    bodyColor: option.ink,
    displayColor: option.ink,
  );

  return base.copyWith(
    textTheme: textTheme,
    appBarTheme: AppBarTheme(
      backgroundColor: option.bg,
      elevation: 0,
      foregroundColor: option.ink,
      titleTextStyle: GoogleFonts.plusJakartaSans(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: option.ink,
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: option.card,
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => GoogleFonts.plusJakartaSans(
          fontSize: 11,
          fontWeight: states.contains(WidgetState.selected) ? FontWeight.w700 : FontWeight.w500,
          color: states.contains(WidgetState.selected) ? option.invest : option.muted,
        ),
      ),
    ),
    switchTheme: SwitchThemeData(
      trackColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected) ? option.invest : option.border,
      ),
    ),
    cardColor: option.card,
    dialogTheme: DialogThemeData(backgroundColor: option.card),
    bottomSheetTheme: BottomSheetThemeData(backgroundColor: option.card),
  );
}
