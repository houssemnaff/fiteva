import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/workout_model.dart';
import '../services/supabase_config.dart';

// ── Status ────────────────────────────────────────────────────────────────────

enum DayStatus { empty, rest, planned, done }

// ── Model ─────────────────────────────────────────────────────────────────────

class DayPlan {
  final int weekdayIndex;
  final String dayShort;
  final String dayFull;
  final DateTime date;
  final DayStatus status;
  final String? categoryId;
  final WorkoutModel? workout;

  const DayPlan({
    required this.weekdayIndex,
    required this.dayShort,
    required this.dayFull,
    required this.date,
    this.status = DayStatus.empty,
    this.categoryId,
    this.workout,
  });

  DayPlan copyWith({
    DayStatus? status,
    String? categoryId,
    WorkoutModel? workout,
    bool clearWorkout = false,
    bool clearCategory = false,
  }) =>
      DayPlan(
        weekdayIndex: weekdayIndex,
        dayShort: dayShort,
        dayFull: dayFull,
        date: date,
        status: status ?? this.status,
        categoryId: clearCategory ? null : (categoryId ?? this.categoryId),
        workout: clearWorkout ? null : (workout ?? this.workout),
      );

  bool get isToday {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  bool get isPast {
    final today = DateTime.now();
    final todayNorm = DateTime(today.year, today.month, today.day);
    final dateNorm  = DateTime(date.year, date.month, date.day);
    return dateNorm.isBefore(todayNorm);
  }
}

// ── Notifier ──────────────────────────────────────────────────────────────────

class WeeklyPlanNotifier extends Notifier<List<DayPlan>> {
  static const _shorts = ['LUN', 'MAR', 'MER', 'JEU', 'VEN', 'SAM', 'DIM'];
  static const _fulls = [
    'Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche'
  ];

  late String _weekStart;

  static String _weekStartKey(DateTime now) {
    final monday = now.subtract(Duration(days: now.weekday - 1));
    return '${monday.year}-${monday.month.toString().padLeft(2, '0')}-${monday.day.toString().padLeft(2, '0')}';
  }

  @override
  List<DayPlan> build() {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    _weekStart = _weekStartKey(now);
    final initial = List.generate(7, (i) => DayPlan(
      weekdayIndex: i,
      dayShort: _shorts[i],
      dayFull: _fulls[i],
      date: monday.add(Duration(days: i)),
    ));
    Future.microtask(_loadFromSupabase);
    return initial;
  }

  Future<void> _loadFromSupabase() async {
    final uid = SupabaseConfig.userId;
    if (uid == null) return;
    try {
      final rows = await SupabaseConfig.table('user_weekly_plans')
          .select()
          .eq('user_id', uid)
          .eq('week_start', _weekStart) as List;
      if (rows.isEmpty) return;

      // Need workouts to resolve workout_id → WorkoutModel.
      // We use ref.read here — providers that expose workouts must already be loaded.
      final updated = List<DayPlan>.from(state);
      for (final r in rows) {
        final idx = r['weekday_index'] as int;
        if (idx < 0 || idx >= 7) continue;
        final statusStr = r['status'] as String? ?? 'empty';
        final status = DayStatus.values.firstWhere(
          (s) => s.name == statusStr,
          orElse: () => DayStatus.empty,
        );
        updated[idx] = updated[idx].copyWith(
          status: status,
          categoryId: r['category_id'] as String?,
        );
      }
      state = updated;
    } catch (_) {}
  }

  Future<void> _save(int index) async {
    final uid = SupabaseConfig.userId;
    if (uid == null) return;
    final day = state[index];
    try {
      if (day.status == DayStatus.empty) {
        await SupabaseConfig.table('user_weekly_plans')
            .delete()
            .eq('user_id', uid)
            .eq('week_start', _weekStart)
            .eq('weekday_index', index);
      } else {
        await SupabaseConfig.table('user_weekly_plans').upsert({
          'user_id':       uid,
          'week_start':    _weekStart,
          'weekday_index': index,
          'category_id':   day.categoryId ?? day.workout?.category,
          'status':        day.status.name,
          'workout_id':    day.workout?.id,
        }, onConflict: 'user_id,week_start,weekday_index');
      }
    } catch (e) {
      debugPrint('[WeeklyPlan] _save error: $e');
    }
  }

  // Assigner une catégorie (+ workout optionnel) à un jour
  void assign(int index, String categoryId, [WorkoutModel? workout]) {
    final updated = List<DayPlan>.from(state);
    final isRest = categoryId == 'rest';
    updated[index] = updated[index].copyWith(
      status: isRest ? DayStatus.rest : DayStatus.planned,
      categoryId: categoryId,
      workout: workout,
      clearWorkout: workout == null && !isRest,
    );
    state = updated;
    _save(index);
  }

  // Raccourci utilisé par l'écran d'accueil
  void assignWorkout(int index, WorkoutModel w) =>
      assign(index, w.category, w);

  void remove(int index) {
    final updated = List<DayPlan>.from(state);
    updated[index] = updated[index].copyWith(
      status: DayStatus.empty,
      clearCategory: true,
      clearWorkout: true,
    );
    state = updated;
    _save(index);
  }

  void markDone(int index) {
    final updated = List<DayPlan>.from(state);
    updated[index] = updated[index].copyWith(status: DayStatus.done);
    state = updated;
    _save(index);
  }

  void swap(int a, int b) {
    final updated = List<DayPlan>.from(state);
    final tmp = updated[a];
    updated[a] = DayPlan(
      weekdayIndex: updated[a].weekdayIndex,
      dayShort: updated[a].dayShort,
      dayFull: updated[a].dayFull,
      date: updated[a].date,
      status: updated[b].status,
      categoryId: updated[b].categoryId,
      workout: updated[b].workout,
    );
    updated[b] = DayPlan(
      weekdayIndex: updated[b].weekdayIndex,
      dayShort: updated[b].dayShort,
      dayFull: updated[b].dayFull,
      date: updated[b].date,
      status: tmp.status,
      categoryId: tmp.categoryId,
      workout: tmp.workout,
    );
    state = updated;
    _save(a);
    _save(b);
  }
}

final weeklyPlanProvider =
    NotifierProvider<WeeklyPlanNotifier, List<DayPlan>>(WeeklyPlanNotifier.new);
