import 'dart:math';

import 'package:fiteva/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:fiteva/services/tick_sound_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'shared_onboarding_widgets.dart';

class StepHealthProfile extends ConsumerStatefulWidget {
  final VoidCallback onNext;
  final VoidCallback? onBack;
  final int initialHeightCm;
  final double initialWeightKg;
  final int initialAge;
  final ValueChanged<int> onHeightChanged;
  final ValueChanged<double> onWeightChanged;
  final ValueChanged<int> onAgeChanged;

  const StepHealthProfile({
    super.key,
    required this.onNext,
    this.onBack,
    this.initialHeightCm = 165,
    this.initialWeightKg = 60.0,
    this.initialAge = 25,
    required this.onHeightChanged,
    required this.onWeightChanged,
    required this.onAgeChanged,
  });

  @override
  ConsumerState<StepHealthProfile> createState() => _StepHealthProfileState();
}

class _StepHealthProfileState extends ConsumerState<StepHealthProfile> {
  static const int _minH = 140, _maxH = 210;
  static const int _minA = 14, _maxA = 70;
  static final List<double> _wList =
      List.generate(231, (i) => 35.0 + i * 0.5);

  late final FixedExtentScrollController _hCtrl;
  late final FixedExtentScrollController _wCtrl;
  late final FixedExtentScrollController _aCtrl;

  late int _hIdx;
  late int _wIdx;
  late int _aIdx;

  int get _heightCm => _minH + _hIdx;
  double get _weightKg => _wList[_wIdx];
  int get _age => _minA + _aIdx;

  double get _bmi => _weightKg / pow(_heightCm / 100, 2);

  String get _bmiLabel {
    if (_bmi < 18.5) return 'Insuffisant';
    if (_bmi < 25.0) return 'Normal';
    if (_bmi < 30.0) return 'Surpoids';
    return 'Obésité';
  }

  Color get _bmiColor {
    if (_bmi < 18.5) return const Color(0xFF5B9BD9);
    if (_bmi < 25.0) return kGreenMid;
    if (_bmi < 30.0) return const Color(0xFFE8A040);
    return const Color(0xFFD94A4A);
  }

  @override
  void initState() {
    super.initState();
    _hIdx = (widget.initialHeightCm - _minH).clamp(0, _maxH - _minH);
    final wNearest = _wList.indexWhere((w) => w >= widget.initialWeightKg);
    _wIdx = wNearest < 0 ? 50 : wNearest;
    _aIdx = (widget.initialAge - _minA).clamp(0, _maxA - _minA);

    _hCtrl = FixedExtentScrollController(initialItem: _hIdx);
    _wCtrl = FixedExtentScrollController(initialItem: _wIdx);
    _aCtrl = FixedExtentScrollController(initialItem: _aIdx);

    TickSoundService.instance.init();
  }

  @override
  void dispose() {
    _hCtrl.dispose();
    _wCtrl.dispose();
    _aCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = ref.watch(l10nProvider);
    return mintScaffold(
      child: Column(
        children: [
          OnboardingTopBar(step: 6, total: 7, onBack: widget.onBack),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: ConstrainedBox(
                    constraints:
                        BoxConstraints(minHeight: constraints.maxHeight),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 8),
                        const StepIcon(Icons.straighten_rounded),
                        const SizedBox(height: 16),
                        const StepHeader(
                          title: 'Profil santé',
                          subtitle:
                              'Taille & poids pour personnaliser ton plan',
                        ),
                        const SizedBox(height: 28),
                        Row(
                          children: [
                            Expanded(
                              child: _DrumPicker(
                                label: l10n.oboHealthHeight,
                                unit: 'cm',
                                selectedIndex: _hIdx,
                                controller: _hCtrl,
                                itemCount: _maxH - _minH + 1,
                                labelFor: (i) => '${_minH + i}',
                                onChanged: (i) {
                                  setState(() => _hIdx = i);
                                  widget.onHeightChanged(_heightCm);
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _DrumPicker(
                                label: l10n.oboHealthWeight,
                                unit: 'kg',
                                selectedIndex: _wIdx,
                                controller: _wCtrl,
                                itemCount: _wList.length,
                                labelFor: (i) {
                                  final w = _wList[i];
                                  return w % 1 == 0
                                      ? '${w.toInt()}'
                                      : w.toStringAsFixed(1);
                                },
                                onChanged: (i) {
                                  setState(() => _wIdx = i);
                                  widget.onWeightChanged(_weightKg);
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _DrumPicker(
                                label: 'ÂGE',
                                unit: 'ans',
                                selectedIndex: _aIdx,
                                controller: _aCtrl,
                                itemCount: _maxA - _minA + 1,
                                labelFor: (i) => '${_minA + i}',
                                onChanged: (i) {
                                  setState(() => _aIdx = i);
                                  widget.onAgeChanged(_age);
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        _BmiCard(
                            bmi: _bmi,
                            label: _bmiLabel,
                            color: _bmiColor),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          CtaButton(
            label: l10n.oboHealthContinue,
            onPressed: widget.onNext,
          ),
        ],
      ),
    );
  }
}

class _DrumPicker extends StatelessWidget {
  final String label;
  final String unit;
  final int selectedIndex;
  final FixedExtentScrollController controller;
  final int itemCount;
  final String Function(int) labelFor;
  final ValueChanged<int> onChanged;

  const _DrumPicker({
    required this.label,
    required this.unit,
    required this.selectedIndex,
    required this.controller,
    required this.itemCount,
    required this.labelFor,
    required this.onChanged,
  });

  static const double _kItemH = 52.0;
  static const int _kVisible = 5;
  static const Color _kBg = Color(0xFF0F1A14);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kGlassFill,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: kGlassBorder, width: 0.5),
      ),
      child: Column(
        children: [
          const SizedBox(height: 16),
          Text(label,
              style: GoogleFonts.inter(
                fontSize: 10,
                letterSpacing: 2.2,
                fontWeight: FontWeight.w700,
                color: kTextMuted,
              )),
          const SizedBox(height: 10),
          SizedBox(
            height: _kItemH * _kVisible,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Center(
                  child: Container(
                    height: _kItemH,
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: kGreenDark.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: kGreenMid.withValues(alpha: 0.3), width: 1),
                    ),
                  ),
                ),
                ListWheelScrollView.useDelegate(
                  controller: controller,
                  itemExtent: _kItemH,
                  perspective: 0.002,
                  diameterRatio: 1.8,
                  squeeze: 1.1,
                  physics: const FixedExtentScrollPhysics(),
                  onSelectedItemChanged: (i) {
                    HapticFeedback.selectionClick();
                    TickSoundService.instance.tick();
                    onChanged(i);
                  },
                  childDelegate: ListWheelChildBuilderDelegate(
                    childCount: itemCount,
                    builder: (_, i) {
                      final sel = i == selectedIndex;
                      return Center(
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 180),
                          style: GoogleFonts.outfit(
                            fontSize: sel ? 24 : 16,
                            fontWeight:
                                sel ? FontWeight.w800 : FontWeight.w400,
                            color: sel ? kGreenBright : kTextMuted,
                          ),
                          child: Text(labelFor(i)),
                        ),
                      );
                    },
                  ),
                ),
                Positioned(
                  top: 0, left: 0, right: 0,
                  height: _kItemH * 1.6,
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [_kBg, _kBg.withValues(alpha: 0)],
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0, left: 0, right: 0,
                  height: _kItemH * 1.6,
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [_kBg, _kBg.withValues(alpha: 0)],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(unit,
              style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: kTextMuted)),
          const SizedBox(height: 14),
        ],
      ),
    );
  }
}

class _BmiCard extends StatelessWidget {
  final double bmi;
  final String label;
  final Color color;

  const _BmiCard({required this.bmi, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
      decoration: BoxDecoration(
        color: kGlassFill,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: kGlassBorder, width: 0.5),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('IMC',
                  style: GoogleFonts.inter(
                      fontSize: 10,
                      letterSpacing: 2,
                      fontWeight: FontWeight.w700,
                      color: kTextMuted)),
              const SizedBox(height: 4),
              Text(bmi.toStringAsFixed(1),
                  style: GoogleFonts.outfit(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: kTextDark)),
            ],
          ),
          const Spacer(),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Text(label,
                style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: color)),
          ),
        ],
      ),
    );
  }
}
