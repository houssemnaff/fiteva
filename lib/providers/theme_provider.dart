import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/storage_service.dart';
import '../services/supabase_config.dart';

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
