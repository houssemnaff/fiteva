import 'supabase_config.dart';

/// Gestion XP / streak / badges — stocké dans user_xp + xp_history (Supabase)
class XpService {
  static String _today() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  static bool _isToday(String? dateStr) => dateStr != null && dateStr == _today();

  // ── Lecture ────────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> load() async {
    final uid = SupabaseConfig.userId;
    if (uid == null) return _empty();

    try {
      final row = await SupabaseConfig.table('user_xp')
          .select()
          .eq('user_id', uid)
          .maybeSingle();

      if (row == null) return _empty();

      final progressRows = await SupabaseConfig.table('user_challenge_progress')
          .select('challenge_key, progress')
          .eq('user_id', uid);

      final Map<String, int> challengeProgress = {
        for (final r in progressRows as List)
          r['challenge_key'] as String: r['progress'] as int,
      };

      final completedRows = await SupabaseConfig.table('user_challenge_progress')
          .select('challenge_key')
          .eq('user_id', uid)
          .eq('completed', true);

      final completedChallenges = (completedRows as List)
          .map((r) => r['challenge_key'] as String)
          .toList();

      return {
        'totalXp':             row['total_xp'] as int? ?? 0,
        'streak':              row['streak'] as int? ?? 0,
        'lastActiveDate':      row['last_active_date'] as String?,
        'badges':              List<String>.from(row['badges'] as List? ?? []),
        'challengeProgress':   challengeProgress,
        'completedChallenges': completedChallenges,
        'loginRewardedToday':  _isToday(row['last_active_date'] as String?),
      };
    } catch (_) {
      return _empty();
    }
  }

  // ── Sauvegarde ─────────────────────────────────────────────────────────────

  static Future<void> save({
    required int totalXp,
    required int streak,
    required String? lastActiveDate,
    required List<String> badges,
    required Map<String, int> challengeProgress,
    required List<String> completedChallenges,
  }) async {
    final uid = SupabaseConfig.userId;
    if (uid == null) return;

    try {
      await SupabaseConfig.table('user_xp').upsert({
        'user_id':          uid,
        'total_xp':         totalXp,
        'streak':           streak,
        'last_active_date': lastActiveDate,
        'badges':           badges,
      }, onConflict: 'user_id');

      // Synchronise la progression par challenge
      for (final entry in challengeProgress.entries) {
        await SupabaseConfig.table('user_challenge_progress').upsert({
          'user_id':       uid,
          'challenge_key': entry.key,
          'progress':      entry.value,
          'completed':     completedChallenges.contains(entry.key),
          'completed_at':  completedChallenges.contains(entry.key)
              ? DateTime.now().toIso8601String()
              : null,
        });
      }
    } catch (_) {}
  }

  // ── Ajouter des XP avec historique ────────────────────────────────────────

  static Future<void> addXpHistory(int amount, String reason) async {
    final uid = SupabaseConfig.userId;
    if (uid == null) return;
    try {
      await SupabaseConfig.table('xp_history').insert({
        'user_id':   uid,
        'amount':    amount,
        'reason':    reason,
        'earned_at': DateTime.now().toIso8601String(),
      });
    } catch (_) {}
  }

  static Future<void> markLoginRewarded() async {
    final uid = SupabaseConfig.userId;
    if (uid == null) return;
    try {
      await SupabaseConfig.table('user_xp').upsert({
        'user_id':              uid,
        'login_rewarded_today': true,
        'last_active_date':     _today(),
      }, onConflict: 'user_id');
    } catch (_) {}
  }

  static Map<String, dynamic> _empty() => {
    'totalXp':             0,
    'streak':              0,
    'lastActiveDate':      null,
    'badges':              <String>[],
    'challengeProgress':   <String, int>{},
    'completedChallenges': <String>[],
    'loginRewardedToday':  false,
  };
}
