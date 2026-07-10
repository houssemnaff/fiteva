import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import 'storage_service.dart';

/// Rappels locaux (eau, repas, séance) — programmés directement sur
/// l'appareil, sans passer par un backend. Contrairement aux push FCM
/// (PushNotificationService), ces rappels fonctionnent même hors ligne et ne
/// nécessitent aucune infrastructure serveur pour être déclenchés.
class LocalReminderService {
  LocalReminderService._();

  static const _enabledKey = 'reminders_enabled';

  // IDs fixes par créneau — un id stable par rappel permet de le
  // reprogrammer (cancel + schedule) sans dupliquer les notifications.
  static const _idWater1     = 1001;
  static const _idWater2     = 1002;
  static const _idWater3     = 1003;
  static const _idBreakfast  = 1010;
  static const _idLunch      = 1011;
  static const _idDinner     = 1012;
  static const _idWorkout    = 1020;

  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static bool get remindersEnabled =>
      StorageService.getString(_enabledKey) != '0'; // activé par défaut

  /// À appeler une fois au démarrage (après runApp), avant tout scheduling.
  static Future<void> init() async {
    if (_initialized) return;
    try {
      tz_data.initializeTimeZones();
      // Best-effort : sans le fuseau local exact, les rappels partent sur
      // UTC — décalés mais pas cassés. Assez pour une v1 sans dépendance
      // native supplémentaire (flutter_timezone) juste pour ce détail.
      tz.setLocalLocation(tz.getLocation('Europe/Paris'));

      const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosInit = DarwinInitializationSettings(
        requestAlertPermission: false, // demandée explicitement via requestPermission()
        requestBadgePermission: false,
        requestSoundPermission: false,
      );
      await _plugin.initialize(
        const InitializationSettings(android: androidInit, iOS: iosInit),
      );
      _initialized = true;
    } catch (e) {
      debugPrint('[Reminders] init error: $e');
    }
  }

  /// Demande la permission (iOS : popup système ; Android 13+ : POST_NOTIFICATIONS).
  static Future<bool> requestPermission() async {
    try {
      final ios = _plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      if (ios != null) {
        final granted = await ios.requestPermissions(
            alert: true, badge: true, sound: true);
        return granted ?? false;
      }
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      if (android != null) {
        final granted = await android.requestNotificationsPermission();
        return granted ?? true; // Android < 13 : pas de permission requise
      }
      return true;
    } catch (e) {
      debugPrint('[Reminders] permission error: $e');
      return false;
    }
  }

  /// Active/désactive tous les rappels — persisté pour survivre au redémarrage.
  static Future<void> setEnabled(bool enabled) async {
    await StorageService.setString(_enabledKey, enabled ? '1' : '0');
    if (enabled) {
      await scheduleAllDefaults();
    } else {
      await cancelAll();
    }
  }

  /// Programme le jeu de rappels par défaut : eau (3x/jour), 3 repas, séance.
  /// Idempotent — peut être rappelé sans créer de doublons (mêmes ids).
  static Future<void> scheduleAllDefaults() async {
    if (!_initialized) await init();
    if (!remindersEnabled) return;

    await _scheduleDaily(_idWater1, 10, 0,
        'Pense à boire 💧', 'Un petit verre d\'eau, ça fait toujours du bien.');
    await _scheduleDaily(_idWater2, 14, 0,
        'Pense à boire 💧', 'Reste hydratée pour garder ton énergie.');
    await _scheduleDaily(_idWater3, 18, 0,
        'Pense à boire 💧', 'Dernier rappel eau de la journée.');

    await _scheduleDaily(_idBreakfast, 8, 30,
        'Petit-déjeuner 🍳', 'N\'oublie pas de logger ton repas dans FitEva.');
    await _scheduleDaily(_idLunch, 12, 30,
        'Déjeuner 🥗', 'C\'est l\'heure de manger — pense à le noter.');
    await _scheduleDaily(_idDinner, 19, 30,
        'Dîner 🍽️', 'Dernier repas de la journée à logger.');

    await _scheduleDaily(_idWorkout, 17, 0,
        'Séance du jour 💪', 'Ta séance t\'attend — même 15 minutes comptent.');
  }

  static Future<void> _scheduleDaily(
    int id, int hour, int minute, String title, String body,
  ) async {
    try {
      final now = tz.TZDateTime.now(tz.local);
      var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
      if (scheduled.isBefore(now)) {
        scheduled = scheduled.add(const Duration(days: 1));
      }
      await _plugin.zonedSchedule(
        id, title, body, scheduled,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'daily_reminders', 'Rappels quotidiens',
            channelDescription: 'Rappels eau, repas et séance',
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time, // répète chaque jour à cette heure
      );
    } catch (e) {
      debugPrint('[Reminders] schedule error ($id): $e');
    }
  }

  static Future<void> cancelAll() async {
    try {
      await _plugin.cancelAll();
    } catch (e) {
      debugPrint('[Reminders] cancelAll error: $e');
    }
  }
}
