import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'shared_onboarding_widgets.dart';

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
      _Level('Débutant', 'Moins de 6 mois d\'entraînement',
          Icons.eco_outlined, 1),
      _Level('Intermédiaire', '6 mois à 2 ans d\'expérience',
          Icons.local_fire_department, 2),
      _Level('Avancé', 'Plus de 2 ans d\'entraînement régulier',
          Icons.flash_on, 3),
    ];

    return mintScaffold(
      child: Column(
        children: [
          OnboardingTopBar(step: 3, total: 7, onBack: onBack),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 4, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const StepHeader(
                    title: 'Ton niveau',
                    subtitle: 'On adapte l\'intensité à ton expérience.',
                  ),
                  const SizedBox(height: 36),
                  ...levels.map((lvl) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: _LevelCard(
                      level: lvl,
                      selected: selectedLevel == lvl.label,
                      onTap: () => onChanged(lvl.label),
                    ),
                  )),
                ],
              ),
            ),
          ),
          CtaButton(
            label: 'Continuer',
            onPressed: selectedLevel != null ? onNext : null,
          ),
        ],
      ),
    );
  }
}

class _Level {
  final String label, sub;
  final IconData icon;
  final int intensity;
  _Level(this.label, this.sub, this.icon, this.intensity);
}

class _LevelCard extends StatefulWidget {
  final _Level level;
  final bool selected;
  final VoidCallback onTap;

  const _LevelCard({
    required this.level,
    required this.selected,
    required this.onTap,
  });

  @override
  State<_LevelCard> createState() => _LevelCardState();
}

class _LevelCardState extends State<_LevelCard>
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
    final lvl = widget.level;

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
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: sel ? kGreenDark.withValues(alpha: 0.35) : kGlassFill,
            borderRadius: BorderRadius.circular(20),
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
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 48, height: 48,
              decoration: BoxDecoration(
                color: sel
                    ? kGreenBright.withValues(alpha: 0.12)
                    : kWhite.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(14)),
              child: Icon(lvl.icon,
                color: sel ? kGreenBright : kTextMuted, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(lvl.label, style: GoogleFonts.outfit(
                  fontSize: 17, fontWeight: FontWeight.w700,
                  color: sel ? kWhite : kTextDark)),
                const SizedBox(height: 4),
                Text(lvl.sub, style: GoogleFonts.inter(
                  fontSize: 13, color: sel ? kGreenMid : kTextMuted,
                  fontWeight: FontWeight.w400)),
                const SizedBox(height: 10),
                // Intensity meter
                Row(children: List.generate(3, (i) {
                  final active = i < lvl.intensity;
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: i < 2 ? 4 : 0),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        height: 3,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2),
                          color: active
                              ? (sel ? kGreenBright : kGreenMid)
                              : kWhite.withValues(alpha: 0.06),
                        ),
                      ),
                    ),
                  );
                })),
              ],
            )),
            const SizedBox(width: 12),
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 24, height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: sel ? kGreenBright : Colors.transparent,
                border: Border.all(
                  color: sel ? kGreenBright : kWhite.withValues(alpha: 0.15),
                  width: sel ? 0 : 1.5),
              ),
              child: sel
                  ? const Icon(Icons.check_rounded, size: 14, color: kBgDark)
                  : null,
            ),
          ]),
        ),
      ),
    );
  }
}
