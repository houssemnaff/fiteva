import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'auth_service.dart';
import 'supabase_config.dart';

/// Export et suppression des données personnelles — conformité RGPD.
///
/// L'app stockait des données de santé sensibles (cycle, grossesse,
/// symptômes) sans qu'il n'existe nulle part un moyen pour l'utilisatrice
/// d'exporter ou de supprimer définitivement ses données.
class PrivacyService {
  PrivacyService._();

  // Toutes les tables connues qui contiennent des données propres à un
  // utilisateur, avec la colonne qui l'identifie (généralement 'user_id',
  // sauf user_profiles qui utilise 'id').
  static const _userTables = <String, String>{
    'user_profiles':          'id',
    'user_biometrics':        'user_id',
    'user_cycle_settings':    'user_id',
    'user_nutrition_targets': 'user_id',
    'user_meal_entries':      'user_id',
    'user_water_logs':        'user_id',
    'cycle_daily_logs':       'user_id',
    'pregnancy_tasks_done':   'user_id',
    'pregnancy_symptoms':     'user_id',
    'user_xp':                'user_id',
    'points_progress_history': 'user_id',
    'user_diamonds':          'user_id',
    'diamonds_history':       'user_id',
    'shop_redemptions':       'user_id',
    'shop_wishlist':          'user_id',
    'partner_requests_shop':  'user_id',
    'user_fcm_tokens':        'user_id',
  };

  /// Rassemble toutes les données connues de l'utilisateur en un seul objet
  /// JSON — une table en erreur n'interrompt pas les autres, elle est juste
  /// absente du résultat (avec un indicateur d'erreur).
  static Future<Map<String, dynamic>> exportUserData() async {
    final uid = SupabaseConfig.userId;
    if (uid == null) return {'error': 'not_authenticated'};

    final result = <String, dynamic>{
      'exported_at': DateTime.now().toIso8601String(),
      'user_id': uid,
    };

    for (final entry in _userTables.entries) {
      final table = entry.key;
      final column = entry.value;
      try {
        final rows = await SupabaseConfig.table(table)
            .select()
            .eq(column, uid);
        result[table] = rows;
      } catch (e) {
        debugPrint('[Privacy] export failed for $table: $e');
        result[table] = {'error': 'export_failed'};
      }
    }
    return result;
  }

  static String exportUserDataAsJson(Map<String, dynamic> data) =>
      const JsonEncoder.withIndent('  ').convert(data);

  /// Supprime toutes les lignes connues appartenant à l'utilisateur, puis
  /// enregistre une demande de suppression du compte d'authentification —
  /// le SDK client n'a pas les droits pour supprimer auth.users directement
  /// (ça nécessite la clé service_role, côté serveur uniquement). Une
  /// fonction backend (cron/edge function) doit lire `account_deletion_requests`
  /// et finaliser la suppression du compte Auth.
  static Future<bool> deleteAllUserData() async {
    final uid = SupabaseConfig.userId;
    if (uid == null) return false;

    var allSucceeded = true;
    for (final entry in _userTables.entries) {
      final table = entry.key;
      final column = entry.value;
      try {
        await SupabaseConfig.table(table).delete().eq(column, uid);
      } catch (e) {
        debugPrint('[Privacy] delete failed for $table: $e');
        allSucceeded = false;
      }
    }

    try {
      await SupabaseConfig.table('account_deletion_requests').insert({
        'user_id':      uid,
        'requested_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('[Privacy] deletion request insert failed: $e');
      allSucceeded = false;
    }

    await AuthService.signOut();
    return allSucceeded;
  }
}
