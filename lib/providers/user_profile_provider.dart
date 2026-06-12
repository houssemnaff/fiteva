import 'package:flutter_riverpod/legacy.dart';
import 'dart:math';

import '../services/storage_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Computed nutrition targets from profile biometrics
// ─────────────────────────────────────────────────────────────────────────────
class NutritionTargets {
  final int tdeeKcal;
  final int proteinG;
  final int carbsG;
  final int fatG;

  const NutritionTargets({
    required this.tdeeKcal,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
  });

  static const NutritionTargets defaults = NutritionTargets(
    tdeeKcal: 2000,
    proteinG: 108,
    carbsG: 225,
    fatG: 67,
  );

  static NutritionTargets compute({
    required double weightKg,
    required int heightCm,
    required int age,
    required String? frequency,
    required List<String> goals,
    required String? healthStatus,
  }) {
    // Mifflin-St Jeor formula for women
    final bmr = (10 * weightKg) + (6.25 * heightCm) - (5 * age) - 161;

    // Activity multiplier from training frequency
    final double multiplier = switch (frequency) {
      '2 jours' => 1.375,
      '3 jours' => 1.375,
      '4 jours' => 1.55,
      '5 jours' => 1.55,
      '6 jours' => 1.725,
      _ => 1.45,
    };

    int tdee = (bmr * multiplier).round();

    // Adjust for goal
    if (goals.contains('Perte de poids') || goals.contains('Mincir')) {
      tdee = (tdee * 0.85).round(); // -15% cut
    } else if (goals.contains('Prise de masse') || goals.contains('Prendre du volume')) {
      tdee = (tdee + 200).round(); // small surplus
    }

    // Protein target (g/day) — varies by health status and goal
    double proteinRatio;
    if (healthStatus == 'postpartum') {
      proteinRatio = 1.5;
    } else if (healthStatus == 'pregnant') {
      proteinRatio = 1.5;
    } else if (goals.contains('Tonifier') || goals.contains('Prendre de la force')) {
      proteinRatio = 1.9;
    } else {
      proteinRatio = 1.7;
    }
    final int proteinG = (weightKg * proteinRatio).round();

    // Fat: 28% of TDEE → kcal ÷ 9 → grams
    final int fatG = ((tdee * 0.28) / 9).round();

    // Carbs: remaining kcal ÷ 4
    final int carbsG = max(
      50,
      ((tdee - (proteinG * 4) - (fatG * 9)) / 4).round(),
    );

    return NutritionTargets(
      tdeeKcal: tdee,
      proteinG: proteinG,
      carbsG: carbsG,
      fatG: fatG,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// UserProfile — parsed from saved onboarding data
// ─────────────────────────────────────────────────────────────────────────────
class UserProfile {
  final String username;
  final String email;
  final List<String> goals;
  final String? fitnessLevel;
  final String? frequency;
  final int heightCm;
  final double weightKg;
  final int age;

  /// 'cycle' | 'pregnant' | 'postpartum'
  final String? healthStatus;
  final int? pregnancyWeekSA;
  final String? ppRecovery;
  final String? ppDuration;

  final String? cycleDuration;
  final DateTime? lastPeriod;

  final NutritionTargets targets;

  const UserProfile({
    required this.username,
    required this.email,
    required this.goals,
    required this.fitnessLevel,
    required this.frequency,
    required this.heightCm,
    required this.weightKg,
    required this.age,
    required this.healthStatus,
    required this.pregnancyWeekSA,
    required this.ppRecovery,
    required this.ppDuration,
    required this.cycleDuration,
    required this.lastPeriod,
    required this.targets,
  });

  static const UserProfile empty = UserProfile(
    username: '',
    email: '',
    goals: [],
    fitnessLevel: null,
    frequency: null,
    heightCm: 165,
    weightKg: 60.0,
    age: 25,
    healthStatus: null,
    pregnancyWeekSA: null,
    ppRecovery: null,
    ppDuration: null,
    cycleDuration: null,
    lastPeriod: null,
    targets: NutritionTargets.defaults,
  );

  factory UserProfile.fromMap(Map<String, dynamic> m) {
    final int heightCm  = (m['height_cm'] as int?) ?? 165;
    final double weight = (m['weight_kg'] is int)
        ? (m['weight_kg'] as int).toDouble()
        : (m['weight_kg'] as double?) ?? 60.0;
    final int age        = (m['age'] as int?) ?? 25;
    final String? freq   = m['frequency'] as String?;
    final List<String> goals =
        List<String>.from(m['goals'] as List<dynamic>? ?? []);
    final String? status = m['health_status'] as String?;

    DateTime? lastPeriod;
    final lp = m['last_period'] as String?;
    if (lp != null) {
      lastPeriod = DateTime.tryParse(lp);
    }

    final targets = NutritionTargets.compute(
      weightKg:     weight,
      heightCm:     heightCm,
      age:          age,
      frequency:    freq,
      goals:        goals,
      healthStatus: status,
    );

    return UserProfile(
      username:       m['username'] as String? ?? '',
      email:          m['email'] as String? ?? '',
      goals:          goals,
      fitnessLevel:   m['fitness_level'] as String?,
      frequency:      freq,
      heightCm:       heightCm,
      weightKg:       weight,
      age:            age,
      healthStatus:   status,
      pregnancyWeekSA: m['pregnancy_week'] as int?,
      ppRecovery:     m['pp_recovery'] as String?,
      ppDuration:     m['pp_duration'] as String?,
      cycleDuration:  m['cycle_duration'] as String?,
      lastPeriod:     lastPeriod,
      targets:        targets,
    );
  }

  // Predicted next period start date (null if not enough data)
  DateTime? get nextPeriodDate {
    if (lastPeriod == null) return null;
    return lastPeriod!.add(Duration(days: cycleDays));
  }

  int get cycleDays {
    if (cycleDuration == null) return 28;
    final n = int.tryParse(cycleDuration!.replaceAll(RegExp(r'[^0-9]'), ''));
    return n ?? 28;
  }

  // Whether pregnancy/postpartum content should be visible for this user
  bool get showPregnancyContent =>
      healthStatus == 'pregnant' || healthStatus == 'postpartum';

  bool get showCycleContent => healthStatus == 'cycle' || healthStatus == null;
}

// ─────────────────────────────────────────────────────────────────────────────
// Provider — synchronous (SharedPreferences already loaded at app start)
// ─────────────────────────────────────────────────────────────────────────────
final userProfileProvider = StateNotifierProvider<UserProfileNotifier, UserProfile>(
  (ref) => UserProfileNotifier(),
);

class UserProfileNotifier extends StateNotifier<UserProfile> {
  UserProfileNotifier() : super(UserProfile.empty) {
    _load();
  }

  void _load() {
    final data = StorageService.getOnboardingData();
    if (data.isNotEmpty) {
      state = UserProfile.fromMap(data);
    }
  }

  /// Call after onboarding completes or when profile data changes.
  void reload() => _load();

  /// Partial update — persist a single field change without full re-onboarding.
  Future<void> updateField(String key, dynamic value) async {
    final current = StorageService.getOnboardingData();
    current[key] = value;
    await StorageService.saveOnboardingData(current);
    _load();
  }
}
