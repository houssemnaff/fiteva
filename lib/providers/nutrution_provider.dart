  import 'package:flutter_riverpod/legacy.dart';

  import 'user_profile_provider.dart';
  import '../services/nutrition_service.dart';

  // ── Recipe Model ──────────────────────────────────────────────────────────────
  class RecipeModel {
    final String id;
    final String name;
    final int calories;
    final double protein;
    final double carbs;
    final double fat;

    RecipeModel({
      required this.id,
      required this.name,
      required this.calories,
      required this.protein,
      required this.carbs,
      required this.fat,
    });
  }

  // ── Meal Category Model ───────────────────────────────────────────────────────
  class MealCategory {
    final String id;
    final String name;
    final String emoji;
    final int budgetCalories;
    final double budgetProtein;
    final List<RecipeModel> recipes;

    MealCategory({
      required this.id,
      required this.name,
      required this.emoji,
      required this.budgetCalories,
      required this.budgetProtein,
      this.recipes = const [],
    });

    int get totalCalories =>
        recipes.fold(0, (s, r) => s + r.calories);
    double get totalProtein =>
        recipes.fold(0.0, (s, r) => s + r.protein);
    double get totalCarbs =>
        recipes.fold(0.0, (s, r) => s + r.carbs);
    double get totalFat =>
        recipes.fold(0.0, (s, r) => s + r.fat);

    int get remainingCalories => budgetCalories - totalCalories;
    double get remainingProtein => budgetProtein - totalProtein;

    MealCategory copyWith({
      String? name,
      int? budgetCalories,
      double? budgetProtein,
      List<RecipeModel>? recipes,
    }) =>
        MealCategory(
          id:             id,
          name:           name            ?? this.name,
          emoji:          emoji,
          budgetCalories: budgetCalories  ?? this.budgetCalories,
          budgetProtein:  budgetProtein   ?? this.budgetProtein,
          recipes:        recipes         ?? this.recipes,
        );
  }

  // ── Nutrition State ───────────────────────────────────────────────────────────
  class NutritionState {
    final List<MealCategory> categories;
    final int targetCalories;
    final bool isLoading;

    NutritionState({
      required this.categories,
      required this.targetCalories,
      this.isLoading = false,
    });

    int get totalCalories =>
        categories.fold(0, (s, c) => s + c.totalCalories);
    double get totalProtein =>
        categories.fold(0.0, (s, c) => s + c.totalProtein);
    double get totalCarbs =>
        categories.fold(0.0, (s, c) => s + c.totalCarbs);
    double get totalFat =>
        categories.fold(0.0, (s, c) => s + c.totalFat);

    NutritionState copyWith({
      List<MealCategory>? categories,
      int? targetCalories,
      bool? isLoading,
    }) =>
        NutritionState(
          categories:     categories     ?? this.categories,
          targetCalories: targetCalories ?? this.targetCalories,
          isLoading:      isLoading      ?? this.isLoading,
        );
  }

  // ── Notifier ──────────────────────────────────────────────────────────────────
  class NutritionNotifier extends StateNotifier<NutritionState> {
    NutritionNotifier({int initialTarget = 2000})
        : super(NutritionState(
            targetCalories: initialTarget,
            isLoading: true,
            categories: [
              MealCategory(id: 'breakfast', name: 'Petit-déjeuner', emoji: '🌅', budgetCalories: 500,  budgetProtein: 25),
              MealCategory(id: 'lunch',     name: 'Déjeuner',       emoji: '☀️', budgetCalories: 650,  budgetProtein: 40),
              MealCategory(id: 'snack',     name: 'Collation',      emoji: '🍎', budgetCalories: 200,  budgetProtein: 10),
              MealCategory(id: 'dinner',    name: 'Dîner',          emoji: '🌙', budgetCalories: 650,  budgetProtein: 45),
            ],
          )) {
      _loadFromSupabase();
    }

    // ── Chargement initial depuis Supabase ────────────────────────────────────
    Future<void> _loadFromSupabase() async {
      try {
        final rows = await NutritionService.fetchTodayLogs();
        _applyRows(rows);
      } catch (_) {
        // Pas connecté ou table inexistante → on garde les catégories vides
      } finally {
        state = state.copyWith(isLoading: false);
      }
    }

    void _applyRows(List<Map<String, dynamic>> rows) {
      final updated = state.categories.map((cat) {
        final catRows = rows.where((r) => r['meal_category'] == cat.id).toList();
        final recipes = catRows.map((r) => RecipeModel(
          id:       r['id'] as String,
          name:     r['meal_name'] as String,
          calories: (r['calories'] as num).toInt(),
          protein:  (r['protein'] as num).toDouble(),
          carbs:    (r['carbs'] as num).toDouble(),
          fat:      (r['fat'] as num).toDouble(),
        )).toList();
        return cat.copyWith(recipes: recipes);
      }).toList();
      state = state.copyWith(categories: updated);
    }

    Future<void> reload() => _loadFromSupabase();

    // ── Category budget ───────────────────────────────────────────────────────
    void updateBudget(String categoryId, int calories, double protein) {
      state = state.copyWith(
        categories: state.categories.map((c) => c.id == categoryId
            ? c.copyWith(budgetCalories: calories, budgetProtein: protein)
            : c).toList(),
      );
    }

    // ── Add recipe (persist to Supabase) ─────────────────────────────────────
    Future<void> addRecipe(String categoryId, RecipeModel recipe) async {
      // Optimistic update
      state = state.copyWith(
        categories: state.categories.map((c) => c.id == categoryId
            ? c.copyWith(recipes: [...c.recipes, recipe])
            : c).toList(),
      );

      try {
        final id = await NutritionService.addLog(
          category: categoryId,
          name:     recipe.name,
          calories: recipe.calories,
          protein:  recipe.protein,
          carbs:    recipe.carbs,
          fat:      recipe.fat,
        );
        // Replace temp id with real Supabase id
        if (id != null) {
          state = state.copyWith(
            categories: state.categories.map((c) => c.id == categoryId
                ? c.copyWith(
                    recipes: c.recipes.map((r) =>
                      r.id == recipe.id
                        ? RecipeModel(id: id, name: r.name, calories: r.calories,
                                      protein: r.protein, carbs: r.carbs, fat: r.fat)
                        : r
                    ).toList())
                : c).toList(),
          );
        }
      } catch (_) {
        // Rollback si échec Supabase
        state = state.copyWith(
          categories: state.categories.map((c) => c.id == categoryId
              ? c.copyWith(recipes: c.recipes.where((r) => r.id != recipe.id).toList())
              : c).toList(),
        );
      }
    }

    // ── Remove recipe (delete from Supabase) ─────────────────────────────────
    Future<void> removeRecipe(String categoryId, String recipeId) async {
      final removed = state.categories
          .firstWhere((c) => c.id == categoryId)
          .recipes
          .where((r) => r.id == recipeId)
          .toList();

      // Optimistic remove
      state = state.copyWith(
        categories: state.categories.map((c) => c.id == categoryId
            ? c.copyWith(recipes: c.recipes.where((r) => r.id != recipeId).toList())
            : c).toList(),
      );

      try {
        await NutritionService.deleteLog(recipeId);
      } catch (_) {
        // Rollback
        if (removed.isNotEmpty) {
          state = state.copyWith(
            categories: state.categories.map((c) => c.id == categoryId
                ? c.copyWith(recipes: [...c.recipes, ...removed])
                : c).toList(),
          );
        }
      }
    }

    void updateTargetCalories(int target) =>
        state = state.copyWith(targetCalories: target);

    String newId() => DateTime.now().microsecondsSinceEpoch.toString();
  }

  // ── Provider ──────────────────────────────────────────────────────────────────
  final nutritionProvider =
      StateNotifierProvider<NutritionNotifier, NutritionState>((ref) {
    final profile = ref.watch(userProfileProvider);
    return NutritionNotifier(initialTarget: profile.targets.tdeeKcal);
  });
