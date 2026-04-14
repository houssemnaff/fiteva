import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../providers/mock_data_provider.dart';
import '../../theme/app_theme.dart';
import '../../models/nutrition_model.dart';

class NutritionScreen extends ConsumerWidget {
  const NutritionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nutrition = ref.watch(nutritionProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nutrition'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Calorie Ring
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 200,
                    height: 200,
                    child: CircularProgressIndicator(
                      value: nutrition.currentCalories / nutrition.targetCalories,
                      strokeWidth: 16,
                      color: AppTheme.primaryColor,
                      backgroundColor: Colors.grey.withOpacity(0.2),
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${nutrition.currentCalories}',
                        style: Theme.of(context).textTheme.displayLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '/ ${nutrition.targetCalories} kcal',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // Macros
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMacro(context, 'Carbs', '${nutrition.carbs}g', Colors.orange),
                _buildMacro(context, 'Protein', '${nutrition.protein}g', Colors.red),
                _buildMacro(context, 'Fat', '${nutrition.fat}g', Colors.blue),
              ],
            ),
            const SizedBox(height: 40),

            // Meals List
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Today\'s Meals',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                IconButton(
                  icon: const Icon(LucideIcons.camera, color: AppTheme.primaryColor),
                  onPressed: () {},
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...nutrition.meals.map((meal) => _buildMealCard(context, meal)).toList(),
            
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(LucideIcons.plus),
                label: const Text('Add Food'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMacro(BuildContext context, String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(color: color)),
        const SizedBox(height: 4),
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }

  Widget _buildMealCard(BuildContext context, MealModel meal) {
    IconData icon;
    switch (meal.type) {
      case 'breakfast':
        icon = LucideIcons.sunrise;
        break;
      case 'lunch':
        icon = LucideIcons.sun;
        break;
      case 'dinner':
        icon = LucideIcons.moon;
        break;
      default:
        icon = LucideIcons.apple;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.accentColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppTheme.primaryColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(meal.name, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(meal.time, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey)),
              ],
            ),
          ),
          Text(
            '${meal.calories} kcal',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppTheme.primaryColor),
          ),
        ],
      ),
    );
  }
}
