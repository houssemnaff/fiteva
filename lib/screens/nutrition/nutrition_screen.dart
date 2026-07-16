// ignore_for_file: deprecated_member_use
import 'dart:math' as math;
import 'package:fiteva/core/nutrition/favorites_provider.dart';
import 'package:fiteva/core/nutrition/models.dart' as core;
import 'package:fiteva/core/nutrition/nutrition_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'models/models.dart';
import '../../l10n/app_localizations.dart';
import '../../l10n/lang.dart';
import '../../providers/points_provider.dart';
import '../../widgets/shared_app_header.dart';
import 'suivi_nutrition_screen.dart';
import 'recipes_list_screen.dart';
import 'ajout_rapide_screen.dart';
import 'recette_detail_screen.dart';
import 'recipe_video_screen.dart';

// ── Meal accent palette ──────────────────────────────────────────────────────
const _kMealColorsLight = [Color(0xFFE8A87C), Color(0xFF85CDCA), Color(0xFFD4A5D0), Color(0xFF7FB5D5)];
const _kMealColorsDark  = [Color(0xFFF0B88E), Color(0xFF9AD8D5), Color(0xFFDFB5DB), Color(0xFF92C5E0)];
const _kMealIcons  = [LucideIcons.coffee, LucideIcons.utensils, LucideIcons.apple, LucideIcons.moon];
const _kMealBgs    = [Color(0xFFFDF4EE), Color(0xFFEDF7F6), Color(0xFFF8F0F7), Color(0xFFEEF4F9)];

List<Color> _mealColors(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark ? _kMealColorsDark : _kMealColorsLight;

// ══════════════════════════════════════════════════════════════════════════════
// SCREEN
// ══════════════════════════════════════════════════════════════════════════════
class NutritionHomeScreen extends ConsumerStatefulWidget {
  const NutritionHomeScreen({super.key});
  @override
  ConsumerState<NutritionHomeScreen> createState() => _NutritionHomeScreenState();
}

class _NutritionHomeScreenState extends ConsumerState<NutritionHomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;
  late Animation<double> _anim;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400));
    _anim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic);
    _animCtrl.forward();
  }

  @override
  void dispose() { _animCtrl.dispose(); super.dispose(); }

  bool get _isToday {
    final now = DateTime.now();
    return _selectedDate.year == now.year &&
        _selectedDate.month == now.month &&
        _selectedDate.day == now.day;
  }

  void _goToPrevDay() {
    setState(() => _selectedDate = _selectedDate.subtract(const Duration(days: 1)));
    ref.read(nutritionProvider.notifier).loadForDate(dateKey(_selectedDate));
  }

  void _goToNextDay() {
    if (_isToday) return;
    setState(() => _selectedDate = _selectedDate.add(const Duration(days: 1)));
  }

  void _goToSuivi(String id) => Navigator.push(context,
      MaterialPageRoute(builder: (_) => SuiviNutritionScreen(
        initialMealId: id, initialDate: _selectedDate)));

  void _goToRecipes() => Navigator.push(context,
      MaterialPageRoute(builder: (_) => const RecipesListScreen()));

  void _goToAjout() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context, MaterialPageRoute(builder: (_) => AjoutRapideScreen(targetDate: _selectedDate)));
    if (result == null || !mounted) return;
    final entries = result['entries'] as List<core.MealEntry>?;
    if (entries != null) {
      for (final e in entries) { ref.read(nutritionProvider.notifier).addMeal(e); }
    }
  }

  static String _mealTime(core.MealType t) => switch (t) {
    core.MealType.breakfast => '7h – 9h',
    core.MealType.lunch     => '12h – 14h',
    core.MealType.snack     => '16h – 17h',
    core.MealType.dinner    => '19h – 21h',
  };

  static String _mealImg(core.MealType t) => switch (t) {
    core.MealType.breakfast => 'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=400&q=80',
    core.MealType.lunch     => 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=400&q=80',
    core.MealType.snack     => 'https://images.unsplash.com/photo-1555685812-4b943f1cb0eb?w=400&q=80',
    core.MealType.dinner    => 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=400&q=80',
  };

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final key = dateKey(_selectedDate);
    final totals = ref.watch(dailyTotalsProvider(key));
    final profile = ref.watch(userProfileProvider);
    final l10n = ref.watch(l10nProvider);
    final categories = core.MealType.values.map((t) {
      final entries = ref.watch(mealsForTypeProvider((dateKey: key, type: t)));
      final tt = core.DailyTotals.from(entries);
      return MealCategoryData(
        _mealImg(t), t.labelFor(Lang.code),
        tt.calories, t.budgetKcalFor(profile.dailyKcal),
        tt.protein.toDouble(), tt.carbs.toDouble(),
        time: _mealTime(t), recipeCount: entries.length);
    }).toList();

    final remaining = profile.dailyKcal - totals.calories;
    final over = remaining < 0;
    final pct = profile.dailyKcal > 0
        ? (totals.calories / profile.dailyKcal).clamp(0.0, 1.0) : 0.0;
    final dbRecipes = ref.watch(imageRecipesProvider).asData?.value ?? [];
    final dbVideos = ref.watch(videoRecipesProvider).asData?.value ?? [];

    return Scaffold(
      backgroundColor: cs.surface,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [

          // ══════════════════════════════════════════════════════════
          // SHARED HEADER
          // ══════════════════════════════════════════════════════════
          SharedAppHeader.sliver(
            eyebrow: 'NUTRITION',
            title: l10n.nutritionMyDiet,
            accentColor: cs.primary,
            bgColor: cs.surface,
            actions: [
              Consumer(builder: (ctx, r, _) {
                final n = r.watch(favoritesProvider).length;
                final favColor = cs.primary.withOpacity(0.55);
                return Stack(clipBehavior: Clip.none, children: [
                  GestureDetector(
                    onTap: () => Navigator.push(ctx, MaterialPageRoute(
                      builder: (_) => const _FavoritesScreen())),
                    child: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: favColor.withOpacity(0.10),
                        shape: BoxShape.circle),
                      child: Icon(Icons.favorite_rounded,
                        size: 18, color: favColor))),
                  if (n > 0)
                    Positioned(top: -2, right: -2,
                      child: Container(
                        width: 16, height: 16,
                        decoration: BoxDecoration(
                          color: cs.primary, shape: BoxShape.circle),
                        child: Center(child: Text('$n',
                          style: const TextStyle(color: Colors.white,
                            fontSize: 8, fontWeight: FontWeight.bold))))),
                ]);
              }),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _goToRecipes,
                child: Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: cs.primary.withOpacity(0.10),
                    shape: BoxShape.circle),
                  child: Icon(LucideIcons.chefHat, size: 17, color: cs.primary))),
            ],
            onAvatarTap: () => context.push('/profile'),
          ),

          SliverToBoxAdapter(child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: _DateStrip(
              date: _selectedDate,
              isToday: _isToday,
              onPrev: _goToPrevDay,
              onNext: _isToday ? null : _goToNextDay,
              onReset: _isToday ? null : () => setState(() => _selectedDate = DateTime.now())),
          )),

          // ══════════════════════════════════════════════════════════
          // PLATE SUMMARY
          // ══════════════════════════════════════════════════════════
          SliverToBoxAdapter(child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: GestureDetector(
              onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => SuiviNutritionScreen(initialDate: _selectedDate))),
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                decoration: BoxDecoration(
                  color: cs.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: cs.outline.withOpacity(0.08)),
                  boxShadow: [BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 20, offset: const Offset(0, 6))]),
                child: Column(children: [
                  // Donut ring
                  AnimatedBuilder(
                    animation: _anim,
                    builder: (_, __) => SizedBox(
                      width: 150, height: 150,
                      child: CustomPaint(
                        painter: _PlatePainter(
                          mealPortions: categories.map((c) => c.consumed.toDouble()).toList(),
                          mealColors: _mealColors(context),
                          totalGoal: profile.dailyKcal.toDouble(),
                          animValue: _anim.value,
                          plateColor: cs.surfaceContainerHighest.withOpacity(0.4),
                          plateRimColor: cs.outline.withOpacity(0.08),
                          isDark: Theme.of(context).brightness == Brightness.dark),
                        child: Center(child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('${totals.calories}', style: GoogleFonts.outfit(
                              fontSize: 28, fontWeight: FontWeight.w800,
                              color: cs.onSurface, height: 1)),
                            const SizedBox(height: 2),
                            Text('kcal', style: GoogleFonts.inter(
                              fontSize: 11, fontWeight: FontWeight.w500,
                              color: cs.onSurface.withOpacity(0.4))),
                          ]))))),

                  const SizedBox(height: 16),

                  // Percentage + remaining
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: over
                            ? const Color(0xFFE03050).withOpacity(0.08)
                            : cs.primary.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(20)),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Text('${(pct * 100).round()}%', style: GoogleFonts.outfit(
                          fontSize: 14, fontWeight: FontWeight.w800,
                          color: over ? const Color(0xFFE03050) : cs.primary)),
                        const SizedBox(width: 6),
                        Container(width: 1, height: 12,
                          color: cs.outline.withOpacity(0.1)),
                        const SizedBox(width: 6),
                        Text(
                          over
                              ? '+${-remaining} ${l10n.nutritionKcalOver}'
                              : '$remaining ${l10n.nutritionKcalLeft}',
                          style: GoogleFonts.inter(fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: cs.onSurface.withOpacity(0.5))),
                      ])),
                  ]),

                  const SizedBox(height: 14),

                  // Macros row
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    _CompactMacro('P', totals.protein, profile.dailyProtein, cs),
                    const SizedBox(width: 16),
                    _CompactMacro('G', totals.carbs, profile.dailyCarbs, cs),
                    const SizedBox(width: 16),
                    _CompactMacro('L', totals.fat, profile.dailyFat, cs),
                  ]),

                  const SizedBox(height: 14),

                  // Meal legend
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    ...List.generate(4, (i) => Padding(
                      padding: EdgeInsets.only(right: i < 3 ? 14 : 0),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Container(width: 8, height: 8,
                          decoration: BoxDecoration(
                            color: categories[i].consumed > 0
                                ? _mealColors(context)[i]
                                : _mealColors(context)[i].withOpacity(0.2),
                            shape: BoxShape.circle)),
                        const SizedBox(width: 4),
                        Text(
                          ['Pdj', 'Déj', 'Col', 'Dîn'][i],
                          style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w600,
                            color: categories[i].consumed > 0
                                ? cs.onSurface.withOpacity(0.5)
                                : cs.onSurface.withOpacity(0.2))),
                      ]))),
                  ]),

                  // Chef IA tip
                  const SizedBox(height: 14),
                  Container(height: 1, color: cs.outline.withOpacity(0.06)),
                  const SizedBox(height: 12),
                  _ChefBadge(
                    calories: totals.calories, calorieGoal: profile.dailyKcal,
                    protein: totals.protein, proteinGoal: profile.dailyProtein,
                    carbs: totals.carbs, carbsGoal: profile.dailyCarbs,
                    fat: totals.fat, fatGoal: profile.dailyFat,
                    onAddToMeal: _goToSuivi),
                ]),
              ),
            ),
          )),

          // ══════════════════════════════════════════════════════════
          // MEALS
          // ══════════════════════════════════════════════════════════
          SliverToBoxAdapter(child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
            child: Text('Mes repas', style: GoogleFonts.outfit(
              fontSize: 15, fontWeight: FontWeight.w800,
              color: cs.onSurface, letterSpacing: -0.3)))),

          SliverToBoxAdapter(child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: List.generate(categories.length, (i) {
                final c = categories[i];
                final id = ['breakfast', 'lunch', 'snack', 'dinner'][i];
                return Expanded(child: Padding(
                  padding: EdgeInsets.only(right: i < 3 ? 8 : 0),
                  child: _MealChip(
                    data: c, index: i,
                    onTap: () => _goToSuivi(id)),
                ));
              }),
            ),
          )),

          // ══════════════════════════════════════════════════════════
          // DISCOVER
          // ══════════════════════════════════════════════════════════
          if (dbRecipes.isNotEmpty || dbVideos.isNotEmpty) ...[
            SliverToBoxAdapter(child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 36, 20, 16),
              child: Row(children: [
                Container(width: 28, height: 2,
                  decoration: BoxDecoration(
                    color: cs.primary, borderRadius: BorderRadius.circular(2))),
                const SizedBox(width: 10),
                Text(l10n.nutritionRecipesEyebrow, style: GoogleFonts.inter(
                  fontSize: 9, fontWeight: FontWeight.w700,
                  color: cs.primary, letterSpacing: 3)),
              ]))),

            SliverToBoxAdapter(child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
              child: Row(children: [
                Expanded(child: Text(l10n.nutritionNewRecipes, style: GoogleFonts.outfit(
                  fontSize: 22, fontWeight: FontWeight.w800,
                  color: cs.onSurface, letterSpacing: -0.5))),
                GestureDetector(
                  onTap: _goToRecipes,
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Text(l10n.nutritionSeeAll, style: GoogleFonts.inter(
                      fontSize: 12, fontWeight: FontWeight.w600, color: cs.primary)),
                    const SizedBox(width: 3),
                    Icon(LucideIcons.chevronRight, size: 14, color: cs.primary),
                  ])),
              ]))),

            // Videos
            if (dbVideos.isNotEmpty)
              SliverToBoxAdapter(child: SizedBox(
                height: 200,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  physics: const BouncingScrollPhysics(),
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemCount: dbVideos.length,
                  itemBuilder: (_, i) => _VideoCard(
                    recipe: dbVideos[i],
                    onTap: () => Navigator.push(context, MaterialPageRoute(
                      builder: (_) => RecipeVideoPlayerScreen(recipe: dbVideos[i]))))),
              )),

            if (dbVideos.isNotEmpty && dbRecipes.isNotEmpty)
              const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // Recipes
            if (dbRecipes.isNotEmpty)
              SliverToBoxAdapter(child: SizedBox(
                height: 210,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  physics: const BouncingScrollPhysics(),
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemCount: dbRecipes.take(8).length,
                  itemBuilder: (_, i) {
                    final r = dbRecipes[i];
                    return _RecipeCard(recipe: r, onTap: () {
                      Navigator.of(context, rootNavigator: true).push(
                        MaterialPageRoute(builder: (_) => RecipeDetailScreen(
                          recipe: r.source ?? RecipeItem(
                            r.imageUrl, r.name, r.name, r.accent))));
                    });
                  }),
              )),
          ],

          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// DONUT PAINTER — segmented ring showing each meal's contribution
// ══════════════════════════════════════════════════════════════════════════════
class _PlatePainter extends CustomPainter {
  final List<double> mealPortions;
  final List<Color> mealColors;
  final double totalGoal;
  final double animValue;
  final Color plateColor, plateRimColor;
  final bool isDark;

  _PlatePainter({
    required this.mealPortions, required this.mealColors,
    required this.totalGoal, required this.animValue,
    required this.plateColor, required this.plateRimColor,
    required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final radius = size.width / 2 - 8;
    const strokeW = 14.0;
    final rect = Rect.fromCircle(center: Offset(cx, cy), radius: radius);

    // Track ring
    canvas.drawArc(rect, 0, 2 * math.pi, false,
      Paint()..color = plateColor..style = PaintingStyle.stroke
        ..strokeWidth = strokeW..strokeCap = StrokeCap.round);

    if (totalGoal <= 0) return;

    // Meal segments
    var startAngle = -math.pi / 2;
    final gap = mealPortions.where((p) => p > 0).length > 1 ? 0.04 : 0.0;

    for (int i = 0; i < mealPortions.length; i++) {
      if (mealPortions[i] <= 0) continue;
      final sweep = (mealPortions[i] / totalGoal).clamp(0.0, 1.0) * 2 * math.pi * animValue;
      if (sweep <= 0) continue;

      final segSweep = (sweep - gap).clamp(0.0, sweep);

      canvas.drawArc(rect, startAngle, segSweep, false,
        Paint()..color = mealColors[i]..style = PaintingStyle.stroke
          ..strokeWidth = strokeW..strokeCap = StrokeCap.round);

      startAngle += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _PlatePainter old) =>
      old.animValue != animValue ||
      old.totalGoal != totalGoal ||
      !_listEqual(old.mealPortions, mealPortions);

  static bool _listEqual(List<double> a, List<double> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) { if (a[i] != b[i]) return false; }
    return true;
  }
}
// ══════════════════════════════════════════════════════════════════════════════
// COMPACT MACRO (for summary row)
// ══════════════════════════════════════════════════════════════════════════════
class _CompactMacro extends StatelessWidget {
  final String label;
  final int consumed, goal;
  final ColorScheme cs;
  const _CompactMacro(this.label, this.consumed, this.goal, this.cs);

  @override
  Widget build(BuildContext context) {
    final pct = goal > 0 ? (consumed / goal).clamp(0.0, 1.0) : 0.0;
    final good = pct >= 0.8;
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Text(label, style: GoogleFonts.inter(
        fontSize: 10, fontWeight: FontWeight.w700,
        color: cs.onSurface.withOpacity(0.35))),
      const SizedBox(width: 4),
      Text('${consumed}', style: GoogleFonts.inter(
        fontSize: 11, fontWeight: FontWeight.w700,
        color: good ? cs.primary : cs.onSurface.withOpacity(0.7))),
      Text('/${goal}g', style: GoogleFonts.inter(
        fontSize: 9, color: cs.onSurface.withOpacity(0.3))),
    ]);
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// CHEF BADGE — floating on the donut, shows tip on tap
// ══════════════════════════════════════════════════════════════════════════════
class _ChefBadge extends StatefulWidget {
  final int calories, calorieGoal, protein, proteinGoal;
  final int carbs, carbsGoal, fat, fatGoal;
  final void Function(String mealId) onAddToMeal;
  const _ChefBadge({
    required this.calories, required this.calorieGoal,
    required this.protein, required this.proteinGoal,
    required this.carbs, required this.carbsGoal,
    required this.fat, required this.fatGoal,
    required this.onAddToMeal});

  @override
  State<_ChefBadge> createState() => _ChefBadgeState();
}

class _ChefBadgeState extends State<_ChefBadge> {
  bool _showTip = false;

  static String _currentMealId() {
    final h = DateTime.now().hour;
    if (h < 10) return 'breakfast';
    if (h < 15) return 'lunch';
    if (h < 18) return 'snack';
    return 'dinner';
  }

  static String _mealLabel(String id) => switch (id) {
    'breakfast' => 'Petit déjeuner',
    'lunch'     => 'Déjeuner',
    'snack'     => 'Collation',
    _           => 'Dîner',
  };

  _ChefAdvice get _advice {
    final protDiff = widget.proteinGoal - widget.protein;
    final carbDiff = widget.carbsGoal - widget.carbs;
    final fatDiff = widget.fatGoal - widget.fat;
    final calDiff = widget.calorieGoal - widget.calories;

    if (widget.calories == 0) {
      return _ChefAdvice(
        title: 'Commence ta journée',
        color: const Color(0xFF6B8FD4),
        missing: [],
        suggestions: [
          ('Flocons d\'avoine', '50g · 180 kcal', LucideIcons.wheat),
          ('Œufs brouillés', '2 · 140 kcal', LucideIcons.circle),
          ('Yaourt grec', '150g · 90 kcal', LucideIcons.coffee),
        ]);
    }
    if (calDiff < -200) {
      return _ChefAdvice(
        title: 'Surplus calorique',
        color: const Color(0xFFF59E0B),
        missing: ['${-calDiff} kcal en trop'],
        suggestions: [
          ('Marche rapide', '30 min · −150 kcal', LucideIcons.activity),
          ('Repas léger ce soir', 'salade verte', LucideIcons.salad),
        ]);
    }

    final missing = <String>[];
    final suggestions = <(String, String, IconData)>[];

    if (protDiff > 20) {
      missing.add('${protDiff}g de protéines');
      suggestions.add(('Yaourt grec', '200g · 20g prot', LucideIcons.coffee));
      suggestions.add(('Blanc de poulet', '150g · 46g prot', LucideIcons.drumstick));
      if (protDiff > 40) {
        suggestions.add(('Thon en boîte', '100g · 26g prot', LucideIcons.waves));
      }
    }
    if (carbDiff > 40) {
      missing.add('${carbDiff}g de glucides');
      if (suggestions.length < 3) {
        suggestions.add(('Riz basmati', '80g · 56g gluc', LucideIcons.wheat));
      }
      if (suggestions.length < 3) {
        suggestions.add(('Banane', '1 · 27g gluc', LucideIcons.apple));
      }
    }
    if (fatDiff > 15) {
      missing.add('${fatDiff}g de lipides');
      if (suggestions.length < 3) {
        suggestions.add(('Avocat', '½ · 15g lip', LucideIcons.leaf));
      }
      if (suggestions.length < 3) {
        suggestions.add(('Amandes', '30g · 15g lip', LucideIcons.circle));
      }
    }

    if (missing.isEmpty) {
      return _ChefAdvice(
        title: calDiff.abs() < 100 ? 'Journée parfaite !' : 'Tu es sur la bonne voie',
        color: const Color(0xFF10B981),
        missing: calDiff.abs() < 100 ? [] : ['Encore $calDiff kcal'],
        suggestions: []);
    }

    return _ChefAdvice(
      title: 'Il te manque',
      color: missing.length > 1 ? const Color(0xFFE03050) : const Color(0xFFF59E0B),
      missing: missing,
      suggestions: suggestions.take(3).toList());
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final advice = _advice;
    final hasSuggestions = advice.suggestions.isNotEmpty;

    return GestureDetector(
      onTap: hasSuggestions
          ? () { HapticFeedback.lightImpact(); setState(() => _showTip = !_showTip); }
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Inline tip row
          Row(children: [
            Container(
              width: 28, height: 28,
              decoration: BoxDecoration(
                color: advice.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8)),
              child: Icon(LucideIcons.chefHat, size: 13, color: advice.color)),
            const SizedBox(width: 10),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(advice.title, style: GoogleFonts.inter(
                  fontSize: 12, fontWeight: FontWeight.w700,
                  color: cs.onSurface)),
                if (advice.missing.isNotEmpty)
                  Text(advice.missing.join(' · '), style: GoogleFonts.inter(
                    fontSize: 10, color: cs.onSurface.withOpacity(0.45))),
              ])),
            if (hasSuggestions)
              AnimatedRotation(
                turns: _showTip ? 0.5 : 0,
                duration: const Duration(milliseconds: 200),
                child: Icon(LucideIcons.chevronDown, size: 14,
                  color: cs.onSurface.withOpacity(0.25))),
          ]),

          // Expandable suggestions
          AnimatedCrossFade(
            firstChild: const SizedBox(width: double.infinity),
            secondChild: Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...advice.suggestions.map((s) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(children: [
                      Container(
                        width: 28, height: 28,
                        decoration: BoxDecoration(
                          color: advice.color.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(8)),
                        child: Icon(s.$3, size: 12, color: advice.color)),
                      const SizedBox(width: 10),
                      Expanded(child: Text(s.$1, style: GoogleFonts.inter(
                        fontSize: 12, fontWeight: FontWeight.w600,
                        color: cs.onSurface))),
                      Text(s.$2, style: GoogleFonts.inter(
                        fontSize: 10, color: cs.onSurface.withOpacity(0.35))),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          widget.onAddToMeal(_currentMealId());
                        },
                        child: Container(
                          width: 24, height: 24,
                          decoration: BoxDecoration(
                            color: advice.color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6)),
                          child: Icon(LucideIcons.plus, size: 12, color: advice.color))),
                    ]))),
                ])),
            crossFadeState: _showTip
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200)),
        ],
      ),
    );
  }
}

class _ChefAdvice {
  final String title;
  final Color color;
  final List<String> missing;
  final List<(String, String, IconData)> suggestions;
  const _ChefAdvice({
    required this.title, required this.color,
    required this.missing, required this.suggestions});
}

// ══════════════════════════════════════════════════════════════════════════════
// POINTS STRIP
// ══════════════════════════════════════════════════════════════════════════════
class _PointsStrip extends ConsumerStatefulWidget {
  final int consumed, goal;
  final core.NutritionGoal goalType;
  const _PointsStrip({required this.consumed, required this.goal, required this.goalType});
  @override
  ConsumerState<_PointsStrip> createState() => _PointsStripState();
}

class _PointsStripState extends ConsumerState<_PointsStrip> {
  bool _checked = false;

  @override
  void initState() { super.initState(); WidgetsBinding.instance.addPostFrameCallback((_) => _award()); }
  @override
  void didUpdateWidget(covariant _PointsStrip old) { super.didUpdateWidget(old); _award(); }

  static bool _reached(int c, int g, core.NutritionGoal t) {
    if (g <= 0) return false;
    return switch (t) {
      core.NutritionGoal.loss     => c >= g * 0.85 && c <= g,
      core.NutritionGoal.maintain => c >= g * 0.9  && c <= g * 1.1,
      core.NutritionGoal.gain     => c >= g,
    };
  }

  void _award() {
    if (!_reached(widget.consumed, widget.goal, widget.goalType) || _checked) return;
    _checked = true;
    ref.read(pointsProvider.notifier).awardCalorieGoalIfNeeded();
  }

  @override
  Widget build(BuildContext context) {
    final r = _reached(widget.consumed, widget.goal, widget.goalType);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(r ? 0.12 : 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(r ? 0.2 : 0.06))),
      child: Row(children: [
        Container(
          width: 28, height: 28,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8)),
          child: Center(child: Text(r ? '🏆' : '⭐', style: const TextStyle(fontSize: 13)))),
        const SizedBox(width: 10),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              r ? 'Objectif atteint !' : 'Log tes repas du jour',
              style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700,
                color: Colors.white.withOpacity(0.9))),
            Text(
              r ? 'Tu as gagné +20 points 🎉' : 'Gagne +20 points',
              style: GoogleFonts.inter(fontSize: 10,
                color: Colors.white.withOpacity(0.5))),
          ])),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: r ? Colors.white.withOpacity(0.15) : Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(10)),
          child: Text('+20 pts', style: GoogleFonts.outfit(
            fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white))),
      ]));
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// DATE BAR
// ══════════════════════════════════════════════════════════════════════════════
class _DateStrip extends StatelessWidget {
  final DateTime date;
  final bool isToday;
  final VoidCallback onPrev;
  final VoidCallback? onNext, onReset;
  const _DateStrip({required this.date, required this.isToday,
    required this.onPrev, this.onNext, this.onReset});

  static const _months = ['jan', 'fév', 'mar', 'avr', 'mai', 'jun',
                           'jul', 'aoû', 'sep', 'oct', 'nov', 'déc'];
  static const _days = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final label = isToday
        ? "Aujourd'hui"
        : '${_days[date.weekday - 1]} ${date.day} ${_months[date.month - 1]}';

    return Row(children: [
      GestureDetector(
        onTap: onPrev,
        child: Icon(LucideIcons.chevronLeft, size: 16,
          color: cs.onSurface.withOpacity(0.4))),
      const SizedBox(width: 8),
      GestureDetector(
        onTap: onReset,
        child: Text(label, style: GoogleFonts.inter(fontSize: 12,
          fontWeight: FontWeight.w600, color: cs.onSurface.withOpacity(0.6)))),
      if (!isToday) ...[
        const SizedBox(width: 6),
        GestureDetector(
          onTap: onReset,
          child: Text("·  Aujourd'hui", style: GoogleFonts.inter(
            fontSize: 10, fontWeight: FontWeight.w600, color: cs.primary))),
      ],
      const Spacer(),
      GestureDetector(
        onTap: onNext,
        child: Icon(LucideIcons.chevronRight, size: 16,
          color: cs.onSurface.withOpacity(isToday ? 0.1 : 0.4))),
    ]);
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// MEAL ROW
// ══════════════════════════════════════════════════════════════════════════════
class _MealChip extends StatelessWidget {
  final MealCategoryData data;
  final int index;
  final VoidCallback onTap;
  const _MealChip({required this.data, required this.index, required this.onTap});

  static const _shortFr = ['P.déj', 'Déj', 'Collat.', 'Dîner'];
  static const _namesFr = ['Petit déjeuner', 'Déjeuner', 'Collation', 'Dîner'];
  static const _namesEn = ['Breakfast', 'Lunch', 'Snack', 'Dinner'];

  int get _idx {
    int i = _namesFr.indexOf(data.name);
    if (i == -1) i = _namesEn.indexOf(data.name);
    return i.clamp(0, 3);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final idx = _idx;
    final accent = _mealColors(context)[idx];
    final icon = _kMealIcons[idx];
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? accent.withOpacity(0.12) : _kMealBgs[idx];
    final empty = data.consumed == 0;
    final pct = data.pct.clamp(0.0, 1.0);
    final over = data.remaining < 0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: accent.withOpacity(0.15))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: accent),
            const SizedBox(height: 4),
            Text(_shortFr[idx], style: GoogleFonts.outfit(
              fontSize: 10, fontWeight: FontWeight.w700,
              color: cs.onSurface)),
            const SizedBox(height: 4),
            if (!empty) ...[
              Text('${data.consumed}', style: GoogleFonts.inter(
                fontSize: 12, fontWeight: FontWeight.w700, color: accent)),
              Text('kcal', style: GoogleFonts.inter(
                fontSize: 8, color: cs.onSurface.withOpacity(0.4))),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: SizedBox(
                  height: 3, width: 32,
                  child: LinearProgressIndicator(
                    value: pct,
                    backgroundColor: cs.surfaceContainerHighest.withOpacity(0.4),
                    valueColor: AlwaysStoppedAnimation(
                      over ? const Color(0xFFE03050) : accent)))),
            ],
            if (empty) ...[
              const SizedBox(height: 2),
              Icon(LucideIcons.plus, size: 14, color: accent.withOpacity(0.6)),
            ],
          ]),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// VIDEO CARD (discover section)
// ══════════════════════════════════════════════════════════════════════════════
class _VideoCard extends StatelessWidget {
  final VideoRecipe recipe;
  final VoidCallback onTap;
  const _VideoCard({required this.recipe, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final pi = PhaseInfo.from(recipe.phase);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 260,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20, offset: const Offset(0, 6))]),
        clipBehavior: Clip.antiAlias,
        child: Stack(fit: StackFit.expand, children: [
          Image.network(recipe.imageUrl, fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(color: cs.primary.withOpacity(0.06))),
          const DecoratedBox(decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter, end: Alignment.bottomCenter,
              stops: [0.0, 0.4, 1.0],
              colors: [Color(0x00000000), Color(0x33000000), Color(0xCC000000)]))),
          // Play
          Center(child: Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.92), shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 12)]),
            child: Icon(LucideIcons.play, color: cs.primary, size: 20))),
          // Phase
          Positioned(top: 12, left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: pi.color.withOpacity(0.9),
                borderRadius: BorderRadius.circular(8)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Container(width: 5, height: 5,
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
                const SizedBox(width: 4),
                Text(pi.label, style: GoogleFonts.inter(
                  fontSize: 9, fontWeight: FontWeight.w700, color: Colors.white)),
              ]))),
          // Duration
          Positioned(top: 12, right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.45),
                borderRadius: BorderRadius.circular(8)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(LucideIcons.clock, size: 9, color: Colors.white70),
                const SizedBox(width: 3),
                Text(recipe.duration, style: GoogleFonts.inter(
                  fontSize: 9, fontWeight: FontWeight.w600, color: Colors.white)),
              ]))),
          // Bottom
          Positioned(bottom: 14, left: 14, right: 14,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(recipe.name, maxLines: 2, overflow: TextOverflow.ellipsis,
                style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w700,
                  color: Colors.white, height: 1.2, letterSpacing: -0.2)),
              const SizedBox(height: 6),
              Row(children: [
                const Icon(LucideIcons.flame, size: 10, color: Colors.white60),
                const SizedBox(width: 3),
                Text('${recipe.kcal} kcal', style: GoogleFonts.inter(
                  fontSize: 10.5, fontWeight: FontWeight.w600, color: Colors.white70)),
                const SizedBox(width: 12),
                Text(recipe.difficulty, style: GoogleFonts.inter(
                  fontSize: 10, color: Colors.white.withOpacity(0.45))),
              ]),
              if (recipe.authorName != null) ...[
                const SizedBox(height: 5),
                Row(children: [
                  const Icon(LucideIcons.user, size: 9, color: Colors.white54),
                  const SizedBox(width: 4),
                  Text(recipe.authorName!, style: GoogleFonts.inter(
                    fontSize: 9.5, fontWeight: FontWeight.w500, color: Colors.white60)),
                ]),
              ],
            ])),
        ])));
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// RECIPE CARD (discover section)
// ══════════════════════════════════════════════════════════════════════════════
class _RecipeCard extends StatelessWidget {
  final RealRecipe recipe;
  final VoidCallback onTap;
  const _RecipeCard({required this.recipe, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final pi = PhaseInfo.from(recipe.phase);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 150,
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: cs.outline.withOpacity(0.08)),
          boxShadow: [BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12, offset: const Offset(0, 4))]),
        clipBehavior: Clip.antiAlias,
        child: Column(children: [
          Expanded(
            child: Stack(fit: StackFit.expand, children: [
              Image.network(recipe.imageUrl, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(color: cs.primary.withOpacity(0.05))),
              // Phase
              Positioned(top: 8, left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: pi.color.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(6)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Container(width: 4, height: 4,
                      decoration: const BoxDecoration(
                        color: Colors.white, shape: BoxShape.circle)),
                    const SizedBox(width: 3),
                    Text(pi.label, style: GoogleFonts.inter(
                      fontSize: 7.5, fontWeight: FontWeight.w700, color: Colors.white)),
                  ]))),
              // Duration
              Positioned(bottom: 6, right: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(6)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(LucideIcons.clock, size: 8, color: Colors.white),
                    const SizedBox(width: 3),
                    Text(recipe.duration, style: GoogleFonts.inter(
                      fontSize: 8.5, fontWeight: FontWeight.w600, color: Colors.white)),
                  ]))),
            ])),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(recipe.name, maxLines: 2, overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.outfit(fontSize: 12.5, fontWeight: FontWeight.w700,
                    color: cs.onSurface, height: 1.2)),
                if (recipe.authorName != null) ...[
                  const SizedBox(height: 3),
                  Row(children: [
                    Icon(LucideIcons.user, size: 9, color: cs.onSurface.withOpacity(0.3)),
                    const SizedBox(width: 3),
                    Expanded(child: Text(recipe.authorName!, maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(fontSize: 9, color: cs.onSurface.withOpacity(0.4)))),
                  ]),
                ],
                const SizedBox(height: 6),
                Row(children: [
                  Icon(LucideIcons.flame, size: 10, color: cs.primary),
                  const SizedBox(width: 3),
                  Text('${recipe.kcal} kcal', style: GoogleFonts.inter(
                    fontSize: 10, fontWeight: FontWeight.w600, color: cs.primary)),
                  const Spacer(),
                  Text(recipe.difficulty, style: GoogleFonts.inter(
                    fontSize: 9, color: cs.onSurface.withOpacity(0.3))),
                ]),
              ])),
          Container(height: 3, color: pi.color),
        ])));
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// FAVORITES SCREEN
// ══════════════════════════════════════════════════════════════════════════════
class _FavoritesScreen extends ConsumerWidget {
  const _FavoritesScreen();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(l10nProvider);
    final cs = Theme.of(context).colorScheme;
    final top = MediaQuery.of(context).padding.top;
    final favNames = ref.watch(favoritesProvider);
    final imageAll = ref.watch(imageRecipesProvider).asData?.value ?? [];
    final videoAll = ref.watch(videoRecipesProvider).asData?.value ?? [];
    final imageFavs = imageAll.where((r) => favNames.contains(r.name)).toList();
    final videoFavs = videoAll.where((r) => favNames.contains(r.name)).toList();
    final isEmpty = imageFavs.isEmpty && videoFavs.isEmpty;

    return Scaffold(
      backgroundColor: cs.surface,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(child: Container(
            padding: EdgeInsets.fromLTRB(20, top + 16, 20, 16),
            child: Row(children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 38, height: 38,
                  decoration: BoxDecoration(
                    color: cs.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12)),
                  child: Icon(LucideIcons.chevronLeft, color: cs.primary, size: 18))),
              const SizedBox(width: 14),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(l10n.nutritionMyRecipes, style: GoogleFonts.inter(
                  color: cs.primary, fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 3)),
                Text(l10n.nutritionFavorites, style: GoogleFonts.outfit(
                  color: cs.onSurface, fontSize: 22,
                  fontWeight: FontWeight.w800, letterSpacing: -0.4)),
              ]),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: cs.primary.withOpacity(0.08), borderRadius: BorderRadius.circular(20)),
                child: Text('${favNames.length}', style: GoogleFonts.inter(
                  fontSize: 12, fontWeight: FontWeight.w700, color: cs.primary))),
            ]))),

          if (isEmpty)
            SliverFillRemaining(child: Center(child: Column(
              mainAxisSize: MainAxisSize.min, children: [
                Container(
                  width: 64, height: 64,
                  decoration: BoxDecoration(
                    color: cs.primary.withOpacity(0.08), borderRadius: BorderRadius.circular(20)),
                  child: Icon(LucideIcons.heart, color: cs.primary, size: 28)),
                const SizedBox(height: 16),
                Text(l10n.nutritionNoFavorites, style: GoogleFonts.outfit(
                  fontSize: 18, fontWeight: FontWeight.w700, color: cs.onSurface)),
                const SizedBox(height: 6),
                Text(l10n.nutritionFavoriteHint, textAlign: TextAlign.center,
                  style: GoogleFonts.inter(fontSize: 13, color: cs.onSurface.withOpacity(0.5))),
              ]))),

          if (imageFavs.isNotEmpty) ...[
            SliverToBoxAdapter(child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 10),
              child: Text(l10n.nutritionPhotoRecipes, style: GoogleFonts.outfit(
                fontSize: 16, fontWeight: FontWeight.w700, color: cs.onSurface)))),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              sliver: SliverList.separated(
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemCount: imageFavs.length,
                itemBuilder: (ctx, i) {
                  final r = imageFavs[i];
                  final pi = PhaseInfo.from(r.phase);
                  return GestureDetector(
                    onTap: () => Navigator.push(ctx, MaterialPageRoute(
                      builder: (_) => RecipeDetailScreen(
                        recipe: r.source ?? RecipeItem(r.imageUrl, r.name, r.name, r.accent)))),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: cs.surface, borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: cs.outline.withOpacity(0.08)),
                        boxShadow: [BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 10, offset: const Offset(0, 3))]),
                      child: Row(children: [
                        Stack(children: [
                          ClipRRect(borderRadius: BorderRadius.circular(12),
                            child: Image.network(r.imageUrl, width: 68, height: 68, fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                Container(width: 68, height: 68, color: cs.primary.withOpacity(0.06)))),
                          Positioned(top: 4, left: 4,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                              decoration: BoxDecoration(
                                color: pi.color.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(6)),
                              child: Row(mainAxisSize: MainAxisSize.min, children: [
                                Container(width: 4, height: 4,
                                  decoration: const BoxDecoration(
                                    color: Colors.white, shape: BoxShape.circle)),
                                const SizedBox(width: 3),
                                Text(pi.label, style: GoogleFonts.inter(
                                  fontSize: 7, fontWeight: FontWeight.w700, color: Colors.white)),
                              ]))),
                        ]),
                        const SizedBox(width: 12),
                        Expanded(child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(r.name, maxLines: 2, overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.outfit(
                                fontSize: 13.5, fontWeight: FontWeight.w700, color: cs.onSurface)),
                            const SizedBox(height: 4),
                            Row(children: [
                              Icon(LucideIcons.flame, size: 10, color: cs.primary),
                              const SizedBox(width: 3),
                              Text('${r.kcal} kcal', style: GoogleFonts.inter(
                                fontSize: 11, fontWeight: FontWeight.w600, color: cs.primary)),
                              const SizedBox(width: 8),
                              Icon(LucideIcons.clock, size: 10, color: cs.onSurface.withOpacity(0.3)),
                              const SizedBox(width: 3),
                              Text(r.duration, style: GoogleFonts.inter(
                                fontSize: 11, color: cs.onSurface.withOpacity(0.4))),
                            ]),
                            if (r.authorName != null) ...[
                              const SizedBox(height: 4),
                              Row(children: [
                                Icon(LucideIcons.user, size: 9, color: cs.onSurface.withOpacity(0.3)),
                                const SizedBox(width: 4),
                                Text(r.authorName!, style: GoogleFonts.inter(
                                  fontSize: 10, color: cs.onSurface.withOpacity(0.4))),
                              ]),
                            ],
                          ])),
                        GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            ref.read(favoritesProvider.notifier).toggle(r.name);
                          },
                          child: Icon(LucideIcons.heart, color: cs.primary, size: 20)),
                      ])));
                })),
          ],

          if (videoFavs.isNotEmpty) ...[
            SliverToBoxAdapter(child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 10),
              child: Text(l10n.nutritionVideoRecipes, style: GoogleFonts.outfit(
                fontSize: 16, fontWeight: FontWeight.w700, color: cs.onSurface)))),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
              sliver: SliverList.separated(
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemCount: videoFavs.length,
                itemBuilder: (ctx, i) {
                  final r = videoFavs[i];
                  final pi = PhaseInfo.from(r.phase);
                  return GestureDetector(
                    onTap: () => Navigator.push(ctx, MaterialPageRoute(
                      builder: (_) => RecipeVideoPlayerScreen(recipe: r))),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: cs.surface, borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: cs.outline.withOpacity(0.08)),
                        boxShadow: [BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 10, offset: const Offset(0, 3))]),
                      child: Row(children: [
                        Stack(children: [
                          ClipRRect(borderRadius: BorderRadius.circular(12),
                            child: Image.network(r.imageUrl, width: 68, height: 68, fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                Container(width: 68, height: 68, color: cs.primary.withOpacity(0.06)))),
                          Positioned.fill(child: Center(child: Container(
                            width: 26, height: 26,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9), shape: BoxShape.circle,
                              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 6)]),
                            child: Icon(LucideIcons.play, color: cs.primary, size: 11)))),
                          Positioned(top: 4, left: 4,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                              decoration: BoxDecoration(
                                color: pi.color.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(6)),
                              child: Row(mainAxisSize: MainAxisSize.min, children: [
                                Container(width: 4, height: 4,
                                  decoration: const BoxDecoration(
                                    color: Colors.white, shape: BoxShape.circle)),
                                const SizedBox(width: 3),
                                Text(pi.label, style: GoogleFonts.inter(
                                  fontSize: 7, fontWeight: FontWeight.w700, color: Colors.white)),
                              ]))),
                        ]),
                        const SizedBox(width: 12),
                        Expanded(child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(r.name, maxLines: 2, overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.outfit(
                                fontSize: 13.5, fontWeight: FontWeight.w700, color: cs.onSurface)),
                            const SizedBox(height: 4),
                            Row(children: [
                              Icon(LucideIcons.flame, size: 10, color: cs.primary),
                              const SizedBox(width: 3),
                              Text('${r.kcal} kcal', style: GoogleFonts.inter(
                                fontSize: 11, fontWeight: FontWeight.w600, color: cs.primary)),
                              const SizedBox(width: 8),
                              Icon(LucideIcons.clock, size: 10, color: cs.onSurface.withOpacity(0.3)),
                              const SizedBox(width: 3),
                              Text(r.duration, style: GoogleFonts.inter(
                                fontSize: 11, color: cs.onSurface.withOpacity(0.4))),
                            ]),
                            if (r.authorName != null) ...[
                              const SizedBox(height: 4),
                              Row(children: [
                                Icon(LucideIcons.user, size: 9, color: cs.onSurface.withOpacity(0.3)),
                                const SizedBox(width: 4),
                                Text(r.authorName!, style: GoogleFonts.inter(
                                  fontSize: 10, color: cs.onSurface.withOpacity(0.4))),
                              ]),
                            ],
                          ])),
                        GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            ref.read(favoritesProvider.notifier).toggle(r.name);
                          },
                          child: Icon(LucideIcons.heart, color: cs.primary, size: 20)),
                      ])));
                })),
          ],
        ],
      ),
    );
  }
}
