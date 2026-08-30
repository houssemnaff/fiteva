// ignore_for_file: deprecated_member_use
import 'package:fiteva/providers/user_profile_provider.dart';
import 'package:fiteva/screens/cycle/pregnancy/PregnancyInsightRepository.dart';
import 'package:fiteva/screens/cycle/pregnancy/daily_insight_model.dart';
import 'package:fiteva/services/pregnancy_content_service.dart';
import 'package:fiteva/providers/points_provider.dart';
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
import 'package:fiteva/l10n/app_localizations.dart';


// ── Premium palette ─────────────────────────────────────────────────────────
const _coral     = Color(0xFFE07A5F);
const _peach     = Color(0xFFF2A977);
const _warmMint  = Color(0xFF5BA88C);
const _deepMint  = Color(0xFF3D8B6E);
const _lavender  = Color(0xFF8B7EC8);
const _gold      = Color(0xFFD4A44C);

Color _bg(bool d)    => d ? const Color(0xFF0E0E11) : const Color(0xFFFAF7F4);
Color _text(bool d)  => d ? const Color(0xFFF5F0EB) : const Color(0xFF1E1A17);
Color _sub(bool d)   => d ? const Color(0xFF9A9498) : const Color(0xFF6D6166);
Color _faint(bool d) => d ? Colors.white.withOpacity(0.05) : const Color(0xFFF0EBE6);

// ── Data ────────────────────────────────────────────────────────────────────
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


const _babySize = <int, String>{
  4:'~1mm', 5:'~2mm', 6:'~5mm', 7:'~1cm', 8:'~1.6cm', 9:'~2.3cm',
  10:'~3cm', 11:'~4cm', 12:'~5.5cm', 13:'~7cm', 14:'~8.5cm',
  15:'~10cm', 16:'~11.5cm', 17:'~13cm', 18:'~14cm', 19:'~15cm',
  20:'~16.5cm', 21:'~27cm', 22:'~28cm', 23:'~29cm', 24:'~30cm',
  25:'~35cm', 26:'~36cm', 27:'~37cm', 28:'~38cm', 29:'~39cm',
  30:'~40cm', 31:'~41cm', 32:'~42.5cm', 33:'~44cm', 34:'~45cm',
  35:'~46cm', 36:'~47cm', 37:'~48cm', 38:'~49cm', 39:'~50cm',
  40:'~51cm', 41:'~51cm', 42:'~51cm',
};

const _babyWeight = <int, String>{
  8:'~1g', 9:'~2g', 10:'~4g', 11:'~7g', 12:'~14g', 13:'~23g',
  14:'~43g', 15:'~70g', 16:'~100g', 17:'~140g', 18:'~190g', 19:'~240g',
  20:'~300g', 21:'~360g', 22:'~430g', 23:'~500g', 24:'~600g',
  25:'~660g', 26:'~760g', 27:'~875g', 28:'~1kg', 29:'~1.15kg',
  30:'~1.3kg', 31:'~1.5kg', 32:'~1.7kg', 33:'~1.9kg', 34:'~2.15kg',
  35:'~2.4kg', 36:'~2.6kg', 37:'~2.85kg', 38:'~3.1kg', 39:'~3.3kg',
  40:'~3.5kg', 41:'~3.6kg', 42:'~3.7kg',
};

const _babyDev = <int, String>{
  4: 'Le cœur commence à battre',
  5: 'Le tube neural se forme',
  6: 'Les bourgeons des bras apparaissent',
  7: 'Le visage commence à se dessiner',
  8: 'Les doigts et orteils se forment',
  9: 'Les organes vitaux sont en place',
  10: 'Les ongles commencent à pousser',
  11: 'Bébé commence à bouger',
  12: 'Les réflexes se développent',
  13: 'Les empreintes digitales se forment',
  14: 'Les expressions faciales apparaissent',
  15: 'Bébé perçoit la lumière',
  16: 'Le squelette se renforce',
  17: 'La graisse commence à se déposer',
  18: 'Bébé bâille et s\'étire',
  19: 'Les sens se développent',
  20: 'Bébé entend votre voix',
  21: 'Les mouvements sont plus forts',
  22: 'Les sourcils se dessinent',
  23: 'La peau se pigmente',
  24: 'Les poumons se développent',
  25: 'Bébé réagit aux sons',
  26: 'Les yeux s\'ouvrent',
  27: 'Le cerveau se développe rapidement',
  28: 'Bébé rêve pendant son sommeil',
  29: 'Les muscles se renforcent',
  30: 'La moelle osseuse produit les globules',
  31: 'Les cinq sens fonctionnent',
  32: 'Bébé prend du poids rapidement',
  33: 'Les os du crâne restent souples',
  34: 'Le système immunitaire se forme',
  35: 'Les poumons sont presque matures',
  36: 'Bébé descend dans le bassin',
  37: 'Bébé est considéré à terme',
  38: 'Les organes sont prêts',
  39: 'Bébé continue de prendre du poids',
  40: 'Prêt pour la naissance !',
  41: 'Bébé attend le grand jour',
  42: 'Bébé est prêt !',
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

Color _triAccent(int tri) => tri == 1 ? _coral : tri == 2 ? _lavender : _warmMint;

// ─────────────────────────────────────────────────────────────────────────────
class PregnancyHubScreen extends ConsumerStatefulWidget {
  const PregnancyHubScreen({super.key});
  @override
  ConsumerState<PregnancyHubScreen> createState() => _PregnancyHubScreenState();
}

class _PregnancyHubScreenState extends ConsumerState<PregnancyHubScreen>
    with SingleTickerProviderStateMixin {
  int? _feeling;
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
      ref.read(pointsProvider.notifier).rewardPregnancyWeek());
  }

  @override
  void dispose() { _switchAnim.dispose(); super.dispose(); }

  bool get _dark => Theme.of(context).brightness == Brightness.dark;

  // ── Mode switches ──
  Future<void> _switchToCycle() async {
    final l10n = ref.read(l10nProvider);
    final ok = await _confirm(l10n.pregQuitter, l10n.pregQuitterSub);
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
      accentColor: Theme.of(context).colorScheme.primary,
    );
    if (birthDate == null || !mounted) return;
    final weeks = DateTime.now().difference(birthDate).inDays ~/ 7;
    final ppDur = weeks < 2 ? '0-2' : weeks < 6 ? '2-6'
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
    await n.updateField('pp_duration', ppDur);
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

  Route _fadeTo(Widget p) => PageRouteBuilder(
    pageBuilder: (_, a, __) => p,
    transitionsBuilder: (_, a, __, c) =>
        FadeTransition(opacity: CurvedAnimation(parent: a, curve: Curves.easeInOut), child: c),
    transitionDuration: const Duration(milliseconds: 260),
  );

  // ── BUILD ──
  @override
  Widget build(BuildContext context) {
    final l10n    = ref.watch(l10nProvider);
    final profile = ref.watch(userProfileProvider);
    final week    = (profile.currentPregnancyWeek ?? profile.pregnancyWeekSA ?? 1).clamp(1, 42);
    final insight = ref.watch(pregnancyInsightProvider(week)).asData?.value
        ?? PregnancyInsightRepository.forWeek(week);
    final due     = DateTime.now().add(Duration(days: (42 - week) * 7));
    final left    = due.difference(DateTime.now()).inDays.clamp(0, 300);
    final fmtDue  = '${due.day} ${_months[due.month - 1]} ${due.year}';
    final tri     = week <= 13 ? 1 : week <= 26 ? 2 : 3;
    final dark    = _dark;
    final accent  = _triAccent(tri);

    return Scaffold(
      backgroundColor: _bg(dark),
      body: FadeTransition(
        opacity: _fadeOut,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [

            // ═══════════════════════════════════════════════════════════════
            //  HERO — week ring + baby
            // ═══════════════════════════════════════════════════════════════
            _HeroSection(
              week: week, tri: tri, accent: accent,
              due: fmtDue, left: left, dark: dark, l10n: l10n,
              onMenu: (v) {
                if (v == 'cycle') _switchToCycle();
                if (v == 'postpartum') _switchToPostpartum();
              },
              switching: _switching,
            ),

            // ═══════════════════════════════════════════════════════════════
            //  BABY DEVELOPMENT — big prominent card
            // ═══════════════════════════════════════════════════════════════
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
              child: Transform.translate(
                offset: const Offset(0, -24),
                child: _BabyDevCard(
                  week: week, tri: tri, accent: accent,
                  insight: insight, dark: dark, l10n: l10n,
                  onTap: () => Navigator.push(context,
                    _fadeTo(BabyStoryScreen(currentWeek: week))),
                ),
              ),
            ),

            // ═══════════════════════════════════════════════════════════════
            //  TRIMESTER JOURNEY
            // ═══════════════════════════════════════════════════════════════
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
              child: _TrimesterJourney(week: week, tri: tri, dark: dark, l10n: l10n),
            ),

            // ═══════════════════════════════════════════════════════════════
            //  FEELING CHECK-IN (pregnancy-specific)
            // ═══════════════════════════════════════════════════════════════
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
              child: _buildFeelingSection(week, dark, l10n),
            ),

            // ═══════════════════════════════════════════════════════════════
            //  DAILY TIP
            // ═══════════════════════════════════════════════════════════════
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
              child: _DailyTipCard(insight: insight, week: week, dark: dark, l10n: l10n),
            ),

            // ═══════════════════════════════════════════════════════════════
            //  EXPLORE — asymmetric grid
            // ═══════════════════════════════════════════════════════════════
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
              child: _buildExploreGrid(week, dark, l10n),
            ),

            // ═══════════════════════════════════════════════════════════════
            //  BORN CTA (week 37+)
            // ═══════════════════════════════════════════════════════════════
            if (week >= 37) Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: _buildBornBanner(dark, l10n),
            ),

            SizedBox(height: MediaQuery.of(context).padding.bottom + 80),
          ]),
        ),
      ),
    );
  }

  // ── FEELING CHECK-IN ──
  Widget _buildFeelingSection(int week, bool dark, AppL10n l10n) {
    final items = <(IconData, String, Color)>[
      (LucideIcons.zap,       l10n.isFrench ? 'Énergie'   : 'Energy',   _gold),
      (LucideIcons.cloudRain, l10n.isFrench ? 'Nausées'   : 'Nausea',   _coral),
      (LucideIcons.moon,      l10n.isFrench ? 'Sommeil'   : 'Sleep',    _lavender),
      (LucideIcons.cookie,    l10n.isFrench ? 'Envies'    : 'Cravings', _peach),
      (LucideIcons.heart,     l10n.isFrench ? 'Humeur'    : 'Mood',     _warmMint),
    ];

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(
        l10n.isFrench ? 'Comment tu te sens ?' : 'How are you feeling?',
        style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: _text(dark)),
      ),
      const SizedBox(height: 12),
      Row(children: List.generate(5, (i) {
        final (icon, label, color) = items[i];
        final sel = _feeling == i;
        return Expanded(child: GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            setState(() => _feeling = _feeling == i ? null : i);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            margin: EdgeInsets.only(right: i < 4 ? 6 : 0),
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              gradient: sel ? LinearGradient(
                begin: Alignment.topLeft, end: Alignment.bottomRight,
                colors: [color, color.withOpacity(0.7)],
              ) : null,
              color: sel ? null : _faint(dark),
              borderRadius: BorderRadius.circular(14),
              boxShadow: sel ? [BoxShadow(
                color: color.withOpacity(0.25), blurRadius: 12, offset: const Offset(0, 4),
              )] : null,
            ),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(icon, size: sel ? 22 : 18,
                color: sel ? Colors.white : _sub(dark)),
              const SizedBox(height: 6),
              Text(label, style: GoogleFonts.inter(
                fontSize: 9, fontWeight: FontWeight.w700,
                color: sel ? Colors.white.withOpacity(0.9) : _sub(dark),
                letterSpacing: 0.2),
                textAlign: TextAlign.center),
            ]),
          ),
        ));
      })),
      if (_feeling != null) ...[
        const SizedBox(height: 14),
        _FeelingResponse(feeling: _feeling!, week: week, dark: dark),
      ],
    ]);
  }

  // ── EXPLORE GRID — asymmetric ──
  Widget _buildExploreGrid(int week, bool dark, AppL10n l10n) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(l10n.pregExplorer, style: GoogleFonts.outfit(
        fontSize: 18, fontWeight: FontWeight.w700, color: _text(dark))),
      const SizedBox(height: 12),

      // Top row: Bébé (tall) + Symptômes stacked with Corps
      SizedBox(
        height: 190,
        child: Row(children: [
          // LEFT — Baby (tall, prominent)
          Expanded(flex: 5, child: _ExploreCard(
            label: l10n.pregVotreBebe,
            subtitle: l10n.isFrench ? 'Semaine $week' : 'Week $week',
            icon: LucideIcons.baby,
            gradient: const [_warmMint, _deepMint],
            dark: dark, tall: true,
            onTap: () => Navigator.push(context,
              _fadeTo(BabyStoryScreen(currentWeek: week))),
          )),
          const SizedBox(width: 8),
          // RIGHT — two stacked
          Expanded(flex: 4, child: Column(children: [
            Expanded(child: _ExploreCard(
              label: l10n.pregSymptomes,
              icon: LucideIcons.heartPulse,
              gradient: [_coral, _coral.withOpacity(0.7)],
              dark: dark,
              onTap: () => Navigator.push(context,
                _fadeTo(SymptomsHomeScreen(currentWeek: week))),
            )),
            const SizedBox(height: 8),
            Expanded(child: _ExploreCard(
              label: l10n.pregVotreCorps,
              icon: LucideIcons.sparkles,
              gradient: [_lavender, _lavender.withOpacity(0.7)],
              dark: dark,
              onTap: () => Navigator.push(context,
                _fadeTo(PregnancyBodyScreen(currentWeek: week))),
            )),
          ])),
        ]),
      ),
      const SizedBox(height: 8),

      // Bottom — Checklist (wide)
      SizedBox(
        height: 64,
        child: _ExploreCard(
          label: l10n.pregMaChecklist,
          icon: LucideIcons.clipboardCheck,
          gradient: [_gold, _gold.withOpacity(0.7)],
          dark: dark, wide: true,
          onTap: () => Navigator.push(context,
            _fadeTo(PregnancyChecklistScreen(currentWeek: week))),
        ),
      ),
    ]);
  }

  // ── BORN BANNER ──
  Widget _buildBornBanner(bool dark, AppL10n l10n) {
    return GestureDetector(
      onTap: () async {
        HapticFeedback.mediumImpact();
        final birthDate = DateTime.now();
        final n = ref.read(userProfileProvider.notifier);
        await n.updateField('health_status', 'postpartum');
        await n.updateField('pp_duration', '0-2');
        await n.updateField('pp_birth_date', birthDate.toIso8601String());
        await n.updateField('pregnancy_week', null);
        if (!mounted) return;
        Navigator.push(context, _fadeTo(PostpartumHubScreen(birthDate: birthDate)));
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: [_coral, _peach],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(
            color: _coral.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8))],
        ),
        child: Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(l10n.pregBabyBorn, style: GoogleFonts.outfit(
              fontSize: 17, fontWeight: FontWeight.w700, color: Colors.white)),
            const SizedBox(height: 4),
            Text(l10n.pregPasserSuivi, style: GoogleFonts.inter(
              fontSize: 12, color: Colors.white70)),
          ])),
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.arrow_forward_rounded, size: 18, color: Colors.white),
          ),
        ]),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
//  HERO SECTION — timeline bar + stats
// ═════════════════════════════════════════════════════════════════════════════
class _HeroSection extends StatelessWidget {
  final int week, tri, left;
  final Color accent;
  final String due;
  final bool dark, switching;
  final AppL10n l10n;
  final void Function(String) onMenu;

  const _HeroSection({
    required this.week, required this.tri, required this.accent,
    required this.due, required this.left, required this.dark,
    required this.l10n, required this.onMenu, required this.switching,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (week / 42).clamp(0.0, 1.0);
    final pct = (progress * 100).round();

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: dark
              ? [const Color(0xFF1A1218), const Color(0xFF151015), _bg(true)]
              : [const Color(0xFFFCEDE6), const Color(0xFFF8E4DA), const Color(0xFFFAF3EE), _bg(false)],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 16, 36),
          child: Column(children: [
            // Header
            Row(children: [
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.pregTitle, style: GoogleFonts.inter(
                    fontSize: 10, fontWeight: FontWeight.w600,
                    letterSpacing: 1.5, color: _sub(dark))),
                  const SizedBox(height: 2),
                  Text(l10n.pregMonSuivi, style: GoogleFonts.outfit(
                    fontSize: 22, fontWeight: FontWeight.w700, color: _text(dark))),
                ],
              )),
              PopupMenuButton<String>(
                enabled: !switching,
                onSelected: onMenu,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 4,
                color: dark ? const Color(0xFF1E1E1E) : Colors.white,
                offset: const Offset(0, 44),
                itemBuilder: (_) => [
                  PopupMenuItem(value: 'postpartum',
                    child: Text(l10n.pregPostPartumBtn, style: GoogleFonts.inter(
                      fontSize: 13, fontWeight: FontWeight.w500, color: _text(dark)))),
                  PopupMenuItem(value: 'cycle',
                    child: Text(l10n.pregMonCycle, style: GoogleFonts.inter(
                      fontSize: 13, fontWeight: FontWeight.w500, color: accent))),
                ],
                child: Icon(Icons.more_horiz_rounded, size: 22,
                  color: _text(dark).withOpacity(0.6)),
              ),
            ]),
            const SizedBox(height: 28),

            // Big week number
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(l10n.isFrench ? 'Semaine ' : 'Week ',
                  style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: _sub(dark))),
                Text('$week', style: GoogleFonts.outfit(
                  fontSize: 52, fontWeight: FontWeight.w900, color: _text(dark), height: 1)),
                Text(' / 42', style: GoogleFonts.outfit(
                  fontSize: 18, fontWeight: FontWeight.w600, color: _sub(dark))),
              ],
            ),
            const SizedBox(height: 16),

            // Timeline bar
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                height: 14,
                child: Stack(children: [
                  // Track
                  Container(
                    decoration: BoxDecoration(
                      color: dark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  // Fill with gradient
                  FractionallySizedBox(
                    widthFactor: progress,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [_coral, _peach]),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [BoxShadow(
                          color: _coral.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 2))],
                      ),
                    ),
                  ),
                  // Trimester markers
                  Positioned(
                    left: MediaQuery.of(context).size.width * 0.30 * (13 / 42) - 20,
                    top: 0, bottom: 0,
                    child: Center(child: Container(width: 1.5, height: 14,
                      color: dark ? Colors.white.withOpacity(0.15) : Colors.black.withOpacity(0.12))),
                  ),
                  Positioned(
                    left: MediaQuery.of(context).size.width * 0.30 * (26 / 42) + (MediaQuery.of(context).size.width * 0.55 * (26 / 42)) - 20,
                    top: 0, bottom: 0,
                    child: Center(child: Container(width: 1.5, height: 14,
                      color: dark ? Colors.white.withOpacity(0.15) : Colors.black.withOpacity(0.12))),
                  ),
                ]),
              ),
            ),
            const SizedBox(height: 8),
            // Percentage + labels
            Row(children: [
              Text('$pct% ${l10n.isFrench ? 'complété' : 'complete'}',
                style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: _coral)),
              const Spacer(),
              Text('T1', style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w600,
                color: tri == 1 ? _coral : _sub(dark).withOpacity(0.4))),
              const SizedBox(width: 8),
              Text('T2', style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w600,
                color: tri == 2 ? _lavender : _sub(dark).withOpacity(0.4))),
              const SizedBox(width: 8),
              Text('T3', style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w600,
                color: tri == 3 ? _warmMint : _sub(dark).withOpacity(0.4))),
            ]),
            const SizedBox(height: 18),

            // Stats row
            Container(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              decoration: BoxDecoration(
                color: dark ? Colors.white.withOpacity(0.05) : Colors.white.withOpacity(0.6),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(children: [
                _HeroStat(value: '$left', label: l10n.isFrench ? 'jours restants' : 'days left',
                  icon: LucideIcons.clock, color: _peach),
                Container(width: 1, height: 28,
                  color: dark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.06)),
                _HeroStat(value: due, label: l10n.isFrench ? 'terme estimé' : 'due date',
                  icon: LucideIcons.calendar, color: _sub(dark)),
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  final String value, label;
  final Color color;
  final IconData icon;
  const _HeroStat({required this.value, required this.label, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Expanded(child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 6),
        Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
          Text(value, style: GoogleFonts.outfit(
            fontSize: value.length > 5 ? 12 : 15, fontWeight: FontWeight.w800, color: color)),
          Text(label, style: GoogleFonts.inter(fontSize: 9, color: color.withOpacity(0.7))),
        ]),
      ],
    ));
  }
}

// ═════════════════════════════════════════════════════════════════════════════
//  BABY DEVELOPMENT CARD
// ═════════════════════════════════════════════════════════════════════════════
class _BabyDevCard extends StatelessWidget {
  final int week, tri;
  final Color accent;
  final DailyInsight insight;
  final bool dark;
  final AppL10n l10n;
  final VoidCallback onTap;

  const _BabyDevCard({
    required this.week, required this.tri, required this.accent,
    required this.insight, required this.dark, required this.l10n,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final size = _babySize[week] ?? '';
    final weight = _babyWeight[week] ?? '';
    final dev = _babyDev[week] ?? insight.babyInsight;
    final fruitName = _fruit[week] ?? 'fruit';

    return Container(
      decoration: BoxDecoration(
        color: dark ? const Color(0xFF1A1820) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(
          color: accent.withOpacity(dark ? 0.15 : 0.08),
          blurRadius: 24, offset: const Offset(0, 8),
        )],
      ),
      child: Column(children: [
        Container(
          height: 3,
          margin: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [accent, accent.withOpacity(0.3)]),
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(3)),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  l10n.isFrench ? 'VOTRE BÉBÉ' : 'YOUR BABY',
                  style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w800,
                    color: accent, letterSpacing: 1.5)),
              ),
              const Spacer(),
              Text(
                l10n.isFrench ? 'Comme une $fruitName' : 'Like a $fruitName',
                style: GoogleFonts.inter(fontSize: 11, color: _sub(dark))),
            ]),
            const SizedBox(height: 14),

            // Size + Weight chips
            if (size.isNotEmpty || weight.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Row(children: [
                  if (size.isNotEmpty)
                    Expanded(child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _faint(dark),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(children: [
                        Icon(LucideIcons.ruler, size: 16, color: accent),
                        const SizedBox(height: 4),
                        Text(size, style: GoogleFonts.outfit(
                          fontSize: 18, fontWeight: FontWeight.w800, color: _text(dark))),
                        Text(l10n.isFrench ? 'taille' : 'size', style: GoogleFonts.inter(
                          fontSize: 9, color: _sub(dark))),
                      ]),
                    )),
                  if (size.isNotEmpty && weight.isNotEmpty) const SizedBox(width: 10),
                  if (weight.isNotEmpty)
                    Expanded(child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _faint(dark),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(children: [
                        Icon(LucideIcons.weight, size: 16, color: _peach),
                        const SizedBox(height: 4),
                        Text(weight, style: GoogleFonts.outfit(
                          fontSize: 18, fontWeight: FontWeight.w800, color: _text(dark))),
                        Text(l10n.isFrench ? 'poids' : 'weight', style: GoogleFonts.inter(
                          fontSize: 9, color: _sub(dark))),
                      ]),
                    )),
                ]),
              ),

            // Development text
            Text(dev, style: GoogleFonts.inter(
              fontSize: 14, fontWeight: FontWeight.w500,
              height: 1.5, color: _text(dark))),
            const SizedBox(height: 6),
            Text(insight.babyInsight, style: GoogleFonts.inter(
              fontSize: 12, height: 1.5, color: _sub(dark)),
              maxLines: 3, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 14),

            // CTA
            GestureDetector(
              onTap: () { HapticFeedback.lightImpact(); onTap(); },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Text(
                    l10n.isFrench ? "Voir l'histoire de bébé" : "See baby's story",
                    style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: accent)),
                  const SizedBox(width: 4),
                  Icon(Icons.arrow_forward_rounded, size: 14, color: accent),
                ]),
              ),
            ),
          ]),
        ),
      ]),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
//  TRIMESTER JOURNEY
// ═════════════════════════════════════════════════════════════════════════════
class _TrimesterJourney extends StatelessWidget {
  final int week, tri;
  final bool dark;
  final AppL10n l10n;
  const _TrimesterJourney({
    required this.week, required this.tri, required this.dark, required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final data = [
      (l10n.pregTrim1Short, 'S1–13',  _coral,    l10n.isFrench ? 'Fondations' : 'Foundations'),
      (l10n.pregTrim2Short, 'S14–26', _lavender,  l10n.isFrench ? 'Croissance' : 'Growth'),
      (l10n.pregTrim3Short, 'S27–42', _warmMint,  l10n.isFrench ? 'Préparation' : 'Preparation'),
    ];

    return Row(children: List.generate(3, (i) {
      final (label, range, color, milestone) = data[i];
      final active = i + 1 == tri;
      final done = i + 1 < tri;
      final triWeeks = i == 0 ? 13 : i == 1 ? 13 : 16;
      final triStart = i == 0 ? 1 : i == 1 ? 14 : 27;
      final localProgress = active
          ? ((week - triStart + 1) / triWeeks).clamp(0.0, 1.0)
          : done ? 1.0 : 0.0;

      return Expanded(child: Container(
        margin: EdgeInsets.only(right: i < 2 ? 8 : 0),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: active ? color.withOpacity(0.08) : _faint(dark),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: active ? color.withOpacity(0.3) : Colors.transparent,
            width: active ? 1.5 : 0,
          ),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            if (done)
              Icon(Icons.check_circle_rounded, size: 14, color: color)
            else
              Container(width: 14, height: 14, decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: active ? color : Colors.transparent,
                border: Border.all(color: active ? color : _sub(dark).withOpacity(0.3), width: 1.5),
              )),
            const SizedBox(width: 6),
            Expanded(child: Text(label, style: GoogleFonts.inter(
              fontSize: 10, fontWeight: FontWeight.w700,
              color: active || done ? color : _sub(dark)),
              overflow: TextOverflow.ellipsis)),
          ]),
          const SizedBox(height: 6),
          // Mini progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: SizedBox(height: 3, child: LinearProgressIndicator(
              value: localProgress,
              backgroundColor: dark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.04),
              valueColor: AlwaysStoppedAnimation(color),
            )),
          ),
          const SizedBox(height: 6),
          Text(milestone, style: GoogleFonts.inter(
            fontSize: 9, fontWeight: FontWeight.w600,
            color: active || done ? color.withOpacity(0.8) : _sub(dark).withOpacity(0.5))),
          Text(range, style: GoogleFonts.inter(fontSize: 9, color: _sub(dark).withOpacity(0.5))),
        ]),
      ));
    }));
  }
}

// ═════════════════════════════════════════════════════════════════════════════
//  FEELING RESPONSE
// ═════════════════════════════════════════════════════════════════════════════
class _FeelingResponse extends StatefulWidget {
  final int feeling, week;
  final bool dark;
  const _FeelingResponse({required this.feeling, required this.week, required this.dark});
  @override
  State<_FeelingResponse> createState() => _FeelingResponseState();
}

class _FeelingResponseState extends State<_FeelingResponse>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 350));
  late final Animation<double> _fade =
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);

  @override
  void initState() { super.initState(); _ctrl.forward(); }

  @override
  void didUpdateWidget(_FeelingResponse old) {
    super.didUpdateWidget(old);
    if (old.feeling != widget.feeling) _ctrl.forward(from: 0);
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  static const _responses = <int, (String, String, Color)>{
    0: ('Ton énergie est précieuse — profites-en pour une activité douce.',
        'Une marche de 20 min ou du yoga prénatal serait idéal.', _gold),
    1: ('Les nausées font partie du parcours — ton corps travaille fort.',
        'Gingembre frais, petits repas fréquents, et repos.', _coral),
    2: ('Un bon sommeil est le meilleur cadeau pour toi et bébé.',
        'Essaie un oreiller de grossesse et du magnésium le soir.', _lavender),
    3: ('Les envies de grossesse sont normales — écoute ton corps.',
        'Privilégie des alternatives saines quand c\'est possible.', _peach),
    4: ('Tes émotions sont un signal, pas un problème.',
        'Parle à quelqu\'un de confiance ou note tes pensées.', _warmMint),
  };

  @override
  Widget build(BuildContext context) {
    final (msg, tip, color) = _responses[widget.feeling] ?? _responses[0]!;
    return FadeTransition(
      opacity: _fade,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.06),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 3, height: 44,
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(msg, style: GoogleFonts.inter(
              fontSize: 13, fontWeight: FontWeight.w500,
              height: 1.5, color: _text(widget.dark))),
            const SizedBox(height: 6),
            Text(tip, style: GoogleFonts.inter(
              fontSize: 12, height: 1.5, color: _sub(widget.dark))),
          ])),
        ]),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
//  DAILY TIP CARD
// ═════════════════════════════════════════════════════════════════════════════
class _DailyTipCard extends StatelessWidget {
  final DailyInsight insight;
  final int week;
  final bool dark;
  final AppL10n l10n;
  const _DailyTipCard({
    required this.insight, required this.week, required this.dark, required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final fitLabel = _fitLabel(week);
    final fitTip = _fitTip(week);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: dark
              ? [const Color(0xFF1A1820), const Color(0xFF151518)]
              : [Colors.white, const Color(0xFFFCF9F6)],
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(
          color: Colors.black.withOpacity(dark ? 0.3 : 0.04),
          blurRadius: 16, offset: const Offset(0, 4))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Mom insight
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(
                width: 28, height: 28,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [_lavender, Color(0xFF6B5FA0)]),
                  borderRadius: BorderRadius.circular(8)),
                child: const Icon(LucideIcons.lightbulb, size: 14, color: Colors.white),
              ),
              const SizedBox(width: 10),
              Text(
                l10n.isFrench ? 'Astuce du jour' : 'Daily tip',
                style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w700, color: _text(dark))),
            ]),
            const SizedBox(height: 10),
            Text(insight.momTip, style: GoogleFonts.inter(
              fontSize: 13, height: 1.6, color: _text(dark).withOpacity(0.85))),
          ]),
        ),

        // Divider
        Container(height: 1, margin: const EdgeInsets.symmetric(horizontal: 18),
          color: _faint(dark)),

        // Fitness tip
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 16),
          child: Row(children: [
            Container(
              width: 28, height: 28,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [_warmMint, _deepMint]),
                borderRadius: BorderRadius.circular(8)),
              child: const Icon(LucideIcons.activity, size: 14, color: Colors.white),
            ),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(fitLabel, style: GoogleFonts.inter(
                fontSize: 13, fontWeight: FontWeight.w700, color: _text(dark))),
              Text(fitTip, style: GoogleFonts.inter(
                fontSize: 11, height: 1.5, color: _sub(dark)),
                maxLines: 2, overflow: TextOverflow.ellipsis),
            ])),
          ]),
        ),
      ]),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
//  EXPLORE CARD
// ═════════════════════════════════════════════════════════════════════════════
class _ExploreCard extends StatelessWidget {
  final String label;
  final String? subtitle;
  final IconData icon;
  final List<Color> gradient;
  final bool dark;
  final bool tall;
  final bool wide;
  final VoidCallback onTap;

  const _ExploreCard({
    required this.label, this.subtitle, required this.icon,
    required this.gradient, required this.dark, required this.onTap,
    this.tall = false, this.wide = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () { HapticFeedback.lightImpact(); onTap(); },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: gradient,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(
            color: gradient.first.withOpacity(0.25),
            blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Padding(
          padding: EdgeInsets.all(wide ? 14 : tall ? 16 : 12),
          child: wide
              ? Row(children: [
                  Icon(icon, size: 20, color: Colors.white),
                  const SizedBox(width: 12),
                  Text(label, style: GoogleFonts.outfit(
                    fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
                  const Spacer(),
                  Icon(Icons.arrow_forward_rounded, size: 16, color: Colors.white70),
                ])
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: tall
                      ? MainAxisAlignment.spaceBetween
                      : MainAxisAlignment.center,
                  children: [
                    Container(
                      width: tall ? 40 : 32, height: tall ? 40 : 32,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10)),
                      child: Icon(icon, size: tall ? 20 : 16, color: Colors.white),
                    ),
                    if (tall) ...[
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        if (subtitle != null)
                          Text(subtitle!, style: GoogleFonts.inter(
                            fontSize: 10, color: Colors.white70)),
                        Text(label, style: GoogleFonts.outfit(
                          fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                      ]),
                    ] else ...[
                      const SizedBox(height: 6),
                      Text(label, style: GoogleFonts.outfit(
                        fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white)),
                    ],
                  ],
                ),
        ),
      ),
    );
  }
}
