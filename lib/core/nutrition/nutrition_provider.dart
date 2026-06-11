import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'models.dart';

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
class NutritionNotifier extends Notifier<NutritionState> {
  @override
  NutritionState build() => _initialState();

  // ── Actions ───────────────────────────────────────────────────────────────
  void addMeal(MealEntry entry) {
    final key = entry.dateKey;
    final updated = Map<String, List<MealEntry>>.from(state.mealsByDate);
    updated[key] = [...(updated[key] ?? []), entry];
    state = state.copyWith(mealsByDate: updated);
  }

  void deleteMeal(String entryId, String key) {
    final updated = Map<String, List<MealEntry>>.from(state.mealsByDate);
    updated[key] = (updated[key] ?? []).where((e) => e.id != entryId).toList();
    state = state.copyWith(mealsByDate: updated);
  }

  void updateProfile(UserProfile profile) =>
      state = state.copyWith(userProfile: profile);

  void setWater(int ml) =>
      state = state.copyWith(waterMlToday: ml.clamp(0, state.userProfile.waterGoalMl));

  void addWater(int ml) => setWater(state.waterMlToday + ml);

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

  // ── Mock initial data ─────────────────────────────────────────────────────
  static NutritionState _initialState() {
    // We'll import food_database lazily to avoid circular; use inline values
    final today = todayKey;
    return NutritionState(
      waterMlToday: 1200,
      mealsByDate: {
        today: [
          // Petit déjeuner
          MealEntry(
            id: 'init_1',
            food: _mockFood('flocons_avoine', 'Flocons d\'avoine',
              kcal: 389, protein: 17, carbs: 66, fat: 7),
            grams: 60, mealType: MealType.breakfast,
            dateTime: DateTime.now().copyWith(hour: 8, minute: 0)),
          MealEntry(
            id: 'init_2',
            food: _mockFood('yaourt_grec', 'Yaourt grec (0%)',
              kcal: 59, protein: 10, carbs: 3.6, fat: 0.4),
            grams: 150, mealType: MealType.breakfast,
            dateTime: DateTime.now().copyWith(hour: 8, minute: 5)),
          // Déjeuner
          MealEntry(
            id: 'init_3',
            food: _mockFood('poulet_filet', 'Poulet (filet)',
              kcal: 165, protein: 31, carbs: 0, fat: 3.6),
            grams: 150, mealType: MealType.lunch,
            dateTime: DateTime.now().copyWith(hour: 12, minute: 30)),
          MealEntry(
            id: 'init_4',
            food: _mockFood('riz_blanc', 'Riz blanc (cuit)',
              kcal: 130, protein: 2.7, carbs: 28, fat: 0.3),
            grams: 150, mealType: MealType.lunch,
            dateTime: DateTime.now().copyWith(hour: 12, minute: 30)),
        ],
      },
    );
  }

  static FoodItem _mockFood(String id, String name, {
    required double kcal, required double protein,
    required double carbs, required double fat,
  }) => FoodItem(
    id: id, name: name,
    category: FoodCategory.platCompose,
    kcal: kcal, protein: protein, carbs: carbs, fat: fat,
  );
}

// ══════════════════════════════════════════════════════════════════════════════
//  PROVIDERS
// ══════════════════════════════════════════════════════════════════════════════

// Main state provider
final nutritionProvider =
    NotifierProvider<NutritionNotifier, NutritionState>(NutritionNotifier.new);

// User profile shortcut
final userProfileProvider = Provider<UserProfile>(
  (ref) => ref.watch(nutritionProvider).userProfile,
);

// Meals for a specific date key
final mealsForDateProvider = Provider.family<List<MealEntry>, String>(
  (ref, key) => ref.watch(nutritionProvider).mealsByDate[key] ?? [],
);

// Meals for a specific date + meal type
final mealsForTypeProvider =
    Provider.family<List<MealEntry>, ({String dateKey, MealType type})>(
  (ref, args) => ref
      .watch(mealsForDateProvider(args.dateKey))
      .where((e) => e.mealType == args.type)
      .toList(),
);

// Daily totals for a date key
final dailyTotalsProvider = Provider.family<DailyTotals, String>(
  (ref, key) => DailyTotals.from(ref.watch(mealsForDateProvider(key))),
);

// Totals for a specific meal type on a date
final mealTypeTotalsProvider =
    Provider.family<DailyTotals, ({String dateKey, MealType type})>(
  (ref, args) => DailyTotals.from(ref.watch(mealsForTypeProvider(args))),
);

// Water today
final waterProvider = Provider<int>(
  (ref) => ref.watch(nutritionProvider).waterMlToday,
);

// Today's totals shortcut
final todayTotalsProvider = Provider<DailyTotals>(
  (ref) => ref.watch(dailyTotalsProvider(todayKey)),
);
