import 'package:fiteva/screens/nutrition/nutrition_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../models/models.dart';
import '../shared/donut_painters.dart';
import '../../../../l10n/lang.dart';
import '../../../../l10n/app_localizations.dart';

// ── Static brand tokens (theme-independent) ───────────────────────────────────
const _kGreen = NutritionColors.green;
const _kMint  = NutritionColors.mint;

// ── Meal accent colors ────────────────────────────────────────────────────────
const _kBreakfastColor = Color(0xFFF59E0B);
const _kLunchColor     = Color(0xFF10B981);
const _kSnackColor     = Color(0xFF8B5CF6);
const _kDinnerColor    = Color(0xFF3B82F6);

// ══════════════════════════════════════════════════════════════════════════════
//  DailyTrackingCard  —  Hero summary (dark green)
// ══════════════════════════════════════════════════════════════════════════════
class DailyTrackingCard extends StatelessWidget {
  final Animation<double> anim;
  final VoidCallback onConsulter, onCamera, onBarcode, onRecipes, onEdit;
  final int caloriesConsumed, caloriesGoal;

  const DailyTrackingCard({
    super.key,
    required this.anim,
    required this.onConsulter,
    required this.onCamera,
    required this.onBarcode,
    required this.onRecipes,
    required this.onEdit,
    required this.caloriesConsumed,
    required this.caloriesGoal,
  });

  @override
  Widget build(BuildContext context) {
    final remaining = caloriesGoal - caloriesConsumed;
    final over      = remaining < 0;
    final pct       = (caloriesConsumed / caloriesGoal).clamp(0.0, 1.0);

    final l10n = AppL10n(Lang.code);
    return Container(
      decoration: BoxDecoration(
        color: _kGreen,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: _kGreen.withOpacity(0.35),
            blurRadius: 32, offset: const Offset(0, 10)),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        // ── Top row: label + status pill ──────────────────────────────────────
        Row(children: [
          Text(l10n.nutritionDailyLog, style: GoogleFonts.inter(
            color: _kMint.withOpacity(0.8), fontSize: 9,
            fontWeight: FontWeight.w700, letterSpacing: 2.8)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.10),
              borderRadius: BorderRadius.circular(20)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Container(width: 5, height: 5,
                decoration: const BoxDecoration(
                  color: _kMint, shape: BoxShape.circle)),
              const SizedBox(width: 5),
              Text(l10n.nutritionOnTrack, style: GoogleFonts.inter(
                fontSize: 10, color: Colors.white70, fontWeight: FontWeight.w500)),
            ])),
        ]),

        const SizedBox(height: 20),

        // ── Main content: ring + right panel ─────────────────────────────────
        Row(crossAxisAlignment: CrossAxisAlignment.center, children: [

          // Donut ring — adaptive size
          Builder(builder: (ctx) {
            final sw = MediaQuery.of(ctx).size.width;
            final ringSize = sw < 380 ? 90.0 : 110.0;
            return SizedBox(
              width: ringSize, height: ringSize,
              child: AnimatedBuilder(
                animation: anim,
                builder: (_, __) => CustomPaint(
                  painter: DonutPainter(
                    proteinRatio: 0.25, carbsRatio: 0.54, fatRatio: 0.41,
                    animValue: anim.value),
                  child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                    FittedBox(fit: BoxFit.scaleDown, child: Text('$caloriesConsumed', style: GoogleFonts.outfit(
                      fontSize: 22, fontWeight: FontWeight.w800,
                      color: Colors.white, height: 1))),
                    Text('kcal', style: GoogleFonts.inter(
                      fontSize: 9, color: _kMint)),
                  ])),
                ),
              ),
            );
          }),

          const SizedBox(width: 18),

          // Right: macros + remaining
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _MacroRow(l10n.nutritionProtein, '25g', '60g', 25 / 60, const Color(0xFF7ABB98)),
              const SizedBox(height: 8),
              _MacroRow(l10n.nutritionCarbs,   '128g', '200g', 128 / 200, const Color(0xFF7BA7FF)),
              const SizedBox(height: 8),
              _MacroRow(l10n.nutritionFat,     '26g', '60g', 26 / 60, const Color(0xFFFFB347)),
              const SizedBox(height: 14),
              // Remaining pill
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: over
                      ? const Color(0xFFE03050).withOpacity(0.18)
                      : Colors.white.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: over
                        ? const Color(0xFFE03050).withOpacity(0.4)
                        : Colors.white.withOpacity(0.12))),
                child: Text(
                  over
                      ? '+${(-remaining).abs()} ${l10n.nutritionKcalExceeded}'
                      : '$remaining ${l10n.nutritionKcalRemaining}',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 11, fontWeight: FontWeight.w700,
                    color: over ? const Color(0xFFFF8585) : _kMint))),
            ],
          )),
        ]),

        const SizedBox(height: 18),

        // ── Overall progress bar ──────────────────────────────────────────────
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text('$caloriesGoal ${l10n.nutritionKcalGoal}', style: GoogleFonts.inter(
              fontSize: 10, color: Colors.white38)),
            const Spacer(),
            Text('${(pct * 100).round()}%', style: GoogleFonts.inter(
              fontSize: 10, fontWeight: FontWeight.w700, color: _kMint)),
          ]),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct, minHeight: 4,
              backgroundColor: Colors.white.withOpacity(0.10),
              valueColor: AlwaysStoppedAnimation(
                over ? const Color(0xFFE03050) : _kMint))),
        ]),

        const SizedBox(height: 18),

        // ── Action strip ──────────────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.symmetric(vertical: 2),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.07),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.08))),
          child: Row(children: [
            _ActionBtn(LucideIcons.camera,        l10n.nutritionPhoto,          onCamera),
            _Divider(),
            _ActionBtn(LucideIcons.scanLine,      l10n.nutritionScanner,        onBarcode),
            _Divider(),
            _ActionBtn(LucideIcons.chefHat,       l10n.nutritionRecipesAction,  onRecipes),
            _Divider(),
            _ActionBtn(LucideIcons.squarePen,     l10n.nutritionManual,         onEdit),
          ]),
        ),
      ]),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
//  MealCategoryCard  —  Compact horizontal row (no hero image)
// ══════════════════════════════════════════════════════════════════════════════
class MealCategoryCard extends StatelessWidget {
  final MealCategoryData data;
  final VoidCallback onTap;
  final bool isLast;

  const MealCategoryCard({
    super.key,
    required this.data,
    required this.onTap,
    this.isLast = false,
  });

  static const _icons  = [
    LucideIcons.coffee, LucideIcons.utensils, LucideIcons.apple, LucideIcons.moon,
  ];
  static const _colors = [
    _kBreakfastColor, _kLunchColor, _kSnackColor, _kDinnerColor,
  ];
  static const _bgColors = [
    Color(0xFFFFFBEB), Color(0xFFECFDF5), Color(0xFFF5F3FF), Color(0xFFEFF6FF),
  ];
  static const _namesFr = ['Petit déjeuner', 'Déjeuner', 'Collation', 'Dîner'];
  static const _namesEn = ['Breakfast', 'Lunch', 'Snack', 'Dinner'];

  int get _index {
    int i = _namesFr.indexOf(data.name);
    if (i == -1) i = _namesEn.indexOf(data.name);
    return i.clamp(0, 3);
  }

  @override
  Widget build(BuildContext context) {
    final l10n   = AppL10n(Lang.code);
    final nc     = NutritionColors.of(context);
    final idx    = _index;
    final accent = _colors[idx];
    final icon   = _icons[idx];
    final pct    = data.pct.clamp(0.0, 1.0);
    final over   = data.remaining < 0;
    final empty  = data.consumed == 0;

    // Dark-mode-aware icon background
    final bgAccent = nc.isDark
        ? accent.withOpacity(0.15)
        : _bgColors[idx];

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: isLast ? 0 : 1),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: nc.surface,
          border: Border(
            bottom: isLast
                ? BorderSide.none
                : BorderSide(color: nc.border, width: 1))),
        child: Row(children: [

          Container(
            width: 42, height: 42,
            decoration: BoxDecoration(color: bgAccent, shape: BoxShape.circle),
            child: Icon(icon, size: 18, color: accent)),

          const SizedBox(width: 14),

          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Text(data.name, style: GoogleFonts.outfit(
                  fontSize: 14, fontWeight: FontWeight.w700, color: nc.text1)),
                const Spacer(),
                Text(data.time, style: GoogleFonts.inter(
                  fontSize: 11, color: nc.text2)),
              ]),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: LinearProgressIndicator(
                  value: pct, minHeight: 3,
                  backgroundColor: nc.surface2,
                  valueColor: AlwaysStoppedAnimation(
                    empty ? nc.border
                        : over ? const Color(0xFFE03050)
                        : accent))),
              const SizedBox(height: 5),
              Row(children: [
                Text(
                  empty ? l10n.nutritionNoMealLogged : '${data.consumed} ${l10n.nutritionKcalConsumed}',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    color: empty ? nc.border : nc.text2)),
                const Spacer(),
                Text('/ ${data.budget} kcal',
                  style: GoogleFonts.inter(fontSize: 10, color: nc.text2)),
              ]),
            ],
          )),

          const SizedBox(width: 10),

          if (over)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFE03050).withOpacity(nc.isDark ? 0.25 : 0.10),
                borderRadius: BorderRadius.circular(20)),
              child: Text(l10n.nutritionExceeded, style: GoogleFonts.inter(
                fontSize: 9, fontWeight: FontWeight.w700,
                color: const Color(0xFFE03050))))
          else
            Icon(LucideIcons.chevronRight, size: 16, color: nc.text2),
        ]),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
//  MealsContainer  —  Wraps the 4 rows in one rounded card
// ══════════════════════════════════════════════════════════════════════════════
class MealsContainer extends StatelessWidget {
  final List<MealCategoryData> categories;
  final void Function(String mealId) onMealTap;

  const MealsContainer({
    super.key,
    required this.categories,
    required this.onMealTap,
  });

  static const _ids = ['breakfast', 'lunch', 'snack', 'dinner'];

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n(Lang.code);
    final nc = NutritionColors.of(context);
    final totalConsumed = categories.fold(0, (s, c) => s + c.consumed);
    final totalBudget   = categories.fold(0, (s, c) => s + c.budget);

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(l10n.nutritionMyMeals, style: GoogleFonts.inter(
            color: _kMint, fontSize: 9, fontWeight: FontWeight.w700,
            letterSpacing: 2.5)),
          const SizedBox(height: 2),
          Text(l10n.nutritionToday, style: GoogleFonts.outfit(
            color: nc.text1, fontSize: 20, fontWeight: FontWeight.w800,
            letterSpacing: -0.4)),
        ]),
        const Spacer(),
       
      ]),

      const SizedBox(height: 12),

      Container(
        decoration: BoxDecoration(
          color: nc.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: nc.border),
          boxShadow: nc.isDark ? [] : [BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16, offset: const Offset(0, 4))]),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: List.generate(categories.length, (i) => MealCategoryCard(
            data: categories[i],
            onTap: () => onMealTap(_ids[i]),
            isLast: i == categories.length - 1,
          )),
        ),
      ),
    ]);
  }
}

// ══════════════════════════════════════════════════════════════════════════════
//  RecipeCard  —  Horizontal scroll card
// ══════════════════════════════════════════════════════════════════════════════
class RecipeCard extends StatelessWidget {
  final RecipeItem recipe;
  final VoidCallback? onTap;
  const RecipeCard({super.key, required this.recipe, this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: MediaQuery.of(context).size.width < 380 ? 140 : 160,
      decoration: BoxDecoration(
        color: recipe.bgColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(
          color: Colors.black.withOpacity(0.08),
          blurRadius: 16, offset: const Offset(0, 4))],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(fit: StackFit.expand, children: [
        Image.network(recipe.emoji, fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            color: recipe.bgColor,
            child: const Center(child: Icon(
              LucideIcons.salad, color: Colors.white38, size: 36)))),

        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter, end: Alignment.bottomCenter,
              colors: [Colors.transparent, Color(0xEE000000)],
              stops: [0.3, 1.0]))),

        Positioned(top: 10, left: 10,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.45),
              borderRadius: BorderRadius.circular(8)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(LucideIcons.clock, size: 9, color: Colors.white70),
              const SizedBox(width: 3),
              Text(recipe.duration, style: GoogleFonts.inter(
                fontSize: 9, color: Colors.white70, fontWeight: FontWeight.w600)),
            ]))),

        Positioned(top: 10, right: 10,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
            decoration: BoxDecoration(
              color: _kMint.withOpacity(0.92),
              borderRadius: BorderRadius.circular(8)),
            child: Text(recipe.difficulty, style: GoogleFonts.inter(
              fontSize: 9, color: _kGreen, fontWeight: FontWeight.w700)))),

        Positioned(bottom: 10, left: 10, right: 10,
          child: Text(recipe.label,
            maxLines: 2, overflow: TextOverflow.ellipsis,
            style: GoogleFonts.outfit(
              fontSize: 13, fontWeight: FontWeight.w800,
              color: Colors.white, letterSpacing: -0.2, height: 1.25))),
      ]),
    ),
  );
}

// ══════════════════════════════════════════════════════════════════════════════
//  SectionHeader
// ══════════════════════════════════════════════════════════════════════════════
class SectionHeader extends StatelessWidget {
  final String title;
  final String? eyebrow;
  final VoidCallback? onSeeAll;
  const SectionHeader({super.key, required this.title, this.eyebrow, this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    final nc = NutritionColors.of(context);
    return Row(
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (eyebrow != null)
          Text(eyebrow!, style: GoogleFonts.inter(
            color: _kMint, fontSize: 9, fontWeight: FontWeight.w700,
            letterSpacing: 2.5)),
        if (eyebrow != null) const SizedBox(height: 2),
        Text(title, style: GoogleFonts.outfit(
          color: nc.text1, fontSize: 20, fontWeight: FontWeight.w800,
          letterSpacing: -0.4)),
      ]),
      const Spacer(),
      if (onSeeAll != null)
        GestureDetector(
          onTap: onSeeAll,
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Text(AppL10n(Lang.code).nutritionSeeAll, style: GoogleFonts.inter(
              fontSize: 12, fontWeight: FontWeight.w600, color: _kGreen)),
            const SizedBox(width: 3),
            const Icon(LucideIcons.chevronRight, size: 12, color: _kGreen),
          ])),
    ],
    );
  }
}

// ── Keep MacroRow for any external usage ──────────────────────────────────────
class MacroRow extends StatelessWidget {
  final String label, value;
  final Color color;
  const MacroRow(this.label, this.value, this.color, {super.key});

  @override
  Widget build(BuildContext context) {
    final nc = NutritionColors.of(context);
    return Row(children: [
    Container(width: 9, height: 9,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color)),
    const SizedBox(width: 8),
    Expanded(child: Text(label, style: GoogleFonts.inter(
      fontSize: 12, color: nc.text2))),
    Text(value, style: GoogleFonts.inter(
      fontSize: 12, fontWeight: FontWeight.w700, color: nc.text1)),
  ]);
  }
}

// ── Private helpers ───────────────────────────────────────────────────────────

class _MacroRow extends StatelessWidget {
  final String label, value, max;
  final double pct;
  final Color color;
  const _MacroRow(this.label, this.value, this.max, this.pct, this.color);

  @override
  Widget build(BuildContext context) => Row(children: [
    SizedBox(width: 62, child: Text(label, style: GoogleFonts.inter(
      fontSize: 10, color: Colors.white54))),
    Expanded(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(3),
        child: LinearProgressIndicator(
          value: pct.clamp(0.0, 1.0), minHeight: 4,
          backgroundColor: Colors.white.withOpacity(0.10),
          valueColor: AlwaysStoppedAnimation(color)))),
    const SizedBox(width: 8),
    Text('$value', style: GoogleFonts.inter(
      fontSize: 10, fontWeight: FontWeight.w700, color: color)),
  ]);
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ActionBtn(this.icon, this.label, this.onTap);

  @override
  Widget build(BuildContext context) => Expanded(
    child: GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 17, color: _kMint),
          const SizedBox(height: 4),
          Text(label, style: GoogleFonts.inter(
            fontSize: 9, color: Colors.white54, fontWeight: FontWeight.w500)),
        ]),
      ),
    ),
  );
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    width: 1, height: 28,
    color: Colors.white.withOpacity(0.08));
}
