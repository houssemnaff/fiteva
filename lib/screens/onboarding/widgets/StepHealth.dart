import 'dart:math';

import 'package:flutter/material.dart';
import 'shared_onboarding_widgets.dart';

// ══════════════════════════════════════════════════════════════════════════════
// STEP 6 — StepHealthProfile (fond mint, sliders conservés)
// ══════════════════════════════════════════════════════════════════════════════
class StepHealthProfile extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback? onBack;
  const StepHealthProfile({super.key, required this.onNext, this.onBack});

  @override
  State<StepHealthProfile> createState() => _StepHealthProfileState();
}

class _StepHealthProfileState extends State<StepHealthProfile> {
  double _heightCm = 165;
  double _weightKg = 60;

  bool get canContinue =>
      _heightCm >= 140 && _heightCm <= 210 &&
      _weightKg >= 35 && _weightKg <= 150;

  double get _bmi => _weightKg / pow(_heightCm / 100, 2);

  @override
  Widget build(BuildContext context) {
    return mintScaffold(
      child: Column(
        children: [
          OnboardingTopBar(step: 6, total: 7, title: 'Profil santé', onBack: widget.onBack),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
              child: Column(
                children: [
                  const StepIcon(Icons.monitor_weight_outlined),
                  const SizedBox(height: 20),
                  const StepHeader(
                    title: 'Profil santé',
                    subtitle: 'Taille & poids pour personnaliser ton plan',
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 310,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(child: _avatarPanel()),
                        const SizedBox(width: 16),
                        SizedBox(width: 84, child: _heightPanel()),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _weightPanel(),
                  const SizedBox(height: 16),
                  // IMC pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.55),
                      borderRadius: BorderRadius.circular(40),
                      border: Border.all(color: Colors.white.withOpacity(0.8)),
                    ),
                    child: Text('IMC : ${_bmi.toStringAsFixed(1)}',
                      style: const TextStyle(fontSize: 13,
                          fontWeight: FontWeight.w600, color: kTextDark)),
                  ),
                ],
              ),
            ),
          ),
          CtaButton(
            label: 'Continuer',
            onPressed: canContinue ? widget.onNext : null,
          ),
        ],
      ),
    );
  }

  Widget _avatarPanel() {
    return Center(
      child: Image.asset(
        _weightKg < 55 ? 'assets/images/slim1.png'
            : _weightKg < 75 ? 'assets/images/average1.png'
            : 'assets/images/chubby1.png',
        fit: BoxFit.contain, width: 190, height: 250,
        errorBuilder: (_, __, ___) =>
            const Icon(Icons.person, size: 90, color: kGreenDark),
      ),
    );
  }

  Widget _heightPanel() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.55),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.8)),
      ),
      child: Column(children: [
        const Text('Height', style: TextStyle(fontSize: 12,
            fontWeight: FontWeight.w600, color: kTextMuted)),
        const SizedBox(height: 8),
        Text('${_heightCm.round()} cm', style: const TextStyle(
            fontSize: 14, fontWeight: FontWeight.w700, color: kTextDark)),
        const SizedBox(height: 6),
        Expanded(child: RotatedBox(quarterTurns: 3,
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: kGreenDark,
              inactiveTrackColor: Colors.white.withOpacity(0.5),
              thumbColor: kGreenDark,
              overlayColor: kGreenDark.withOpacity(0.15),
            ),
            child: Slider(value: _heightCm, min: 140, max: 210,
                onChanged: (v) => setState(() => _heightCm = v)),
          ),
        )),
      ]),
    );
  }

  Widget _weightPanel() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.55),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.8)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Weight', style: TextStyle(fontSize: 13,
            color: kTextMuted, fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        Text('${_weightKg.round()} kg', style: const TextStyle(
            fontSize: 22, fontWeight: FontWeight.w700, color: kTextDark)),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: kGreenDark,
            inactiveTrackColor: Colors.white.withOpacity(0.5),
            thumbColor: kGreenDark,
            overlayColor: kGreenDark.withOpacity(0.15),
          ),
          child: Slider(value: _weightKg, min: 35, max: 150,
              onChanged: (v) => setState(() => _weightKg = v)),
        ),
      ]),
    );
  }
}
