// ignore_for_file: deprecated_member_use
import 'package:fiteva/core/nutrition/models.dart';
import 'package:fiteva/core/nutrition/nutrition_provider.dart';
import 'package:fiteva/screens/nutrition/nutrition_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'ajout_rapide_screen.dart';
import '../../l10n/lang.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/points_provider.dart';
import '../../widgets/points_toast.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  SCREEN
// ─────────────────────────────────────────────────────────────────────────────
class SuiviNutritionScreen extends ConsumerStatefulWidget {
  final String? initialMealId;
  final DateTime? initialDate;
  const SuiviNutritionScreen({super.key, this.initialMealId, this.initialDate});

  @override
  ConsumerState<SuiviNutritionScreen> createState() =>
      _SuiviNutritionScreenState();
}

class _SuiviNutritionScreenState extends ConsumerState<SuiviNutritionScreen> {
  late DateTime _selectedDate = widget.initialDate ?? DateTime.now();

  DateTime get _today =>
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

  bool get _isToday {
    final d = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
    return d == _today;
  }

  void _prevDay() =>
      setState(() => _selectedDate = _selectedDate.subtract(const Duration(days: 1)));

  void _nextDay() {
    final next = _selectedDate.add(const Duration(days: 1));
    if (!DateTime(next.year, next.month, next.day).isAfter(_today)) {
      setState(() => _selectedDate = next);
    }
  }

  bool get _canGoNext {
    final next = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day)
        .add(const Duration(days: 1));
    return !next.isAfter(_today);
  }

  String _fmt(DateTime d) {
    final l10n = AppL10n(Lang.code);
    return '${l10n.daysShort[d.weekday - 1]} ${d.day} ${l10n.monthsShort[d.month - 1]}';
  }

  String get _dateLabel {
    final l10n = AppL10n(Lang.code);
    return _isToday ? '${l10n.nutritionTodayLabel} · ${_fmt(_selectedDate)}' : _fmt(_selectedDate);
  }

  String get _key => dateKey(_selectedDate);

  Future<void> _goToAjout({MealType? preselected}) async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (_) => AjoutRapideScreen(
          initialTypeId: preselected?.id,
          targetDate: _selectedDate,
        ),
      ),
    );
    if (result == null || !mounted) return;
    final entries = result['entries'] as List<MealEntry>?;
    if (entries != null && entries.isNotEmpty) {
      // Snapshot calories BEFORE adding new entries — sur le jour réellement
      // ciblé (_key), pas toujours "aujourd'hui".
      final nutrition = ref.read(nutritionProvider);
      final calGoal   = nutrition.userProfile.dailyKcal;
      final calBefore = ref.read(dailyTotalsProvider(_key)).calories;

      for (final entry in entries) {
        ref.read(nutritionProvider.notifier).addMeal(entry);
      }
      ref.read(pointsProvider.notifier).rewardMealLogged();

      // Calories AFTER
      final calAfter = ref.read(dailyTotalsProvider(_key)).calories;

      // La récompense "objectif atteint" ne concerne que la journée en
      // cours — pas de sens de la déclencher en éditant rétroactivement un
      // jour passé.
      final goalJustReached = _isToday
          && calGoal > 0
          && calBefore < calGoal
          && calAfter >= calGoal;

      if (goalJustReached) {
        final granted = await ref.read(pointsProvider.notifier).rewardCalorieGoalReached();
        if (granted && mounted) {
          PointsToast.show(context, PointsAmounts.calorieGoalReached,
              label: 'Objectif calorique atteint ! 🎉');
          maybeShowLevelUpToast(context, ref);
        }
      }

      HapticFeedback.mediumImpact();
    }
  }

  void _deleteMeal(MealEntry entry) {
    ref.read(nutritionProvider.notifier).deleteMeal(entry.id, _key);
    HapticFeedback.lightImpact();
  }

  List<MealType> get _visibleTypes {
    if (widget.initialMealId != null) return [MealType.fromId(widget.initialMealId!)];
    return MealType.values;
  }

  @override
  Widget build(BuildContext context) {
    final top     = MediaQuery.of(context).padding.top;
    final types   = _visibleTypes;
    final single  = widget.initialMealId != null;
    final totals  = ref.watch(dailyTotalsProvider(_key));
    final profile = ref.watch(userProfileProvider);
    final nc      = NutritionColors.of(context);

    return Scaffold(
      backgroundColor: nc.bg,
      body: Column(children: [
        _Header(
          nc:        nc,
          top:       top,
          dateLabel: _dateLabel,
          title:     single ? types.first.labelFor(Lang.code) : 'Nutrition',
          onBack:    () => Navigator.pop(context),
          onPrev:    _prevDay,
          onNext:    _canGoNext ? _nextDay : null,
        ),

        Expanded(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              if (!single)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: _SummaryCard(nc: nc, totals: totals, profile: profile),
                  ),
                ),

              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, i) {
                    final type       = types[i];
                    final entries    = ref.watch(mealsForTypeProvider(
                        (dateKey: _key, type: type)));
                    final typeTotals = DailyTotals.from(entries);
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                      child: _MealGroupCard(
                        nc:              nc,
                        mealType:        type,
                        entries:         entries,
                        typeTotals:      typeTotals,
                        dailyKcal:       profile.dailyKcal,
                        showBudgetBadge: single,
                        onAdd:           () => _goToAjout(preselected: type),
                        onTapEntry:      (entry) => showModalBottomSheet(
                          context: context,
                          backgroundColor: Colors.transparent,
                          builder: (_) => _MealEntryDetailSheet(nc: nc, entry: entry),
                        ),
                        onDeleteEntry:   _deleteMeal,
                      ),
                    );
                  },
                  childCount: types.length,
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 80)),
            ],
          ),
        ),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  HEADER
// ─────────────────────────────────────────────────────────────────────────────
class _Header extends StatelessWidget {
  final NutritionColors nc;
  final double top;
  final String dateLabel, title;
  final VoidCallback onBack, onPrev;
  final VoidCallback? onNext;

  const _Header({
    required this.nc, required this.top, required this.dateLabel,
    required this.title, required this.onBack, required this.onPrev,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: nc.surface,
      padding: EdgeInsets.fromLTRB(16, top + 10, 16, 10),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Row(children: [
          GestureDetector(
            onTap: onBack,
            child: Container(
              width: 34, height: 34,
              decoration: BoxDecoration(
                color: nc.mintBg, borderRadius: BorderRadius.circular(10)),
              child: Icon(LucideIcons.chevronLeft, color: nc.greenFg, size: 18)),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(title, style: GoogleFonts.outfit(
            color: nc.text1, fontSize: 17,
            fontWeight: FontWeight.w800, letterSpacing: -0.3))),
          _NavBtn(nc: nc, icon: LucideIcons.chevronLeft, onTap: onPrev),
          const SizedBox(width: 4),
          Text(dateLabel, style: GoogleFonts.inter(
            fontSize: 11, fontWeight: FontWeight.w600, color: nc.text2)),
          const SizedBox(width: 4),
          _NavBtn(nc: nc, icon: LucideIcons.chevronRight,
            onTap: onNext, disabled: onNext == null),
        ]),
      ]),
    );
  }
}

class _NavBtn extends StatelessWidget {
  final NutritionColors nc;
  final IconData icon;
  final VoidCallback? onTap;
  final bool disabled;
  const _NavBtn({required this.nc, required this.icon,
      this.onTap, this.disabled = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28, height: 28,
        decoration: BoxDecoration(
          color: nc.surface2, shape: BoxShape.circle),
        child: Icon(icon, size: 14,
          color: disabled ? nc.border : nc.text2)),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  SUMMARY CARD
// ─────────────────────────────────────────────────────────────────────────────
class _SummaryCard extends StatelessWidget {
  final NutritionColors nc;
  final DailyTotals totals;
  final UserProfile profile;
  const _SummaryCard({required this.nc, required this.totals, required this.profile});

  @override
  Widget build(BuildContext context) {
    final l10n  = AppL10n(Lang.code);
    final goal   = profile.dailyKcal;
    final pct    = goal > 0 ? (totals.calories / goal).clamp(0.0, 1.0) : 0.0;
    final over   = totals.calories > goal;
    final remain = goal - totals.calories;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: nc.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: nc.border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text('${totals.calories}', style: GoogleFonts.outfit(
            fontSize: 28, fontWeight: FontWeight.w800, color: nc.text1, height: 1)),
          const SizedBox(width: 4),
          Text('/ $goal kcal', style: GoogleFonts.inter(
            fontSize: 11, color: nc.text2)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: over ? nc.redBg : nc.mintBg,
              borderRadius: BorderRadius.circular(12)),
            child: Text(
              over ? '+${-remain}' : '$remain ${l10n.nutritionLeft}',
              style: GoogleFonts.inter(
                fontSize: 10, fontWeight: FontWeight.w700,
                color: over ? nc.redFg : nc.greenFg))),
        ]),

        const SizedBox(height: 10),

        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: pct, minHeight: 5,
            backgroundColor: nc.border,
            valueColor: AlwaysStoppedAnimation(over ? nc.redFg : nc.greenFg))),

        const SizedBox(height: 10),

        Row(children: [
          _MacroChip(nc: nc, label: l10n.nutritionProtein,
            value: '${totals.protein}g',
            goal: '${profile.dailyProtein}g',
            fg: nc.greenFg, bg: nc.mintBg),
          const SizedBox(width: 6),
          _MacroChip(nc: nc, label: l10n.nutritionCarbs,
            value: '${totals.carbs}g',
            goal: '${profile.dailyCarbs}g',
            fg: nc.blueFg, bg: nc.blueBg),
          const SizedBox(width: 6),
          _MacroChip(nc: nc, label: l10n.nutritionFat,
            value: '${totals.fat}g',
            goal: '${profile.dailyFat}g',
            fg: nc.amberFg, bg: nc.amberBg),
        ]),
      ]),
    );
  }
}


class _MacroChip extends StatelessWidget {
  final NutritionColors nc;
  final String label, value, goal;
  final Color fg, bg;
  const _MacroChip({required this.nc, required this.label,
      required this.value, required this.goal,
      required this.fg, required this.bg});

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
      decoration: BoxDecoration(
        color: bg, borderRadius: BorderRadius.circular(10)),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(label[0], style: GoogleFonts.inter(
          fontSize: 9, fontWeight: FontWeight.w800, color: fg)),
        const SizedBox(width: 4),
        Text(value, style: GoogleFonts.outfit(
          fontSize: 12, fontWeight: FontWeight.w700, color: fg)),
        Text(' /$goal', style: GoogleFonts.inter(
          fontSize: 9, color: fg.withOpacity(0.5))),
      ]),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
//  MEAL ENTRY DETAIL SHEET — vraies données de l'aliment loggé (au lieu de
//  rediriger vers l'écran recette qui affichait un contenu factice sans
//  rapport avec ce qui a réellement été mangé).
// ─────────────────────────────────────────────────────────────────────────────
class _MealEntryDetailSheet extends StatelessWidget {
  final NutritionColors nc;
  final MealEntry entry;
  const _MealEntryDetailSheet({required this.nc, required this.entry});

  Widget _macroRow(String label, int value, String unit, Color fg, Color bg) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
        child: Column(children: [
          Text('$value$unit', style: GoogleFonts.outfit(
              fontSize: 15, fontWeight: FontWeight.w800, color: fg)),
          const SizedBox(height: 2),
          Text(label, style: GoogleFonts.inter(fontSize: 10, color: fg.withOpacity(0.75))),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n(Lang.code);
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.all(12),
        padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).padding.bottom + 20),
        decoration: BoxDecoration(color: nc.surface, borderRadius: BorderRadius.circular(24)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(width: 36, height: 4,
                  decoration: BoxDecoration(color: nc.border, borderRadius: BorderRadius.circular(2))),
            ),
            const SizedBox(height: 20),
            Text(entry.mealType.labelFor(Lang.code), style: GoogleFonts.inter(
                color: NutritionColors.mint, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 2)),
            const SizedBox(height: 4),
            Text(entry.food.name, style: GoogleFonts.outfit(
                fontSize: 20, fontWeight: FontWeight.w800, color: nc.text1, letterSpacing: -0.4)),
            const SizedBox(height: 4),
            Text('${entry.grams.toStringAsFixed(0)} g',
                style: GoogleFonts.inter(fontSize: 13, color: nc.text2)),
            const SizedBox(height: 20),
            Container(height: 1, color: nc.border),
            const SizedBox(height: 20),
            Row(children: [
              Text('${entry.calories}', style: GoogleFonts.outfit(
                  fontSize: 32, fontWeight: FontWeight.w800, color: nc.text1, height: 1)),
              const SizedBox(width: 6),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text('kcal', style: GoogleFonts.inter(fontSize: 13, color: nc.text2)),
              ),
            ]),
            const SizedBox(height: 16),
            Row(children: [
              _macroRow(l10n.nutritionProtein, entry.protein, 'g', nc.greenFg, nc.mintBg),
              const SizedBox(width: 8),
              _macroRow(l10n.nutritionCarbs, entry.carbs, 'g', nc.blueFg, nc.blueBg),
              const SizedBox(width: 8),
              _macroRow(l10n.nutritionFat, entry.fat, 'g', nc.amberFg, nc.amberBg),
            ]),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  MEAL GROUP CARD
// ─────────────────────────────────────────────────────────────────────────────
class _MealGroupCard extends StatelessWidget {
  final NutritionColors nc;
  final MealType mealType;
  final List<MealEntry> entries;
  final DailyTotals typeTotals;
  final int dailyKcal;
  final bool showBudgetBadge;
  final VoidCallback onAdd;
  final void Function(MealEntry) onTapEntry;
  final void Function(MealEntry) onDeleteEntry;

  const _MealGroupCard({
    required this.nc, required this.mealType, required this.entries,
    required this.typeTotals, required this.dailyKcal, this.showBudgetBadge = false,
    required this.onAdd, required this.onTapEntry, required this.onDeleteEntry,
  });

  int    get _budget => mealType.budgetKcalFor(dailyKcal);
  bool   get _over   => typeTotals.calories > _budget;
  double get _pct    => _budget > 0 ? (typeTotals.calories / _budget).clamp(0.0, 1.2) : 0.0;

  IconData get _icon => switch (mealType) {
    MealType.breakfast => LucideIcons.coffee,
    MealType.lunch     => LucideIcons.utensils,
    MealType.snack     => LucideIcons.apple,
    MealType.dinner    => LucideIcons.moon,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n(Lang.code);
    return Container(
      decoration: BoxDecoration(
        color: nc.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: nc.border)),
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
          child: Row(children: [
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(
                color: _over ? nc.redBg : nc.mintBg,
                borderRadius: BorderRadius.circular(10)),
              child: Icon(_icon, size: 15,
                color: _over ? nc.redFg : nc.greenFg)),
            const SizedBox(width: 10),
            Expanded(child: Text(mealType.labelFor(Lang.code), style: GoogleFonts.outfit(
              fontSize: 14, fontWeight: FontWeight.w800, color: nc.text1))),
            Text('${typeTotals.calories}', style: GoogleFonts.outfit(
              fontSize: 16, fontWeight: FontWeight.w800,
              color: _over ? nc.redFg : nc.text1, height: 1)),
            Text(' / $_budget', style: GoogleFonts.inter(
              fontSize: 10, color: nc.text2)),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onAdd,
              child: Container(
                width: 28, height: 28,
                decoration: BoxDecoration(
                  color: nc.mintBg, shape: BoxShape.circle),
                child: Icon(LucideIcons.plus, size: 13, color: nc.greenFg))),
          ]),
        ),

        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: _pct.clamp(0.0, 1.0), minHeight: 3,
              backgroundColor: nc.border,
              valueColor: AlwaysStoppedAnimation(
                  _over ? nc.redFg : NutritionColors.mint))),
        ),

        if (entries.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
            child: Column(
              children: entries.map((entry) => _EntryRow(
                nc: nc,
                entry: entry,
                onTap: () => onTapEntry(entry),
                onDelete: () => onDeleteEntry(entry),
              )).toList()),
          ),

        if (entries.isEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
            child: GestureDetector(
              onTap: onAdd,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 18),
                decoration: BoxDecoration(
                  color: nc.mintBg.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: nc.greenFg.withOpacity(0.15),
                    strokeAlign: BorderSide.strokeAlignInside),
                ),
                child: Column(children: [
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: nc.mintBg,
                      borderRadius: BorderRadius.circular(12)),
                    child: Icon(_icon, size: 18,
                      color: nc.greenFg.withOpacity(0.5))),
                  const SizedBox(height: 8),
                  Text(l10n.nutritionNoFood, style: GoogleFonts.inter(
                    fontSize: 12, color: nc.text2)),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: nc.greenFg.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8)),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(LucideIcons.plus, size: 12, color: nc.greenFg),
                      const SizedBox(width: 5),
                      Text('Ajouter', style: GoogleFonts.inter(
                        fontSize: 12, fontWeight: FontWeight.w700,
                        color: nc.greenFg)),
                    ]),
                  ),
                ]),
              ),
            ),
          ),

        const SizedBox(height: 10),
      ]),
    );
  }
}


// ─────────────────────────────────────────────────────────────────────────────
//  ENTRY ROW
// ─────────────────────────────────────────────────────────────────────────────
class _EntryRow extends StatelessWidget {
  final NutritionColors nc;
  final MealEntry entry;
  final VoidCallback onTap, onDelete;
  const _EntryRow({required this.nc, required this.entry,
      required this.onTap, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(entry.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: nc.redBg, borderRadius: BorderRadius.circular(10)),
        child: Icon(LucideIcons.trash2, size: 14, color: nc.redFg)),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: nc.surface2,
            borderRadius: BorderRadius.circular(10)),
          child: Row(children: [
            Text(entry.food.category.emoji, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 8),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.food.name,
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 12, fontWeight: FontWeight.w600, color: nc.text1)),
                Text('${entry.grams.round()}g', style: GoogleFonts.inter(
                  fontSize: 10, color: nc.text2)),
              ])),
            Text('${entry.calories}', style: GoogleFonts.outfit(
              fontSize: 13, fontWeight: FontWeight.w800, color: nc.text1)),
            Text(' kcal', style: GoogleFonts.inter(
              fontSize: 9, color: nc.text2)),
          ]),
        ),
      ),
    );
  }
}

