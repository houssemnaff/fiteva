// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../models/workout_model.dart';
import '../../providers/mock_data_provider.dart';

// ═══════════════════════════════════════════════════════════════
// WORKOUT CATEGORY
// ═══════════════════════════════════════════════════════════════

class WorkoutCategory {
  final String id;
  final String label;
  final String subtitle;
  final IconData icon;
  final Color color;
  final bool isRest;

  const WorkoutCategory({
    required this.id,
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.isRest = false,
  });
}

const _categories = [
  WorkoutCategory(
    id: 'yoga',
    label: 'Yoga',
    subtitle: 'Équilibre & sérénité',
    icon: LucideIcons.sprout,
    color: Color(0xFF8B5CF6),
  ),
  WorkoutCategory(
    id: 'cardio',
    label: 'Cardio',
    subtitle: 'Endurance & bruler',
    icon: LucideIcons.heartPulse,
    color: Color(0xFFEF4444),
  ),
  WorkoutCategory(
    id: 'full_body',
    label: 'Full Body',
    subtitle: 'Corps complet',
    icon: LucideIcons.dumbbell,
    color: Color(0xFF1C4D30),
  ),
  WorkoutCategory(
    id: 'zones',
    label: 'Abdos / Jambes',
    subtitle: 'Zones ciblées',
    icon: LucideIcons.target,
    color: Color(0xFFF59E0B),
  ),
  WorkoutCategory(
    id: 'stretching',
    label: 'Stretching',
    subtitle: 'Souplesse & récup',
    icon: LucideIcons.wind,
    color: Color(0xFF06B6D4),
  ),
  WorkoutCategory(
    id: 'rest',
    label: 'Repos',
    subtitle: 'Récupération',
    icon: LucideIcons.moon,
    color: Color(0xFF6B7280),
    isRest: true,
  ),
];

WorkoutCategory? _catById(String? id) =>
    id == null ? null : _categories.firstWhere((c) => c.id == id,
        orElse: () => _categories.last);

// ═══════════════════════════════════════════════════════════════
// MODEL
// ═══════════════════════════════════════════════════════════════

enum DayStatus { empty, rest, planned, done }

class DayPlan {
  final int weekdayIndex; // 0 = Monday
  final String dayShort;  // 'LUN'
  final String dayFull;   // 'Lundi'
  final DateTime date;
  final DayStatus status;
  final String? categoryId;
  final WorkoutModel? workout;

  const DayPlan({
    required this.weekdayIndex,
    required this.dayShort,
    required this.dayFull,
    required this.date,
    this.status = DayStatus.empty,
    this.categoryId,
    this.workout,
  });

  DayPlan copyWith({
    DayStatus? status,
    String? categoryId,
    WorkoutModel? workout,
    bool clearWorkout = false,
    bool clearCategory = false,
  }) => DayPlan(
    weekdayIndex: weekdayIndex,
    dayShort: dayShort,
    dayFull: dayFull,
    date: date,
    status: status ?? this.status,
    categoryId: clearCategory ? null : (categoryId ?? this.categoryId),
    workout: clearWorkout ? null : (workout ?? this.workout),
  );

  bool get isToday {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  WorkoutCategory? get category => _catById(categoryId);
}

// ═══════════════════════════════════════════════════════════════
// PROVIDER
// ═══════════════════════════════════════════════════════════════

class WeeklyPlanNotifier extends Notifier<List<DayPlan>> {
  static const _shorts = ['LUN', 'MAR', 'MER', 'JEU', 'VEN', 'SAM', 'DIM'];
  static const _fulls = [
    'Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche'
  ];

  @override
  List<DayPlan> build() {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    return List.generate(7, (i) => DayPlan(
      weekdayIndex: i,
      dayShort: _shorts[i],
      dayFull: _fulls[i],
      date: monday.add(Duration(days: i)),
    ));
  }

  void assign(int index, String categoryId, [WorkoutModel? workout]) {
    final updated = List<DayPlan>.from(state);
    final isRest = categoryId == 'rest';
    updated[index] = updated[index].copyWith(
      status: isRest ? DayStatus.rest : DayStatus.planned,
      categoryId: categoryId,
      workout: workout,
      clearWorkout: workout == null && !isRest,
    );
    state = updated;
  }

  void remove(int index) {
    final updated = List<DayPlan>.from(state);
    updated[index] = updated[index].copyWith(
      status: DayStatus.empty,
      clearCategory: true,
      clearWorkout: true,
    );
    state = updated;
  }

  void markDone(int index) {
    final updated = List<DayPlan>.from(state);
    updated[index] = updated[index].copyWith(status: DayStatus.done);
    state = updated;
  }

  void swap(int a, int b) {
    final updated = List<DayPlan>.from(state);
    final catA = updated[a].categoryId;
    final wA   = updated[a].workout;
    final sA   = updated[a].status;
    final catB = updated[b].categoryId;
    final wB   = updated[b].workout;
    final sB   = updated[b].status;

    updated[a] = DayPlan(
      weekdayIndex: updated[a].weekdayIndex,
      dayShort: updated[a].dayShort,
      dayFull: updated[a].dayFull,
      date: updated[a].date,
      status: sB,
      categoryId: catB,
      workout: wB,
    );
    updated[b] = DayPlan(
      weekdayIndex: updated[b].weekdayIndex,
      dayShort: updated[b].dayShort,
      dayFull: updated[b].dayFull,
      date: updated[b].date,
      status: sA,
      categoryId: catA,
      workout: wA,
    );
    state = updated;
  }
}

final weeklyPlanProvider =
    NotifierProvider<WeeklyPlanNotifier, List<DayPlan>>(WeeklyPlanNotifier.new);

// ═══════════════════════════════════════════════════════════════
// SCREEN
// ═══════════════════════════════════════════════════════════════

class WeeklyPlanScreen extends ConsumerStatefulWidget {
  const WeeklyPlanScreen({super.key});

  @override
  ConsumerState<WeeklyPlanScreen> createState() => _WeeklyPlanScreenState();
}

class _WeeklyPlanScreenState extends ConsumerState<WeeklyPlanScreen> {
  int _selected = -1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final plans = ref.read(weeklyPlanProvider);
      final todayIdx = plans.indexWhere((d) => d.isToday);
      if (todayIdx >= 0) setState(() => _selected = todayIdx);
    });
  }

  void _openPicker(int index) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (_) => _WorkoutPickerSheet(
        dayFull: ref.read(weeklyPlanProvider)[index].dayFull,
        onPick: (catId, workout) {
          ref.read(weeklyPlanProvider.notifier).assign(index, catId, workout);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showDayOptions(BuildContext ctx, int index, DayPlan plan) {
    final cs = Theme.of(ctx).colorScheme;
    final plans = ref.read(weeklyPlanProvider);

    showModalBottomSheet<void>(
      context: ctx,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.fromLTRB(
            20, 16, 20, 16 + MediaQuery.of(ctx).padding.bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // handle
            Center(child: Container(
              width: 36, height: 4,
              decoration: BoxDecoration(
                color: cs.outline.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2)),
            )),
            const SizedBox(height: 16),
            Text(plan.dayFull, style: GoogleFonts.outfit(
              fontSize: 17, fontWeight: FontWeight.w800, color: cs.onSurface)),
            const SizedBox(height: 16),

            _OptionTile(
              icon: LucideIcons.refreshCw,
              label: plan.categoryId == null
                  ? 'Ajouter un workout'
                  : 'Changer le workout',
              color: cs.primary,
              onTap: () { Navigator.pop(ctx); _openPicker(index); },
            ),

            if (plan.status == DayStatus.planned || plan.status == DayStatus.rest)
              _OptionTile(
                icon: LucideIcons.checkCircle,
                label: 'Marquer comme terminé',
                color: const Color(0xFF34D399),
                onTap: () {
                  ref.read(weeklyPlanProvider.notifier).markDone(index);
                  Navigator.pop(ctx);
                },
              ),

            _OptionTile(
              icon: LucideIcons.arrowLeftRight,
              label: 'Déplacer vers un autre jour',
              color: const Color(0xFF3B82F6),
              onTap: () {
                Navigator.pop(ctx);
                _showSwapPicker(index, plans);
              },
            ),

            if (plan.categoryId != null)
              _OptionTile(
                icon: LucideIcons.trash2,
                label: 'Supprimer la séance',
                color: cs.error,
                onTap: () {
                  ref.read(weeklyPlanProvider.notifier).remove(index);
                  Navigator.pop(ctx);
                },
              ),
          ],
        ),
      ),
    );
  }

  void _showSwapPicker(int fromIndex, List<DayPlan> plans) {
    final cs = Theme.of(context).colorScheme;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.fromLTRB(
            20, 16, 20, 16 + MediaQuery.of(context).padding.bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(child: Container(
              width: 36, height: 4,
              decoration: BoxDecoration(
                color: cs.outline.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2)),
            )),
            const SizedBox(height: 16),
            Text('Déplacer vers…', style: GoogleFonts.outfit(
              fontSize: 17, fontWeight: FontWeight.w800, color: cs.onSurface)),
            const SizedBox(height: 12),
            ...List.generate(7, (i) {
              if (i == fromIndex) return const SizedBox.shrink();
              final d = plans[i];
              return GestureDetector(
                onTap: () {
                  ref.read(weeklyPlanProvider.notifier).swap(fromIndex, i);
                  Navigator.pop(context);
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: cs.outline),
                  ),
                  child: Row(children: [
                    Text(d.dayShort, style: GoogleFonts.outfit(
                      fontSize: 13, fontWeight: FontWeight.w800,
                      color: cs.primary)),
                    const SizedBox(width: 10),
                    Expanded(child: Text(d.dayFull, style: GoogleFonts.inter(
                      fontSize: 14, color: cs.onSurface))),
                    if (d.category != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: d.category!.color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Text(d.category!.label, style: GoogleFonts.inter(
                          fontSize: 10, fontWeight: FontWeight.w700,
                          color: d.category!.color)),
                      )
                    else
                      Text('Vide', style: GoogleFonts.inter(
                        fontSize: 12,
                        color: cs.onSurface.withValues(alpha: 0.35))),
                    const SizedBox(width: 8),
                    Icon(LucideIcons.chevronsRight, size: 14,
                        color: cs.onSurface.withValues(alpha: 0.3)),
                  ]),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final plans = ref.watch(weeklyPlanProvider);
    final selectedPlan = _selected >= 0 ? plans[_selected] : null;

    final doneCount = plans.where((d) => d.status == DayStatus.done).length;
    final plannedCount = plans.where(
        (d) => d.status == DayStatus.planned || d.status == DayStatus.rest).length;
    final totalCal = plans
        .where((d) => d.workout != null && d.status == DayStatus.done)
        .fold(0, (s, d) => s + int.tryParse(d.workout!.calories)!);

    return Scaffold(
      backgroundColor: cs.surface,
      body: CustomScrollView(
        slivers: [

          // ── App Bar ────────────────────────────────────────
          SliverAppBar(
            pinned: true,
            backgroundColor: cs.surface,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            leading: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                margin: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest,
                  shape: BoxShape.circle,
                ),
                child: Icon(LucideIcons.arrowLeft,
                    size: 16, color: cs.onSurface),
              ),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('PLANNING', style: GoogleFonts.inter(
                  fontSize: 9, fontWeight: FontWeight.w700,
                  color: cs.primary, letterSpacing: 3.5)),
                Text('Ma semaine', style: GoogleFonts.outfit(
                  fontSize: 20, fontWeight: FontWeight.w800,
                  color: cs.onSurface, letterSpacing: -0.5, height: 1.1)),
              ],
            ),
          ),

          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ── Stats strip ────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: cs.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(children: [
                      Expanded(child: _StatBox(
                        value: '$doneCount', label: 'Terminées',
                        icon: LucideIcons.checkCircle,
                        color: const Color(0xFF34D399))),
                      Container(width: 1, height: 34,
                          color: Colors.white.withValues(alpha: 0.15)),
                      Expanded(child: _StatBox(
                        value: '$plannedCount', label: 'Planifiées',
                        icon: LucideIcons.calendarDays,
                        color: Colors.white)),
                      Container(width: 1, height: 34,
                          color: Colors.white.withValues(alpha: 0.15)),
                      Expanded(child: _StatBox(
                        value: '${totalCal}k', label: 'kcal',
                        icon: LucideIcons.flame,
                        color: const Color(0xFFFBBF24))),
                    ]),
                  ),
                ),

                const SizedBox(height: 24),

                // ── Day strip ──────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 0, 12),
                  child: Text('Cette semaine', style: GoogleFonts.inter(
                    fontSize: 9, fontWeight: FontWeight.w700,
                    color: cs.onSurface.withValues(alpha: 0.4),
                    letterSpacing: 2)),
                ),
                SizedBox(
                  height: 86,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: 7,
                    itemBuilder: (_, i) {
                      final d = plans[i];
                      final sel = _selected == i;
                      final cat = d.category;
                      final dotColor = d.status == DayStatus.done
                          ? const Color(0xFF34D399)
                          : cat != null
                              ? cat.color
                              : cs.outline;
                      return GestureDetector(
                        onTap: () => setState(() => _selected = i),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          width: 58,
                          margin: const EdgeInsets.only(right: 10),
                          decoration: BoxDecoration(
                            color: sel
                                ? (cat?.color ?? cs.primary)
                                : cs.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: sel
                                  ? Colors.transparent
                                  : (cat != null
                                      ? cat.color.withValues(alpha: 0.35)
                                      : cs.outline),
                              width: 1.5),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(d.dayShort, style: GoogleFonts.inter(
                                fontSize: 10, fontWeight: FontWeight.w700,
                                color: sel
                                    ? Colors.white.withValues(alpha: 0.8)
                                    : cs.onSurface.withValues(alpha: 0.45),
                                letterSpacing: 0.5)),
                              const SizedBox(height: 4),
                              Text('${d.date.day}', style: GoogleFonts.outfit(
                                fontSize: 20, fontWeight: FontWeight.w800,
                                color: sel ? Colors.white : cs.onSurface,
                                height: 1)),
                              const SizedBox(height: 5),
                              // Status dot
                              Container(
                                width: 6, height: 6,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: sel
                                      ? Colors.white.withValues(alpha: 0.7)
                                      : dotColor,
                                ),
                              ),
                              if (d.isToday) ...[
                                const SizedBox(height: 3),
                                Container(
                                  width: 4, height: 4,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: sel
                                        ? Colors.white
                                        : cs.primary,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 24),

                // ── Selected day detail ────────────────────
                if (selectedPlan != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 260),
                      child: _DayDetailCard(
                        key: ValueKey(_selected),
                        plan: selectedPlan,
                        index: _selected,
                        onAdd: () => _openPicker(_selected),
                        onOptions: () => _showDayOptions(
                            context, _selected, selectedPlan),
                      ),
                    ),
                  ),

                const SizedBox(height: 28),

                // ── Weekly list ───────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                  child: Text('PROGRAMME SEMAINE', style: GoogleFonts.inter(
                    fontSize: 9, fontWeight: FontWeight.w700,
                    color: cs.onSurface.withValues(alpha: 0.4),
                    letterSpacing: 2)),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                  child: Column(
                    children: List.generate(7, (i) {
                      final d = plans[i];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _WeekRow(
                          plan: d,
                          isSelected: _selected == i,
                          onTap: () => setState(() => _selected = i),
                          onLongPress: () =>
                              _showDayOptions(context, i, d),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// DAY DETAIL CARD
// ═══════════════════════════════════════════════════════════════

class _DayDetailCard extends StatelessWidget {
  final DayPlan plan;
  final int index;
  final VoidCallback onAdd;
  final VoidCallback onOptions;

  const _DayDetailCard({
    super.key,
    required this.plan,
    required this.index,
    required this.onAdd,
    required this.onOptions,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final cat = plan.category;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: cat != null
              ? cat.color.withValues(alpha: 0.3)
              : cs.outline),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        // Header
        Container(
          padding: const EdgeInsets.fromLTRB(18, 16, 12, 16),
          decoration: BoxDecoration(
            color: cat != null
                ? cat.color.withValues(alpha: 0.08)
                : cs.surfaceContainerHighest,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Row(children: [
            if (cat != null) ...[
              Container(
                width: 38, height: 38,
                decoration: BoxDecoration(
                  color: cat.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(cat.icon, size: 18, color: cat.color),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(plan.dayFull, style: GoogleFonts.outfit(
                  fontSize: 16, fontWeight: FontWeight.w800,
                  color: cs.onSurface, letterSpacing: -0.3)),
                Text(
                  plan.isToday ? "Aujourd'hui" : _formatDate(plan.date),
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: plan.isToday ? cs.primary : cs.onSurface.withValues(alpha: 0.4))),
              ],
            )),
            // Status badge
            if (plan.status != DayStatus.empty)
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusColor(plan.status, cat).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(
                    color: _statusColor(plan.status, cat).withValues(alpha: 0.3)),
                ),
                child: Text(_statusLabel(plan.status), style: GoogleFonts.inter(
                  fontSize: 10, fontWeight: FontWeight.w700,
                  color: _statusColor(plan.status, cat))),
              ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onOptions,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: cs.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: cs.outline),
                ),
                child: Icon(LucideIcons.ellipsis,
                    size: 14, color: cs.onSurface.withValues(alpha: 0.6)),
              ),
            ),
          ]),
        ),

        Padding(
          padding: const EdgeInsets.all(16),
          child: cat == null
              ? _EmptyDayBody(onAdd: onAdd, cs: cs)
              : cat.isRest
                  ? _RestDayBody(cat: cat, cs: cs, onEdit: onAdd)
                  : _PlannedDayBody(
                      plan: plan, cat: cat, cs: cs, onEdit: onAdd),
        ),
      ]),
    );
  }

  Color _statusColor(DayStatus s, WorkoutCategory? cat) {
    switch (s) {
      case DayStatus.done:    return const Color(0xFF34D399);
      case DayStatus.planned: return cat?.color ?? const Color(0xFF1C4D30);
      case DayStatus.rest:    return const Color(0xFF6B7280);
      case DayStatus.empty:   return const Color(0xFF9CA3AF);
    }
  }

  String _statusLabel(DayStatus s) {
    switch (s) {
      case DayStatus.done:    return 'Terminé';
      case DayStatus.planned: return 'Planifié';
      case DayStatus.rest:    return 'Repos';
      case DayStatus.empty:   return 'Vide';
    }
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}

// Empty body
class _EmptyDayBody extends StatelessWidget {
  final VoidCallback onAdd;
  final ColorScheme cs;
  const _EmptyDayBody({required this.onAdd, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 28),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(children: [
          Icon(LucideIcons.calendarPlus, size: 36,
              color: cs.onSurface.withValues(alpha: 0.15)),
          const SizedBox(height: 8),
          Text('Aucune séance prévue', style: GoogleFonts.inter(
            fontSize: 14, color: cs.onSurface.withValues(alpha: 0.35))),
        ]),
      ),
      const SizedBox(height: 12),
      GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          onAdd();
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: cs.primary,
            borderRadius: BorderRadius.circular(50),
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(LucideIcons.plus, color: Colors.white, size: 16),
            const SizedBox(width: 8),
            Text('Planifier une séance', style: GoogleFonts.outfit(
              fontSize: 14, fontWeight: FontWeight.w800,
              color: Colors.white)),
          ]),
        ),
      ),
    ]);
  }
}

// Rest body
class _RestDayBody extends StatelessWidget {
  final WorkoutCategory cat;
  final ColorScheme cs;
  final VoidCallback onEdit;
  const _RestDayBody({
    required this.cat, required this.cs, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cat.color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cat.color.withValues(alpha: 0.15)),
      ),
      child: Column(children: [
        Icon(LucideIcons.moon, size: 36, color: cat.color),
        const SizedBox(height: 10),
        Text('Jour de repos', style: GoogleFonts.outfit(
          fontSize: 16, fontWeight: FontWeight.w800, color: cat.color)),
        const SizedBox(height: 4),
        Text('Laisse ton corps récupérer', style: GoogleFonts.inter(
          fontSize: 12, color: cs.onSurface.withValues(alpha: 0.45))),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: onEdit,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: cat.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(50),
              border: Border.all(color: cat.color.withValues(alpha: 0.3)),
            ),
            child: Text('Changer', style: GoogleFonts.outfit(
              fontSize: 13, fontWeight: FontWeight.w700, color: cat.color)),
          ),
        ),
      ]),
    );
  }
}

// Planned body (with category + optional specific workout)
class _PlannedDayBody extends ConsumerWidget {
  final DayPlan plan;
  final WorkoutCategory cat;
  final ColorScheme cs;
  final VoidCallback onEdit;
  const _PlannedDayBody({
    required this.plan, required this.cat,
    required this.cs, required this.onEdit});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final w = plan.workout;
    final isDone = plan.status == DayStatus.done;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Category banner
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cat.color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: cat.color.withValues(alpha: 0.2)),
        ),
        child: Row(children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: cat.color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(cat.icon, color: cat.color, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(cat.label, style: GoogleFonts.outfit(
                fontSize: 16, fontWeight: FontWeight.w800,
                color: cs.onSurface, letterSpacing: -0.3)),
              Text(cat.subtitle, style: GoogleFonts.inter(
                fontSize: 12,
                color: cs.onSurface.withValues(alpha: 0.45))),
            ],
          )),
          if (isDone)
            Icon(LucideIcons.checkCircle, color: const Color(0xFF34D399),
                size: 22),
        ]),
      ),

      // Specific workout (if any)
      if (w != null) ...[
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Stack(children: [
            Image.asset(w.imageUrl,
              width: double.infinity, height: 130, fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                height: 130, color: cat.color.withValues(alpha: 0.1),
                child: Icon(cat.icon, size: 40, color: cat.color))),
            Positioned.fill(child: DecoratedBox(decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.transparent,
                    Colors.black.withValues(alpha: 0.65)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter)))),
            if (isDone)
              Positioned.fill(child: Container(
                color: Colors.black.withValues(alpha: 0.4),
                child: const Center(child: Icon(LucideIcons.checkCircle,
                    color: Color(0xFF34D399), size: 44)))),
            Positioned(bottom: 12, left: 12, right: 12,
              child: Row(children: [
                Expanded(child: Text(w.title, style: GoogleFonts.outfit(
                  color: Colors.white, fontSize: 14,
                  fontWeight: FontWeight.w800))),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8)),
                  child: Text(w.level, style: GoogleFonts.inter(
                    color: Colors.white, fontSize: 10,
                    fontWeight: FontWeight.w700))),
              ])),
          ]),
        ),
        const SizedBox(height: 10),
        Row(children: [
          _MiniPill(icon: LucideIcons.timer,
              label: w.duration, color: cat.color),
          const SizedBox(width: 8),
          _MiniPill(icon: LucideIcons.flame,
              label: '${w.calories} kcal',
              color: const Color(0xFFEF4444)),
        ]),
      ],

      const SizedBox(height: 14),

      // Action button
      GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          onEdit();
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isDone
                ? cs.surfaceContainerHighest
                : cat.color,
            borderRadius: BorderRadius.circular(50),
            border: isDone
                ? Border.all(color: cs.outline)
                : null,
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center,
              children: [
            Icon(isDone ? LucideIcons.refreshCw : LucideIcons.refreshCw,
                color: isDone ? cs.onSurface.withValues(alpha: 0.4)
                    : Colors.white,
                size: 14),
            const SizedBox(width: 8),
            Text('Changer', style: GoogleFonts.outfit(
              fontSize: 13, fontWeight: FontWeight.w800,
              color: isDone
                  ? cs.onSurface.withValues(alpha: 0.4)
                  : Colors.white)),
          ]),
        ),
      ),
    ]);
  }
}

// ═══════════════════════════════════════════════════════════════
// WEEKLY ROW
// ═══════════════════════════════════════════════════════════════

class _WeekRow extends StatelessWidget {
  final DayPlan plan;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _WeekRow({
    required this.plan,
    required this.isSelected,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final cat = plan.category;
    final isDone = plan.status == DayStatus.done;

    return GestureDetector(
      onTap: onTap,
      onLongPress: () {
        HapticFeedback.mediumImpact();
        onLongPress();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? (cat?.color ?? cs.primary).withValues(alpha: 0.07)
              : cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(18),
          border: Border(
            left: BorderSide(
              color: cat != null
                  ? (isDone ? const Color(0xFF34D399) : cat.color)
                  : cs.outline,
              width: isSelected ? 4 : 2),
            top: BorderSide(color: cs.outline),
            right: BorderSide(color: cs.outline),
            bottom: BorderSide(color: cs.outline),
          ),
        ),
        child: Row(children: [
          // Day label
          SizedBox(width: 38, child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(plan.dayShort, style: GoogleFonts.inter(
                fontSize: 10, fontWeight: FontWeight.w700,
                color: cat != null
                    ? (isDone ? const Color(0xFF34D399) : cat.color)
                    : cs.onSurface.withValues(alpha: 0.35),
                letterSpacing: 0.5)),
              Text('${plan.date.day}', style: GoogleFonts.outfit(
                fontSize: 18, fontWeight: FontWeight.w800,
                color: cs.onSurface, height: 1.1)),
              if (plan.isToday)
                Container(width: 14, height: 2,
                    decoration: BoxDecoration(
                      color: cs.primary,
                      borderRadius: BorderRadius.circular(1))),
            ],
          )),

          const SizedBox(width: 12),

          // Content
          Expanded(child: cat == null
            ? Text('Aucune séance', style: GoogleFonts.inter(
                fontSize: 13, color: cs.onSurface.withValues(alpha: 0.3)))
            : cat.isRest
              ? Row(children: [
                  Icon(LucideIcons.moon, size: 13,
                      color: cat.color.withValues(alpha: 0.6)),
                  const SizedBox(width: 6),
                  Text('Repos', style: GoogleFonts.inter(
                    fontSize: 13, color: cat.color.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w500)),
                ])
              : Column(crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  Row(children: [
                    Icon(cat.icon, size: 12, color: cat.color),
                    const SizedBox(width: 6),
                    Text(cat.label, style: GoogleFonts.outfit(
                      fontSize: 13, fontWeight: FontWeight.w700,
                      color: cs.onSurface)),
                  ]),
                  if (plan.workout != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(plan.workout!.title, style: GoogleFonts.inter(
                        fontSize: 11, color: cs.onSurface.withValues(alpha: 0.5)),
                        maxLines: 1, overflow: TextOverflow.ellipsis)),
                ])),

          const SizedBox(width: 10),

          // Right: status + duration
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            if (isDone)
              Icon(LucideIcons.checkCircle, size: 16,
                  color: const Color(0xFF34D399))
            else if (cat != null && !cat.isRest)
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: cat.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Text('Planifié', style: GoogleFonts.inter(
                  fontSize: 9, fontWeight: FontWeight.w700,
                  color: cat.color))),
            if (plan.workout != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(plan.workout!.duration, style: GoogleFonts.inter(
                  fontSize: 10,
                  color: cs.onSurface.withValues(alpha: 0.35)))),
          ]),
        ]),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// WORKOUT PICKER BOTTOM SHEET
// ═══════════════════════════════════════════════════════════════

class _WorkoutPickerSheet extends ConsumerStatefulWidget {
  final String dayFull;
  final void Function(String categoryId, WorkoutModel? workout) onPick;

  const _WorkoutPickerSheet({
    required this.dayFull,
    required this.onPick,
  });

  @override
  ConsumerState<_WorkoutPickerSheet> createState() =>
      _WorkoutPickerSheetState();
}

class _WorkoutPickerSheetState extends ConsumerState<_WorkoutPickerSheet> {
  String? _selectedCatId;
  String _search = '';

  List<WorkoutModel> get _workoutsForCat {
    final all = ref.read(workoutsProvider);
    final cat = _categories.firstWhere((c) => c.id == _selectedCatId!,
        orElse: () => _categories.first);
    if (cat.isRest) return [];
    final keyword = cat.id == 'full_body'
        ? 'full'
        : cat.id == 'zones'
            ? ''
            : cat.label.toLowerCase();
    return all
        .where((w) =>
            w.category.toLowerCase().contains(keyword) ||
            w.title.toLowerCase().contains(keyword))
        .toList();
  }

  List<WorkoutModel> get _filtered {
    if (_search.isEmpty) return _workoutsForCat;
    final q = _search.toLowerCase();
    return _workoutsForCat
        .where((w) =>
            w.title.toLowerCase().contains(q) ||
            w.category.toLowerCase().contains(q))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final h = MediaQuery.of(context).size.height;
    final bottom = MediaQuery.of(context).padding.bottom;

    return Container(
      constraints: BoxConstraints(maxHeight: h * 0.88),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [

        // Handle
        Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Center(child: Container(
            width: 36, height: 4,
            decoration: BoxDecoration(
              color: cs.outline.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2)),
          )),
        ),

        // Title
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
          child: Row(children: [
            if (_selectedCatId != null)
              GestureDetector(
                onTap: () => setState(() {
                  _selectedCatId = null;
                  _search = '';
                }),
                child: Container(
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(LucideIcons.arrowLeft,
                      size: 14, color: cs.onSurface),
                ),
              ),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_selectedCatId == null
                    ? widget.dayFull
                    : _catById(_selectedCatId)!.label,
                  style: GoogleFonts.outfit(fontSize: 20,
                    fontWeight: FontWeight.w800, color: cs.onSurface)),
                Text(_selectedCatId == null
                    ? 'Choisir un type de séance'
                    : 'Sélectionner un workout',
                  style: GoogleFonts.inter(fontSize: 12,
                    color: cs.onSurface.withValues(alpha: 0.45))),
              ],
            )),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest,
                  shape: BoxShape.circle,
                ),
                child: Icon(LucideIcons.x, size: 14, color: cs.onSurface),
              ),
            ),
          ]),
        ),

        Flexible(
          child: _selectedCatId == null
              ? _CategoryGrid(
                  onSelect: (catId) {
                    if (catId == 'rest') {
                      widget.onPick('rest', null);
                      return;
                    }
                    setState(() => _selectedCatId = catId);
                  },
                )
              : _WorkoutList(
                  filtered: _filtered,
                  search: _search,
                  onSearch: (q) => setState(() => _search = q),
                  selectedCatId: _selectedCatId!,
                  cs: cs,
                  onPick: (w) => widget.onPick(_selectedCatId!, w),
                  onPickCatOnly: () =>
                      widget.onPick(_selectedCatId!, null),
                  bottom: bottom,
                ),
        ),
      ]),
    );
  }
}

// ── Category grid ──────────────────────────────────────────────

class _CategoryGrid extends StatelessWidget {
  final void Function(String catId) onSelect;
  const _CategoryGrid({required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      child: GridView.builder(
        shrinkWrap: true,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.55,
        ),
        itemCount: _categories.length,
        itemBuilder: (_, i) {
          final cat = _categories[i];
          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              onSelect(cat.id);
            },
            child: Container(
              decoration: BoxDecoration(
                color: cat.color.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                    color: cat.color.withValues(alpha: 0.25)),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: cat.color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(cat.icon, size: 18, color: cat.color),
                  ),
                  const Spacer(),
                  Text(cat.label, style: GoogleFonts.outfit(
                    fontSize: 14, fontWeight: FontWeight.w800,
                    color: cs.onSurface, letterSpacing: -0.2)),
                  Text(cat.subtitle, style: GoogleFonts.inter(
                    fontSize: 10,
                    color: cs.onSurface.withValues(alpha: 0.45)),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── Workout list inside picker ─────────────────────────────────

class _WorkoutList extends StatelessWidget {
  final List<WorkoutModel> filtered;
  final String search;
  final ValueChanged<String> onSearch;
  final String selectedCatId;
  final ColorScheme cs;
  final void Function(WorkoutModel) onPick;
  final VoidCallback onPickCatOnly;
  final double bottom;

  const _WorkoutList({
    required this.filtered,
    required this.search,
    required this.onSearch,
    required this.selectedCatId,
    required this.cs,
    required this.onPick,
    required this.onPickCatOnly,
    required this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    final cat = _catById(selectedCatId)!;
    return Column(children: [
      // Search bar
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
        child: Container(
          height: 42,
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(50),
            border: Border.all(color: cs.outline),
          ),
          child: Row(children: [
            const SizedBox(width: 14),
            Icon(LucideIcons.search, size: 14,
                color: cs.onSurface.withValues(alpha: 0.35)),
            const SizedBox(width: 10),
            Expanded(child: TextField(
              onChanged: onSearch,
              style: GoogleFonts.inter(fontSize: 13, color: cs.onSurface),
              decoration: InputDecoration(
                hintText: 'Rechercher…',
                hintStyle: GoogleFonts.inter(
                  fontSize: 13, color: cs.onSurface.withValues(alpha: 0.3)),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            )),
          ]),
        ),
      ),

      // "Without specific workout" shortcut
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
        child: GestureDetector(
          onTap: onPickCatOnly,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: cat.color.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: cat.color.withValues(alpha: 0.2)),
            ),
            child: Row(children: [
              Icon(cat.icon, size: 16, color: cat.color),
              const SizedBox(width: 10),
              Expanded(child: Text('${cat.label} — sans workout précis',
                style: GoogleFonts.inter(fontSize: 13,
                  color: cs.onSurface, fontWeight: FontWeight.w500))),
              Icon(LucideIcons.chevronRight, size: 14,
                  color: cs.onSurface.withValues(alpha: 0.3)),
            ]),
          ),
        ),
      ),

      Expanded(
        child: filtered.isEmpty
            ? Center(child: Text('Aucun workout disponible',
                style: GoogleFonts.inter(
                  color: cs.onSurface.withValues(alpha: 0.35), fontSize: 14)))
            : ListView.builder(
                padding: EdgeInsets.fromLTRB(20, 0, 20, 20 + bottom),
                itemCount: filtered.length,
                itemBuilder: (_, i) {
                  final w = filtered[i];
                  return GestureDetector(
                    onTap: () => onPick(w),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: cs.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: cs.outline),
                      ),
                      child: Row(children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.asset(w.imageUrl,
                            width: 58, height: 58, fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 58, height: 58,
                              color: cat.color.withValues(alpha: 0.1),
                              child: Icon(cat.icon, color: cat.color, size: 24))),
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(w.title, style: GoogleFonts.outfit(
                              fontSize: 14, fontWeight: FontWeight.w700,
                              color: cs.onSurface)),
                            const SizedBox(height: 4),
                            Row(children: [
                              Icon(LucideIcons.timer, size: 11,
                                  color: cs.onSurface.withValues(alpha: 0.4)),
                              const SizedBox(width: 3),
                              Text(w.duration, style: GoogleFonts.inter(
                                fontSize: 11,
                                color: cs.onSurface.withValues(alpha: 0.45))),
                              const SizedBox(width: 8),
                              Icon(LucideIcons.flame, size: 11,
                                  color: const Color(0xFFEF4444)),
                              const SizedBox(width: 3),
                              Text('${w.calories} kcal', style: GoogleFonts.inter(
                                fontSize: 11,
                                color: cs.onSurface.withValues(alpha: 0.45))),
                            ]),
                          ],
                        )),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 9, vertical: 3),
                          decoration: BoxDecoration(
                            color: cat.color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: Text(w.level, style: GoogleFonts.inter(
                            fontSize: 9, fontWeight: FontWeight.w700,
                            color: cat.color)),
                        ),
                      ]),
                    ),
                  );
                },
              ),
      ),
    ]);
  }
}

// ═══════════════════════════════════════════════════════════════
// OPTION TILE (action sheet row)
// ═══════════════════════════════════════════════════════════════

class _OptionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _OptionTile({
    required this.icon, required this.label,
    required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.15)),
        ),
        child: Row(children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, size: 15, color: color),
          ),
          const SizedBox(width: 12),
          Text(label, style: GoogleFonts.inter(
            fontSize: 14, fontWeight: FontWeight.w600,
            color: cs.onSurface)),
          const Spacer(),
          Icon(LucideIcons.chevronRight, size: 14,
              color: cs.onSurface.withValues(alpha: 0.25)),
        ]),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// SMALL HELPERS
// ═══════════════════════════════════════════════════════════════

class _StatBox extends StatelessWidget {
  final String value, label;
  final IconData icon;
  final Color color;
  const _StatBox({
    required this.value, required this.label,
    required this.icon, required this.color});

  @override
  Widget build(BuildContext context) => Column(children: [
    Icon(icon, size: 16, color: color),
    const SizedBox(height: 4),
    Text(value, style: GoogleFonts.outfit(
      fontSize: 18, fontWeight: FontWeight.w800,
      color: Colors.white, letterSpacing: -0.5)),
    Text(label, style: GoogleFonts.inter(
      fontSize: 10, color: Colors.white.withValues(alpha: 0.65))),
  ]);
}

class _MiniPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _MiniPill({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 11, color: color),
        const SizedBox(width: 5),
        Text(label, style: GoogleFonts.inter(
          fontSize: 11, fontWeight: FontWeight.w600,
          color: cs.onSurface.withValues(alpha: 0.7))),
      ]),
    );
  }
}
