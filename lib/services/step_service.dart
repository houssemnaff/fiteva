import 'package:pedometer/pedometer.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StepService {
  static const String _keyInitialSteps = 'initial_steps';
  static const String _keyLastDate = 'last_step_date';

  late SharedPreferences _prefs;
  int _currentSteps = 0;
  int? _initialSteps;
  bool _baselineSet = false;

  late Stream<StepCount> _stepStream;

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadDailyBaseline();
    _stepStream = Pedometer.stepCountStream;
  }

  Stream<StepCount> getStepStream() => _stepStream;

  /// Call this when stream emits data
  void onStepEvent(StepCount event) {
    _currentSteps = event.steps;

    if (!_baselineSet) {
      _initialSteps = event.steps;
      _prefs.setInt(_keyInitialSteps, event.steps);
      _baselineSet = true;
    }
  }

  int getStepsToday() {
    if (_initialSteps == null) return 0;
    return (_currentSteps - _initialSteps!).clamp(0, double.infinity).toInt();
  }

  int getCurrentSteps() => _currentSteps;

  Future<void> _loadDailyBaseline() async {
    final lastDate = _prefs.getString(_keyLastDate) ?? '';
    final today = _getDateString(DateTime.now());

    if (lastDate != today) {
      await _prefs.setString(_keyLastDate, today);
      await _prefs.remove(_keyInitialSteps);
      _initialSteps = null;
      _baselineSet = false;
    } else {
      _initialSteps = _prefs.getInt(_keyInitialSteps);
      _baselineSet = _initialSteps != null;
    }
  }

  static String _getDateString(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  static String formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (Match m) => ',',
    );
  }
}