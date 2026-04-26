import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static late SharedPreferences _prefs;

  /// MUST CALL AT APP START
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // --------------------
  // BOOL
  // --------------------
  static Future<void> setBool(String key, bool value) async {
    await _prefs.setBool(key, value);
  }

  static bool getBool(String key) {
    return _prefs.getBool(key) ?? false;
  }

  // --------------------
  // JSON GENERIC
  // --------------------
  static Future<void> saveJson(String key, Map<String, dynamic> data) async {
    await _prefs.setString(key, jsonEncode(data));
  }

  static Map<String, dynamic>? getJson(String key) {
    final str = _prefs.getString(key);
    if (str == null) return null;
    return jsonDecode(str) as Map<String, dynamic>;
  }

  // --------------------
  // ONBOARDING
  // --------------------
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
    if (str == null) return {};
    return jsonDecode(str) as Map<String, dynamic>;
  }

  // --------------------
  // POINTS
  // --------------------
  static Future<void> setTotalPoints(int points) async {
    await _prefs.setInt('total_points', points);
  }

  static int getTotalPoints() {
    return _prefs.getInt('total_points') ?? 0;
  }

  // --------------------
  // CHAT
  // --------------------
  static Future<void> saveChatHistory(List<dynamic> history) async {
    await _prefs.setString('chat_history', jsonEncode(history));
  }

  static List<dynamic> getChatHistory() {
    final str = _prefs.getString('chat_history');
    if (str == null) return [];
    return jsonDecode(str) as List<dynamic>;
  }

  // --------------------
  // CLEAR ALL
  // --------------------
  static Future<void> clearAll() async {
    await _prefs.clear();
  }
}