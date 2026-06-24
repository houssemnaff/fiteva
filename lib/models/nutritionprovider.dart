/*import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

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

  NutritionState({
    required this.categories,
    required this.targetCalories,
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
  }) =>
      NutritionState(
        categories:     categories     ?? this.categories,
        targetCalories: targetCalories ?? this.targetCalories,
      );
}

// ── Notifier ──────────────────────────────────────────────────────────────────
class NutritionNotifier extends StateNotifier<NutritionState> {
  NutritionNotifier()
      : super(NutritionState(
          targetCalories: 2000,
          categories: [
            MealCategory(
              id: 'breakfast', name: 'Petit-déjeuner',
              emoji: '🌅', budgetCalories: 500, budgetProtein: 25,
              recipes: [
                RecipeModel(id: 'r1', name: 'Oatmeal & Berries',
                    calories: 350, protein: 12, carbs: 60, fat: 6),
              ],
            ),
            MealCategory(
              id: 'lunch', name: 'Déjeuner',
              emoji: '☀️', budgetCalories: 650, budgetProtein: 40,
              recipes: [
                RecipeModel(id: 'r2', name: 'Chicken Salad',
                    calories: 450, protein: 38, carbs: 20, fat: 12),
              ],
            ),
            MealCategory(
              id: 'snack', name: 'Collation',
              emoji: '🍎', budgetCalories: 200, budgetProtein: 10,
              recipes: [
                RecipeModel(id: 'r3', name: 'Protein Shake',
                    calories: 180, protein: 25, carbs: 8, fat: 3),
              ],
            ),
            MealCategory(
              id: 'dinner', name: 'Dîner',
              emoji: '🌙', budgetCalories: 650, budgetProtein: 45,
              recipes: [
                RecipeModel(id: 'r4', name: 'Salmon & Quinoa',
                    calories: 450, protein: 40, carbs: 35, fat: 14),
              ],
            ),
          ],
        ));

  String _uid() => DateTime.now().microsecondsSinceEpoch.toString();

  // ── Category budget ───────────────────────────────────────────────────────
  void updateBudget(String categoryId, int calories, double protein) {
    state = state.copyWith(
      categories: state.categories.map((c) => c.id == categoryId
          ? c.copyWith(budgetCalories: calories, budgetProtein: protein)
          : c).toList(),
    );
  }

  // ── Recipes ───────────────────────────────────────────────────────────────
  void addRecipe(String categoryId, RecipeModel recipe) {
    state = state.copyWith(
      categories: state.categories.map((c) => c.id == categoryId
          ? c.copyWith(recipes: [...c.recipes, recipe])
          : c).toList(),
    );
  }

  void removeRecipe(String categoryId, String recipeId) {
    state = state.copyWith(
      categories: state.categories.map((c) => c.id == categoryId
          ? c.copyWith(
              recipes: c.recipes.where((r) => r.id != recipeId).toList())
          : c).toList(),
    );
  }

  void updateTargetCalories(int target) =>
      state = state.copyWith(targetCalories: target);

  String newId() => _uid();
}

// ── Provider ──────────────────────────────────────────────────────────────────
final nutritionProvider =
    StateNotifierProvider<NutritionNotifier, NutritionState>(
  (ref) => NutritionNotifier(),
);*/