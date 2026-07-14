import 'package:fiteva/models/points_model.dart';

import 'supabase_config.dart';

/// Gestion des diamants (monnaie boutique) — stocké dans user_diamonds +
/// diamonds_history (Supabase).
///
/// Les diamants ne sont JAMAIS crédités par une action quotidienne : seule la
/// montée de niveau (points) en donne, via le trigger SQL
/// fn_award_level_up_diamonds (serveur) doublé du fallback idempotent
/// [creditLevelUpBonus] (client). Ils se dépensent uniquement en boutique.
class DiamondsService {
  // ── Lecture ────────────────────────────────────────────────────────────────

  static Future<int> getDiamonds() async {
    final uid = SupabaseConfig.userId;
    if (uid == null) return 0;

    try {
      final row = await SupabaseConfig.table('user_diamonds')
          .select('diamonds')
          .eq('user_id', uid)
          .maybeSingle();
      return row?['diamonds'] as int? ?? 0;
    } catch (_) {
      return 0;
    }
  }

  // ── Ajout ─────────────────────────────────────────────────────────────────

  static Future<int> addDiamonds(int amount, {String reason = 'reward'}) async {
    final uid = SupabaseConfig.userId;
    if (uid == null) return 0;

    try {
      final current = await getDiamonds();
      final updated = current + amount;

      await SupabaseConfig.table('user_diamonds').upsert({
        'user_id':    uid,
        'diamonds':   updated,
        'updated_at': DateTime.now().toIso8601String(),
      }, onConflict: 'user_id');

      await SupabaseConfig.table('diamonds_history').insert({
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

  /// Crédite le bonus de diamants du passage au niveau [level].
  ///
  /// Idempotent : la reason `level_up_bonus_L<n>` est unique par utilisatrice
  /// et par niveau — jamais créditée deux fois. Le trigger SQL
  /// fn_award_level_up_diamonds fait normalement ce travail côté serveur dès
  /// l'upsert de user_xp ; ce fallback ne crédite que si la ligne d'historique
  /// n'existe pas encore (ex: trigger pas déployé). Retourne le montant
  /// effectivement crédité par CE client (0 si déjà crédité côté serveur).
  static Future<int> creditLevelUpBonus(int level) async {
    final bonus = PointsModel.diamondsForLevel(level);
    if (bonus <= 0) return 0;
    if (await _hasReason('level_up_bonus_L$level')) return 0;
    await addDiamonds(bonus, reason: 'level_up_bonus_L$level');
    return bonus;
  }

  /// La reason a-t-elle déjà été créditée (sur toute la durée de vie du
  /// compte, pas seulement aujourd'hui) — un niveau ne se repasse jamais.
  static Future<bool> _hasReason(String reason) async {
    final uid = SupabaseConfig.userId;
    if (uid == null) return false;
    try {
      final rows = await SupabaseConfig.table('diamonds_history')
          .select('id')
          .eq('user_id', uid)
          .eq('reason', reason)
          .limit(1);
      return (rows as List).isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  // ── Dépense ───────────────────────────────────────────────────────────────

  static Future<int> spendDiamonds(int amount, {String reason = 'shop_redemption'}) async {
    final uid = SupabaseConfig.userId;
    if (uid == null) return 0;

    try {
      final current = await getDiamonds();
      final updated = (current - amount).clamp(0, 999999);

      await SupabaseConfig.table('user_diamonds').upsert({
        'user_id':  uid,
        'diamonds': updated,
      }, onConflict: 'user_id');

      await SupabaseConfig.table('diamonds_history').insert({
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
      final rows = await SupabaseConfig.table('diamonds_history')
          .select()
          .eq('user_id', uid)
          .order('earned_at', ascending: false)
          .limit(limit);
      return List<Map<String, dynamic>>.from(rows as List);
    } catch (_) {
      return [];
    }
  }

  static Future<void> resetDiamonds() async {
    final uid = SupabaseConfig.userId;
    if (uid == null) return;
    try {
      await SupabaseConfig.table('user_diamonds').upsert({
        'user_id':  uid,
        'diamonds': 0,
      }, onConflict: 'user_id');
    } catch (_) {}
  }
}
