import 'package:fiteva/models/xp_model.dart';
import 'package:fiteva/services/xp_service.dart';
import 'package:flutter_riverpod/legacy.dart';

// ── XP amounts ───────────────────────────────────────────────────────────────
class XpAmounts {
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
}

// ── Level badge keys ─────────────────────────────────────────────────────────
const _levelBadgeKeys = ['', 'level1', 'level2', 'level3', 'level4'];

// Plafond quotidien pour l'XP "repas loggé" — sans ça, ajouter plein de
// petites entrées permettait de farmer du XP à l'infini.
const int _maxMealLoggedRewardsPerDay = 4;
const String _mealLoggedReason = 'meal_logged';
const String _calorieGoalXpReason = 'nutrition_calorie_goal_xp';
// rewardPregnancyWeek/rewardPostpartumTask s'appelaient sans aucun plafond à
// chaque ouverture de l'écran grossesse/post-partum (initState) — naviguer
// vers/depuis l'écran en boucle permettait de farmer de l'XP à l'infini.
const String _pregnancyWeekXpReason  = 'pregnancy_week_xp';
const String _postpartumTaskXpReason = 'postpartum_task_xp';

class XpNotifier extends StateNotifier<XpModel> {
  XpNotifier() : super(const XpModel()) {
    _load();
  }

  Future<void> _load() async {
    final data = await XpService.load();
    state = XpModel(
      totalXp:            data['totalXp'] as int,
      streak:             data['streak'] as int,
      lastActiveDate:     data['lastActiveDate'] as String?,
      badges:             List<String>.from(data['badges'] as List),
      challengeProgress:  Map<String, int>.from(data['challengeProgress'] as Map),
      completedChallenges: List<String>.from(data['completedChallenges'] as List),
      loginRewardedToday: data['loginRewardedToday'] as bool,
    );
  }

  Future<void> reload() => _load();

  Future<void> _save() async {
    await XpService.save(
      totalXp:            state.totalXp,
      streak:             state.streak,
      lastActiveDate:     state.lastActiveDate,
      badges:             state.badges,
      challengeProgress:  state.challengeProgress,
      completedChallenges: state.completedChallenges,
    );
  }

  // ── Core: add XP, check level-up badges ────────────────────────────────────
  Future<void> _addXp(int amount) async {
    final before = state.level;
    final newXp  = state.totalXp + amount;
    var  badges  = List<String>.from(state.badges);

    state = state.copyWith(totalXp: newXp);

    // Check if levelled up — award level badge
    final after = state.level;
    if (after > before && !badges.contains(_levelBadgeKeys[after])) {
      badges.add(_levelBadgeKeys[after]);
      state = state.copyWith(badges: badges);
    }
    await _save();
  }

  // ── Streak update (call once per day) ──────────────────────────────────────
  Future<void> _updateStreak() async {
    final today = _todayStr();
    final last  = state.lastActiveDate;
    int newStreak = state.streak;
    var badges    = List<String>.from(state.badges);
    int bonusXp   = 0;

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

    // Streak bonus XP + badges
    if (newStreak == 3  && !badges.contains('streak3')) {
      bonusXp += XpAmounts.streak3DaysBonus;
      badges.add('streak3');
    }
    if (newStreak == 7  && !badges.contains('streak7')) {
      bonusXp += XpAmounts.streak7DaysBonus;
      badges.add('streak7');
    }
    if (newStreak == 30 && !badges.contains('streak30')) {
      bonusXp += XpAmounts.streak30DaysBonus;
      badges.add('streak30');
    }

    state = state.copyWith(
      streak: newStreak,
      lastActiveDate: today,
      badges: badges,
    );

    if (bonusXp > 0) await _addXp(bonusXp);
    await _save();
  }

  // ── Public actions ─────────────────────────────────────────────────────────

  Future<void> rewardDailyLogin() async {
    if (state.loginRewardedToday) return;
    await _updateStreak();
    await _addXp(XpAmounts.dailyLogin);
    await XpService.markLoginRewarded();
    state = state.copyWith(loginRewardedToday: true);
  }

  /// Récompense un repas loggé — plafonnée à [_maxMealLoggedRewardsPerDay]
  /// par jour pour éviter de farmer du XP en ajoutant plein de petites
  /// entrées d'affilée.
  Future<void> rewardMealLogged() async {
    final count = await XpService.countReasonToday(_mealLoggedReason);
    if (count >= _maxMealLoggedRewardsPerDay) return;
    await _addXp(XpAmounts.mealLogged);
    await XpService.addXpHistory(XpAmounts.mealLogged, _mealLoggedReason);
  }

  /// Récompense l'objectif calorique du jour — une seule fois par jour,
  /// quel que soit le nombre de fois où on ajoute/supprime des repas et
  /// re-franchit le seuil. Retourne true si des XP viennent d'être crédités.
  Future<bool> rewardCalorieGoalReached() async {
    if (await XpService.hasEarnedReasonToday(_calorieGoalXpReason)) return false;
    await _addXp(20);
    await XpService.addXpHistory(20, _calorieGoalXpReason);
    return true;
  }
  Future<void> rewardCycleTracking()    => _addXp(XpAmounts.cycleTracking);
  Future<void> rewardSymptomAdded()     => _addXp(XpAmounts.symptomAdded);
  Future<void> rewardHealthTipRead()    => _addXp(XpAmounts.healthTipRead);
  Future<void> rewardProfileCompleted() => _addXp(XpAmounts.profileCompleted);
  Future<void> rewardPregnancyWeek() async {
    if (await XpService.hasEarnedReasonToday(_pregnancyWeekXpReason)) return;
    await _addXp(XpAmounts.pregnancyWeek);
    await XpService.addXpHistory(XpAmounts.pregnancyWeek, _pregnancyWeekXpReason);
  }

  Future<void> rewardPostpartumTask() async {
    if (await XpService.hasEarnedReasonToday(_postpartumTaskXpReason)) return;
    await _addXp(XpAmounts.postpartumTask);
    await XpService.addXpHistory(XpAmounts.postpartumTask, _postpartumTaskXpReason);
  }
  Future<void> rewardDailyCheckin()     => _addXp(XpAmounts.dailyCheckin);
  Future<void> rewardPainSymptom()      => _addXp(XpAmounts.painSymptomNoted);
  Future<void> addCustomXp(int amount)  => _addXp(amount);

  // ── Challenge progress ─────────────────────────────────────────────────────
  Future<void> incrementChallenge(String key) async {
    if (state.completedChallenges.contains(key)) return;

    final challenge = XpChallenge.all.firstWhere(
      (c) => c.key == key,
      orElse: () => throw ArgumentError('Unknown challenge: $key'),
    );

    final progress = Map<String, int>.from(state.challengeProgress);
    final current  = (progress[key] ?? 0) + 1;
    progress[key]  = current;

    var completed = List<String>.from(state.completedChallenges);
    var badges    = List<String>.from(state.badges);
    int bonusXp   = 0;

    if (current >= challenge.targetDays) {
      completed.add(key);
      badges.add('challenge_$key');
      bonusXp = challenge.xpReward;
    }

    state = state.copyWith(
      challengeProgress: progress,
      completedChallenges: completed,
      badges: badges,
    );
    if (bonusXp > 0) await _addXp(bonusXp);
    await _save();
  }

  static String _todayStr() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }
}

final xpProvider = StateNotifierProvider<XpNotifier, XpModel>((ref) {
  return XpNotifier();
});
