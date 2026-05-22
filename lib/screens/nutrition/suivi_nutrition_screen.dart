import 'package:fiteva/screens/nutrition/recette_detail_screen.dart';
import 'package:flutter/material.dart';
import 'ajout_rapide_screen.dart';
import 'models/models.dart';
import 'recipes_list_screen.dart';
import 'theme/app_colors.dart';

// ─── Tokens locaux ────────────────────────────────────────────────────────────
abstract class _C {
  static const bg = Color(0xFFF5F3EE);
  static const white = Colors.white;
  static const border = Color(0x14000000);
  static const green = Color(0xFF1D9E75);
  static const greenDark = Color(0xFF085041);
  static const greenBg = Color(0xFFE1F5EE);
  static const textDark = Color(0xFF1A1A1A);
  static const textGrey = Color(0xFF888780);
  static const pill = Color(0xFFF1EFE8);
  static const orange = Color(0xFFD85A30);
  static const orangeBg = Color(0xFFFAECE7);
}

// ─── Modèle étendu avec image ─────────────────────────────────────────────────
class _Meal {
  final String name, imageUrl, category;
  final int calories;
  final int protein, carbs, fat;
  const _Meal({
    required this.name,
    required this.imageUrl,
    required this.category,
    required this.calories,
    this.protein = 0,
    this.carbs = 0,
    this.fat = 0,
  });
}

class _MealGroup {
  final String id, title, imageUrl;
  final int budgetKcal;
  final String time;
  final List<_Meal> meals;
  const _MealGroup({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.budgetKcal,
    required this.time,
    this.meals = const [],
  });

  _MealGroup copyWith({
    String? id,
    String? title,
    String? imageUrl,
    int? budgetKcal,
    String? time,
    List<_Meal>? meals,
  }) {
    return _MealGroup(
      id: id ?? this.id,
      title: title ?? this.title,
      imageUrl: imageUrl ?? this.imageUrl,
      budgetKcal: budgetKcal ?? this.budgetKcal,
      time: time ?? this.time,
      meals: meals ?? this.meals,
    );
  }

  int get totalKcal => meals.fold(0, (s, m) => s + m.calories);
  bool get isOver => totalKcal > budgetKcal;
  double get pct => (totalKcal / budgetKcal).clamp(0.0, 1.2);
}

// ─── Données ──────────────────────────────────────────────────────────────────
final _groups = [
  _MealGroup(
    id: 'breakfast',
    title: 'Petit déjeuner',
    time: '08 h 00',
    budgetKcal: 500,
    imageUrl:
        'https://images.unsplash.com/photo-1533089860892-a7c6f0a88666?w=600&q=80',
    meals: [
      _Meal(
        name: 'Riz noir, lait de coco et mangue',
        imageUrl:
            'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=300&q=70',
        category: 'Petit déjeuner',
        calories: 333,
        protein: 8,
        carbs: 62,
        fat: 7,
      ),
    ],
  ),
  _MealGroup(
    id: 'lunch',
    title: 'Déjeuner',
    time: '12 h 30',
    budgetKcal: 600,
    imageUrl:
        'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=600&q=80',
    meals: [
      _Meal(
        name: 'Tiramisu rice cake',
        imageUrl:
            'https://images.unsplash.com/photo-1482049016688-2d3e1b311543?w=300&q=70',
        category: 'Déjeuner',
        calories: 198,
        protein: 12,
        carbs: 28,
        fat: 5,
      ),
    ],
  ),
  _MealGroup(
    id: 'snack',
    title: 'Collation',
    time: '16 h 00',
    budgetKcal: 200,
    imageUrl:
        'https://images.unsplash.com/photo-1482049016688-2d3e1b311543?w=600&q=80',
    meals: [],
  ),
  _MealGroup(
    id: 'dinner',
    title: 'Dîner',
    time: '19 h 30',
    budgetKcal: 620,
    imageUrl:
        'https://images.unsplash.com/photo-1555939594-58d7cb561ad1?w=600&q=80',
    meals: [],
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
// SCREEN PRINCIPAL
// ─────────────────────────────────────────────────────────────────────────────
class SuiviNutritionScreen extends StatefulWidget {
  final String initialMealId;

  const SuiviNutritionScreen({
    super.key,
    this.initialMealId = 'lunch',
  });
  @override
  State<SuiviNutritionScreen> createState() => _SuiviNutritionScreenState();
}

class _SuiviNutritionScreenState extends State<SuiviNutritionScreen> {
  late List<_MealGroup> _mealGroups;
  String _selectedMealId = 'lunch';

  @override
  void initState() {
    super.initState();
    _mealGroups = List<_MealGroup>.from(_groups);
    _selectedMealId = widget.initialMealId;
  }

  _MealGroup get _selectedGroup {
    return _mealGroups.firstWhere(
      (group) => group.id == _selectedMealId,
      orElse: () => _mealGroups.first,
    );
  }

  int get _totalKcal => _mealGroups.fold(0, (s, g) => s + g.totalKcal);
  int get _goalKcal => _mealGroups.fold(0, (s, g) => s + g.budgetKcal);
  int get _remaining => _goalKcal - _totalKcal;

  Future<void> _goToAjout({String? groupId, String? groupTitle}) async {
    final targetGroup = groupId ?? _selectedGroup.id;
    final targetTitle = groupTitle ?? _selectedGroup.title;

    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(builder: (_) => const AjoutRapideScreen()),
    );

    if (result == null) {
      return;
    }

    final meal = _Meal(
      name: (result['name'] as String? ?? '').trim(),
      imageUrl:
          'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=300&q=70',
        category: targetTitle,
      calories: result['calories'] as int? ?? 0,
      protein: result['protein'] as int? ?? 0,
      carbs: result['carbs'] as int? ?? 0,
      fat: result['fat'] as int? ?? 0,
    );

    if (meal.name.isEmpty) {
      return;
    }

    setState(() {
      _mealGroups =
          _mealGroups.map((g) {
            if (g.id != targetGroup) {
              return g;
            }
            return g.copyWith(meals: [...g.meals, meal]);
          }).toList();
      _selectedMealId = targetGroup;
    });
  }

  void _goToRecipes() => Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const RecipesListScreen()),
  );

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    final selectedGroup = _selectedGroup;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      body: Column(
        children: [
          // ── Header ────────────────────────────────────────────
          _Header(top: top, onBack: () => Navigator.pop(context)),

          Expanded(
            child: CustomScrollView(
              slivers: [
                // ── Résumé journalier ──────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: _DailySummaryCard(
                      total: _totalKcal,
                      goal: _goalKcal,
                      remaining: _remaining,
                    ),
                  ),
                ),

                // ── Détail du repas sélectionné ─────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                    child: _SelectedMealDetailCard(
                      group: selectedGroup,
                      onAdd: () => _goToAjout(
                        groupId: selectedGroup.id,
                        groupTitle: selectedGroup.title,
                      ),
                      onTapMeal: (meal) => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => RecipeDetailScreen(recipe: meal),
                        ),
                      ),
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 28)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HEADER
// ─────────────────────────────────────────────────────────────────────────────
class _Header extends StatelessWidget {
  final double top;
  final VoidCallback onBack;
  const _Header({required this.top, required this.onBack});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      color: colorScheme.background,
      padding: EdgeInsets.fromLTRB(20, top + 12, 20, 14),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: onBack,
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.shadow.withOpacity(0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.chevron_left,
                    color: colorScheme.onSurface,
                    size: 22,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Suivi nutrition',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.shadow.withOpacity(0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.info_outline,
                  size: 16,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Nav date
          Row(
            children: [
              _DateArrow(icon: Icons.chevron_left),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.shadow.withOpacity(0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 13,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "Aujourd'hui · Vendredi 25 avril",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              _DateArrow(icon: Icons.chevron_right),
            ],
          ),
        ],
      ),
    );
  }
}

class _DateArrow extends StatelessWidget {
  final IconData icon;
  const _DateArrow({required this.icon});
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(icon, size: 18, color: colorScheme.onSurface),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// RÉSUMÉ JOURNALIER
// ─────────────────────────────────────────────────────────────────────────────
class _DailySummaryCard extends StatelessWidget {
  final int total, goal, remaining;
  const _DailySummaryCard({
    required this.total,
    required this.goal,
    required this.remaining,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final pct = (total / goal).clamp(0.0, 1.0);
    final over = remaining < 0;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.08),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Calories aujourd\'hui',
                      style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '$total',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '/ $goal kcal',
                          style: TextStyle(
                            fontSize: 13,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: over ? colorScheme.tertiaryContainer.withOpacity(0.35) : colorScheme.secondaryContainer.withOpacity(0.35),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: over ? colorScheme.tertiary : colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      over
                          ? '+${-remaining} kcal dépassés'
                          : '$remaining kcal restantes',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: over ? colorScheme.tertiary : colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Barre de progression
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 7,
              backgroundColor: colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation(over ? colorScheme.tertiary : colorScheme.primary),
            ),
          ),

          const SizedBox(height: 14),

          // Macros
          Row(
            children: [
              _MacroStat(label: 'Protéines', value: '20g', color: colorScheme.primary),
              const SizedBox(width: 8),
              _MacroStat(
                label: 'Glucides',
                value: '90g',
                color: colorScheme.secondary,
              ),
              const SizedBox(width: 8),
              _MacroStat(
                label: 'Lipides',
                value: '12g',
                color: colorScheme.tertiary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MacroStat extends StatelessWidget {
  final String label, value;
  final Color color;
  const _MacroStat({
    required this.label,
    required this.value,
    required this.color,
  });
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(fontSize: 10, color: colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SELECTED MEAL DETAIL CARD
// ─────────────────────────────────────────────────────────────────────────────
class _SelectedMealDetailCard extends StatelessWidget {
  final _MealGroup group;
  final VoidCallback onAdd;
  final void Function(_Meal) onTapMeal;

  const _SelectedMealDetailCard({
    required this.group,
    required this.onAdd,
    required this.onTapMeal,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final over = group.isOver;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 140,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  group.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(color: colorScheme.secondaryContainer.withOpacity(0.35)),
                ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        colorScheme.scrim.withOpacity(0.05),
                        colorScheme.scrim.withOpacity(0.55),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.scrim.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          group.time,
                          style: TextStyle(
                            fontSize: 10,
                            color: colorScheme.onPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        group.title,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${group.totalKcal} / ${group.budgetKcal} kcal',
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onPrimary.withOpacity(0.85),
                        ),
                      ),
                    ],
                  ),
                ),
                if (over)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.tertiary.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Dépassé',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
            child: Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: LinearProgressIndicator(
                      value: group.pct.clamp(0.0, 1.0),
                      minHeight: 5,
                      //backgroundColor: _C.pill,
                      backgroundColor: colorScheme.surfaceContainerHighest,
                      valueColor: AlwaysStoppedAnimation(
                        over ? colorScheme.tertiary : colorScheme.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  over
                      ? '+${group.totalKcal - group.budgetKcal} kcal'
                      : '${(group.pct * 100).round()}%',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: over ? colorScheme.tertiary : colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (group.meals.isEmpty)
                  _EmptyMealSlot(onAdd: onAdd)
                else ...[
                  ...group.meals.map(
                    (meal) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _MealEntryRow(
                        meal: meal,
                        onTap: () => onTapMeal(meal),
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 10),
                _AddMealBtn(onTap: onAdd),
                const SizedBox(height: 10),
                _BudgetRow(group: group),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MEAL ENTRY ROW
// ─────────────────────────────────────────────────────────────────────────────
class _MealEntryRow extends StatelessWidget {
  final _Meal meal;
  final VoidCallback onTap;
  const _MealEntryRow({required this.meal, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // Photo
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                meal.imageUrl,
                width: 48,
                height: 48,
                fit: BoxFit.cover,
                errorBuilder:
                    (_, __, ___) => Container(
                      width: 48,
                      height: 48,
                      color: colorScheme.secondaryContainer.withOpacity(0.4),
                      child: const Icon(
                        Icons.restaurant,
                        color: Color(0xFF1D9E75),
                        size: 20,
                      ),
                    ),
              ),
            ),
            const SizedBox(width: 12),
            // Nom + macros
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    meal.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _C.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _MiniMacro('P ${meal.protein}g', _C.green),
                      const SizedBox(width: 4),
                      _MiniMacro('G ${meal.carbs}g', const Color(0xFF378ADD)),
                      const SizedBox(width: 4),
                      _MiniMacro('L ${meal.fat}g', const Color(0xFFBA7517)),
                    ],
                  ),
                ],
              ),
            ),
            // Kcal
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: _C.greenBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${meal.calories} kcal',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _C.greenDark,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniMacro extends StatelessWidget {
  final String label;
  final Color color;
  const _MiniMacro(this.label, this.color);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// EMPTY SLOT
// ─────────────────────────────────────────────────────────────────────────────
class _EmptyMealSlot extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyMealSlot({required this.onAdd});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onAdd,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.shadow.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: const Column(
          children: [
            Icon(Icons.add_circle_outline_rounded, color: _C.green, size: 24),
            SizedBox(height: 6),
            Text(
              'Ajouter un aliment',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: _C.textGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ADD MEAL BUTTON
// ─────────────────────────────────────────────────────────────────────────────
class _AddMealBtn extends StatelessWidget {
  final VoidCallback onTap;
  const _AddMealBtn({required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.35),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.12),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_rounded, size: 16, color: _C.green),
            SizedBox(width: 6),
            Text(
              'Ajouter un aliment',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: _C.greenDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// BUDGET ROW
// ─────────────────────────────────────────────────────────────────────────────
class _BudgetRow extends StatelessWidget {
  final _MealGroup group;
  const _BudgetRow({required this.group});
  @override
  Widget build(BuildContext context) {
    final remaining = group.budgetKcal - group.totalKcal;
    final over = remaining < 0;
    return Row(
      children: [
        Icon(
          over
              ? Icons.warning_amber_rounded
              : Icons.check_circle_outline_rounded,
          size: 14,
          color: over ? Theme.of(context).colorScheme.tertiary : Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: 6),
        Text(
          over
              ? '+${-remaining} kcal dépassés pour ce repas'
              : '$remaining kcal restantes pour ce repas',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: over ? Theme.of(context).colorScheme.tertiary : Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    );
  }
}

