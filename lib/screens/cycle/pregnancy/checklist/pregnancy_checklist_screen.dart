// ─────────────────────────────────────────────
// pregnancy_checklist_screen.dart
// ─────────────────────────────────────────────

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fiteva/screens/cycle/pregnancy/theme.dart';

import 'pregnancy_checklist_repository.dart';

// ════════════════════════════════════════════════════════════
// MAIN SCREEN
// ════════════════════════════════════════════════════════════

class PregnancyChecklistScreen extends StatefulWidget {
  const PregnancyChecklistScreen({super.key, required this.currentWeek});

  final int currentWeek;

  @override
  State<PregnancyChecklistScreen> createState() =>
      _PregnancyChecklistScreenState();
}

class _PregnancyChecklistScreenState extends State<PregnancyChecklistScreen> {
  late final List<ChecklistTask> _tasks;
  final Set<String> _completed = {};

  Color get _accent => ThreadTheme.threadColorForWeek(widget.currentWeek);

  int get _completedCount => _completed.length;
  int get _total => _tasks.length;
  double get _progress => _total == 0 ? 0 : _completedCount / _total;

  @override
  void initState() {
    super.initState();
    _tasks = PregnancyChecklistRepository.forWeek(widget.currentWeek);
  }

  void _toggle(String id) {
    HapticFeedback.lightImpact();
    setState(() {
      if (_completed.contains(id)) {
        _completed.remove(id);
      } else {
        _completed.add(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final double safeBottom = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: ThreadTheme.bg,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── App bar ─────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: ThreadTheme.bg,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded,
                  size: 18, color: _accent),
              onPressed: () => Navigator.of(context).pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: _ChecklistHeader(
                week: widget.currentWeek,
                accent: _accent,
                progress: _progress,
                completed: _completedCount,
                total: _total,
              ),
            ),
          ),

          // ── Empty state ─────────────────────────────────────────────
          if (_tasks.isEmpty)
            SliverFillRemaining(
              child: _EmptyState(accent: _accent),
            )

          // ── Task cards ──────────────────────────────────────────────
          else ...[
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, i) => _ChecklistCard(
                    key: ValueKey(_tasks[i].id),
                    task: _tasks[i],
                    isCompleted: _completed.contains(_tasks[i].id),
                    accent: _accent,
                    index: i,
                    onToggle: () => _toggle(_tasks[i].id),
                  ),
                  childCount: _tasks.length,
                ),
              ),
            ),
            // Space for FAB
            SliverToBoxAdapter(
              child: SizedBox(height: 100 + safeBottom),
            ),
          ],
        ],
      ),

      // ── Bottom button ────────────────────────────────────────────────
      floatingActionButton: _UpcomingFAB(
        accent: _accent,
        safeBottom: safeBottom,
        onTap: () => _showUpcomingSheet(context),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  void _showUpcomingSheet(BuildContext context) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _UpcomingTasksSheet(
        currentWeek: widget.currentWeek,
        accent: _accent,
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
// HEADER  — Week label + Progress ring + summary
// ════════════════════════════════════════════════════════════

class _ChecklistHeader extends StatelessWidget {
  const _ChecklistHeader({
    required this.week,
    required this.accent,
    required this.progress,
    required this.completed,
    required this.total,
  });

  final int week;
  final Color accent;
  final double progress;
  final int completed;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 72, 20, 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── Text block ─────────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: accent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Week $week',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: accent,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Pregnancy\nChecklist',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: ThreadTheme.textPrimary,
                    letterSpacing: -0.6,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  total == 0
                      ? 'Nothing scheduled'
                      : '$completed of $total tasks complete',
                  style: const TextStyle(
                    fontSize: 13,
                    color: ThreadTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 24),

          // ── Progress ring ──────────────────────────────────────────
          _ProgressRing(
            progress: progress,
            accent: accent,
            completed: completed,
            total: total,
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
// PROGRESS RING
// ════════════════════════════════════════════════════════════

class _ProgressRing extends StatelessWidget {
  const _ProgressRing({
    required this.progress,
    required this.accent,
    required this.completed,
    required this.total,
  });

  final double progress;
  final Color accent;
  final int completed;
  final int total;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 88,
      height: 88,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Ring
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: progress),
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeOutCubic,
            builder: (_, value, __) => CustomPaint(
              size: const Size(88, 88),
              painter: _RingPainter(progress: value, color: accent),
            ),
          ),
          // Center label
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$completed',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: accent,
                  height: 1,
                ),
              ),
              Text(
                'of $total',
                style: const TextStyle(
                  fontSize: 10,
                  color: ThreadTheme.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 10) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // Track
    canvas.drawArc(
      rect,
      -math.pi / 2,
      math.pi * 2,
      false,
      Paint()
        ..color = color.withOpacity(0.1)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 7
        ..strokeCap = StrokeCap.round,
    );

    // Progress arc
    if (progress > 0) {
      canvas.drawArc(
        rect,
        -math.pi / 2,
        math.pi * 2 * progress,
        false,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 7
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.progress != progress;
}

// ════════════════════════════════════════════════════════════
// CHECKLIST CARD
// ════════════════════════════════════════════════════════════

class _ChecklistCard extends StatefulWidget {
  const _ChecklistCard({
    super.key,
    required this.task,
    required this.isCompleted,
    required this.accent,
    required this.index,
    required this.onToggle,
  });

  final ChecklistTask task;
  final bool isCompleted;
  final Color accent;
  final int index;
  final VoidCallback onToggle;

  @override
  State<_ChecklistCard> createState() => _ChecklistCardState();
}

class _ChecklistCardState extends State<_ChecklistCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _scale = Tween<double>(begin: 0.94, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);

    // Staggered entrance
    Future.delayed(Duration(milliseconds: 60 * widget.index), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: ScaleTransition(
        scale: _scale,
        child: GestureDetector(
          onTap: widget.onToggle,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: widget.isCompleted
                  ? widget.accent.withOpacity(0.06)
                  : ThreadTheme.bgCard,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: widget.isCompleted
                    ? widget.accent.withOpacity(0.3)
                    : ThreadTheme.bgCardBorder,
                width: 1,
              ),
              boxShadow: widget.isCompleted
                  ? []
                  : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 12,
                        offset: const Offset(0, 3),
                      ),
                    ],
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Animated checkbox ─────────────────────────────
                _AnimatedCheckbox(
                  isCompleted: widget.isCompleted,
                  accent: widget.accent,
                ),

                const SizedBox(width: 14),

                // ── Emoji + text ──────────────────────────────────
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(widget.task.emoji,
                              style: const TextStyle(fontSize: 16)),
                          const SizedBox(width: 6),
                          Expanded(
                            child: AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 300),
                              style: TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w600,
                                color: widget.isCompleted
                                    ? ThreadTheme.textSecondary
                                    : ThreadTheme.textPrimary,
                                decoration: widget.isCompleted
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none,
                                decorationColor:
                                    widget.accent.withOpacity(0.5),
                                letterSpacing: -0.2,
                              ),
                              child: Text(widget.task.title),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      AnimatedOpacity(
                        opacity: widget.isCompleted ? 0.5 : 1.0,
                        duration: const Duration(milliseconds: 300),
                        child: Text(
                          widget.task.description,
                          style: const TextStyle(
                            fontSize: 12.5,
                            height: 1.5,
                            color: ThreadTheme.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
// ANIMATED CHECKBOX
// ════════════════════════════════════════════════════════════

class _AnimatedCheckbox extends StatelessWidget {
  const _AnimatedCheckbox({
    required this.isCompleted,
    required this.accent,
  });

  final bool isCompleted;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutBack,
      width: 24,
      height: 24,
      margin: const EdgeInsets.only(top: 1),
      decoration: BoxDecoration(
        color: isCompleted ? accent : Colors.transparent,
        borderRadius: BorderRadius.circular(7),
        border: Border.all(
          color: isCompleted ? accent : ThreadTheme.bgCardBorder,
          width: 1.5,
        ),
      ),
      child: isCompleted
          ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
          : null,
    );
  }
}

// ════════════════════════════════════════════════════════════
// EMPTY STATE
// ════════════════════════════════════════════════════════════

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.accent});
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: accent.withOpacity(0.08),
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Center(
                child: Text('🌿', style: TextStyle(fontSize: 32)),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Nothing scheduled\nthis week.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: ThreadTheme.textPrimary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Check back soon or browse\nupcoming tasks below.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                height: 1.55,
                color: ThreadTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
// FLOATING BUTTON — View upcoming tasks
// ════════════════════════════════════════════════════════════

class _UpcomingFAB extends StatelessWidget {
  const _UpcomingFAB({
    required this.accent,
    required this.safeBottom,
    required this.onTap,
  });

  final Color accent;
  final double safeBottom;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: safeBottom + 12),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 28),
          decoration: BoxDecoration(
            color: accent,
            borderRadius: BorderRadius.circular(26),
            boxShadow: [
              BoxShadow(
                color: accent.withOpacity(0.32),
                blurRadius: 18,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.calendar_month_rounded,
                  color: Colors.white, size: 18),
              SizedBox(width: 8),
              Text(
                'View upcoming tasks',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14.5,
                  letterSpacing: 0.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
// UPCOMING TASKS SHEET
// ════════════════════════════════════════════════════════════

class _UpcomingTasksSheet extends StatelessWidget {
  const _UpcomingTasksSheet({
    required this.currentWeek,
    required this.accent,
  });

  final int currentWeek;
  final Color accent;

  /// Next 3 weeks that have data
  List<MapEntry<int, List<ChecklistTask>>> _upcomingWeeks() {
    final results = <MapEntry<int, List<ChecklistTask>>>[];
    for (int w = currentWeek + 1; w <= 40 && results.length < 3; w++) {
      final tasks = PregnancyChecklistRepository.forWeek(w);
      // Only add if the week actually has its own key (not a fallback)
      if (tasks.isNotEmpty) results.add(MapEntry(w, tasks));
    }
    return results;
  }

  @override
  Widget build(BuildContext context) {
    final safeBottom = MediaQuery.of(context).padding.bottom;
    final weeks = _upcomingWeeks();

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.80,
      ),
      decoration: const BoxDecoration(
        color: ThreadTheme.bgCard,
        borderRadius: BorderRadius.all(Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          const SizedBox(height: 12),
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFDDD8D0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Icon(Icons.upcoming_rounded, size: 18, color: accent),
                const SizedBox(width: 8),
                Text(
                  'Upcoming Tasks',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: ThreadTheme.textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Scrollable list
          Flexible(
            child: ListView.builder(
              padding: EdgeInsets.fromLTRB(24, 0, 24, 24 + safeBottom),
              itemCount: weeks.isEmpty ? 1 : weeks.length,
              itemBuilder: (_, wi) {
                if (weeks.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.only(top: 32),
                    child: Center(
                      child: Text(
                        'You\'re almost at the end — no more upcoming weeks.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: ThreadTheme.textSecondary,
                          height: 1.5,
                        ),
                      ),
                    ),
                  );
                }

                final entry = weeks[wi];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Week label
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10, top: 4),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: accent.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Week ${entry.key}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: accent,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                    // Tasks preview
                    ...entry.value.map(
                      (task) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Container(
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                color: accent.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Center(
                                child: Text(task.emoji,
                                    style: const TextStyle(fontSize: 12)),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                task.title,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: ThreadTheme.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}