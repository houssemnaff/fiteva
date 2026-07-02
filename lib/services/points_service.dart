import 'supabase_config.dart';

/// Gestion des étoiles (points boutique) — stocké dans user_points + points_history
class PointsService {
  static const int pointsPerVideo = 10;

  // ── Lecture ────────────────────────────────────────────────────────────────

  static Future<int> getPoints() async {
    final uid = SupabaseConfig.userId;
    if (uid == null) return 0;

    try {
      final row = await SupabaseConfig.table('user_points')
          .select('etoiles')
          .eq('user_id', uid)
          .maybeSingle();
      return row?['etoiles'] as int? ?? 0;
    } catch (_) {
      return 0;
    }
  }

  // ── Ajout ─────────────────────────────────────────────────────────────────

  static Future<int> addPoints(int amount, {String reason = 'reward'}) async {
    final uid = SupabaseConfig.userId;
    if (uid == null) return 0;

    try {
      final current = await getPoints();
      final updated = current + amount;

      await SupabaseConfig.table('user_points').upsert({
        'user_id': uid,
        'etoiles': updated,
      }, onConflict: 'user_id');

      await SupabaseConfig.table('points_history').insert({
        'user_id':   uid,
        'amount':    amount,
        'reason':    reason,
        'earned_at': DateTime.now().toIso8601String(),
      });

      return updated;
    } catch (_) {
      return 0;
    }
  }

  // ── Dépense ───────────────────────────────────────────────────────────────

  static Future<int> spendPoints(int amount, {String reason = 'shop_redemption'}) async {
    final uid = SupabaseConfig.userId;
    if (uid == null) return 0;

    try {
      final current = await getPoints();
      final updated = (current - amount).clamp(0, 999999);

      await SupabaseConfig.table('user_points').upsert({
        'user_id': uid,
        'etoiles': updated,
      }, onConflict: 'user_id');

      await SupabaseConfig.table('points_history').insert({
        'user_id':   uid,
        'amount':    -amount,
        'reason':    reason,
        'earned_at': DateTime.now().toIso8601String(),
      });

      return updated;
    } catch (_) {
      return 0;
    }
  }

  // ── Historique ────────────────────────────────────────────────────────────

  static Future<List<Map<String, dynamic>>> getHistory({int limit = 20}) async {
    final uid = SupabaseConfig.userId;
    if (uid == null) return [];

    try {
      final rows = await SupabaseConfig.table('points_history')
          .select()
          .eq('user_id', uid)
          .order('earned_at', ascending: false)
          .limit(limit);
      return List<Map<String, dynamic>>.from(rows as List);
    } catch (_) {
      return [];
    }
  }

  static Future<void> resetPoints() async {
    final uid = SupabaseConfig.userId;
    if (uid == null) return;
    try {
      await SupabaseConfig.table('user_points').upsert({
        'user_id': uid,
        'etoiles': 0,
      }, onConflict: 'user_id');
    } catch (_) {}
  }
}
