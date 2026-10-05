import 'package:flutter/material.dart';

/// A full, self-contained color palette the whole app can switch to at
/// once — the semantic roles match what AppColors exposes, so swapping the
/// active preset re-colors every screen without touching individual widgets.
class AppThemeOption {
  final String id;
  final String name;
  final bool isDark;

  final Color bg;
  final Color card;
  final Color border;
  final Color ink;
  final Color inkSoft;
  final Color muted;

  final Color use;
  final Color invest;
  final Color lifestyle;
  final Color emergency;
  final Color sadaqah;

  const AppThemeOption({
    required this.id,
    required this.name,
    required this.isDark,
    required this.bg,
    required this.card,
    required this.border,
    required this.ink,
    required this.inkSoft,
    required this.muted,
    required this.use,
    required this.invest,
    required this.lifestyle,
    required this.emergency,
    required this.sadaqah,
  });
}

const kThemeBarabri = AppThemeOption(
  id: 'barabri',
  name: 'Barabri',
  isDark: false,
  bg: Color(0xFFF6F5F1),
  card: Colors.white,
  border: Color(0xFFE7E4DC),
  ink: Color(0xFF2A2A26),
  inkSoft: Color(0xFF6B6A63),
  muted: Color(0xFF9A968C),
  use: Color(0xFFC1666B),
  invest: Color(0xFF2E7D6B),
  lifestyle: Color(0xFFB07D3D),
  emergency: Color(0xFF3A3A86),
  sadaqah: Color(0xFF5C8A62),
);

const kThemeMidnight = AppThemeOption(
  id: 'midnight',
  name: 'Midnight',
  isDark: true,
  bg: Color(0xFF17181C),
  card: Color(0xFF212227),
  border: Color(0xFF34353B),
  ink: Color(0xFFF1F0EC),
  inkSoft: Color(0xFFA8A7A2),
  muted: Color(0xFF757470),
  use: Color(0xFFE08A8F),
  invest: Color(0xFF4FAF96),
  lifestyle: Color(0xFFD6A15B),
  emergency: Color(0xFF8786D6),
  sadaqah: Color(0xFF7FB885),
);

const kThemeOcean = AppThemeOption(
  id: 'ocean',
  name: 'Ocean',
  isDark: false,
  bg: Color(0xFFF2F6F7),
  card: Colors.white,
  border: Color(0xFFDCE6E8),
  ink: Color(0xFF1E2E33),
  inkSoft: Color(0xFF5B7177),
  muted: Color(0xFF8FA3A8),
  use: Color(0xFFD97A6B),
  invest: Color(0xFF1F7A8C),
  lifestyle: Color(0xFF4C9BA6),
  emergency: Color(0xFF2E4F6E),
  sadaqah: Color(0xFF3F9B7B),
);

const kThemeSunset = AppThemeOption(
  id: 'sunset',
  name: 'Sunset',
  isDark: false,
  bg: Color(0xFFFBF3EC),
  card: Colors.white,
  border: Color(0xFFEFDFD1),
  ink: Color(0xFF3A2A22),
  inkSoft: Color(0xFF7D6A5E),
  muted: Color(0xFFAC9A8C),
  use: Color(0xFFD9674A),
  invest: Color(0xFFB6542F),
  lifestyle: Color(0xFFE0A33D),
  emergency: Color(0xFF7A4E6B),
  sadaqah: Color(0xFF7A9456),
);

const kThemeForest = AppThemeOption(
  id: 'forest',
  name: 'Forest',
  isDark: false,
  bg: Color(0xFFF3F6F0),
  card: Colors.white,
  border: Color(0xFFE0E7D8),
  ink: Color(0xFF263024),
  inkSoft: Color(0xFF61715C),
  muted: Color(0xFF93A08C),
  use: Color(0xFFBE6E55),
  invest: Color(0xFF3E6B4F),
  lifestyle: Color(0xFF8C9A3F),
  emergency: Color(0xFF45625F),
  sadaqah: Color(0xFF5A8A3F),
);

const List<AppThemeOption> kThemePresets = [
  kThemeBarabri,
  kThemeMidnight,
  kThemeOcean,
  kThemeSunset,
  kThemeForest,
];

AppThemeOption themeById(String id) {
  return kThemePresets.firstWhere((t) => t.id == id, orElse: () => kThemeBarabri);
}
