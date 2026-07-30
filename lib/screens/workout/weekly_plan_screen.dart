// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../l10n/app_localizations.dart';
import '../../models/home_program_model.dart';
import '../../providers/mock_data_provider.dart';
import '../../providers/subscription_provider.dart';
import '../../providers/weekly_plan_provider.dart';
import '../../widgets/paywall_sheet.dart';
import 'programme_detail_screen.dart';

// ═══════════════════════════════════════════════════════════════
// PROGRAM CATEGORY
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
  ProgramCategory(id: 'home', label: 'Maison', icon: LucideIcons.house, color: Color(0xFF1C4D30)),
  ProgramCategory(id: 'salle', label: 'Salle', icon: LucideIcons.dumbbell, color: Color(0xFFEF4444)),
  ProgramCategory(id: 'dance', label: 'Danse', icon: LucideIcons.music, color: Color(0xFF8B5CF6)),
  ProgramCategory(id: 'recuperation', label: 'Récupération', icon: LucideIcons.heartPulse, color: Color(0xFF06B6D4)),
  ProgramCategory(id: 'grossesse', label: 'Grossesse', icon: LucideIcons.baby, color: Color(0xFFF59E0B)),
  ProgramCategory(id: 'rest', label: 'Repos', icon: LucideIcons.moon, color: Color(0xFF6B7280), isRest: true),
];

ProgramCategory? _catById(String? id) {
  if (id == null) return null;
  try { return _categories.firstWhere((c) => c.id == id); }
  catch (_) { return null; }
}

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

class _WeeklyPlanScreenState extends ConsumerState<WeeklyPlanScreen>
    with TickerProviderStateMixin {
  int _selected = -1;

  late final AnimationController _sweepCtrl;
  late final List<Animation<double>> _dayScales;
  late final Animation<double> _sweepProgress;
  bool _isSweeping = false;

  @override
  void initState() {
    super.initState();

    _sweepCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );

    _sweepProgress = CurvedAnimation(
      parent: _sweepCtrl,
      curve: Curves.easeInOut,
    );

    _dayScales = List.generate(7, (i) {
      final start = (i / 7) * 0.7;
      final end = start + 0.3;
      return TweenSequence<double>([
        TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.85)
            .chain(CurveTween(curve: Curves.easeIn)), weight: 30),
        TweenSequenceItem(tween: Tween(begin: 0.85, end: 1.12)
            .chain(CurveTween(curve: Curves.easeOut)), weight: 40),
        TweenSequenceItem(tween: Tween(begin: 1.12, end: 1.0)
            .chain(CurveTween(curve: Curves.elasticOut)), weight: 30),
      ]).animate(CurvedAnimation(
        parent: _sweepCtrl,
        curve: Interval(start.clamp(0.0, 1.0), end.clamp(0.0, 1.0)),
      ));
    });

    _sweepCtrl.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() => _isSweeping = false);
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final plans = ref.read(weeklyPlanProvider);
      final todayIdx = plans.indexWhere((d) => d.isToday);
      if (todayIdx >= 0) setState(() => _selected = todayIdx);
    });
  }

  @override
  void dispose() {
    _sweepCtrl.dispose();
    super.dispose();
  }

  void _runAutoGenerate() {
    ref.read(weeklyPlanProvider.notifier).generateSmartPlan();
    HapticFeedback.mediumImpact();
    setState(() => _isSweeping = true);
    _sweepCtrl.forward(from: 0.0);

    for (var i = 0; i < 7; i++) {
      final delay = Duration(milliseconds: (i * 1600 * 0.7 / 7).round() + 100);
      Future.delayed(delay, () {
        if (mounted) HapticFeedback.lightImpact();
      });
    }
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
        padding: EdgeInsets.fromLTRB(20, 16, 20, 16 + MediaQuery.of(ctx).padding.bottom),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Center(child: Container(width: 36, height: 4,
            decoration: BoxDecoration(color: cs.outline.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 16),
          Text(plan.dayFull, style: GoogleFonts.outfit(
            fontSize: 17, fontWeight: FontWeight.w800, color: cs.onSurface)),
          const SizedBox(height: 16),
          _OptionTile(icon: LucideIcons.refreshCw,
            label: plan.categoryId == null ? 'Choisir un programme' : 'Changer le programme',
            color: cs.primary,
            onTap: () { Navigator.pop(ctx); _openPicker(index); }),
          _OptionTile(icon: LucideIcons.arrowLeftRight,
            label: 'Déplacer vers un autre jour',
            color: const Color(0xFF3B82F6),
            onTap: () { Navigator.pop(ctx); _showSwapPicker(index, plans); }),
          if (plan.categoryId != null)
            _OptionTile(icon: LucideIcons.trash2, label: 'Supprimer la séance',
              color: cs.error,
              onTap: () { ref.read(weeklyPlanProvider.notifier).remove(index); Navigator.pop(ctx); }),
        ]),
      ),
    );
  }

  void _showSwapPicker(int fromIndex, List<DayPlan> plans) {
    final cs = Theme.of(context).colorScheme;
    showModalBottomSheet<void>(
      context: context, backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: BoxDecoration(color: cs.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
        padding: EdgeInsets.fromLTRB(20, 16, 20, 16 + MediaQuery.of(context).padding.bottom),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Center(child: Container(width: 36, height: 4,
            decoration: BoxDecoration(color: cs.outline.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 16),
          Text(ref.read(l10nProvider).weeklyDeplacer, style: GoogleFonts.outfit(
            fontSize: 17, fontWeight: FontWeight.w800, color: cs.onSurface)),
          const SizedBox(height: 12),
          ...List.generate(7, (i) {
            if (i == fromIndex) return const SizedBox.shrink();
            final d = plans[i];
            return GestureDetector(
              onTap: () { ref.read(weeklyPlanProvider.notifier).swap(fromIndex, i); Navigator.pop(context); },
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(color: cs.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: cs.outline)),
                child: Row(children: [
                  Text(d.dayShort, style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w800, color: cs.primary)),
                  const SizedBox(width: 10),
                  Expanded(child: Text(d.dayFull, style: GoogleFonts.inter(fontSize: 14, color: cs.onSurface))),
                  if (d.category != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: d.category!.color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(50)),
                      child: Text(d.category!.label, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: d.category!.color)))
                  else
                    Text(ref.read(l10nProvider).weeklyVide, style: GoogleFonts.inter(fontSize: 12, color: cs.onSurface.withValues(alpha: 0.35))),
                  const SizedBox(width: 8),
                  Icon(LucideIcons.chevronsRight, size: 14, color: cs.onSurface.withValues(alpha: 0.3)),
                ]),
              ),
            );
          }),
        ]),
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
    final plannedCount = plans.where((d) => d.status == DayStatus.planned || d.status == DayStatus.rest).length;
    final filledCount = doneCount + plannedCount;

    return Scaffold(
      backgroundColor: cs.surface,
      body: CustomScrollView(
        slivers: [
          // ── App Bar ────────────────────────────────────
          SliverAppBar(
            pinned: true,
            backgroundColor: cs.surface,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            leading: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                margin: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: cs.surfaceContainerHighest, shape: BoxShape.circle),
                child: Icon(LucideIcons.arrowLeft, size: 16, color: cs.onSurface),
              ),
            ),
            title: Text(l10n.weeklyMaSemaine, style: GoogleFonts.outfit(
              fontSize: 22, fontWeight: FontWeight.w800,
              color: cs.onSurface, letterSpacing: -0.5)),
            actions: [
              Consumer(builder: (context, ref, _) {
                final isPro = ref.watch(isProProvider);
                return GestureDetector(
                  onTap: _isSweeping ? null : () {
                    HapticFeedback.selectionClick();
                    if (!isPro) {
                      showPaywallSheet(context,
                        feature: 'Plan intelligent',
                        description: 'Génère automatiquement ton plan de la semaine adapté à ta phase du cycle.');
                      return;
                    }
                    _runAutoGenerate();
                  },
                  child: AnimatedBuilder(
                    animation: _sweepCtrl,
                    builder: (context, child) {
                      final glow = _isSweeping ? _sweepProgress.value : 0.0;
                      return Container(
                        margin: const EdgeInsets.only(right: 16),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                        decoration: BoxDecoration(
                          color: cs.primary,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: glow > 0 ? [
                            BoxShadow(
                              color: cs.primary.withValues(alpha: 0.4 * glow),
                              blurRadius: 16 * glow,
                              spreadRadius: 2 * glow),
                          ] : null,
                        ),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Icon(isPro ? LucideIcons.sparkles : LucideIcons.lock, size: 13, color: Colors.white),
                          const SizedBox(width: 5),
                          Text('Auto', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
                        ]),
                      );
                    },
                  ),
                );
              }),
            ],
          ),

          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ── Progress bar ──────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 2, 20, 4),
                  child: Row(children: [
                    Text('$filledCount/7', style: GoogleFonts.outfit(
                      fontSize: 13, fontWeight: FontWeight.w700,
                      color: cs.primary)),
                    const SizedBox(width: 4),
                    Text('jours planifiés', style: GoogleFonts.inter(
                      fontSize: 12, color: cs.onSurface.withValues(alpha: 0.4))),
                    const Spacer(),
                    if (doneCount > 0)
                      Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(LucideIcons.checkCircle, size: 12, color: const Color(0xFF34D399)),
                        const SizedBox(width: 3),
                        Text('$doneCount terminé${doneCount > 1 ? 's' : ''}',
                          style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600,
                            color: const Color(0xFF34D399))),
                      ]),
                  ]),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
                  child: AnimatedBuilder(
                    animation: _sweepCtrl,
                    builder: (context, _) {
                      final sweepVal = _sweepProgress.value;
                      return SizedBox(
                        height: 4,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(2),
                          child: Stack(children: [
                            Row(
                              children: List.generate(7, (i) {
                                final d = plans[i];
                                Color segColor;
                                if (d.status == DayStatus.done) {
                                  segColor = const Color(0xFF34D399);
                                } else if (d.status == DayStatus.planned) {
                                  segColor = cs.primary.withValues(alpha: 0.5);
                                } else if (d.status == DayStatus.rest) {
                                  segColor = const Color(0xFF6B7280).withValues(alpha: 0.3);
                                } else {
                                  segColor = cs.onSurface.withValues(alpha: 0.06);
                                }
                                final segThreshold = (i + 0.5) / 7;
                                final lit = _isSweeping && sweepVal >= segThreshold;
                                return Expanded(child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 150),
                                  margin: EdgeInsets.only(right: i < 6 ? 2 : 0),
                                  decoration: BoxDecoration(
                                    color: lit
                                        ? Color.lerp(segColor, cs.primary, 0.6)!
                                        : segColor,
                                    boxShadow: lit ? [
                                      BoxShadow(
                                        color: cs.primary.withValues(alpha: 0.5),
                                        blurRadius: 6),
                                    ] : null,
                                  ),
                                ));
                              }),
                            ),
                            if (_isSweeping)
                              Positioned(
                                left: sweepVal * MediaQuery.of(context).size.width * 0.85,
                                top: -3,
                                child: Container(
                                  width: 10, height: 10,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: cs.primary,
                                    boxShadow: [
                                      BoxShadow(
                                        color: cs.primary.withValues(alpha: 0.6),
                                        blurRadius: 12, spreadRadius: 2),
                                    ],
                                  ),
                                ),
                              ),
                          ]),
                        ),
                      );
                    },
                  ),
                ),

                // ── Week strip ────────────────────────────
                SizedBox(
                  height: 98,
                  child: AnimatedBuilder(
                    animation: _sweepCtrl,
                    builder: (context, _) => ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: 7,
                      itemBuilder: (_, i) {
                        final d = plans[i];
                        final sel = _selected == i;
                        final cat = d.category;
                        final isDone = d.status == DayStatus.done;
                        final isEmpty = d.status == DayStatus.empty;
                        final isPastEmpty = d.isPast && isEmpty;

                        final scale = _isSweeping ? _dayScales[i].value : 1.0;

                        return GestureDetector(
                          onTap: () => setState(() => _selected = i),
                          onLongPress: d.isPast ? null : () {
                            HapticFeedback.mediumImpact();
                            _showDayOptions(context, i, d);
                          },
                          child: Transform.scale(
                            scale: scale,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: (MediaQuery.of(context).size.width - 32 - 36) / 7,
                              margin: const EdgeInsets.only(right: 6),
                              decoration: BoxDecoration(
                                color: sel ? cs.primary : cs.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  if (sel)
                                    BoxShadow(
                                      color: cs.primary.withValues(alpha: 0.25),
                                      blurRadius: 12, offset: const Offset(0, 4)),
                                  if (_isSweeping && scale > 1.0)
                                    BoxShadow(
                                      color: cs.primary.withValues(alpha: 0.3 * (scale - 1.0) / 0.12),
                                      blurRadius: 16, spreadRadius: 2),
                                ],
                              ),
                              child: Opacity(
                                opacity: isPastEmpty ? 0.4 : 1.0,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(d.dayShort, style: GoogleFonts.inter(
                                      fontSize: 9, fontWeight: FontWeight.w700,
                                      color: sel ? Colors.white.withValues(alpha: 0.7) : cs.onSurface.withValues(alpha: 0.35),
                                      letterSpacing: 0.3)),
                                    const SizedBox(height: 3),
                                    Text('${d.date.day}', style: GoogleFonts.outfit(
                                      fontSize: 18, fontWeight: FontWeight.w800,
                                      color: sel ? Colors.white : cs.onSurface, height: 1)),
                                    const SizedBox(height: 6),
                                    SizedBox(
                                      height: 20,
                                      child: isDone
                                        ? Icon(LucideIcons.checkCircle, size: 14,
                                            color: sel ? Colors.white : const Color(0xFF34D399))
                                        : cat != null && !cat.isRest
                                          ? Container(
                                              width: 20, height: 20,
                                              decoration: BoxDecoration(
                                                color: sel ? Colors.white.withValues(alpha: 0.2) : cat.color.withValues(alpha: 0.12),
                                                borderRadius: BorderRadius.circular(6)),
                                              child: Icon(cat.icon, size: 10,
                                                color: sel ? Colors.white : cat.color))
                                          : cat != null && cat.isRest
                                            ? Icon(LucideIcons.moon, size: 12,
                                                color: sel ? Colors.white.withValues(alpha: 0.6) : const Color(0xFF6B7280).withValues(alpha: 0.4))
                                            : Container(
                                                width: 6, height: 6,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: sel ? Colors.white.withValues(alpha: 0.3) : cs.onSurface.withValues(alpha: 0.1))),
                                    ),
                                    if (d.isToday) ...[
                                      const SizedBox(height: 2),
                                      Container(width: 16, height: 2,
                                        decoration: BoxDecoration(
                                          color: sel ? Colors.white : cs.primary,
                                          borderRadius: BorderRadius.circular(1))),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // ── Selected day detail ───────────────────
                if (selectedPlan != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 260),
                      child: _buildDayDetail(
                        context, cs, selectedPlan, _selected),
                    ),
                  ),

                const SizedBox(height: 32),

                // ── Week overview list ────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                  child: Text('APERÇU DE LA SEMAINE', style: GoogleFonts.inter(
                    fontSize: 10, fontWeight: FontWeight.w700,
                    color: cs.onSurface.withValues(alpha: 0.3), letterSpacing: 1.5)),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                  child: Column(
                    children: List.generate(7, (i) {
                      final d = plans[i];
                      final cat = d.category;
                      final isDone = d.status == DayStatus.done;
                      final isSel = _selected == i;
                      final isPast = d.isPast && d.status == DayStatus.empty;

                      return GestureDetector(
                        onTap: () => setState(() => _selected = i),
                        onLongPress: d.isPast ? null : () {
                          HapticFeedback.mediumImpact();
                          _showDayOptions(context, i, d);
                        },
                        child: Opacity(
                          opacity: isPast ? 0.4 : 1.0,
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 4),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: isSel ? cs.primary.withValues(alpha: 0.05) : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(children: [
                              // Day column
                              SizedBox(width: 34, child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(d.dayShort, style: GoogleFonts.inter(
                                    fontSize: 9, fontWeight: FontWeight.w700,
                                    color: isSel ? cs.primary : cs.onSurface.withValues(alpha: 0.35),
                                    letterSpacing: 0.3)),
                                  Text('${d.date.day}', style: GoogleFonts.outfit(
                                    fontSize: 16, fontWeight: FontWeight.w800,
                                    color: cs.onSurface, height: 1.2)),
                                ],
                              )),
                              // Vertical accent
                              Container(
                                width: 3, height: 28,
                                margin: const EdgeInsets.symmetric(horizontal: 10),
                                decoration: BoxDecoration(
                                  color: isDone
                                    ? const Color(0xFF34D399)
                                    : cat != null
                                      ? cat.color.withValues(alpha: 0.5)
                                      : cs.onSurface.withValues(alpha: 0.06),
                                  borderRadius: BorderRadius.circular(2)),
                              ),
                              // Content
                              Expanded(child: cat == null
                                ? Text('—', style: GoogleFonts.inter(
                                    fontSize: 13, color: cs.onSurface.withValues(alpha: 0.2)))
                                : cat.isRest
                                  ? Text('Repos', style: GoogleFonts.inter(
                                      fontSize: 13, fontWeight: FontWeight.w500,
                                      color: cat.color.withValues(alpha: 0.6)))
                                  : Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(d.program?.name ?? cat.label, style: GoogleFonts.inter(
                                          fontSize: 13, fontWeight: FontWeight.w600,
                                          color: cs.onSurface),
                                          maxLines: 1, overflow: TextOverflow.ellipsis),
                                        if (d.program != null)
                                          Text(d.program!.duration, style: GoogleFonts.inter(
                                            fontSize: 11, color: cs.onSurface.withValues(alpha: 0.35))),
                                      ],
                                    )),
                              // Status
                              if (isDone)
                                Icon(LucideIcons.checkCircle, size: 16, color: const Color(0xFF34D399))
                              else if (d.isToday)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: cs.primary.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(6)),
                                  child: Text("Auj.", style: GoogleFonts.inter(
                                    fontSize: 9, fontWeight: FontWeight.w700, color: cs.primary)),
                                ),
                            ]),
                          ),
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

  Widget _buildDayDetail(BuildContext context, ColorScheme cs, DayPlan plan, int index) {
    final cat = plan.category;
    final p = plan.program;
    final isDone = plan.status == DayStatus.done;

    // ── Past empty ──
    if (plan.isPast && plan.status == DayStatus.empty) {
      return Container(
        key: ValueKey(index),
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: _cardDecoration(cs),
        child: Column(children: [
          Icon(LucideIcons.lock, size: 22, color: cs.onSurface.withValues(alpha: 0.12)),
          const SizedBox(height: 8),
          Text(plan.dayFull, style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700, color: cs.onSurface.withValues(alpha: 0.3))),
          const SizedBox(height: 2),
          Text('Jour passé', style: GoogleFonts.inter(fontSize: 12, color: cs.onSurface.withValues(alpha: 0.2))),
        ]),
      );
    }

    // ── Empty ──
    if (plan.status == DayStatus.empty) {
      return Container(
        key: ValueKey(index),
        width: double.infinity,
        decoration: _cardDecoration(cs),
        child: Column(children: [
          _dayHeader(cs, plan, cat),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: GestureDetector(
              onTap: () { HapticFeedback.selectionClick(); _openPicker(index); },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 28),
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: cs.primary.withValues(alpha: 0.12), width: 1.5,
                    strokeAlign: BorderSide.strokeAlignInside),
                ),
                child: Column(children: [
                  Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      color: cs.primary.withValues(alpha: 0.08),
                      shape: BoxShape.circle),
                    child: Icon(LucideIcons.plus, size: 20, color: cs.primary),
                  ),
                  const SizedBox(height: 10),
                  Text('Ajouter une séance', style: GoogleFonts.outfit(
                    fontSize: 14, fontWeight: FontWeight.w700, color: cs.primary)),
                  const SizedBox(height: 2),
                  Text('Choisis un programme ou repos', style: GoogleFonts.inter(
                    fontSize: 11, color: cs.onSurface.withValues(alpha: 0.3))),
                ]),
              ),
            ),
          ),
        ]),
      );
    }

    // ── Rest ──
    if (plan.status == DayStatus.rest) {
      final restCat = cat ?? _categories.firstWhere((c) => c.id == 'rest');
      return Container(
        key: ValueKey(index),
        width: double.infinity,
        decoration: _cardDecoration(cs),
        child: Column(children: [
          _dayHeader(cs, plan, restCat),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24),
              decoration: BoxDecoration(
                color: restCat.color.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: restCat.color.withValues(alpha: 0.1))),
              child: Column(children: [
                Icon(LucideIcons.moon, size: 28, color: restCat.color.withValues(alpha: 0.5)),
                const SizedBox(height: 8),
                Text('Jour de repos', style: GoogleFonts.outfit(
                  fontSize: 15, fontWeight: FontWeight.w700, color: restCat.color)),
                const SizedBox(height: 2),
                Text('Laisse ton corps récupérer', style: GoogleFonts.inter(
                  fontSize: 11, color: cs.onSurface.withValues(alpha: 0.35))),
                if (!plan.isPast) ...[
                  const SizedBox(height: 14),
                  GestureDetector(
                    onTap: () => _openPicker(index),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: restCat.color.withValues(alpha: 0.2))),
                      child: Text('Modifier', style: GoogleFonts.inter(
                        fontSize: 12, fontWeight: FontWeight.w600, color: restCat.color)),
                    ),
                  ),
                ],
              ]),
            ),
          ),
        ]),
      );
    }

    // ── Planned / Done ──
    final c = cat ?? const ProgramCategory(
      id: 'planned', label: 'Programme', icon: LucideIcons.dumbbell, color: Color(0xFF1C4D30));

    return Container(
      key: ValueKey(index),
      width: double.infinity,
      decoration: _cardDecoration(cs),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _dayHeader(cs, plan, cat),

        // Program image
        if (p != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Stack(children: [
                Image.asset(p.imageUrl,
                  width: double.infinity, height: 140, fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 140, color: c.color.withValues(alpha: 0.06),
                    child: Center(child: Icon(c.icon, size: 36, color: c.color.withValues(alpha: 0.2))))),
                Positioned.fill(child: DecoratedBox(decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.black.withValues(alpha: 0.0), Colors.black.withValues(alpha: 0.55)],
                    begin: Alignment.topCenter, end: Alignment.bottomCenter)))),
                if (isDone)
                  Positioned.fill(child: Container(
                    color: Colors.black.withValues(alpha: 0.3),
                    child: const Center(child: Icon(LucideIcons.checkCircle, color: Color(0xFF34D399), size: 40)))),
                Positioned(bottom: 12, left: 14, right: 14,
                  child: Row(children: [
                    Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(5)),
                            child: Row(mainAxisSize: MainAxisSize.min, children: [
                              Icon(c.icon, size: 9, color: Colors.white.withValues(alpha: 0.8)),
                              const SizedBox(width: 3),
                              Text(c.label, style: GoogleFonts.inter(
                                fontSize: 9, fontWeight: FontWeight.w600,
                                color: Colors.white.withValues(alpha: 0.8))),
                            ]),
                          ),
                        ]),
                        const SizedBox(height: 4),
                        Text(p.name, style: GoogleFonts.outfit(
                          color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800, letterSpacing: -0.2)),
                      ],
                    )),
                    if (p.level != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)),
                        child: Text(p.level!, style: GoogleFonts.inter(
                          color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700))),
                  ])),
              ]),
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Container(
              width: double.infinity, padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: c.color.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(14),
                border: Border.all(color: c.color.withValues(alpha: 0.1))),
              child: Row(children: [
                Container(width: 36, height: 36,
                  decoration: BoxDecoration(color: c.color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                  child: Icon(c.icon, color: c.color, size: 16)),
                const SizedBox(width: 12),
                Text(c.label, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w700, color: cs.onSurface)),
              ]),
            ),
          ),

        // Meta + Action
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
          child: Column(children: [
            if (p != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(children: [
                  Icon(LucideIcons.timer, size: 12, color: cs.onSurface.withValues(alpha: 0.3)),
                  const SizedBox(width: 4),
                  Text(p.duration, style: GoogleFonts.inter(fontSize: 12, color: cs.onSurface.withValues(alpha: 0.45))),
                  const SizedBox(width: 14),
                  Icon(LucideIcons.star, size: 12, color: const Color(0xFFFBBF24).withValues(alpha: 0.6)),
                  const SizedBox(width: 4),
                  Text('${p.totalPoints} pts', style: GoogleFonts.inter(fontSize: 12, color: cs.onSurface.withValues(alpha: 0.45))),
                  const Spacer(),
                  if (!plan.isPast)
                    GestureDetector(
                      onTap: () { HapticFeedback.selectionClick(); _openPicker(index); },
                      child: Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: cs.onSurface.withValues(alpha: 0.08))),
                        child: Icon(LucideIcons.refreshCw, size: 13, color: cs.onSurface.withValues(alpha: 0.35)),
                      ),
                    ),
                ]),
              ),
            GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                if (p != null && !isDone) {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => WorkoutDetailScreen(program: p)));
                } else if (!plan.isPast) {
                  _openPicker(index);
                }
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: isDone ? cs.onSurface.withValues(alpha: 0.04) : cs.primary,
                  borderRadius: BorderRadius.circular(14),
                  border: isDone ? Border.all(color: cs.onSurface.withValues(alpha: 0.06)) : null,
                ),
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(isDone ? LucideIcons.checkCircle : LucideIcons.play,
                    color: isDone ? cs.onSurface.withValues(alpha: 0.3) : Colors.white, size: 15),
                  const SizedBox(width: 7),
                  Text(isDone ? 'Terminé' : (p != null ? 'Commencer' : 'Planifier'),
                    style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w700,
                      color: isDone ? cs.onSurface.withValues(alpha: 0.3) : Colors.white)),
                ]),
              ),
            ),
          ]),
        ),
      ]),
    );
  }

  Widget _dayHeader(ColorScheme cs, DayPlan plan, ProgramCategory? cat) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 10, 0),
      child: Row(children: [
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(plan.dayFull, style: GoogleFonts.outfit(
              fontSize: 18, fontWeight: FontWeight.w800,
              color: cs.onSurface, letterSpacing: -0.3)),
            Text(
              plan.isToday ? "Aujourd'hui" : _fmtDate(plan.date),
              style: GoogleFonts.inter(fontSize: 11, fontWeight: plan.isToday ? FontWeight.w600 : FontWeight.w400,
                color: plan.isToday ? cs.primary : cs.onSurface.withValues(alpha: 0.35))),
          ],
        )),
        if (plan.status != DayStatus.empty) _buildStatusBadge(cs, plan, cat),
        if (!plan.isPast) ...[
          const SizedBox(width: 4),
          GestureDetector(
            onTap: () => _showDayOptions(context, _selected, plan),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Icon(LucideIcons.moreHorizontal, size: 16, color: cs.onSurface.withValues(alpha: 0.35)),
            ),
          ),
        ],
      ]),
    );
  }

  Widget _buildStatusBadge(ColorScheme cs, DayPlan plan, ProgramCategory? cat) {
    Color color;
    String label;
    switch (plan.status) {
      case DayStatus.done:    color = const Color(0xFF34D399); label = 'Terminé'; break;
      case DayStatus.planned: color = cs.primary; label = 'Planifié'; break;
      case DayStatus.rest:    color = const Color(0xFF6B7280); label = 'Repos'; break;
      case DayStatus.empty:   return const SizedBox.shrink();
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
      child: Text(label, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: color)),
    );
  }

  BoxDecoration _cardDecoration(ColorScheme cs) => BoxDecoration(
    color: cs.surfaceContainerHighest,
    borderRadius: BorderRadius.circular(22),
    boxShadow: [
      BoxShadow(color: cs.onSurface.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 4)),
    ],
  );

  String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}';
}

// ═══════════════════════════════════════════════════════════════
// PROGRAM PICKER BOTTOM SHEET
// ═══════════════════════════════════════════════════════════════

class _ProgramPickerSheet extends ConsumerStatefulWidget {
  final String dayFull;
  final void Function(HomeProgramModel program) onPick;
  final VoidCallback onPickRest;
  const _ProgramPickerSheet({required this.dayFull, required this.onPick, required this.onPickRest});
  @override
  ConsumerState<_ProgramPickerSheet> createState() => _ProgramPickerSheetState();
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
      decoration: BoxDecoration(color: cs.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28))),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Padding(padding: const EdgeInsets.only(top: 12),
          child: Center(child: Container(width: 36, height: 4,
            decoration: BoxDecoration(color: cs.outline.withValues(alpha: 0.4), borderRadius: BorderRadius.circular(2))))),
        Padding(padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
          child: Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(widget.dayFull, style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w800, color: cs.onSurface)),
              Text('Choisir un programme', style: GoogleFonts.inter(fontSize: 12, color: cs.onSurface.withValues(alpha: 0.45))),
            ])),
            GestureDetector(onTap: () => Navigator.pop(context),
              child: Container(padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: cs.surfaceContainerHighest, shape: BoxShape.circle),
                child: Icon(LucideIcons.x, size: 14, color: cs.onSurface))),
          ])),
        const SizedBox(height: 10),
        Padding(padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
          child: GestureDetector(onTap: widget.onPickRest,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: restCat.color.withValues(alpha: 0.07), borderRadius: BorderRadius.circular(14),
                border: Border.all(color: restCat.color.withValues(alpha: 0.2))),
              child: Row(children: [
                Icon(restCat.icon, size: 16, color: restCat.color),
                const SizedBox(width: 10),
                Expanded(child: Text('Jour de repos', style: GoogleFonts.inter(fontSize: 13, color: cs.onSurface, fontWeight: FontWeight.w500))),
                Icon(LucideIcons.chevronRight, size: 14, color: cs.onSurface.withValues(alpha: 0.3)),
              ])))),
        SizedBox(height: 36,
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
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: sel ? cat.color : cs.surface,
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(color: sel ? cat.color : cs.outline)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(cat.icon, size: 13, color: sel ? Colors.white : cat.color),
                    const SizedBox(width: 6),
                    Text(cat.label, style: GoogleFonts.inter(
                      color: sel ? Colors.white : cs.onSurfaceVariant, fontWeight: FontWeight.w700, fontSize: 11.5)),
                  ])));
            })),
        const SizedBox(height: 12),
        Padding(padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
          child: Container(height: 42,
            decoration: BoxDecoration(color: cs.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(50), border: Border.all(color: cs.outline)),
            child: Row(children: [
              const SizedBox(width: 14),
              Icon(LucideIcons.search, size: 14, color: cs.onSurface.withValues(alpha: 0.35)),
              const SizedBox(width: 10),
              Expanded(child: TextField(
                onChanged: (v) => setState(() => _search = v),
                style: GoogleFonts.inter(fontSize: 13, color: cs.onSurface),
                decoration: InputDecoration(
                  hintText: 'Rechercher…',
                  hintStyle: GoogleFonts.inter(fontSize: 13, color: cs.onSurface.withValues(alpha: 0.3)),
                  border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.zero))),
            ]))),
        Flexible(
          child: filtered.isEmpty
            ? Padding(padding: const EdgeInsets.symmetric(vertical: 40),
                child: Center(child: Text('Aucun programme disponible',
                  style: GoogleFonts.inter(color: cs.onSurface.withValues(alpha: 0.35), fontSize: 14))))
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
                        border: Border.all(color: cs.outline)),
                      child: Row(children: [
                        ClipRRect(borderRadius: BorderRadius.circular(10),
                          child: Image.asset(p.imageUrl, width: 58, height: 58, fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(width: 58, height: 58,
                              color: p.color.withValues(alpha: 0.1),
                              child: Icon(LucideIcons.dumbbell, color: p.color, size: 24)))),
                        const SizedBox(width: 12),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(p.name, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w700, color: cs.onSurface)),
                          const SizedBox(height: 4),
                          Row(children: [
                            Icon(LucideIcons.timer, size: 11, color: cs.onSurface.withValues(alpha: 0.4)),
                            const SizedBox(width: 3),
                            Text(p.duration, style: GoogleFonts.inter(fontSize: 11, color: cs.onSurface.withValues(alpha: 0.45))),
                          ]),
                        ])),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                          decoration: BoxDecoration(color: p.color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(50)),
                          child: Text('${p.totalPoints} pts', style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w700, color: p.color))),
                      ])));
                })),
      ]),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// OPTION TILE
// ═══════════════════════════════════════════════════════════════

class _OptionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _OptionTile({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.15))),
        child: Row(children: [
          Container(width: 32, height: 32,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(9)),
            child: Icon(icon, size: 15, color: color)),
          const SizedBox(width: 12),
          Text(label, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: cs.onSurface)),
          const Spacer(),
          Icon(LucideIcons.chevronRight, size: 14, color: cs.onSurface.withValues(alpha: 0.25)),
        ]),
      ),
    );
  }
}
