import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'shared_onboarding_widgets.dart';

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
          OnboardingTopBar(step: 5, total: 7, onBack: onBack),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 4, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const StepHeader(
                    title: 'Ta fréquence',
                    subtitle: 'Combien de jours par semaine tu veux t\'entraîner.',
                  ),
                  const SizedBox(height: 36),
                  ...options.map((item) {
                    final isSel = selectedFrequency == item.label;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _FreqCard(
                        item: item,
                        selected: isSel,
                        onTap: () => onChanged(item.label),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
          CtaButton(
            label: 'Continuer',
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

class _FreqCard extends StatefulWidget {
  final _FreqItem item;
  final bool selected;
  final VoidCallback onTap;

  const _FreqCard({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  @override
  State<_FreqCard> createState() => _FreqCardState();
}

class _FreqCardState extends State<_FreqCard>
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
    _scale = Tween(begin: 1.0, end: 0.97).animate(
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
    final days = widget.item.days;

    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        HapticFeedback.lightImpact();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: sel ? kGreenDark.withValues(alpha: 0.35) : kGlassFill,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: sel ? kGreenBright.withValues(alpha: 0.5) : kGlassBorder,
              width: sel ? 1.2 : 0.5,
            ),
            boxShadow: sel
                ? [BoxShadow(
                    color: kGreenBright.withValues(alpha: 0.08),
                    blurRadius: 24, offset: const Offset(0, 8))]
                : [],
          ),
          child: Row(children: [
            // Week dots — 7 days, filled = training day
            Row(children: List.generate(7, (idx) {
              final active = idx < days;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(right: 4),
                width: 10, height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: active
                      ? (sel ? kGreenBright : kGreenMid.withValues(alpha: 0.7))
                      : kWhite.withValues(alpha: 0.06),
                  border: active ? null : Border.all(
                    color: kWhite.withValues(alpha: 0.08), width: 0.5),
                ),
              );
            })),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                '${widget.item.label} / semaine',
                style: GoogleFonts.inter(
                  fontSize: 15, fontWeight: FontWeight.w600,
                  color: sel ? kWhite : kTextDark),
              ),
            ),
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
