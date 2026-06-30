import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/storage_service.dart';
import '../services/supabase_config.dart';
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
    // Sauvegarde locale (synchrone, fonctionne hors-ligne)
    await StorageService.setString(_key, locale.languageCode);
    // Sync Supabase
    _syncToSupabase(locale.languageCode);
  }

  bool get isFrench => state.languageCode == 'fr';

  void _syncToSupabase(String code) {
    final uid = SupabaseConfig.userId;
    if (uid == null) return;
    SupabaseConfig.table('user_profiles').upsert({
      'id':         uid,
      'language':   code,
      'updated_at': DateTime.now().toIso8601String(),
    }).catchError((_) {});
  }
}
