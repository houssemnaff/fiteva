import 'package:flutter_riverpod/legacy.dart';
import 'dart:math';

import '../services/storage_service.dart';
import '../services/supabase_config.dart';

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
      tdee = (tdee * 0.85).round();
    } else if (goals.contains('Prise de masse') || goals.contains('Prendre du volume')) {
      tdee = (tdee + 200).round();
    }

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
    final int fatG     = ((tdee * 0.28) / 9).round();
    final int carbsG   = max(
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
// UserProfile — parsed from onboarding data (local ou Supabase)
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
  final int? streak;
  final String? level;

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
    required this.targets, this.streak, this.level,
  });

  static const UserProfile empty = UserProfile(
    username: '',
    email: '',
    goals: [],
    fitnessLevel: null,
    frequency: null,
    level: null,
    streak: null,
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
    final int heightCm  = (m['height_cm'] is double)
        ? (m['height_cm'] as double).toInt()
        : (m['height_cm'] as int?) ?? 165;
    final double weight = (m['weight_kg'] is int)
        ? (m['weight_kg'] as int).toDouble()
        : (m['weight_kg'] as double?) ?? 60.0;
    final int age       = (m['age'] is double)
        ? (m['age'] as double).toInt()
        : (m['age'] as int?) ?? 25;
    final String? freq  = m['frequency'] as String?;
    final List<String> goals =
        List<String>.from(m['goals'] as List<dynamic>? ?? []);
    final String? status = m['health_status'] as String?;
    final String? streak = m['streak'] as String?;
    final String? level = m['level'] as String?;

    DateTime? lastPeriod;
    final lp = m['last_period'] as String?;
    if (lp != null) lastPeriod = DateTime.tryParse(lp);

    final targets = NutritionTargets.compute(
      weightKg:     weight,
      heightCm:     heightCm,
      age:          age,
      frequency:    freq,
      goals:        goals,
      healthStatus: status,
    );

    return UserProfile(
      username:        m['username'] as String? ?? '',
      email:           m['email'] as String? ?? '',
      goals:           goals,
      fitnessLevel:    m['fitness_level'] as String?,
      frequency:       freq,
      heightCm:        heightCm,
      weightKg:        weight,
      age:             age,
      healthStatus:    status,
      pregnancyWeekSA: m['pregnancy_week'] as int?,
      ppRecovery:      m['pp_recovery'] as String?,
      ppDuration:      m['pp_duration'] as String?,
      cycleDuration:   m['cycle_duration'] as String?,
      lastPeriod:      lastPeriod,
      targets:         targets,
      level:            level,
      streak:           streak != null ? int.tryParse(streak) : null,
    );
  }

  DateTime? get nextPeriodDate {
    if (lastPeriod == null) return null;
    final today = DateTime.now();
    var next = lastPeriod!.add(Duration(days: cycleDays));
    // Avancer jusqu'à la prochaine occurrence future
    while (next.isBefore(DateTime(today.year, today.month, today.day))) {
      next = next.add(Duration(days: cycleDays));
    }
    return next;
  }

  /// Date de règles prévue la plus récente — peut être aujourd'hui ou dans le passé
  /// (pour détecter un retard). Différent de nextPeriodDate qui avance toujours au futur.
  DateTime? get pendingPeriodDate {
    if (lastPeriod == null) return null;
    final now   = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    var next = lastPeriod!.add(Duration(days: cycleDays));
    // Avancer uniquement si la prochaine occurrence est elle aussi passée
    while (!next.add(Duration(days: cycleDays)).isAfter(today)) {
      next = next.add(Duration(days: cycleDays));
    }
    return next; // peut être <= today (retard) ou >= today (à venir)
  }

  DateTime? get ovulationDate {
    final next = nextPeriodDate;
    if (next == null) return null;
    final now   = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    var ovulation = next.subtract(const Duration(days: 14));
    // Si l'ovulation de ce cycle est déjà passée, passer au cycle suivant
    if (ovulation.isBefore(today)) {
      ovulation = next.add(Duration(days: cycleDays)).subtract(const Duration(days: 14));
    }
    return ovulation;
  }

  int get cycleDays {
    if (cycleDuration == null) return 28;
    final n = int.tryParse(cycleDuration!.replaceAll(RegExp(r'[^0-9]'), ''));
    return n ?? 28;
  }

  bool get showPregnancyContent =>
      healthStatus == 'pregnant' || healthStatus == 'postpartum';

  bool get showCycleContent => healthStatus == 'cycle' || healthStatus == null;
}

// ─────────────────────────────────────────────────────────────────────────────
// Provider — local-first, dual-write vers Supabase
// ─────────────────────────────────────────────────────────────────────────────
final userProfileProvider = StateNotifierProvider<UserProfileNotifier, UserProfile>(
  (ref) => UserProfileNotifier(),
);

class UserProfileNotifier extends StateNotifier<UserProfile> {
  UserProfileNotifier() : super(UserProfile.empty) {
    _loadLocal();
    _refreshFromSupabase();
  }

  // ── Chargement local (instantané au démarrage) ────────────────────────────

  void _loadLocal() {
    final data = StorageService.getOnboardingData();
    if (data.isNotEmpty) state = UserProfile.fromMap(data);
  }

  // ── Chargement Supabase (async, met à jour le state si l'user est connecté) ─

  Future<void> _refreshFromSupabase() async {
    final uid = SupabaseConfig.userId;
    if (uid == null) return;

    try {
      // Profil principal
      final profile = await SupabaseConfig.table('user_profiles')
          .select('username, email, language')
          .eq('id', uid)
          .maybeSingle();

      // Biométrie
      final bio = await SupabaseConfig.table('user_biometrics')
          .select()
          .eq('user_id', uid)
          .maybeSingle();

      // Cycle
      final cycle = await SupabaseConfig.table('user_cycle_settings')
          .select()
          .eq('user_id', uid)
          .maybeSingle();

      if (profile == null && bio == null) return;

      // Fusionne les données Supabase dans la map locale et met à jour
      final merged = <String, dynamic>{
        ...StorageService.getOnboardingData(),
        if (profile != null) ...{
          'username': profile['username'],
          'email':    profile['email'],
        },
        if (bio != null) ...{
          'height_cm':    bio['height_cm'],
          'weight_kg':    bio['weight_kg'],
          'age':          bio['age'],
          'fitness_level': bio['fitness_level'],
          'goals':        bio['goals'] ?? [],
          'health_status': cycle?['health_status'],
          'cycle_duration': cycle?['cycle_duration']?.toString(),
          'last_period':   cycle?['last_period_date'],
          'streak':        cycle?['streak'],
          'level':           cycle?['level'],
        },
      };

      // Persiste localement pour les prochains démarrages hors-ligne
      await StorageService.saveOnboardingData(merged);
      state = UserProfile.fromMap(merged);
    } catch (_) {}
  }

  void reload() {
    _loadLocal();
    _refreshFromSupabase();
  }

  /// Mise à jour d'un champ : dual-write local + Supabase
  Future<void> updateField(String key, dynamic value) async {
    final current = StorageService.getOnboardingData();
    current[key] = value;
    await StorageService.saveOnboardingData(current);
    _loadLocal();
    _syncFieldToSupabase(key, value, current);
  }

  /// Mise à jour de plusieurs champs en une fois
  Future<void> updateFields(Map<String, dynamic> fields) async {
    final current = StorageService.getOnboardingData();
    current.addAll(fields);
    await StorageService.saveOnboardingData(current);
    _loadLocal();
    _syncAllToSupabase(current);
  }

  // ── Sync Supabase ─────────────────────────────────────────────────────────

  void _syncFieldToSupabase(String key, dynamic value, Map<String, dynamic> full) {
    final uid = SupabaseConfig.userId;
    if (uid == null) return;

    // Détermine quelle table mettre à jour selon le champ
    if (_profileKeys.contains(key)) {
      SupabaseConfig.table('user_profiles').upsert({
        'id':         uid,
        key:          value,
        'updated_at': DateTime.now().toIso8601String(),
      }).catchError((_) {});
    } else if (_bioKeys.contains(key)) {
      SupabaseConfig.table('user_biometrics').upsert({
        'user_id':    uid,
        _toBioKey(key): value,
        'updated_at': DateTime.now().toIso8601String(),
      }).catchError((_) {});
    } else if (_cycleKeys.contains(key)) {
      SupabaseConfig.table('user_cycle_settings').upsert({
        'user_id':    uid,
        _toCycleKey(key): value,
        'updated_at': DateTime.now().toIso8601String(),
      }).catchError((_) {});
    }
  }

  void _syncAllToSupabase(Map<String, dynamic> data) {
    final uid = SupabaseConfig.userId;
    if (uid == null) return;

    // user_profiles
    SupabaseConfig.table('user_profiles').upsert({
      'id':         uid,
      if (data['username'] != null) 'username': data['username'],
      if (data['email']    != null) 'email':    data['email'],
      'updated_at': DateTime.now().toIso8601String(),
    }).catchError((_) {});

    // user_biometrics
    final bio = <String, dynamic>{'user_id': uid, 'updated_at': DateTime.now().toIso8601String()};
    if (data['height_cm']    != null) bio['height_cm']         = data['height_cm'];
    if (data['weight_kg']    != null) bio['weight_kg']         = data['weight_kg'];
    if (data['age']          != null) bio['age']               = data['age'];
    if (data['fitness_level'] != null) bio['fitness_level']    = data['fitness_level'];
    if (data['goals']        != null) bio['goals']             = data['goals'];
    if (data['equipment']    != null) bio['equipment']         = data['equipment'];
    if (data['frequency']    != null) bio['frequency_days']    = _freqToDays(data['frequency']);
    if (bio.length > 2) {
      SupabaseConfig.table('user_biometrics').upsert(bio).catchError((_) {});
    }

    // user_cycle_settings
    if (data['health_status'] != null) {
      SupabaseConfig.table('user_cycle_settings').upsert({
        'user_id':          uid,
        'health_status':    data['health_status'],
        if (data['cycle_duration'] != null) 'cycle_duration': int.tryParse(
          (data['cycle_duration'] as String).replaceAll(RegExp(r'[^0-9]'), '')) ?? 28,
        if (data['last_period'] != null) 'last_period_date': data['last_period'],
        'updated_at': DateTime.now().toIso8601String(),
      }).catchError((_) {});
    }

    // user_nutrition_targets
    final t = NutritionTargets.compute(
      weightKg:     (data['weight_kg'] as num?)?.toDouble() ?? 60,
      heightCm:     data['height_cm'] as int? ?? 165,
      age:          data['age'] as int? ?? 25,
      frequency:    data['frequency'] as String?,
      goals:        List<String>.from(data['goals'] as List? ?? []),
      healthStatus: data['health_status'] as String?,
    );
    SupabaseConfig.table('user_nutrition_targets').upsert({
      'user_id':   uid,
      'tdee_kcal': t.tdeeKcal,
      'protein_g': t.proteinG,
      'carbs_g':   t.carbsG,
      'fat_g':     t.fatG,
      'updated_at': DateTime.now().toIso8601String(),
    }).catchError((_) {});
  }

  // ── Helpers de mapping clés locales → colonnes Supabase ──────────────────

  static const _profileKeys = {'username', 'email'};
  static const _bioKeys     = {'height_cm', 'weight_kg', 'age', 'fitness_level', 'goals', 'equipment', 'frequency'};
  static const _cycleKeys   = {'health_status', 'cycle_duration', 'last_period'};

  static String _toBioKey(String k) => switch (k) {
    'frequency' => 'frequency_days',
    _           => k,
  };

  static String _toCycleKey(String k) => switch (k) {
    'last_period'    => 'last_period_date',
    'cycle_duration' => 'cycle_duration',
    _                => k,
  };

  static int _freqToDays(dynamic freq) {
    if (freq == null) return 3;
    final n = int.tryParse(freq.toString().replaceAll(RegExp(r'[^0-9]'), ''));
    return n ?? 3;
  }
}
