// ignore_for_file: deprecated_member_use
import 'package:fiteva/providers/user_profile_provider.dart';
import 'package:fiteva/screens/cycle/pregnancy/PregnancyInsightRepository.dart';
import 'package:fiteva/screens/cycle/pregnancy/baby-story/baby_story_screen.dart';
import 'package:fiteva/screens/cycle/pregnancy/checklist/pregnancy_checklist_screen.dart';
import 'package:fiteva/screens/cycle/pregnancy/daily_insight_model.dart';
import 'package:fiteva/screens/cycle/pregnancy/body/pregnancy_body_screen.dart';
import 'package:fiteva/screens/cycle/pregnancy/postpartum/postpartum_hub_screen.dart';
import 'package:fiteva/screens/cycle/pregnancy/symptom/symptoms_home_screen.dart';
import 'package:fiteva/widgets/custom_date_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:fiteva/screens/cycle/pregnancy/pregnancy_colors.dart';
import 'package:fiteva/widgets/shared_app_header.dart';

extension _Pg on BuildContext {
  PgColors get _p => PgColors.of(this);
}

// ─── fruit sizes ──────────────────────────────────────────────────────────────
const _fruit = <int,String>{
  1:'grain de pavot', 2:'graine de sésame', 3:'graine de sésame',
  4:'lentille', 5:'lentille', 6:'lentille', 7:'myrtille',
  8:'framboise', 9:'olive', 10:'datte', 11:'figue', 12:'prune',
  13:'pêche', 14:'citron', 15:'pomme', 16:'avocat', 17:'poire',
  18:'poivron', 19:'tomate', 20:'banane', 21:'carotte', 22:'papaye',
  23:'mangue', 24:'épi de maïs', 25:'chou-fleur', 26:'laitue romaine',
  27:'chou', 28:'aubergine', 29:'courge', 30:'chou frisé',
  31:'ananas', 32:'ananas', 33:'melon', 34:'melon cantaloup',
  35:'melon miellé', 36:'laitue iceberg', 37:'céleri',
  38:'citrouille', 39:'petite pastèque', 40:'pastèque',
  41:'pastèque', 42:'pastèque géante',
};

// ─── fitness tips ─────────────────────────────────────────────────────────────
const _fitData = <int,(String,String)>{
  1: ('Marche douce','20 à 30 min par jour. Ton corps sait ce dont il a besoin.'),
  7: ('Yoga prénatal','Soulage les nausées et maintient la souplesse.'),
  13:('Pilates prénatal','Périnée, dos, stabilité — les bases pour la suite.'),
  17:('Natation','Zéro impact. Le meilleur allié du 2e trimestre.'),
  24:('Gainage doux','Stabilité du bassin et du dos — essentielle maintenant.'),
  27:('Ballon de grossesse','Rebonds légers pour soulager le bas du dos.'),
  34:('Marche quotidienne','Prépare le corps naturellement à l\'accouchement.'),
  38:('Respiration','Cohérence cardiaque 5 min — matin et soir.'),
};
String _fitLabel(int w){final k=_fitData.keys.where((k)=>k<=w).fold(1,(p,k)=>k>p?k:p);return _fitData[k]!.$1;}
String _fitTip(int w){final k=_fitData.keys.where((k)=>k<=w).fold(1,(p,k)=>k>p?k:p);return _fitData[k]!.$2;}

// ─────────────────────────────────────────────────────────────────────────────
class PregnancyHubScreen extends ConsumerStatefulWidget {
  const PregnancyHubScreen({super.key});
  @override
  ConsumerState<PregnancyHubScreen> createState() => _PregnancyHubScreenState();
}

class _PregnancyHubScreenState extends ConsumerState<PregnancyHubScreen>
    with SingleTickerProviderStateMixin {
  int? _mood;
  bool _switching = false;

  late final AnimationController _switchAnim = AnimationController(
    vsync: this, duration: const Duration(milliseconds: 600));
  late final Animation<double> _fadeOut =
      Tween<double>(begin: 1, end: 0).animate(
          CurvedAnimation(parent: _switchAnim, curve: Curves.easeInCubic));
  late final Animation<double> _scaleOut =
      Tween<double>(begin: 1, end: 0.92).animate(
          CurvedAnimation(parent: _switchAnim, curve: Curves.easeInCubic));

  static const _months = ['janv.','fevr.','mars','avr.','mai','juin',
    'juil.','aout','sept.','oct.','nov.','dec.'];

  @override
  void dispose() {
    _switchAnim.dispose();
    super.dispose();
  }

  Future<void> _switchToCycle() async {
    // Confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Quitter le suivi grossesse ?',
          style: GoogleFonts.outfit(fontSize: 17, fontWeight: FontWeight.w700,
              color: const Color(0xFF1A2E20))),
        content: Text(
          'Votre application passera en mode Cycle menstruel. '
          'Vos donnees de grossesse seront conservees.',
          style: GoogleFonts.inter(fontSize: 13, height: 1.55,
              color: const Color(0xFF5A7A65))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Annuler',
              style: GoogleFonts.inter(color: const Color(0xFF888888)))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1C4D30),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Confirmer',
              style: GoogleFonts.inter(fontWeight: FontWeight.w700))),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    // Animate out
    setState(() => _switching = true);
    await _switchAnim.forward();

    if (!mounted) return;

    // Save profile
    final notifier = ref.read(userProfileProvider.notifier);
    await notifier.updateField('health_status', 'cycle');
    await notifier.updateField('pregnancy_week', null);
  }

  Future<void> _switchToPostpartum() async {
    // Calendrier date d'accouchement
    final birthDate = await showCustomDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 730)),
      lastDate: DateTime.now(),
      title: 'Date d\'accouchement',
      subtitle: 'Quand est ne votre bebe ?',
      icon: Icons.child_care_rounded,
      accentColor: const Color(0xFF1C4D30),
    );

    if (birthDate == null || !mounted) return;

    // Calcul semaines depuis l'accouchement
    final weeks = DateTime.now().difference(birthDate).inDays ~/ 7;
    final String ppDuration;
    if (weeks < 2)       ppDuration = '0-2';
    else if (weeks < 6)  ppDuration = '2-6';
    else if (weeks < 12) ppDuration = '6-12';
    else if (weeks < 26) ppDuration = '3-6m';
    else                 ppDuration = '6m+';

    // Confirmation
    if (!mounted) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Passer en mode Post-partum ?',
          style: GoogleFonts.outfit(fontSize: 17, fontWeight: FontWeight.w700,
              color: const Color(0xFF1A2E20))),
        content: Text(
          'Accouchement le ${birthDate.day}/${birthDate.month}/${birthDate.year} '
          '($weeks semaines). Votre suivi passera en mode post-partum.',
          style: GoogleFonts.inter(fontSize: 13, height: 1.55,
              color: const Color(0xFF5A7A65))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Annuler',
              style: GoogleFonts.inter(color: const Color(0xFF888888)))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1C4D30),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Confirmer',
              style: GoogleFonts.inter(fontWeight: FontWeight.w700))),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    // Animation + sauvegarde
    setState(() => _switching = true);
    await _switchAnim.forward();
    if (!mounted) return;

    final notifier = ref.read(userProfileProvider.notifier);
    await notifier.updateField('health_status', 'postpartum');
    await notifier.updateField('pp_duration', ppDuration);
    await notifier.updateField('pregnancy_week', null);
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(userProfileProvider);
    final week    = (profile.pregnancyWeekSA ?? 1).clamp(1, 42);
    final insight = PregnancyInsightRepository.forWeek(week);
    final due     = DateTime.now().add(Duration(days: (42 - week) * 7));
    final left    = due.difference(DateTime.now()).inDays.clamp(0, 300);
    final fmtDue  = '${due.day} ${_months[due.month - 1]} ${due.year}';
    final tri     = week <= 13 ? '1er trimestre'
        : week <= 26 ? '2e trimestre' : '3e trimestre';

    return Scaffold(
      backgroundColor: context._p.bg,
      body: AnimatedBuilder(
        animation: _switchAnim,
        builder: (context, child) => FadeTransition(
          opacity: _fadeOut,
          child: ScaleTransition(scale: _scaleOut, child: child),
        ),
        child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [

          SharedAppHeader.sliver(
            eyebrow: 'GROSSESSE',
            title: 'Ma grossesse',
            accentColor: context._p.green,
            bgColor: Colors.white,
            actions: [
              PopupMenuButton<String>(
                enabled: !_switching,
                onSelected: (v) {
                  if (v == 'cycle')      _switchToCycle();
                  if (v == 'postpartum') _switchToPostpartum();
                },
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                elevation: 4,
                color: Colors.white,
                offset: const Offset(0, 44),
                itemBuilder: (_) => [
                  PopupMenuItem(
                    value: 'postpartum',
                    child: Row(children: [
                      const Text('👶', style: TextStyle(fontSize: 16)),
                      const SizedBox(width: 10),
                      Text('Post-partum', style: GoogleFonts.inter(
                        fontSize: 13, fontWeight: FontWeight.w600,
                        color: const Color(0xFF1A2E20))),
                    ]),
                  ),
                  PopupMenuItem(
                    value: 'cycle',
                    child: Row(children: [
                      const Icon(Icons.water_drop_rounded,
                          size: 16, color: Color(0xFFD94F6B)),
                      const SizedBox(width: 10),
                      Text('Mon cycle', style: GoogleFonts.inter(
                        fontSize: 13, fontWeight: FontWeight.w600,
                        color: const Color(0xFFD94F6B))),
                    ]),
                  ),
                ],
                child: Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: context._p.mintLight,
                    shape: BoxShape.circle,
                    border: Border.all(color: context._p.border),
                  ),
                  child: Icon(Icons.more_horiz_rounded,
                      size: 18, color: context._p.green),
                ),
              ),
            ],
          ),

          SliverToBoxAdapter(child: Column(children: [

          // ══ HERO CARD ════════════════════════════════════════════════
          _HeroCard(
            week: week, tri: tri,
            left: left, fmtDue: fmtDue,
            fruit: _fruit[week] ?? 'fruit',
          ),

          const SizedBox(height: 16),

          // ══ MOOD CHECK-IN ════════════════════════════════════════════
          _pad(_MoodCard(selected: _mood, onSelect: (i) {
            HapticFeedback.lightImpact();
            setState(() => _mood = i);
          })),

          // ══ MOOD RESPONSE ════════════════════════════════════════════
          AnimatedSize(
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOutCubic,
            child: _mood == null
                ? const SizedBox.shrink()
                : Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: _MoodResponseCard(mood: _mood!, week: week),
                  ),
          ),

          const SizedBox(height: 12),

          // ══ CETTE SEMAINE ════════════════════════════════════════════
          _pad(_WeekCard(insight: insight)),

          const SizedBox(height: 12),

          // ══ FORME & MOUVEMENT ════════════════════════════════════════
          _pad(_FitCard(week: week)),

          const SizedBox(height: 12),

          // ══ NAVIGATION ═══════════════════════════════════════════════
          _pad(_NavCard(week: week, context: context)),

          // ══ BORN ═════════════════════════════════════════════════════
          if (week >= 37) ...[
            const SizedBox(height: 12),
            _pad(_BornCard(context: context)),
          ],

          SizedBox(height: MediaQuery.of(context).padding.bottom + 90),
        ])),
        ],
      ),
      ),  // AnimatedBuilder child
    );
  }

  Widget _pad(Widget w) =>
      Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: w);
}

// ─────────────────────────────────────────────────────────────────────────────
//  HERO CARD
// ─────────────────────────────────────────────────────────────────────────────

class _HeroCard extends StatelessWidget {
  final int week, left;
  final String tri, fmtDue, fruit;

  const _HeroCard({
    required this.week, required this.tri,
    required this.left, required this.fmtDue, required this.fruit,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (week / 42).clamp(0.0, 1.0);

    return Column(children: [

      // ── image — complètement libre, aucun container ──────────────────────
      AnimatedSwitcher(
        duration: const Duration(milliseconds: 450),
        transitionBuilder: (c, a) => FadeTransition(opacity: a, child: c),
        child: _FetusPic(key: ValueKey(week), week: week),
      ),

      // ── info card — commence après l'image ──────────────────────────────
      Container(
        decoration: BoxDecoration(
          color: context._p.surface,
          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
          boxShadow: [BoxShadow(
            color: Color(0x0A1C4D30), blurRadius: 20, offset: Offset(0, 8))],
        ),
        child: Column(children: [
          const SizedBox(height: 16),

          // semaine
          Text(tri.toUpperCase(), style: GoogleFonts.inter(
            fontSize: 9, fontWeight: FontWeight.w500,
            color: context._p.textSoft, letterSpacing: 2.5)),
          const SizedBox(height: 2),
          Row(mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text('Semaine ', style: GoogleFonts.inter(
                  fontSize: 18, fontWeight: FontWeight.w400, color: context._p.textMid)),
                Text('$week', style: GoogleFonts.outfit(
                  fontSize: 48, fontWeight: FontWeight.w600,
                  color: context._p.green, height: 1.1)),
              ]),

          const SizedBox(height: 6),
          Text('Taille d\'une $fruit',
              style: GoogleFonts.inter(
                  fontSize: 13, color: context._p.textSoft)),

          const SizedBox(height: 24),

          // progress + jours
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('$left jours restants', style: GoogleFonts.inter(
                  fontSize: 12, color: context._p.textSoft)),
                Text('S42', style: GoogleFonts.inter(
                  fontSize: 12, color: context._p.textSoft)),
              ]),
              const SizedBox(height: 6),
              ClipRRect(borderRadius: BorderRadius.circular(4),
                child: Stack(children: [
                  Container(height: 6, color: context._p.mintLight),
                  FractionallySizedBox(
                    widthFactor: progress,
                    child: Container(height: 6,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        gradient: LinearGradient(
                          colors: [context._p.mint, context._p.green]),
                      )),
                  ),
                ]),
              ),
            ]),
          ),

          const SizedBox(height: 28),
        ]),
      ),
    ]);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  MOOD CARD — la touche chaleureuse unique FitEva
// ─────────────────────────────────────────────────────────────────────────────

class _MoodCard extends StatelessWidget {
  final int? selected;
  final void Function(int) onSelect;
  const _MoodCard({required this.selected, required this.onSelect});

  static const _moods = [
    ('Bien', Icons.sentiment_satisfied_alt_outlined),
    ('Fatiguée', Icons.sentiment_neutral_outlined),
    ('Joyeuse', Icons.sentiment_very_satisfied_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _card(context),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Comment tu te sens aujourd\'hui ?',
            style: GoogleFonts.inter(
                fontSize: 14, fontWeight: FontWeight.w600, color: context._p.textDark)),
        const SizedBox(height: 14),
        Row(children: List.generate(_moods.length, (i) {
          final sel = selected == i;
          return Expanded(child: GestureDetector(
            onTap: () => onSelect(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.only(right: i < 2 ? 8 : 0),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: sel ? context._p.mintLight : context._p.bg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: sel ? context._p.mint : Colors.transparent, width: 1.5),
              ),
              child: Column(children: [
                Icon(_moods[i].$2,
                  size: 24,
                  color: sel ? context._p.green : context._p.textSoft),
                const SizedBox(height: 6),
                Text(_moods[i].$1, style: GoogleFonts.inter(
                  fontSize: 11, fontWeight: FontWeight.w500,
                  color: sel ? context._p.green : context._p.textSoft)),
              ]),
            ),
          ));
        })),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  MOOD RESPONSE CARD
// ─────────────────────────────────────────────────────────────────────────────

class _MoodResponseCard extends StatefulWidget {
  final int mood;
  final int week;
  const _MoodResponseCard({required this.mood, required this.week});

  @override
  State<_MoodResponseCard> createState() => _MoodResponseCardState();
}

class _MoodResponseCardState extends State<_MoodResponseCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 420));
    _fade  = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _ctrl.forward();
  }

  @override
  void didUpdateWidget(_MoodResponseCard old) {
    super.didUpdateWidget(old);
    if (old.mood != widget.mood) {
      _ctrl.forward(from: 0);
    }
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  // ── contenu selon mood + semaine ──────────────────────────────────────────


  static const _moodIcons = [
    Icons.spa_outlined,
    Icons.bedtime_outlined,
    Icons.wb_sunny_outlined,
  ];

  (String, String) _content() {
    final tri = widget.week <= 13 ? 1 : widget.week <= 26 ? 2 : 3;
    switch (widget.mood) {
      case 0: // Bien
        if (tri == 1) return (
          'Tu traverses le premier trimestre avec sérénité — c\'est précieux.',
          'Profite de cette énergie pour une marche de 20 min aujourd\'hui.',
        );
        if (tri == 2) return (
          'Le beau trimestre te va bien. Ton corps et ton bébé sont en harmonie.',
          'C\'est le bon moment pour inscrire un cours de yoga prénatal.',
        );
        return (
          'Être en forme à la semaine ${widget.week}, c\'est une vraie force.',
          'Une marche douce le matin prépare ton corps naturellement.',
        );

      case 1: // Fatiguée
        if (tri == 1) return (
          'La fatigue du 1er trimestre est l\'une des plus intenses — ton corps construit tout.',
          'Accorde-toi une sieste aujourd\'hui. C\'est du soin, pas de la paresse.',
        );
        if (tri == 2) return (
          'Une fatigue au 2e trimestre peut signaler une croissance rapide de bébé.',
          'Vérifie ton apport en fer et en protéines — et dors dès que tu peux.',
        );
        return (
          'À la semaine ${widget.week}, la fatigue est le signal que ton corps se prépare.',
          'Surélève les pieds 20 min ce soir et laisse quelqu\'un t\'aider aujourd\'hui.',
        );

      default: // Joyeuse
        if (tri == 1) return (
          'Cette joie est un beau cadeau — savoure chaque instant de ce début.',
          'Note ce moment dans un journal de grossesse. Tu seras heureuse de le relire.',
        );
        if (tri == 2) return (
          'Ta joie rayonne — bébé la perçoit vraiment. Les émotions traversent le placenta.',
          'Mets de la musique que tu aimes et danse doucement avec bébé.',
        );
        return (
          'Cette joie à l\'approche du grand jour est la plus belle des préparations.',
          'Partage ce moment avec quelqu\'un que tu aimes — ce souvenir est précieux.',
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final (accent, bg, textAccent) = switch (widget.mood) {
      0 => (context._p.mint, context._p.mintLight, context._p.green),
      1 => (context._p.warmPink, context._p.pinkSoft, const Color.fromARGB(255, 87, 134, 184)),
      _ => (const Color(0xFFF4A940), const Color(0xFFFDF5E6), const Color(0xFFB87A20)),
    };
    final (message, tip) = _content();

    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: accent.withOpacity(0.3), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(
                    color: accent.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(10)),
                  child: Icon(_moodIcons[widget.mood],
                      size: 16, color: textAccent),
                ),
                const SizedBox(width: 10),
                Text('Pour toi aujourd\'hui', style: GoogleFonts.inter(
                  fontSize: 10, fontWeight: FontWeight.w600,
                  color: textAccent, letterSpacing: 1.3)),
              ]),
              const SizedBox(height: 12),
              Text(message, style: GoogleFonts.outfit(
                fontSize: 14, height: 1.65,
                color: context._p.textDark, fontStyle: FontStyle.italic)),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.65),
                  borderRadius: BorderRadius.circular(12)),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.lightbulb_outline_rounded,
                        size: 14, color: textAccent),
                    const SizedBox(width: 8),
                    Expanded(child: Text(tip, style: GoogleFonts.inter(
                      fontSize: 12, color: context._p.textMid,
                      height: 1.55, fontWeight: FontWeight.w500))),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  WEEK CARD — insights bébé + maman
// ─────────────────────────────────────────────────────────────────────────────

class _WeekCard extends StatelessWidget {
  final DailyInsight insight;
  const _WeekCard({required this.insight});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _card(context),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _cardTitle('Cette semaine', context),
        const SizedBox(height: 16),

        // bébé
        _InsightRow(
          label: 'Votre bébé',
          text: insight.babyInsight,
          bg: context._p.mintLight,
          labelColor: context._p.green,
        ),
        const SizedBox(height: 10),

        // maman
        _InsightRow(
          label: 'Pour vous',
          text: insight.momTip,
          bg: context._p.pinkSoft,
          labelColor: context._p.warmPink,
        ),

        if (insight.poeticLine.isNotEmpty) ...[
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: context._p.bg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text('"${insight.poeticLine}"',
                style: GoogleFonts.outfit(
                  fontSize: 13, fontStyle: FontStyle.italic,
                  color: context._p.textMid, height: 1.7),
                textAlign: TextAlign.center),
          ),
        ],
      ]),
    );
  }
}

class _InsightRow extends StatelessWidget {
  final String label, text;
  final Color bg, labelColor;
  const _InsightRow({
    required this.label, required this.text,
    required this.bg, required this.labelColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bg, borderRadius: BorderRadius.circular(14)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label.toUpperCase(), style: GoogleFonts.inter(
          fontSize: 9, fontWeight: FontWeight.w600,
          color: labelColor, letterSpacing: 1.8)),
        const SizedBox(height: 7),
        Text(text, style: GoogleFonts.inter(
          fontSize: 13, color: context._p.textDark, height: 1.6)),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  FITNESS CARD
// ─────────────────────────────────────────────────────────────────────────────

class _FitCard extends StatelessWidget {
  final int week;
  const _FitCard({required this.week});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _card(context),
      child: Row(children: [
        Container(
          width: 48, height: 48,
          decoration: BoxDecoration(
            color: context._p.mintLight, borderRadius: BorderRadius.circular(14)),
          child: Icon(Icons.self_improvement_outlined,
              size: 22, color: context._p.green),
        ),
        const SizedBox(width: 16),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Forme & mouvement', style: GoogleFonts.inter(
              fontSize: 9, fontWeight: FontWeight.w600,
              color: context._p.textSoft, letterSpacing: 1.8)),
            const SizedBox(height: 4),
            Text(_fitLabel(week), style: GoogleFonts.inter(
              fontSize: 14, fontWeight: FontWeight.w600, color: context._p.textDark)),
            const SizedBox(height: 3),
            Text(_fitTip(week), style: GoogleFonts.inter(
              fontSize: 12, color: context._p.textMid, height: 1.5)),
          ],
        )),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  NAV CARD
// ─────────────────────────────────────────────────────────────────────────────

class _NavCard extends StatelessWidget {
  final int week;
  final BuildContext context;
  const _NavCard({required this.week, required this.context});

  @override
  Widget build(BuildContext ctx) {
    Route fade(Widget p) => PageRouteBuilder(
      pageBuilder: (_, a, __) => p,
      transitionsBuilder: (_, a, __, c) => FadeTransition(
          opacity: CurvedAnimation(parent: a, curve: Curves.easeInOut),
          child: c),
      transitionDuration: const Duration(milliseconds: 280),
    );

    final items = [
      (Icons.favorite_border_rounded, 'Symptômes',
          'Journaliser aujourd\'hui', () {
        HapticFeedback.lightImpact();
        Navigator.push(context, fade(SymptomsHomeScreen(currentWeek: week)));
      }),
      (Icons.child_care_outlined, 'Votre bébé',
          'Développement — semaine $week', () {
        HapticFeedback.lightImpact();
        Navigator.push(context, fade(BabyStoryScreen(currentWeek: week)));
      }),
      (Icons.self_improvement_outlined, 'Votre corps',
          'Évolutions physiques', () {
        HapticFeedback.lightImpact();
        Navigator.push(context, fade(PregnancyBodyScreen(currentWeek: week)));
      }),
      (Icons.check_circle_outline_rounded, 'Ma checklist',
          'Préparatifs & rendez-vous', () {
        HapticFeedback.lightImpact();
        Navigator.push(context,
            fade(PregnancyChecklistScreen(currentWeek: week)));
      }),
    ];

    return Container(
      decoration: _card(ctx),
      child: Column(children: List.generate(items.length, (i) {
        final item = items[i];
        return Column(children: [
          GestureDetector(
            onTap: item.$4,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
              child: Row(children: [
                Container(
                  width: 38, height: 38,
                  decoration: BoxDecoration(
                    color: ctx._p.mintLight,
                    borderRadius: BorderRadius.circular(11)),
                  child: Icon(item.$1, size: 18, color: ctx._p.green),
                ),
                const SizedBox(width: 14),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.$2, style: GoogleFonts.inter(
                      fontSize: 14, fontWeight: FontWeight.w600,
                      color: ctx._p.textDark)),
                    Text(item.$3, style: GoogleFonts.inter(
                      fontSize: 12, color: ctx._p.textSoft)),
                  ],
                )),
                Icon(Icons.chevron_right_rounded,
                    size: 18, color: ctx._p.textSoft),
              ]),
            ),
          ),
          if (i < items.length - 1)
            Divider(height: 1, indent: 72, endIndent: 20,
                color: ctx._p.mintLight),
        ]);
      })),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  BORN CARD
// ─────────────────────────────────────────────────────────────────────────────

class _BornCard extends StatelessWidget {
  final BuildContext context;
  const _BornCard({required this.context});

  @override
  Widget build(BuildContext ctx) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        Navigator.push(context, PageRouteBuilder(
          pageBuilder: (_, a, __) =>
              PostpartumHubScreen(birthDate: DateTime.now()),
          transitionsBuilder: (_, a, __, c) => FadeTransition(
              opacity: CurvedAnimation(parent: a, curve: Curves.easeInOut),
              child: c),
          transitionDuration: const Duration(milliseconds: 280),
        ));
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [ctx._p.green, const Color(0xFF2E6B45)],
            begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(children: [
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Mon bébé est né', style: GoogleFonts.outfit(
                fontSize: 16, fontWeight: FontWeight.w600,
                color: Colors.white)),
              const SizedBox(height: 3),
              Text('Passer au suivi post-partum',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.65))),
            ],
          )),
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              shape: BoxShape.circle),
            child: const Icon(Icons.arrow_forward_rounded,
                size: 18, color: Colors.white),
          ),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  HELPERS
// ─────────────────────────────────────────────────────────────────────────────

BoxDecoration _card(BuildContext context) => BoxDecoration(
  color: context._p.surface,
  borderRadius: BorderRadius.circular(20),
  boxShadow: const [BoxShadow(
    color: Color(0x081C4D30), blurRadius: 16, offset: Offset(0, 4))],
);

Widget _cardTitle(String t, BuildContext context) => Text(t, style: GoogleFonts.outfit(
  fontSize: 16, fontWeight: FontWeight.w600, color: context._p.textDark));

// ─────────────────────────────────────────────────────────────────────────────
//  FETUS PICTURE
// ─────────────────────────────────────────────────────────────────────────────

class _FetusPic extends StatelessWidget {
  final int week;
  const _FetusPic({super.key, required this.week});

  @override
  Widget build(BuildContext context) => Image.asset(
    'assets/fetus/week_$week.png',
    width: double.infinity,
    fit: BoxFit.fitWidth,
    errorBuilder: (_, __, ___) => _FetusPlaceholder(week: week),
  );
}

class _FetusPlaceholder extends StatelessWidget {
  final int week;
  const _FetusPlaceholder({required this.week});

  @override
  Widget build(BuildContext context) {
    final r = (10.0 + (week - 1) * (44.0 / 41.0)).clamp(10.0, 54.0);
    return Container(
      width: 168, height: 168, color: context._p.mintLight,
      child: Center(child: Container(
        width: r * 2, height: r * 2.4,
        decoration: BoxDecoration(
          border: Border.all(color: context._p.mint.withOpacity(0.4), width: 1.5),
          borderRadius: BorderRadius.circular(r),
        ),
      )),
    );
  }
}
