// ─────────────────────────────────────────────
// symptom_insight_engine.dart
// ─────────────────────────────────────────────

import 'symptom_entry.dart';

enum InsightSeverity { reassuring, informational, watchful }

class SymptomInsight {
  final String text;
  final String tag;
  final InsightSeverity severity;

  const SymptomInsight({
    required this.text,
    required this.tag,
    required this.severity,
  });
}

class SymptomInsightEngine {
  SymptomInsightEngine._();

  static SymptomInsight generate({
    required int week,
    required List<SymptomEntry> symptoms,
  }) {
    if (symptoms.isEmpty) {
      return const SymptomInsight(
        text:
            'No symptoms logged this week — your body seems to be having '
            'a quiet moment. Rest, stay hydrated, and enjoy the stillness.',
        tag: 'Stable Week',
        severity: InsightSeverity.reassuring,
      );
    }

    final String trimester = _trimester(week);
    final Map<SymptomType, List<SymptomEntry>> grouped = _group(symptoms);
    final List<SymptomType> spiking = _spikes(grouped);
    final double avgIntensity = _avgIntensity(symptoms);
    final int distinctCount = grouped.keys.length;

    // ── High-intensity multi-symptom cluster ─────────────────────────────────
    if (spiking.length >= 3 && avgIntensity >= 3.5) {
      return SymptomInsight(
        text:
            'You\'re experiencing several symptoms at higher intensity this '
            'week. This level of discomfort during $trimester is not uncommon, '
            'but do mention it to your midwife or OB at your next visit — '
            'they can offer personalised support.',
        tag: 'Check In',
        severity: InsightSeverity.watchful,
      );
    }

    // ── Fatigue spike ─────────────────────────────────────────────────────────
    if (_isSpiking(grouped, SymptomType.fatigue)) {
      if (week <= 13) {
        return const SymptomInsight(
          text:
              'Fatigue this intense in the first trimester is very common. '
              'Progesterone is working hard building your baby\'s foundation. '
              'Your body is asking you to rest — please listen.',
          tag: 'Normal for Trimester 1',
          severity: InsightSeverity.reassuring,
        );
      } else if (week <= 27) {
        return const SymptomInsight(
          text:
              'Second-trimester fatigue can return when your baby has a '
              'growth spurt. Extra iron-rich foods and short daytime rests '
              'can make a meaningful difference.',
          tag: 'Growth Phase',
          severity: InsightSeverity.informational,
        );
      } else {
        return const SymptomInsight(
          text:
              'Deep fatigue in the third trimester is your body conserving '
              'energy for birth. Short walks and gentle movement often help '
              'more than complete rest — listen to your own rhythm.',
          tag: 'Third Trimester',
          severity: InsightSeverity.reassuring,
        );
      }
    }

    // ── Nausea spike ──────────────────────────────────────────────────────────
    if (_isSpiking(grouped, SymptomType.nausea)) {
      if (week <= 16) {
        return const SymptomInsight(
          text:
              'Nausea peaks for most people between weeks 6 and 12, though '
              'it can persist a little longer. Small, frequent meals and '
              'ginger in any form are your allies right now.',
          tag: 'Common in Trimester 1',
          severity: InsightSeverity.reassuring,
        );
      } else {
        return const SymptomInsight(
          text:
              'Nausea returning after the first trimester can be linked '
              'to iron supplements, reflux, or your growing baby pressing '
              'on the stomach. Try smaller meals and mention it at your '
              'next visit.',
          tag: 'Worth Noting',
          severity: InsightSeverity.informational,
        );
      }
    }

    // ── Headache spike ────────────────────────────────────────────────────────
    if (_isSpiking(grouped, SymptomType.headache)) {
      return SymptomInsight(
        text:
            'Headaches during $trimester are often linked to dehydration, '
            'blood pressure shifts, or reduced caffeine. Aim for 2–3 litres '
            'of water daily and rest in a cool, dark room when one hits. '
            'If they are severe or persistent, contact your provider.',
        tag: week > 20 ? 'Monitor' : 'Common',
        severity:
            week > 20 ? InsightSeverity.watchful : InsightSeverity.informational,
      );
    }

    // ── Cramps spike ──────────────────────────────────────────────────────────
    if (_isSpiking(grouped, SymptomType.cramps)) {
      if (week > 36) {
        return const SymptomInsight(
          text:
              'Cramping and tightening in the final weeks can be Braxton '
              'Hicks or early signs of labour. Time them — if they are '
              'regular, intensifying, and less than 10 minutes apart, '
              'contact your care team.',
          tag: 'Monitor Closely',
          severity: InsightSeverity.watchful,
        );
      }
      return SymptomInsight(
        text:
            'Mild cramping during $trimester is usually the uterus '
            'stretching to accommodate your growing baby. Rest, warmth, '
            'and gentle movement often help. Any sharp or prolonged pain '
            'warrants a call to your midwife.',
        tag: 'Usually Normal',
        severity: InsightSeverity.informational,
      );
    }

    // ── Swelling spike (late pregnancy watch) ────────────────────────────────
    if (_isSpiking(grouped, SymptomType.swelling) && week > 28) {
      return const SymptomInsight(
        text:
            'Some swelling in the feet and ankles in the third trimester '
            'is very common. Elevate your feet when resting and stay '
            'hydrated. Sudden or significant swelling in the face or hands '
            'should be mentioned to your provider promptly.',
        tag: 'Keep an Eye On',
        severity: InsightSeverity.watchful,
      );
    }

    // ── Breathlessness spike ─────────────────────────────────────────────────
    if (_isSpiking(grouped, SymptomType.breathlessness) && week > 28) {
      return const SymptomInsight(
        text:
            'Shortness of breath in the third trimester is common as your '
            'uterus presses on the diaphragm. Sitting upright and sleeping '
            'propped up can help. Sudden severe breathlessness should be '
            'assessed immediately.',
        tag: 'Third Trimester Normal',
        severity: InsightSeverity.informational,
      );
    }

    // ── Mood fluctuations ─────────────────────────────────────────────────────
    if (_isSpiking(grouped, SymptomType.mood)) {
      return const SymptomInsight(
        text:
            'Emotional waves are a natural part of pregnancy. Hormones, '
            'sleep shifts, and the enormity of becoming a parent all '
            'contribute. Being kind to yourself today is not a luxury — '
            'it\'s essential care.',
        tag: 'You\'re Doing Well',
        severity: InsightSeverity.reassuring,
      );
    }

    // ── Multiple moderate symptoms (general hormonal variation) ──────────────
    if (distinctCount >= 3 && avgIntensity >= 2) {
      return SymptomInsight(
        text:
            'You\'re navigating a cluster of symptoms this week — a very '
            'common hormonal variation during $trimester. Your body is '
            'doing extraordinary work. Keep logging so you can spot '
            'patterns over time.',
        tag: 'Hormonal Variation',
        severity: InsightSeverity.informational,
      );
    }

    // ── Sleep disruption ──────────────────────────────────────────────────────
    if (_isSpiking(grouped, SymptomType.sleep)) {
      return const SymptomInsight(
        text:
            'Sleep disturbances are among the most common pregnancy '
            'complaints at every stage. A pregnancy pillow, a consistent '
            'bedtime routine, and limiting screens after 9 pm can '
            'meaningfully improve sleep quality.',
        tag: 'Rest Matters',
        severity: InsightSeverity.informational,
      );
    }

    // ── Low-intensity baseline ────────────────────────────────────────────────
    return SymptomInsight(
      text:
          'Your symptoms this week are mild and consistent with what\'s '
          'expected during $trimester. Keep listening to your body, '
          'stay nourished and hydrated, and reach out to your provider '
          'whenever you feel uncertain — that\'s always the right call.',
      tag: 'Stable Pattern',
      severity: InsightSeverity.reassuring,
    );
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────

  static String _trimester(int week) {
    if (week <= 13) return 'the first trimester';
    if (week <= 27) return 'the second trimester';
    return 'the third trimester';
  }

  static Map<SymptomType, List<SymptomEntry>> _group(
      List<SymptomEntry> symptoms) {
    final Map<SymptomType, List<SymptomEntry>> map = {};
    for (final e in symptoms) {
      map.putIfAbsent(e.type, () => []).add(e);
    }
    return map;
  }

  static List<SymptomType> _spikes(
      Map<SymptomType, List<SymptomEntry>> grouped) {
    return grouped.entries
        .where((entry) => _avgForGroup(entry.value) >= 3.0)
        .map((e) => e.key)
        .toList();
  }

  static bool _isSpiking(
      Map<SymptomType, List<SymptomEntry>> grouped, SymptomType type) {
    final entries = grouped[type];
    if (entries == null || entries.isEmpty) return false;
    return _avgForGroup(entries) >= 3.0;
  }

  static double _avgForGroup(List<SymptomEntry> entries) {
    if (entries.isEmpty) return 0;
    return entries.fold(0.0, (sum, e) => sum + e.intensity) / entries.length;
  }

  static double _avgIntensity(List<SymptomEntry> symptoms) {
    if (symptoms.isEmpty) return 0;
    return symptoms.fold(0.0, (sum, e) => sum + e.intensity) / symptoms.length;
  }
}