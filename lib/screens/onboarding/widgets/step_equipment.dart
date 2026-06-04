import 'package:flutter/material.dart';
import 'shared_onboarding_widgets.dart';

// ══════════════════════════════════════════════════════════════════════════════
// STEP 4 — StepEquipment (fond mint + grille pills)
// ══════════════════════════════════════════════════════════════════════════════
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
      _EquipItem('Aucun matériel', Icons.self_improvement),
      _EquipItem('Haltères',       Icons.fitness_center),
      _EquipItem('Barre & poids',  Icons.sports_gymnastics),
      _EquipItem('Machines',       Icons.precision_manufacturing),
      _EquipItem('Résistances',    Icons.timeline),
      _EquipItem('Tapis de yoga',  Icons.spa),
    ];

    return mintScaffold(
      child: Column(
        children: [
          OnboardingTopBar(step: 4, total: 7, title: 'Equipment', onBack: onBack),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
              child: Column(
                children: [
                  const StepIcon(Icons.sports_gymnastics),
                  const SizedBox(height: 20),
                  const StepHeader(
                    title: 'Ton équipement',
                    subtitle: 'On adapte tes workouts',
                  ),
                  const SizedBox(height: 28),
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
            label: 'Next',
            onPressed: selectedEquipment.isNotEmpty ? onNext : null,
          ),
        ],
      ),
    );
  }
}

class _EquipItem {
  final String label;
  final IconData icon;
  _EquipItem(this.label, this.icon);
}
