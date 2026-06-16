import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class XpService {
  static const _kXp          = 'xp_total';
  static const _kStreak       = 'xp_streak';
  static const _kLastDate     = 'xp_last_date';
  static const _kBadges       = 'xp_badges';
  static const _kChallengeP   = 'xp_challenge_progress';
  static const _kChallengeC   = 'xp_challenge_completed';
  static const _kLoginRewarded = 'xp_login_today';

  static Future<Map<String, dynamic>> load() async {
    final p = await SharedPreferences.getInstance();
    return {
      'totalXp':            p.getInt(_kXp) ?? 0,
      'streak':             p.getInt(_kStreak) ?? 0,
      'lastActiveDate':     p.getString(_kLastDate),
      'badges':             p.getStringList(_kBadges) ?? [],
      'challengeProgress':  _decodeIntMap(p.getString(_kChallengeP)),
      'completedChallenges': p.getStringList(_kChallengeC) ?? [],
      'loginRewardedToday': _isToday(p.getString(_kLoginRewarded)),
    };
  }

  static Future<void> save({
    required int totalXp,
    required int streak,
    required String? lastActiveDate,
    required List<String> badges,
    required Map<String, int> challengeProgress,
    required List<String> completedChallenges,
  }) async {
    final p = await SharedPreferences.getInstance();
    await p.setInt(_kXp, totalXp);
    await p.setInt(_kStreak, streak);
    if (lastActiveDate != null) await p.setString(_kLastDate, lastActiveDate);
    await p.setStringList(_kBadges, badges);
    await p.setString(_kChallengeP, json.encode(challengeProgress));
    await p.setStringList(_kChallengeC, completedChallenges);
  }

  static Future<void> markLoginRewarded() async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_kLoginRewarded, _todayString());
  }

  static String _todayString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  static bool _isToday(String? dateStr) {
    if (dateStr == null) return false;
    return dateStr == _todayString();
  }

  static Map<String, int> _decodeIntMap(String? raw) {
    if (raw == null) return {};
    try {
      final decoded = json.decode(raw) as Map<String, dynamic>;
      return decoded.map((k, v) => MapEntry(k, v as int));
    } catch (_) {
      return {};
    }
  }
}
