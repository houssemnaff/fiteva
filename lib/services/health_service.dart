import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:health/health.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HealthService {
  HealthService._();

  static final Health _health = Health();
  static const String _enabledKey = 'health_sync_enabled';

  static final List<HealthDataType> _types = [
    HealthDataType.WORKOUT,
    HealthDataType.ACTIVE_ENERGY_BURNED,
    HealthDataType.STEPS,
  ];

  static final List<HealthDataAccess> _permissions = [
    HealthDataAccess.READ_WRITE,
    HealthDataAccess.READ_WRITE,
    HealthDataAccess.READ,
  ];

  static Future<bool> get isEnabled async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_enabledKey) ?? false;
  }

  static Future<void> setEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_enabledKey, value);
  }

  static bool get isSupported =>
      !kIsWeb && (Platform.isIOS || Platform.isAndroid);

  static Future<bool> requestAuthorization() async {
    if (!isSupported) return false;
    try {
      if (Platform.isIOS) {
        return await _health.requestAuthorization(_types, permissions: _permissions);
      } else {
        await Health().configure();
        return await _health.requestAuthorization(_types, permissions: _permissions);
      }
    } catch (e) {
      debugPrint('[HealthService] requestAuthorization failed: $e');
      return false;
    }
  }

  static Future<bool> hasPermissions() async {
    if (!isSupported) return false;
    try {
      final result = await _health.hasPermissions(_types, permissions: _permissions);
      return result ?? false;
    } catch (e) {
      debugPrint('[HealthService] hasPermissions check failed: $e');
      return false;
    }
  }

  static Future<bool> syncWorkout({
    required String workoutTitle,
    required int durationMinutes,
    required int caloriesBurned,
  }) async {
    if (!isSupported) return false;

    final enabled = await isEnabled;
    if (!enabled) return false;

    final hasPerm = await hasPermissions();
    if (!hasPerm) return false;

    try {
      final now = DateTime.now();
      final start = now.subtract(Duration(minutes: durationMinutes));

      final success = await _health.writeWorkoutData(
        activityType: HealthWorkoutActivityType.TRADITIONAL_STRENGTH_TRAINING,
        start: start,
        end: now,
        totalEnergyBurned: caloriesBurned,
        totalEnergyBurnedUnit: HealthDataUnit.KILOCALORIE,
      );

      if (success) {
        debugPrint('[HealthService] Workout synced: $workoutTitle ($durationMinutes min, $caloriesBurned kcal)');
      }
      return success;
    } catch (e) {
      debugPrint('[HealthService] syncWorkout failed: $e');
      return false;
    }
  }

  static Future<int> getTodaySteps() async {
    if (!isSupported) return 0;
    try {
      final now = DateTime.now();
      final midnight = DateTime(now.year, now.month, now.day);
      final steps = await _health.getTotalStepsInInterval(midnight, now);
      return steps ?? 0;
    } catch (e) {
      debugPrint('[HealthService] getTodaySteps failed: $e');
      return 0;
    }
  }
}
