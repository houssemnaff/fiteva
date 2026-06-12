/*import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/workout_model.dart';
import '../../models/home_program_model.dart';
import '../../providers/mock_data_provider.dart';
import 'theme/color.dart';
import 'workout_detail_screen.dart';

// ═══════════════════════════════════════════════════════════
// MODELS
// ═══════════════════════════════════════════════════════════

enum DayStatus { rest, planned, done, today }

class DayPlan {
  final String dayLabel;   // 'LUN', 'MAR', etc.
  final String fullDay;    // 'Lundi', 'Mardi', etc.
  final DateTime date;
  DayStatus status;
  WorkoutModel? workout;

  DayPlan({
    required this.dayLabel,
    required this.fullDay,
    required this.date,
    this.status = DayStatus.rest,
    this.workout,
  });
}

// ═══════════════════════════════════════════════════════════
// PROVIDER
// ═══════════════════════════════════════════════════════════

class WeeklyPlanNotifier extends Notifier<List<DayPlan>> {
  @override
  List<DayPlan> build() => _generateWeek();

  List<DayPlan> _generateWeek() {
    final now = DateTime.now();
    // Find Monday of current week
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final labels = ['LUN', 'MAR', 'MER', 'JEU', 'VEN', 'SAM', 'DIM'];
    final full   = ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche'];

    return List.generate(7, (i) {
      final date = monday.add(Duration(days: i));
      DayStatus status;
      if (_isSameDay(date, now)) {
        status = DayStatus.today;
      } else if (date.isBefore(now)) {
        status = DayStatus.rest;
      } else {
        status = DayStatus.rest;
      }
      return DayPlan(
        dayLabel: labels[i],
        fullDay: full[i],
        date: date,
        status: status,
      );
    });
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  void assignWorkout(int dayIndex, WorkoutModel workout) {
    final updated = List<DayPlan>.from(state);
    updated[dayIndex] = DayPlan(
      dayLabel: updated[dayIndex].dayLabel,
      fullDay:  updated[dayIndex].fullDay,
      date:     updated[dayIndex].date,
      status:   DayStatus.planned,
      workout:  workout,
    );
    state = updated;
  }

  void markAsDone(int dayIndex) {
    final updated = List<DayPlan>.from(state);
    final day = updated[dayIndex];
    updated[dayIndex] = DayPlan(
      dayLabel: day.dayLabel,
      fullDay:  day.fullDay,
      date:     day.date,
      status:   DayStatus.done,
      workout:  day.workout,
    );
    state = updated;
  }

  void removeWorkout(int dayIndex) {
    final updated = List<DayPlan>.from(state);
    final day = updated[dayIndex];
    final now = DateTime.now();
    updated[dayIndex] = DayPlan(
      dayLabel: day.dayLabel,
      fullDay:  day.fullDay,
      date:     day.date,
      status:   _isSameDay(day.date, now) ? DayStatus.today : DayStatus.rest,
      workout:  null,
    );
    state = updated;
  }
}

final weeklyPlanProvider =
    NotifierProvider<WeeklyPlanNotifier, List<DayPlan>>(WeeklyPlanNotifier.new);

// ═══════════════════════════════════════════════════════════
// SCREEN
// ═══════════════════════════════════════════════════════════

class WeeklyPlanScreen extends ConsumerStatefulWidget {
  const WeeklyPlanScreen({super.key});

  @override
  ConsumerState<WeeklyPlanScreen> createState() => _WeeklyPlanScreenState();
}

class _WeeklyPlanScreenState extends ConsumerState<WeeklyPlanScreen>
    with SingleTickerProviderStateMixin {
  int _selectedDay = -1;
  late AnimationController _controller;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _controller.forward();

    // Auto-select today
    final plans = ref.read(weeklyPlanProvider);
    final todayIdx = plans.indexWhere((d) => d.status == DayStatus.today);
    if (todayIdx != -1) _selectedDay = todayIdx;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _statusColor(DayStatus s, ColorScheme cs) {
    switch (s) {
      case DayStatus.done:    return const Color(0xFF4CAF50);
      case DayStatus.planned: return cs.primary;
      case DayStatus.today:   return WorkoutColors.grossesse;
      case DayStatus.rest:    return cs.surfaceContainerHighest;
    }
  }

  IconData _statusIcon(DayStatus s) {
    switch (s) {
      case DayStatus.done:    return Icons.check_circle_rounded;
      case DayStatus.planned: return Icons.fitness_center_rounded;
      case DayStatus.today:   return Icons.today_rounded;
      case DayStatus.rest:    return Icons.hotel_rounded;
    }
  }

  String _statusLabel(DayStatus s) {
    switch (s) {
      case DayStatus.done:    return 'Terminé';
      case DayStatus.planned: return 'Planifié';
      case DayStatus.today:   return "Aujourd'hui";
      case DayStatus.rest:    return 'Repos';
    }
  }

  // ── Stats helpers ──────────────────────────────────────
  Map<String, int> _computeStats(List<DayPlan> plans) {
    int done    = plans.where((d) => d.status == DayStatus.done).length;
    int planned = plans.where((d) => d.status == DayStatus.planned ||
                                     d.status == DayStatus.today).length;
    int totalCal = plans
        .where((d) => d.workout != null && d.status == DayStatus.done)
        .fold(0, (sum, d) => sum + int.tryParse(d.workout!.calories)!);
    return {'done': done, 'planned': planned, 'calories': totalCal};
  }

  // ── Bottom sheet: choisir un workout ──────────────────
  void _showPickWorkout(BuildContext context, int dayIndex) {
    final workouts     = ref.read(workoutsProvider);
    final homePrograms = ref.read(homeProgramsProvider);
    final sallePrograms= ref.read(salleProgramsProvider);

    // Flatten program workouts
    final programWorkouts = [
      ...homePrograms.expand((p) => p.workouts),
      ...sallePrograms.expand((p) => p.workouts),
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _WorkoutPickerSheet(
        workouts: [...workouts, ...programWorkouts],
        onPick: (w) {
          ref.read(weeklyPlanProvider.notifier).assignWorkout(dayIndex, w);
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme       = Theme.of(context);
    final cs          = theme.colorScheme;
    final plans       = ref.watch(weeklyPlanProvider);
    final stats       = _computeStats(plans);
    final selectedPlan = _selectedDay >= 0 ? plans[_selectedDay] : null;

    return Scaffold(
      backgroundColor: cs.background,
      appBar: AppBar(
        backgroundColor: cs.surface,
        elevation: 0,
        title: Text(
          'Planning de la semaine',
          style: TextStyle(
            color: cs.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: false,
      ),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ── Stats Banner ────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        cs.primary.withOpacity(0.9),
                        cs.secondary.withOpacity(0.9),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: cs.primary.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _StatChip(
                        icon: Icons.check_circle_rounded,
                        value: '${stats['done']}',
                        label: 'Terminés',
                        color: const Color(0xFF4CAF50),
                        textColor: cs.onPrimary,
                      ),
                      _Divider(),
                      _StatChip(
                        icon: Icons.fitness_center_rounded,
                        value: '${stats['planned']}',
                        label: 'Planifiés',
                        color: cs.onPrimary,
                        textColor: cs.onPrimary,
                      ),
                      _Divider(),
                      _StatChip(
                        icon: Icons.local_fire_department_rounded,
                        value: '${stats['calories']}',
                        label: 'kcal',
                        color: const Color(0xFFFF7043),
                        textColor: cs.onPrimary,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ── Day Strip ───────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Cette semaine',
                  style: TextStyle(
                    color: cs.onSurface,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              SizedBox(
                height: 90,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: plans.length,
                  itemBuilder: (_, i) {
                    final plan = plans[i];
                    final isSelected = _selectedDay == i;
                    final statusColor = _statusColor(plan.status, cs);

                    return GestureDetector(
                      onTap: () => setState(() => _selectedDay = i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        width: 62,
                        margin: const EdgeInsets.only(right: 10),
                        decoration: BoxDecoration(
                          color: isSelected ? statusColor : cs.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? statusColor
                                : plan.status != DayStatus.rest
                                    ? statusColor.withOpacity(0.5)
                                    : cs.outlineVariant,
                            width: isSelected ? 2 : 1,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: statusColor.withOpacity(0.35),
                                    blurRadius: 10,
                                    offset: const Offset(0, 3),
                                  )
                                ]
                              : [],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              plan.dayLabel,
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : cs.onSurface.withOpacity(0.6),
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '${plan.date.day}',
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : cs.onSurface,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Icon(
                              _statusIcon(plan.status),
                              size: 14,
                              color: isSelected
                                  ? Colors.white.withOpacity(0.85)
                                  : statusColor,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),

              // ── Selected Day Detail ─────────────────────
              if (selectedPlan != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _DayDetail(
                      key: ValueKey(_selectedDay),
                      plan: selectedPlan,
                      dayIndex: _selectedDay,
                      statusColor: _statusColor(selectedPlan.status, cs),
                      statusLabel: _statusLabel(selectedPlan.status),
                      onAddWorkout: () => _showPickWorkout(context, _selectedDay),
                      onMarkDone: () => ref
                          .read(weeklyPlanProvider.notifier)
                          .markAsDone(_selectedDay),
                      onRemove: () => ref
                          .read(weeklyPlanProvider.notifier)
                          .removeWorkout(_selectedDay),
                      onViewDetail: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              WorkoutDetailScreen(workout: selectedPlan.workout!),
                        ),
                      ),
                    ),
                  ),
                ),

              const SizedBox(height: 24),

              // ── Weekly Overview List ────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Aperçu de la semaine',
                  style: TextStyle(
                    color: cs.onSurface,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: plans.length,
                itemBuilder: (_, i) {
                  final plan = plans[i];
                  final isSelected = _selectedDay == i;
                  final statusColor = _statusColor(plan.status, cs);

                  return GestureDetector(
                    onTap: () => setState(() => _selectedDay = i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? statusColor.withOpacity(0.12)
                            : cs.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? statusColor
                              : cs.outlineVariant,
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          // Day circle
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                plan.dayLabel,
                                style: TextStyle(
                                  color: statusColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),

                          // Workout info
                          Expanded(
                            child: plan.workout != null
                                ? Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        plan.workout!.title,
                                        style: TextStyle(
                                          color: cs.onSurface,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Row(children: [
                                        Icon(Icons.timer_rounded,
                                            size: 12,
                                            color: cs.onSurface.withOpacity(0.5)),
                                        const SizedBox(width: 4),
                                        Text(
                                          plan.workout!.duration,
                                          style: TextStyle(
                                            color: cs.onSurface.withOpacity(0.55),
                                            fontSize: 12,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Icon(Icons.local_fire_department_rounded,
                                            size: 12,
                                            color: const Color(0xFFFF7043)
                                                .withOpacity(0.8)),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${plan.workout!.calories} kcal',
                                          style: TextStyle(
                                            color: cs.onSurface.withOpacity(0.55),
                                            fontSize: 12,
                                          ),
                                        ),
                                      ]),
                                    ],
                                  )
                                : Text(
                                    plan.status == DayStatus.rest
                                        ? 'Jour de repos'
                                        : plan.fullDay,
                                    style: TextStyle(
                                      color: cs.onSurface.withOpacity(0.55),
                                      fontSize: 14,
                                    ),
                                  ),
                          ),

                          // Status badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(children: [
                              Icon(_statusIcon(plan.status),
                                  size: 12, color: statusColor),
                              const SizedBox(width: 4),
                              Text(
                                _statusLabel(plan.status),
                                style: TextStyle(
                                  color: statusColor,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ]),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// DAY DETAIL WIDGET
// ═══════════════════════════════════════════════════════════

class _DayDetail extends StatelessWidget {
  final DayPlan plan;
  final int dayIndex;
  final Color statusColor;
  final String statusLabel;
  final VoidCallback onAddWorkout;
  final VoidCallback onMarkDone;
  final VoidCallback onRemove;
  final VoidCallback onViewDetail;

  const _DayDetail({
    super.key,
    required this.plan,
    required this.dayIndex,
    required this.statusColor,
    required this.statusLabel,
    required this.onAddWorkout,
    required this.onMarkDone,
    required this.onRemove,
    required this.onViewDetail,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final w  = plan.workout;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: statusColor.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                Icon(_dayIcon(plan.date.weekday),
                    color: statusColor, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        plan.fullDay,
                        style: TextStyle(
                          color: cs.onSurface,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        '${plan.date.day}/${plan.date.month}/${plan.date.year}',
                        style: TextStyle(
                          color: cs.onSurface.withOpacity(0.5),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    statusLabel,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: w == null ? _EmptyDay(
              onAdd: onAddWorkout,
              statusColor: statusColor,
            ) : _WorkoutCard(
              workout: w,
              statusColor: statusColor,
              plan: plan,
              onViewDetail: onViewDetail,
              onMarkDone: onMarkDone,
              onRemove: onRemove,
              onAddWorkout: onAddWorkout,
            ),
          ),
        ],
      ),
    );
  }

  IconData _dayIcon(int weekday) {
    switch (weekday) {
      case 6:
      case 7: return Icons.weekend_rounded;
      default: return Icons.calendar_today_rounded;
    }
  }
}

// ── Empty Day ──────────────────────────────────────────────

class _EmptyDay extends StatelessWidget {
  final VoidCallback onAdd;
  final Color statusColor;

  const _EmptyDay({required this.onAdd, required this.statusColor});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 24),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest.withOpacity(0.5),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(children: [
            Icon(Icons.add_circle_outline_rounded,
                size: 36, color: cs.onSurface.withOpacity(0.3)),
            const SizedBox(height: 8),
            Text('Aucun workout prévu',
                style: TextStyle(
                    color: cs.onSurface.withOpacity(0.45),
                    fontSize: 14)),
          ]),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: onAdd,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 13),
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(50),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.add_rounded, color: Colors.white, size: 18),
                const SizedBox(width: 6),
                const Text('Ajouter un workout',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Workout Card in detail ─────────────────────────────────

class _WorkoutCard extends StatelessWidget {
  final WorkoutModel workout;
  final Color statusColor;
  final DayPlan plan;
  final VoidCallback onViewDetail;
  final VoidCallback onMarkDone;
  final VoidCallback onRemove;
  final VoidCallback onAddWorkout;

  const _WorkoutCard({
    required this.workout,
    required this.statusColor,
    required this.plan,
    required this.onViewDetail,
    required this.onMarkDone,
    required this.onRemove,
    required this.onAddWorkout,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDone = plan.status == DayStatus.done;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Workout image + info
        GestureDetector(
          onTap: onViewDetail,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Stack(
              children: [
                Image.asset(
                  workout.imageUrl,
                  width: double.infinity,
                  height: 140,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 140,
                    color: cs.surfaceContainerHighest,
                    child: Center(
                      child: Icon(Icons.fitness_center_rounded,
                          size: 40,
                          color: cs.onSurface.withOpacity(0.2)),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.65),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ),
                if (isDone)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black.withOpacity(0.35),
                      child: const Center(
                        child: Icon(Icons.check_circle_rounded,
                            color: Color(0xFF4CAF50), size: 50),
                      ),
                    ),
                  ),
                Positioned(
                  bottom: 12, left: 12, right: 12,
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          workout.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          workout.level,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
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

        const SizedBox(height: 12),

        // Info row
        Row(
          children: [
            _InfoPill(
              icon: Icons.timer_rounded,
              label: workout.duration,
              color: statusColor,
            ),
            const SizedBox(width: 8),
            _InfoPill(
              icon: Icons.local_fire_department_rounded,
              label: '${workout.calories} kcal',
              color: const Color(0xFFFF7043),
            ),
            const SizedBox(width: 8),
            _InfoPill(
              icon: Icons.category_rounded,
              label: workout.category,
              color: WorkoutColors.dance,
            ),
          ],
        ),

        const SizedBox(height: 14),

        // Exercises preview
        Text('Exercices',
            style: TextStyle(
              color: cs.onSurface,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            )),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: workout.exercises
              .take(4)
              .map((e) => Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(e,
                        style: TextStyle(
                          color: cs.onSurface.withOpacity(0.7),
                          fontSize: 11,
                        )),
                  ))
              .toList(),
        ),

        const SizedBox(height: 16),

        // Action buttons
        Row(
          children: [
            if (!isDone)
              Expanded(
                child: GestureDetector(
                  onTap: onMarkDone,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_rounded,
                            color: Colors.white, size: 16),
                        SizedBox(width: 6),
                        Text('Marquer terminé',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            )),
                      ],
                    ),
                  ),
                ),
              ),
            if (!isDone) const SizedBox(width: 10),
            Expanded(
              child: GestureDetector(
                onTap: onViewDetail,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.play_arrow_rounded,
                          color: Colors.white, size: 16),
                      const SizedBox(width: 6),
                      Text(isDone ? 'Revoir' : 'Démarrer',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          )),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        // Change / remove
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: onAddWorkout,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: cs.surface,
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(color: statusColor.withOpacity(0.4)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.swap_horiz_rounded,
                          color: statusColor, size: 16),
                      const SizedBox(width: 6),
                      Text('Changer',
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          )),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: onRemove,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: cs.surface,
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(
                      color: cs.error.withOpacity(0.4)),
                ),
                child: Icon(Icons.delete_outline_rounded,
                    color: cs.error, size: 18),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════
// WORKOUT PICKER BOTTOM SHEET
// ═══════════════════════════════════════════════════════════

class _WorkoutPickerSheet extends StatefulWidget {
  final List<WorkoutModel> workouts;
  final void Function(WorkoutModel) onPick;

  const _WorkoutPickerSheet({
    required this.workouts,
    required this.onPick,
  });

  @override
  State<_WorkoutPickerSheet> createState() => _WorkoutPickerSheetState();
}

class _WorkoutPickerSheetState extends State<_WorkoutPickerSheet> {
  String _selectedCat = 'Tout';

  List<String> get _categories {
    final cats = widget.workouts.map((w) => w.category).toSet().toList();
    return ['Tout', ...cats];
  }

  List<WorkoutModel> get _filtered {
    if (_selectedCat == 'Tout') return widget.workouts;
    return widget.workouts
        .where((w) => w.category == _selectedCat)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      height: MediaQuery.of(context).size.height * 0.78,
      decoration: BoxDecoration(
        color: cs.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            width: 40, height: 4,
            margin: const EdgeInsets.only(top: 12, bottom: 16),
            decoration: BoxDecoration(
              color: cs.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Text('Choisir un workout',
                    style: TextStyle(
                      color: cs.onSurface,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    )),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerHighest,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.close_rounded,
                        size: 18, color: cs.onSurface),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Category filter
          SizedBox(
            height: 36,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _categories.length,
              itemBuilder: (_, i) {
                final cat = _categories[i];
                final sel = _selectedCat == cat;
                return GestureDetector(
                  onTap: () => setState(() => _selectedCat = cat),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: sel ? cs.primary : cs.surface,
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(
                        color: sel ? cs.primary : cs.outlineVariant,
                      ),
                    ),
                    child: Text(cat,
                        style: TextStyle(
                          color: sel
                              ? cs.onPrimary
                              : cs.onSurface.withOpacity(0.7),
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        )),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 12),

          // List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _filtered.length,
              itemBuilder: (_, i) {
                final w = _filtered[i];
                return GestureDetector(
                  onTap: () => widget.onPick(w),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: cs.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: cs.outlineVariant),
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.asset(
                            w.imageUrl,
                            width: 56,
                            height: 56,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 56, height: 56,
                              color: cs.surfaceContainerHighest,
                              child: Icon(Icons.fitness_center_rounded,
                                  color: cs.onSurface.withOpacity(0.3)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(w.title,
                                  style: TextStyle(
                                    color: cs.onSurface,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  )),
                              const SizedBox(height: 4),
                              Row(children: [
                                Icon(Icons.timer_rounded,
                                    size: 11,
                                    color: cs.onSurface.withOpacity(0.45)),
                                const SizedBox(width: 3),
                                Text(w.duration,
                                    style: TextStyle(
                                      color: cs.onSurface.withOpacity(0.5),
                                      fontSize: 11,
                                    )),
                                const SizedBox(width: 8),
                                Icon(Icons.local_fire_department_rounded,
                                    size: 11,
                                    color: const Color(0xFFFF7043)
                                        .withOpacity(0.8)),
                                const SizedBox(width: 3),
                                Text('${w.calories} kcal',
                                    style: TextStyle(
                                      color: cs.onSurface.withOpacity(0.5),
                                      fontSize: 11,
                                    )),
                              ]),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: cs.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(w.level,
                              style: TextStyle(
                                color: cs.primary,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              )),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// SMALL HELPERS
// ═══════════════════════════════════════════════════════════

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final Color textColor;

  const _StatChip({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Icon(icon, color: color, size: 20),
      const SizedBox(height: 4),
      Text(value,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          )),
      Text(label,
          style: TextStyle(
            color: textColor.withOpacity(0.7),
            fontSize: 11,
          )),
    ]);
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 36,
      color: Colors.white.withOpacity(0.25),
    );
  }
}

class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoPill({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 4),
        Text(label,
            style: TextStyle(
              color: cs.onSurface.withOpacity(0.75),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            )),
      ]),
    );
  }
}*/