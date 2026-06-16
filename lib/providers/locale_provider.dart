import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/storage_service.dart';
import '../l10n/lang.dart';

final localeProvider = NotifierProvider<LocaleNotifier, Locale>(
  LocaleNotifier.new,
);

class LocaleNotifier extends Notifier<Locale> {
  static const _key = 'app_locale';

  @override
  Locale build() {
    final stored = StorageService.getString(_key);
    final code = stored == 'en' ? 'en' : 'fr';
    Lang.code = code;
    return Locale(code);
  }

  Future<void> setLocale(Locale locale) async {
    Lang.code = locale.languageCode;
    state = locale;
    await StorageService.setString(_key, locale.languageCode);
  }

  bool get isFrench => state.languageCode == 'fr';
}
