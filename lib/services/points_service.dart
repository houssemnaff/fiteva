import 'package:shared_preferences/shared_preferences.dart';

class PointsService {
  static const String _key = 'user_points';
  static const int pointsPerVideo = 10;

  static Future<int> getPoints() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_key) ?? 0;
  }

  static Future<int> addPoints(int amount) async {
    final prefs = await SharedPreferences.getInstance();

    final current = prefs.getInt(_key) ?? 0;
    final updated = current + amount;

    await prefs.setInt(_key, updated);

    return updated;
  }

  static Future<void> setPoints(int points) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_key, points);
  }

  static Future<void> resetPoints() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_key, 0);
  }
}