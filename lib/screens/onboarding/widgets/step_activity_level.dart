import 'package:flutter/material.dart';
import 'shared_onboarding_widgets.dart';
// ══════════════════════════════════════════════════════════════════════════════
// STEP 5 — StepFrequency (fond mint + pills liste avec dots)
// ══════════════════════════════════════════════════════════════════════════════
class StepFrequency extends StatelessWidget {
  final String? selectedFrequency;
  final VoidCallback? onBack;
  final ValueChanged<String> onChanged;
  final VoidCallback onNext;

  const StepFrequency({
    super.key,
    required this.selectedFrequency,
    this.onBack,
    required this.onChanged,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final options = [
      _FreqItem('2 jours', 2),
      _FreqItem('3 jours', 3),
      _FreqItem('4 jours', 4),
      _FreqItem('5 jours', 5),
      _FreqItem('6 jours', 6),
    ];

    return mintScaffold(
      child: Column(
        children: [
          OnboardingTopBar(step: 5, total: 7, title: 'Wellbeing', onBack: onBack),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
              child: Column(
                children: [
                  const StepIcon(Icons.calendar_today_rounded),
                  const SizedBox(height: 20),
                  const StepHeader(
                    title: 'Ta fréquence',
                    subtitle: 'On crée ton rythme idéal',
                  ),
                  const SizedBox(height: 28),
                  Expanded(
                    child: ListView.separated(
                      itemCount: options.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (_, i) {
                        final item   = options[i];
                        final isSel  = selectedFrequency == item.label;
                        return GestureDetector(
                          onTap: () => onChanged(item.label),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 220),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 18),
                            decoration: BoxDecoration(
                              color: isSel
                                  ? kCardSel
                                  : Colors.white.withOpacity(0.55),
                              borderRadius: BorderRadius.circular(50),
                              border: Border.all(
                                color: isSel
                                    ? kCardSel
                                    : Colors.white.withOpacity(0.8),
                                width: 1.5,
                              ),
                              boxShadow: isSel
                                  ? [BoxShadow(color: kGreenDark.withOpacity(0.25),
                                      blurRadius: 16, offset: const Offset(0, 6))]
                                  : [],
                            ),
                            child: Row(children: [
                              // dots
                              Row(children: List.generate(6, (idx) {
                                final active = idx < item.days;
                                return Container(
                                  margin: const EdgeInsets.only(right: 5),
                                  width: 8, height: 8,
                                  decoration: BoxDecoration(
                                    color: active
                                        ? (isSel ? Colors.white : kGreenMid)
                                        : (isSel
                                            ? Colors.white30
                                            : Colors.white.withOpacity(0.5)),
                                    shape: BoxShape.circle,
                                  ),
                                );
                              })),
                              const SizedBox(width: 16),
                              Expanded(child: Text(
                                "${item.label} par semaine",
                                style: TextStyle(fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: isSel ? Colors.white : kTextDark),
                              )),
                              if (isSel)
                                const Icon(Icons.check_circle,
                                    color: Colors.white, size: 20),
                            ]),
                          ),
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
            onPressed: selectedFrequency != null ? onNext : null,
          ),
        ],
      ),
    );
  }
}

class _FreqItem {
  final String label;
  final int days;
  _FreqItem(this.label, this.days);
}