import 'package:fiteva/l10n/app_localizations.dart';
import 'package:fiteva/widgets/custom_date_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'shared_onboarding_widgets.dart';

class StepCycle extends ConsumerStatefulWidget {
  final VoidCallback onNext;
  final VoidCallback? onBack;
  const StepCycle({super.key, required this.onNext, this.onBack});

  @override
  ConsumerState<StepCycle> createState() => _StepCycleState();
}

class _StepCycleState extends ConsumerState<StepCycle> {
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
    HapticFeedback.lightImpact();
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
    final l10n = ref.watch(l10nProvider);
    return mintScaffold(
      child: Column(
        children: [
          OnboardingTopBar(step: 7, total: 7, title: 'Cycle', onBack: widget.onBack),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 4, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const StepHeader(
                    title: 'Ton cycle',
                    subtitle: 'La clé du cycle syncing pour adapter tes entraînements.',
                  ),
                  const SizedBox(height: 28),
                  // Info card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: kGlassFill,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: kGlassBorder, width: 0.5),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40, height: 40,
                          decoration: BoxDecoration(
                            color: kGreenBright.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(LucideIcons.info,
                              size: 18, color: kGreenMid),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(l10n.oboCycleTitle,
                                style: GoogleFonts.outfit(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14, color: kTextDark)),
                              const SizedBox(height: 4),
                              Text(l10n.oboCycleSub,
                                style: GoogleFonts.inter(
                                    fontSize: 12.5, color: kTextMuted,
                                    height: 1.4)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text(l10n.oboCycleDuree,
                    style: GoogleFonts.inter(
                        fontSize: 13, fontWeight: FontWeight.w500,
                        color: kTextMuted, letterSpacing: 0.3)),
                  const SizedBox(height: 14),
                  // Duration pills
                  Wrap(
                    spacing: 8, runSpacing: 8,
                    children: _durations.map((d) {
                      final isSelected = _selectedDuration == d;
                      return _DurationPill(
                        label: d,
                        selected: isSelected,
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() => _selectedDuration = d);
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 28),
                  Text(l10n.oboCycleLastPeriod,
                    style: GoogleFonts.inter(
                        fontSize: 13, fontWeight: FontWeight.w500,
                        color: kTextMuted, letterSpacing: 0.3)),
                  const SizedBox(height: 12),
                  // Date picker button
                  GestureDetector(
                    onTap: _pickDate,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 18),
                      decoration: BoxDecoration(
                        color: kGlassFill,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: kGlassBorder, width: 0.5),
                      ),
                      child: Row(children: [
                        Container(
                          width: 36, height: 36,
                          decoration: BoxDecoration(
                            color: kGreenBright.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(LucideIcons.calendarDays,
                              size: 16, color: kGreenMid),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(_formatDate(_lastPeriodDate),
                            style: GoogleFonts.outfit(
                                fontWeight: FontWeight.w600,
                                fontSize: 16, color: kTextDark)),
                        ),
                        const Icon(LucideIcons.chevronRight,
                            size: 16, color: kTextMuted),
                      ]),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          CtaButton(
            label: l10n.oboCycleCommencer,
            onPressed: widget.onNext,
          ),
        ],
      ),
    );
  }
}

class _DurationPill extends StatefulWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _DurationPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  State<_DurationPill> createState() => _DurationPillState();
}

class _DurationPillState extends State<_DurationPill>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 60),
      reverseDuration: const Duration(milliseconds: 160),
    );
    _scale = Tween(begin: 1.0, end: 0.93).animate(
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
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
          decoration: BoxDecoration(
            color: sel
                ? kGreenDark.withValues(alpha: 0.5)
                : kGlassFill,
            borderRadius: BorderRadius.circular(40),
            border: Border.all(
              color: sel
                  ? kGreenBright.withValues(alpha: 0.5)
                  : kGlassBorder,
              width: sel ? 1.2 : 0.5,
            ),
            boxShadow: sel
                ? [BoxShadow(
                    color: kGreenBright.withValues(alpha: 0.1),
                    blurRadius: 12)]
                : [],
          ),
          child: Text(sel ? '✓  $d' : d, style: GoogleFonts.inter(
            color: sel ? kGreenBright : kTextDark,
            fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
            fontSize: 14,
          )),
        ),
      ),
    );
  }

  String get d => widget.label;
}
