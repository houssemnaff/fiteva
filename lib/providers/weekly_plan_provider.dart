import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/home_program_model.dart';
import '../services/supabase_config.dart';
import 'mock_data_provider.dart';
import 'user_profile_provider.dart';
import 'workout_progress_provider.dart';

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

  /// Jour passé, avec un programme planifié, jamais marqué fait — dérivé à
  /// la volée (pas de nouveau statut en base) pour distinguer visuellement
  /// un jour raté d'un jour à venir ou réellement terminé.
  bool get isMissed => isPast && status == DayStatus.planned;
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
  _WeekRolloverObserver? _rolloverObserver;

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

    // L'app peut rester ouverte à travers minuit lundi sans qu'aucune action
    // ne soit faite sur le plan — on vérifie le rollover de semaine à chaque
    // retour au premier plan, pas seulement au prochain build().
    _rolloverObserver = _WeekRolloverObserver(_rolloverIfNeeded);
    WidgetsBinding.instance.addObserver(_rolloverObserver!);
    ref.onDispose(() {
      if (_rolloverObserver != null) {
        WidgetsBinding.instance.removeObserver(_rolloverObserver!);
      }
    });

    // Le statut "done" ne doit pas dépendre uniquement du bouton manuel —
    // dès que toutes les vidéos des séances d'un jour sont réellement
    // terminées (suivi vidéo par vidéo), on marque ce jour comme fait
    // automatiquement, pour que le plan reflète le vrai progrès.
    ref.listen(completedWorkoutsProvider, (previous, next) {
      next.whenData(_syncDoneFromProgress);
    });
    ref.read(completedWorkoutsProvider).whenData(_syncDoneFromProgress);

    Future.microtask(_loadFromSupabase);
    return initial;
  }

  /// Marque automatiquement "done" tout jour "planned" dont le programme
  /// assigné est entièrement complété (tous ses workouts dans
  /// [completedWorkouts]) — synchronise le plan avec le vrai suivi de
  /// progression au lieu de dépendre uniquement du bouton manuel.
  void _syncDoneFromProgress(Set<String> completedWorkouts) {
    if (completedWorkouts.isEmpty) return;
    final updated = List<DayPlan>.from(state);
    final justCompletedIndexes = <int>[];
    for (var i = 0; i < updated.length; i++) {
      final day = updated[i];
      final program = day.program;
      if (day.status != DayStatus.planned || program == null) continue;
      if (program.workouts.isEmpty) continue;
      final allDone = program.workouts.every((w) => completedWorkouts.contains(w.id));
      if (!allDone) continue;
      updated[i] = day.copyWith(status: DayStatus.done);
      justCompletedIndexes.add(i);
    }
    if (justCompletedIndexes.isEmpty) return;
    state = updated;
    for (final i in justCompletedIndexes) {
      _save(i);
    }
  }

  /// Si la semaine calendaire en cours a changé depuis le dernier chargement
  /// (ex: app restée ouverte du dimanche soir au lundi matin), repart d'une
  /// semaine vierge et recharge depuis Supabase pour la nouvelle semaine.
  void _rolloverIfNeeded() {
    final currentWeekStart = _weekStartKey(DateTime.now());
    if (currentWeekStart == _weekStart) return;
    _pendingProgramIds.clear();
    state = _freshWeek();
    Future.microtask(_loadFromSupabase);
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
    _rolloverIfNeeded();
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
    _rolloverIfNeeded();
    final updated = List<DayPlan>.from(state);
    updated[index] = updated[index].copyWith(
      status: DayStatus.empty,
      clearCategory: true,
      clearProgram: true,
    );
    state = updated;
    _save(index);
  }

  /// Génère automatiquement un plan hebdo adapté à la phase du cycle.
  /// Pour chaque jour de la semaine, calcule la phase du cycle à cette date
  /// et assigne un programme compatible. Ajoute des jours de repos pendant
  /// les Règles et espace les programmes pour varier.
  void generateSmartPlan() {
    _rolloverIfNeeded();
    final profile = ref.read(userProfileProvider);
    final programs = ref.read(allProgramsProvider);
    if (programs.isEmpty) return;

    final lastPeriod = profile.lastPeriod;
    final totalDays = profile.cycleDays;
    final isPregnant = profile.healthStatus == 'pregnant';
    final isPostpartum = profile.healthStatus == 'postpartum';

    final updated = List<DayPlan>.from(state);
    final usedIds = <String>{};

    for (var i = 0; i < 7; i++) {
      final day = updated[i];
      // Skip days already done
      if (day.status == DayStatus.done) continue;

      final date = day.date;

      // Determine cycle phase for this specific day
      String phase;
      if (isPregnant) {
        phase = 'Grossesse';
      } else if (isPostpartum) {
        phase = 'Règles'; // gentle recovery
      } else if (lastPeriod == null) {
        phase = 'Folliculaire';
      } else {
        final cycleDay = (date.difference(lastPeriod).inDays % totalDays + 1)
            .clamp(1, totalDays);
        if (cycleDay <= 5) {
          phase = 'Règles';
        } else if (cycleDay <= 13) {
          phase = 'Folliculaire';
        } else if (cycleDay <= 16) {
          phase = 'Ovulation';
        } else {
          phase = 'Lutéale';
        }
      }

      // During Règles: rest on some days (day 1, 3, 5 of the week if in Règles)
      if (phase == 'Règles' && (i % 2 == 1)) {
        updated[i] = day.copyWith(
          status: DayStatus.rest,
          categoryId: 'rest',
          clearProgram: true,
        );
        _save(i);
        continue;
      }

      // Recovery for postpartum
      if (isPostpartum) {
        phase = 'Règles'; // maps to recuperation programs
      }

      // Find compatible programs not yet used this week
      final compatible = programs.where((p) {
        if (p.isPremium) return false; // don't auto-assign locked programs
        if (usedIds.contains(p.id)) return false;
        if (isPregnant) return p.category == 'grossesse';
        if (isPostpartum) return p.category == 'recuperation';
        return p.compatibleCycles.contains(phase);
      }).toList();

      // Fallback: any non-premium program not yet used
      final candidates = compatible.isNotEmpty
          ? compatible
          : programs.where((p) => !p.isPremium && !usedIds.contains(p.id)).toList();

      if (candidates.isEmpty) {
        // All programs used — allow repeats
        final fallback = compatible.isNotEmpty ? compatible : programs.where((p) => !p.isPremium).toList();
        if (fallback.isEmpty) continue;
        final pick = fallback[i % fallback.length];
        updated[i] = day.copyWith(
          status: DayStatus.planned,
          categoryId: pick.category,
          program: pick,
        );
      } else {
        final pick = candidates.first;
        usedIds.add(pick.id);
        updated[i] = day.copyWith(
          status: DayStatus.planned,
          categoryId: pick.category,
          program: pick,
        );
      }
      _save(i);
    }

    state = updated;
  }

  void swap(int a, int b) {
    _rolloverIfNeeded();
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

/// Déclenche [onResume] à chaque retour au premier plan de l'app — utilisé
/// pour détecter un changement de semaine calendaire si l'app est restée
/// ouverte (ou en arrière-plan) à travers minuit lundi.
class _WeekRolloverObserver extends WidgetsBindingObserver {
  final VoidCallback onResume;
  _WeekRolloverObserver(this.onResume);

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) onResume();
  }
}
