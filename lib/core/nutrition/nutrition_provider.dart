import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'models.dart';
import 'food_database.dart';
import '../../services/storage_service.dart';
import '../../services/supabase_config.dart';
import '../../providers/user_profile_provider.dart' as ap;

// ══════════════════════════════════════════════════════════════════════════════
//  NUTRITION STATE
// ══════════════════════════════════════════════════════════════════════════════
class NutritionState {
  final Map<String, List<MealEntry>> mealsByDate; // 'yyyy-MM-dd' → entries
  final UserProfile userProfile;
  final int waterMlToday;

  const NutritionState({
    this.mealsByDate  = const {},
    this.userProfile  = const UserProfile(),
    this.waterMlToday = 0,
  });

  NutritionState copyWith({
    Map<String, List<MealEntry>>? mealsByDate,
    UserProfile? userProfile,
    int? waterMlToday,
  }) => NutritionState(
    mealsByDate:  mealsByDate  ?? this.mealsByDate,
    userProfile:  userProfile  ?? this.userProfile,
    waterMlToday: waterMlToday ?? this.waterMlToday,
  );
}

// ══════════════════════════════════════════════════════════════════════════════
//  DATE HELPERS
// ══════════════════════════════════════════════════════════════════════════════
String dateKey(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

String get todayKey => dateKey(DateTime.now());

// ══════════════════════════════════════════════════════════════════════════════
//  NUTRITION NOTIFIER
// ══════════════════════════════════════════════════════════════════════════════
// Convertit le profil app (user_profile_provider) → profil nutrition (models.dart)
UserProfile _toNutritionProfile(ap.UserProfile p) {
  final ActivityLevel activity = switch (p.frequency) {
    '2 jours' || '3 jours' => ActivityLevel.light,
    '4 jours' || '5 jours' => ActivityLevel.moderate,
    '6 jours'              => ActivityLevel.active,
    _                      => ActivityLevel.moderate,
  };
  NutritionGoal goal = NutritionGoal.maintain;
  if (p.goals.any((g) => g.toLowerCase().contains('poids') || g.toLowerCase().contains('mincir'))) {
    goal = NutritionGoal.loss;
  } else if (p.goals.any((g) => g.toLowerCase().contains('masse') || g.toLowerCase().contains('volume'))) {
    goal = NutritionGoal.gain;
  }
  return UserProfile(
    name:          p.username,
    age:           p.age,
    weightKg:      p.weightKg,
    heightCm:      p.heightCm.toDouble(),
    isFemale:      true,
    activityLevel: activity,
    goal:          goal,
  );
}

class NutritionNotifier extends Notifier<NutritionState> {
  @override
  NutritionState build() {
    // Écoute les changements de profil (poids, objectifs, etc.)
    // et met à jour les targets nutrition sans réinitialiser les repas
    ref.listen<ap.UserProfile>(ap.userProfileProvider, (_, appProfile) {
      state = state.copyWith(userProfile: _toNutritionProfile(appProfile));
    });

    // Profil initial : priorité au vrai profil Supabase, sinon fallback local
    final appProfile = ref.read(ap.userProfileProvider);
    final profile = appProfile.username.isNotEmpty
        ? _toNutritionProfile(appProfile)
        : () {
            final saved = StorageService.getOnboardingData();
            return saved.isNotEmpty
                ? UserProfile.fromOnboardingData(saved)
                : const UserProfile();
          }();

    Future.microtask(_loadFromSupabase);
    return NutritionState(
      userProfile:  profile,
      mealsByDate:  const {},
      waterMlToday: 0,
    );
  }

  // ── Chargement Supabase ───────────────────────────────────────────────────

  Future<void> _loadFromSupabase() async {
    final uid = SupabaseConfig.userId;
    if (uid == null) return;

    try {
      // Repas d'aujourd'hui
      final rows = await SupabaseConfig.table('user_meal_entries')
          .select()
          .eq('user_id', uid)
          .eq('date', todayKey)
          .order('created_at') as List;

      final entries = rows
          .map((r) => _entryFromRow(r as Map<String, dynamic>))
          .whereType<MealEntry>()
          .toList();

      final updated = Map<String, List<MealEntry>>.from(state.mealsByDate);
      updated[todayKey] = entries;
      state = state.copyWith(mealsByDate: updated);

      // Eau du jour
      final waterRow = await SupabaseConfig.table('user_water_logs')
          .select('water_ml')
          .eq('user_id', uid)
          .eq('date', todayKey)
          .maybeSingle();
      if (waterRow != null) {
        state = state.copyWith(
          waterMlToday: (waterRow['water_ml'] as int? ?? 0)
              .clamp(0, state.userProfile.waterGoalMl),
        );
      }
    } catch (_) {}
  }

  MealEntry? _entryFromRow(Map<String, dynamic> r) {
    final foodId = r['food_id'] as String? ?? '';
    final food = FoodDatabase.all.firstWhere(
      (f) => f.id == foodId,
      orElse: () => FoodItem(
        id:       foodId,
        name:     r['food_name'] as String? ?? foodId,
        category: FoodCategory.platCompose,
        kcal:     (r['kcal_per100'] as num? ?? 0).toDouble(),
        protein:  (r['protein_per100'] as num? ?? 0).toDouble(),
        carbs:    (r['carbs_per100'] as num? ?? 0).toDouble(),
        fat:      (r['fat_per100'] as num? ?? 0).toDouble(),
      ),
    );

    final dt = DateTime.tryParse(r['created_at'] as String? ?? '') ?? DateTime.now();
    return MealEntry(
      id:       r['id'] as String,
      food:     food,
      grams:    (r['grams'] as num).toDouble(),
      mealType: MealType.fromId(r['meal_type'] as String? ?? 'lunch'),
      dateTime: dt,
    );
  }

  // ── Actions ───────────────────────────────────────────────────────────────

  void addMeal(MealEntry entry) {
    final key = entry.dateKey;
    final updated = Map<String, List<MealEntry>>.from(state.mealsByDate);
    updated[key] = [...(updated[key] ?? []), entry];
    state = state.copyWith(mealsByDate: updated);
    _persistMeal(entry);
  }

  void deleteMeal(String entryId, String key) {
    final updated = Map<String, List<MealEntry>>.from(state.mealsByDate);
    updated[key] = (updated[key] ?? []).where((e) => e.id != entryId).toList();
    state = state.copyWith(mealsByDate: updated);
    _deleteMealFromSupabase(entryId);
  }

  void updateProfile(UserProfile profile) =>
      state = state.copyWith(userProfile: profile);

  void setWater(int ml) {
    final clamped = ml.clamp(0, state.userProfile.waterGoalMl);
    state = state.copyWith(waterMlToday: clamped);
    _persistWater(clamped);
  }

  void addWater(int ml) => setWater(state.waterMlToday + ml);

  // ── Supabase writes ───────────────────────────────────────────────────────

  void _persistMeal(MealEntry e) {
    final uid = SupabaseConfig.userId;
    if (uid == null) return;
    SupabaseConfig.table('user_meal_entries').insert({
      'id':             e.id,
      'user_id':        uid,
      'date':           e.dateKey,
      'meal_type':      e.mealType.id,
      'food_id':        e.food.id,
      'food_name':      e.food.name,
      'food_category':  e.food.category.name,
      'grams':          e.grams,
      'kcal_per100':    e.food.kcal,
      'protein_per100': e.food.protein,
      'carbs_per100':   e.food.carbs,
      'fat_per100':     e.food.fat,
      'fiber_per100':   e.food.fiber,
    }).catchError((_) {});
  }

  void _deleteMealFromSupabase(String entryId) {
    final uid = SupabaseConfig.userId;
    if (uid == null) return;
    SupabaseConfig.table('user_meal_entries')
        .delete()
        .eq('id', entryId)
        .eq('user_id', uid)
        .catchError((_) {});
  }

  void _persistWater(int ml) {
    final uid = SupabaseConfig.userId;
    if (uid == null) return;
    SupabaseConfig.table('user_water_logs').upsert({
      'user_id':    uid,
      'date':       todayKey,
      'water_ml':   ml,
      'updated_at': DateTime.now().toIso8601String(),
    }, onConflict: 'user_id,date').catchError((_) {});
  }

  // ── Queries ───────────────────────────────────────────────────────────────

  List<MealEntry> mealsFor(DateTime date) =>
      state.mealsByDate[dateKey(date)] ?? [];

  List<MealEntry> mealsForKey(String key) =>
      state.mealsByDate[key] ?? [];

  List<MealEntry> mealsForMealType(DateTime date, MealType type) =>
      mealsFor(date).where((e) => e.mealType == type).toList();

  DailyTotals totalsFor(DateTime date) =>
      DailyTotals.from(mealsFor(date));

  DailyTotals totalsForType(DateTime date, MealType type) =>
      DailyTotals.from(mealsForMealType(date, type));
}

// ══════════════════════════════════════════════════════════════════════════════
//  PROVIDERS
// ══════════════════════════════════════════════════════════════════════════════

final nutritionProvider =
    NotifierProvider<NutritionNotifier, NutritionState>(NutritionNotifier.new);

final userProfileProvider = Provider<UserProfile>(
  (ref) => ref.watch(nutritionProvider).userProfile,
);

final mealsForDateProvider = Provider.family<List<MealEntry>, String>(
  (ref, key) => ref.watch(nutritionProvider).mealsByDate[key] ?? [],
);

final mealsForTypeProvider =
    Provider.family<List<MealEntry>, ({String dateKey, MealType type})>(
  (ref, args) => ref
      .watch(mealsForDateProvider(args.dateKey))
      .where((e) => e.mealType == args.type)
      .toList(),
);

final dailyTotalsProvider = Provider.family<DailyTotals, String>(
  (ref, key) => DailyTotals.from(ref.watch(mealsForDateProvider(key))),
);

final mealTypeTotalsProvider =
    Provider.family<DailyTotals, ({String dateKey, MealType type})>(
  (ref, args) => DailyTotals.from(ref.watch(mealsForTypeProvider(args))),
);

final waterProvider = Provider<int>(
  (ref) => ref.watch(nutritionProvider).waterMlToday,
);

final todayTotalsProvider = Provider<DailyTotals>(
  (ref) => ref.watch(dailyTotalsProvider(todayKey)),
);
