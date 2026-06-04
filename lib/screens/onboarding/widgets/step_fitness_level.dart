import 'package:flutter/material.dart';
import 'shared_onboarding_widgets.dart';

// ══════════════════════════════════════════════════════════════════════════════
// STEP 3 — StepFitnessLevel (fond mint + pills liste)
// ══════════════════════════════════════════════════════════════════════════════
class StepFitnessLevel extends StatelessWidget {
  final String? selectedLevel;
  final VoidCallback? onBack;
  final ValueChanged<String> onChanged;
  final VoidCallback onNext;

  const StepFitnessLevel({
    super.key,
    required this.selectedLevel,
    this.onBack,
    required this.onChanged,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final levels = [
      LevelItem('Débutant',      'Moins de 6 mois d\'expérience', Icons.eco_outlined),
      LevelItem('Intermédiaire', '6 mois à 2 ans d\'expérience',  Icons.local_fire_department),
      LevelItem('Avancé',        'Plus de 2 ans d\'expérience',   Icons.flash_on),
    ];

    return mintScaffold(
      child: Column(
        children: [
          OnboardingTopBar(step: 3, total: 7, title: 'Level', onBack: onBack),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
              child: Column(
                children: [
                  const StepIcon(Icons.show_chart_rounded),
                  const SizedBox(height: 20),
                  const StepHeader(
                    title: 'Ton niveau',
                    subtitle: 'On adapte ton programme',
                  ),
                  const SizedBox(height: 32),
                  Expanded(
                    child: ListView.separated(
                      itemCount: levels.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (_, i) {
                        final item = levels[i];
                        return PillCard(
                          label: item.label,
                          sublabel: item.sub,
                          icon: item.icon,
                          selected: selectedLevel == item.label,
                          onTap: () => onChanged(item.label),
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
            onPressed: selectedLevel != null ? onNext : null,
          ),
        ],
      ),
    );
  }
}
