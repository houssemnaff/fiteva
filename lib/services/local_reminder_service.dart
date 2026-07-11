import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import '../providers/notification_preferences_provider.dart';
import 'storage_service.dart';

class LocalReminderService {
  LocalReminderService._();

  static const _enabledKey = 'reminders_enabled';

  // IDs fixes par créneau
  static const _idWater1     = 1001;
  static const _idWater2     = 1002;
  static const _idWater3     = 1003;
  static const _idBreakfast  = 1010;
  static const _idLunch      = 1011;
  static const _idDinner     = 1012;
  static const _idWorkout    = 1020;
  static const _idCycle      = 1030;

  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static bool get remindersEnabled =>
      StorageService.getString(_enabledKey) != '0';

  static Future<void> init() async {
    if (_initialized) return;
    try {
      tz_data.initializeTimeZones();
      tz.setLocalLocation(tz.getLocation('Europe/Paris'));

      const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosInit = DarwinInitializationSettings(
        requestAlertPermission: false,
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
        return granted ?? true;
      }
      return true;
    } catch (e) {
      debugPrint('[Reminders] permission error: $e');
      return false;
    }
  }

  static Future<void> setEnabled(bool enabled) async {
    await StorageService.setString(_enabledKey, enabled ? '1' : '0');
    if (enabled) {
      await scheduleAllDefaults();
    } else {
      await cancelAll();
    }
  }

  /// Reprogramme tous les rappels selon les préférences utilisateur.
  static Future<void> scheduleFromPrefs(NotificationPreferences prefs) async {
    if (!_initialized) await init();
    if (!remindersEnabled) return;

    // Cancel all first, then reschedule only enabled ones
    await cancelAll();

    if (prefs.waterEnabled) {
      await _scheduleDaily(_idWater1, prefs.waterTime1Hour, prefs.waterTime1Min,
          'Pense à boire 💧', 'Un petit verre d\'eau, ça fait toujours du bien.');
      await _scheduleDaily(_idWater2, prefs.waterTime2Hour, prefs.waterTime2Min,
          'Pense à boire 💧', 'Reste hydratée pour garder ton énergie.');
      await _scheduleDaily(_idWater3, prefs.waterTime3Hour, prefs.waterTime3Min,
          'Pense à boire 💧', 'Dernier rappel eau de la journée.');
    }

    if (prefs.mealsEnabled) {
      await _scheduleDaily(_idBreakfast, prefs.breakfastHour, prefs.breakfastMin,
          'Petit-déjeuner 🍳', 'N\'oublie pas de logger ton repas dans FitEva.');
      await _scheduleDaily(_idLunch, prefs.lunchHour, prefs.lunchMin,
          'Déjeuner 🥗', 'C\'est l\'heure de manger — pense à le noter.');
      await _scheduleDaily(_idDinner, prefs.dinnerHour, prefs.dinnerMin,
          'Dîner 🍽️', 'Dernier repas de la journée à logger.');
    }

    if (prefs.workoutEnabled) {
      await _scheduleDaily(_idWorkout, prefs.workoutHour, prefs.workoutMin,
          'Séance du jour 💪', 'Ta séance t\'attend — même 15 minutes comptent.');
    }

    if (prefs.cycleEnabled) {
      await _scheduleDaily(_idCycle, prefs.cycleHour, prefs.cycleMin,
          'Rappel cycle 🌸', 'Consulte ta phase du cycle et adapte ta journée.');
    }
  }

  /// Fallback : programme avec les horaires par défaut.
  static Future<void> scheduleAllDefaults() async {
    await scheduleFromPrefs(const NotificationPreferences());
  }

  /// Programme un rappel cycle contextuel (une seule fois, pas récurrent).
  static Future<void> scheduleCycleReminder({
    required String phaseName,
    required String advice,
    required int hour,
    required int minute,
  }) async {
    if (!_initialized) await init();
    if (!remindersEnabled) return;

    final title = switch (phaseName) {
      'Règles'        => 'Phase menstruelle 🌙',
      'Folliculaire'  => 'Phase folliculaire 🌱',
      'Ovulation'     => 'Pic d\'énergie ! ⚡',
      'Lutéale'       => 'Phase lutéale 🍂',
      _               => 'Ton cycle 🌸',
    };

    await _scheduleDaily(_idCycle, hour, minute, title, advice);
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
            channelDescription: 'Rappels eau, repas, séance et cycle',
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
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
