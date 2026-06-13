import 'package:shared_preferences/shared_preferences.dart';

class PointsService {
  static const String pointsKey    = 'user_points';
  static const String _key         = pointsKey;
  static const int    pointsPerVideo = 10;

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

  static Future<int> spendPoints(int amount) async {
    final prefs   = await SharedPreferences.getInstance();
    final current = prefs.getInt(_key) ?? 0;
    final updated = (current - amount).clamp(0, 999999);
    await prefs.setInt(_key, updated);
    return updated;
  }

  static Future<void> resetPoints() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_key, 0);
  }
}