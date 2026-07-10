import 'cycle_log_service.dart';
import 'supabase_config.dart';

/// Agrège les données déjà loguées (repas, eau, humeur) sur une plage de
/// jours pour l'écran "Tendances" — aucune nouvelle table nécessaire, tout
/// existait déjà en base mais n'était jamais visualisé dans la durée.
class DayPoint {
  final DateTime date;
  final double value;
  const DayPoint(this.date, this.value);
}

class TrendsService {
  TrendsService._();

  static String _key(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  /// Calories consommées par jour sur les [days] derniers jours (aujourd'hui inclus).
  static Future<List<DayPoint>> caloriesByDay({int days = 14}) async {
    final uid = SupabaseConfig.userId;
    if (uid == null) return [];
    final from = DateTime.now().subtract(Duration(days: days - 1));
    try {
      final rows = await SupabaseConfig.table('user_meal_entries')
          .select('date, grams, kcal_per100')
          .eq('user_id', uid)
          .gte('date', _key(from)) as List;

      final totals = <String, double>{};
      for (final r in rows) {
        final map = r as Map<String, dynamic>;
        final date = map['date'] as String;
        final grams = (map['grams'] as num? ?? 0).toDouble();
        final kcalPer100 = (map['kcal_per100'] as num? ?? 0).toDouble();
        totals[date] = (totals[date] ?? 0) + grams * kcalPer100 / 100;
      }
      return _fillRange(from, days, totals);
    } catch (_) {
      return [];
    }
  }

  /// Eau (ml) par jour sur les [days] derniers jours.
  static Future<List<DayPoint>> waterByDay({int days = 14}) async {
    final uid = SupabaseConfig.userId;
    if (uid == null) return [];
    final from = DateTime.now().subtract(Duration(days: days - 1));
    try {
      final rows = await SupabaseConfig.table('user_water_logs')
          .select('date, water_ml')
          .eq('user_id', uid)
          .gte('date', _key(from)) as List;

      final totals = <String, double>{
        for (final r in rows)
          (r as Map<String, dynamic>)['date'] as String:
              ((r)['water_ml'] as num? ?? 0).toDouble(),
      };
      return _fillRange(from, days, totals);
    } catch (_) {
      return [];
    }
  }

  /// Humeur (index 0-4) par jour sur les [days] derniers jours — null les
  /// jours non renseignés (pas de barre à 0, juste absente du graphe).
  static Future<List<DayPoint?>> moodByDay({int days = 14}) async {
    final from = DateTime.now().subtract(Duration(days: days - 1));
    final logs = await CycleLogService.loadLogsRange(from, DateTime.now());
    final byDate = {for (final l in logs) _key(l.date): l.moodIndex};

    return List.generate(days, (i) {
      final d = from.add(Duration(days: i));
      final mood = byDate[_key(d)];
      return mood == null ? null : DayPoint(d, mood.toDouble());
    });
  }

  static List<DayPoint> _fillRange(
      DateTime from, int days, Map<String, double> totals) {
    return List.generate(days, (i) {
      final d = from.add(Duration(days: i));
      return DayPoint(d, totals[_key(d)] ?? 0);
    });
  }
}
