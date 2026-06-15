import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/storage_service.dart';

final localeProvider = NotifierProvider<LocaleNotifier, Locale>(
  LocaleNotifier.new,
);

class LocaleNotifier extends Notifier<Locale> {
  static const _key = 'app_locale';

  @override
  Locale build() {
    final stored = StorageService.getString(_key);
    return stored == 'en' ? const Locale('en') : const Locale('fr');
  }

  Future<void> setLocale(Locale locale) async {
    state = locale;
    await StorageService.setString(_key, locale.languageCode);
  }

  bool get isFrench => state.languageCode == 'fr';
}
