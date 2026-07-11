import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/storage_service.dart';

class NotificationPreferences {
  final bool waterEnabled;
  final bool mealsEnabled;
  final bool workoutEnabled;
  final bool cycleEnabled;
  final bool inactivityEnabled;

  // Horaires personnalisables (heure * 60 + minute)
  final int waterTime1;
  final int waterTime2;
  final int waterTime3;
  final int breakfastTime;
  final int lunchTime;
  final int dinnerTime;
  final int workoutTime;
  final int cycleTime;

  const NotificationPreferences({
    this.waterEnabled = true,
    this.mealsEnabled = true,
    this.workoutEnabled = true,
    this.cycleEnabled = true,
    this.inactivityEnabled = true,
    this.waterTime1 = 600,     // 10:00
    this.waterTime2 = 840,     // 14:00
    this.waterTime3 = 1080,    // 18:00
    this.breakfastTime = 510,  // 08:30
    this.lunchTime = 750,      // 12:30
    this.dinnerTime = 1170,    // 19:30
    this.workoutTime = 1020,   // 17:00
    this.cycleTime = 540,      // 09:00
  });

  int get waterTime1Hour => waterTime1 ~/ 60;
  int get waterTime1Min => waterTime1 % 60;
  int get waterTime2Hour => waterTime2 ~/ 60;
  int get waterTime2Min => waterTime2 % 60;
  int get waterTime3Hour => waterTime3 ~/ 60;
  int get waterTime3Min => waterTime3 % 60;
  int get breakfastHour => breakfastTime ~/ 60;
  int get breakfastMin => breakfastTime % 60;
  int get lunchHour => lunchTime ~/ 60;
  int get lunchMin => lunchTime % 60;
  int get dinnerHour => dinnerTime ~/ 60;
  int get dinnerMin => dinnerTime % 60;
  int get workoutHour => workoutTime ~/ 60;
  int get workoutMin => workoutTime % 60;
  int get cycleHour => cycleTime ~/ 60;
  int get cycleMin => cycleTime % 60;

  NotificationPreferences copyWith({
    bool? waterEnabled,
    bool? mealsEnabled,
    bool? workoutEnabled,
    bool? cycleEnabled,
    bool? inactivityEnabled,
    int? waterTime1,
    int? waterTime2,
    int? waterTime3,
    int? breakfastTime,
    int? lunchTime,
    int? dinnerTime,
    int? workoutTime,
    int? cycleTime,
  }) => NotificationPreferences(
    waterEnabled: waterEnabled ?? this.waterEnabled,
    mealsEnabled: mealsEnabled ?? this.mealsEnabled,
    workoutEnabled: workoutEnabled ?? this.workoutEnabled,
    cycleEnabled: cycleEnabled ?? this.cycleEnabled,
    inactivityEnabled: inactivityEnabled ?? this.inactivityEnabled,
    waterTime1: waterTime1 ?? this.waterTime1,
    waterTime2: waterTime2 ?? this.waterTime2,
    waterTime3: waterTime3 ?? this.waterTime3,
    breakfastTime: breakfastTime ?? this.breakfastTime,
    lunchTime: lunchTime ?? this.lunchTime,
    dinnerTime: dinnerTime ?? this.dinnerTime,
    workoutTime: workoutTime ?? this.workoutTime,
    cycleTime: cycleTime ?? this.cycleTime,
  );
}

class NotificationPreferencesNotifier extends Notifier<NotificationPreferences> {
  static const _prefix = 'notif_';

  @override
  NotificationPreferences build() {
    return NotificationPreferences(
      waterEnabled: _getBool('water', true),
      mealsEnabled: _getBool('meals', true),
      workoutEnabled: _getBool('workout', true),
      cycleEnabled: _getBool('cycle', true),
      inactivityEnabled: _getBool('inactivity', true),
      waterTime1: _getInt('water_t1', 600),
      waterTime2: _getInt('water_t2', 840),
      waterTime3: _getInt('water_t3', 1080),
      breakfastTime: _getInt('breakfast_t', 510),
      lunchTime: _getInt('lunch_t', 750),
      dinnerTime: _getInt('dinner_t', 1170),
      workoutTime: _getInt('workout_t', 1020),
      cycleTime: _getInt('cycle_t', 540),
    );
  }

  bool _getBool(String key, bool def) =>
      StorageService.getString('$_prefix$key') == null
          ? def
          : StorageService.getString('$_prefix$key') == '1';

  int _getInt(String key, int def) {
    final v = StorageService.getString('$_prefix$key');
    return v == null ? def : (int.tryParse(v) ?? def);
  }

  Future<void> _save(String key, String value) =>
      StorageService.setString('$_prefix$key', value);

  Future<void> setWaterEnabled(bool v) async {
    await _save('water', v ? '1' : '0');
    state = state.copyWith(waterEnabled: v);
  }

  Future<void> setMealsEnabled(bool v) async {
    await _save('meals', v ? '1' : '0');
    state = state.copyWith(mealsEnabled: v);
  }

  Future<void> setWorkoutEnabled(bool v) async {
    await _save('workout', v ? '1' : '0');
    state = state.copyWith(workoutEnabled: v);
  }

  Future<void> setCycleEnabled(bool v) async {
    await _save('cycle', v ? '1' : '0');
    state = state.copyWith(cycleEnabled: v);
  }

  Future<void> setInactivityEnabled(bool v) async {
    await _save('inactivity', v ? '1' : '0');
    state = state.copyWith(inactivityEnabled: v);
  }

  Future<void> setWaterTime1(int v) async {
    await _save('water_t1', '$v');
    state = state.copyWith(waterTime1: v);
  }

  Future<void> setWaterTime2(int v) async {
    await _save('water_t2', '$v');
    state = state.copyWith(waterTime2: v);
  }

  Future<void> setWaterTime3(int v) async {
    await _save('water_t3', '$v');
    state = state.copyWith(waterTime3: v);
  }

  Future<void> setBreakfastTime(int v) async {
    await _save('breakfast_t', '$v');
    state = state.copyWith(breakfastTime: v);
  }

  Future<void> setLunchTime(int v) async {
    await _save('lunch_t', '$v');
    state = state.copyWith(lunchTime: v);
  }

  Future<void> setDinnerTime(int v) async {
    await _save('dinner_t', '$v');
    state = state.copyWith(dinnerTime: v);
  }

  Future<void> setWorkoutTime(int v) async {
    await _save('workout_t', '$v');
    state = state.copyWith(workoutTime: v);
  }

  Future<void> setCycleTime(int v) async {
    await _save('cycle_t', '$v');
    state = state.copyWith(cycleTime: v);
  }
}

final notifPrefsProvider =
    NotifierProvider<NotificationPreferencesNotifier, NotificationPreferences>(
        NotificationPreferencesNotifier.new);
