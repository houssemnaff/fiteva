// ignore_for_file: deprecated_member_use
import 'package:fiteva/core/nutrition/models.dart';
import 'package:fiteva/core/nutrition/nutrition_provider.dart';
import 'package:fiteva/screens/nutrition/nutrition_colors.dart';
import 'package:fiteva/screens/nutrition/recette_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'ajout_rapide_screen.dart';

// ── Palette ───────────────────────────────────────────────────────────────────
abstract class _C {
  static const bg       = Color(0xFFFEFEFE);
  static const surface  = Colors.white;
  static const border   = Color(0xFFECECEC);
  static const green    = Color(0xFF1C4D30);
  static const greenBg  = Color(0xFFEAF3EC);
  static const mint     = Color(0xFF7ABB98);
  static const textDark = Color(0xFF1A1A1A);
  static const textGrey = Color(0xFF6B7280);
  static const red      = Color(0xFFE03050);
  static const redBg    = Color(0xFFFFEEEE);
  static const blue     = Color(0xFF3B7FD4);
  static const blueBg   = Color(0xFFEBF2FC);
  static const amber    = Color(0xFFC47A00);
  static const amberBg  = Color(0xFFFFF3DC);
}

// ─────────────────────────────────────────────────────────────────────────────
//  SCREEN
// ─────────────────────────────────────────────────────────────────────────────
class SuiviNutritionScreen extends ConsumerStatefulWidget {
  final String? initialMealId;
  const SuiviNutritionScreen({super.key, this.initialMealId});

  @override
  ConsumerState<SuiviNutritionScreen> createState() =>
      _SuiviNutritionScreenState();
}

class _SuiviNutritionScreenState
    extends ConsumerState<SuiviNutritionScreen> {
  DateTime _selectedDate = DateTime.now();

  DateTime get _today =>
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

  bool get _isToday {
    final d = DateTime(
        _selectedDate.year, _selectedDate.month, _selectedDate.day);
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
    final next = DateTime(
        _selectedDate.year, _selectedDate.month, _selectedDate.day)
        .add(const Duration(days: 1));
    return !next.isAfter(_today);
  }

  static const _days   = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
  static const _months = ['jan', 'fév', 'mar', 'avr', 'mai', 'juin',
      'juil', 'août', 'sep', 'oct', 'nov', 'déc'];

  String _fmt(DateTime d) =>
      '${_days[d.weekday - 1]} ${d.day} ${_months[d.month - 1]}';

  String get _dateLabel =>
      _isToday ? 'Aujourd\'hui · ${_fmt(_selectedDate)}' : _fmt(_selectedDate);

  String get _key => dateKey(_selectedDate);

  // ── Go to ajout rapide ────────────────────────────────────────────────────
  Future<void> _goToAjout({MealType? preselected}) async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (_) => AjoutRapideScreen(
          initialTypeId: preselected?.id),
      ),
    );
    if (result == null || !mounted) return;

    final entries = result['entries'] as List<MealEntry>?;
    if (entries != null && entries.isNotEmpty) {
      for (final entry in entries) {
        ref.read(nutritionProvider.notifier).addMeal(entry);
      }
      HapticFeedback.mediumImpact();
    }
  }

  void _deleteMeal(MealEntry entry) {
    ref.read(nutritionProvider.notifier).deleteMeal(entry.id, _key);
    HapticFeedback.lightImpact();
  }

  List<MealType> get _visibleTypes {
    if (widget.initialMealId != null) {
      return [MealType.fromId(widget.initialMealId!)];
    }
    return MealType.values;
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final top     = MediaQuery.of(context).padding.top;
    final types   = _visibleTypes;
    final single  = widget.initialMealId != null;
    final totals  = ref.watch(dailyTotalsProvider(_key));
    final profile = ref.watch(userProfileProvider);

    final nc = NutritionColors.of(context);

    return Scaffold(
      backgroundColor: nc.bg,
      body: Column(children: [
        _Header(
          top:       top,
          dateLabel: _dateLabel,
          title:     single ? types.first.label : 'Nutrition',
          onBack:    () => Navigator.pop(context),
          onPrev:    _prevDay,
          onNext:    _canGoNext ? _nextDay : null,
        ),

        Expanded(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Summary card — vue complète uniquement
              if (!single)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: _SummaryCard(
                      totals:  totals,
                      profile: profile,
                    ),
                  ),
                ),

              // Meal group cards
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, i) {
                    final type    = types[i];
                    final entries = ref.watch(mealsForTypeProvider(
                        (dateKey: _key, type: type)));
                    final typeTotals = DailyTotals.from(entries);
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                      child: _MealGroupCard(
                        mealType:        type,
                        entries:         entries,
                        typeTotals:      typeTotals,
                        showBudgetBadge: single,
                        onAdd: () =>
                            _goToAjout(preselected: type),
                        onTapEntry: (entry) =>
                            Navigator.push(context, MaterialPageRoute(
                              builder: (_) => RecipeDetailScreen(
                                recipe: entry))),
                        onDeleteEntry: _deleteMeal,
                      ),
                    );
                  },
                  childCount: types.length,
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 60)),
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
  final double top;
  final String dateLabel, title;
  final VoidCallback onBack, onPrev;
  final VoidCallback? onNext;

  const _Header({
    required this.top, required this.dateLabel, required this.title,
    required this.onBack, required this.onPrev, required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final nc = NutritionColors.of(context);
    return Container(
    color: nc.surface,
    padding: EdgeInsets.fromLTRB(20, top + 14, 20, 14),
    child: Column(children: [
      Row(children: [
        GestureDetector(
          onTap: onBack,
          child: Container(
            width: 38, height: 38,
            decoration: BoxDecoration(
              color: nc.mintBg, borderRadius: BorderRadius.circular(12)),
            child: const Icon(LucideIcons.chevronLeft, color: _C.green, size: 20)),
        ),
        const SizedBox(width: 14),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('SUIVI', style: GoogleFonts.inter(
            color: _C.mint, fontSize: 9, fontWeight: FontWeight.w700,
            letterSpacing: 2.5)),
          Text(title, style: GoogleFonts.outfit(
            color: _C.green, fontSize: 20,
            fontWeight: FontWeight.w800, letterSpacing: -0.4)),
        ]),
        const Spacer(),
      ]),
      const SizedBox(height: 12),
      Row(children: [
        _NavBtn(icon: LucideIcons.chevronLeft, onTap: onPrev),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: nc.mintBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _C.mint.withOpacity(0.35))),
            child: Row(children: [
              const Icon(LucideIcons.calendarDays, size: 13, color: _C.green),
              const SizedBox(width: 8),
              Expanded(child: Text(dateLabel,
                maxLines: 1, overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 13, fontWeight: FontWeight.w600, color: _C.green))),
            ]),
          ),
        ),
        const SizedBox(width: 10),
        _NavBtn(
          icon: LucideIcons.chevronRight,
          onTap: onNext, disabled: onNext == null),
      ]),
    ]),
    );
  }
}

class _NavBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final bool disabled;
  const _NavBtn({required this.icon, this.onTap, this.disabled = false});

  @override
  Widget build(BuildContext context) {
    final nc = NutritionColors.of(context);
    return GestureDetector(
    onTap: onTap,
    child: Container(
      width: 34, height: 34,
      decoration: BoxDecoration(
        color: nc.surface, shape: BoxShape.circle,
        border: Border.all(color: nc.border)),
      child: Icon(icon, size: 16,
        color: disabled ? nc.border : nc.text2)),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  SUMMARY CARD
// ─────────────────────────────────────────────────────────────────────────────
class _SummaryCard extends StatelessWidget {
  final DailyTotals totals;
  final UserProfile profile;
  const _SummaryCard({required this.totals, required this.profile});

  @override
  Widget build(BuildContext context) {
    final goal    = profile.dailyKcal;
    final pct     = (totals.calories / goal).clamp(0.0, 1.0);
    final over    = totals.calories > goal;
    final remain  = goal - totals.calories;

    final nc = NutritionColors.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: nc.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: nc.border),
        boxShadow: nc.isDark ? [] : [BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 16, offset: const Offset(0, 4))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        Row(children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('CALORIES DU JOUR', style: GoogleFonts.inter(
              color: _C.mint, fontSize: 9, fontWeight: FontWeight.w700,
              letterSpacing: 2.5)),
            const SizedBox(height: 2),
            Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text('${totals.calories}', style: GoogleFonts.outfit(
                fontSize: 36, fontWeight: FontWeight.w800,
                color: _C.green, height: 1)),
              const SizedBox(width: 6),
              Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Text('/ $goal kcal', style: GoogleFonts.inter(
                  fontSize: 13, color: nc.text2))),
            ]),
          ]),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: over ? _C.redBg : nc.mintBg,
              borderRadius: BorderRadius.circular(20)),
            child: Text(
              over ? '+${-remain} surplus' : '$remain restantes',
              style: GoogleFonts.inter(
                fontSize: 11, fontWeight: FontWeight.w700,
                color: over ? _C.red : _C.green))),
        ]),

        const SizedBox(height: 14),
        ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: LinearProgressIndicator(
            value: pct, minHeight: 6,
            backgroundColor: nc.border,
            valueColor: AlwaysStoppedAnimation(over ? _C.red : _C.green))),

        const SizedBox(height: 14),

        // Macro chips
        Row(children: [
          _MacroChip('Protéines', '${totals.protein}g / ${profile.dailyProtein}g',
            _C.green, _C.greenBg),
          const SizedBox(width: 8),
          _MacroChip('Glucides', '${totals.carbs}g / ${profile.dailyCarbs}g',
            _C.blue, _C.blueBg),
          const SizedBox(width: 8),
          _MacroChip('Lipides', '${totals.fat}g / ${profile.dailyFat}g',
            _C.amber, _C.amberBg),
        ]),
      ]),
    );
  }
}

class _MacroChip extends StatelessWidget {
  final String label, value;
  final Color color, bg;
  const _MacroChip(this.label, this.value, this.color, this.bg);

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 9),
      decoration: BoxDecoration(
        color: bg, borderRadius: BorderRadius.circular(10)),
      child: Column(children: [
        Text(value, style: GoogleFonts.outfit(
          fontSize: 12, fontWeight: FontWeight.w800, color: color)),
        const SizedBox(height: 1),
        Text(label, style: GoogleFonts.inter(
          fontSize: 9, color: color.withOpacity(0.7))),
      ]),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
//  MEAL GROUP CARD
// ─────────────────────────────────────────────────────────────────────────────
class _MealGroupCard extends StatelessWidget {
  final MealType mealType;
  final List<MealEntry> entries;
  final DailyTotals typeTotals;
  final bool showBudgetBadge;
  final VoidCallback onAdd;
  final void Function(MealEntry) onTapEntry;
  final void Function(MealEntry) onDeleteEntry;

  const _MealGroupCard({
    required this.mealType, required this.entries,
    required this.typeTotals, this.showBudgetBadge = false,
    required this.onAdd, required this.onTapEntry,
    required this.onDeleteEntry,
  });

  int get _budget => mealType.budgetKcal;
  bool get _over  => typeTotals.calories > _budget;
  double get _pct => (typeTotals.calories / _budget).clamp(0.0, 1.2);

  IconData get _icon => switch (mealType) {
    MealType.breakfast => LucideIcons.coffee,
    MealType.lunch     => LucideIcons.utensils,
    MealType.snack     => LucideIcons.apple,
    MealType.dinner    => LucideIcons.moon,
  };

  @override
  Widget build(BuildContext context) {
    final nc = NutritionColors.of(context);
    return Container(
      decoration: BoxDecoration(
        color: nc.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: nc.border),
        boxShadow: nc.isDark ? [] : [BoxShadow(
          color: Colors.black.withOpacity(0.03),
          blurRadius: 12, offset: const Offset(0, 3))]),
      child: Column(children: [

        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
          child: Row(children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: _over ? _C.redBg : nc.mintBg,
                borderRadius: BorderRadius.circular(12)),
              child: Icon(_icon, size: 18,
                color: _over ? _C.red : _C.green)),
            const SizedBox(width: 12),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(mealType.label, style: GoogleFonts.outfit(
                fontSize: 16, fontWeight: FontWeight.w800, color: nc.text1)),
              Text(entries.isEmpty ? 'Vide' : '${entries.length} aliment${entries.length > 1 ? 's' : ''}',
                style: GoogleFonts.inter(fontSize: 11, color: nc.text2)),
            ])),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text('${typeTotals.calories}', style: GoogleFonts.outfit(
                fontSize: 18, fontWeight: FontWeight.w800,
                color: _over ? _C.red : _C.green, height: 1)),
              Text('/ $_budget kcal', style: GoogleFonts.inter(
                fontSize: 10, color: nc.text2)),
            ]),
          ]),
        ),

        // Progress bar
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: _pct.clamp(0.0, 1.0), minHeight: 4,
              backgroundColor: nc.border,
              valueColor: AlwaysStoppedAnimation(_over ? _C.red : _C.mint))),
        ),

        // Budget badge (single meal view)
        if (showBudgetBadge)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Row(children: [
              Icon(
                _over ? LucideIcons.alertTriangle : LucideIcons.checkCircle,
                size: 12, color: _over ? _C.red : _C.green),
              const SizedBox(width: 6),
              Text(
                _over
                    ? '+${typeTotals.calories - _budget} kcal dépassées'
                    : '${_budget - typeTotals.calories} kcal restantes',
                style: GoogleFonts.inter(
                  fontSize: 12, fontWeight: FontWeight.w600,
                  color: _over ? _C.red : _C.green)),
            ]),
          ),

        // Macro summary row (when entries exist)
        if (entries.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            child: Row(children: [
              _MiniMacro('P', '${typeTotals.protein}g', _C.green, _C.greenBg),
              const SizedBox(width: 6),
              _MiniMacro('G', '${typeTotals.carbs}g', _C.blue, _C.blueBg),
              const SizedBox(width: 6),
              _MiniMacro('L', '${typeTotals.fat}g', _C.amber, _C.amberBg),
            ]),
          ),

        // Entry rows
        if (entries.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
            child: Column(
              children: entries.map((entry) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: _EntryRow(
                  entry: entry,
                  onTap: () => onTapEntry(entry),
                  onDelete: () => onDeleteEntry(entry)))).toList()),
          ),

        // Add button
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 14),
          child: GestureDetector(
            onTap: onAdd,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 11),
              decoration: BoxDecoration(
                color: _C.greenBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _C.mint.withOpacity(0.4))),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Icon(LucideIcons.plus, size: 14, color: _C.green),
                const SizedBox(width: 7),
                Text('Ajouter un aliment', style: GoogleFonts.inter(
                  fontSize: 13, fontWeight: FontWeight.w600, color: _C.green)),
              ]),
            ),
          ),
        ),
      ]),
    );
  }
}

class _MiniMacro extends StatelessWidget {
  final String letter, value;
  final Color color, bg;
  const _MiniMacro(this.letter, this.value, this.color, this.bg);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Text(letter, style: GoogleFonts.inter(
        fontSize: 10, fontWeight: FontWeight.w800, color: color)),
      const SizedBox(width: 4),
      Text(value, style: GoogleFonts.inter(
        fontSize: 10, fontWeight: FontWeight.w600, color: color)),
    ]),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
//  ENTRY ROW
// ─────────────────────────────────────────────────────────────────────────────
class _EntryRow extends StatelessWidget {
  final MealEntry entry;
  final VoidCallback onTap, onDelete;
  const _EntryRow({required this.entry, required this.onTap, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final nc = NutritionColors.of(context);
    return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: nc.surface2,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: nc.border)),
      child: Row(children: [
        // Category emoji
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            color: nc.mintBg, borderRadius: BorderRadius.circular(10)),
          child: Center(child: Text(
            entry.food.category.emoji,
            style: const TextStyle(fontSize: 18)))),
        const SizedBox(width: 10),

        // Name + grams + macros
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(entry.food.name,
            maxLines: 1, overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontSize: 13, fontWeight: FontWeight.w600, color: nc.text1)),
          const SizedBox(height: 2),
          Row(children: [
            Text('${entry.grams.round()}g', style: GoogleFonts.inter(
              fontSize: 10, color: nc.text2)),
            const SizedBox(width: 8),
            _Macro('P ${entry.protein}g', _C.green, _C.greenBg),
            const SizedBox(width: 3),
            _Macro('G ${entry.carbs}g', _C.blue, _C.blueBg),
            const SizedBox(width: 3),
            _Macro('L ${entry.fat}g', _C.amber, _C.amberBg),
          ]),
        ])),

        const SizedBox(width: 8),

        // Kcal
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          decoration: BoxDecoration(
            color: _C.green, borderRadius: BorderRadius.circular(8)),
          child: Text('${entry.calories}', style: GoogleFonts.outfit(
            fontSize: 12, fontWeight: FontWeight.w800, color: Colors.white))),

        const SizedBox(width: 6),

        // Delete
        GestureDetector(
          onTap: onDelete,
          behavior: HitTestBehavior.opaque,
          child: Container(
            width: 30, height: 30,
            decoration: BoxDecoration(
              color: _C.redBg, borderRadius: BorderRadius.circular(8)),
            child: const Icon(LucideIcons.trash2, size: 13, color: _C.red))),
      ]),
    ),
    );
  }
}

class _Macro extends StatelessWidget {
  final String label;
  final Color color, bg;
  const _Macro(this.label, this.color, this.bg);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
    decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(5)),
    child: Text(label, style: GoogleFonts.inter(
      fontSize: 9, fontWeight: FontWeight.w600, color: color)));
}
