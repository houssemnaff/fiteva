import 'package:fiteva/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'shared_onboarding_widgets.dart';

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

  Color get _trimesterColor {
    switch (_trimester) {
      case 1: return kGreenBright;
      case 2: return const Color(0xFFE8A040);
      default: return const Color(0xFFE87070);
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
              padding: const EdgeInsets.fromLTRB(24, 4, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const StepHeader(
                    title: 'Grossesse',
                    subtitle: 'On adapte ton programme pour ta sécurité.',
                  ),
                  const SizedBox(height: 32),
                  // Yes / No cards
                  Row(children: [
                    Expanded(child: _ChoiceCard(
                      selected: _isPregnant == false,
                      icon: Icons.do_not_disturb_alt_outlined,
                      label: l10n.oboPregnancyNo,
                      sub: l10n.oboPregnancyNoSub,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        setState(() => _isPregnant = false);
                      },
                    )),
                    const SizedBox(width: 12),
                    Expanded(child: _ChoiceCard(
                      selected: _isPregnant == true,
                      icon: Icons.pregnant_woman,
                      label: l10n.oboPregnancyYes,
                      sub: l10n.oboPregnancyYesSub,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        setState(() => _isPregnant = true);
                      },
                    )),
                  ]),

                  if (_isPregnant == true) ...[
                    const SizedBox(height: 28),
                    // Week slider card
                    Container(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: kGlassFill,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: kGlassBorder, width: 0.5),
                      ),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l10n.oboPregnancyWeek,
                            style: GoogleFonts.inter(fontSize: 13,
                                fontWeight: FontWeight.w500, color: kTextMuted)),
                          const SizedBox(height: 12),
                          Row(crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text('${_week.round()}', style: GoogleFonts.outfit(
                                  fontSize: 48, fontWeight: FontWeight.w800,
                                  color: kTextDark, letterSpacing: -2)),
                              const SizedBox(width: 6),
                              Text(l10n.oboPregnancySA, style: GoogleFonts.inter(
                                  fontSize: 18, color: kTextMuted,
                                  fontWeight: FontWeight.w400)),
                            ]),
                          const SizedBox(height: 8),
                          SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              activeTrackColor: _trimesterColor,
                              inactiveTrackColor: kWhite.withValues(alpha: 0.06),
                              thumbColor: kTextDark,
                              overlayColor: _trimesterColor.withValues(alpha: 0.12),
                              trackHeight: 4,
                              thumbShape: const RoundSliderThumbShape(
                                  enabledThumbRadius: 8),
                            ),
                            child: Slider(value: _week, min: 1, max: 42,
                                divisions: 41,
                                onChanged: (v) {
                                  HapticFeedback.selectionClick();
                                  setState(() => _week = v);
                                }),
                          ),
                          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('1 SA', style: GoogleFonts.inter(
                                  fontSize: 11, color: kTextMuted)),
                              Text('42 SA', style: GoogleFonts.inter(
                                  fontSize: 11, color: kTextMuted)),
                            ]),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    // Trimester badge
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 13),
                      decoration: BoxDecoration(
                        color: _trimesterColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: _trimesterColor.withValues(alpha: 0.25),
                          width: 0.5),
                      ),
                      child: Text(_trimesterLabel(l10n),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.outfit(
                            fontWeight: FontWeight.w700, fontSize: 14,
                            color: _trimesterColor)),
                    ),
                    const SizedBox(height: 14),
                    // Advice card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: kGlassFill,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: kGlassBorder, width: 0.5),
                      ),
                      child: Row(crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 32, height: 32,
                            decoration: BoxDecoration(
                              color: kGreenBright.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.tips_and_updates_outlined,
                                color: kGreenMid, size: 16),
                          ),
                          const SizedBox(width: 12),
                          Expanded(child: Text(_trimesterAdvice,
                            style: GoogleFonts.inter(fontSize: 13.5,
                                color: kTextMuted, height: 1.55))),
                        ]),
                    ),
                  ],
                  const SizedBox(height: 24),
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
}

class _ChoiceCard extends StatefulWidget {
  final bool selected;
  final IconData icon;
  final String label;
  final String sub;
  final VoidCallback onTap;

  const _ChoiceCard({
    required this.selected,
    required this.icon,
    required this.label,
    required this.sub,
    required this.onTap,
  });

  @override
  State<_ChoiceCard> createState() => _ChoiceCardState();
}

class _ChoiceCardState extends State<_ChoiceCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 80),
      reverseDuration: const Duration(milliseconds: 200),
    );
    _scale = Tween(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sel = widget.selected;
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) { _ctrl.reverse(); widget.onTap(); },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
          decoration: BoxDecoration(
            color: sel ? kGreenDark.withValues(alpha: 0.35) : kGlassFill,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: sel ? kGreenBright.withValues(alpha: 0.5) : kGlassBorder,
              width: sel ? 1.2 : 0.5,
            ),
            boxShadow: sel
                ? [BoxShadow(
                    color: kGreenBright.withValues(alpha: 0.08),
                    blurRadius: 20, offset: const Offset(0, 6))]
                : [],
          ),
          child: Column(children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 48, height: 48,
              decoration: BoxDecoration(
                color: sel
                    ? kGreenBright.withValues(alpha: 0.12)
                    : kWhite.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(widget.icon,
                  color: sel ? kGreenBright : kTextMuted, size: 24),
            ),
            const SizedBox(height: 14),
            Text(widget.label, style: GoogleFonts.outfit(
                fontWeight: FontWeight.w700, fontSize: 17,
                color: sel ? kWhite : kTextDark)),
            const SizedBox(height: 4),
            Text(widget.sub, textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 12,
                  color: sel ? kGreenMid : kTextMuted)),
            const SizedBox(height: 12),
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 22, height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: sel ? kGreenBright : Colors.transparent,
                border: Border.all(
                  color: sel ? kGreenBright : kWhite.withValues(alpha: 0.15),
                  width: sel ? 0 : 1.5),
              ),
              child: sel
                  ? const Icon(Icons.check_rounded, size: 13, color: kBgDark)
                  : null,
            ),
          ]),
        ),
      ),
    );
  }
}
