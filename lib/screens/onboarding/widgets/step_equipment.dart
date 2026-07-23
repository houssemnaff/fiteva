import 'package:flutter/material.dart';
import 'shared_onboarding_widgets.dart';

class StepEquipment extends StatelessWidget {
  final List<String> selectedEquipment;
  final VoidCallback? onBack;
  final ValueChanged<String> onToggleEquipment;
  final VoidCallback onNext;

  const StepEquipment({
    super.key,
    required this.selectedEquipment,
    this.onBack,
    required this.onToggleEquipment,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final options = [
      GoalItem('Aucun matériel', Icons.self_improvement),
      GoalItem('Haltères',       Icons.fitness_center),
      GoalItem('Barre & poids',  Icons.sports_gymnastics),
      GoalItem('Machines',       Icons.precision_manufacturing),
      GoalItem('Résistances',    Icons.timeline),
      GoalItem('Tapis de yoga',  Icons.spa),
    ];

    return mintScaffold(
      child: Column(
        children: [
          OnboardingTopBar(step: 4, total: 7, onBack: onBack),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 4, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const StepHeader(
                    title: 'Ton équipement',
                    subtitle: 'On adapte tes workouts à ce que tu as.',
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
                        final selected = selectedEquipment.contains(item.label);
                        return CompactPill(
                          label: item.label,
                          icon: item.icon,
                          selected: selected,
                          onTap: () => onToggleEquipment(item.label),
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
            onPressed: selectedEquipment.isNotEmpty ? onNext : null,
          ),
        ],
      ),
    );
  }
}
