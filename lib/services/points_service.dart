import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Riverpod provider — auto-refreshed by calling ref.invalidate(pointsProvider)
final pointsProvider = FutureProvider<int>((ref) => PointsService.getPoints());

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
    await prefs.remove(_key);
  }
}
