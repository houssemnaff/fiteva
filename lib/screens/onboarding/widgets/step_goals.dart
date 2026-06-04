import 'package:flutter/material.dart';
import 'shared_onboarding_widgets.dart';

// ══════════════════════════════════════════════════════════════════════════════
// STEP 2 — StepGoals  (fond mint + pills)
// ══════════════════════════════════════════════════════════════════════════════
class StepGoals extends StatelessWidget {
  final List<String> selectedGoals;
  final VoidCallback? onBack;
  final ValueChanged<String> onToggleGoal;
  final VoidCallback onNext;

  const StepGoals({
    super.key,
    required this.selectedGoals,
    this.onBack,
    required this.onToggleGoal,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final options = [
      GoalItem('Perdre du poids',    Icons.local_fire_department),
      GoalItem('Prendre du muscle',  Icons.fitness_center),
      GoalItem('Endurance',          Icons.directions_run),
      GoalItem('Réduire le stress',  Icons.self_improvement),
      GoalItem('Hormones',           Icons.spa),
      GoalItem('Sommeil',            Icons.nightlight_round),
    ];

    return mintScaffold(
      child: Column(
        children: [
          OnboardingTopBar(step: 2, total: 7, title: 'Goals', onBack: onBack),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
              child: Column(
                children: [
                  const StepIcon(Icons.track_changes_rounded),
                  const SizedBox(height: 20),
                  const StepHeader(
                    title: 'Tes objectifs',
                    subtitle: 'Choisis ce qui te correspond',
                  ),
                  const SizedBox(height: 28),
                  // Grille 2 colonnes de pills
                  Expanded(
                    child: GridView.builder(
                      itemCount: options.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 2.8,
                      ),
                      itemBuilder: (_, i) {
                        final item = options[i];
                        final selected = selectedGoals.contains(item.label);
                        return CompactPill(
                          label: item.label,
                          icon: item.icon,
                          selected: selected,
                          onTap: () => onToggleGoal(item.label),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          CtaButton(
            label: 'Next',
            onPressed: selectedGoals.isNotEmpty ? onNext : null,
          ),
        ],
      ),
    );
  }
}
