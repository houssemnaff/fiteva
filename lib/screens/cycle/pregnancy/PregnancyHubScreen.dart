// ignore_for_file: deprecated_member_use
import 'package:fiteva/providers/user_profile_provider.dart';
import 'package:fiteva/screens/cycle/pregnancy/PregnancyInsightRepository.dart';
import 'package:fiteva/screens/cycle/pregnancy/baby-story/baby_story_screen.dart';
import 'package:fiteva/screens/cycle/pregnancy/checklist/pregnancy_checklist_screen.dart';
import 'package:fiteva/screens/cycle/pregnancy/body/pregnancy_body_screen.dart';
import 'package:fiteva/screens/cycle/pregnancy/postpartum/postpartum_hub_screen.dart';
import 'package:fiteva/screens/cycle/pregnancy/symptom/symptoms_home_screen.dart';
import 'package:fiteva/widgets/custom_date_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

// ── Palette ───────────────────────────────────────────────────────────────────
const _rose      = Color(0xFFF2A8B8);
const _roseDark  = Color(0xFFD4607A);
const _roseSoft  = Color(0xFFFFF0F3);
const _sage      = Color(0xFF7ABB98);
const _sageDark  = Color(0xFF1C4D30);
const _sageSoft  = Color(0xFFEAF5EE);
const _cream     = Color(0xFFFDFAF7);
const _peach     = Color(0xFFFFF3EC);
const _warmText  = Color(0xFF2D1F1A);
const _mutedText = Color(0xFF9A857D);
const _gold      = Color(0xFFF4A940);

// ── Fruit sizes ───────────────────────────────────────────────────────────────
const _fruit = <int, String>{
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

const _fruitEmoji = <int, String>{
  1:'🌱', 2:'🌿', 3:'🌿', 4:'🫘', 5:'🫘', 6:'🫘', 7:'🫐',
  8:'🍇', 9:'🫒', 10:'🍑', 11:'🍈', 12:'🍑', 13:'🍑', 14:'🍋',
  15:'🍎', 16:'🥑', 17:'🍐', 18:'🫑', 19:'🍅', 20:'🍌',
  21:'🥕', 22:'🥭', 23:'🥭', 24:'🌽', 25:'🥦', 26:'🥬',
  27:'🥬', 28:'🍆', 29:'🎃', 30:'🥬', 31:'🍍', 32:'🍍',
  33:'🍈', 34:'🍈', 35:'🍈', 36:'🥬', 37:'🌿', 38:'🎃',
  39:'🍉', 40:'🍉', 41:'🍉', 42:'🍉',
};

// ── Fitness tips ──────────────────────────────────────────────────────────────
const _fitData = <int, (String, String)>{
  1:  ('Marche douce',        '20 à 30 min par jour, ton corps sait ce dont il a besoin.'),
  7:  ('Yoga prénatal',       'Soulage les nausées et maintient la souplesse.'),
  13: ('Pilates prénatal',    'Périnée, dos, stabilité — les bases pour la suite.'),
  17: ('Natation',            'Zéro impact. Le meilleur allié du 2e trimestre.'),
  24: ('Gainage doux',        'Stabilité du bassin et du dos — essentielle maintenant.'),
  27: ('Ballon de grossesse', 'Rebonds légers pour soulager le bas du dos.'),
  34: ('Marche quotidienne',  "Prépare le corps naturellement à l'accouchement."),
  38: ('Respiration',         'Cohérence cardiaque 5 min — matin et soir.'),
};
String _fitLabel(int w) {
  final k = _fitData.keys.where((k) => k <= w).fold(1, (p, k) => k > p ? k : p);
  return _fitData[k]!.$1;
}
String _fitTip(int w) {
  final k = _fitData.keys.where((k) => k <= w).fold(1, (p, k) => k > p ? k : p);
  return _fitData[k]!.$2;
}

const _months = ['janv.','févr.','mars','avr.','mai','juin',
  'juil.','août','sept.','oct.','nov.','déc.'];

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
      Tween<double>(begin: 1, end: 0.94).animate(
          CurvedAnimation(parent: _switchAnim, curve: Curves.easeInCubic));

  @override
  void dispose() { _switchAnim.dispose(); super.dispose(); }

  Future<void> _switchToCycle() async {
    final confirm = await _confirmDialog(
      'Quitter le suivi grossesse ?',
      'Votre application passera en mode Cycle menstruel. Vos données de grossesse seront conservées.',
    );
    if (confirm != true || !mounted) return;
    setState(() => _switching = true);
    await _switchAnim.forward();
    if (!mounted) return;
    final n = ref.read(userProfileProvider.notifier);
    await n.updateField('health_status', 'cycle');
    await n.updateField('pregnancy_week', null);
  }

  Future<void> _switchToPostpartum() async {
    final birthDate = await showCustomDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 730)),
      lastDate: DateTime.now(),
      title: "Date d'accouchement",
      subtitle: 'Quand est né votre bébé ?',
      icon: Icons.child_care_rounded,
      accentColor: _sageDark,
    );
    if (birthDate == null || !mounted) return;
    final weeks = DateTime.now().difference(birthDate).inDays ~/ 7;
    final ppDuration = weeks < 2 ? '0-2' : weeks < 6 ? '2-6'
        : weeks < 12 ? '6-12' : weeks < 26 ? '3-6m' : '6m+';
    final confirm = await _confirmDialog(
      'Passer en mode Post-partum ?',
      'Accouchement le ${birthDate.day}/${birthDate.month}/${birthDate.year} ($weeks semaines). Votre suivi passera en mode post-partum.',
    );
    if (confirm != true || !mounted) return;
    setState(() => _switching = true);
    await _switchAnim.forward();
    if (!mounted) return;
    final n = ref.read(userProfileProvider.notifier);
    await n.updateField('health_status', 'postpartum');
    await n.updateField('pp_duration', ppDuration);
    await n.updateField('pregnancy_week', null);
  }

  Future<bool?> _confirmDialog(String title, String body) => showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: _cream,
      title: Text(title, style: GoogleFonts.outfit(
        fontSize: 17, fontWeight: FontWeight.w700, color: _warmText)),
      content: Text(body, style: GoogleFonts.inter(
        fontSize: 13, height: 1.6, color: _mutedText)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text('Annuler', style: GoogleFonts.inter(color: _mutedText))),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: _sageDark, foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10)),
          onPressed: () => Navigator.pop(ctx, true),
          child: Text('Confirmer', style: GoogleFonts.inter(fontWeight: FontWeight.w700))),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(userProfileProvider);
    final week    = (profile.pregnancyWeekSA ?? 1).clamp(1, 42);
    final insight = PregnancyInsightRepository.forWeek(week);
    final due     = DateTime.now().add(Duration(days: (42 - week) * 7));
    final left    = due.difference(DateTime.now()).inDays.clamp(0, 300);
    final fmtDue  = '${due.day} ${_months[due.month - 1]} ${due.year}';
    final tri     = week <= 13 ? 1 : week <= 26 ? 2 : 3;
    final triLabel = tri == 1 ? '1er trimestre' : tri == 2 ? '2e trimestre' : '3e trimestre';

    return Scaffold(
      backgroundColor: _cream,
      body: AnimatedBuilder(
        animation: _switchAnim,
        builder: (_, child) => FadeTransition(
          opacity: _fadeOut,
          child: ScaleTransition(scale: _scaleOut, child: child),
        ),
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [

            // ── Header ──────────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: _AppBar(
                switching: _switching,
                onCycle: _switchToCycle,
                onPostpartum: _switchToPostpartum,
              ),
            ),

            SliverToBoxAdapter(child: Column(children: [

              // ── Hero ────────────────────────────────────────────────────
              _HeroSection(
                week: week, tri: tri, triLabel: triLabel,
                left: left, fmtDue: fmtDue,
                fruit: _fruit[week] ?? 'fruit',
                emoji: _fruitEmoji[week] ?? '🌱',
              ),

              const SizedBox(height: 20),

              // ── Trimester strip ────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _TrimesterStrip(week: week),
              ),

              const SizedBox(height: 20),

              // ── Mood check-in ──────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _MoodCard(selected: _mood, onSelect: (i) {
                  HapticFeedback.lightImpact();
                  setState(() => _mood = i);
                }),
              ),

              // ── Mood response ──────────────────────────────────────────
              AnimatedSize(
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeOutCubic,
                child: _mood == null
                    ? const SizedBox.shrink()
                    : Padding(
                        padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                        child: _MoodResponseCard(mood: _mood!, week: week),
                      ),
              ),

              const SizedBox(height: 20),

              // ── Week insight ───────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _WeekInsightCard(insight: insight),
              ),

              const SizedBox(height: 16),

              // ── Fitness tip ────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _FitCard(week: week),
              ),

              const SizedBox(height: 20),

              // ── Nav grid ───────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _NavGrid(week: week, ctx: context),
              ),

              // ── Born CTA (week 37+) ────────────────────────────────────
              if (week >= 37) ...[
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _BornCard(ctx: context),
                ),
              ],

              SizedBox(height: MediaQuery.of(context).padding.bottom + 100),
            ])),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  APP BAR
// ─────────────────────────────────────────────────────────────────────────────
class _AppBar extends StatelessWidget {
  final bool switching;
  final VoidCallback onCycle, onPostpartum;
  const _AppBar({required this.switching, required this.onCycle, required this.onPostpartum});

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return Container(
      color: _cream,
      padding: EdgeInsets.fromLTRB(20, top + 12, 16, 12),
      child: Row(children: [
        if (Navigator.canPop(context))
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 8, offset: const Offset(0, 2))]),
              child: const Icon(Icons.arrow_back_ios_new_rounded, size: 14, color: _warmText),
            ),
          ),
        const SizedBox(width: 12),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('MA GROSSESSE', style: GoogleFonts.inter(
            fontSize: 9, fontWeight: FontWeight.w700,
            color: _rose, letterSpacing: 2.5)),
          Text('Suivi prénatal', style: GoogleFonts.outfit(
            fontSize: 20, fontWeight: FontWeight.w700, color: _warmText)),
        ]),
        const Spacer(),
        PopupMenuButton<String>(
          enabled: !switching,
          onSelected: (v) {
            if (v == 'cycle') onCycle();
            if (v == 'postpartum') onPostpartum();
          },
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 6,
          color: Colors.white,
          offset: const Offset(0, 48),
          itemBuilder: (_) => [
            PopupMenuItem(
              value: 'postpartum',
              child: Row(children: [
                const Text('👶', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 10),
                Text('Post-partum', style: GoogleFonts.inter(
                  fontSize: 13, fontWeight: FontWeight.w600, color: _warmText)),
              ]),
            ),
            PopupMenuItem(
              value: 'cycle',
              child: Row(children: [
                const Icon(Icons.water_drop_rounded, size: 16, color: _roseDark),
                const SizedBox(width: 10),
                Text('Mon cycle', style: GoogleFonts.inter(
                  fontSize: 13, fontWeight: FontWeight.w600, color: _roseDark)),
              ]),
            ),
          ],
          child: Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(
                color: Colors.black.withOpacity(0.07),
                blurRadius: 8, offset: const Offset(0, 2))]),
            child: const Icon(Icons.more_horiz_rounded, size: 18, color: _warmText),
          ),
        ),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  HERO SECTION
// ─────────────────────────────────────────────────────────────────────────────
class _HeroSection extends StatefulWidget {
  final int week, tri, left;
  final String triLabel, fmtDue, fruit, emoji;
  const _HeroSection({
    required this.week, required this.tri, required this.triLabel,
    required this.left, required this.fmtDue, required this.fruit, required this.emoji,
  });
  @override
  State<_HeroSection> createState() => _HeroSectionState();
}

class _HeroSectionState extends State<_HeroSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulse;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 2400))
      ..repeat(reverse: true);
    _scale = Tween(begin: 0.96, end: 1.04)
        .animate(CurvedAnimation(parent: _pulse, curve: Curves.easeInOut));
  }

  @override
  void dispose() { _pulse.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final progress = (widget.week / 42).clamp(0.0, 1.0);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFF5F7), Color(0xFFF0F9F4)],
        ),
        boxShadow: [
          BoxShadow(
            color: _rose.withOpacity(0.18),
            blurRadius: 28, offset: const Offset(0, 8)),
        ],
        border: Border.all(color: _rose.withOpacity(0.18), width: 1),
      ),
      child: Column(children: [

        // ── Top row: week + emoji ─────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Week number
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(widget.triLabel.toUpperCase(), style: GoogleFonts.inter(
                  fontSize: 9, fontWeight: FontWeight.w700,
                  color: _roseDark.withOpacity(0.6), letterSpacing: 2)),
                const SizedBox(height: 2),
                Row(crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text('S', style: GoogleFonts.outfit(
                        fontSize: 28, fontWeight: FontWeight.w300, color: _mutedText)),
                      Text('${widget.week}', style: GoogleFonts.outfit(
                        fontSize: 72, fontWeight: FontWeight.w800,
                        color: _roseDark, height: 0.9)),
                    ]),
                const SizedBox(height: 4),
                Text('comme une ${widget.fruit}', style: GoogleFonts.inter(
                  fontSize: 12, color: _mutedText)),
              ]),

              const Spacer(),

              // Fruit emoji orb
              ScaleTransition(
                scale: _scale,
                child: Container(
                  width: 110, height: 110,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        _rose.withOpacity(0.4),
                        _roseSoft,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _rose.withOpacity(0.3),
                        blurRadius: 24, spreadRadius: 4),
                    ],
                  ),
                  child: Center(
                    child: Text(widget.emoji,
                      style: const TextStyle(fontSize: 52)),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // ── Progress bar ──────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('${(progress * 100).round()}% accompli',
                style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600,
                  color: _sageDark.withOpacity(0.7))),
              Text('${ widget.left } jours restants',
                style: GoogleFonts.inter(fontSize: 11, color: _mutedText)),
            ]),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Stack(children: [
                Container(height: 8, color: Colors.white.withOpacity(0.8)),
                FractionallySizedBox(
                  widthFactor: progress,
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      gradient: const LinearGradient(
                        colors: [_rose, _sage]),
                    ),
                  ),
                ),
              ]),
            ),
          ]),
        ),

        const SizedBox(height: 16),

        // ── Due date chip ─────────────────────────────────────────────────
        Container(
          margin: const EdgeInsets.fromLTRB(24, 0, 24, 20),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.7),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(children: [
            const Icon(Icons.calendar_today_rounded, size: 14, color: _sageDark),
            const SizedBox(width: 8),
            Text('Date prévue · ', style: GoogleFonts.inter(
              fontSize: 12, color: _mutedText)),
            Text(widget.fmtDue, style: GoogleFonts.inter(
              fontSize: 12, fontWeight: FontWeight.w700, color: _sageDark)),
          ]),
        ),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  TRIMESTER STRIP
// ─────────────────────────────────────────────────────────────────────────────
class _TrimesterStrip extends StatelessWidget {
  final int week;
  const _TrimesterStrip({required this.week});

  @override
  Widget build(BuildContext context) {
    final tri = week <= 13 ? 0 : week <= 26 ? 1 : 2;
    final labels = ['1er trimestre', '2e trimestre', '3e trimestre'];
    final subtitles = ['S1 – S13', 'S14 – S26', 'S27 – S42'];

    return Row(children: List.generate(3, (i) {
      final active = i == tri;
      final done   = i < tri;
      return Expanded(
        child: Container(
          margin: EdgeInsets.only(right: i < 2 ? 8 : 0),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
          decoration: BoxDecoration(
            color: active ? _roseDark : done ? _sageSoft : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: active ? _roseDark : done ? _sage.withOpacity(0.4) : Colors.grey.withOpacity(0.12),
            ),
            boxShadow: active ? [BoxShadow(
              color: _roseDark.withOpacity(0.22),
              blurRadius: 12, offset: const Offset(0, 4))] : [],
          ),
          child: Column(children: [
            Text(done ? '✓' : '${i + 1}',
              style: GoogleFonts.outfit(
                fontSize: 16, fontWeight: FontWeight.w800,
                color: active ? Colors.white : done ? _sage : _mutedText)),
            const SizedBox(height: 3),
            Text(labels[i], style: GoogleFonts.inter(
              fontSize: 9, fontWeight: FontWeight.w700,
              color: active ? Colors.white.withOpacity(0.9) : done ? _sageDark : _mutedText),
              textAlign: TextAlign.center),
            Text(subtitles[i], style: GoogleFonts.inter(
              fontSize: 9,
              color: active ? Colors.white.withOpacity(0.65) : _mutedText.withOpacity(0.7)),
              textAlign: TextAlign.center),
          ]),
        ),
      );
    }));
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  MOOD CARD
// ─────────────────────────────────────────────────────────────────────────────
class _MoodCard extends StatelessWidget {
  final int? selected;
  final void Function(int) onSelect;
  const _MoodCard({required this.selected, required this.onSelect});

  static const _moods = [
    ('Bien 😊',     _sageSoft,  _sage),
    ('Fatiguée 😴', _peach,     _gold),
    ('Joyeuse 🌟',  _roseSoft,  _roseDark),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecor,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Text('💭', style: TextStyle(fontSize: 18)),
          const SizedBox(width: 10),
          Text("Comment tu te sens aujourd'hui ?",
            style: GoogleFonts.outfit(
              fontSize: 15, fontWeight: FontWeight.w700, color: _warmText)),
        ]),
        const SizedBox(height: 16),
        Row(children: List.generate(3, (i) {
          final sel = selected == i;
          final (label, bg, color) = _moods[i];
          return Expanded(
            child: GestureDetector(
              onTap: () => onSelect(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: EdgeInsets.only(right: i < 2 ? 8 : 0),
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: sel ? bg : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: sel ? color : Colors.grey.withOpacity(0.12), width: 1.5),
                  boxShadow: sel ? [BoxShadow(
                    color: color.withOpacity(0.2),
                    blurRadius: 10, offset: const Offset(0, 3))] : [],
                ),
                child: Text(label,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 11, fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                    color: sel ? color : _mutedText)),
              ),
            ),
          );
        })),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  MOOD RESPONSE CARD
// ─────────────────────────────────────────────────────────────────────────────
class _MoodResponseCard extends StatefulWidget {
  final int mood, week;
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
    _ctrl  = AnimationController(vsync: this, duration: const Duration(milliseconds: 380));
    _fade  = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween(begin: const Offset(0, 0.06), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _ctrl.forward();
  }

  @override
  void didUpdateWidget(_MoodResponseCard old) {
    super.didUpdateWidget(old);
    if (old.mood != widget.mood) _ctrl.forward(from: 0);
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  (String, String) _content() {
    final tri = widget.week <= 13 ? 1 : widget.week <= 26 ? 2 : 3;
    switch (widget.mood) {
      case 0:
        return tri == 1
            ? ('Tu traverses le premier trimestre avec sérénité — c\'est précieux.',
               'Profite de cette énergie pour une marche de 20 min aujourd\'hui.')
            : tri == 2
            ? ('Le beau trimestre te va bien. Ton corps et ton bébé sont en harmonie.',
               'C\'est le bon moment pour un cours de yoga prénatal.')
            : ('Être en forme à la semaine ${widget.week}, c\'est une vraie force.',
               'Une marche douce le matin prépare ton corps naturellement.');
      case 1:
        return tri == 1
            ? ('La fatigue du 1er trimestre est l\'une des plus intenses — ton corps construit tout.',
               'Accorde-toi une sieste aujourd\'hui. C\'est du soin, pas de la paresse.')
            : tri == 2
            ? ('Une fatigue au 2e trimestre peut signaler une croissance rapide de bébé.',
               'Vérifie ton apport en fer et en protéines — et dors dès que tu peux.')
            : ('À la semaine ${widget.week}, la fatigue est le signal que ton corps se prépare.',
               'Surélève les pieds 20 min ce soir et laisse quelqu\'un t\'aider.');
      default:
        return tri == 1
            ? ('Cette joie est un beau cadeau — savoure chaque instant de ce début.',
               'Note ce moment dans un journal de grossesse. Tu seras heureuse de le relire.')
            : tri == 2
            ? ('Ta joie rayonne — bébé la perçoit vraiment.',
               'Mets de la musique que tu aimes et danse doucement avec bébé.')
            : ('Cette joie à l\'approche du grand jour est la plus belle des préparations.',
               'Partage ce moment avec quelqu\'un que tu aimes.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = [
      (_sageSoft, _sage, _sageDark),
      (_peach, _gold, const Color(0xFF8A6500)),
      (_roseSoft, _rose, _roseDark),
    ];
    final (bg, accent, textColor) = colors[widget.mood.clamp(0, 2)];
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
            border: Border.all(color: accent.withOpacity(0.3)),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Pour toi aujourd\'hui', style: GoogleFonts.inter(
              fontSize: 10, fontWeight: FontWeight.w700,
              color: textColor, letterSpacing: 1.5)),
            const SizedBox(height: 10),
            Text(message, style: GoogleFonts.outfit(
              fontSize: 14, height: 1.65, color: _warmText,
              fontStyle: FontStyle.italic)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.7),
                borderRadius: BorderRadius.circular(12)),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Icon(Icons.lightbulb_outline_rounded, size: 14, color: textColor),
                const SizedBox(width: 8),
                Expanded(child: Text(tip, style: GoogleFonts.inter(
                  fontSize: 12, color: _mutedText, height: 1.55,
                  fontWeight: FontWeight.w500))),
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  WEEK INSIGHT CARD
// ─────────────────────────────────────────────────────────────────────────────
class _WeekInsightCard extends StatelessWidget {
  final dynamic insight;
  const _WeekInsightCard({required this.insight});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecor,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Text('🍼', style: TextStyle(fontSize: 18)),
          const SizedBox(width: 10),
          Text('Cette semaine', style: GoogleFonts.outfit(
            fontSize: 16, fontWeight: FontWeight.w700, color: _warmText)),
        ]),
        const SizedBox(height: 16),

        // Baby insight
        _InsightTile(
          emoji: '👶', label: 'Votre bébé',
          text: insight.babyInsight,
          bg: _sageSoft, labelColor: _sageDark,
        ),
        const SizedBox(height: 10),

        // Mom tip
        _InsightTile(
          emoji: '💗', label: 'Pour vous',
          text: insight.momTip,
          bg: _roseSoft, labelColor: _roseDark,
        ),

        if ((insight.poeticLine as String).isNotEmpty) ...[
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _peach,
              borderRadius: BorderRadius.circular(14)),
            child: Text('"${insight.poeticLine}"',
              style: GoogleFonts.outfit(
                fontSize: 13, fontStyle: FontStyle.italic,
                color: _mutedText, height: 1.7),
              textAlign: TextAlign.center),
          ),
        ],
      ]),
    );
  }
}

class _InsightTile extends StatelessWidget {
  final String emoji, label, text;
  final Color bg, labelColor;
  const _InsightTile({
    required this.emoji, required this.label, required this.text,
    required this.bg, required this.labelColor,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(14)),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(emoji, style: const TextStyle(fontSize: 18)),
      const SizedBox(width: 10),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label.toUpperCase(), style: GoogleFonts.inter(
          fontSize: 9, fontWeight: FontWeight.w700,
          color: labelColor, letterSpacing: 1.8)),
        const SizedBox(height: 5),
        Text(text, style: GoogleFonts.inter(
          fontSize: 13, color: _warmText, height: 1.6)),
      ])),
    ]),
  );
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
      decoration: _cardDecor,
      child: Row(children: [
        Container(
          width: 52, height: 52,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [_sageSoft, Color(0xFFD4EDDD)],
              begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(16)),
          child: const Center(child: Text('🧘', style: TextStyle(fontSize: 24))),
        ),
        const SizedBox(width: 16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('FORME & MOUVEMENT', style: GoogleFonts.inter(
            fontSize: 9, fontWeight: FontWeight.w700,
            color: _sage, letterSpacing: 1.8)),
          const SizedBox(height: 4),
          Text(_fitLabel(week), style: GoogleFonts.outfit(
            fontSize: 15, fontWeight: FontWeight.w700, color: _warmText)),
          const SizedBox(height: 3),
          Text(_fitTip(week), style: GoogleFonts.inter(
            fontSize: 12, color: _mutedText, height: 1.5)),
        ])),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  NAV GRID  (2 × 2)
// ─────────────────────────────────────────────────────────────────────────────
class _NavGrid extends StatelessWidget {
  final int week;
  final BuildContext ctx;
  const _NavGrid({required this.week, required this.ctx});

  @override
  Widget build(BuildContext context) {
    Route fade(Widget p) => PageRouteBuilder(
      pageBuilder: (_, a, __) => p,
      transitionsBuilder: (_, a, __, c) =>
          FadeTransition(opacity: CurvedAnimation(parent: a, curve: Curves.easeInOut), child: c),
      transitionDuration: const Duration(milliseconds: 280),
    );

    final items = [
      ('💗', 'Symptômes',   'Journaliser aujourd\'hui', _roseSoft,  _roseDark,
        () { HapticFeedback.lightImpact(); Navigator.push(ctx, fade(SymptomsHomeScreen(currentWeek: week))); }),
      ('👶', 'Votre bébé',  'Sem. $week — développement', _sageSoft, _sageDark,
        () { HapticFeedback.lightImpact(); Navigator.push(ctx, fade(BabyStoryScreen(currentWeek: week))); }),
      ('🌸', 'Votre corps', 'Évolutions physiques', _peach,     const Color(0xFFB87A20),
        () { HapticFeedback.lightImpact(); Navigator.push(ctx, fade(PregnancyBodyScreen(currentWeek: week))); }),
      ('✅', 'Ma checklist','Préparatifs & RDV',     Color(0xFFF0F0FF), Color(0xFF5B5FEF),
        () { HapticFeedback.lightImpact(); Navigator.push(ctx, fade(PregnancyChecklistScreen(currentWeek: week))); }),
    ];

    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.35,
      children: items.map((item) {
        final (emoji, title, sub, bg, color, onTap) = item;
        return GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: color.withOpacity(0.15)),
              boxShadow: [BoxShadow(
                color: color.withOpacity(0.08),
                blurRadius: 12, offset: const Offset(0, 4))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(emoji, style: const TextStyle(fontSize: 26)),
                const Spacer(),
                Text(title, style: GoogleFonts.outfit(
                  fontSize: 14, fontWeight: FontWeight.w700, color: color)),
                const SizedBox(height: 2),
                Text(sub, style: GoogleFonts.inter(
                  fontSize: 10, color: color.withOpacity(0.7))),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  BORN CTA
// ─────────────────────────────────────────────────────────────────────────────
class _BornCard extends StatelessWidget {
  final BuildContext ctx;
  const _BornCard({required this.ctx});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        Navigator.push(ctx, PageRouteBuilder(
          pageBuilder: (_, a, __) => PostpartumHubScreen(birthDate: DateTime.now()),
          transitionsBuilder: (_, a, __, c) => FadeTransition(
            opacity: CurvedAnimation(parent: a, curve: Curves.easeInOut), child: c),
          transitionDuration: const Duration(milliseconds: 280),
        ));
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [_sageDark, Color(0xFF2E6B45)],
            begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [BoxShadow(
            color: _sageDark.withOpacity(0.3),
            blurRadius: 16, offset: const Offset(0, 6))],
        ),
        child: Row(children: [
          const Text('👶', style: TextStyle(fontSize: 28)),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Mon bébé est né !', style: GoogleFonts.outfit(
              fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
            Text('Passer au suivi post-partum', style: GoogleFonts.inter(
              fontSize: 12, color: Colors.white.withOpacity(0.65))),
          ])),
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              shape: BoxShape.circle),
            child: const Icon(Icons.arrow_forward_rounded, size: 18, color: Colors.white),
          ),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  SHARED DECORATION
// ─────────────────────────────────────────────────────────────────────────────
const _cardDecor = BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.all(Radius.circular(22)),
  boxShadow: [BoxShadow(
    color: Color(0x0A000000), blurRadius: 16, offset: Offset(0, 4))],
);
