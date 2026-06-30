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
        if (data['height']         != null) 'height_cm':        data['height'],
        if (data['weight']         != null) 'weight_kg':        data['weight'],
        if (data['age']            != null) 'age':              data['age'],
        if (data['isFemale']       != null) 'is_female':        data['isFemale'],
        if (data['fitnessLevel']   != null) 'fitness_level':    data['fitnessLevel'],
        if (data['activityLevel']  != null) 'activity_level':   data['activityLevel'],
        if (data['nutritionGoal']  != null) 'nutrition_goal':   data['nutritionGoal'],
        if (data['trainingLocation'] != null) 'training_location': data['trainingLocation'],
        if (data['frequencyDays']  != null) 'frequency_days':   data['frequencyDays'],
        if (data['goals']          != null) 'goals':            data['goals'],
        if (data['equipment']      != null) 'equipment':        data['equipment'],
        'updated_at': DateTime.now().toIso8601String(),
      };
      await SupabaseConfig.table('user_biometrics').upsert(bio);

      // Statut santé (cycle / grossesse / post-partum)
      if (data['healthStatus'] != null) {
        await SupabaseConfig.table('user_cycle_settings').upsert({
          'user_id':          uid,
          'health_status':    data['healthStatus'],
          'cycle_duration':   data['cycleDuration'] ?? 28,
          'last_period_date': data['lastPeriodDate'],
          'updated_at':       DateTime.now().toIso8601String(),
        });
      }
    } catch (_) {}
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

  // ── Reset local ───────────────────────────────────────────────────────────

  static Future<void> clearAll() => _prefs.clear();
}
