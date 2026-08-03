import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show PostgresChangeEvent, RealtimeChannel;

import '../models/notification_model.dart';
import '../services/notification_service.dart';
import '../services/supabase_config.dart';

/// Notifications in-app (bell icon) — distinct des providers push/FCM.
class NotificationsNotifier extends StateNotifier<List<NotificationModel>> {
  NotificationsNotifier() : super([]) {
    refresh();

    // Écoute Realtime — pas de filtre : RLS ne laisse de toute façon
    // remonter à ce client que ses propres notifications (même convention
    // que partner_join_requests_realtime / training_partners_realtime).
    _channel = SupabaseConfig.client
        .channel('user_notifications_realtime')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'user_notifications',
          callback: (payload) {
            debugPrint('[Notifications] realtime event: ${payload.eventType}');
            refresh();
          },
        )
        .subscribe((status, error) {
          debugPrint('[Notifications] channel status: $status${error != null ? ' error: $error' : ''}');
        });
  }

  late final RealtimeChannel _channel;

  Future<void> refresh() async {
    state = await NotificationService.loadNotifications();
  }

  Future<void> markAllAsRead() async {
    if (state.every((n) => n.isRead)) return;
    state = [for (final n in state) n.copyWith(isRead: true)];
    await NotificationService.markAllAsRead();
  }

  /// Suppression optimiste (swipe) — pas de rollback en cas d'échec réseau,
  /// même convention que le reste de l'app (CommunityService.leaveEvent...).
  Future<void> delete(String id) async {
    state = state.where((n) => n.id != id).toList();
    await NotificationService.delete(id);
  }

  @override
  void dispose() {
    SupabaseConfig.client.removeChannel(_channel);
    super.dispose();
  }
}

final notificationsProvider =
    StateNotifierProvider<NotificationsNotifier, List<NotificationModel>>(
        (_) => NotificationsNotifier());

final notificationsUnreadCountProvider = Provider<int>(
  (ref) => ref.watch(notificationsProvider).where((n) => !n.isRead).length,
);
