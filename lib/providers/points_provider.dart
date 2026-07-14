import 'package:fiteva/models/points_model.dart';
import 'package:fiteva/providers/diamonds_provider.dart';
import 'package:fiteva/services/diamonds_service.dart';
import 'package:fiteva/services/points_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

// ── Barème des points (ex-XP + ex-étoiles unifiés) ───────────────────────────
// TOUTES les actions créditent des points ; les diamants ne viennent QUE des
// passages de niveau (voir _addPoints).
class PointsAmounts {
  static const dailyLogin          = 5;
  static const mealLogged          = 8;
  static const cycleTracking       = 10;
  static const symptomAdded        = 3;
  static const healthTipRead       = 2;
  static const profileCompleted    = 15;
  static const streak3DaysBonus    = 20;
  static const streak7DaysBonus    = 50;
  static const streak30DaysBonus   = 100;
  static const pregnancyWeek       = 10;
  static const postpartumTask      = 10;
  static const dailyCheckin        = 5;
  static const painSymptomNoted    = 3;
  static const calorieGoalReached  = 20;
  // Ex-récompenses "étoiles" — donnent désormais des points de progression.
  static const videoWatched        = 10;   // vidéo CorpsZone regardée ≥ 80 %
  static const stepGoalReached     = 50;   // 10 000 pas dans la journée
}

// ── Level badge keys ─────────────────────────────────────────────────────────
const _levelBadgeKeys = [
  '', 'level1', 'level2', 'level3', 'level4', 'level5', 'level6', 'level7',
];

// Plafond quotidien pour les points "repas loggé" — sans ça, ajouter plein de
// petites entrées permettait de farmer des points à l'infini.
const int _maxMealLoggedRewardsPerDay = 4;
const String _mealLoggedReason = 'meal_logged';
// Valeurs de reason conservées à l'identique (héritées de l'époque XP) pour
// que les garde-fous "1×/jour" restent continus à travers la migration.
const String _calorieGoalReason      = 'nutrition_calorie_goal_xp';
const String _pregnancyWeekReason    = 'pregnancy_week_xp';
const String _postpartumTaskReason   = 'postpartum_task_xp';
// rewardDailyCheckin/rewardCycleTracking s'appelaient sans aucun plafond à
// chaque ouverture de l'écran cycle (initState) — naviguer vers/depuis
// l'écran en boucle permettait de farmer des points à l'infini.
const String _dailyCheckinReason     = 'daily_checkin';
const String _cycleTrackingReason    = 'cycle_tracking';
const String _dailyLoginReason       = 'daily_login';
// Ex-récompenses étoiles migrées vers les points.
const String _videoWatchedReason     = 'corpszone_video';
const String _stepGoalReason         = 'step_goal_reached';
const String _workoutExerciseReason  = 'workout_exercise';

class PointsNotifier extends StateNotifier<PointsModel> {
  PointsNotifier(this._ref) : super(const PointsModel()) {
    _initialLoad = _load();
  }

  final Ref _ref;

  /// Chargement initial depuis Supabase. Toute récompense DOIT l'attendre :
  /// sans ça, un reward déclenché au démarrage (ex: rewardDailyLogin dans le
  /// premier frame du home) partait d'un état vide (streak 0, points 0) et
  /// écrasait les vraies valeurs en base.
  late final Future<void> _initialLoad;

  Future<void> _load() async {
    final data = await PointsService.load();
    state = PointsModel(
      totalPoints:        data['totalPoints'] as int,
      streak:             data['streak'] as int,
      lastActiveDate:     data['lastActiveDate'] as String?,
      badges:             List<String>.from(data['badges'] as List),
      challengeProgress:  Map<String, int>.from(data['challengeProgress'] as Map),
      completedChallenges: List<String>.from(data['completedChallenges'] as List),
      loginRewardedToday: data['loginRewardedToday'] as bool,
      totalLoginDays:     data['totalLoginDays'] as int? ?? 0,
    );
  }

  Future<void> reload() => _load();

  Future<void> _save() async {
    await PointsService.save(
      totalPoints:        state.totalPoints,
      streak:             state.streak,
      lastActiveDate:     state.lastActiveDate,
      badges:             state.badges,
      challengeProgress:  state.challengeProgress,
      completedChallenges: state.completedChallenges,
    );
  }

  // ── Core: add points, check level-up (badge + bonus diamants) ─────────────
  Future<void> _addPoints(int amount) async {
    await _initialLoad; // jamais partir d'un état pas encore chargé
    final before = state.level;
    final newPts = state.totalPoints + amount;
    var  badges  = List<String>.from(state.badges);

    state = state.copyWith(totalPoints: newPts);

    final after = state.level;
    if (after > before) {
      if (!badges.contains(_levelBadgeKeys[after])) {
        badges.add(_levelBadgeKeys[after]);
        state = state.copyWith(badges: badges);
      }
      // _save() d'abord : l'upsert de user_xp déclenche le trigger SQL qui
      // crédite les diamants côté serveur. creditLevelUpBonus est un fallback
      // idempotent (ne crédite que si le trigger n'a rien écrit).
      await _save();
      int earnedDiamonds = 0;
      for (int lvl = before + 1; lvl <= after; lvl++) {
        earnedDiamonds += PointsModel.diamondsForLevel(lvl);
        await DiamondsService.creditLevelUpBonus(lvl);
      }
      await _ref.read(diamondsProvider.notifier).loadDiamonds();
      if (earnedDiamonds > 0) {
        state = state.copyWith(recentLevelUpDiamonds: earnedDiamonds);
      }
      return;
    }
    await _save();
  }

  /// L'UI consomme l'animation "+N 💎" du dernier level-up (une seule fois).
  int? consumeLevelUpReward() {
    final diamonds = state.recentLevelUpDiamonds;
    if (diamonds != null) state = state.clearLevelUp();
    return diamonds;
  }

  // ── Streak update (call once per day) ──────────────────────────────────────
  Future<void> _updateStreak() async {
    final today = _todayStr();
    final last  = state.lastActiveDate;
    int newStreak = state.streak;
    var badges    = List<String>.from(state.badges);
    int bonusPts  = 0;

    if (last == null) {
      newStreak = 1;
    } else if (last == today) {
      return; // already counted today
    } else {
      final lastDate  = DateTime.parse(last);
      final todayDate = DateTime.parse(today);
      final diff      = todayDate.difference(lastDate).inDays;
      if (diff == 1) {
        newStreak += 1;
      } else {
        newStreak = 1; // streak broken
      }
    }

    // Streak bonus points + badges
    if (newStreak == 3  && !badges.contains('streak3')) {
      bonusPts += PointsAmounts.streak3DaysBonus;
      badges.add('streak3');
    }
    if (newStreak == 7  && !badges.contains('streak7')) {
      bonusPts += PointsAmounts.streak7DaysBonus;
      badges.add('streak7');
    }
    if (newStreak == 30 && !badges.contains('streak30')) {
      bonusPts += PointsAmounts.streak30DaysBonus;
      badges.add('streak30');
    }

    state = state.copyWith(
      streak: newStreak,
      lastActiveDate: today,
      badges: badges,
    );

    if (bonusPts > 0) await _addPoints(bonusPts);
    await _save();
  }

  // ── Public actions ─────────────────────────────────────────────────────────

  Future<void> rewardDailyLogin() async {
    // Attendre le chargement initial — appelé dès le premier frame du home,
    // souvent AVANT que _load() ait fini (sinon on écrasait le vrai streak).
    await _initialLoad;
    if (state.loginRewardedToday) return;
    // Garde serveur 1×/jour (comme les autres récompenses) : même si l'état
    // local est incohérent (multi-device, cache), pas de double récompense.
    if (await PointsService.hasEarnedReasonToday(_dailyLoginReason)) {
      state = state.copyWith(loginRewardedToday: true);
      return;
    }
    await _updateStreak();
    await _addPoints(PointsAmounts.dailyLogin);
    await PointsService.addPointsHistory(PointsAmounts.dailyLogin, _dailyLoginReason);
    await PointsService.markLoginRewarded();
    state = state.copyWith(loginRewardedToday: true);
    // Le streak et total_login_days sont recalculés côté serveur par le
    // trigger fn_track_login_day — on recharge pour afficher LEURS valeurs.
    await reload();
  }

  /// Récompense un repas loggé — plafonnée à [_maxMealLoggedRewardsPerDay]
  /// par jour pour éviter de farmer des points en ajoutant plein de petites
  /// entrées d'affilée.
  Future<void> rewardMealLogged() async {
    final count = await PointsService.countReasonToday(_mealLoggedReason);
    if (count >= _maxMealLoggedRewardsPerDay) return;
    await _addPoints(PointsAmounts.mealLogged);
    await PointsService.addPointsHistory(PointsAmounts.mealLogged, _mealLoggedReason);
  }

  /// Récompense l'objectif calorique du jour — une seule fois par jour,
  /// quel que soit le nombre de fois où on ajoute/supprime des repas et
  /// re-franchit le seuil. Retourne true si des points viennent d'être crédités.
  Future<bool> rewardCalorieGoalReached() async {
    if (await PointsService.hasEarnedReasonToday(_calorieGoalReason)) return false;
    await _addPoints(PointsAmounts.calorieGoalReached);
    await PointsService.addPointsHistory(PointsAmounts.calorieGoalReached, _calorieGoalReason);
    return true;
  }

  /// Alias conservé pour les écrans nutrition qui créditaient l'objectif
  /// calorique via l'ancien provider étoiles — même garde-fou 1×/jour.
  Future<bool> awardCalorieGoalIfNeeded() => rewardCalorieGoalReached();

  /// Suivi de cycle — 1×/jour (était appelé sans limite à chaque ouverture
  /// de l'écran cycle).
  Future<void> rewardCycleTracking() async {
    if (await PointsService.hasEarnedReasonToday(_cycleTrackingReason)) return;
    await _addPoints(PointsAmounts.cycleTracking);
    await PointsService.addPointsHistory(PointsAmounts.cycleTracking, _cycleTrackingReason);
  }

  /// Check-in quotidien — 1×/jour (même faille corrigée que rewardCycleTracking).
  Future<void> rewardDailyCheckin() async {
    if (await PointsService.hasEarnedReasonToday(_dailyCheckinReason)) return;
    await _addPoints(PointsAmounts.dailyCheckin);
    await PointsService.addPointsHistory(PointsAmounts.dailyCheckin, _dailyCheckinReason);
  }

  Future<void> rewardSymptomAdded()     => _addPoints(PointsAmounts.symptomAdded);
  Future<void> rewardHealthTipRead()    => _addPoints(PointsAmounts.healthTipRead);
  Future<void> rewardProfileCompleted() => _addPoints(PointsAmounts.profileCompleted);

  Future<void> rewardPregnancyWeek() async {
    if (await PointsService.hasEarnedReasonToday(_pregnancyWeekReason)) return;
    await _addPoints(PointsAmounts.pregnancyWeek);
    await PointsService.addPointsHistory(PointsAmounts.pregnancyWeek, _pregnancyWeekReason);
  }

  Future<void> rewardPostpartumTask() async {
    if (await PointsService.hasEarnedReasonToday(_postpartumTaskReason)) return;
    await _addPoints(PointsAmounts.postpartumTask);
    await PointsService.addPointsHistory(PointsAmounts.postpartumTask, _postpartumTaskReason);
  }

  Future<void> rewardPainSymptom()      => _addPoints(PointsAmounts.painSymptomNoted);
  Future<void> addCustomPoints(int amount) => _addPoints(amount);

  /// Vidéo CorpsZone regardée ≥ 80 % — donnait des étoiles, donne maintenant
  /// des points (le garde par-vidéo reste géré côté écran, comme avant).
  Future<void> rewardVideoWatched() async {
    await _addPoints(PointsAmounts.videoWatched);
    await PointsService.addPointsHistory(PointsAmounts.videoWatched, _videoWatchedReason);
  }

  /// Objectif 10 000 pas — 1×/jour, vérifié CÔTÉ SERVEUR (l'ancien système ne
  /// se protégeait qu'avec SharedPreferences, contournable en réinstallant).
  /// Retourne true si les points viennent d'être crédités.
  Future<bool> rewardStepGoalReached() async {
    if (await PointsService.hasEarnedReasonToday(_stepGoalReason)) return false;
    await _addPoints(PointsAmounts.stepGoalReached);
    await PointsService.addPointsHistory(PointsAmounts.stepGoalReached, _stepGoalReason);
    return true;
  }

  /// Points variables d'un exercice de programme terminé (workout.points
  /// réparti par exercice) — l'unicité est garantie par la complétion vidéo
  /// en base (une vidéo déjà terminée ne repasse jamais par ici).
  Future<void> addWorkoutPoints(int amount) async {
    if (amount <= 0) return;
    await _addPoints(amount);
    await PointsService.addPointsHistory(amount, _workoutExerciseReason);
  }

  // ── Challenge progress ─────────────────────────────────────────────────────
  Future<void> incrementChallenge(String key) async {
    if (state.completedChallenges.contains(key)) return;

    final challenge = PointsChallenge.all.firstWhere(
      (c) => c.key == key,
      orElse: () => throw ArgumentError('Unknown challenge: $key'),
    );

    final progress = Map<String, int>.from(state.challengeProgress);
    final current  = (progress[key] ?? 0) + 1;
    progress[key]  = current;

    var completed = List<String>.from(state.completedChallenges);
    var badges    = List<String>.from(state.badges);
    int bonusPts  = 0;

    if (current >= challenge.targetDays) {
      completed.add(key);
      badges.add('challenge_$key');
      bonusPts = challenge.pointsReward;
    }

    state = state.copyWith(
      challengeProgress: progress,
      completedChallenges: completed,
      badges: badges,
    );
    if (bonusPts > 0) await _addPoints(bonusPts);
    await _save();
  }

  static String _todayStr() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }
}

final pointsProvider = StateNotifierProvider<PointsNotifier, PointsModel>((ref) {
  return PointsNotifier(ref);
});
