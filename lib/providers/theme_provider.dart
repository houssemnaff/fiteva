import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/storage_service.dart';

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
  }
}