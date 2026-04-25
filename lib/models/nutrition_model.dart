class MealModel {
  final String id;
  final String name;
  final int calories;
  final String type; // 'breakfast', 'lunch', 'dinner', 'snack'
  final String time;

  MealModel({
    required this.id,
    required this.name,
    required this.calories,
    required this.type,
    required this.time,
  });
}

class NutritionSummary {
  final int currentCalories;
  final int targetCalories;
  final int carbs;
  final int protein;
  final int fat;
  final List<MealModel> meals;

  NutritionSummary({
    required this.currentCalories,
    required this.targetCalories,
    required this.carbs,
    required this.protein,
    required this.fat,
    required this.meals,
  });
}