import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // --- Generic JSON Handlers ---
  static Future<void> saveJson(String key, Map<String, dynamic> data) async {
    await _prefs.setString(key, jsonEncode(data));
  }

  static Map<String, dynamic>? getJson(String key) {
    final str = _prefs.getString(key);
    if (str != null) {
      return jsonDecode(str) as Map<String, dynamic>;
    }
    return null;
  }

  // --- Specific Data Handlers ---

  static Future<void> setOnboardingCompleted(bool completed) async {
    await _prefs.setBool('onboarding_completed', completed);
  }

  static bool isOnboardingCompleted() {
    return _prefs.getBool('onboarding_completed') ?? false;
  }

  static Future<void> saveOnboardingData(Map<String, dynamic> data) async {
    await _prefs.setString('onboarding_data', jsonEncode(data));
  }

  static Map<String, dynamic> getOnboardingData() {
    final str = _prefs.getString('onboarding_data');
    if (str != null) {
      return jsonDecode(str) as Map<String, dynamic>;
    }
    return {};
  }

  static Future<void> setTotalPoints(int points) async {
    await _prefs.setInt('total_points', points);
  }

  static int getTotalPoints() {
    return _prefs.getInt('total_points') ?? 0;
  }

  // Used for chat list (List<Map<String, dynamic>>)
  static Future<void> saveChatHistory(List<dynamic> history) async {
    await _prefs.setString('chat_history', jsonEncode(history));
  }

  static List<dynamic> getChatHistory() {
    final str = _prefs.getString('chat_history');
    if (str != null) {
      return jsonDecode(str) as List<dynamic>;
    }
    return [];
  }

  static Future<void> clearAll() async {
    await _prefs.clear();
  }
}
