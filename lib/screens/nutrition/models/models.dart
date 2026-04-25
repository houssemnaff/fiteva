  import 'package:flutter/material.dart';

class MealEntry {
  final String emoji, name, category;
  final int calories;
  const MealEntry(this.emoji, this.name, this.category, this.calories);
}

class MealSection {
  final String emoji, title;
  final List<MealEntry> entries;
  const MealSection(this.emoji, this.title, this.entries);
}

class RecipeItem {
  final String emoji, name, label;
  final Color bgColor;
  const RecipeItem(this.emoji, this.name, this.label, this.bgColor);
}

class MealCategoryData {
  final String imageUrl;
  final String name;
  final String time;
  final int recipeCount;
  final int consumed;
  final int budget;
  final double proteinConsumed;
  final double proteinBudget;

  const MealCategoryData(
    this.imageUrl,
    this.name,
    this.consumed,
    this.budget,
    this.proteinConsumed,
    this.proteinBudget, {
    this.time = '',
    this.recipeCount = 0,
  });

  int get remaining => budget - consumed;
  double get pct => budget > 0 ? (consumed / budget).clamp(0.0, 1.0) : 0.0;
}