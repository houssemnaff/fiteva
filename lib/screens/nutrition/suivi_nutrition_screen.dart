import 'package:fiteva/screens/nutrition/recette_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'ajout_rapide_screen.dart';
import 'models/models.dart';
import 'recipes_list_screen.dart';
import 'theme/app_colors.dart';

// ── We Rise palette ───────────────────────────────────────────────────────────
abstract class _C {
  static const bg       = Color(0xFFFEFEFE);
  static const white    = Colors.white;
  static const border   = Color(0xFFECECEC);
  static const green    = Color(0xFF1C4D30);
  static const greenBg  = Color(0xFFEAF3EC);
  static const mint     = Color(0xFF7ABB98);
  static const textDark = Color(0xFF1A1A1A);
  static const textGrey = Color(0xFF6B7280);
  static const pill     = Color(0xFFF4F4F4);
  static const red      = Color(0xFFE03050);
  static const redBg    = Color(0xFFFFEEEE);
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
// HEADER — We Rise editorial style
// ─────────────────────────────────────────────────────────────────────────────
class _Header extends StatelessWidget {
  final double top;
  final VoidCallback onBack;
  const _Header({required this.top, required this.onBack});

  @override
  Widget build(BuildContext context) => Container(
    color: _C.bg,
    padding: EdgeInsets.fromLTRB(20, top + 14, 20, 12),
    child: Column(children: [
      // Title row
      Row(children: [
        GestureDetector(
          onTap: onBack,
          child: Container(
            width: 38, height: 38,
            decoration: BoxDecoration(
              color: _C.greenBg, borderRadius: BorderRadius.circular(12)),
            child: const Icon(LucideIcons.chevronLeft,
              color: _C.green, size: 20)),
        ),
        const SizedBox(width: 14),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('SUIVI', style: GoogleFonts.inter(
            color: _C.mint, fontSize: 9, fontWeight: FontWeight.w700,
            letterSpacing: 2.5)),
          Text('Nutrition', style: GoogleFonts.outfit(
            color: _C.green, fontSize: 20, fontWeight: FontWeight.w800,
            letterSpacing: -0.4)),
        ]),
        const Spacer(),
      ]),
      const SizedBox(height: 12),
      // Date navigation
      Row(children: [
        _DateArrow(icon: LucideIcons.chevronLeft),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _C.border)),
            child: Row(children: [
              const Icon(LucideIcons.calendarDays, size: 13, color: _C.textGrey),
              const SizedBox(width: 8),
              Expanded(child: Text("Aujourd'hui · Vendredi 25 avril",
                maxLines: 1, overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 13, fontWeight: FontWeight.w500,
                  color: _C.textDark))),
            ]),
          ),
        ),
        const SizedBox(width: 10),
        _DateArrow(icon: LucideIcons.chevronRight),
      ]),
    ]),
  );
}

class _DateArrow extends StatelessWidget {
  final IconData icon;
  const _DateArrow({required this.icon});
  @override
  Widget build(BuildContext context) => Container(
    width: 34, height: 34,
    decoration: BoxDecoration(
      color: Colors.white, shape: BoxShape.circle,
      border: Border.all(color: _C.border)),
    child: Icon(icon, size: 16, color: _C.textGrey),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// RÉSUMÉ JOURNALIER — We Rise editorial
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
    final pct  = (total / goal).clamp(0.0, 1.0);
    final over = remaining < 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _C.border),
        boxShadow: [BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 16, offset: const Offset(0, 4))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        // Overline + number row
        Text('CALORIES DU JOUR', style: GoogleFonts.inter(
          color: _C.mint, fontSize: 9, fontWeight: FontWeight.w700,
          letterSpacing: 2.5)),
        const SizedBox(height: 8),
        Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('$total', style: GoogleFonts.outfit(
            fontSize: 42, fontWeight: FontWeight.w800,
            color: _C.green, height: 1)),
          const SizedBox(width: 6),
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text('/ $goal kcal', style: GoogleFonts.inter(
              fontSize: 14, color: _C.textGrey))),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: over ? _C.redBg : _C.greenBg,
              borderRadius: BorderRadius.circular(20)),
            child: Text(
              over ? '+${-remaining} en surplus' : '$remaining restantes',
              style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700,
                color: over ? _C.red : _C.green))),
        ]),

        const SizedBox(height: 14),

        // Progress bar — thin editorial line
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: pct, minHeight: 5,
            backgroundColor: const Color(0xFFF0F0F0),
            valueColor: AlwaysStoppedAnimation(
              over ? _C.red : _C.green))),

        const SizedBox(height: 14),

        // Macro chips
        Row(children: [
          _MacroStat(label: 'Protéines', value: '20g',
            color: _C.green, bg: _C.greenBg),
          const SizedBox(width: 8),
          _MacroStat(label: 'Glucides',  value: '90g',
            color: const Color(0xFF3B7FD4), bg: const Color(0xFFEBF2FC)),
          const SizedBox(width: 8),
          _MacroStat(label: 'Lipides',   value: '12g',
            color: const Color(0xFFC47A00), bg: const Color(0xFFFFF3DC)),
        ]),
      ]),
    );
  }
}

class _MacroStat extends StatelessWidget {
  final String label, value;
  final Color color, bg;
  const _MacroStat({
    required this.label, required this.value,
    required this.color, required this.bg,
  });
  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: bg, borderRadius: BorderRadius.circular(10)),
      child: Column(children: [
        Text(value, style: GoogleFonts.outfit(
          fontSize: 16, fontWeight: FontWeight.w800, color: color)),
        const SizedBox(height: 1),
        Text(label, style: GoogleFonts.inter(
          fontSize: 10, color: color.withValues(alpha: 0.7))),
      ]),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// SELECTED MEAL DETAIL CARD — We Rise
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
    final over = group.isOver;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _C.border),
        boxShadow: [BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 16, offset: const Offset(0, 4))],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        // ── Hero image 150px ────────────────────────────────────
        SizedBox(
          height: 150, width: double.infinity,
          child: Stack(fit: StackFit.expand, children: [
            Image.network(group.imageUrl, fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  Container(color: _C.greenBg,
                    child: const Center(child: Icon(
                      LucideIcons.salad, color: _C.mint, size: 32)))),

            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter, end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Color(0xCC0A2A18)],
                  stops: [0.2, 1.0]))),

            // Time pill + over badge
            Positioned(top: 12, left: 14, right: 14,
              child: Row(children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3), width: 0.5),
                    borderRadius: BorderRadius.circular(20)),
                  child: Text(group.time, style: GoogleFonts.inter(
                    fontSize: 10, color: Colors.white, fontWeight: FontWeight.w600))),
                const Spacer(),
                if (over) Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: _C.red.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(20)),
                  child: Text('Dépassé', style: GoogleFonts.inter(
                    fontSize: 10, color: Colors.white, fontWeight: FontWeight.w700))),
              ])),

            // Meal name + kcal
            Positioned(bottom: 12, left: 14, right: 14,
              child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Expanded(child: Text(group.title,
                  style: GoogleFonts.outfit(
                    fontSize: 22, fontWeight: FontWeight.w800,
                    color: Colors.white, letterSpacing: -0.4))),
                const SizedBox(width: 8),
                Column(crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min, children: [
                  Text('${group.totalKcal}', style: GoogleFonts.outfit(
                    fontSize: 20, fontWeight: FontWeight.w800,
                    color: Colors.white, height: 1)),
                  Text('/ ${group.budgetKcal} kcal', style: GoogleFonts.inter(
                    fontSize: 10,
                    color: Colors.white.withValues(alpha: 0.7))),
                ]),
              ])),
          ]),
        ),

        // ── Thin progress bar ───────────────────────────────────
        LinearProgressIndicator(
          value: group.pct.clamp(0.0, 1.0), minHeight: 3,
          backgroundColor: _C.border,
          valueColor: AlwaysStoppedAnimation(over ? _C.red : _C.green)),

        // ── Meal list + actions ─────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            if (group.meals.isEmpty)
              _EmptyMealSlot(onAdd: onAdd)
            else ...[
              ...group.meals.map((meal) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _MealEntryRow(meal: meal, onTap: () => onTapMeal(meal)))),
            ],
            const SizedBox(height: 10),
            _AddMealBtn(onTap: onAdd),
            const SizedBox(height: 10),
            _BudgetRow(group: group),
          ]),
        ),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MEAL ENTRY ROW — We Rise
// ─────────────────────────────────────────────────────────────────────────────
class _MealEntryRow extends StatelessWidget {
  final _Meal meal;
  final VoidCallback onTap;
  const _MealEntryRow({required this.meal, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _C.border)),
      child: Row(children: [
        // Thumbnail
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.network(
            meal.imageUrl, width: 48, height: 48, fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              width: 48, height: 48, color: _C.greenBg,
              child: const Center(child: Icon(
                LucideIcons.salad, color: _C.mint, size: 20))))),
        const SizedBox(width: 12),
        // Name + macros
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(meal.name,
            maxLines: 1, overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontSize: 13, fontWeight: FontWeight.w600, color: _C.textDark)),
          const SizedBox(height: 4),
          Row(children: [
            _MiniMacro('P ${meal.protein}g', _C.green, _C.greenBg),
            const SizedBox(width: 4),
            _MiniMacro('G ${meal.carbs}g',
              const Color(0xFF3B7FD4), const Color(0xFFEBF2FC)),
            const SizedBox(width: 4),
            _MiniMacro('L ${meal.fat}g',
              const Color(0xFFC47A00), const Color(0xFFFFF3DC)),
          ]),
        ])),
        // Kcal badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: _C.green, borderRadius: BorderRadius.circular(10)),
          child: Text('${meal.calories}', style: GoogleFonts.outfit(
            fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white))),
      ]),
    ),
  );
}

class _MiniMacro extends StatelessWidget {
  final String label;
  final Color color, bg;
  const _MiniMacro(this.label, this.color, this.bg);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
    child: Text(label, style: GoogleFonts.inter(
      fontSize: 10, fontWeight: FontWeight.w600, color: color)),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// EMPTY SLOT — We Rise
// ─────────────────────────────────────────────────────────────────────────────
class _EmptyMealSlot extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyMealSlot({required this.onAdd});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onAdd,
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: _C.greenBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _C.mint.withValues(alpha: 0.3))),
      child: Column(children: [
        const Icon(LucideIcons.plus, color: _C.green, size: 22),
        const SizedBox(height: 6),
        Text('Ajouter un aliment', style: GoogleFonts.inter(
          fontSize: 13, fontWeight: FontWeight.w600, color: _C.green)),
      ]),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// ADD MEAL BUTTON — We Rise green pill
// ─────────────────────────────────────────────────────────────────────────────
class _AddMealBtn extends StatelessWidget {
  final VoidCallback onTap;
  const _AddMealBtn({required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 13),
      decoration: BoxDecoration(
        color: _C.green, borderRadius: BorderRadius.circular(50),
        boxShadow: [BoxShadow(
          color: _C.green.withValues(alpha: 0.2),
          blurRadius: 12, offset: const Offset(0, 4))]),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(LucideIcons.plus, size: 15, color: Colors.white),
        const SizedBox(width: 7),
        Text('Ajouter un aliment', style: GoogleFonts.inter(
          fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
      ]),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// BUDGET ROW — We Rise
// ─────────────────────────────────────────────────────────────────────────────
class _BudgetRow extends StatelessWidget {
  final _MealGroup group;
  const _BudgetRow({required this.group});
  @override
  Widget build(BuildContext context) {
    final remaining = group.budgetKcal - group.totalKcal;
    final over = remaining < 0;
    return Row(children: [
      Icon(
        over ? LucideIcons.alertTriangle : LucideIcons.checkCircle,
        size: 13, color: over ? _C.red : _C.green),
      const SizedBox(width: 6),
      Text(
        over
            ? '+${-remaining} kcal dépassés pour ce repas'
            : '$remaining kcal restantes pour ce repas',
        style: GoogleFonts.inter(
          fontSize: 12, fontWeight: FontWeight.w600,
          color: over ? _C.red : _C.green)),
    ]);
  }
}

