// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../l10n/app_localizations.dart';
import '../../models/home_program_model.dart';
import '../../providers/mock_data_provider.dart';
import '../../providers/weekly_plan_provider.dart';
import 'programme_detail_screen.dart';

// ═══════════════════════════════════════════════════════════════
// PROGRAM CATEGORY (catégories de programmes du catalogue + "Repos")
// ═══════════════════════════════════════════════════════════════

class ProgramCategory {
  final String id;
  final String label;
  final IconData icon;
  final Color color;
  final bool isRest;

  const ProgramCategory({
    required this.id,
    required this.label,
    required this.icon,
    required this.color,
    this.isRest = false,
  });
}

const _categories = [
  ProgramCategory(
    id: 'home',
    label: 'Maison',
    icon: LucideIcons.house,
    color: Color(0xFF1C4D30),
  ),
  ProgramCategory(
    id: 'salle',
    label: 'Salle',
    icon: LucideIcons.dumbbell,
    color: Color(0xFFEF4444),
  ),
  ProgramCategory(
    id: 'dance',
    label: 'Danse',
    icon: LucideIcons.music,
    color: Color(0xFF8B5CF6),
  ),
  ProgramCategory(
    id: 'recuperation',
    label: 'Récupération',
    icon: LucideIcons.heartPulse,
    color: Color(0xFF06B6D4),
  ),
  ProgramCategory(
    id: 'grossesse',
    label: 'Grossesse',
    icon: LucideIcons.baby,
    color: Color(0xFFF59E0B),
  ),
  ProgramCategory(
    id: 'rest',
    label: 'Repos',
    icon: LucideIcons.moon,
    color: Color(0xFF6B7280),
    isRest: true,
  ),
];

ProgramCategory? _catById(String? id) {
  if (id == null) return null;
  try { return _categories.firstWhere((c) => c.id == id); }
  catch (_) { return null; }
}

// ═══════════════════════════════════════════════════════════════
// MODEL EXTENSION (category helper only)
// ═══════════════════════════════════════════════════════════════

extension DayPlanCategory on DayPlan {
  ProgramCategory? get category => _catById(categoryId);
}


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
      builder: (_) => _ProgramPickerSheet(
        dayFull: ref.read(weeklyPlanProvider)[index].dayFull,
        onPick: (program) {
          ref.read(weeklyPlanProvider.notifier).assignProgram(index, program);
          Navigator.pop(context);
        },
        onPickRest: () {
          ref.read(weeklyPlanProvider.notifier).assign(index, 'rest');
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
                  ? 'Choisir un programme'
                  : 'Changer le programme',
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
            Text(ref.read(l10nProvider).weeklyDeplacer, style: GoogleFonts.outfit(
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
                      Text(ref.read(l10nProvider).weeklyVide, style: GoogleFonts.inter(
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
    final l10n = ref.watch(l10nProvider);
    final plans = ref.watch(weeklyPlanProvider);
    final selectedPlan = _selected >= 0 ? plans[_selected] : null;

    final doneCount = plans.where((d) => d.status == DayStatus.done).length;
    final plannedCount = plans.where(
        (d) => d.status == DayStatus.planned || d.status == DayStatus.rest).length;
    final totalPts = plans
        .where((d) => d.program != null && d.status == DayStatus.done)
        .fold(0, (s, d) => s + d.program!.totalPoints);

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
                Text(l10n.weeklyPlanTitle, style: GoogleFonts.inter(
                  fontSize: 9, fontWeight: FontWeight.w700,
                  color: cs.primary, letterSpacing: 3.5)),
                Text(l10n.weeklyMaSemaine, style: GoogleFonts.outfit(
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
                        value: '$totalPts', label: 'pts',
                        icon: LucideIcons.star,
                        color: const Color(0xFFFBBF24))),
                    ]),
                  ),
                ),

                const SizedBox(height: 24),

                // ── Day strip ──────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 0, 12),
                  child: Text(l10n.weeklyCetteSemaine, style: GoogleFonts.inter(
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
                        onAdd: selectedPlan.isPast ? null : () => _openPicker(_selected),
                        onOptions: selectedPlan.isPast ? null : () => _showDayOptions(
                            context, _selected, selectedPlan),
                      ),
                    ),
                  ),

                const SizedBox(height: 28),

                // ── Weekly list ───────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                  child: Text(l10n.weeklyProgSemaine, style: GoogleFonts.inter(
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
  final VoidCallback? onAdd;
  final VoidCallback? onOptions;

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
            if (onOptions != null)
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
              )
            else
              Icon(LucideIcons.lock,
                  size: 16, color: cs.onSurface.withValues(alpha: 0.25)),
          ]),
        ),

        Padding(
          padding: const EdgeInsets.all(16),
          child: plan.isPast && plan.status == DayStatus.empty
              ? _PastDayBody(cs: cs, dayFull: plan.dayFull)
              : plan.status == DayStatus.empty
                  ? _EmptyDayBody(onAdd: onAdd!, cs: cs)
                  : plan.status == DayStatus.rest
                      ? _RestDayBody(
                          cat: cat ?? _categories.firstWhere((c) => c.id == 'rest'),
                          cs: cs, onEdit: onAdd)
                      : _PlannedDayBody(
                          plan: plan, cat: cat, cs: cs, onEdit: onAdd),
        ),
      ]),
    );
  }

  Color _statusColor(DayStatus s, ProgramCategory? cat) {
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
// Past day — locked
class _PastDayBody extends StatelessWidget {
  final ColorScheme cs;
  final String dayFull;
  const _PastDayBody({required this.cs, required this.dayFull});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28),
      decoration: BoxDecoration(
        color: cs.onSurface.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(children: [
        Icon(LucideIcons.lock, size: 28,
            color: cs.onSurface.withValues(alpha: 0.18)),
        const SizedBox(height: 8),
        Text('Jour passé', style: GoogleFonts.inter(
          fontSize: 13, color: cs.onSurface.withValues(alpha: 0.3))),
      ]),
    );
  }
}

class _EmptyDayBody extends ConsumerWidget {
  final VoidCallback onAdd;
  final ColorScheme cs;
  const _EmptyDayBody({required this.onAdd, required this.cs});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(l10nProvider);
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
          Text(l10n.weeklyAucuneSeance, style: GoogleFonts.inter(
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
            Text('Choisir un programme', style: GoogleFonts.outfit(
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
  final ProgramCategory cat;
  final ColorScheme cs;
  final VoidCallback? onEdit;
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

// Planned body (with category + programme choisi)
class _PlannedDayBody extends ConsumerWidget {
  final DayPlan plan;
  final ProgramCategory? cat;
  final ColorScheme cs;
  final VoidCallback? onEdit;
  const _PlannedDayBody({
    required this.plan, required this.cat,
    required this.cs, required this.onEdit});

  static const _fallbackCat = ProgramCategory(
    id: 'planned', label: 'Programme planifié',
    icon: LucideIcons.dumbbell, color: Color(0xFF1C4D30));

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = plan.program;
    final isDone = plan.status == DayStatus.done;
    final c = cat ?? _fallbackCat;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Category banner
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: c.color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: c.color.withValues(alpha: 0.2)),
        ),
        child: Row(children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: c.color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(c.icon, color: c.color, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(p?.name ?? c.label, style: GoogleFonts.outfit(
                fontSize: 16, fontWeight: FontWeight.w800,
                color: cs.onSurface, letterSpacing: -0.3)),
              if (p != null)
                Text('${p.duration} · ${p.sessions}', style: GoogleFonts.inter(
                  fontSize: 12,
                  color: cs.onSurface.withValues(alpha: 0.45))),
            ],
          )),
          if (isDone)
            Icon(LucideIcons.checkCircle, color: const Color(0xFF34D399),
                size: 22),
        ]),
      ),

      // Programme choisi (si présent)
      if (p != null) ...[
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Stack(children: [
            Image.asset(p.imageUrl,
              width: double.infinity, height: 130, fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                height: 130, color: c.color.withValues(alpha: 0.1),
                child: Icon(c.icon, size: 40, color: c.color))),
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
                Expanded(child: Text(p.name, style: GoogleFonts.outfit(
                  color: Colors.white, fontSize: 14,
                  fontWeight: FontWeight.w800))),
                if (p.level != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8)),
                    child: Text(p.level!, style: GoogleFonts.inter(
                      color: Colors.white, fontSize: 10,
                      fontWeight: FontWeight.w700))),
              ])),
          ]),
        ),
        const SizedBox(height: 10),
        Row(children: [
          _MiniPill(icon: LucideIcons.timer,
              label: p.duration, color: c.color),
          const SizedBox(width: 8),
          _MiniPill(icon: LucideIcons.star,
              label: '${p.totalPoints} pts',
              color: const Color(0xFFFBBF24)),
        ]),
      ],

      const SizedBox(height: 14),

      // Action buttons: Commencer + Change icon
      Row(children: [
        // Start / Commencer button
        Expanded(
          child: GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              if (p != null && !isDone) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => WorkoutDetailScreen(program: p)),
                );
              } else {
                onEdit?.call();
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isDone
                    ? cs.surfaceContainerHighest
                    : c.color,
                borderRadius: BorderRadius.circular(50),
                border: isDone ? Border.all(color: cs.outline) : null,
              ),
              child: Row(mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                Icon(
                  isDone ? LucideIcons.checkCircle : LucideIcons.play,
                  color: isDone
                      ? cs.onSurface.withValues(alpha: 0.4)
                      : Colors.white,
                  size: 14),
                const SizedBox(width: 8),
                Text(
                  isDone ? 'Terminé' : (p != null ? 'Commencer' : 'Planifier'),
                  style: GoogleFonts.outfit(
                    fontSize: 13, fontWeight: FontWeight.w800,
                    color: isDone
                        ? cs.onSurface.withValues(alpha: 0.4)
                        : Colors.white)),
              ]),
            ),
          ),
        ),
        const SizedBox(width: 8),
        // Change icon button
        GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            onEdit?.call();
          },
          child: Container(
            width: 46, height: 46,
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(50),
              border: Border.all(color: cs.outline),
            ),
            child: Icon(LucideIcons.refreshCw,
                size: 16,
                color: cs.onSurface.withValues(alpha: 0.5)),
          ),
        ),
      ]),
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
    final isPast = plan.isPast;

    return GestureDetector(
      onTap: onTap,
      onLongPress: isPast ? null : () {
        HapticFeedback.mediumImpact();
        onLongPress();
      },
      child: Opacity(
        opacity: isPast && plan.status == DayStatus.empty ? 0.45 : 1.0,
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
                  if (plan.program != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(plan.program!.name, style: GoogleFonts.inter(
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
            if (plan.program != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(plan.program!.duration, style: GoogleFonts.inter(
                  fontSize: 10,
                  color: cs.onSurface.withValues(alpha: 0.35)))),
          ]),
        ]),
      ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// PROGRAM PICKER BOTTOM SHEET
// ═══════════════════════════════════════════════════════════════

class _ProgramPickerSheet extends ConsumerStatefulWidget {
  final String dayFull;
  final void Function(HomeProgramModel program) onPick;
  final VoidCallback onPickRest;

  const _ProgramPickerSheet({
    required this.dayFull,
    required this.onPick,
    required this.onPickRest,
  });

  @override
  ConsumerState<_ProgramPickerSheet> createState() =>
      _ProgramPickerSheetState();
}

class _ProgramPickerSheetState extends ConsumerState<_ProgramPickerSheet> {
  String _catId = 'home';
  String _search = '';

  List<HomeProgramModel> get _filtered {
    final all = ref.watch(allProgramsProvider);
    final byCat = all.where((p) => p.category == _catId).toList();
    if (_search.isEmpty) return byCat;
    final q = _search.toLowerCase();
    return byCat.where((p) => p.name.toLowerCase().contains(q)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final h = MediaQuery.of(context).size.height;
    final bottom = MediaQuery.of(context).padding.bottom;
    final programCats = _categories.where((c) => !c.isRest).toList();
    final restCat = _categories.firstWhere((c) => c.isRest);
    final filtered = _filtered;

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
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.dayFull,
                  style: GoogleFonts.outfit(fontSize: 20,
                    fontWeight: FontWeight.w800, color: cs.onSurface)),
                Text('Choisir un programme',
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

        const SizedBox(height: 10),

        // "Jour de repos" quick action
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
          child: GestureDetector(
            onTap: widget.onPickRest,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: restCat.color.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: restCat.color.withValues(alpha: 0.2)),
              ),
              child: Row(children: [
                Icon(restCat.icon, size: 16, color: restCat.color),
                const SizedBox(width: 10),
                Expanded(child: Text('Jour de repos',
                  style: GoogleFonts.inter(fontSize: 13,
                    color: cs.onSurface, fontWeight: FontWeight.w500))),
                Icon(LucideIcons.chevronRight, size: 14,
                    color: cs.onSurface.withValues(alpha: 0.3)),
              ]),
            ),
          ),
        ),

        // Category chips
        SizedBox(
          height: 36,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: programCats.length,
            itemBuilder: (_, i) {
              final cat = programCats[i];
              final sel = _catId == cat.id;
              return GestureDetector(
                onTap: () => setState(() => _catId = cat.id),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: sel ? cat.color : cs.surface,
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(
                      color: sel ? cat.color : cs.outline,
                    ),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(cat.icon, size: 13,
                        color: sel ? Colors.white : cat.color),
                    const SizedBox(width: 6),
                    Text(cat.label,
                        style: GoogleFonts.inter(
                          color: sel ? Colors.white : cs.onSurfaceVariant,
                          fontWeight: FontWeight.w700,
                          fontSize: 11.5,
                        )),
                  ]),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 12),

        // Search bar
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
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
                onChanged: (v) => setState(() => _search = v),
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

        Flexible(
          child: filtered.isEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Center(child: Text('Aucun programme disponible',
                      style: GoogleFonts.inter(
                        color: cs.onSurface.withValues(alpha: 0.35), fontSize: 14))),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  padding: EdgeInsets.fromLTRB(20, 0, 20, 20 + bottom),
                  itemCount: filtered.length,
                  itemBuilder: (_, i) {
                    final p = filtered[i];
                    return GestureDetector(
                      onTap: () => widget.onPick(p),
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
                            child: Image.asset(p.imageUrl,
                              width: 58, height: 58, fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 58, height: 58,
                                color: p.color.withValues(alpha: 0.1),
                                child: Icon(LucideIcons.dumbbell, color: p.color, size: 24))),
                          ),
                          const SizedBox(width: 12),
                          Expanded(child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(p.name, style: GoogleFonts.outfit(
                                fontSize: 14, fontWeight: FontWeight.w700,
                                color: cs.onSurface)),
                              const SizedBox(height: 4),
                              Row(children: [
                                Icon(LucideIcons.timer, size: 11,
                                    color: cs.onSurface.withValues(alpha: 0.4)),
                                const SizedBox(width: 3),
                                Text(p.duration, style: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: cs.onSurface.withValues(alpha: 0.45))),
                                const SizedBox(width: 8),
                                Icon(LucideIcons.layers, size: 11,
                                    color: cs.onSurface.withValues(alpha: 0.4)),
                                const SizedBox(width: 3),
                                Text(p.sessions, style: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: cs.onSurface.withValues(alpha: 0.45))),
                              ]),
                            ],
                          )),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 9, vertical: 3),
                            decoration: BoxDecoration(
                              color: p.color.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: Text('${p.totalPoints} pts', style: GoogleFonts.inter(
                              fontSize: 9, fontWeight: FontWeight.w700,
                              color: p.color)),
                          ),
                        ]),
                      ),
                    );
                  },
                ),
        ),
      ]),
    );
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
