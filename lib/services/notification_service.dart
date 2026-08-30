import 'package:flutter/foundation.dart';

import '../models/notification_model.dart';
import 'supabase_config.dart';

/// Notifications in-app (bell icon) — distinct du push FCM
/// ([PushNotificationService] / edge function `send-push`).
/// Source de vérité : Supabase (table user_notifications).
class NotificationService {
  NotificationService._();

  static String? get _uid => SupabaseConfig.userId;

  /// Crée une notification pour [userId]. Ne bloque jamais l'action qui l'a
  /// déclenchée (rejoindre un événement, envoyer une demande...) — les
  /// erreurs sont avalées, comme le reste de CommunityService.
  static Future<void> create({
    required String userId,
    required String actorId,
    required String type,
    required String title,
    required String body,
    Map<String, dynamic> data = const {},
  }) async {
    if (actorId == userId) return;
    try {
      await SupabaseConfig.table('user_notifications').insert({
        'user_id':  userId,
        'actor_id': actorId,
        'type':     type,
        'title':    title,
        'body':     body,
        'data':     data,
      });
    } catch (e) {
      debugPrint('[NotificationService] create error: $e');
    }
  }

  static Future<List<NotificationModel>> loadNotifications({int limit = 50}) async {
    if (_uid == null) return [];
    try {
      final rows = await SupabaseConfig.table('user_notifications')
          .select()
          .eq('user_id', _uid!)
          .order('created_at', ascending: false)
          .limit(limit) as List;
      return rows
          .map((r) => NotificationModel.fromJson(r as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('[NotificationService] loadNotifications error: $e');
      return [];
    }
  }

  static Future<void> markAsRead(String id) async {
    try {
      await SupabaseConfig.table('user_notifications')
          .update({'is_read': true})
          .eq('id', id);
    } catch (e) {
      debugPrint('[NotificationService] markAsRead error: $e');
    }
  }

  static Future<void> markAllAsRead() async {
    if (_uid == null) return;
    try {
      await SupabaseConfig.table('user_notifications')
          .update({'is_read': true})
          .eq('user_id', _uid!)
          .eq('is_read', false);
    } catch (e) {
      debugPrint('[NotificationService] markAllAsRead error: $e');
    }
  }

  static Future<void> delete(String id) async {
    try {
      await SupabaseConfig.table('user_notifications').delete().eq('id', id);
    } catch (e) {
      debugPrint('[NotificationService] delete error: $e');
    }
  }
}
