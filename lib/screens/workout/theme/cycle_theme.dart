import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ── Cycle phase definitions ───────────────────────────────────────────────────
enum CyclePhase { menstruation, follicular, ovulation, luteal }

extension CyclePhaseX on CyclePhase {
  String get label {
    switch (this) {
      case CyclePhase.menstruation: return 'Règles';
      case CyclePhase.follicular:   return 'Follic.';
      case CyclePhase.ovulation:    return 'Ovul.';
      case CyclePhase.luteal:       return 'Lutéale';
    }
  }

  // Palette harmonisée (moins saturée, même famille tonale) — les 4 couleurs
  // précédentes (rouge/orange/vert vif/violet) créaient un effet "arc-en-ciel"
  // trop criard sur les cartes de programme.
  Color get color {
    switch (this) {
      case CyclePhase.menstruation: return const Color(0xFFC97B84);
      case CyclePhase.follicular:   return const Color(0xFFB8860B);
      case CyclePhase.ovulation:    return const Color(0xFF5A8A6E);
      case CyclePhase.luteal:       return const Color(0xFF8E7BA6);
    }
  }
}

// ── Parser ────────────────────────────────────────────────────────────────────
List<CyclePhase> parseCyclePhases(String phases) {
  if (phases.isEmpty) return [];
  final s = phases.toLowerCase();

  if (s.contains('toutes') || s.contains('all')) {
    return CyclePhase.values;
  }

  final result = <CyclePhase>[];
  if (s.contains('règl') || s.contains('regl') || s.contains('mens')) {
    result.add(CyclePhase.menstruation);
  }
  if (s.contains('foll')) result.add(CyclePhase.follicular);
  if (s.contains('ovul'))  result.add(CyclePhase.ovulation);
  if (s.contains('lut'))   result.add(CyclePhase.luteal);
  return result;
}

// ── Badge row widget ──────────────────────────────────────────────────────────
class CycleBadgeRow extends StatelessWidget {
  final String phases;
  const CycleBadgeRow({super.key, required this.phases});

  @override
  Widget build(BuildContext context) {
    final list = parseCyclePhases(phases);
    if (list.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: list.map((p) => _CycleBadge(phase: p)).toList(),
    );
  }
}

class _CycleBadge extends StatelessWidget {
  final CyclePhase phase;
  const _CycleBadge({required this.phase});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: phase.color.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: phase.color.withValues(alpha: 0.45)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: phase.color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 5),
            Text(
              phase.label,
              style: GoogleFonts.inter(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: phase.color,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      );
}
