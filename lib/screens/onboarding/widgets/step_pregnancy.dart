import 'package:fiteva/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'shared_onboarding_widgets.dart';

// ══════════════════════════════════════════════════════════════════════════════
// STEP 8 — StepPregnancy (fond mint + pills Oui/Non)
// ══════════════════════════════════════════════════════════════════════════════
class StepPregnancy extends ConsumerStatefulWidget {
  final VoidCallback onNext;
  final VoidCallback? onBack;
  final void Function(bool isPregnant, int? weekSA) onChanged;

  const StepPregnancy({
    super.key,
    required this.onNext,
    this.onBack,
    required this.onChanged,
  });

  @override
  ConsumerState<StepPregnancy> createState() => _StepPregnancyState();
}

class _StepPregnancyState extends ConsumerState<StepPregnancy> {
  bool? _isPregnant;
  double _week = 12;

  bool get _canContinue => _isPregnant != null;

  int get _trimester {
    if (_week <= 13) return 1;
    if (_week <= 27) return 2;
    return 3;
  }

  String _trimesterLabel(AppL10n l10n) {
    switch (_trimester) {
      case 1: return l10n.oboPregnancyTri1;
      case 2: return l10n.oboPregnancyTri2;
      default: return l10n.oboPregnancyTri3;
    }
  }

  String get _trimesterAdvice {
    switch (_trimester) {
      case 1:
        return 'Privilégie la marche et le yoga prénatal. Évite les abdominaux et les efforts intenses.';
      case 2:
        return 'La natation et le Pilates prénatal sont idéaux. Évite les positions sur le dos après 16 SA.';
      default:
        return 'Privilégie la mobilité douce et la respiration. L\'intensité doit rester très modérée.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = ref.watch(l10nProvider);
    return mintScaffold(
      child: Column(
        children: [
          OnboardingTopBar(step: 8, total: 8, title: 'Grossesse', onBack: widget.onBack),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
              child: Column(
                children: [
                  const StepIcon(Icons.pregnant_woman),
                  const SizedBox(height: 20),
                  const StepHeader(
                    title: 'Grossesse',
                    subtitle: 'On adapte ton programme selon ton état de santé',
                  ),
                  const SizedBox(height: 28),
                  // Oui / Non en pills pleine largeur
                  Row(children: [
                    Expanded(child: _pregnancyPill(false, l10n.oboPregnancyNo,
                        l10n.oboPregnancyNoSub, Icons.do_not_disturb_alt_outlined)),
                    const SizedBox(width: 12),
                    Expanded(child: _pregnancyPill(true, l10n.oboPregnancyYes,
                        l10n.oboPregnancyYesSub, Icons.pregnant_woman)),
                  ]),

                  if (_isPregnant == true) ...[
                    const SizedBox(height: 24),
                    // Semaines
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.55),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.white.withOpacity(0.8)),
                      ),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l10n.oboPregnancyWeek,
                            style: const TextStyle(fontSize: 13,
                                fontWeight: FontWeight.w600, color: kTextMuted)),
                          const SizedBox(height: 10),
                          Row(crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text('${_week.round()}', style: const TextStyle(
                                  fontSize: 40, fontWeight: FontWeight.w800,
                                  color: kGreenDark)),
                              const SizedBox(width: 6),
                              Text(l10n.oboPregnancySA, style: const TextStyle(fontSize: 18,
                                  color: kTextMuted, fontWeight: FontWeight.w500)),
                            ]),
                          SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              activeTrackColor: kGreenDark,
                              inactiveTrackColor: Colors.white.withOpacity(0.5),
                              thumbColor: kGreenDark,
                              overlayColor: kGreenDark.withOpacity(0.15),
                            ),
                            child: Slider(value: _week, min: 1, max: 42,
                                divisions: 41,
                                onChanged: (v) => setState(() => _week = v)),
                          ),
                          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Text('1 SA', style: TextStyle(fontSize: 11, color: kTextMuted)),
                              Text('42 SA', style: TextStyle(fontSize: 11, color: kTextMuted)),
                            ]),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Trimestre pill
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        color: kGreenDark,
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: Text(_trimesterLabel(l10n), textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.w700,
                            fontSize: 13.5, color: Colors.white)),
                    ),
                    const SizedBox(height: 12),
                    // Advice
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.55),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withOpacity(0.8)),
                      ),
                      child: Row(crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.info_outline,
                              color: kGreenDark, size: 18),
                          const SizedBox(width: 10),
                          Expanded(child: Text(_trimesterAdvice,
                            style: const TextStyle(fontSize: 13.5,
                                color: kTextMuted, height: 1.5))),
                        ]),
                    ),
                  ],
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          CtaButton(
            label: l10n.oboPregnancyContinue,
            onPressed: _canContinue ? widget.onNext : null,
          ),
        ],
      ),
    );
  }

  Widget _pregnancyPill(bool value, String label, String sub, IconData icon) {
    final selected = _isPregnant == value;
    return GestureDetector(
      onTap: () => setState(() => _isPregnant = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          color: selected ? kCardSel : Colors.white.withOpacity(0.55),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: selected ? kCardSel : Colors.white.withOpacity(0.8),
            width: 1.5,
          ),
          boxShadow: selected
              ? [BoxShadow(color: kGreenDark.withOpacity(0.25),
                  blurRadius: 16, offset: const Offset(0, 6))]
              : [],
        ),
        child: Column(children: [
          Icon(icon, color: selected ? Colors.white : kGreenMid, size: 30),
          const SizedBox(height: 10),
          Text(label, style: TextStyle(fontWeight: FontWeight.w800,
              fontSize: 16, color: selected ? Colors.white : kTextDark)),
          const SizedBox(height: 4),
          Text(sub, textAlign: TextAlign.center, style: TextStyle(
              fontSize: 11.5,
              color: selected ? Colors.white70 : kTextMuted)),
        ]),
      ),
    );
  }
}