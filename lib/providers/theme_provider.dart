import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/storage_service.dart';
import '../services/supabase_config.dart';
import '../theme/color_palettes.dart';

// ── Theme mode (dark/light) ──────────────────────────────────────────────────

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);

class ThemeModeNotifier extends Notifier<ThemeMode> {
  static const _storageKey = 'theme_mode_is_dark';

  @override
  ThemeMode build() {
    final isDark = StorageService.getBool(_storageKey);
    return isDark ? ThemeMode.dark : ThemeMode.light;
  }

  Future<void> toggleThemeMode() async {
    final nextMode = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    state = nextMode;
    await StorageService.setBool(_storageKey, nextMode == ThemeMode.dark);
    _syncToSupabase(nextMode == ThemeMode.dark ? 'dark' : 'light');
  }

  void _syncToSupabase(String themeMode) {
    final uid = SupabaseConfig.userId;
    if (uid == null) return;
    SupabaseConfig.table('user_profiles').upsert({
      'id':         uid,
      'theme_mode': themeMode,
      'updated_at': DateTime.now().toIso8601String(),
    }).catchError((_) {});
  }
}

// ── Color palette ────────────────────────────────────────────────────────────

final colorPaletteProvider = NotifierProvider<ColorPaletteNotifier, AppColorPalette>(
  ColorPaletteNotifier.new,
);

class ColorPaletteNotifier extends Notifier<AppColorPalette> {
  static const _storageKey = 'color_palette_id';

  @override
  AppColorPalette build() {
    final id = StorageService.getString(_storageKey);
    return paletteById(id ?? 'forest');
  }

  Future<void> setPalette(AppColorPalette palette) async {
    state = palette;
    await StorageService.setString(_storageKey, palette.id);
    _syncToSupabase(palette.id);
  }

  void _syncToSupabase(String paletteId) {
    final uid = SupabaseConfig.userId;
    if (uid == null) return;
    SupabaseConfig.table('user_profiles').upsert({
      'id':           uid,
      'color_palette': paletteId,
      'updated_at':   DateTime.now().toIso8601String(),
    }).catchError((_) {});
  }
}
