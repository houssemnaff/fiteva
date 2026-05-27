import 'package:flutter/material.dart';

// ═══════════════════════════════════════════════════════════════
// MODELS
// ═══════════════════════════════════════════════════════════════

enum CyclePhase { menstruation, folliculaire, ovulation, luteale }

extension CyclePhaseExt on CyclePhase {
  String get label => switch (this) {
        CyclePhase.menstruation => 'Menstruation',
        CyclePhase.folliculaire => 'Folliculaire',
        CyclePhase.ovulation => 'Ovulation',
        CyclePhase.luteale => 'Lutéale',
      };

  String get days => switch (this) {
        CyclePhase.menstruation => 'J1–J5',
        CyclePhase.folliculaire => 'J6–J13',
        CyclePhase.ovulation => 'J14–J16',
        CyclePhase.luteale => 'J17–J28',
      };

  String get emoji => switch (this) {
        CyclePhase.menstruation => '🔴',
        CyclePhase.folliculaire => '🌱',
        CyclePhase.ovulation => '✨',
        CyclePhase.luteale => '🌙',
      };

  Color get color => switch (this) {
        CyclePhase.menstruation => const Color(0xFFB22B4A),
        CyclePhase.folliculaire => const Color(0xFF185FA5),
        CyclePhase.ovulation => const Color(0xFF0F6E56),
        CyclePhase.luteale => const Color(0xFF9B5E0A),
      };

  Color get bg => switch (this) {
        CyclePhase.menstruation => const Color(0xFFFBE8EE),
        CyclePhase.folliculaire => const Color(0xFFE6F1FB),
        CyclePhase.ovulation => const Color(0xFFE1F5EE),
        CyclePhase.luteale => const Color(0xFFFAEEDA),
      };

  String get tip => switch (this) {
        CyclePhase.menstruation =>
          'Privilégier les aliments riches en fer pour compenser les pertes sanguines.',
        CyclePhase.folliculaire =>
          'Phase idéale pour augmenter l\'intensité de l\'entraînement et les protéines.',
        CyclePhase.ovulation =>
          'Énergie au maximum : profiter pour les efforts physiques intenses.',
        CyclePhase.luteale =>
          'Magnésium et B6 réduisent les symptômes du SPM et les fringales.',
      };

  List<String> get recommend => switch (this) {
        CyclePhase.menstruation => [
            'Fer (lentilles, épinards)',
            'Vitamine C',
            'Gingembre anti-douleur',
            'Chocolat noir 70%',
          ],
        CyclePhase.folliculaire => [
            'Graines de lin',
            'Légumes crucifères',
            'Protéines maigres',
            'Oméga-3',
          ],
        CyclePhase.ovulation => [
            'Antioxydants (baies, brocoli)',
            'Fibres',
            'Zinc (graines de citrouille)',
            'Eau ++',
          ],
        CyclePhase.luteale => [
            'Magnésium (amandes, banane)',
            'Vitamine B6',
            'Calcium',
            'Complexes glucides',
          ],
      };

  List<String> get avoid => switch (this) {
        CyclePhase.menstruation => [
            'Alcool',
            'Sel en excès',
            'Caféine',
            'Sucres raffinés',
          ],
        CyclePhase.folliculaire => ['Alcool', 'Aliments transformés'],
        CyclePhase.ovulation => [
            'Excès de caféine',
            'Aliments inflammatoires',
          ],
        CyclePhase.luteale => ['Sel', 'Caféine', 'Alcool', 'Sucre raffiné'],
      };
}

class ExpertAdvice {
  final String name;
  final String role;
  final String initials;
  final Color color;
  final Color bg;
  final String title;
  final String body;
  final String tag;
  const ExpertAdvice({
    required this.name,
    required this.role,
    required this.initials,
    required this.color,
    required this.bg,
    required this.title,
    required this.body,
    required this.tag,
  });
}

class HealthAlert {
  final AlertType type;
  final IconData icon;
  final String text;
  const HealthAlert({required this.type, required this.icon, required this.text});
}

enum AlertType { danger, warning, info }

extension AlertTypeExt on AlertType {
  Color get bg => switch (this) {
        AlertType.danger => const Color(0xFFFCEBEB),
        AlertType.warning => const Color(0xFFFAEEDA),
        AlertType.info => const Color(0xFFE6F1FB),
      };
  Color get border => switch (this) {
        AlertType.danger => const Color(0xFFF09595),
        AlertType.warning => const Color(0xFFFAC775),
        AlertType.info => const Color(0xFF85B7EB),
      };
  Color get text => switch (this) {
        AlertType.danger => const Color(0xFFA32D2D),
        AlertType.warning => const Color(0xFF854F0B),
        AlertType.info => const Color(0xFF185FA5),
      };
  Color get iconColor => switch (this) {
        AlertType.danger => const Color(0xFFE24B4A),
        AlertType.warning => const Color(0xFFEF9F27),
        AlertType.info => const Color(0xFF378ADD),
      };
}

// ═══════════════════════════════════════════════════════════════
// WIDGET 1 — Alertes santé
// ═══════════════════════════════════════════════════════════════

class HealthAlertsSection extends StatelessWidget {
  final List<HealthAlert> alerts;
  const HealthAlertsSection({super.key, required this.alerts});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionLabel('Alertes du jour'),
        const SizedBox(height: 8),
        ...alerts.map((a) => _AlertTile(alert: a)),
      ],
    );
  }
}

class _AlertTile extends StatelessWidget {
  final HealthAlert alert;
  const _AlertTile({required this.alert});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border.all(color: alert.type.border.withOpacity(0.55), width: 0.5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(alert.icon, color: alert.type.iconColor, size: 17),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              alert.text,
              style: TextStyle(
                fontSize: 13,
                color: colorScheme.onSurface,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// WIDGET 2 — Suivi nutritionnel (calories + macros)
// ═══════════════════════════════════════════════════════════════





// ═══════════════════════════════════════════════════════════════
// WIDGET 3 — Water tracker
// ═══════════════════════════════════════════════════════════════

class WaterTrackerCard extends StatefulWidget {
  final int initialMl;
  final int goalMl;
  const WaterTrackerCard(
      {super.key, this.initialMl = 1200, this.goalMl = 2500});

  @override
  State<WaterTrackerCard> createState() => _WaterTrackerCardState();
}

class _WaterTrackerCardState extends State<WaterTrackerCard> {
  late int _currentMl;
  static const _glassSize = 250;

  @override
  void initState() {
    super.initState();
    _currentMl = widget.initialMl;
  }

  int get _glasses => (_currentMl / _glassSize).round();
  int get _goalGlasses => (widget.goalMl / _glassSize).round();
  double get _pct => (_currentMl / widget.goalMl).clamp(0.0, 1.0);

  Color get _barColor => _pct >= 0.8
      ? const Color(0xFF1D9E75)
      : _pct >= 0.5
          ? const Color.fromARGB(255, 101, 86, 0)
          : const Color(0xFFE24B4A);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border.all(color: colorScheme.outlineVariant, width: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.water_drop_outlined,
                  color: colorScheme.primary, size: 18),
              const SizedBox(width: 8),
              Text('Hydratation',
                  style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      color: colorScheme.onSurface)),
              const Spacer(),
              Text(
                '${(_currentMl / 1000).toStringAsFixed(1)} L / ${(widget.goalMl / 1000).toStringAsFixed(1)} L',
                style: TextStyle(
                    fontSize: 13,
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: List.generate(_goalGlasses, (i) {
              final filled = i < _glasses;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (filled) {
                      _currentMl = (i * _glassSize).clamp(0, widget.goalMl);
                    } else {
                      _currentMl =
                          ((i + 1) * _glassSize).clamp(0, widget.goalMl);
                    }
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 32,
                  height: 36,
                  decoration: BoxDecoration(
                    color: filled
                        ? const Color(0xFF378ADD)
                        : colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: filled
                          ? colorScheme.primary
                          : colorScheme.outlineVariant,
                      width: 0.5,
                    ),
                  ),
                  child: Icon(
                    Icons.local_drink_outlined,
                    size: 16,
                    color: filled ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: _pct,
              minHeight: 8,
              backgroundColor: colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(_barColor),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${(_pct * 100).round()}% de l\'objectif journalier',
            style:
                TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// WIDGET 4 — Recommandation du jour
// ═══════════════════════════════════════════════════════════════

class DailyRecommendationCard extends StatelessWidget {
  final CyclePhase phase;
  final List<String> foodTags;

  const DailyRecommendationCard({
    super.key,
    required this.phase,
    required this.foodTags,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.tertiaryContainer.withOpacity(0.35),
        border:
            Border.all(color: colorScheme.tertiary.withOpacity(0.25), width: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome_rounded,
                  color: colorScheme.tertiary, size: 18),
              const SizedBox(width: 8),
              Text('Recommandation du jour',
                  style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      color: colorScheme.tertiary)),
            ],
          ),
          const SizedBox(height: 8),
          RichText(
            text: TextSpan(
              style: TextStyle(
                  fontSize: 13,
                  color: colorScheme.onSurface,
                  height: 1.6),
              children: [
                TextSpan(
                    text: 'Phase ${phase.label} détectée · Objectif : équilibre hormonal\n'),
                const TextSpan(
                    text: 'Priorité : ',
                    style: TextStyle(fontWeight: FontWeight.w500)),
                TextSpan(text: phase.tip),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: foodTags
                .map((t) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                  color: colorScheme.tertiary.withOpacity(0.12),
                  border: Border.all(
                    color: colorScheme.tertiary.withOpacity(0.35),
                    width: 0.5),
                        borderRadius: BorderRadius.circular(999),
                      ),
                  child: Text(t,
                    style: TextStyle(
                      fontSize: 12, color: colorScheme.onSurface)),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// WIDGET 5 — Nutrition par phase du cycle
// ═══════════════════════════════════════════════════════════════

class CycleNutritionSection extends StatefulWidget {
  final CyclePhase initialPhase;
  const CycleNutritionSection(
      {super.key, this.initialPhase = CyclePhase.luteale});

  @override
  State<CycleNutritionSection> createState() => _CycleNutritionSectionState();
}

class _CycleNutritionSectionState extends State<CycleNutritionSection> {
  late CyclePhase _active;

  @override
  void initState() {
    super.initState();
    _active = widget.initialPhase;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionLabel('Nutrition & cycle menstruel'),
        const SizedBox(height: 8),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 2.8,
          children: CyclePhase.values
              .map((p) => _PhaseTab(
                    phase: p,
                    selected: _active == p,
                    onTap: () => setState(() => _active = p),
                  ))
              .toList(),
        ),
        const SizedBox(height: 12),
        _PhaseDetailCard(phase: _active),
      ],
    );
  }
}

class _PhaseTab extends StatelessWidget {
  final CyclePhase phase;
  final bool selected;
  final VoidCallback onTap;
  const _PhaseTab(
      {required this.phase, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? phase.bg : colorScheme.surface,
          border: Border.all(
            color: selected ? phase.color : colorScheme.outlineVariant,
            width: selected ? 1.5 : 0.5,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(phase.emoji, style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 2),
            Text(phase.label,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                color: selected ? phase.color : colorScheme.onSurface)),
            Text(phase.days,
              style: TextStyle(
                fontSize: 10, color: colorScheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}

class _PhaseDetailCard extends StatelessWidget {
  final CyclePhase phase;
  const _PhaseDetailCard({required this.phase});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: phase.bg,
        border: Border.all(
            color: phase.color.withOpacity(0.25), width: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.lightbulb_outline_rounded, size: 15),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  phase.tip,
                  style: TextStyle(
                      fontSize: 12, color: phase.color, height: 1.5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: const [
                      Icon(Icons.check_circle_outline_rounded,
                        color: Color(0xFF3B6D11), size: 14),
                      SizedBox(width: 4),
                      Text('À privilégier',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF3B6D11))),
                    ]),
                    const SizedBox(height: 6),
                    ...phase.recommend.map((r) => _FoodItem(
                        text: r,
                        borderColor: phase.color.withOpacity(0.4))),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: const [
                      Icon(Icons.cancel_outlined,
                          color: Color(0xFFA32D2D), size: 14),
                      SizedBox(width: 4),
                      Text('À éviter',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFFA32D2D))),
                    ]),
                    const SizedBox(height: 6),
                    ...phase.avoid.map((a) => _FoodItem(
                        text: a,
                        borderColor:
                            const Color(0xFFF09595).withOpacity(0.6))),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FoodItem extends StatelessWidget {
  final String text;
  final Color borderColor;
  const _FoodItem({required this.text, required this.borderColor});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.only(left: 6),
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: borderColor, width: 2)),
      ),
      child: Text(text,
          style: TextStyle(fontSize: 12, color: colorScheme.onSurface, height: 1.4)),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// WIDGET 6 — Conseils d'experts
// ═══════════════════════════════════════════════════════════════

class ExpertAdviceSection extends StatelessWidget {
  final List<ExpertAdvice> experts;
  const ExpertAdviceSection({super.key, required this.experts});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionLabel('Conseils d\'experts'),
        const SizedBox(height: 8),
        ...experts.map((e) => _ExpertCard(expert: e)),
      ],
    );
  }
}

class _ExpertCard extends StatelessWidget {
  final ExpertAdvice expert;
  const _ExpertCard({required this.expert});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border.all(color: colorScheme.outlineVariant, width: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 19,
                backgroundColor: expert.bg,
                child: Text(
                  expert.initials,
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: expert.color),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(expert.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 13)),
                    Text(expert.role,
                      style: TextStyle(
                        fontSize: 12, color: colorScheme.onSurfaceVariant)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 9, vertical: 3),
                decoration: BoxDecoration(
                  color: expert.bg,
                  border: Border.all(
                      color: expert.color.withOpacity(0.25), width: 0.5),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.verified_outlined,
                        size: 12, color: expert.color),
                    const SizedBox(width: 4),
                    Text('Vérifié',
                        style: TextStyle(
                            fontSize: 11,
                            color: expert.color,
                            fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(expert.title,
              style: const TextStyle(
                  fontWeight: FontWeight.w500, fontSize: 13)),
          const SizedBox(height: 6),
          Text(expert.body,
              style: TextStyle(
                  fontSize: 13,
                  color: colorScheme.onSurfaceVariant,
                  height: 1.6)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text('# ${expert.tag}',
                style: TextStyle(
                    fontSize: 11, color: colorScheme.onSurfaceVariant)),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// SHARED — Label de section
// ═══════════════════════════════════════════════════════════════

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: colorScheme.onSurfaceVariant,
        letterSpacing: 0.8,
      ),
    );
  }
}