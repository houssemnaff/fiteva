import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../models/models.dart';
import '../shared/donut_painters.dart';

// ── Design tokens ──────────────────────────────────────────────────────────────
const _kGreen   = Color(0xFF1C4D30);
const _kMint    = Color(0xFF7ABB98);
const _kMintBg  = Color(0xFFEAF3EC);
const _kCream   = Color(0xFFFEFEFE);
const _kWhite   = Colors.white;
const _kBorder  = Color(0xFFECECEC);
const _kText1   = Color(0xFF1A1A1A);
const _kText2   = Color(0xFF6B7280);

// ── NutritionHeader ───────────────────────────────────────────────────────────
class NutritionHeader extends StatelessWidget {
  const NutritionHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return SliverToBoxAdapter(
      child: Container(
        color: _kCream,
        padding: EdgeInsets.fromLTRB(20, top + 16, 20, 12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('NUTRITION', style: GoogleFonts.inter(
                color: _kMint, fontSize: 9, fontWeight: FontWeight.w700,
                letterSpacing: 3.5)),
              const SizedBox(height: 2),
              Text('Mon alimentation', style: GoogleFonts.outfit(
                color: _kGreen, fontSize: 26, fontWeight: FontWeight.w800,
                letterSpacing: -0.5)),
            ]),
            const Spacer(),
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: _kMintBg, shape: BoxShape.circle,
                border: Border.all(color: _kMint, width: 1.5)),
              child: Center(child: Text('Y', style: GoogleFonts.outfit(
                color: _kGreen, fontSize: 15, fontWeight: FontWeight.w700))),
            ),
          ]),
          const SizedBox(height: 10),
          Divider(height: 1, color: _kBorder),
          const SizedBox(height: 10),
          Row(children: [
            const Icon(LucideIcons.calendarDays, size: 12, color: _kText2),
            const SizedBox(width: 5),
            Text(_todayLabel(), style: GoogleFonts.inter(fontSize: 12, color: _kText2)),
            const Spacer(),
            Container(width: 6, height: 6,
              decoration: const BoxDecoration(color: _kMint, shape: BoxShape.circle)),
            const SizedBox(width: 5),
            Text('Sur la bonne voie', style: GoogleFonts.inter(
              fontSize: 12, fontWeight: FontWeight.w600, color: _kGreen)),
          ]),
        ]),
      ),
    );
  }

  String _todayLabel() {
    final now = DateTime.now();
    const j = ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche'];
    const m = ['janvier', 'février', 'mars', 'avril', 'mai', 'juin',
        'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre'];
    return '${j[now.weekday - 1]} ${now.day} ${m[now.month - 1]} ${now.year}';
  }
}

// ── DailyTrackingCard ─────────────────────────────────────────────────────────
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
    final over = remaining < 0;

    return Container(
      decoration: BoxDecoration(
        color: _kGreen,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(
          color: _kGreen.withValues(alpha: 0.3),
          blurRadius: 24, offset: const Offset(0, 8))],
      ),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        // ── Header ───────────────────────────────────────────────
        Row(children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('SUIVI DU JOUR', style: GoogleFonts.inter(
              color: _kMint, fontSize: 9, fontWeight: FontWeight.w700,
              letterSpacing: 2.5)),
            const SizedBox(height: 2),
            Text('Calories', style: GoogleFonts.outfit(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800,
              letterSpacing: -0.4)),
          ]),
          const Spacer(),
          GestureDetector(
            onTap: onConsulter,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: _kMint, borderRadius: BorderRadius.circular(50)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Text('Consulter', style: GoogleFonts.inter(
                  color: _kGreen, fontSize: 12, fontWeight: FontWeight.w700)),
                const SizedBox(width: 2),
                const Icon(LucideIcons.chevronRight, size: 13, color: _kGreen),
              ]),
            ),
          ),
        ]),

        const SizedBox(height: 18),

        // ── Donut + macros ────────────────────────────────────────
        Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          SizedBox(
            width: 118, height: 118,
            child: AnimatedBuilder(
              animation: anim,
              builder: (_, __) => CustomPaint(
                painter: DonutPainter(
                  proteinRatio: 0.25, carbsRatio: 0.54, fatRatio: 0.41,
                  animValue: anim.value),
                child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Text('$caloriesConsumed', style: GoogleFonts.outfit(
                    fontSize: 26, fontWeight: FontWeight.w800,
                    color: Colors.white, height: 1)),
                  Text('kcal', style: GoogleFonts.inter(fontSize: 11, color: _kMint)),
                ])),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _DarkMacroBar('Protéines', 25, 60, _kMint),
              const SizedBox(height: 9),
              _DarkMacroBar('Glucides', 128, 200, const Color(0xFF7BA7FF)),
              const SizedBox(height: 9),
              _DarkMacroBar('Lipides', 26, 60, const Color(0xFFFFB347)),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 7),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10)),
                child: Text(
                  over ? '${(-remaining).abs()} kcal surplus' : '$remaining kcal restantes',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700,
                    color: over ? const Color(0xFFFF8585) : _kMint)),
              ),
            ]),
          ),
        ]),

        const SizedBox(height: 16),

        // ── Actions ───────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14)),
          child: Row(children: [
            _ActionBtn(LucideIcons.camera,   'Photo',    onCamera),
            _ActionBtn(LucideIcons.qrCode,   'Scan',     onBarcode),
            _ActionBtn(LucideIcons.utensils, 'Recettes', onRecipes),
            _ActionBtn(LucideIcons.pencil,   'Manuel',   onEdit),
          ]),
        ),
      ]),
    );
  }
}

// ── MealCategoryCard ──────────────────────────────────────────────────────────
class MealCategoryCard extends StatelessWidget {
  final MealCategoryData data;
  final VoidCallback onTap;

  const MealCategoryCard({super.key, required this.data, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final over = data.remaining < 0;
    final pct  = data.pct.clamp(0.0, 1.0);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: _kWhite,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: _kBorder),
          boxShadow: [BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16, offset: const Offset(0, 4))],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          // ── Hero image 115px ──────────────────────────────────
          SizedBox(
            height: 115, width: double.infinity,
            child: Stack(fit: StackFit.expand, children: [
              Image.network(data.imageUrl, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: _kMintBg,
                  child: const Center(child: Icon(
                    LucideIcons.salad, color: _kMint, size: 28)))),

              // Gradient
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter, end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Color(0xCC0A2A18)],
                    stops: [0.25, 1.0]))),

              // Time pill + over badge
              Positioned(top: 10, left: 12, right: 12,
                child: Row(children: [
                  _TimePill(data.time),
                  const Spacer(),
                  if (over) _OverBadge(),
                ])),

              // Name + kcal
              Positioned(bottom: 10, left: 12, right: 12,
                child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Expanded(child: Text(data.name,
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.outfit(
                      fontSize: 16, fontWeight: FontWeight.w800,
                      color: Colors.white, letterSpacing: -0.3))),
                  const SizedBox(width: 8),
                  Column(crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min, children: [
                    Text('${data.consumed}', style: GoogleFonts.outfit(
                      fontSize: 18, fontWeight: FontWeight.w800,
                      color: Colors.white, height: 1)),
                    Text('/ ${data.budget} kcal', style: GoogleFonts.inter(
                      fontSize: 10,
                      color: Colors.white.withValues(alpha: 0.7))),
                  ]),
                ])),
            ]),
          ),

          // ── Thin progress bar ─────────────────────────────────
          LinearProgressIndicator(
            value: pct, minHeight: 3,
            backgroundColor: _kBorder,
            valueColor: AlwaysStoppedAnimation(
              over ? const Color(0xFFE03050) : _kGreen)),

          // ── Info chips ────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Row(children: [
              Expanded(child: _InfoChip(
                icon: LucideIcons.flame,
                label: over
                    ? '+${(-data.remaining).abs()} kcal dépassés'
                    : '${data.remaining} kcal restantes',
                color: over ? const Color(0xFFE03050) : _kGreen,
                bg: over ? const Color(0xFFFFEEEE) : _kMintBg)),
              const SizedBox(width: 8),
              _InfoChip(
                icon: LucideIcons.dumbbell,
                label: '${(data.proteinBudget - data.proteinConsumed).toStringAsFixed(0)}g prot.',
                color: _kText2, bg: const Color(0xFFF4F4F4)),
            ]),
          ),
        ]),
      ),
    );
  }
}

// ── RecipeCard (horizontal scroll) ───────────────────────────────────────────
class RecipeCard extends StatelessWidget {
  final RecipeItem recipe;
  final VoidCallback? onTap;
  const RecipeCard({super.key, required this.recipe, this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 162,
      decoration: BoxDecoration(
        color: recipe.bgColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(
          color: Colors.black.withValues(alpha: 0.06),
          blurRadius: 14, offset: const Offset(0, 4))],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(fit: StackFit.expand, children: [
        // Thumbnail
        Image.network(recipe.emoji,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            color: recipe.bgColor,
            child: const Center(child: Icon(
              LucideIcons.salad, color: Colors.white38, size: 36)))),

        // Gradient
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter, end: Alignment.bottomCenter,
              colors: [Colors.transparent, Color(0xDD000000)],
              stops: [0.35, 1.0]))),

        // Duration badge
        Positioned(top: 10, left: 10,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(8)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(LucideIcons.clock, size: 9, color: Colors.white),
              const SizedBox(width: 3),
              Text(recipe.duration, style: GoogleFonts.inter(
                fontSize: 9, color: Colors.white, fontWeight: FontWeight.w600)),
            ]))),

        // Difficulty badge
        Positioned(top: 10, right: 10,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
            decoration: BoxDecoration(
              color: _kMint.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(8)),
            child: Text(recipe.difficulty, style: GoogleFonts.inter(
              fontSize: 9, color: _kGreen, fontWeight: FontWeight.w700)))),

        // Name
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

// ── SectionHeader ─────────────────────────────────────────────────────────────
class SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAll;
  const SectionHeader({super.key, required this.title, this.onSeeAll});

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('RECETTES', style: GoogleFonts.inter(
          color: _kMint, fontSize: 9, fontWeight: FontWeight.w700,
          letterSpacing: 2.5)),
        const SizedBox(height: 1),
        Text(title, style: GoogleFonts.outfit(
          color: _kText1, fontSize: 20, fontWeight: FontWeight.w800,
          letterSpacing: -0.4)),
      ]),
      const Spacer(),
      GestureDetector(
        onTap: onSeeAll,
        child: Text('Tout voir', style: GoogleFonts.inter(
          fontSize: 12, fontWeight: FontWeight.w600, color: _kGreen))),
    ],
  );
}

// ── MacroRow (API kept for compatibility) ─────────────────────────────────────
class MacroRow extends StatelessWidget {
  final String label, value;
  final Color color;
  const MacroRow(this.label, this.value, this.color, {super.key});

  @override
  Widget build(BuildContext context) => Row(children: [
    Container(width: 9, height: 9,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color)),
    const SizedBox(width: 8),
    Expanded(child: Text(label, style: GoogleFonts.inter(
      fontSize: 12, color: _kText2))),
    Text(value, style: GoogleFonts.inter(
      fontSize: 12, fontWeight: FontWeight.w700, color: _kText1)),
  ]);
}

// ── Private helpers ───────────────────────────────────────────────────────────

class _DarkMacroBar extends StatelessWidget {
  final String label;
  final int value, max;
  final Color color;
  const _DarkMacroBar(this.label, this.value, this.max, this.color);

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: GoogleFonts.inter(fontSize: 10, color: Colors.white60)),
        Text('${value}g', style: GoogleFonts.inter(
          fontSize: 10, fontWeight: FontWeight.w700, color: color)),
      ]),
      const SizedBox(height: 4),
      ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: LinearProgressIndicator(
          value: (value / max).clamp(0.0, 1.0),
          minHeight: 4,
          backgroundColor: Colors.white.withValues(alpha: 0.12),
          valueColor: AlwaysStoppedAnimation(color))),
    ],
  );
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
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 18, color: _kMint),
          const SizedBox(height: 4),
          Text(label, style: GoogleFonts.inter(
            fontSize: 9, color: Colors.white60, fontWeight: FontWeight.w500)),
        ]),
      ),
    ),
  );
}

class _TimePill extends StatelessWidget {
  final String label;
  const _TimePill(this.label);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: 0.18),
      border: Border.all(color: Colors.white.withValues(alpha: 0.28), width: 0.5),
      borderRadius: BorderRadius.circular(20)),
    child: Text(label, style: GoogleFonts.inter(
      fontSize: 10, color: Colors.white, fontWeight: FontWeight.w600)),
  );
}

class _OverBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
    decoration: BoxDecoration(
      color: const Color(0xFFE03050).withValues(alpha: 0.9),
      borderRadius: BorderRadius.circular(20)),
    child: Text('Dépassé', style: GoogleFonts.inter(
      fontSize: 10, color: Colors.white, fontWeight: FontWeight.w700)),
  );
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color, bg;
  const _InfoChip({required this.icon, required this.label,
    required this.color, required this.bg});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
    decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 10, color: color),
      const SizedBox(width: 5),
      Flexible(child: Text(label,
        maxLines: 1, overflow: TextOverflow.ellipsis,
        style: GoogleFonts.inter(
          fontSize: 10, color: color, fontWeight: FontWeight.w600))),
    ]),
  );
}
