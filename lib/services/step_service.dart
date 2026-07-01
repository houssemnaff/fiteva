import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:pedometer/pedometer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'supabase_config.dart';

class StepService {
  static const String _keyInitialSteps = 'initial_steps';
  static const String _keyLastDate     = 'last_step_date';
  static const String _keySavedSteps   = 'saved_steps_today';

  late SharedPreferences _prefs;
  int _currentSteps = 0;
  int? _initialSteps;
  bool _baselineSet = false;

  late Stream<StepCount> _stepStream;

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadDailyBaseline();
    _stepStream = kIsWeb ? const Stream.empty() : Pedometer.stepCountStream;
    // Charge les pas sauvegardés localement au démarrage
    _currentSteps = _prefs.getInt(_keySavedSteps) ?? 0;
  }

  Stream<StepCount> getStepStream() => _stepStream;

  /// Appelé à chaque événement du pédomètre
  void onStepEvent(StepCount event) {
    _currentSteps = event.steps;

    if (!_baselineSet) {
      _initialSteps = event.steps;
      _prefs.setInt(_keyInitialSteps, event.steps);
      _baselineSet = true;
    }

    final stepsToday = getStepsToday();
    _prefs.setInt(_keySavedSteps, stepsToday);
    _syncToSupabase(stepsToday);
  }

  int getStepsToday() {
    if (_initialSteps == null) return _prefs.getInt(_keySavedSteps) ?? 0;
    return (_currentSteps - _initialSteps!).clamp(0, 999999).toInt();
  }

  int getCurrentSteps() => _currentSteps;

  Future<void> _loadDailyBaseline() async {
    final lastDate = _prefs.getString(_keyLastDate) ?? '';
    final today    = _dateString(DateTime.now());

    if (lastDate != today) {
      // Nouveau jour : réinitialise la baseline
      await _prefs.setString(_keyLastDate, today);
      await _prefs.remove(_keyInitialSteps);
      await _prefs.remove(_keySavedSteps);
      _initialSteps = null;
      _baselineSet  = false;
    } else {
      _initialSteps = _prefs.getInt(_keyInitialSteps);
      _baselineSet  = _initialSteps != null;
    }
  }

  // ── Sync Supabase (upsert daily steps) ──────────────────────────────────────
  void _syncToSupabase(int steps) {
    final uid = SupabaseConfig.userId;
    if (uid == null) return;

    SupabaseConfig.table('user_step_logs').upsert({
      'user_id':    uid,
      'date':       _dateString(DateTime.now()),
      'steps':      steps,
      'updated_at': DateTime.now().toIso8601String(),
    }, onConflict: 'user_id,date').catchError((_) {});
  }

  /// Charge les pas d'un jour depuis Supabase (pour l'historique).
  static Future<int> fetchStepsForDate(DateTime date) async {
    final uid = SupabaseConfig.userId;
    if (uid == null) return 0;
    try {
      final row = await SupabaseConfig.table('user_step_logs')
          .select('steps')
          .eq('user_id', uid)
          .eq('date', _dateString(date))
          .maybeSingle();
      return (row?['steps'] as int?) ?? 0;
    } catch (_) {
      return 0;
    }
  }

  static String _dateString(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  static String formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (Match m) => ',',
    );
  }
}
