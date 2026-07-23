import 'package:flutter/material.dart';
import 'shared_onboarding_widgets.dart';

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
          OnboardingTopBar(step: 2, total: 7, onBack: onBack),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 4, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const StepHeader(
                    title: 'Tes objectifs',
                    subtitle: 'Sélectionne tout ce qui te correspond.',
                  ),
                  const SizedBox(height: 32),
                  Expanded(
                    child: GridView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: options.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 0.95,
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
            label: 'Continuer',
            onPressed: selectedGoals.isNotEmpty ? onNext : null,
          ),
        ],
      ),
    );
  }
}
