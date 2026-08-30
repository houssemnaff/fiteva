import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/points_provider.dart';

void showStreakRewardsSheet(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const StreakRewardsSheet(),
  );
}

class _RewardStep {
  final String badgeKey;
  final String days;
  final int points;
  final IconData icon;
  const _RewardStep({
    required this.badgeKey,
    required this.days,
    required this.points,
    required this.icon,
  });
}

const _steps = [
  _RewardStep(badgeKey: 'streak5week', days: '5j', points: PointsAmounts.streak5SameWeekBonus, icon: LucideIcons.flame),
  _RewardStep(badgeKey: 'totalDays10', days: '10j', points: PointsAmounts.totalDays10Bonus, icon: LucideIcons.calendarDays),
  _RewardStep(badgeKey: 'totalDays20', days: '20j', points: PointsAmounts.totalDays20Bonus, icon: LucideIcons.calendarDays),
  _RewardStep(badgeKey: 'totalDays30', days: '30j', points: PointsAmounts.totalDays30Bonus, icon: LucideIcons.calendarDays),
];

/// Feuille "récompenses de connexion" — feuille de route horizontale des
/// paliers streak/total-jours, atteinte = badge présent dans pointsProvider.
class StreakRewardsSheet extends ConsumerWidget {
  const StreakRewardsSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final l10n = ref.watch(l10nProvider);
    final xp = ref.watch(pointsProvider);
    final bottom = MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 16),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: cs.onSurface.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.isFrench ? 'Récompenses de connexion' : 'Login rewards',
                    style: GoogleFonts.outfit(
                      color: cs.onSurface,
                      fontWeight: FontWeight.w800,
                      fontSize: 19,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: cs.onSurface.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.close_rounded, size: 16, color: cs.onSurface),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 6),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              l10n.isFrench
                  ? '5 jours de connexion consécutifs dans la même semaine : ${PointsAmounts.streak5SameWeekBonus} points. '
                    'Puis des paliers sur ton total de jours de connexion (pas besoin d\'être consécutifs).'
                  : '5 consecutive login days within the same week: ${PointsAmounts.streak5SameWeekBonus} points. '
                    'Then milestones on your total login days (don\'t need to be consecutive).',
              style: GoogleFonts.inter(fontSize: 12.5, color: cs.onSurface.withValues(alpha: 0.6), height: 1.4),
            ),
          ),

          const SizedBox(height: 28),

          Padding(
            padding: EdgeInsets.fromLTRB(24, 0, 24, bottom + 28),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (int i = 0; i < _steps.length; i++) ...[
                  if (i > 0)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 24),
                        child: Container(
                          height: 3,
                          decoration: BoxDecoration(
                            color: (xp.badges.contains(_steps[i - 1].badgeKey))
                                ? cs.primary
                                : cs.onSurface.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ),
                  _StepNode(step: _steps[i], reached: xp.badges.contains(_steps[i].badgeKey)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StepNode extends StatelessWidget {
  const _StepNode({required this.step, required this.reached});

  final _RewardStep step;
  final bool reached;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      children: [
        Container(
          width: 48, height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: reached ? cs.primary : cs.onSurface.withValues(alpha: 0.08),
            shape: BoxShape.circle,
            border: reached ? null : Border.all(color: cs.onSurface.withValues(alpha: 0.15)),
          ),
          child: Icon(
            reached ? LucideIcons.check : step.icon,
            size: 20,
            color: reached ? cs.onPrimary : cs.onSurface.withValues(alpha: 0.4),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          step.days,
          style: GoogleFonts.outfit(
            fontSize: 13, fontWeight: FontWeight.w800,
            color: reached ? cs.onSurface : cs.onSurface.withValues(alpha: 0.5),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '+${step.points}',
          style: GoogleFonts.inter(
            fontSize: 11, fontWeight: FontWeight.w600,
            color: reached ? cs.primary : cs.onSurface.withValues(alpha: 0.35),
          ),
        ),
      ],
    );
  }
}
