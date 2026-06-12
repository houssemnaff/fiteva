// ══════════════════════════════════════════════════════════════════════════════
//  NUTRITION CORE MODELS
// ══════════════════════════════════════════════════════════════════════════════

// ── Meal type ─────────────────────────────────────────────────────────────────
enum MealType {
  breakfast,
  lunch,
  snack,
  dinner;

  String get label => switch (this) {
    MealType.breakfast => 'Petit déjeuner',
    MealType.lunch     => 'Déjeuner',
    MealType.snack     => 'Collation',
    MealType.dinner    => 'Dîner',
  };

  String get id => switch (this) {
    MealType.breakfast => 'breakfast',
    MealType.lunch     => 'lunch',
    MealType.snack     => 'snack',
    MealType.dinner    => 'dinner',
  };

  int get budgetKcal => switch (this) {
    MealType.breakfast => 500,
    MealType.lunch     => 600,
    MealType.snack     => 200,
    MealType.dinner    => 620,
  };

  static MealType fromId(String id) => switch (id) {
    'breakfast' => MealType.breakfast,
    'lunch'     => MealType.lunch,
    'snack'     => MealType.snack,
    'dinner'    => MealType.dinner,
    _           => MealType.lunch,
  };
}

// ── Food category ─────────────────────────────────────────────────────────────
enum FoodCategory {
  viandes,
  poissons,
  oeufslaitiers,
  cereales,
  legumineuses,
  legumes,
  fruits,
  oleagineux,
  corpsGras,
  platCompose,
  boissons,
  desserts;

  String get label => switch (this) {
    FoodCategory.viandes      => 'Viandes & Volailles',
    FoodCategory.poissons     => 'Poissons & Fruits de mer',
    FoodCategory.oeufslaitiers=> 'Œufs & Laitiers',
    FoodCategory.cereales     => 'Céréales & Féculents',
    FoodCategory.legumineuses => 'Légumineuses',
    FoodCategory.legumes      => 'Légumes',
    FoodCategory.fruits       => 'Fruits',
    FoodCategory.oleagineux   => 'Oléagineux & Graines',
    FoodCategory.corpsGras    => 'Corps gras',
    FoodCategory.platCompose  => 'Plats composés',
    FoodCategory.boissons     => 'Boissons',
    FoodCategory.desserts     => 'Desserts',
  };

  String get emoji => switch (this) {
    FoodCategory.viandes      => '🥩',
    FoodCategory.poissons     => '🐟',
    FoodCategory.oeufslaitiers=> '🥚',
    FoodCategory.cereales     => '🌾',
    FoodCategory.legumineuses => '🫘',
    FoodCategory.legumes      => '🥦',
    FoodCategory.fruits       => '🍎',
    FoodCategory.oleagineux   => '🥜',
    FoodCategory.corpsGras    => '🧈',
    FoodCategory.platCompose  => '🥗',
    FoodCategory.boissons     => '🧃',
    FoodCategory.desserts     => '🍰',
  };

}

// ── Food item ─────────────────────────────────────────────────────────────────
class FoodItem {
  final String id;
  final String name;
  final FoodCategory category;

  // Per 100g
  final double kcal;
  final double protein;
  final double carbs;
  final double fat;
  final double fiber;

  // Default serving
  final double defaultGrams;
  final String portionLabel;

  const FoodItem({
    required this.id,
    required this.name,
    required this.category,
    required this.kcal,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.fiber = 0,
    this.defaultGrams = 100,
    this.portionLabel = '100 g',
  });

  // Computed for a given portion
  double kcalFor(double grams)    => kcal    * grams / 100;
  double proteinFor(double grams) => protein * grams / 100;
  double carbsFor(double grams)   => carbs   * grams / 100;
  double fatFor(double grams)     => fat     * grams / 100;
  double fiberFor(double grams)   => fiber   * grams / 100;

  @override
  String toString() => name;
}

// ── Meal entry ────────────────────────────────────────────────────────────────
class MealEntry {
  final String id;
  final FoodItem food;
  final double grams;
  final MealType mealType;
  final DateTime dateTime;

  const MealEntry({
    required this.id,
    required this.food,
    required this.grams,
    required this.mealType,
    required this.dateTime,
  });

  int get calories => food.kcalFor(grams).round();
  int get protein  => food.proteinFor(grams).round();
  int get carbs    => food.carbsFor(grams).round();
  int get fat      => food.fatFor(grams).round();
  int get fiber    => food.fiberFor(grams).round();

  String get dateKey {
    final d = dateTime;
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  MealEntry copyWith({
    String? id, FoodItem? food, double? grams,
    MealType? mealType, DateTime? dateTime,
  }) => MealEntry(
    id:       id       ?? this.id,
    food:     food     ?? this.food,
    grams:    grams    ?? this.grams,
    mealType: mealType ?? this.mealType,
    dateTime: dateTime ?? this.dateTime,
  );
}

// ── Activity level ────────────────────────────────────────────────────────────
enum ActivityLevel {
  sedentary,
  light,
  moderate,
  active,
  veryActive;

  String get label => switch (this) {
    ActivityLevel.sedentary  => 'Sédentaire',
    ActivityLevel.light      => 'Légèrement actif',
    ActivityLevel.moderate   => 'Modérément actif',
    ActivityLevel.active     => 'Actif',
    ActivityLevel.veryActive => 'Très actif',
  };

  double get multiplier => switch (this) {
    ActivityLevel.sedentary  => 1.2,
    ActivityLevel.light      => 1.375,
    ActivityLevel.moderate   => 1.55,
    ActivityLevel.active     => 1.725,
    ActivityLevel.veryActive => 1.9,
  };
}

// ── Goal ─────────────────────────────────────────────────────────────────────
enum NutritionGoal {
  loss,
  maintain,
  gain;

  String get label => switch (this) {
    NutritionGoal.loss     => 'Perte de poids',
    NutritionGoal.maintain => 'Maintien',
    NutritionGoal.gain     => 'Prise de masse',
  };

  int get kcalAdjustment => switch (this) {
    NutritionGoal.loss     => -500,
    NutritionGoal.maintain => 0,
    NutritionGoal.gain     => 300,
  };
}

// ── User profile ──────────────────────────────────────────────────────────────
class UserProfile {
  final String name;
  final int    age;
  final double weightKg;
  final double heightCm;
  final bool   isFemale;
  final ActivityLevel activityLevel;
  final NutritionGoal goal;

  const UserProfile({
    this.name          = '',
    this.age           = 25,
    this.weightKg      = 60.0,
    this.heightCm      = 165.0,
    this.isFemale      = true,
    this.activityLevel = ActivityLevel.moderate,
    this.goal          = NutritionGoal.maintain,
  });

  factory UserProfile.fromOnboardingData(Map<String, dynamic> data) {
    final name     = data['username'] as String? ?? '';
    final age      = data['age'] as int? ?? 25;
    final weight   = (data['weight_kg'] is int)
        ? (data['weight_kg'] as int).toDouble()
        : (data['weight_kg'] as double?) ?? 60.0;
    final height   = (data['height_cm'] is int)
        ? (data['height_cm'] as int).toDouble()
        : (data['height_cm'] as double?) ?? 165.0;

    final freq = data['frequency'] as String?;
    final ActivityLevel activity = switch (freq) {
      '2 jours' || '3 jours' => ActivityLevel.light,
      '4 jours' || '5 jours' => ActivityLevel.moderate,
      '6 jours'              => ActivityLevel.active,
      _                      => ActivityLevel.moderate,
    };

    final goals = List<String>.from(data['goals'] as List<dynamic>? ?? []);
    NutritionGoal goal = NutritionGoal.maintain;
    if (goals.any((g) =>
        g.toLowerCase().contains('poids') ||
        g.toLowerCase().contains('mincir'))) {
      goal = NutritionGoal.loss;
    } else if (goals.any((g) =>
        g.toLowerCase().contains('masse') ||
        g.toLowerCase().contains('volume'))) {
      goal = NutritionGoal.gain;
    }

    return UserProfile(
      name:          name,
      age:           age,
      weightKg:      weight,
      heightCm:      height,
      isFemale:      true,
      activityLevel: activity,
      goal:          goal,
    );
  }

  // Mifflin-St Jeor BMR
  double get bmr => isFemale
      ? 10 * weightKg + 6.25 * heightCm - 5 * age - 161
      : 10 * weightKg + 6.25 * heightCm - 5 * age + 5;

  double get tdee => bmr * activityLevel.multiplier;

  int get dailyKcal => (tdee + goal.kcalAdjustment).round();

  // Macro split (grams)
  int get dailyProtein => switch (goal) {
    NutritionGoal.loss     => (dailyKcal * 0.35 / 4).round(),
    NutritionGoal.maintain => (dailyKcal * 0.30 / 4).round(),
    NutritionGoal.gain     => (dailyKcal * 0.35 / 4).round(),
  };

  int get dailyCarbs => switch (goal) {
    NutritionGoal.loss     => (dailyKcal * 0.35 / 4).round(),
    NutritionGoal.maintain => (dailyKcal * 0.40 / 4).round(),
    NutritionGoal.gain     => (dailyKcal * 0.45 / 4).round(),
  };

  int get dailyFat => switch (goal) {
    NutritionGoal.loss     => (dailyKcal * 0.30 / 9).round(),
    NutritionGoal.maintain => (dailyKcal * 0.30 / 9).round(),
    NutritionGoal.gain     => (dailyKcal * 0.20 / 9).round(),
  };

  int get dailyFiber => 25; // general recommendation

  int get waterGoalMl => (weightKg * 35).round();

  UserProfile copyWith({
    String? name, int? age, double? weightKg, double? heightCm,
    bool? isFemale, ActivityLevel? activityLevel, NutritionGoal? goal,
  }) => UserProfile(
    name:          name          ?? this.name,
    age:           age           ?? this.age,
    weightKg:      weightKg      ?? this.weightKg,
    heightCm:      heightCm      ?? this.heightCm,
    isFemale:      isFemale      ?? this.isFemale,
    activityLevel: activityLevel ?? this.activityLevel,
    goal:          goal          ?? this.goal,
  );
}

// ── Daily totals ──────────────────────────────────────────────────────────────
class DailyTotals {
  final int calories;
  final int protein;
  final int carbs;
  final int fat;
  final int fiber;
  final int entryCount;

  const DailyTotals({
    this.calories   = 0,
    this.protein    = 0,
    this.carbs      = 0,
    this.fat        = 0,
    this.fiber      = 0,
    this.entryCount = 0,
  });

  static DailyTotals from(List<MealEntry> entries) => DailyTotals(
    calories:   entries.fold(0, (s, e) => s + e.calories),
    protein:    entries.fold(0, (s, e) => s + e.protein),
    carbs:      entries.fold(0, (s, e) => s + e.carbs),
    fat:        entries.fold(0, (s, e) => s + e.fat),
    fiber:      entries.fold(0, (s, e) => s + e.fiber),
    entryCount: entries.length,
  );

  DailyTotals forMealType(List<MealEntry> entries, MealType type) {
    final filtered = entries.where((e) => e.mealType == type).toList();
    return DailyTotals.from(filtered);
  }
}
