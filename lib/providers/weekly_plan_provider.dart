import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/home_program_model.dart';
import '../services/supabase_config.dart';
import 'mock_data_provider.dart';

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
  final HomeProgramModel? program;

  const DayPlan({
    required this.weekdayIndex,
    required this.dayShort,
    required this.dayFull,
    required this.date,
    this.status = DayStatus.empty,
    this.categoryId,
    this.program,
  });

  DayPlan copyWith({
    DayStatus? status,
    String? categoryId,
    HomeProgramModel? program,
    bool clearProgram = false,
    bool clearCategory = false,
  }) =>
      DayPlan(
        weekdayIndex: weekdayIndex,
        dayShort: dayShort,
        dayFull: dayFull,
        date: date,
        status: status ?? this.status,
        categoryId: clearCategory ? null : (categoryId ?? this.categoryId),
        program: clearProgram ? null : (program ?? this.program),
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
//
// Persiste uniquement dans Supabase (table user_weekly_plans) — aucun cache
// local (SharedPreferences) : l'état en mémoire est reconstruit à chaque
// démarrage depuis Supabase.
class WeeklyPlanNotifier extends Notifier<List<DayPlan>> {
  static const _shorts = ['LUN', 'MAR', 'MER', 'JEU', 'VEN', 'SAM', 'DIM'];
  static const _fulls = [
    'Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche'
  ];

  late String _weekStart;

  // weekdayIndex → id de programme en attente de résolution (le catalogue de
  // programmes charge en arrière-plan et peut ne pas encore être prêt quand
  // le plan Supabase arrive).
  final Map<int, String> _pendingProgramIds = {};

  // Uid pour lequel l'état en mémoire a été chargé — sert à détecter un
  // changement de compte (connexion/déconnexion/switch) et réinitialiser
  // le plan au lieu de garder celui de l'utilisateur précédent en mémoire.
  String? _loadedUid;
  StreamSubscription? _authSub;

  static String _weekStartKey(DateTime now) {
    final monday = now.subtract(Duration(days: now.weekday - 1));
    return '${monday.year}-${monday.month.toString().padLeft(2, '0')}-${monday.day.toString().padLeft(2, '0')}';
  }

  static HomeProgramModel? _findProgram(List<HomeProgramModel> programs, String id) {
    for (final p in programs) {
      if (p.id == id) return p;
    }
    return null;
  }

  List<DayPlan> _freshWeek() {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    _weekStart = _weekStartKey(now);
    return List.generate(7, (i) => DayPlan(
      weekdayIndex: i,
      dayShort: _shorts[i],
      dayFull: _fulls[i],
      date: monday.add(Duration(days: i)),
    ));
  }

  @override
  List<DayPlan> build() {
    final initial = _freshWeek();
    _loadedUid = SupabaseConfig.userId;

    // Le catalogue de programmes (Supabase, temps réel) peut finir de charger
    // après ce plan — dès qu'il a des données, on résout les ids restés en attente.
    ref.listen(allProgramsProvider, (previous, next) {
      if (next.isEmpty || _pendingProgramIds.isEmpty) return;
      final updated = List<DayPlan>.from(state);
      var changed = false;
      _pendingProgramIds.removeWhere((idx, programId) {
        final program = _findProgram(next, programId);
        if (program == null) return false;
        updated[idx] = updated[idx].copyWith(program: program);
        changed = true;
        return true;
      });
      if (changed) state = updated;
    });

    // Chaque compte doit voir SON plan — si l'utilisateur change (connexion,
    // déconnexion, switch de compte) sans redémarrage complet de l'app, on
    // repart d'une semaine vierge et on recharge pour le nouvel uid.
    _authSub = SupabaseConfig.client.auth.onAuthStateChange.listen((authState) {
      final newUid = authState.session?.user.id;
      if (newUid == _loadedUid) return;
      _loadedUid = newUid;
      _pendingProgramIds.clear();
      state = _freshWeek();
      if (newUid != null) Future.microtask(_loadFromSupabase);
    });
    ref.onDispose(() => _authSub?.cancel());

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
      // Une requête lente peut résoudre après un changement de compte —
      // dans ce cas on jette le résultat pour ne pas écraser le nouveau
      // plan (déjà vierge/rechargé pour le nouvel uid) avec des données
      // de l'utilisateur précédent.
      if (uid != _loadedUid) return;
      if (rows.isEmpty) return;

      final programs = ref.read(allProgramsProvider);
      final updated = List<DayPlan>.from(state);
      for (final r in rows) {
        final idx = r['weekday_index'] as int;
        if (idx < 0 || idx >= 7) continue;
        final statusStr = r['status'] as String? ?? 'empty';
        final status = DayStatus.values.firstWhere(
          (s) => s.name == statusStr,
          orElse: () => DayStatus.empty,
        );
        // La colonne s'appelle workout_id côté base (schéma existant) mais
        // stocke désormais l'id du programme choisi, pas d'un workout isolé.
        final programId = r['workout_id'] as String?;
        HomeProgramModel? program;
        if (programId != null) {
          program = _findProgram(programs, programId);
          if (program == null) {
            // Pas encore chargé — sera résolu par le listener dès que
            // allProgramsProvider aura des données.
            _pendingProgramIds[idx] = programId;
          }
        }
        updated[idx] = updated[idx].copyWith(
          status: status,
          categoryId: r['category_id'] as String?,
          program: program,
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
          'category_id':   day.categoryId ?? day.program?.category,
          'status':        day.status.name,
          'workout_id':    day.program?.id,
        }, onConflict: 'user_id,week_start,weekday_index');
      }
    } catch (e) {
      debugPrint('[WeeklyPlan] _save error: $e');
    }
  }

  // Assigner une catégorie (+ programme optionnel) à un jour
  void assign(int index, String categoryId, [HomeProgramModel? program]) {
    final updated = List<DayPlan>.from(state);
    final isRest = categoryId == 'rest';
    updated[index] = updated[index].copyWith(
      status: isRest ? DayStatus.rest : DayStatus.planned,
      categoryId: categoryId,
      program: program,
      clearProgram: program == null && !isRest,
    );
    state = updated;
    _save(index);
  }

  // Raccourci : assigner directement un programme (catégorie déduite du programme)
  void assignProgram(int index, HomeProgramModel program) =>
      assign(index, program.category, program);

  void remove(int index) {
    final updated = List<DayPlan>.from(state);
    updated[index] = updated[index].copyWith(
      status: DayStatus.empty,
      clearCategory: true,
      clearProgram: true,
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
      program: updated[b].program,
    );
    updated[b] = DayPlan(
      weekdayIndex: updated[b].weekdayIndex,
      dayShort: updated[b].dayShort,
      dayFull: updated[b].dayFull,
      date: updated[b].date,
      status: tmp.status,
      categoryId: tmp.categoryId,
      program: tmp.program,
    );
    state = updated;
    _save(a);
    _save(b);
  }
}

final weeklyPlanProvider =
    NotifierProvider<WeeklyPlanNotifier, List<DayPlan>>(WeeklyPlanNotifier.new);
