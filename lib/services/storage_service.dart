import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'supabase_config.dart';

/// StorageService — données locales uniquement (onboarding, chat, cache)
/// Les données utilisateur persistantes (profil, XP, points…) sont dans Supabase.
class StorageService {
  static late SharedPreferences _prefs;

  /// MUST CALL AT APP START (avant runApp)
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ── Booléens ─────────────────────────────────────────────────────────────

  static Future<void> setBool(String key, bool value) async =>
      _prefs.setBool(key, value);

  static bool getBool(String key) => _prefs.getBool(key) ?? false;

  // ── JSON générique ────────────────────────────────────────────────────────

  static Future<void> saveJson(String key, Map<String, dynamic> data) async =>
      _prefs.setString(key, jsonEncode(data));

  static Map<String, dynamic>? getJson(String key) {
    final str = _prefs.getString(key);
    return str == null ? null : jsonDecode(str) as Map<String, dynamic>;
  }

  // ── Onboarding (local uniquement) ────────────────────────────────────────

  static Future<void> setOnboardingCompleted(bool completed) =>
      _prefs.setBool('onboarding_completed', completed);

  static bool isOnboardingCompleted() =>
      _prefs.getBool('onboarding_completed') ?? false;

  static Future<void> saveOnboardingData(Map<String, dynamic> data) =>
      _prefs.setString('onboarding_data', jsonEncode(data));

  static Map<String, dynamic> getOnboardingData() {
    final str = _prefs.getString('onboarding_data');
    return str == null ? {} : jsonDecode(str) as Map<String, dynamic>;
  }

  static Future<void> clearOnboardingData() =>
      _prefs.remove('onboarding_data');

  /// Synchronise les données d'onboarding vers Supabase après inscription.
  /// Appeler une fois après que l'utilisateur est authentifié.
  static Future<void> syncOnboardingToSupabase() async {
    final uid  = SupabaseConfig.userId;
    final data = getOnboardingData();
    if (uid == null || data.isEmpty) return;

    try {
      // Profil principal
      await SupabaseConfig.table('user_profiles').upsert({
        'id':              uid,
        'username':        data['username'] ?? '',
        'language':        data['language'] ?? 'fr',
        'onboarding_done': true,
        'updated_at':      DateTime.now().toIso8601String(),
      });

      // Biométrie & objectifs
      final bio = <String, dynamic>{
        'user_id': uid,
        if (data['height_cm']         != null) 'height_cm':        data['height_cm'],
        if (data['weight_kg']         != null) 'weight_kg':        data['weight_kg'],
        if (data['age']               != null) 'age':              data['age'],
        if (data['fitness_level']     != null) 'fitness_level':    data['fitness_level'],
        if (data['training_location'] != null) 'training_location': data['training_location'],
        if (data['frequency']         != null) 'frequency_days':   _freqToDays(data['frequency']),
        if (data['goals']             != null) 'goals':            data['goals'],
        if (data['equipment']         != null) 'equipment':        data['equipment'],
        'updated_at': DateTime.now().toIso8601String(),
      };
      await SupabaseConfig.table('user_biometrics').upsert(bio, onConflict: 'user_id');

      // Statut santé (cycle / grossesse / post-partum)
      if (data['health_status'] != null) {
        await SupabaseConfig.table('user_cycle_settings').upsert({
          'user_id':          uid,
          'health_status':    data['health_status'],
          'cycle_duration':   _cycleDaysFrom(data['cycle_duration']),
          'last_period_date': data['last_period'],
          'updated_at':       DateTime.now().toIso8601String(),
        }, onConflict: 'user_id');
      }
    } catch (_) {}
  }

  static int _freqToDays(dynamic freq) {
    if (freq == null) return 3;
    final n = int.tryParse(freq.toString().replaceAll(RegExp(r'[^0-9]'), ''));
    return n ?? 3;
  }

  static int _cycleDaysFrom(dynamic duration) {
    if (duration == null) return 28;
    final n = int.tryParse(duration.toString().replaceAll(RegExp(r'[^0-9]'), ''));
    return n ?? 28;
  }

  // ── Points (délégués à Supabase, gardés pour compatibilité) ──────────────

  static Future<void> setTotalPoints(int points) =>
      _prefs.setInt('total_points', points);

  static int getTotalPoints() => _prefs.getInt('total_points') ?? 0;

  // ── Historique de chat (local) ────────────────────────────────────────────

  static Future<void> saveChatHistory(List<dynamic> history) =>
      _prefs.setString('chat_history', jsonEncode(history));

  static List<dynamic> getChatHistory() {
    final str = _prefs.getString('chat_history');
    return str == null ? [] : jsonDecode(str) as List<dynamic>;
  }

  // ── String générique ──────────────────────────────────────────────────────

  static Future<void> setString(String key, String value) =>
      _prefs.setString(key, value);

  static String? getString(String key) => _prefs.getString(key);

  // ── Chatbot visibility ────────────────────────────────────────────────────

  static bool getChatbotVisible() => _prefs.getBool('chatbot_visible') ?? true;

  static Future<void> setChatbotVisible(bool v) =>
      _prefs.setBool('chatbot_visible', v);

  // ── Reset local ───────────────────────────────────────────────────────────

  static Future<void> clearAll() => _prefs.clear();
}
