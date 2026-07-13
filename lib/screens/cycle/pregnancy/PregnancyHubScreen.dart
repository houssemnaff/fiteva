// ignore_for_file: deprecated_member_use
import 'package:fiteva/providers/user_profile_provider.dart';
import 'package:fiteva/screens/cycle/pregnancy/PregnancyInsightRepository.dart';
import 'package:fiteva/services/pregnancy_content_service.dart';
import 'package:fiteva/providers/xp_provider.dart';
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
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:fiteva/widgets/shared_app_header.dart';
import 'package:fiteva/l10n/app_localizations.dart';

// ── Brand colors (theme-aware helpers) ───────────────────────────────────────
Color _primary(BuildContext c) => Theme.of(c).colorScheme.primary;
Color _accent(BuildContext c)  => Theme.of(c).colorScheme.secondary;
Color _heroBg(BuildContext c)  => Color.lerp(Theme.of(c).colorScheme.primary, Colors.black, 0.8)!;
const _heroMid   = Color(0xFF122015);

// ── Data ─────────────────────────────────────────────────────────────────────
const _months = ['janv.','févr.','mars','avr.','mai','juin',
  'juil.','août','sept.','oct.','nov.','déc.'];

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
      vsync: this, duration: const Duration(milliseconds: 500));
  late final Animation<double> _fadeOut =
      Tween<double>(begin: 1, end: 0).animate(
          CurvedAnimation(parent: _switchAnim, curve: Curves.easeInCubic));

  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
      ref.read(xpProvider.notifier).rewardPregnancyWeek());
  }

  @override
  void dispose() {
    _switchAnim.dispose();
    super.dispose();
  }

  Future<void> _switchToCycle() async {
    final l10n = ref.read(l10nProvider);
    final ok = await _confirm(
      l10n.pregQuitter,
      l10n.pregQuitterSub,
    );
    if (ok != true || !mounted) return;
    setState(() => _switching = true);
    await _switchAnim.forward();
    if (!mounted) return;
    final n = ref.read(userProfileProvider.notifier);
    await n.updateField('health_status', 'cycle');
    await n.updateField('pregnancy_week', null);
  }

  Future<void> _switchToPostpartum() async {
    final l10n = ref.read(l10nProvider);
    final birthDate = await showCustomDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 730)),
      lastDate: DateTime.now(),
      title: l10n.pregDateAccouch,
      subtitle: l10n.pregQuandNe,
      icon: Icons.child_care_rounded,
      accentColor: _primary(context),
    );
    if (birthDate == null || !mounted) return;
    final weeks = DateTime.now().difference(birthDate).inDays ~/ 7;
    final ppDuration = weeks < 2 ? '0-2' : weeks < 6 ? '2-6'
        : weeks < 12 ? '6-12' : weeks < 26 ? '3-6m' : '6m+';
    final ok = await _confirm(
      l10n.pregPostPartum,
      'Accouchement le ${birthDate.day}/${birthDate.month}/${birthDate.year} · $weeks semaines.',
    );
    if (ok != true || !mounted) return;
    setState(() => _switching = true);
    await _switchAnim.forward();
    if (!mounted) return;
    final n = ref.read(userProfileProvider.notifier);
    await n.updateField('health_status', 'postpartum');
    await n.updateField('pp_duration', ppDuration);
    // La vraie date est maintenant sauvegardée (pas seulement le bucket
    // ppDuration) — sinon le décompte post-partum se figeait indéfiniment
    // au lieu d'avancer avec le temps réel.
    await n.updateField('pp_birth_date', birthDate.toIso8601String());
    await n.updateField('pregnancy_week', null);
  }

  Future<bool?> _confirm(String title, String body) => showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(title, style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 17)),
          content: Text(body, style: GoogleFonts.inter(fontSize: 13, height: 1.6,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6))),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(ref.read(l10nProvider).pregAnnuler)),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(ref.read(l10nProvider).pregConfirmer)),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    final l10n    = ref.watch(l10nProvider);
    final cs      = Theme.of(context).colorScheme;
    final profile = ref.watch(userProfileProvider);
    final week    = (profile.currentPregnancyWeek ?? profile.pregnancyWeekSA ?? 1).clamp(1, 42);
    final insight = ref.watch(pregnancyInsightProvider(week)).asData?.value
        ?? PregnancyInsightRepository.forWeek(week);
    final due     = DateTime.now().add(Duration(days: (42 - week) * 7));
    final left    = due.difference(DateTime.now()).inDays.clamp(0, 300);
    final fmtDue  = '${due.day} ${_months[due.month - 1]} ${due.year}';
    final tri     = week <= 13 ? 1 : week <= 26 ? 2 : 3;

    return Scaffold(
      backgroundColor: cs.surface,
      body: FadeTransition(
        opacity: _fadeOut,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [

            // ── Shared header (same as cycle screen) ─────────────────────
            SharedAppHeader.sliver(
              eyebrow: l10n.pregTitle,
              title: l10n.pregMonSuivi,
              accentColor: _accent(context),
              bgColor: cs.surface,
              actions: [
                PopupMenuButton<String>(
                  enabled: !_switching,
                  onSelected: (v) {
                    if (v == 'cycle') _switchToCycle();
                    if (v == 'postpartum') _switchToPostpartum();
                  },
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  color: cs.surfaceContainerHighest,
                  offset: const Offset(0, 44),
                  itemBuilder: (_) => [
                    PopupMenuItem(
                      value: 'postpartum',
                      child: Text(l10n.pregPostPartumBtn,
                        style: GoogleFonts.inter(
                          fontSize: 13, fontWeight: FontWeight.w500,
                          color: cs.onSurface))),
                    PopupMenuItem(
                      value: 'cycle',
                      child: Text(l10n.pregMonCycle,
                        style: GoogleFonts.inter(
                          fontSize: 13, fontWeight: FontWeight.w500,
                          color: _accent(context)))),
                  ],
                  child: Container(
                    width: 38, height: 38,
                    decoration: BoxDecoration(
                      color: _accent(context).withOpacity(0.10),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.more_horiz_rounded,
                        size: 18, color: _primary(context)),
                  ),
                ),
              ],
            ),

            // ── Dark editorial hero ──────────────────────────────────────
            SliverToBoxAdapter(
              child: _Hero(
                week: week, tri: tri, left: left, fmtDue: fmtDue,
                fruit: _fruit[week] ?? 'fruit',
                l10n: l10n,
              ),
            ),

            // ── Body ────────────────────────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              sliver: SliverList(
                delegate: SliverChildListDelegate([

                  // Progress strip (3 trimesters)
                  _ProgressStrip(week: week, labels: [l10n.pregTrim1Short, l10n.pregTrim2Short, l10n.pregTrim3Short]),
                  const SizedBox(height: 24),

                  // Mood check-in
                  _SectionLabel(l10n.pregCommentTuTeSens),
                  const SizedBox(height: 10),
                  _MoodRow(selected: _mood, onSelect: (i) {
                    HapticFeedback.lightImpact();
                    setState(() => _mood = i);
                  }),

                  // Mood response
                  AnimatedSize(
                    duration: const Duration(milliseconds: 320),
                    curve: Curves.easeOutCubic,
                    child: _mood == null
                        ? const SizedBox.shrink()
                        : Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: _MoodResponse(mood: _mood!, week: week),
                          ),
                  ),

                  const SizedBox(height: 28),

                  // Week insight
                  _SectionLabel(l10n.pregSemaineN(week)),
                  const SizedBox(height: 10),
                  _WeekCard(insight: insight, cs: cs),
                  const SizedBox(height: 16),

                  // Fitness
                  _FitCard(week: week, cs: cs),
                  const SizedBox(height: 28),

                  // Navigation
                  _SectionLabel(l10n.pregExplorer),
                  const SizedBox(height: 10),
                  _NavList(week: week, cs: cs, l10n: l10n),

                  // Born CTA
                  if (week >= 37) ...[
                    const SizedBox(height: 16),
                    _BornBanner(cs: cs, l10n: l10n),
                  ],

                  SizedBox(height: MediaQuery.of(context).padding.bottom + 100),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  HERO  (full-bleed dark editorial, matches home screen language)
// ─────────────────────────────────────────────────────────────────────────────
class _Hero extends StatelessWidget {
  final int week, tri, left;
  final String fmtDue, fruit;
  final AppL10n l10n;

  const _Hero({
    required this.week, required this.tri, required this.left,
    required this.fmtDue, required this.fruit, required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (week / 42).clamp(0.0, 1.0);
    final triLabel = tri == 1 ? '1ER TRIMESTRE' : tri == 2 ? '2E TRIMESTRE' : '3E TRIMESTRE';

    return SizedBox(
      height: 260,
      child: Stack(
        fit: StackFit.expand,
        children: [

          // Deep dark background gradient
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [_heroBg(context), _heroMid, const Color(0xFF0D1A10)],
              ),
            ),
          ),

          // Subtle radial glow
          Positioned(
            right: -40, top: 20,
            child: Container(
              width: 240, height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    _primary(context).withOpacity(0.35),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Content
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  const Spacer(),

                  // ── Eyebrow (matches home screen) ─────────────────────
                  Row(children: [
                    Container(width: 24, height: 2, color: _accent(context)),
                    const SizedBox(width: 10),
                    Text(triLabel, style: GoogleFonts.inter(
                      fontSize: 10, fontWeight: FontWeight.w700,
                      color: _accent(context), letterSpacing: 3)),
                  ]),

                  const SizedBox(height: 10),

                  // ── Week number (big editorial) ────────────────────────
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text('${l10n.pregSemaine} ', style: GoogleFonts.outfit(
                        fontSize: 18, fontWeight: FontWeight.w300,
                        color: Colors.white54, letterSpacing: 1)),
                      Text('$week', style: GoogleFonts.outfit(
                        fontSize: 80, fontWeight: FontWeight.w900,
                        color: Colors.white, height: 0.9,
                        letterSpacing: -2)),
                    ],
                  ),

                  const SizedBox(height: 6),

                  // ── Fruit size ─────────────────────────────────────────
                  Row(children: [
                    Icon(LucideIcons.sprout, size: 14, color: _accent(context)),
                    const SizedBox(width: 8),
                    Text(l10n.pregCommeFruit(fruit), style: GoogleFonts.inter(
                      fontSize: 13, color: Colors.white60)),
                    const Spacer(),
                    Text('$left ${l10n.pregJoursRestants}', style: GoogleFonts.inter(
                      fontSize: 12, color: Colors.white38)),
                  ]),

                  const SizedBox(height: 16),

                  // ── Progress bar ───────────────────────────────────────
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Stack(children: [
                      Container(height: 3,
                        color: Colors.white.withOpacity(0.12)),
                      FractionallySizedBox(
                        widthFactor: progress,
                        child: Container(height: 3, color: _accent(context)),
                      ),
                    ]),
                  ),

                  const SizedBox(height: 12),

                  // ── Due date ───────────────────────────────────────────
                  Row(children: [
                    Icon(Icons.event_rounded, size: 13,
                        color: Colors.white38),
                    const SizedBox(width: 6),
                    Text('Terme estimé · ', style: GoogleFonts.inter(
                      fontSize: 12, color: Colors.white38)),
                    Text(fmtDue, style: GoogleFonts.inter(
                      fontSize: 12, fontWeight: FontWeight.w600,
                      color: Colors.white60)),
                  ]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  SECTION LABEL
// ─────────────────────────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(text,
    style: GoogleFonts.outfit(
      fontSize: 18, fontWeight: FontWeight.w700,
      color: Theme.of(context).colorScheme.onSurface));
}

// ─────────────────────────────────────────────────────────────────────────────
//  PROGRESS STRIP  (3 trimesters, minimal)
// ─────────────────────────────────────────────────────────────────────────────
class _ProgressStrip extends StatelessWidget {
  final int week;
  final List<String> labels;
  const _ProgressStrip({required this.week, required this.labels});

  @override
  Widget build(BuildContext context) {
    final cs  = Theme.of(context).colorScheme;
    final tri = week <= 13 ? 0 : week <= 26 ? 1 : 2;
    final subtitles = ['S1–S13', 'S14–S26', 'S27–S42'];

    return Row(children: List.generate(3, (i) {
      final active = i == tri;
      final done   = i < tri;
      return Expanded(
        child: Container(
          margin: EdgeInsets.only(right: i < 2 ? 8 : 0),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
          decoration: BoxDecoration(
            color: active
                ? _primary(context)
                : done
                    ? _primary(context).withOpacity(0.08)
                    : cs.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: active
                  ? _primary(context)
                  : done
                      ? _primary(context).withOpacity(0.2)
                      : cs.outline,
              width: 1,
            ),
          ),
          child: Column(children: [
            Text(
              done ? '✓' : '${i + 1}',
              style: GoogleFonts.outfit(
                fontSize: 15, fontWeight: FontWeight.w800,
                color: active
                    ? Colors.white
                    : done
                        ? _primary(context)
                        : cs.onSurface.withOpacity(0.35)),
            ),
            const SizedBox(height: 3),
            Text(labels[i], style: GoogleFonts.inter(
              fontSize: 9, fontWeight: FontWeight.w700,
              color: active ? Colors.white : done ? _primary(context) : cs.onSurface.withOpacity(0.45),
              letterSpacing: 0.2),
              textAlign: TextAlign.center),
            Text(subtitles[i], style: GoogleFonts.inter(
              fontSize: 9,
              color: active ? Colors.white54 : cs.onSurface.withOpacity(0.3)),
              textAlign: TextAlign.center),
          ]),
        ),
      );
    }));
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  MOOD ROW
// ─────────────────────────────────────────────────────────────────────────────
class _MoodRow extends StatelessWidget {
  final int? selected;
  final void Function(int) onSelect;
  const _MoodRow({required this.selected, required this.onSelect});

  static const _labels = ['Bien', 'Fatiguée', 'Joyeuse'];
  static const _icons  = [
    LucideIcons.smile,
    LucideIcons.moonStar,
    LucideIcons.sparkles,
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(children: List.generate(3, (i) {
      final sel = selected == i;
      return Expanded(
        child: GestureDetector(
          onTap: () => onSelect(i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: EdgeInsets.only(right: i < 2 ? 10 : 0),
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: sel ? _primary(context) : cs.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: sel ? _primary(context) : cs.outline, width: 1),
            ),
            child: Column(children: [
              Icon(_icons[i], size: 20,
                color: sel ? Colors.white : cs.onSurface.withOpacity(0.5)),
              const SizedBox(height: 6),
              Text(_labels[i], style: GoogleFonts.inter(
                fontSize: 11, fontWeight: FontWeight.w600,
                color: sel ? Colors.white : cs.onSurface.withOpacity(0.6))),
            ]),
          ),
        ),
      );
    }));
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  MOOD RESPONSE
// ─────────────────────────────────────────────────────────────────────────────
class _MoodResponse extends StatefulWidget {
  final int mood, week;
  const _MoodResponse({required this.mood, required this.week});
  @override
  State<_MoodResponse> createState() => _MoodResponseState();
}

class _MoodResponseState extends State<_MoodResponse>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 350));
  late final Animation<double> _fade =
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
  late final Animation<Offset> _slide =
      Tween(begin: const Offset(0, 0.05), end: Offset.zero)
          .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));

  @override
  void initState() { super.initState(); _ctrl.forward(); }

  @override
  void didUpdateWidget(_MoodResponse old) {
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
            ? ('Tu traverses le 1er trimestre avec sérénité.',
               'Profite de cette énergie pour une marche de 20 min.')
            : tri == 2
            ? ('Ton corps et ton bébé sont en harmonie.',
               'Moment idéal pour un cours de yoga prénatal.')
            : ('Être en forme à la semaine ${ widget.week }, c\'est une vraie force.',
               'Une marche douce le matin prépare ton corps naturellement.');
      case 1:
        return tri == 1
            ? ('La fatigue du 1er trimestre est normale — ton corps construit tout.',
               'Une sieste aujourd\'hui, c\'est du soin, pas de la paresse.')
            : tri == 2
            ? ('Une fatigue au 2e trimestre peut signaler une croissance rapide.',
               'Vérifie ton apport en fer et en protéines.')
            : ('À la semaine ${ widget.week }, ton corps se prépare activement.',
               'Surélève les pieds 20 min ce soir.');
      default:
        return tri == 1
            ? ('Cette joie est un beau cadeau en ce début de grossesse.',
               'Note ce moment dans un journal — tu seras heureuse de le relire.')
            : tri == 2
            ? ('Ta joie rayonne — bébé la perçoit vraiment.',
               'Mets de la musique et danse doucement avec bébé.')
            : ('Cette joie à l\'approche du grand jour est la plus belle des préparations.',
               'Partage ce moment avec quelqu\'un que tu aimes.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final (message, tip) = _content();
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _primary(context).withOpacity(0.06),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _primary(context).withOpacity(0.12)),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(message, style: GoogleFonts.outfit(
              fontSize: 14, height: 1.6,
              color: cs.onSurface, fontStyle: FontStyle.italic)),
            const SizedBox(height: 10),
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(width: 3, height: 36,
                margin: const EdgeInsets.only(right: 10, top: 2),
                decoration: BoxDecoration(
                  color: _accent(context),
                  borderRadius: BorderRadius.circular(2))),
              Expanded(child: Text(tip, style: GoogleFonts.inter(
                fontSize: 12, height: 1.6,
                color: cs.onSurface.withOpacity(0.6)))),
            ]),
          ]),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  WEEK INSIGHT CARD
// ─────────────────────────────────────────────────────────────────────────────
class _WeekCard extends StatelessWidget {
  final dynamic insight;
  final ColorScheme cs;
  const _WeekCard({required this.insight, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cs.outline),
      ),
      child: Column(children: [

        // Baby row
        _InsightRow(
          label: 'VOTRE BÉBÉ',
          text: insight.babyInsight,
          accent: _primary(context),
          cs: cs,
          topRadius: true,
        ),

        Divider(height: 1, color: cs.outline),

        // Mom row
        _InsightRow(
          label: 'POUR VOUS',
          text: insight.momTip,
          accent: _accent(context),
          cs: cs,
          bottomRadius: true,
        ),

        if ((insight.poeticLine as String).isNotEmpty) ...[
          Divider(height: 1, color: cs.outline),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text('"${insight.poeticLine}"',
              style: GoogleFonts.outfit(
                fontSize: 13, fontStyle: FontStyle.italic,
                color: cs.onSurface.withOpacity(0.45), height: 1.7),
              textAlign: TextAlign.center),
          ),
        ],
      ]),
    );
  }
}

class _InsightRow extends StatelessWidget {
  final String label, text;
  final Color accent;
  final ColorScheme cs;
  final bool topRadius, bottomRadius;
  const _InsightRow({
    required this.label, required this.text, required this.accent,
    required this.cs, this.topRadius = false, this.bottomRadius = false,
  });

  @override
  Widget build(BuildContext context) {
    final r = BorderRadius.vertical(
      top: topRadius ? const Radius.circular(18) : Radius.zero,
      bottom: bottomRadius ? const Radius.circular(18) : Radius.zero,
    );
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(borderRadius: r),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 3, height: 40,
          margin: const EdgeInsets.only(right: 12, top: 2),
          decoration: BoxDecoration(
            color: accent, borderRadius: BorderRadius.circular(2)),
        ),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: GoogleFonts.inter(
            fontSize: 9, fontWeight: FontWeight.w700,
            color: accent, letterSpacing: 1.8)),
          const SizedBox(height: 5),
          Text(text, style: GoogleFonts.inter(
            fontSize: 13, height: 1.6,
            color: cs.onSurface.withOpacity(0.85))),
        ])),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  FITNESS CARD
// ─────────────────────────────────────────────────────────────────────────────
class _FitCard extends StatelessWidget {
  final int week;
  final ColorScheme cs;
  const _FitCard({required this.week, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cs.outline),
      ),
      child: Row(children: [
        Container(
          width: 48, height: 48,
          decoration: BoxDecoration(
            color: _primary(context),
            borderRadius: BorderRadius.circular(14)),
          child: const Center(
            child: Icon(LucideIcons.activity, size: 22, color: Colors.white)),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('MOUVEMENT', style: GoogleFonts.inter(
            fontSize: 9, fontWeight: FontWeight.w700,
            color: _accent(context), letterSpacing: 1.8)),
          const SizedBox(height: 3),
          Text(_fitLabel(week), style: GoogleFonts.outfit(
            fontSize: 15, fontWeight: FontWeight.w700,
            color: cs.onSurface)),
          const SizedBox(height: 2),
          Text(_fitTip(week), style: GoogleFonts.inter(
            fontSize: 12, color: cs.onSurface.withOpacity(0.55), height: 1.5)),
        ])),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  NAV LIST  (clean rows, matches app style)
// ─────────────────────────────────────────────────────────────────────────────
class _NavList extends StatelessWidget {
  final int week;
  final ColorScheme cs;
  final AppL10n l10n;
  const _NavList({required this.week, required this.cs, required this.l10n});

  @override
  Widget build(BuildContext context) {
    Route fadeTo(Widget p) => PageRouteBuilder(
      pageBuilder: (_, a, __) => p,
      transitionsBuilder: (_, a, __, c) =>
          FadeTransition(opacity: CurvedAnimation(parent: a, curve: Curves.easeInOut), child: c),
      transitionDuration: const Duration(milliseconds: 260),
    );

    final items = [
      (l10n.pregSymptomes,   l10n.pregSuivreSymptomes,  Icons.favorite_border_rounded,
        () => Navigator.push(context, fadeTo(SymptomsHomeScreen(currentWeek: week)))),
      (l10n.pregVotreBebe,   '${l10n.pregDeveloppement} — ${l10n.pregSemaineN(week)}', Icons.child_care_rounded,
        () => Navigator.push(context, fadeTo(BabyStoryScreen(currentWeek: week)))),
      (l10n.pregVotreCorps,  l10n.pregEvolutions,       Icons.self_improvement_rounded,
        () => Navigator.push(context, fadeTo(PregnancyBodyScreen(currentWeek: week)))),
      (l10n.pregMaChecklist, l10n.pregPreparatifs,      Icons.check_circle_outline_rounded,
        () => Navigator.push(context, fadeTo(PregnancyChecklistScreen(currentWeek: week)))),
    ];

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cs.outline),
      ),
      child: Column(children: List.generate(items.length, (i) {
        final (title, sub, icon, onTap) = items[i];
        final isLast = i == items.length - 1;
        return Column(children: [
          InkWell(
            onTap: () { HapticFeedback.lightImpact(); onTap(); },
            borderRadius: BorderRadius.vertical(
              top: i == 0 ? const Radius.circular(18) : Radius.zero,
              bottom: isLast ? const Radius.circular(18) : Radius.zero,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: _primary(context).withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12)),
                  child: Icon(icon, size: 18, color: _primary(context)),
                ),
                const SizedBox(width: 14),
                Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(title, style: GoogleFonts.outfit(
                    fontSize: 14, fontWeight: FontWeight.w700,
                    color: cs.onSurface)),
                  Text(sub, style: GoogleFonts.inter(
                    fontSize: 11,
                    color: cs.onSurface.withOpacity(0.5))),
                ])),
                Icon(Icons.chevron_right_rounded,
                    size: 18, color: cs.onSurface.withOpacity(0.3)),
              ]),
            ),
          ),
          if (!isLast) Divider(height: 1, indent: 70, color: cs.outline),
        ]);
      })),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  BORN BANNER  (week 37+)
// ─────────────────────────────────────────────────────────────────────────────
class _BornBanner extends ConsumerWidget {
  final ColorScheme cs;
  final AppL10n l10n;
  const _BornBanner({required this.cs, required this.l10n});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () async {
        HapticFeedback.mediumImpact();
        // Ce raccourci n'enregistrait jamais le passage en post-partum
        // (health_status restait 'pregnant') — il ne faisait que naviguer
        // vers l'écran, qui se réinitialisait donc à chaque réouverture.
        final birthDate = DateTime.now();
        final n = ref.read(userProfileProvider.notifier);
        await n.updateField('health_status', 'postpartum');
        await n.updateField('pp_duration', '0-2');
        await n.updateField('pp_birth_date', birthDate.toIso8601String());
        await n.updateField('pregnancy_week', null);
        if (!context.mounted) return;
        Navigator.push(context, PageRouteBuilder(
          pageBuilder: (_, a, __) =>
              PostpartumHubScreen(birthDate: birthDate),
          transitionsBuilder: (_, a, __, c) => FadeTransition(
            opacity: CurvedAnimation(parent: a, curve: Curves.easeInOut),
            child: c),
          transitionDuration: const Duration(milliseconds: 260),
        ));
      },
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: _primary(context),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            Text(l10n.pregBabyBorn, style: GoogleFonts.outfit(
              fontSize: 16, fontWeight: FontWeight.w700,
              color: Colors.white)),
            const SizedBox(height: 2),
            Text(l10n.pregPasserSuivi, style: GoogleFonts.inter(
              fontSize: 12, color: Colors.white60)),
          ])),
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.arrow_forward_rounded,
                size: 16, color: Colors.white),
          ),
        ]),
      ),
    );
  }
}
