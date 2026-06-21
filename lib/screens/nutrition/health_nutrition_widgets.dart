// ignore_for_file: deprecated_member_use
import 'package:fiteva/core/nutrition/nutrition_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

// ══════════════════════════════════════════════════════════════════════════════
//  DESIGN TOKENS
// ══════════════════════════════════════════════════════════════════════════════
const _kGreen   = Color(0xFF1C4D30);
const _kMint    = Color(0xFF7ABB98);
const _kMintBg  = Color(0xFFEAF3EC);
const _kBorder  = Color(0xFFECECEC);
const _kText1   = Color(0xFF1A1A1A);
const _kText2   = Color(0xFF6B7280);
const _kSurface = Colors.white;

// ══════════════════════════════════════════════════════════════════════════════
//  MODELS
// ══════════════════════════════════════════════════════════════════════════════
enum CyclePhase { menstruation, folliculaire, ovulation, luteale }

extension CyclePhaseExt on CyclePhase {
  String get label => switch (this) {
    CyclePhase.menstruation => 'Menstruation',
    CyclePhase.folliculaire => 'Folliculaire',
    CyclePhase.ovulation    => 'Ovulation',
    CyclePhase.luteale      => 'Lutéale',
  };
  String get days => switch (this) {
    CyclePhase.menstruation => 'J1–J5',
    CyclePhase.folliculaire => 'J6–J13',
    CyclePhase.ovulation    => 'J14–J16',
    CyclePhase.luteale      => 'J17–J28',
  };
  String get emoji => switch (this) {
    CyclePhase.menstruation => '🔴',
    CyclePhase.folliculaire => '🌱',
    CyclePhase.ovulation    => '✨',
    CyclePhase.luteale      => '🌙',
  };
  Color get color => switch (this) {
    CyclePhase.menstruation => const Color(0xFFB22B4A),
    CyclePhase.folliculaire => const Color(0xFF185FA5),
    CyclePhase.ovulation    => const Color(0xFF0F6E56),
    CyclePhase.luteale      => const Color(0xFF9B5E0A),
  };
  Color get bg => switch (this) {
    CyclePhase.menstruation => const Color(0xFFFBE8EE),
    CyclePhase.folliculaire => const Color(0xFFE6F1FB),
    CyclePhase.ovulation    => const Color(0xFFE1F5EE),
    CyclePhase.luteale      => const Color(0xFFFAEEDA),
  };
  String get tip => switch (this) {
    CyclePhase.menstruation =>
      'Privilégier les aliments riches en fer pour compenser les pertes sanguines.',
    CyclePhase.folliculaire =>
      'Phase idéale pour augmenter l\'intensité de l\'entraînement et les protéines.',
    CyclePhase.ovulation    =>
      'Énergie au maximum : profiter pour les efforts physiques intenses.',
    CyclePhase.luteale      =>
      'Magnésium et B6 réduisent les symptômes du SPM et les fringales.',
  };
  List<String> get recommend => switch (this) {
    CyclePhase.menstruation => ['Fer (lentilles, épinards)', 'Vitamine C', 'Gingembre anti-douleur', 'Chocolat noir 70%'],
    CyclePhase.folliculaire => ['Graines de lin', 'Légumes crucifères', 'Protéines maigres', 'Oméga-3'],
    CyclePhase.ovulation    => ['Antioxydants (baies, brocoli)', 'Fibres', 'Zinc (graines de citrouille)', 'Eau ++'],
    CyclePhase.luteale      => ['Magnésium (amandes, banane)', 'Vitamine B6', 'Calcium', 'Complexes glucides'],
  };
  List<String> get avoid => switch (this) {
    CyclePhase.menstruation => ['Alcool', 'Sel en excès', 'Caféine', 'Sucres raffinés'],
    CyclePhase.folliculaire => ['Alcool', 'Aliments transformés'],
    CyclePhase.ovulation    => ['Excès de caféine', 'Aliments inflammatoires'],
    CyclePhase.luteale      => ['Sel', 'Caféine', 'Alcool', 'Sucre raffiné'],
  };
}

class ExpertAdvice {
  final String name, role, initials, title, body, tag;
  final Color color, bg;
  const ExpertAdvice({
    required this.name, required this.role, required this.initials,
    required this.color, required this.bg,
    required this.title, required this.body, required this.tag,
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
    AlertType.danger  => const Color(0xFFFCEBEB),
    AlertType.warning => const Color(0xFFFAEEDA),
    AlertType.info    => const Color(0xFFE6F1FB),
  };
  Color get border => switch (this) {
    AlertType.danger  => const Color(0xFFF09595),
    AlertType.warning => const Color(0xFFFAC775),
    AlertType.info    => const Color(0xFF85B7EB),
  };
  Color get textColor => switch (this) {
    AlertType.danger  => const Color(0xFFA32D2D),
    AlertType.warning => const Color(0xFF854F0B),
    AlertType.info    => const Color(0xFF185FA5),
  };
  Color get iconColor => switch (this) {
    AlertType.danger  => const Color(0xFFE24B4A),
    AlertType.warning => const Color(0xFFEF9F27),
    AlertType.info    => const Color(0xFF378ADD),
  };
  IconData get defaultIcon => switch (this) {
    AlertType.danger  => LucideIcons.alertCircle,
    AlertType.warning => LucideIcons.alertTriangle,
    AlertType.info    => LucideIcons.info,
  };
}

// ── Calorie extension ─────────────────────────────────────────────────────────
extension CyclePhaseCalorieExt on CyclePhase {
  int get calorieAdjustment => switch (this) {
    CyclePhase.menstruation => -50,
    CyclePhase.folliculaire => 0,
    CyclePhase.ovulation    => 0,
    CyclePhase.luteale      => 150,
  };
  String get calorieExplanation => switch (this) {
    CyclePhase.menstruation => 'Légère réduction — le métabolisme ralentit en début de cycle.',
    CyclePhase.folliculaire => 'Objectif standard — énergie stable et montante.',
    CyclePhase.ovulation    => 'Objectif standard — pic d\'énergie, besoins stables.',
    CyclePhase.luteale      => 'Cible plus haute — ton corps brûle plus en phase lutéale.',
  };
  List<PhaseNutritionTarget> get macroTargets => switch (this) {
    CyclePhase.menstruation => const [
      PhaseNutritionTarget('Fer',                '↑', Color(0xFFD94F6B)),
      PhaseNutritionTarget('Anti-inflammatoires','↑', Color(0xFFE8927C)),
      PhaseNutritionTarget('Protéines',          '=', _kMint),
      PhaseNutritionTarget('Glucides',           '=', Color(0xFF7BA7FF)),
    ],
    CyclePhase.folliculaire => const [
      PhaseNutritionTarget('Protéines','↑', _kMint),
      PhaseNutritionTarget('Oméga-3', '↑', Color(0xFF6B8FD4)),
      PhaseNutritionTarget('Glucides','=', Color(0xFF7BA7FF)),
      PhaseNutritionTarget('Lipides', '=', Color(0xFFF4A940)),
    ],
    CyclePhase.ovulation => const [
      PhaseNutritionTarget('Zinc',        '↑', Color(0xFF0F6E56)),
      PhaseNutritionTarget('Antioxydants','↑', Color(0xFF7BA7FF)),
      PhaseNutritionTarget('Protéines',   '=', _kMint),
      PhaseNutritionTarget('Fibres',      '↑', Color(0xFFF4A940)),
    ],
    CyclePhase.luteale => const [
      PhaseNutritionTarget('Glucides complexes','+', Color(0xFF7BA7FF)),
      PhaseNutritionTarget('Magnésium',         '+', Color(0xFF6B4F9B)),
      PhaseNutritionTarget('Protéines',         '=', _kMint),
      PhaseNutritionTarget('Lipides',           '=', Color(0xFFF4A940)),
    ],
  };
  DailyNutrientTip get nutrientOfDay => switch (this) {
    CyclePhase.menstruation => const DailyNutrientTip(
      nutrient: 'Fer', icon: LucideIcons.droplets,
      color: Color(0xFFD94F6B), bg: Color(0xFFFDF0F2),
      reason: 'Compense les pertes sanguines et combat la fatigue.',
      sources: [
        NutrientFoodSource('Lentilles cuites',  '3,3 mg / 100 g'),
        NutrientFoodSource('Épinards cuits',    '2,7 mg / 100 g'),
        NutrientFoodSource('Chocolat noir 70%', '11 mg / 100 g'),
      ]),
    CyclePhase.folliculaire => const DailyNutrientTip(
      nutrient: 'Protéines', icon: LucideIcons.dumbbell,
      color: _kGreen, bg: _kMintBg,
      reason: 'Soutient la synthèse hormonale et la récupération musculaire.',
      sources: [
        NutrientFoodSource('Poulet grillé', '31 g / 100 g'),
        NutrientFoodSource('Œufs entiers',  '13 g / 100 g'),
        NutrientFoodSource('Pois chiches',  '9 g / 100 g'),
      ]),
    CyclePhase.ovulation => const DailyNutrientTip(
      nutrient: 'Zinc', icon: LucideIcons.zap,
      color: Color(0xFF0F6E56), bg: Color(0xFFE1F5EE),
      reason: 'Favorise la maturation de l\'ovule et le système immunitaire.',
      sources: [
        NutrientFoodSource('Graines de courge', '7,5 mg / 30 g'),
        NutrientFoodSource('Bœuf maigre',       '4,8 mg / 100 g'),
        NutrientFoodSource('Noix de cajou',     '1,6 mg / 30 g'),
      ]),
    CyclePhase.luteale => const DailyNutrientTip(
      nutrient: 'Magnésium', icon: LucideIcons.moonStar,
      color: Color(0xFF6B4F9B), bg: Color(0xFFF3EEF9),
      reason: 'Réduit les crampes, l\'irritabilité et améliore le sommeil.',
      sources: [
        NutrientFoodSource('Amandes',           '76 mg / 30 g'),
        NutrientFoodSource('Graines de courge', '150 mg / 30 g'),
        NutrientFoodSource('Banane',            '37 mg / pièce'),
      ]),
  };
}

class PhaseNutritionTarget {
  final String name, direction;
  final Color color;
  const PhaseNutritionTarget(this.name, this.direction, this.color);
}

class DailyNutrientTip {
  final String nutrient, reason;
  final IconData icon;
  final Color color, bg;
  final List<NutrientFoodSource> sources;
  const DailyNutrientTip({
    required this.nutrient, required this.icon, required this.color,
    required this.bg, required this.reason, required this.sources,
  });
}

class NutrientFoodSource {
  final String food, amount;
  const NutrientFoodSource(this.food, this.amount);
}

// ══════════════════════════════════════════════════════════════════════════════
//  W1 — SCORE VITALITÉ
// ══════════════════════════════════════════════════════════════════════════════
class VitalityScoreCard extends ConsumerWidget {
  const VitalityScoreCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totals  = ref.watch(todayTotalsProvider);
    final profile = ref.watch(userProfileProvider);
    final water   = ref.watch(waterProvider);

    final calPct   = profile.dailyKcal > 0
        ? (totals.calories / profile.dailyKcal).clamp(0.0, 1.0) : 0.0;
    final protPct  = profile.dailyProtein > 0
        ? (totals.protein / profile.dailyProtein).clamp(0.0, 1.0) : 0.0;
    final carbsPct = profile.dailyCarbs > 0
        ? (totals.carbs / profile.dailyCarbs).clamp(0.0, 1.0) : 0.0;
    final fatPct   = profile.dailyFat > 0
        ? (totals.fat / profile.dailyFat).clamp(0.0, 1.0) : 0.0;
    final waterPct = profile.waterGoalMl > 0
        ? (water / profile.waterGoalMl).clamp(0.0, 1.0) : 0.0;

    final score = ((calPct + protPct + carbsPct + fatPct + waterPct) / 5 * 100).round();

    final tip = calPct < 0.5
        ? 'Mange davantage pour atteindre ton objectif calorique'
        : waterPct < 0.5
            ? 'Améliore l\'hydratation pour atteindre 80 pts'
            : score >= 80
                ? 'Excellent bilan nutritionnel aujourd\'hui !'
                : 'Continue comme ça pour atteindre 80 pts';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _kGreen,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [BoxShadow(
          color: _kGreen.withOpacity(0.28),
          blurRadius: 20, offset: const Offset(0, 6))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        Row(children: [
          Text('BILAN DU JOUR', style: GoogleFonts.inter(
            color: _kMint, fontSize: 9, fontWeight: FontWeight.w700,
            letterSpacing: 2.5)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.10),
              borderRadius: BorderRadius.circular(20)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(LucideIcons.calendarDays, size: 10, color: Colors.white54),
              const SizedBox(width: 5),
              Text('Aujourd\'hui', style: GoogleFonts.inter(
                fontSize: 10, color: Colors.white60)),
            ])),
        ]),

        const SizedBox(height: 16),

        // Score ring + calories consumed
        Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          

          const SizedBox(width: 16),

          // Calories big number
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, children: [
            FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft,
            child: Text('${totals.calories}', style: GoogleFonts.outfit(
              fontSize: 36, fontWeight: FontWeight.w800,
              color: Colors.white, height: 1))),
            Text('/ ${profile.dailyKcal} kcal', style: GoogleFonts.inter(
              fontSize: 12, color: _kMint)),
            const SizedBox(height: 4),
            Text(
              totals.calories >= profile.dailyKcal
                  ? 'Objectif atteint 🎉'
                  : '${profile.dailyKcal - totals.calories} kcal restantes',
              style: GoogleFonts.inter(fontSize: 11, color: Colors.white60)),
          ])),
        ]),

        const SizedBox(height: 14),

        // Macros grid — each shows consumed / goal / remaining
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.07),
            borderRadius: BorderRadius.circular(16)),
          child: Column(children: [
            _MacroRow(
              label: 'Protéines',
              consumed: totals.protein,
              goal: profile.dailyProtein,
              unit: 'g',
              color: _kMint,
            ),
            const SizedBox(height: 10),
            _MacroRow(
              label: 'Glucides',
              consumed: totals.carbs,
              goal: profile.dailyCarbs,
              unit: 'g',
              color: const Color(0xFF7BD4FF),
            ),
            const SizedBox(height: 10),
            _MacroRow(
              label: 'Lipides',
              consumed: totals.fat,
              goal: profile.dailyFat,
              unit: 'g',
              color: const Color(0xFFFFB347),
            ),
          ]),
        ),

        const SizedBox(height: 10),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12)),
          child: Row(children: [
            const Icon(LucideIcons.trendingUp, size: 13, color: _kMint),
            const SizedBox(width: 8),
            Flexible(child: Text(tip,
              style: GoogleFonts.inter(fontSize: 11, color: Colors.white70, height: 1.4))),
          ])),
      ]),
    );
  }
}

class _MacroRow extends StatelessWidget {
  final String label, unit;
  final int consumed, goal;
  final Color color;
  const _MacroRow({
    required this.label, required this.consumed, required this.goal,
    required this.unit, required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final pct       = goal > 0 ? (consumed / goal).clamp(0.0, 1.0) : 0.0;
    final remaining = (goal - consumed).clamp(0, 9999);
    return Row(children: [
      SizedBox(width: 70, child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, maxLines: 1, overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
          fontSize: 11, color: Colors.white70, fontWeight: FontWeight.w600)),
        Text(
          remaining > 0 ? '-$remaining$unit' : 'OK ✓',
          maxLines: 1, overflow: TextOverflow.ellipsis,
          style: GoogleFonts.inter(
            fontSize: 9,
            color: remaining > 0 ? color.withOpacity(0.75) : _kMint)),
      ])),
      Expanded(child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: pct.toDouble(), minHeight: 6,
            backgroundColor: Colors.white.withOpacity(0.12),
            valueColor: AlwaysStoppedAnimation(color))),
        const SizedBox(height: 3),
        Text('$consumed / $goal $unit', style: GoogleFonts.inter(
          fontSize: 9, color: Colors.white38)),
      ])),
    ]);
  }
}

// ══════════════════════════════════════════════════════════════════════════════
//  W2 — MICRONUTRIMENTS CLÉS
// ══════════════════════════════════════════════════════════════════════════════
class MicronutrientsCard extends StatelessWidget {
  const MicronutrientsCard({super.key});

  static const _nutrients = [
    _NutrientData('Fer',       12.0, 18.0,   'mg', Color(0xFFD94F6B), Color(0xFFFDF0F2)),
    _NutrientData('Calcium',  680.0, 1000.0,  'mg', Color(0xFF5BAE8A), Color(0xFFEEF8F3)),
    _NutrientData('Magnésium',180.0, 310.0,   'mg', Color(0xFF6B8FD4), Color(0xFFF0F3FC)),
    _NutrientData('Oméga-3',    0.8,   1.6,   'g',  Color(0xFFF4A940), Color(0xFFFFF6E9)),
  ];

  @override
  Widget build(BuildContext context) => _Card(
    eyebrow: 'MICRONUTRIMENTS',
    title: 'Nutriments essentiels',
    trailing: _StatusPill('${_nutrients.where((n) => n.pct >= 0.7).length}/4 OK',
      _kGreen, _kMintBg),
    child: GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 10, mainAxisSpacing: 10,
      childAspectRatio: 2.0,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: _nutrients.map((n) => _NutrientTileWidget(n: n)).toList()),
  );
}

class _NutrientData {
  final String name, unit;
  final double current, goal;
  final Color color, bg;
  const _NutrientData(this.name, this.current, this.goal, this.unit, this.color, this.bg);
  double get pct => (current / goal).clamp(0.0, 1.0);
}

class _NutrientTileWidget extends StatelessWidget {
  final _NutrientData n;
  const _NutrientTileWidget({required this.n});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
    decoration: BoxDecoration(
      color: n.bg, borderRadius: BorderRadius.circular(14)),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(children: [
          Container(width: 7, height: 7,
            decoration: BoxDecoration(color: n.color, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text(n.name, style: GoogleFonts.inter(
            fontSize: 11, fontWeight: FontWeight.w700, color: _kText1)),
          const Spacer(),
          Text('${(n.pct * 100).round()}%', style: GoogleFonts.inter(
            fontSize: 10, fontWeight: FontWeight.w700, color: n.color)),
        ]),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: LinearProgressIndicator(
            value: n.pct, minHeight: 5,
            backgroundColor: n.color.withOpacity(0.15),
            valueColor: AlwaysStoppedAnimation(n.color))),
        Text(
          '${n.current.toStringAsFixed(n.current < 10 ? 1 : 0)} / ${n.goal.toStringAsFixed(0)} ${n.unit}',
          style: GoogleFonts.inter(fontSize: 10, color: _kText2)),
      ],
    ),
  );
}

// ══════════════════════════════════════════════════════════════════════════════
//  W3 — SIGNAL DU MOMENT (Body Signals)
// ══════════════════════════════════════════════════════════════════════════════
class BodySignalCard extends StatefulWidget {
  const BodySignalCard({super.key});

  @override
  State<BodySignalCard> createState() => _BodySignalCardState();
}

class _BodySignalCardState extends State<BodySignalCard> {
  int _energy = -1, _digestion = -1, _humeur = -1;
  bool _saved = false;

  @override
  Widget build(BuildContext context) {
    final allSet = _energy >= 0 && _digestion >= 0 && _humeur >= 0;
    return _Card(
      eyebrow: 'SIGNAL DU MOMENT',
      title: 'Comment tu te sens ?',
      child: Column(children: [
        _SignalRowWidget(
          icon: LucideIcons.zap, label: 'Énergie',
          options: ['Faible', 'Normale', 'Élevée'],
          color: const Color(0xFFF4A940),
          selected: _energy, onSelect: (i) => setState(() { _energy = i; _saved = false; })),
        const SizedBox(height: 10),
        _SignalRowWidget(
          icon: LucideIcons.activity, label: 'Digestion',
          options: ['Difficile', 'Correcte', 'Bonne'],
          color: const Color(0xFF5BAE8A),
          selected: _digestion, onSelect: (i) => setState(() { _digestion = i; _saved = false; })),
        const SizedBox(height: 10),
        _SignalRowWidget(
          icon: LucideIcons.smile, label: 'Humeur',
          options: ['Basse', 'Neutre', 'Bonne'],
          color: const Color(0xFF6B8FD4),
          selected: _humeur, onSelect: (i) => setState(() { _humeur = i; _saved = false; })),

        if (allSet && !_saved) ...[
          const SizedBox(height: 14),
          GestureDetector(
            onTap: () {
              HapticFeedback.mediumImpact();
              setState(() => _saved = true);
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 13),
              decoration: BoxDecoration(
                color: _kGreen,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [BoxShadow(
                  color: _kGreen.withOpacity(0.2),
                  blurRadius: 12, offset: const Offset(0, 4))]),
              child: Center(child: Text('Enregistrer mon signal',
                style: GoogleFonts.inter(
                  fontSize: 13, fontWeight: FontWeight.w700,
                  color: Colors.white)))),
          ),
        ],

        if (_saved) ...[
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: _kMintBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _kMint.withOpacity(0.35))),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(LucideIcons.checkCircle, size: 14, color: _kGreen),
              const SizedBox(width: 7),
              Text('Signal enregistré !', style: GoogleFonts.inter(
                fontSize: 13, fontWeight: FontWeight.w600, color: _kGreen)),
            ])),
        ],
      ]),
    );
  }
}

class _SignalRowWidget extends StatelessWidget {
  final IconData icon;
  final String label;
  final List<String> options;
  final Color color;
  final int selected;
  final ValueChanged<int> onSelect;

  const _SignalRowWidget({
    required this.icon, required this.label, required this.options,
    required this.color, required this.selected, required this.onSelect,
  });

  @override
  Widget build(BuildContext context) => Row(children: [
    Container(
      padding: const EdgeInsets.all(7),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(9)),
      child: Icon(icon, size: 13, color: color)),
    const SizedBox(width: 10),
    SizedBox(width: 68, child: Text(label, style: GoogleFonts.inter(
      fontSize: 12, fontWeight: FontWeight.w600, color: _kText1))),
    const Spacer(),
    ...List.generate(3, (i) => GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onSelect(i);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        margin: const EdgeInsets.only(left: 5),
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
        decoration: BoxDecoration(
          color: selected == i ? color : const Color(0xFFF4F4F4),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected == i ? color : Colors.transparent)),
        child: Text(options[i], style: GoogleFonts.inter(
          fontSize: 10, fontWeight: FontWeight.w600,
          color: selected == i ? Colors.white : _kText2))))),
  ]);
}

// ══════════════════════════════════════════════════════════════════════════════
//  W4 — HYDRATATION
// ══════════════════════════════════════════════════════════════════════════════
class WaterTrackerCard extends ConsumerWidget {
  const WaterTrackerCard({super.key});

  static const _step = 250;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentMl = ref.watch(waterProvider);
    final goalMl    = ref.watch(userProfileProvider).waterGoalMl;
    final notifier  = ref.read(nutritionProvider.notifier);

    final pct        = goalMl > 0 ? (currentMl / goalMl).clamp(0.0, 1.0) : 0.0;
    final glasses    = (currentMl / _step).floor();
    final goalGlasses = (goalMl / _step).ceil();
    final remaining  = goalMl - currentMl;

    final statusColor = pct >= 0.8
        ? _kGreen
        : pct >= 0.5
            ? const Color(0xFFC47A00)
            : const Color(0xFFE24B4A);

    final statusText = pct >= 0.8
        ? 'Très bien hydratée'
        : pct >= 0.5
            ? 'À continuer'
            : 'Bois plus d\'eau';

    return _Card(
      eyebrow: 'HYDRATATION',
      title: 'Suivi de l\'eau',
      trailing: _StatusPill(statusText, statusColor, statusColor.withOpacity(0.10)),
      child: Column(children: [

        Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Flexible(child: FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft,
            child: Text((currentMl / 1000).toStringAsFixed(1),
              style: GoogleFonts.outfit(
                fontSize: 42, fontWeight: FontWeight.w800,
                color: _kGreen, height: 1)))),
          const SizedBox(width: 6),
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text('L / ${(goalMl / 1000).toStringAsFixed(1)} L',
              style: GoogleFonts.inter(fontSize: 13, color: _kText2))),
          const Spacer(),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(remaining > 0 ? '$remaining ml restants' : 'Atteint !',
              maxLines: 1,
              style: GoogleFonts.inter(
                fontSize: 11, fontWeight: FontWeight.w600,
                color: remaining > 0 ? _kText2 : _kGreen)),
            Text('$glasses / $goalGlasses verres',
              style: GoogleFonts.inter(fontSize: 10, color: _kText2)),
          ]),
        ]),

        const SizedBox(height: 14),

        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: pct, minHeight: 8,
            backgroundColor: const Color(0xFFEBF5FF),
            valueColor: const AlwaysStoppedAnimation(Color(0xFF378ADD)))),

        const SizedBox(height: 16),

        Wrap(spacing: 7, runSpacing: 7,
          children: List.generate(goalGlasses, (i) {
            final filled = i < glasses;
            return GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                final newMl = filled
                    ? (i * _step).clamp(0, goalMl)
                    : ((i + 1) * _step).clamp(0, goalMl);
                notifier.setWater(newMl);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 34, height: 38,
                decoration: BoxDecoration(
                  color: filled ? const Color(0xFFD6EEFF) : const Color(0xFFF4F4F4),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: filled ? const Color(0xFF378ADD) : _kBorder,
                    width: filled ? 1.5 : 1)),
                child: Icon(LucideIcons.glassWater,
                  size: 16,
                  color: filled ? const Color(0xFF2373C7) : _kText2)),
            );
          })),

        const SizedBox(height: 14),

        Row(children: [
          _WaterBtn(label: '-250 ml', onTap: () {
            if (currentMl >= _step) notifier.addWater(-_step);
          }, minus: true),
          const SizedBox(width: 10),
          _WaterBtn(label: '+250 ml', onTap: () {
            notifier.addWater(_step);
          }, minus: false),
        ]),
      ]),
    );
  }
}

class _WaterBtn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool minus;
  const _WaterBtn({required this.label, required this.onTap, required this.minus});

  @override
  Widget build(BuildContext context) => Expanded(
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(
          color: minus ? const Color(0xFFF4F4F4) : _kMintBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: minus ? _kBorder : _kMint.withOpacity(0.4))),
        child: Center(child: Text(label, style: GoogleFonts.inter(
          fontSize: 12, fontWeight: FontWeight.w700,
          color: minus ? _kText2 : _kGreen)))),
    ),
  );
}

// ══════════════════════════════════════════════════════════════════════════════
//  W5 — CYCLE NUTRITION
// ══════════════════════════════════════════════════════════════════════════════
class CycleNutritionSection extends StatefulWidget {
  final CyclePhase initialPhase;
  const CycleNutritionSection({super.key, this.initialPhase = CyclePhase.luteale});

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
    return _Card(
      eyebrow: 'CYCLE MENSTRUEL',
      title: 'Nutrition & cycle',
      child: Column(children: [

        // Phase selector pills
        Row(children: CyclePhase.values.map((p) {
          final sel = _active == p;
          return Expanded(child: GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _active = p);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              margin: EdgeInsets.only(
                right: p != CyclePhase.luteale ? 6 : 0),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: sel ? p.color : const Color(0xFFF4F4F4),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: sel ? p.color : Colors.transparent,
                  width: 1.5)),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Text(p.emoji, style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 3),
                Text(p.label.split(' ').first, style: GoogleFonts.inter(
                  fontSize: 9, fontWeight: FontWeight.w700,
                  color: sel ? Colors.white : _kText2)),
              ])),
          ));
        }).toList()),

        const SizedBox(height: 14),

        // Phase detail
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: _PhaseDetailCard(phase: _active, key: ValueKey(_active))),
      ]),
    );
  }
}

class _PhaseDetailCard extends StatelessWidget {
  final CyclePhase phase;
  const _PhaseDetailCard({required this.phase, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: phase.bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: phase.color.withOpacity(0.2))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        // Phase pill + days
        Row(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: phase.color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20)),
            child: Text('${phase.emoji} ${phase.label}',
              style: GoogleFonts.inter(
                fontSize: 11, fontWeight: FontWeight.w700,
                color: phase.color))),
          const SizedBox(width: 8),
          Text(phase.days, style: GoogleFonts.inter(
            fontSize: 11, color: _kText2)),
        ]),

        const SizedBox(height: 10),

        // Tip
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(LucideIcons.lightbulb, size: 13, color: phase.color),
          const SizedBox(width: 6),
          Expanded(child: Text(phase.tip, style: GoogleFonts.inter(
            fontSize: 12, color: _kText1, height: 1.5))),
        ]),

        const SizedBox(height: 14),
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Recommend
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Icon(LucideIcons.checkCircle, size: 12, color: Color(0xFF3B6D11)),
              const SizedBox(width: 4),
              Text('À privilégier', style: GoogleFonts.inter(
                fontSize: 11, fontWeight: FontWeight.w700,
                color: const Color(0xFF3B6D11))),
            ]),
            const SizedBox(height: 7),
            ...phase.recommend.map((r) => _FoodLine(text: r,
              color: phase.color.withOpacity(0.5))),
          ])),

          const SizedBox(width: 12),

          // Avoid
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Icon(LucideIcons.xCircle, size: 12, color: Color(0xFFA32D2D)),
              const SizedBox(width: 4),
              Text('À éviter', style: GoogleFonts.inter(
                fontSize: 11, fontWeight: FontWeight.w700,
                color: const Color(0xFFA32D2D))),
            ]),
            const SizedBox(height: 7),
            ...phase.avoid.map((a) => _FoodLine(text: a,
              color: const Color(0xFFF09595).withOpacity(0.6))),
          ])),
        ]),
      ]),
    );
  }
}

class _FoodLine extends StatelessWidget {
  final String text;
  final Color color;
  const _FoodLine({required this.text, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 4),
    padding: const EdgeInsets.only(left: 6),
    decoration: BoxDecoration(
      border: Border(left: BorderSide(color: color, width: 2))),
    child: Text(text, style: GoogleFonts.inter(
      fontSize: 11, color: _kText1, height: 1.4)));
}

// ══════════════════════════════════════════════════════════════════════════════
//  W6 — CONSEILS D'EXPERTS
// ══════════════════════════════════════════════════════════════════════════════
class ExpertAdviceSection extends StatelessWidget {
  final List<ExpertAdvice> experts;
  const ExpertAdviceSection({super.key, required this.experts});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start, children: [
    Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(children: [
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('EXPERTS', style: GoogleFonts.inter(
            color: _kMint, fontSize: 9, fontWeight: FontWeight.w700,
            letterSpacing: 2.5)),
          Text('Conseils personnalisés', style: GoogleFonts.outfit(
            color: _kText1, fontSize: 20, fontWeight: FontWeight.w800,
            letterSpacing: -0.3)),
        ])),
      ])),
    ...experts.map((e) => _ExpertCard(expert: e)),
  ]);
}

class _ExpertCard extends StatelessWidget {
  final ExpertAdvice expert;
  const _ExpertCard({required this.expert});

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    decoration: BoxDecoration(
      color: _kSurface,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: _kBorder),
      boxShadow: [BoxShadow(
        color: Colors.black.withOpacity(0.04),
        blurRadius: 14, offset: const Offset(0, 4))]),
    child: Column(children: [

      // Color accent strip
      Container(
        height: 4,
        decoration: BoxDecoration(
          color: expert.color,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20)))),

      Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          // Expert row
          Row(children: [
            CircleAvatar(
              radius: 20, backgroundColor: expert.bg,
              child: Text(expert.initials, style: GoogleFonts.inter(
                fontSize: 13, fontWeight: FontWeight.w700,
                color: expert.color))),
            const SizedBox(width: 10),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(expert.name, style: GoogleFonts.inter(
                fontSize: 13, fontWeight: FontWeight.w700, color: _kText1)),
              Text(expert.role, style: GoogleFonts.inter(
                fontSize: 11, color: _kText2)),
            ])),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
              decoration: BoxDecoration(
                color: expert.bg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: expert.color.withOpacity(0.2))),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(LucideIcons.badgeCheck, size: 11, color: expert.color),
                const SizedBox(width: 4),
                Text('Vérifié', style: GoogleFonts.inter(
                  fontSize: 10, fontWeight: FontWeight.w600,
                  color: expert.color)),
              ])),
          ]),

          const SizedBox(height: 12),

          Text(expert.title, style: GoogleFonts.outfit(
            fontSize: 15, fontWeight: FontWeight.w800, color: _kText1)),
          const SizedBox(height: 5),
          Text(expert.body, style: GoogleFonts.inter(
            fontSize: 13, color: _kText2, height: 1.55)),

          const SizedBox(height: 10),

          Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F0F0),
                borderRadius: BorderRadius.circular(20)),
              child: Text('# ${expert.tag}', style: GoogleFonts.inter(
                fontSize: 10, color: _kText2))),
          ]),
        ]),
      ),
    ]),
  );
}

// ══════════════════════════════════════════════════════════════════════════════
//  W7 — ALERTES SANTÉ
// ══════════════════════════════════════════════════════════════════════════════
class HealthAlertsSection extends StatelessWidget {
  final List<HealthAlert> alerts;
  const HealthAlertsSection({super.key, required this.alerts});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start, children: [
    Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _kBorder),
        boxShadow: [BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 14, offset: const Offset(0, 4))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 30, height: 30,
            decoration: BoxDecoration(
              color: const Color(0xFFFAEEDA),
              borderRadius: BorderRadius.circular(9)),
            child: const Icon(LucideIcons.bell, size: 14, color: Color(0xFFC47A00))),
          const SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('ALERTES', style: GoogleFonts.inter(
              color: _kMint, fontSize: 9, fontWeight: FontWeight.w700,
              letterSpacing: 2.5)),
            Text('Notifications santé', style: GoogleFonts.outfit(
              color: _kText1, fontSize: 16, fontWeight: FontWeight.w800)),
          ]),
        ]),
        const SizedBox(height: 14),
        ...alerts.map((a) => _AlertTile(alert: a)),
      ]),
    ),
  ]);
}

class _AlertTile extends StatelessWidget {
  final HealthAlert alert;
  const _AlertTile({required this.alert});

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: alert.type.bg,
      border: Border.all(color: alert.type.border.withOpacity(0.5)),
      borderRadius: BorderRadius.circular(12)),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(alert.icon, color: alert.type.iconColor, size: 15),
      const SizedBox(width: 10),
      Expanded(child: Text(alert.text, style: GoogleFonts.inter(
        fontSize: 12, color: alert.type.textColor, height: 1.5))),
    ]),
  );
}

// ══════════════════════════════════════════════════════════════════════════════
//  W8 — OBJECTIF CALORIQUE DYNAMIQUE
// ══════════════════════════════════════════════════════════════════════════════
class DynamicCalorieCard extends StatefulWidget {
  final CyclePhase phase;
  final int baseCalories, consumed;

  const DynamicCalorieCard({
    super.key,
    required this.phase,
    this.baseCalories = 2000,
    this.consumed = 865,
  });

  @override
  State<DynamicCalorieCard> createState() => _DynamicCalorieCardState();
}

class _DynamicCalorieCardState extends State<DynamicCalorieCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    _ctrl.forward();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final adjusted  = widget.baseCalories + widget.phase.calorieAdjustment;
    final adj       = widget.phase.calorieAdjustment;
    final progress  = (widget.consumed / adjusted).clamp(0.0, 1.0);
    final remaining = adjusted - widget.consumed;
    final over      = remaining < 0;
    final pc        = widget.phase.color;
    final pb        = widget.phase.bg;

    return _Card(
      eyebrow: 'OBJECTIF CALORIQUE',
      title: 'Ajusté pour ta phase',
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(color: pb, borderRadius: BorderRadius.circular(20)),
        child: Text('${widget.phase.emoji} ${widget.phase.label}',
          style: GoogleFonts.inter(
            fontSize: 10, fontWeight: FontWeight.w700, color: pc))),
      child: Column(children: [

        Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          AnimatedBuilder(
            animation: _anim,
            builder: (_, __) => SizedBox(
              width: 100, height: 100,
              child: Stack(alignment: Alignment.center, children: [
                SizedBox(
                  width: 100, height: 100,
                  child: CircularProgressIndicator(
                    value: progress * _anim.value,
                    strokeWidth: 9,
                    backgroundColor: pc.withOpacity(0.10),
                    valueColor: AlwaysStoppedAnimation(
                      over ? const Color(0xFFE24B4A) : pc),
                    strokeCap: StrokeCap.round)),
                Column(mainAxisSize: MainAxisSize.min, children: [
                  Text('${widget.consumed}', style: GoogleFonts.outfit(
                    fontSize: 22, fontWeight: FontWeight.w800,
                    color: _kText1, height: 1)),
                  Text('/ $adjusted', style: GoogleFonts.inter(
                    fontSize: 10, color: _kText2)),
                  Text('kcal', style: GoogleFonts.inter(
                    fontSize: 9, color: _kText2)),
                ]),
              ])),
          ),

          const SizedBox(width: 14),

          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('$adjusted kcal', style: GoogleFonts.outfit(
              fontSize: 16, fontWeight: FontWeight.w800, color: _kText1)),
            if (adj != 0) ...[
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: adj > 0 ? const Color(0xFFFAEEDA) : _kMintBg,
                  borderRadius: BorderRadius.circular(20)),
                child: Text('${adj > 0 ? '+' : ''}$adj kcal vs base',
                  style: GoogleFonts.inter(
                    fontSize: 10, fontWeight: FontWeight.w700,
                    color: adj > 0 ? const Color(0xFF9B5E0A) : _kGreen))),
            ],
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: over ? const Color(0xFFFFEEEE) : pc.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10)),
              child: Center(child: Text(
                over ? '+${(-remaining).abs()} kcal dépassés'
                     : '$remaining kcal restantes',
                style: GoogleFonts.inter(
                  fontSize: 11, fontWeight: FontWeight.w700,
                  color: over ? const Color(0xFFE03050) : pc)))),
            const SizedBox(height: 8),
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Icon(LucideIcons.info, size: 11, color: pc),
              const SizedBox(width: 5),
              Expanded(child: Text(widget.phase.calorieExplanation,
                style: GoogleFonts.inter(
                  fontSize: 10, color: _kText2, height: 1.4))),
            ]),
          ])),
        ]),

        const SizedBox(height: 14),

        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: pb, borderRadius: BorderRadius.circular(14)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('MACROS · ${widget.phase.label.toUpperCase()}',
              style: GoogleFonts.inter(
                fontSize: 9, fontWeight: FontWeight.w700,
                color: pc, letterSpacing: 2.0)),
            const SizedBox(height: 10),
            Wrap(spacing: 7, runSpacing: 6,
              children: widget.phase.macroTargets.map((m) =>
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: m.color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: m.color.withOpacity(0.25))),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Container(
                      width: 16, height: 16,
                      decoration: BoxDecoration(
                        color: m.color.withOpacity(0.20),
                        shape: BoxShape.circle),
                      child: Center(child: Text(m.direction,
                        style: TextStyle(
                          fontSize: 9, color: m.color,
                          fontWeight: FontWeight.w900)))),
                    const SizedBox(width: 5),
                    Text(m.name, style: GoogleFonts.inter(
                      fontSize: 11, fontWeight: FontWeight.w600, color: _kText1)),
                  ])))
              .toList()),
          ])),
      ]),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
//  W9 — NUTRIMENT DU JOUR
// ══════════════════════════════════════════════════════════════════════════════
class DailyNutrientTipCard extends StatelessWidget {
  final CyclePhase phase;
  const DailyNutrientTipCard({super.key, required this.phase});

  @override
  Widget build(BuildContext context) {
    final tip = phase.nutrientOfDay;
    return _Card(
      eyebrow: 'NUTRIMENT DU JOUR',
      titleWidget: Row(children: [
        Text('Priorité : ', style: GoogleFonts.outfit(
          color: _kText1, fontSize: 20, fontWeight: FontWeight.w800,
          letterSpacing: -0.3)),
        Text(tip.nutrient, style: GoogleFonts.outfit(
          color: tip.color, fontSize: 20, fontWeight: FontWeight.w800,
          letterSpacing: -0.3)),
      ]),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0xFFF4F4F4),
          borderRadius: BorderRadius.circular(20)),
        child: Text('Aujourd\'hui', style: GoogleFonts.inter(
          fontSize: 10, fontWeight: FontWeight.w600, color: _kText2))),
      child: Column(children: [
        // Icon + reason
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: tip.bg,
            borderRadius: BorderRadius.circular(16)),
          child: Row(children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: tip.color.withOpacity(0.12),
                shape: BoxShape.circle),
              child: Icon(tip.icon, color: tip.color, size: 20)),
            const SizedBox(width: 12),
            Expanded(child: Text(tip.reason, style: GoogleFonts.inter(
              fontSize: 13, color: _kText1, height: 1.5))),
          ]),
        ),

        const SizedBox(height: 12),

        // Sources
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF8F8F8),
            borderRadius: BorderRadius.circular(16)),
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
              child: Row(children: [
                Text('LES 3 MEILLEURES SOURCES', style: GoogleFonts.inter(
                  fontSize: 9, fontWeight: FontWeight.w700,
                  color: _kMint, letterSpacing: 2.0)),
              ])),
            ...tip.sources.asMap().entries.map((entry) {
              final idx  = entry.key;
              final src  = entry.value;
              final last = idx == tip.sources.length - 1;
              return Column(children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 4, 14, 4),
                  child: Row(children: [
                    Container(
                      width: 22, height: 22,
                      decoration: BoxDecoration(
                        color: tip.color, shape: BoxShape.circle),
                      child: Center(child: Text('${idx + 1}',
                        style: GoogleFonts.inter(
                          fontSize: 10, fontWeight: FontWeight.w800,
                          color: Colors.white)))),
                    const SizedBox(width: 10),
                    Expanded(child: Text(src.food, style: GoogleFonts.inter(
                      fontSize: 13, fontWeight: FontWeight.w600, color: _kText1))),
                    Text(src.amount, style: GoogleFonts.inter(
                      fontSize: 11, color: _kText2)),
                  ])),
                if (!last)
                  Divider(height: 14, indent: 46, color: _kBorder)
                else
                  const SizedBox(height: 12),
              ]);
            }),
          ]),
        ),
      ]),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
//  W10 — SOMMEIL  (nouveau)
// ══════════════════════════════════════════════════════════════════════════════
class SleepQualityCard extends StatefulWidget {
  const SleepQualityCard({super.key});

  @override
  State<SleepQualityCard> createState() => _SleepQualityCardState();
}

class _SleepQualityCardState extends State<SleepQualityCard> {
  int _quality = -1; // 0=Mauvais, 1=Correct, 2=Bon, 3=Excellent
  double _hours = 7.0;

  static const _labels = ['Mauvais', 'Correct', 'Bon', 'Excellent'];
  static const _icons  = [LucideIcons.frown, LucideIcons.meh, LucideIcons.smile, LucideIcons.laugh];
  static const _colors = [
    Color(0xFFE24B4A), Color(0xFFC47A00),
    Color(0xFF5BAE8A), _kGreen,
  ];

  @override
  Widget build(BuildContext context) {
    return _Card(
      eyebrow: 'SOMMEIL',
      title: 'Qualité du sommeil',
      trailing: _StatusPill(
        '${_hours.toStringAsFixed(1)}h',
        _hours >= 7 ? _kGreen : const Color(0xFFC47A00),
        _hours >= 7 ? _kMintBg : const Color(0xFFFAEEDA)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        // Hours slider
        Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Flexible(child: FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft,
            child: Text(_hours.toStringAsFixed(1), style: GoogleFonts.outfit(
              fontSize: 42, fontWeight: FontWeight.w800,
              color: _kGreen, height: 1)))),
          const SizedBox(width: 6),
          Padding(
            padding: const EdgeInsets.only(bottom: 7),
            child: Text('heures', style: GoogleFonts.inter(
              fontSize: 14, color: _kText2))),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: _hours >= 7 ? _kMintBg : const Color(0xFFFAEEDA),
              borderRadius: BorderRadius.circular(20)),
            child: Text(_hours >= 8 ? 'Idéal' : _hours >= 7 ? 'Suffisant' : 'Insuffisant',
              style: GoogleFonts.inter(
                fontSize: 11, fontWeight: FontWeight.w700,
                color: _hours >= 7 ? _kGreen : const Color(0xFFB26200)))),
        ]),

        const SizedBox(height: 8),

        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: _kGreen,
            inactiveTrackColor: const Color(0xFFF0F0F0),
            thumbColor: _kGreen,
            overlayColor: _kGreen.withOpacity(0.12),
            trackHeight: 5,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10)),
          child: Slider(
            value: _hours, min: 3, max: 12, divisions: 18,
            onChanged: (v) => setState(() => _hours = v))),

        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('3h', style: GoogleFonts.inter(fontSize: 10, color: _kText2)),
          Text('Recommandé : 7–9h', style: GoogleFonts.inter(
            fontSize: 10, color: _kMint, fontWeight: FontWeight.w600)),
          Text('12h', style: GoogleFonts.inter(fontSize: 10, color: _kText2)),
        ]),

        const SizedBox(height: 18),
        Divider(height: 1, color: _kBorder),
        const SizedBox(height: 16),

        Text('QUALITÉ RESSENTIE', style: GoogleFonts.inter(
          color: _kText2, fontSize: 9, fontWeight: FontWeight.w700,
          letterSpacing: 2.5)),
        const SizedBox(height: 10),

        Row(children: List.generate(4, (i) => Expanded(
          child: GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _quality = i);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              margin: EdgeInsets.only(right: i < 3 ? 7 : 0),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: _quality == i
                    ? _colors[i].withOpacity(0.12)
                    : const Color(0xFFF4F4F4),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _quality == i ? _colors[i] : Colors.transparent,
                  width: 1.5)),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(_icons[i], size: 18,
                  color: _quality == i ? _colors[i] : _kText2),
                const SizedBox(height: 4),
                Text(_labels[i], style: GoogleFonts.inter(
                  fontSize: 9, fontWeight: FontWeight.w600,
                  color: _quality == i ? _colors[i] : _kText2)),
              ]))))),
        ),

        if (_quality >= 0) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _colors[_quality].withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _colors[_quality].withOpacity(0.2))),
            child: Row(children: [
              Icon(LucideIcons.moonStar, size: 13, color: _colors[_quality]),
              const SizedBox(width: 8),
              Expanded(child: Text(_sleepTip(_quality), style: GoogleFonts.inter(
                fontSize: 11, color: _kText1, height: 1.4))),
            ])),
        ],
      ]),
    );
  }

  String _sleepTip(int q) => switch (q) {
    0 => 'Évite la caféine après 14h et expose-toi à la lumière naturelle le matin.',
    1 => 'Essaie de te coucher et lever à heures fixes pour réguler ton rythme.',
    2 => 'Bon sommeil ! Maintiens tes habitudes et évite les écrans avant de dormir.',
    _ => 'Excellent ! Ton sommeil soutient bien ta récupération et tes hormones.',
  };
}

// ══════════════════════════════════════════════════════════════════════════════
//  W11 — MINUTES ACTIVES  (nouveau)
// ══════════════════════════════════════════════════════════════════════════════
class ActiveMinutesCard extends StatelessWidget {
  final int activeMinutes;
  final int goalMinutes;
  final int steps;
  const ActiveMinutesCard({
    super.key,
    this.activeMinutes = 34,
    this.goalMinutes   = 60,
    this.steps         = 5240,
  });

  static const _activities = [
    _Activity('Marche',     22, LucideIcons.footprints, Color(0xFF5BAE8A)),
    _Activity('Étirements', 12, LucideIcons.personStanding, Color(0xFF6B8FD4)),
  ];

  @override
  Widget build(BuildContext context) {
    final pct  = (activeMinutes / goalMinutes).clamp(0.0, 1.0);
    final left = goalMinutes - activeMinutes;

    return _Card(
      eyebrow: 'ACTIVITÉ DU JOUR',
      title: 'Minutes actives',
      trailing: _StatusPill(
        pct >= 1.0 ? 'Objectif atteint !' : '$left min restantes',
        pct >= 1.0 ? _kGreen : _kText2,
        pct >= 1.0 ? _kMintBg : const Color(0xFFF4F4F4)),
      child: Column(children: [

        Row(children: [
          // Ring
          SizedBox(
            width: 96, height: 96,
            child: Stack(alignment: Alignment.center, children: [
              SizedBox(
                width: 96, height: 96,
                child: CircularProgressIndicator(
                  value: pct, strokeWidth: 8,
                  backgroundColor: _kMint.withOpacity(0.12),
                  valueColor: const AlwaysStoppedAnimation(_kGreen),
                  strokeCap: StrokeCap.round)),
              Column(mainAxisSize: MainAxisSize.min, children: [
                Text('$activeMinutes', style: GoogleFonts.outfit(
                  fontSize: 26, fontWeight: FontWeight.w800,
                  color: _kGreen, height: 1)),
                Text('min', style: GoogleFonts.inter(
                  fontSize: 10, color: _kText2)),
              ]),
            ])),

          const SizedBox(width: 16),

          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, children: [

            // Steps
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: _kMintBg,
                borderRadius: BorderRadius.circular(12)),
              child: Row(children: [
                const Icon(LucideIcons.footprints, size: 14, color: _kGreen),
                const SizedBox(width: 8),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('$steps', style: GoogleFonts.outfit(
                    fontSize: 16, fontWeight: FontWeight.w800, color: _kGreen)),
                  Text('pas aujourd\'hui', style: GoogleFonts.inter(
                    fontSize: 10, color: _kText2)),
                ]),
              ])),

            const SizedBox(height: 8),

            // Activities
            ..._activities.map((a) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(children: [
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: a.color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(7)),
                  child: Icon(a.icon, size: 11, color: a.color)),
                const SizedBox(width: 7),
                Text(a.name, style: GoogleFonts.inter(
                  fontSize: 11, color: _kText1, fontWeight: FontWeight.w500)),
                const Spacer(),
                Text('${a.minutes} min', style: GoogleFonts.inter(
                  fontSize: 11, fontWeight: FontWeight.w700, color: a.color)),
              ]))),
          ])),
        ]),
      ]),
    );
  }
}

class _Activity {
  final String name;
  final int minutes;
  final IconData icon;
  final Color color;
  const _Activity(this.name, this.minutes, this.icon, this.color);
}

// ══════════════════════════════════════════════════════════════════════════════
//  SHARED CARD SHELL
// ══════════════════════════════════════════════════════════════════════════════
class _Card extends StatelessWidget {
  final String eyebrow;
  final String? title;
  final Widget? titleWidget;
  final Widget? trailing;
  final Widget child;

  const _Card({
    required this.eyebrow,
    this.title,
    this.titleWidget,
    this.trailing,
    required this.child,
  });

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: _kSurface,
      borderRadius: BorderRadius.circular(22),
      border: Border.all(color: _kBorder),
      boxShadow: [BoxShadow(
        color: Colors.black.withOpacity(0.04),
        blurRadius: 16, offset: const Offset(0, 4))]),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Header
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(eyebrow, style: GoogleFonts.inter(
            color: _kMint, fontSize: 9, fontWeight: FontWeight.w700,
            letterSpacing: 2.5)),
          if (titleWidget != null) ...[
            const SizedBox(height: 2),
            titleWidget!,
          ] else if (title != null) ...[
            const SizedBox(height: 2),
            Text(title!, style: GoogleFonts.outfit(
              color: _kText1, fontSize: 18, fontWeight: FontWeight.w800,
              letterSpacing: -0.3)),
          ],
        ])),
        if (trailing != null) ...[
          const SizedBox(width: 8),
          trailing!,
        ],
      ]),

      const SizedBox(height: 16),
      child,
    ]),
  );
}

// ── Small status pill ─────────────────────────────────────────────────────────
class _StatusPill extends StatelessWidget {
  final String label;
  final Color color, bg;
  const _StatusPill(this.label, this.color, this.bg);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: bg, borderRadius: BorderRadius.circular(20)),
    child: Text(label, style: GoogleFonts.inter(
      fontSize: 10, fontWeight: FontWeight.w700, color: color)));
}

// ══════════════════════════════════════════════════════════════════════════════
//  LEGACY COMPAT  (unused but kept for any existing callers)
// ══════════════════════════════════════════════════════════════════════════════
class DailyRecommendationCard extends StatelessWidget {
  final CyclePhase phase;
  final List<String> foodTags;
  const DailyRecommendationCard({
    super.key, required this.phase, required this.foodTags});

  @override
  Widget build(BuildContext context) => DailyNutrientTipCard(phase: phase);
}
