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
const _kMealColors = [Color(0xFFF59E0B), Color(0xFF10B981), Color(0xFF8B5CF6), Color(0xFF3B82F6)];
const _kMealIcons  = [LucideIcons.coffee, LucideIcons.utensils, LucideIcons.apple, LucideIcons.moon];
const _kMealBgs    = [Color(0xFFFFFBEB), Color(0xFFECFDF5), Color(0xFFF5F3FF), Color(0xFFEFF6FF)];

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
    final hasAnyMeal = totals.calories > 0;
    final dbRecipes = ref.watch(imageRecipesProvider).asData?.value ?? [];
    final dbVideos = ref.watch(videoRecipesProvider).asData?.value ?? [];

    return Scaffold(
      backgroundColor: cs.surface,
      floatingActionButton: FloatingActionButton(
        onPressed: () { HapticFeedback.mediumImpact(); _goToAjout(); },
        backgroundColor: cs.primary,
        elevation: 8,
        child: const Icon(LucideIcons.plus, color: Colors.white, size: 22)),
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
                return GestureDetector(
                  onTap: () => Navigator.push(ctx, MaterialPageRoute(
                    builder: (_) => const _FavoritesScreen())),
                  child: Container(
                    width: 38, height: 38,
                    decoration: BoxDecoration(
                      color: cs.primary.withOpacity(n > 0 ? 0.12 : 0.06),
                      shape: BoxShape.circle),
                    child: Stack(clipBehavior: Clip.none, children: [
                      Center(child: Icon(LucideIcons.heart, size: 17,
                        color: n > 0 ? const Color(0xFFE03050) : cs.onSurface.withOpacity(0.35))),
                      if (n > 0) Positioned(top: -2, right: -2,
                        child: Container(
                          width: 15, height: 15,
                          decoration: const BoxDecoration(
                            color: Color(0xFFE03050), shape: BoxShape.circle),
                          child: Center(child: Text('$n',
                            style: const TextStyle(color: Colors.white,
                              fontSize: 8, fontWeight: FontWeight.w800))))),
                    ])));
              }),
            ],
            onAvatarTap: () => context.push('/profile'),
          ),

          // ══════════════════════════════════════════════════════════
          // CALORIE RING CARD
          // ══════════════════════════════════════════════════════════
          SliverToBoxAdapter(child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: GestureDetector(
              onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => SuiviNutritionScreen(initialDate: _selectedDate))),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                    colors: [
                      cs.primary,
                      Color.lerp(cs.primary, Colors.black, 0.25)!,
                    ]),
                  borderRadius: BorderRadius.circular(24)),
                child: Column(children: [
                  Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                    AnimatedBuilder(
                      animation: _anim,
                      builder: (_, __) => SizedBox(
                        width: 110, height: 110,
                        child: CustomPaint(
                          painter: _NutritionRingPainter(
                            progress: pct * _anim.value,
                            isOver: over,
                            trackColor: Colors.white.withOpacity(0.1),
                            progressColor: over ? const Color(0xFFFF6B6B) : Colors.white),
                          child: Center(child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('${totals.calories}', style: GoogleFonts.outfit(
                                fontSize: 28, fontWeight: FontWeight.w800,
                                color: Colors.white, height: 1)),
                              const SizedBox(height: 2),
                              Text('kcal', style: GoogleFonts.inter(
                                fontSize: 11, fontWeight: FontWeight.w500,
                                color: Colors.white.withOpacity(0.55))),
                            ]))))),

                    const SizedBox(width: 20),

                    Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: over
                                ? const Color(0xFFFF6B6B).withOpacity(0.2)
                                : Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20)),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            Icon(
                              over ? LucideIcons.alertTriangle : LucideIcons.target,
                              size: 11, color: over ? const Color(0xFFFF8585) : Colors.white70),
                            const SizedBox(width: 6),
                            Text(
                              over
                                  ? '+${-remaining} ${l10n.nutritionKcalOver}'
                                  : '$remaining ${l10n.nutritionKcalLeft}',
                              style: GoogleFonts.inter(fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: over ? const Color(0xFFFF8585) : Colors.white)),
                          ])),

                        const SizedBox(height: 4),
                        Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: Text('objectif ${profile.dailyKcal} kcal',
                            style: GoogleFonts.inter(fontSize: 11,
                              color: Colors.white.withOpacity(0.35)))),

                        const SizedBox(height: 14),

                        _HeroMacroRow('Protéines', totals.protein, profile.dailyProtein, Colors.white),
                        const SizedBox(height: 8),
                        _HeroMacroRow('Glucides', totals.carbs, profile.dailyCarbs, const Color(0xFF7BD4FF)),
                        const SizedBox(height: 8),
                        _HeroMacroRow('Lipides', totals.fat, profile.dailyFat, const Color(0xFFFFB347)),
                      ])),
                  ]),

                  const SizedBox(height: 16),
                  _PointsStrip(
                    consumed: totals.calories,
                    goal: profile.dailyKcal,
                    goalType: profile.goal),
                ]),
              ),
            ),
          )),

          // ══════════════════════════════════════════════════════════
          // DATE BAR
          // ══════════════════════════════════════════════════════════
          SliverToBoxAdapter(child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: _DateBar(
              date: _selectedDate,
              isToday: _isToday,
              onPrev: _goToPrevDay,
              onNext: _isToday ? null : _goToNextDay,
              onReset: _isToday ? null : () => setState(() => _selectedDate = DateTime.now())),
          )),

          // ══════════════════════════════════════════════════════════
          // EMPTY STATE
          // ══════════════════════════════════════════════════════════
          if (!hasAnyMeal)
            SliverToBoxAdapter(child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: GestureDetector(
                onTap: _goToAjout,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cs.primary.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: cs.primary.withOpacity(0.1)),
                    boxShadow: [BoxShadow(
                      color: cs.primary.withOpacity(0.04),
                      blurRadius: 20, offset: const Offset(0, 4))]),
                  child: Row(children: [
                    Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [cs.primary, cs.primary.withOpacity(0.7)]),
                        borderRadius: BorderRadius.circular(13)),
                      child: const Icon(LucideIcons.utensils, color: Colors.white, size: 18)),
                    const SizedBox(width: 14),
                    Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.nutritionNoMealsToday, style: GoogleFonts.outfit(
                          fontSize: 14, fontWeight: FontWeight.w700, color: cs.onSurface)),
                        const SizedBox(height: 2),
                        Text(l10n.nutritionStartTracking, style: GoogleFonts.inter(
                          fontSize: 11.5, color: cs.onSurface.withOpacity(0.45))),
                      ])),
                    Container(
                      width: 32, height: 32,
                      decoration: BoxDecoration(
                        color: cs.primary.withOpacity(0.08),
                        shape: BoxShape.circle),
                      child: Icon(LucideIcons.plus, size: 14, color: cs.primary)),
                  ])),
              ),
            )),

          // ══════════════════════════════════════════════════════════
          // MEALS
          // ══════════════════════════════════════════════════════════
          SliverToBoxAdapter(child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 6),
            child: Row(children: [
              Text('Mes repas', style: GoogleFonts.outfit(
                fontSize: 18, fontWeight: FontWeight.w800,
                color: cs.onSurface, letterSpacing: -0.3)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(8)),
                child: Text(
                  '${categories.fold(0, (s, c) => s + c.consumed)} / ${categories.fold(0, (s, c) => s + c.budget)} kcal',
                  style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600,
                    color: cs.onSurface.withOpacity(0.45)))),
            ]))),

          SliverToBoxAdapter(child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: cs.outline.withOpacity(0.08)),
                boxShadow: [BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 16, offset: const Offset(0, 4))]),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: List.generate(categories.length, (i) {
                  final c = categories[i];
                  final id = ['breakfast', 'lunch', 'snack', 'dinner'][i];
                  final isLast = i == categories.length - 1;
                  return _MealRow(
                    data: c, index: i, isLast: isLast,
                    onTap: () => _goToSuivi(id));
                })),
            ),
          )),

          // ══════════════════════════════════════════════════════════
          // AI NUTRITION COACH
          // ══════════════════════════════════════════════════════════
          SliverToBoxAdapter(child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
            child: _AiCoachCard(
              calories: totals.calories, calorieGoal: profile.dailyKcal,
              protein: totals.protein, proteinGoal: profile.dailyProtein,
              carbs: totals.carbs, carbsGoal: profile.dailyCarbs,
              fat: totals.fat, fatGoal: profile.dailyFat,
              onAddFood: _goToAjout))),

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
                height: 180,
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
// CUSTOM RING PAINTER (premium arc)
// ══════════════════════════════════════════════════════════════════════════════
class _NutritionRingPainter extends CustomPainter {
  final double progress;
  final bool isOver;
  final Color trackColor, progressColor;

  _NutritionRingPainter({
    required this.progress, required this.isOver,
    required this.trackColor, required this.progressColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 6;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // Track
    canvas.drawArc(rect, -math.pi / 2, 2 * math.pi, false,
      Paint()..color = trackColor..style = PaintingStyle.stroke
        ..strokeWidth = 8..strokeCap = StrokeCap.round);

    // Progress
    if (progress > 0) {
      final sweep = 2 * math.pi * progress;
      canvas.drawArc(rect, -math.pi / 2, sweep, false,
        Paint()..color = progressColor..style = PaintingStyle.stroke
          ..strokeWidth = 8..strokeCap = StrokeCap.round);
    }
  }

  @override
  bool shouldRepaint(covariant _NutritionRingPainter old) =>
      old.progress != progress || old.isOver != isOver;
}

// ══════════════════════════════════════════════════════════════════════════════
// HERO MACRO ROW
// ══════════════════════════════════════════════════════════════════════════════
class _HeroMacroRow extends StatelessWidget {
  final String label;
  final int consumed, goal;
  final Color color;
  const _HeroMacroRow(this.label, this.consumed, this.goal, this.color);

  @override
  Widget build(BuildContext context) {
    final pct = goal > 0 ? (consumed / goal).clamp(0.0, 1.0) : 0.0;
    return Row(children: [
      SizedBox(width: 58, child: Text(label, style: GoogleFonts.inter(
        fontSize: 10, fontWeight: FontWeight.w500, color: Colors.white54))),
      Expanded(child: Container(
        height: 4,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(2)),
        child: FractionallySizedBox(
          alignment: Alignment.centerLeft,
          widthFactor: pct,
          child: Container(
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2)))))),
      const SizedBox(width: 8),
      SizedBox(width: 32, child: Text('${consumed}g', textAlign: TextAlign.right,
        style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600,
          color: Colors.white.withOpacity(0.7)))),
    ]);
  }
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
class _DateBar extends StatelessWidget {
  final DateTime date;
  final bool isToday;
  final VoidCallback onPrev;
  final VoidCallback? onNext, onReset;
  const _DateBar({required this.date, required this.isToday,
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

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withOpacity(0.35),
        borderRadius: BorderRadius.circular(14)),
      child: Row(children: [
        GestureDetector(
          onTap: onPrev,
          child: Container(
            width: 34, height: 34,
            decoration: BoxDecoration(
              color: cs.surface, shape: BoxShape.circle),
            child: Icon(LucideIcons.chevronLeft, size: 14,
              color: cs.onSurface.withOpacity(0.5)))),
        Expanded(child: GestureDetector(
          onTap: onReset,
          child: Column(children: [
            Text(label, style: GoogleFonts.inter(fontSize: 13,
              fontWeight: FontWeight.w700, color: cs.onSurface)),
            if (!isToday)
              Text("Aujourd'hui →", style: GoogleFonts.inter(
                fontSize: 9, fontWeight: FontWeight.w500, color: cs.primary)),
          ]))),
        GestureDetector(
          onTap: onNext,
          child: Container(
            width: 34, height: 34,
            decoration: BoxDecoration(
              color: isToday ? cs.surface.withOpacity(0.5) : cs.surface,
              shape: BoxShape.circle),
            child: Icon(LucideIcons.chevronRight, size: 14,
              color: cs.onSurface.withOpacity(isToday ? 0.12 : 0.5)))),
      ]));
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// MEAL ROW
// ══════════════════════════════════════════════════════════════════════════════
class _MealRow extends StatelessWidget {
  final MealCategoryData data;
  final int index;
  final bool isLast;
  final VoidCallback onTap;
  const _MealRow({required this.data, required this.index,
    required this.isLast, required this.onTap});

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
    final accent = _kMealColors[idx];
    final icon = _kMealIcons[idx];
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgAccent = isDark ? accent.withOpacity(0.15) : _kMealBgs[idx];
    final pct = data.pct.clamp(0.0, 1.0);
    final over = data.remaining < 0;
    final empty = data.consumed == 0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: isLast ? null : Border(
            bottom: BorderSide(color: cs.outline.withOpacity(0.06)))),
        child: Row(children: [
          Container(
            width: 42, height: 42,
            decoration: BoxDecoration(
              color: bgAccent,
              borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, size: 18, color: accent)),
          const SizedBox(width: 14),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Expanded(child: Text(data.name, style: GoogleFonts.outfit(
                  fontSize: 14, fontWeight: FontWeight.w700, color: cs.onSurface))),
                Text(data.time, style: GoogleFonts.inter(
                  fontSize: 10, color: cs.onSurface.withOpacity(0.3))),
              ]),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: LinearProgressIndicator(
                  value: pct, minHeight: 3,
                  backgroundColor: cs.surfaceContainerHighest.withOpacity(0.5),
                  valueColor: AlwaysStoppedAnimation(
                    empty ? cs.outline.withOpacity(0.15)
                        : over ? const Color(0xFFE03050) : accent))),
              const SizedBox(height: 5),
              Row(children: [
                Text(
                  empty ? 'Aucun repas' : '${data.consumed} kcal',
                  style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500,
                    color: cs.onSurface.withOpacity(empty ? 0.3 : 0.6))),
                const Spacer(),
                Text('/ ${data.budget} kcal', style: GoogleFonts.inter(
                  fontSize: 10, color: cs.onSurface.withOpacity(0.25))),
              ]),
            ])),
          const SizedBox(width: 8),
          Icon(LucideIcons.chevronRight, size: 14,
            color: cs.onSurface.withOpacity(0.15)),
        ])));
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// AI NUTRITION COACH CARD
// ══════════════════════════════════════════════════════════════════════════════
class _CoachInsight {
  final String emoji;
  final String title;
  final String subtitle;
  final Color color;
  final List<_FoodSuggestion> suggestions;
  const _CoachInsight({required this.emoji, required this.title,
    required this.subtitle, required this.color, required this.suggestions});
}

class _FoodSuggestion {
  final String name;
  final String amount;
  final IconData icon;
  const _FoodSuggestion({required this.name, required this.amount, required this.icon});
}

class _AiCoachCard extends StatefulWidget {
  final int calories, calorieGoal, protein, proteinGoal;
  final int carbs, carbsGoal, fat, fatGoal;
  final VoidCallback onAddFood;

  const _AiCoachCard({
    required this.calories, required this.calorieGoal,
    required this.protein, required this.proteinGoal,
    required this.carbs, required this.carbsGoal,
    required this.fat, required this.fatGoal,
    required this.onAddFood});

  @override
  State<_AiCoachCard> createState() => _AiCoachCardState();
}

class _AiCoachCardState extends State<_AiCoachCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late Animation<double> _pulse;
  bool _expanded = false;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 2000))
      ..repeat(reverse: true);
    _pulse = Tween(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() { _pulseCtrl.dispose(); super.dispose(); }

  _CoachInsight _analyze() {
    final protDiff = widget.proteinGoal - widget.protein;
    final carbDiff = widget.carbsGoal - widget.carbs;
    final fatDiff = widget.fatGoal - widget.fat;
    final calDiff = widget.calorieGoal - widget.calories;

    // Perfect day
    if (calDiff.abs() < 100 &&
        protDiff.abs() < 10 &&
        carbDiff.abs() < 20 &&
        fatDiff.abs() < 10) {
      return _CoachInsight(
        emoji: '🌟',
        title: 'Journée parfaite !',
        subtitle: 'Tes macros sont bien équilibrés. Continue comme ça.',
        color: const Color(0xFF10B981),
        suggestions: []);
    }

    // Over calories
    if (calDiff < -200) {
      return _CoachInsight(
        emoji: '⚡',
        title: 'Surplus calorique',
        subtitle: 'Tu as dépassé de ${-calDiff} kcal. Pas de panique, ça arrive.',
        color: const Color(0xFFF59E0B),
        suggestions: [
          const _FoodSuggestion(name: 'Marche rapide 30 min', amount: '−150 kcal', icon: LucideIcons.activity),
          const _FoodSuggestion(name: 'Repas léger ce soir', amount: 'salade', icon: LucideIcons.salad),
          const _FoodSuggestion(name: 'Boire de l\'eau', amount: '2 verres', icon: LucideIcons.droplets),
        ]);
    }

    // Not started
    if (widget.calories == 0) {
      return _CoachInsight(
        emoji: '🍳',
        title: 'Commence ta journée',
        subtitle: 'Log ton premier repas pour des conseils personnalisés.',
        color: const Color(0xFF6B8FD4),
        suggestions: [
          const _FoodSuggestion(name: 'Flocons d\'avoine', amount: '50g · 180 kcal', icon: LucideIcons.wheat),
          const _FoodSuggestion(name: 'Œufs brouillés', amount: '2 · 140 kcal', icon: LucideIcons.circle),
          const _FoodSuggestion(name: 'Yaourt grec', amount: '150g · 90 kcal', icon: LucideIcons.coffee),
        ]);
    }

    // Low protein (most common)
    if (protDiff > 20) {
      return _CoachInsight(
        emoji: '💪',
        title: 'Protéines en retard',
        subtitle: 'Il te manque ${protDiff}g de protéines aujourd\'hui.',
        color: const Color(0xFFE03050),
        suggestions: [
          _FoodSuggestion(name: 'Yaourt grec', amount: '200g · 20g prot', icon: LucideIcons.coffee),
          _FoodSuggestion(name: 'Blanc de poulet', amount: '150g · 46g prot', icon: LucideIcons.drumstick),
          _FoodSuggestion(name: 'Œufs', amount: '3 · 18g prot', icon: LucideIcons.circle),
          if (protDiff > 40)
            _FoodSuggestion(name: 'Thon en boîte', amount: '100g · 26g prot', icon: LucideIcons.waves),
        ]);
    }

    // Low carbs
    if (carbDiff > 40) {
      return _CoachInsight(
        emoji: '⚡',
        title: 'Énergie basse',
        subtitle: 'Il te manque ${carbDiff}g de glucides pour tenir.',
        color: const Color(0xFF3B82F6),
        suggestions: [
          const _FoodSuggestion(name: 'Riz basmati', amount: '80g · 56g gluc', icon: LucideIcons.wheat),
          const _FoodSuggestion(name: 'Banane', amount: '1 · 27g gluc', icon: LucideIcons.apple),
          const _FoodSuggestion(name: 'Pain complet', amount: '2 tr · 30g gluc', icon: LucideIcons.wheat),
        ]);
    }

    // Low fat
    if (fatDiff > 15) {
      return _CoachInsight(
        emoji: '🥑',
        title: 'Lipides insuffisants',
        subtitle: 'Il te manque ${fatDiff}g de lipides pour tes hormones.',
        color: const Color(0xFF8B5CF6),
        suggestions: [
          const _FoodSuggestion(name: 'Avocat', amount: '½ · 15g lip', icon: LucideIcons.leaf),
          const _FoodSuggestion(name: 'Amandes', amount: '30g · 15g lip', icon: LucideIcons.circle),
          const _FoodSuggestion(name: 'Huile d\'olive', amount: '1 c.s · 14g lip', icon: LucideIcons.droplets),
        ]);
    }

    // Default: on track
    return _CoachInsight(
      emoji: '✅',
      title: 'Tu es sur la bonne voie',
      subtitle: 'Encore $calDiff kcal à consommer. Tu gères !',
      color: const Color(0xFF10B981),
      suggestions: []);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final insight = _analyze();
    final hasSuggestions = insight.suggestions.isNotEmpty;

    return GestureDetector(
      onTap: hasSuggestions ? () => setState(() => _expanded = !_expanded) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: [
              insight.color.withOpacity(0.08),
              insight.color.withOpacity(0.03),
            ]),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: insight.color.withOpacity(0.15)),
          boxShadow: [BoxShadow(
            color: insight.color.withOpacity(0.06),
            blurRadius: 20, offset: const Offset(0, 4))]),
        child: Column(children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Chef AI avatar
              AnimatedBuilder(
                animation: _pulse,
                builder: (_, __) => Transform.scale(
                  scale: _pulse.value,
                  child: Container(
                    width: 48, height: 48,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft, end: Alignment.bottomRight,
                        colors: [insight.color, insight.color.withOpacity(0.6)]),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: insight.color.withOpacity(0.35),
                          blurRadius: 14, offset: const Offset(0, 5)),
                        BoxShadow(
                          color: insight.color.withOpacity(0.1),
                          blurRadius: 30, spreadRadius: 2),
                      ]),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Positioned(
                          top: 4,
                          child: Icon(LucideIcons.chefHat, size: 16,
                            color: Colors.white.withOpacity(0.9))),
                        Positioned(
                          bottom: 6,
                          child: Icon(LucideIcons.sparkles, size: 12,
                            color: Colors.white.withOpacity(0.7))),
                      ])))),

              const SizedBox(width: 12),

              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: insight.color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(6)),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(LucideIcons.chefHat, size: 9, color: insight.color),
                        const SizedBox(width: 3),
                        Text('Chef IA', style: GoogleFonts.inter(
                          fontSize: 9, fontWeight: FontWeight.w700,
                          color: insight.color, letterSpacing: 0.5)),
                      ])),
                    const Spacer(),
                    if (hasSuggestions)
                      AnimatedRotation(
                        turns: _expanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 200),
                        child: Icon(LucideIcons.chevronDown, size: 16,
                          color: cs.onSurface.withOpacity(0.3))),
                  ]),
                  const SizedBox(height: 6),
                  Text(insight.title, style: GoogleFonts.outfit(
                    fontSize: 16, fontWeight: FontWeight.w800,
                    color: cs.onSurface, letterSpacing: -0.3)),
                  const SizedBox(height: 2),
                  Text(insight.subtitle, style: GoogleFonts.inter(
                    fontSize: 12, color: cs.onSurface.withOpacity(0.55),
                    height: 1.4)),
                ])),
            ])),

          // Macro summary bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Row(children: [
              _MacroChip('P', widget.protein, widget.proteinGoal,
                Colors.white, insight.color),
              const SizedBox(width: 6),
              _MacroChip('G', widget.carbs, widget.carbsGoal,
                const Color(0xFF7BD4FF), insight.color),
              const SizedBox(width: 6),
              _MacroChip('L', widget.fat, widget.fatGoal,
                const Color(0xFFFFB347), insight.color),
            ])),

          // Suggestions (expandable)
          AnimatedCrossFade(
            firstChild: const SizedBox(height: 16, width: double.infinity),
            secondChild: _buildSuggestions(cs, insight),
            crossFadeState: _expanded && hasSuggestions
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 250)),
        ]),
      ),
    );
  }

  Widget _buildSuggestions(ColorScheme cs, _CoachInsight insight) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Column(children: [
        // Divider
        Container(
          height: 1,
          color: insight.color.withOpacity(0.08)),
        const SizedBox(height: 12),

        // Label
        Row(children: [
          Icon(LucideIcons.lightbulb, size: 12, color: insight.color),
          const SizedBox(width: 6),
          Text('Suggestions', style: GoogleFonts.inter(
            fontSize: 11, fontWeight: FontWeight.w700,
            color: insight.color, letterSpacing: 0.5)),
        ]),
        const SizedBox(height: 10),

        // Food suggestions
        ...insight.suggestions.map((s) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: cs.outline.withOpacity(0.06))),
            child: Row(children: [
              Container(
                width: 32, height: 32,
                decoration: BoxDecoration(
                  color: insight.color.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8)),
                child: Icon(s.icon, size: 14, color: insight.color)),
              const SizedBox(width: 10),
              Expanded(child: Text(s.name, style: GoogleFonts.inter(
                fontSize: 13, fontWeight: FontWeight.w600, color: cs.onSurface))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: insight.color.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8)),
                child: Text(s.amount, style: GoogleFonts.inter(
                  fontSize: 10, fontWeight: FontWeight.w600, color: insight.color))),
            ])))),

        // CTA
        const SizedBox(height: 4),
        GestureDetector(
          onTap: widget.onAddFood,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [insight.color, insight.color.withOpacity(0.8)]),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(
                color: insight.color.withOpacity(0.25),
                blurRadius: 8, offset: const Offset(0, 3))]),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(LucideIcons.plus, size: 14, color: Colors.white),
              const SizedBox(width: 6),
              Text('Ajouter un aliment', style: GoogleFonts.inter(
                fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
            ]))),
      ]),
    );
  }
}

class _MacroChip extends StatelessWidget {
  final String label;
  final int consumed, goal;
  final Color barColor, accentColor;
  const _MacroChip(this.label, this.consumed, this.goal,
    this.barColor, this.accentColor);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final pct = goal > 0 ? (consumed / goal).clamp(0.0, 1.0) : 0.0;
    final low = goal > 0 && consumed < goal * 0.5;
    return Expanded(child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: low ? accentColor.withOpacity(0.06) : cs.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: low ? accentColor.withOpacity(0.15) : cs.outline.withOpacity(0.06))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text(label, style: GoogleFonts.inter(
            fontSize: 9, fontWeight: FontWeight.w700,
            color: low ? accentColor : cs.onSurface.withOpacity(0.4))),
          const Spacer(),
          Text('${consumed}/${goal}g', style: GoogleFonts.inter(
            fontSize: 9, fontWeight: FontWeight.w600,
            color: cs.onSurface.withOpacity(0.45))),
        ]),
        const SizedBox(height: 5),
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: LinearProgressIndicator(
            value: pct, minHeight: 3,
            backgroundColor: cs.surfaceContainerHighest.withOpacity(0.5),
            valueColor: AlwaysStoppedAnimation(
              low ? accentColor : cs.primary.withOpacity(0.5)))),
      ])));
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
            flex: 5,
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
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(recipe.name, maxLines: 2, overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.outfit(fontSize: 12.5, fontWeight: FontWeight.w700,
                      color: cs.onSurface, height: 1.2)),
                  const Spacer(),
                  Row(children: [
                    Icon(LucideIcons.flame, size: 10, color: cs.primary),
                    const SizedBox(width: 3),
                    Text('${recipe.kcal} kcal', style: GoogleFonts.inter(
                      fontSize: 10, fontWeight: FontWeight.w600, color: cs.primary)),
                    const Spacer(),
                    Text(recipe.difficulty, style: GoogleFonts.inter(
                      fontSize: 9, color: cs.onSurface.withOpacity(0.3))),
                  ]),
                ]))),
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
    const kRed = Color(0xFFE03050);

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
                    color: kRed.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12)),
                  child: const Icon(LucideIcons.chevronLeft, color: kRed, size: 18))),
              const SizedBox(width: 14),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(l10n.nutritionMyRecipes, style: GoogleFonts.inter(
                  color: kRed, fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 3)),
                Text(l10n.nutritionFavorites, style: GoogleFonts.outfit(
                  color: cs.onSurface, fontSize: 22,
                  fontWeight: FontWeight.w800, letterSpacing: -0.4)),
              ]),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: kRed.withOpacity(0.08), borderRadius: BorderRadius.circular(20)),
                child: Text('${favNames.length}', style: GoogleFonts.inter(
                  fontSize: 12, fontWeight: FontWeight.w700, color: kRed))),
            ]))),

          if (isEmpty)
            SliverFillRemaining(child: Center(child: Column(
              mainAxisSize: MainAxisSize.min, children: [
                Container(
                  width: 64, height: 64,
                  decoration: BoxDecoration(
                    color: kRed.withOpacity(0.08), borderRadius: BorderRadius.circular(20)),
                  child: const Icon(LucideIcons.heart, color: kRed, size: 28)),
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
                  return GestureDetector(
                    onTap: () => Navigator.push(ctx, MaterialPageRoute(
                      builder: (_) => RecipeDetailScreen(
                        recipe: r.source ?? RecipeItem(r.imageUrl, r.name, r.name, r.accent)))),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: cs.surface, borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: cs.outline.withOpacity(0.1))),
                      child: Row(children: [
                        ClipRRect(borderRadius: BorderRadius.circular(10),
                          child: Image.network(r.imageUrl, width: 60, height: 60, fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                              Container(width: 60, height: 60, color: cs.primary.withOpacity(0.1)))),
                        const SizedBox(width: 12),
                        Expanded(child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(r.name, style: GoogleFonts.outfit(
                              fontSize: 13.5, fontWeight: FontWeight.w700, color: cs.onSurface)),
                            const SizedBox(height: 3),
                            Text('${r.kcal} kcal · ${r.duration}',
                              style: GoogleFonts.inter(fontSize: 11.5,
                                color: cs.onSurface.withOpacity(0.5))),
                          ])),
                        GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            ref.read(favoritesProvider.notifier).toggle(r.name);
                          },
                          child: const Icon(LucideIcons.heart, color: kRed, size: 20)),
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
                  return GestureDetector(
                    onTap: () => Navigator.push(ctx, MaterialPageRoute(
                      builder: (_) => RecipeVideoPlayerScreen(recipe: r))),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: cs.surface, borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: cs.outline.withOpacity(0.1))),
                      child: Row(children: [
                        Stack(children: [
                          ClipRRect(borderRadius: BorderRadius.circular(10),
                            child: Image.network(r.imageUrl, width: 60, height: 60, fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                Container(width: 60, height: 60, color: cs.primary.withOpacity(0.1)))),
                          Positioned.fill(child: Center(child: Container(
                            width: 24, height: 24,
                            decoration: BoxDecoration(
                              color: cs.primary.withOpacity(0.85), shape: BoxShape.circle),
                            child: const Icon(LucideIcons.play, color: Colors.white, size: 10)))),
                        ]),
                        const SizedBox(width: 12),
                        Expanded(child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(r.name, style: GoogleFonts.outfit(
                              fontSize: 13.5, fontWeight: FontWeight.w700, color: cs.onSurface)),
                            const SizedBox(height: 3),
                            Text('${r.kcal} kcal · ${r.duration}',
                              style: GoogleFonts.inter(fontSize: 11.5,
                                color: cs.onSurface.withOpacity(0.5))),
                          ])),
                        GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            ref.read(favoritesProvider.notifier).toggle(r.name);
                          },
                          child: const Icon(LucideIcons.heart, color: kRed, size: 20)),
                      ])));
                })),
          ],
        ],
      ),
    );
  }
}
