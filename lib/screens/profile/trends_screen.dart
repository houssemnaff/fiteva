import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../providers/theme_provider.dart';
import '../../providers/user_profile_provider.dart';
import '../../core/nutrition/nutrition_provider.dart' as nut;
import '../../l10n/app_localizations.dart';
import '../../services/trends_service.dart';

/// Vue "Tendances" — agrège calories, eau et humeur sur les 14 derniers
/// jours. Les données existaient déjà en base (repas, eau, humeur) mais
/// n'étaient visualisées que jour par jour, jamais dans la durée.
class TrendsScreen extends ConsumerStatefulWidget {
  const TrendsScreen({super.key});

  @override
  ConsumerState<TrendsScreen> createState() => _TrendsScreenState();
}

class _TrendsScreenState extends ConsumerState<TrendsScreen> {
  static const _days = 14;

  bool _loading = true;
  List<DayPoint> _calories = [];
  List<DayPoint> _water = [];
  List<DayPoint?> _mood = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final results = await Future.wait([
      TrendsService.caloriesByDay(days: _days),
      TrendsService.waterByDay(days: _days),
      TrendsService.moodByDay(days: _days),
    ]);
    if (!mounted) return;
    setState(() {
      _calories = results[0] as List<DayPoint>;
      _water = results[1] as List<DayPoint>;
      _mood = results[2] as List<DayPoint?>;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(themeModeProvider) == ThemeMode.dark;
    final l10n = ref.watch(l10nProvider);
    final profile = ref.watch(userProfileProvider);
    final nutProfile = ref.watch(nut.userProfileProvider);

    final bg = isDarkMode ? const Color(0xFF0D0D0D) : const Color(0xFFF6F7F5);
    final ink = isDarkMode ? const Color(0xFFF0F0EE) : const Color(0xFF111110);
    final muted = isDarkMode ? const Color(0xFF888886) : const Color(0xFF6B6B68);
    final surf = isDarkMode ? const Color(0xFF1A1A1A) : Colors.white;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        title: Text(
          l10n.isFrench ? 'Tendances' : 'Trends',
          style: TextStyle(color: ink, fontWeight: FontWeight.w700),
        ),
        iconTheme: IconThemeData(color: ink),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              children: [
                _TrendCard(
                  title: l10n.isFrench ? 'Calories (14 jours)' : 'Calories (14 days)',
                  icon: LucideIcons.flame,
                  color: const Color(0xFFF4A940),
                  surf: surf, ink: ink, muted: muted,
                  child: _BarChart(
                    points: _calories,
                    goal: profile.targets.tdeeKcal.toDouble(),
                    barColor: const Color(0xFFF4A940),
                    goalLabel: l10n.isFrench ? 'objectif' : 'goal',
                  ),
                ),
                const SizedBox(height: 16),
                _TrendCard(
                  title: l10n.isFrench ? 'Eau (14 jours)' : 'Water (14 days)',
                  icon: LucideIcons.droplets,
                  color: const Color(0xFF3B9FD4),
                  surf: surf, ink: ink, muted: muted,
                  child: _BarChart(
                    points: _water,
                    goal: nutProfile.waterGoalMl.toDouble(),
                    barColor: const Color(0xFF3B9FD4),
                    goalLabel: l10n.isFrench ? 'objectif' : 'goal',
                    valueSuffix: 'ml',
                  ),
                ),
                const SizedBox(height: 16),
                _TrendCard(
                  title: l10n.isFrench ? 'Humeur (14 jours)' : 'Mood (14 days)',
                  icon: LucideIcons.smile,
                  color: const Color(0xFFE0678F),
                  surf: surf, ink: ink, muted: muted,
                  child: _MoodChart(points: _mood, color: const Color(0xFFE0678F)),
                ),
              ],
            ),
    );
  }
}

class _TrendCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final Color surf, ink, muted;
  final Widget child;

  const _TrendCard({
    required this.title, required this.icon, required this.color,
    required this.surf, required this.ink, required this.muted,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surf,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 8),
              Text(title, style: TextStyle(
                  color: ink, fontWeight: FontWeight.w700, fontSize: 15)),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _BarChart extends StatelessWidget {
  final List<DayPoint> points;
  final double goal;
  final Color barColor;
  final String goalLabel;
  final String valueSuffix;

  const _BarChart({
    required this.points, required this.goal, required this.barColor,
    required this.goalLabel, this.valueSuffix = 'kcal',
  });

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) {
      return const SizedBox(height: 120, child: Center(child: Text('—')));
    }
    final maxVal = [
      goal,
      ...points.map((p) => p.value),
    ].reduce((a, b) => a > b ? a : b).clamp(1, double.infinity);

    return SizedBox(
      height: 130,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: points.map((p) {
          final ratio = (p.value / maxVal).clamp(0.0, 1.0);
          final overGoal = goal > 0 && p.value > goal;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Tooltip(
                message: '${p.value.round()} $valueSuffix',
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      height: 100 * ratio,
                      decoration: BoxDecoration(
                        color: overGoal
                            ? barColor
                            : barColor.withValues(alpha: 0.45),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${p.date.day}',
                      style: const TextStyle(fontSize: 9, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _MoodChart extends StatelessWidget {
  final List<DayPoint?> points;
  final Color color;

  const _MoodChart({required this.points, required this.color});

  @override
  Widget build(BuildContext context) {
    if (points.every((p) => p == null)) {
      return const SizedBox(
        height: 80,
        child: Center(child: Text('—', style: TextStyle(color: Colors.grey))),
      );
    }
    return SizedBox(
      height: 100,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: points.map((p) {
          final ratio = p == null ? 0.0 : ((p.value + 1) / 5).clamp(0.1, 1.0);
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    height: 70 * ratio,
                    decoration: BoxDecoration(
                      color: p == null
                          ? Colors.grey.withValues(alpha: 0.15)
                          : color.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${p?.date.day ?? ''}',
                    style: const TextStyle(fontSize: 9, color: Colors.grey),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
