import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'supabase_config.dart';
import 'storage_service.dart';

/// Push notifications via Firebase Cloud Messaging.
///
/// Flux :
///  1. init() au démarrage (après Firebase.initializeApp)
///  2. requestPermissionIfNeeded() après l'onboarding / premier lancement
///  3. Le token FCM est sauvegardé dans Supabase (user_fcm_tokens)
///     → le backend peut envoyer des push ciblés
class PushNotificationService {
  static const _permissionAskedKey = 'push_permission_asked';

  static FirebaseMessaging get _fm => FirebaseMessaging.instance;

  /// À appeler une fois au démarrage, après Firebase.initializeApp().
  static Future<void> init() async {
    try {
      // Message reçu pendant que l'app est ouverte (foreground)
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('[Push] foreground: ${message.notification?.title}');
        // Sur web le navigateur n'affiche pas les notifs foreground —
        // on pourrait afficher un SnackBar ici si besoin.
      });

      // L'utilisateur a tapé sur une notification (app en background)
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        debugPrint('[Push] opened from notification: ${message.data}');
      });

      // Token refresh → re-sync Supabase
      _fm.onTokenRefresh.listen(_saveToken);
    } catch (e) {
      debugPrint('[Push] init error: $e');
    }
  }

  /// Demande la permission une seule fois (au premier lancement).
  /// Retourne true si la permission est accordée.
  static Future<bool> requestPermissionIfNeeded() async {
    // Déjà demandé ? on vérifie juste le statut actuel
    final alreadyAsked = StorageService.getString(_permissionAskedKey) == '1';

    try {
      NotificationSettings settings;
      if (alreadyAsked) {
        settings = await _fm.getNotificationSettings();
      } else {
        settings = await _fm.requestPermission(
          alert: true,
          badge: true,
          sound: true,
        );
        await StorageService.setString(_permissionAskedKey, '1');
      }

      final granted =
          settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;

      if (granted) {
        final token = await _fm.getToken();
        if (token != null) await _saveToken(token);
      }
      return granted;
    } catch (e) {
      debugPrint('[Push] permission error: $e');
      return false;
    }
  }

  /// Sauvegarde le token FCM dans Supabase pour cibler cet utilisateur.
  static Future<void> _saveToken(String token) async {
    final uid = SupabaseConfig.userId;
    if (uid == null) return;
    try {
      await SupabaseConfig.table('user_fcm_tokens').upsert({
        'user_id':    uid,
        'token':      token,
        'platform':   kIsWeb ? 'web' : defaultTargetPlatform.name,
        'updated_at': DateTime.now().toIso8601String(),
      }, onConflict: 'user_id,token');
      debugPrint('[Push] token saved');
    } catch (e) {
      debugPrint('[Push] save token error: $e');
    }
  }

  /// À appeler au logout pour ne plus recevoir de push sur cet appareil.
  static Future<void> deleteToken() async {
    final uid = SupabaseConfig.userId;
    try {
      final token = await _fm.getToken();
      if (token != null && uid != null) {
        await SupabaseConfig.table('user_fcm_tokens')
            .delete()
            .eq('user_id', uid)
            .eq('token', token);
      }
      await _fm.deleteToken();
    } catch (_) {}
  }
}
