// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../models/home_program_model.dart';
import '../../models/workout_model.dart';
import '../../providers/mock_data_provider.dart';
import '../../services/workout_progress_service.dart';

class WorkoutHistoryScreen extends ConsumerStatefulWidget {
  const WorkoutHistoryScreen({super.key});

  @override
  ConsumerState<WorkoutHistoryScreen> createState() => _WorkoutHistoryScreenState();
}

class _WorkoutHistoryScreenState extends ConsumerState<WorkoutHistoryScreen> {
  late DateTime _currentMonth;
  Map<DateTime, int> _counts = {};
  List<Map<String, dynamic>> _recent = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _currentMonth = DateTime(now.year, now.month);
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final counts = await WorkoutProgressService.getWorkoutCountsByMonth(
        _currentMonth.year, _currentMonth.month);
    final recent = await WorkoutProgressService.getRecentCompletions(20);
    if (mounted) {
      setState(() {
        _counts = counts;
        _recent = recent;
        _loading = false;
      });
    }
  }

  void _prevMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
    });
    _load();
  }

  void _nextMonth() {
    final now = DateTime.now();
    final next = DateTime(_currentMonth.year, _currentMonth.month + 1);
    if (next.isAfter(DateTime(now.year, now.month + 1))) return;
    setState(() => _currentMonth = next);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final totalThisMonth = _counts.values.fold(0, (a, b) => a + b);
    final activeDays = _counts.length;
    final programs = ref.watch(allProgramsProvider);

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest,
              shape: BoxShape.circle,
            ),
            child: Icon(LucideIcons.arrowLeft, size: 16, color: cs.onSurface),
          ),
        ),
        title: Text('Historique', style: GoogleFonts.outfit(
          fontSize: 20, fontWeight: FontWeight.w800, color: cs.onSurface)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
              children: [
                // ── Stats du mois ──────────────────────────
                Row(children: [
                  Expanded(child: _StatCard(
                    icon: LucideIcons.flame,
                    value: '$totalThisMonth',
                    label: 'Séances',
                    color: const Color(0xFFEF4444),
                    cs: cs,
                  )),
                  const SizedBox(width: 12),
                  Expanded(child: _StatCard(
                    icon: LucideIcons.calendarCheck,
                    value: '$activeDays',
                    label: 'Jours actifs',
                    color: const Color(0xFF22C55E),
                    cs: cs,
                  )),
                  const SizedBox(width: 12),
                  Expanded(child: _StatCard(
                    icon: LucideIcons.trophy,
                    value: _longestStreak().toString(),
                    label: 'Meilleur streak',
                    color: const Color(0xFFF59E0B),
                    cs: cs,
                  )),
                ]),

                const SizedBox(height: 24),

                // ── Calendrier ─────────────────────────────
                _CalendarHeader(
                  month: _currentMonth,
                  onPrev: _prevMonth,
                  onNext: _nextMonth,
                  cs: cs,
                ),
                const SizedBox(height: 12),
                _CalendarGrid(
                  month: _currentMonth,
                  counts: _counts,
                  cs: cs,
                ),

                const SizedBox(height: 24),

                // ── Activité récente ───────────────────────
                Text('ACTIVITÉ RÉCENTE', style: GoogleFonts.inter(
                  fontSize: 10, fontWeight: FontWeight.w700,
                  color: cs.onSurface.withValues(alpha: 0.4),
                  letterSpacing: 2)),
                const SizedBox(height: 12),

                if (_recent.isEmpty)
                  Center(child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Column(children: [
                      Icon(LucideIcons.dumbbell, size: 40,
                        color: cs.onSurface.withValues(alpha: 0.15)),
                      const SizedBox(height: 12),
                      Text('Aucune séance terminée',
                        style: GoogleFonts.inter(fontSize: 14,
                          color: cs.onSurface.withValues(alpha: 0.35))),
                    ]),
                  ))
                else
                  ...(_recent.map((r) {
                    final workoutId = r['workout_id'] as String;
                    final completedAt = DateTime.parse(r['completed_at'] as String);
                    final workout = _findWorkout(programs, workoutId);
                    return _RecentTile(
                      workoutName: workout?.title ?? workoutId,
                      programName: _findProgramName(programs, workoutId),
                      date: completedAt,
                      cs: cs,
                    );
                  })),
              ],
            ),
    );
  }

  int _longestStreak() {
    if (_counts.isEmpty) return 0;
    final days = _counts.keys.toList()..sort();
    int best = 1, current = 1;
    for (var i = 1; i < days.length; i++) {
      if (days[i].difference(days[i - 1]).inDays == 1) {
        current++;
        if (current > best) best = current;
      } else {
        current = 1;
      }
    }
    return best;
  }

  WorkoutModel? _findWorkout(List<HomeProgramModel> programs, String workoutId) {
    for (final p in programs) {
      for (final w in p.workouts) {
        if (w.id == workoutId) return w;
      }
    }
    return null;
  }

  String? _findProgramName(List<HomeProgramModel> programs, String workoutId) {
    for (final p in programs) {
      for (final w in p.workouts) {
        if (w.id == workoutId) return p.name;
      }
    }
    return null;
  }
}

// ═════════════════════════════════════════════════════════════════
// STAT CARD
// ═════════════════════════════════════════════════════════════════

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final ColorScheme cs;

  const _StatCard({
    required this.icon, required this.value,
    required this.label, required this.color, required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(height: 6),
        Text(value, style: GoogleFonts.outfit(
          fontSize: 22, fontWeight: FontWeight.w800, color: cs.onSurface)),
        Text(label, style: GoogleFonts.inter(
          fontSize: 10, color: cs.onSurface.withValues(alpha: 0.5))),
      ]),
    );
  }
}

// ═════════════════════════════════════════════════════════════════
// CALENDAR HEADER
// ═════════════════════════════════════════════════════════════════

class _CalendarHeader extends StatelessWidget {
  final DateTime month;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final ColorScheme cs;

  const _CalendarHeader({
    required this.month, required this.onPrev,
    required this.onNext, required this.cs,
  });

  static const _months = [
    '', 'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
    'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre',
  ];

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      GestureDetector(
        onTap: onPrev,
        child: Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(LucideIcons.chevronLeft, size: 16, color: cs.onSurface),
        ),
      ),
      Expanded(child: Center(child: Text(
        '${_months[month.month]} ${month.year}',
        style: GoogleFonts.outfit(
          fontSize: 16, fontWeight: FontWeight.w700, color: cs.onSurface),
      ))),
      GestureDetector(
        onTap: onNext,
        child: Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(LucideIcons.chevronRight, size: 16, color: cs.onSurface),
        ),
      ),
    ]);
  }
}

// ═════════════════════════════════════════════════════════════════
// CALENDAR GRID (GitHub-style)
// ═════════════════════════════════════════════════════════════════

class _CalendarGrid extends StatelessWidget {
  final DateTime month;
  final Map<DateTime, int> counts;
  final ColorScheme cs;

  const _CalendarGrid({
    required this.month, required this.counts, required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final firstWeekday = DateTime(month.year, month.month, 1).weekday; // 1=Mon
    final today = DateTime.now();
    final todayNorm = DateTime(today.year, today.month, today.day);

    return Column(children: [
      // Day labels
      Row(children: ['L', 'M', 'M', 'J', 'V', 'S', 'D'].map((d) =>
        Expanded(child: Center(child: Text(d, style: GoogleFonts.inter(
          fontSize: 10, fontWeight: FontWeight.w700,
          color: cs.onSurface.withValues(alpha: 0.3))))),
      ).toList()),
      const SizedBox(height: 8),

      // Day cells
      ...List.generate(6, (week) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(children: List.generate(7, (col) {
            final dayIndex = week * 7 + col - (firstWeekday - 1);
            if (dayIndex < 1 || dayIndex > daysInMonth) {
              return const Expanded(child: SizedBox(height: 40));
            }

            final date = DateTime(month.year, month.month, dayIndex);
            final count = counts[date] ?? 0;
            final isToday = date == todayNorm;
            final isFuture = date.isAfter(todayNorm);

            Color cellColor;
            if (count == 0) {
              cellColor = cs.surfaceContainerHighest;
            } else if (count == 1) {
              cellColor = cs.primary.withValues(alpha: 0.25);
            } else if (count == 2) {
              cellColor = cs.primary.withValues(alpha: 0.5);
            } else {
              cellColor = cs.primary.withValues(alpha: 0.8);
            }

            return Expanded(child: Container(
              height: 40,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: isFuture
                    ? cs.surfaceContainerHighest.withValues(alpha: 0.5)
                    : cellColor,
                borderRadius: BorderRadius.circular(10),
                border: isToday
                    ? Border.all(color: cs.primary, width: 2)
                    : null,
              ),
              child: Center(child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('$dayIndex', style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: isToday ? FontWeight.w800 : FontWeight.w500,
                    color: count > 0 && !isFuture
                        ? Colors.white
                        : isFuture
                            ? cs.onSurface.withValues(alpha: 0.2)
                            : cs.onSurface.withValues(alpha: 0.6))),
                  if (count > 0 && !isFuture)
                    Container(
                      margin: const EdgeInsets.only(top: 2),
                      width: 4, height: 4,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              )),
            ));
          })),
        );
      }),
    ]);
  }
}

// ═════════════════════════════════════════════════════════════════
// RECENT TILE
// ═════════════════════════════════════════════════════════════════

class _RecentTile extends StatelessWidget {
  final String workoutName;
  final String? programName;
  final DateTime date;
  final ColorScheme cs;

  const _RecentTile({
    required this.workoutName,
    required this.programName,
    required this.date,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outline),
      ),
      child: Row(children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            color: cs.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(LucideIcons.checkCircle, size: 18, color: cs.primary),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(workoutName, style: GoogleFonts.outfit(
              fontSize: 14, fontWeight: FontWeight.w700, color: cs.onSurface),
              maxLines: 1, overflow: TextOverflow.ellipsis),
            if (programName != null)
              Text(programName!, style: GoogleFonts.inter(
                fontSize: 11, color: cs.onSurface.withValues(alpha: 0.45))),
          ],
        )),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}',
              style: GoogleFonts.inter(
                fontSize: 11, color: cs.onSurface.withValues(alpha: 0.4))),
            Text(
              '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}',
              style: GoogleFonts.inter(
                fontSize: 10, color: cs.onSurface.withValues(alpha: 0.3))),
          ],
        ),
      ]),
    );
  }
}
