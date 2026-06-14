import 'package:fiteva/widgets/custom_date_picker.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'shared_onboarding_widgets.dart';

// ══════════════════════════════════════════════════════════════════════════════
// STEP 7 — StepCycle (fond mint)
// ══════════════════════════════════════════════════════════════════════════════
class StepCycle extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback? onBack;
  const StepCycle({super.key, required this.onNext, this.onBack});

  @override
  State<StepCycle> createState() => _StepCycleState();
}

class _StepCycleState extends State<StepCycle> {
  String? _selectedDuration = '28 jours';
  DateTime _lastPeriodDate  = DateTime(2026, 4, 5);

  final List<String> _durations = [
    '24 jours', '26 jours', '28 jours', '30 jours', '32 jours',
  ];

  String _formatDate(DateTime d) {
    const months = ['Janvier','Février','Mars','Avril','Mai','Juin',
      'Juillet','Août','Septembre','Octobre','Novembre','Décembre'];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  Future<void> _pickDate() async {
    final picked = await showCustomDatePicker(
      context: context,
      initialDate: _lastPeriodDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      title: 'Dernieres regles',
      subtitle: 'Date du premier jour',
      icon: Icons.water_drop_rounded,
      accentColor: const Color(0xFFD94F6B),
    );
    if (picked != null) setState(() => _lastPeriodDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    return mintScaffold(
      child: Column(
        children: [
          OnboardingTopBar(step: 7, total: 7, title: 'Cycle', onBack: widget.onBack),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
              child: Column(
                children: [
                  const StepIcon(LucideIcons.moon),
                  const SizedBox(height: 20),
                  const StepHeader(
                    title: 'Ton cycle menstruel',
                    subtitle: 'La clé du cycle syncing',
                  ),
                  const SizedBox(height: 24),
                  // Info card pill large
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.55),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withOpacity(0.8)),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Durée de ton cycle',
                          style: TextStyle(fontWeight: FontWeight.w700,
                              fontSize: 15, color: kTextDark)),
                        SizedBox(height: 6),
                        Text(
                          'La moyenne est de 28 jours mais chaque femme est unique',
                          style: TextStyle(fontSize: 13, color: kTextMuted),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Align(alignment: Alignment.centerLeft,
                    child: const Text('Durée habituelle',
                      style: TextStyle(fontSize: 13, color: kTextMuted))),
                  const SizedBox(height: 12),
                  // Pills durée
                  Wrap(
                    spacing: 10, runSpacing: 10,
                    children: _durations.map((d) {
                      final isSelected = _selectedDuration == d;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedDuration = d),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 22, vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? kCardSel
                                : Colors.white.withOpacity(0.55),
                            borderRadius: BorderRadius.circular(40),
                            border: Border.all(
                              color: isSelected
                                  ? kCardSel
                                  : Colors.white.withOpacity(0.8),
                            ),
                          ),
                          child: Text(d, style: TextStyle(
                            color: isSelected ? Colors.white : kTextDark,
                            fontWeight: FontWeight.w600, fontSize: 14,
                          )),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  Align(alignment: Alignment.centerLeft,
                    child: const Text('Début de tes dernières règles',
                      style: TextStyle(fontSize: 13, color: kTextMuted))),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: _pickDate,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 18),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.55),
                        borderRadius: BorderRadius.circular(40),
                        border: Border.all(color: Colors.white.withOpacity(0.8)),
                      ),
                      child: Row(children: [
                        const Icon(LucideIcons.calendarDays,
                            size: 20, color: kTextMuted),
                        const SizedBox(width: 12),
                        Text(_formatDate(_lastPeriodDate),
                          style: const TextStyle(fontWeight: FontWeight.w600,
                              fontSize: 16, color: kTextDark)),
                      ]),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          CtaButton(
            label: 'Commencer FITEVA',
            onPressed: widget.onNext,
          ),
        ],
      ),
    );
  }
}
