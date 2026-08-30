// ignore_for_file: deprecated_member_use
import 'package:fiteva/providers/user_profile_provider.dart';
import 'package:fiteva/providers/points_provider.dart';
import 'package:fiteva/screens/cycle/pregnancy/postpartum/postpartum_insight_repository.dart';
import 'package:fiteva/services/pregnancy_content_service.dart';
import 'package:fiteva/services/cycle_log_service.dart';
import 'package:fiteva/widgets/custom_date_picker.dart';
import 'package:fiteva/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

// ── Premium palette ─────────────────────────────────────────────────────────
const _sage      = Color(0xFF5BA88C);
const _deepSage  = Color(0xFF3D8B6E);
const _warmRose  = Color(0xFFE58F8A);
const _amber     = Color(0xFFF4A940);
const _lavender  = Color(0xFF8B7EC8);
const _slate     = Color(0xFF5A7A9E);

Color _bg(bool d)    => d ? const Color(0xFF0E0E11) : const Color(0xFFFAF7F4);
Color _text(bool d)  => d ? const Color(0xFFF5F0EB) : const Color(0xFF1E1A17);
Color _sub(bool d)   => d ? const Color(0xFF9A9498) : const Color(0xFF6D6166);
Color _faint(bool d) => d ? Colors.white.withOpacity(0.05) : const Color(0xFFF0EBE6);

// ─────────────────────────────────────────────────────────────────────────────
class PostpartumHubScreen extends ConsumerStatefulWidget {
  final DateTime birthDate;
  const PostpartumHubScreen({super.key, required this.birthDate});

  @override
  ConsumerState<PostpartumHubScreen> createState() => _PostpartumHubScreenState();
}

class _PostpartumHubScreenState extends ConsumerState<PostpartumHubScreen>
    with SingleTickerProviderStateMixin {
  late DateTime _birthDate;
  int?  _mood;
  bool  _switching = false;

  late final AnimationController _switchAnim = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 550));
  late final Animation<double> _fadeOut =
      Tween<double>(begin: 1, end: 0).animate(
          CurvedAnimation(parent: _switchAnim, curve: Curves.easeInCubic));

  @override
  void initState() {
    super.initState();
    _birthDate = widget.birthDate;
    Future.microtask(() => ref.read(pointsProvider.notifier).rewardPostpartumTask());
    _loadMood();
  }

  Future<void> _loadMood() async {
    final mood = await CycleLogService.loadMood(DateTime.now());
    if (mounted && mood != null) setState(() => _mood = mood);
  }

  @override
  void dispose() {
    _switchAnim.dispose();
    super.dispose();
  }

  // ── Computed ─────────────────────────────────────────────────────────────────
  int get _days  => DateTime.now().difference(_birthDate).inDays.clamp(0, 730);
  int get _weeks => _days ~/ 7;
  int get _rem   => _days % 7;

  String get _phaseName {
    if (_weeks < 2)  return 'Repos absolu';
    if (_weeks < 6)  return 'Reconstruction';
    if (_weeks < 12) return 'Renforcement';
    if (_weeks < 26) return 'Retour actif';
    if (_weeks < 52) return 'Stabilisation';
    return 'Suivi long terme';
  }

  String get _phaseDesc {
    if (_weeks < 2)  return 'Votre corps cicatrise. Le repos est votre entraînement.';
    if (_weeks < 6)  return 'Mobilité douce, périnée et reconnexion au corps.';
    if (_weeks < 12) return 'Renforcement progressif, posture et énergie.';
    if (_weeks < 26) return 'Reprise du sport, reconditionnement musculaire.';
    if (_weeks < 52) return 'Forme retrouvée, corps stabilisé sur la durée.';
    return 'Plus d\'un an déjà — continue d\'écouter ton corps.';
  }

  Color get _phaseColor {
    if (_weeks < 2)  return _warmRose;
    if (_weeks < 6)  return _amber;
    if (_weeks < 12) return _sage;
    if (_weeks < 26) return _deepSage;
    if (_weeks < 52) return _sage;
    return _slate;
  }

  double get _progress => (_weeks / 12).clamp(0.0, 1.0);
  double get _longTermProgress => (_weeks / 52).clamp(0.0, 1.0);
  bool get _isBeyondFourthTrimester => _weeks >= 12;
  bool get _dark => Theme.of(context).brightness == Brightness.dark;

  // ── Pickers ──────────────────────────────────────────────────────────────────
  Future<void> _pickBirthDate() async {
    HapticFeedback.lightImpact();
    final l10n = ref.read(l10nProvider);
    final picked = await showCustomDatePicker(
      context: context,
      initialDate: _birthDate,
      firstDate: DateTime.now().subtract(const Duration(days: 730)),
      lastDate: DateTime.now(),
      title: l10n.ppDateAccouch,
      subtitle: l10n.ppQuandNe,
      icon: Icons.child_care_rounded,
      accentColor: _sage,
    );
    if (picked == null || !mounted) return;
    setState(() => _birthDate = picked);
    await ref.read(userProfileProvider.notifier)
        .updateField('pp_birth_date', picked.toIso8601String());
  }

  Future<void> _switchToCycle() async {
    HapticFeedback.mediumImpact();
    final l10n2 = ref.read(l10nProvider);
    final picked = await showCustomDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 180)),
      lastDate: DateTime.now(),
      title: l10n2.ppMesRegles,
      subtitle: l10n2.ppQuandRegles,
      icon: Icons.water_drop_rounded,
      accentColor: const Color(0xFFD94F6B),
    );
    if (picked == null || !mounted) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(l10n2.ppPasserCycle,
          style: GoogleFonts.outfit(fontSize: 17, fontWeight: FontWeight.w700)),
        content: Text(
          'Votre suivi passera du post-partum au cycle menstruel à partir du '
          '${picked.day}/${picked.month}/${picked.year}.',
          style: GoogleFonts.inter(fontSize: 13, height: 1.5,
              color: const Color(0xFF5A5A5A))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n2.ppAnnuler,
              style: GoogleFonts.inter(color: const Color(0xFF888888)))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD94F6B),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n2.ppConfirmer,
              style: GoogleFonts.inter(fontWeight: FontWeight.w700))),
        ],
      ),
    );
    if (confirm != true || !mounted) return;

    setState(() => _switching = true);
    await _switchAnim.forward();
    if (!mounted) return;

    final notifier = ref.read(userProfileProvider.notifier);
    await notifier.updateField('health_status', 'cycle');
    await notifier.updateField('last_period', picked.toIso8601String());
    await notifier.updateField('pp_recovery', null);
    await notifier.updateField('pp_duration', null);
    await notifier.updateField('pp_birth_date', null);

    if (mounted) Navigator.maybePop(context);
  }

  // ── Build ─────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final l10n    = ref.watch(l10nProvider);
    final dark    = _dark;
    final insightWeek = _weeks.clamp(1, 104);
    final insight = ref.watch(postpartumInsightProvider(insightWeek)).asData?.value
        ?? PostpartumInsightRepository.forWeek(insightWeek);
    final d       = _birthDate;
    final months  = ['janv.','févr.','mars','avr.','mai','juin',
                     'juil.','août','sept.','oct.','nov.','déc.'];
    final dateStr = '${d.day} ${months[d.month - 1]} ${d.year}';
    final progress = _isBeyondFourthTrimester ? _longTermProgress : _progress;
    final pct = (progress * 100).round();

    return Scaffold(
      backgroundColor: _bg(dark),
      body: FadeTransition(
        opacity: _fadeOut,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [

            // ═══════════════════════════════════════════════════════════════
            //  HERO — timeline bar + stats
            // ═══════════════════════════════════════════════════════════════
            _buildHero(dark, l10n, progress, pct),

            // ═══════════════════════════════════════════════════════════════
            //  PHASE CARD — overlapping hero
            // ═══════════════════════════════════════════════════════════════
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
              child: Transform.translate(
                offset: const Offset(0, -20),
                child: _buildPhaseCard(dark),
              ),
            ),

            // ═══════════════════════════════════════════════════════════════
            //  RECOVERY TIMELINE
            // ═══════════════════════════════════════════════════════════════
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
              child: _buildRecoveryTimeline(dark),
            ),

            // ═══════════════════════════════════════════════════════════════
            //  DATE + EDIT
            // ═══════════════════════════════════════════════════════════════
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
              child: _buildDateCard(dark, l10n, dateStr),
            ),

            // ═══════════════════════════════════════════════════════════════
            //  MOOD CHECK-IN
            // ═══════════════════════════════════════════════════════════════
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
              child: _buildMoodSection(dark, l10n),
            ),

            // ═══════════════════════════════════════════════════════════════
            //  WEEKLY INSIGHTS
            // ═══════════════════════════════════════════════════════════════
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
              child: _buildInsights(dark, l10n, insight),
            ),

            // ═══════════════════════════════════════════════════════════════
            //  RECOVERY TIPS
            // ═══════════════════════════════════════════════════════════════
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
              child: _buildTips(dark),
            ),

            SizedBox(height: MediaQuery.of(context).padding.bottom + 80),
          ]),
        ),
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════════════════════
  //  HERO
  // ═════════════════════════════════════════════════════════════════════════════
  Widget _buildHero(bool dark, AppL10n l10n, double progress, int pct) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: dark
              ? [const Color(0xFF141A18), const Color(0xFF101210), _bg(true)]
              : [const Color(0xFFE8F0EB), const Color(0xFFDFEDE4), const Color(0xFFF2F7F4), _bg(false)],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 16, 40),
          child: Column(children: [
            // Header
            Row(children: [
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.ppTitle, style: GoogleFonts.inter(
                    fontSize: 10, fontWeight: FontWeight.w600,
                    letterSpacing: 1.5, color: _sub(dark))),
                  const SizedBox(height: 2),
                  Text(l10n.ppTrim4, style: GoogleFonts.outfit(
                    fontSize: 22, fontWeight: FontWeight.w700, color: _text(dark))),
                ],
              )),
              PopupMenuButton<String>(
                enabled: !_switching,
                onSelected: (v) {
                  if (v == 'cycle') _switchToCycle();
                },
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 4,
                color: dark ? const Color(0xFF1E1E1E) : Colors.white,
                offset: const Offset(0, 44),
                itemBuilder: (_) => [
                  PopupMenuItem(
                    value: 'cycle',
                    child: Row(children: [
                      const Icon(Icons.water_drop_rounded,
                          size: 16, color: Color(0xFFD94F6B)),
                      const SizedBox(width: 10),
                      Text(l10n.ppMesRegles, style: GoogleFonts.inter(
                        fontSize: 13, fontWeight: FontWeight.w600,
                        color: const Color(0xFFD94F6B))),
                    ]),
                  ),
                ],
                child: Icon(Icons.more_horiz_rounded, size: 22,
                  color: _text(dark).withOpacity(0.6)),
              ),
            ]),
            const SizedBox(height: 28),

            // Big week/day number
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text('S', style: GoogleFonts.outfit(
                  fontSize: 16, fontWeight: FontWeight.w600, color: _sage)),
                Text('$_weeks', style: GoogleFonts.outfit(
                  fontSize: 52, fontWeight: FontWeight.w900, color: _text(dark), height: 1)),
                Text(' +${_rem}j', style: GoogleFonts.outfit(
                  fontSize: 16, fontWeight: FontWeight.w600, color: _sub(dark))),
              ],
            ),
            const SizedBox(height: 16),

            // Timeline bar
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                height: 14,
                child: Stack(children: [
                  Container(
                    decoration: BoxDecoration(
                      color: dark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: progress,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [_sage, _deepSage]),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [BoxShadow(
                          color: _sage.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 2))],
                      ),
                    ),
                  ),
                ]),
              ),
            ),
            const SizedBox(height: 8),
            Row(children: [
              Text('$pct% ${l10n.isFrench ? 'récupération' : 'recovery'}',
                style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: _sage)),
              const Spacer(),
              Text(_isBeyondFourthTrimester ? 'S52' : 'S12',
                style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w600, color: _sub(dark))),
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
                _buildHeroStat('$_weeks', l10n.isFrench ? 'semaines' : 'weeks',
                  LucideIcons.calendar, _sage, dark),
                Container(width: 1, height: 28,
                  color: dark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.06)),
                _buildHeroStat('$_days', l10n.isFrench ? 'jours' : 'days',
                  LucideIcons.clock, _sub(dark), dark),
              ]),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _buildHeroStat(String value, String label, IconData icon, Color color, bool dark) {
    return Expanded(child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 6),
        Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
          Text(value, style: GoogleFonts.outfit(
            fontSize: 15, fontWeight: FontWeight.w800, color: color)),
          Text(label, style: GoogleFonts.inter(fontSize: 9, color: color.withOpacity(0.7))),
        ]),
      ],
    ));
  }

  // ═════════════════════════════════════════════════════════════════════════════
  //  PHASE CARD
  // ═════════════════════════════════════════════════════════════════════════════
  Widget _buildPhaseCard(bool dark) {
    return Container(
      decoration: BoxDecoration(
        color: dark ? const Color(0xFF1A1820) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(
          color: _phaseColor.withOpacity(dark ? 0.15 : 0.08),
          blurRadius: 24, offset: const Offset(0, 8),
        )],
      ),
      child: Column(children: [
        Container(
          height: 3,
          margin: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [_phaseColor, _phaseColor.withOpacity(0.3)]),
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(3)),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(18),
          child: Row(children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: _phaseColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(LucideIcons.sprout, size: 22, color: _phaseColor),
            ),
            const SizedBox(width: 14),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _phaseColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(_phaseName.toUpperCase(), style: GoogleFonts.inter(
                    fontSize: 9, fontWeight: FontWeight.w800,
                    color: _phaseColor, letterSpacing: 1.5)),
                ),
                const SizedBox(height: 6),
                Text(_phaseDesc, style: GoogleFonts.inter(
                  fontSize: 13, color: _sub(dark), height: 1.5)),
              ],
            )),
          ]),
        ),
      ]),
    );
  }

  // ═════════════════════════════════════════════════════════════════════════════
  //  RECOVERY TIMELINE
  // ═════════════════════════════════════════════════════════════════════════════
  Widget _buildRecoveryTimeline(bool dark) {
    final phases = <(String, int, int, Color)>[
      ('Repos', 0, 2, _warmRose),
      ('Reconstruction', 2, 6, _amber),
      ('Renforcement', 6, 12, _sage),
      ('Retour actif', 12, 26, _deepSage),
      ('Stabilisation', 26, 52, _slate),
    ];

    int activeIdx = 0;
    for (int i = 0; i < phases.length; i++) {
      if (_weeks >= phases[i].$2) activeIdx = i;
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: dark ? const Color(0xFF1A1820) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(
          color: Colors.black.withOpacity(dark ? 0.2 : 0.04),
          blurRadius: 16, offset: const Offset(0, 4))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(
          'PARCOURS DE RÉCUPÉRATION',
          style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w700,
            color: _sub(dark), letterSpacing: 1.8),
        ),
        const SizedBox(height: 14),
        Row(children: List.generate(phases.length, (i) {
          final (_, start, end, color) = phases[i];
          final isActive = i == activeIdx;
          final isPast = i < activeIdx;
          return Expanded(
            flex: end - start,
            child: Container(
              margin: EdgeInsets.only(right: i < phases.length - 1 ? 3 : 0),
              height: isActive ? 10 : 6,
              decoration: BoxDecoration(
                color: isPast || isActive ? color : color.withOpacity(0.18),
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          );
        })),
        const SizedBox(height: 12),
        // Phase labels
        Row(children: [
          for (int i = 0; i < phases.length; i++) ...[
            if (i > 0) const Spacer(),
            Text(
              i == activeIdx ? phases[i].$1 : 'S${phases[i].$2}',
              style: GoogleFonts.inter(
                fontSize: 9,
                fontWeight: i == activeIdx ? FontWeight.w700 : FontWeight.w500,
                color: i == activeIdx ? phases[i].$4 : _sub(dark).withOpacity(0.5)),
            ),
          ],
        ]),
      ]),
    );
  }

  // ═════════════════════════════════════════════════════════════════════════════
  //  DATE CARD
  // ═════════════════════════════════════════════════════════════════════════════
  Widget _buildDateCard(bool dark, AppL10n l10n, String dateStr) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: dark ? const Color(0xFF1A1820) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(
          color: Colors.black.withOpacity(dark ? 0.2 : 0.04),
          blurRadius: 16, offset: const Offset(0, 4))],
      ),
      child: Row(children: [
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(
            color: _sage.withOpacity(0.12),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(LucideIcons.calendar, size: 20, color: _sage),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.ppDateAccouch, style: GoogleFonts.inter(
              fontSize: 11, fontWeight: FontWeight.w500, color: _sub(dark))),
            const SizedBox(height: 3),
            Text(dateStr, style: GoogleFonts.outfit(
              fontSize: 17, fontWeight: FontWeight.w700, color: _text(dark))),
            Text(l10n.ppDaysNaissance(_days), style: GoogleFonts.inter(
              fontSize: 11, color: _sub(dark))),
          ],
        )),
        GestureDetector(
          onTap: _pickBirthDate,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: _sage.withOpacity(0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(l10n.ppModifier, style: GoogleFonts.inter(
              fontSize: 12, fontWeight: FontWeight.w700, color: _sage)),
          ),
        ),
      ]),
    );
  }

  // ═════════════════════════════════════════════════════════════════════════════
  //  MOOD CHECK-IN — Lucide icons
  // ═════════════════════════════════════════════════════════════════════════════
  static const _moodIcons = [LucideIcons.frown, LucideIcons.meh, LucideIcons.smile, LucideIcons.sun, LucideIcons.sparkles];
  static const _moodLabels = ['Difficile', 'Neutre', 'Bien', 'Très bien', 'Super'];
  static const _moodColors = [_warmRose, _amber, _sage, _deepSage, _lavender];

  Widget _buildMoodSection(bool dark, AppL10n l10n) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(l10n.ppCommentSentez, style: GoogleFonts.outfit(
        fontSize: 18, fontWeight: FontWeight.w700, color: _text(dark))),
      const SizedBox(height: 14),
      Row(children: List.generate(5, (i) {
        final sel = _mood == i;
        final color = _moodColors[i];
        return Expanded(
          child: GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _mood = i);
              CycleLogService.saveMood(DateTime.now(), i);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.only(right: i < 4 ? 6 : 0),
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                gradient: sel ? LinearGradient(
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                  colors: [color, color.withOpacity(0.7)],
                ) : null,
                color: sel ? null : _faint(dark),
                borderRadius: BorderRadius.circular(16),
                boxShadow: sel ? [BoxShadow(
                  color: color.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 3))] : null,
              ),
              child: Column(children: [
                Icon(_moodIcons[i], size: sel ? 24 : 20,
                  color: sel ? Colors.white : _sub(dark)),
                const SizedBox(height: 6),
                Text(_moodLabels[i], style: GoogleFonts.inter(
                  fontSize: 9, fontWeight: FontWeight.w600,
                  color: sel ? Colors.white : _sub(dark)),
                  textAlign: TextAlign.center),
              ]),
            ),
          ),
        );
      })),
    ]);
  }

  // ═════════════════════════════════════════════════════════════════════════════
  //  WEEKLY INSIGHTS
  // ═════════════════════════════════════════════════════════════════════════════
  Widget _buildInsights(bool dark, AppL10n l10n, PostpartumInsight insight) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Semaine $_weeks — ${insight.title}',
        style: GoogleFonts.outfit(
          fontSize: 18, fontWeight: FontWeight.w700, color: _text(dark))),
      const SizedBox(height: 14),

      _insightCard(
        icon: LucideIcons.baby,
        label: l10n.ppVotreBebe,
        text: insight.babyMilestone,
        color: _sage,
        dark: dark,
      ),
      const SizedBox(height: 10),
      _insightCard(
        icon: LucideIcons.heartPulse,
        label: l10n.ppVotreCorps,
        text: insight.momRecovery,
        color: _warmRose,
        dark: dark,
      ),
      const SizedBox(height: 10),
      _insightCard(
        icon: LucideIcons.brain,
        label: l10n.ppVotreMental,
        text: insight.mentalHealth,
        color: _lavender,
        dark: dark,
      ),

      if (insight.poeticLine.isNotEmpty) ...[
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft, end: Alignment.bottomRight,
              colors: dark
                  ? [_sage.withOpacity(0.08), _sage.withOpacity(0.03)]
                  : [_sage.withOpacity(0.06), _sage.withOpacity(0.02)],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _sage.withOpacity(0.12)),
          ),
          child: Row(children: [
            Icon(LucideIcons.quote, size: 18, color: _sage.withOpacity(0.5)),
            const SizedBox(width: 12),
            Expanded(child: Text('"${insight.poeticLine}"',
              style: GoogleFonts.inter(
                fontSize: 13, fontStyle: FontStyle.italic,
                color: _text(dark).withOpacity(0.75), height: 1.7))),
          ]),
        ),
      ],
    ]);
  }

  Widget _insightCard({
    required IconData icon, required String label, required String text,
    required Color color, required bool dark,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: dark ? const Color(0xFF1A1820) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(
          color: color.withOpacity(dark ? 0.12 : 0.06),
          blurRadius: 16, offset: const Offset(0, 4))],
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft, end: Alignment.bottomRight,
              colors: [color.withOpacity(0.15), color.withOpacity(0.08)],
            ),
            borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, size: 18, color: color),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label.toUpperCase(), style: GoogleFonts.inter(
              fontSize: 9, fontWeight: FontWeight.w700,
              color: color, letterSpacing: 1.8)),
            const SizedBox(height: 6),
            Text(text, style: GoogleFonts.inter(
              fontSize: 13, color: _text(dark).withOpacity(0.85), height: 1.55)),
          ],
        )),
      ]),
    );
  }

  // ═════════════════════════════════════════════════════════════════════════════
  //  RECOVERY TIPS
  // ═════════════════════════════════════════════════════════════════════════════
  Widget _buildTips(bool dark) {
    final categories = <(String, IconData, Color)>[
      ('Nutrition', LucideIcons.apple, _sage),
      ('Exercice', LucideIcons.dumbbell, _deepSage),
      ('Repos', LucideIcons.moon, _amber),
      ('Mental', LucideIcons.brain, _warmRose),
    ];

    final tipsByPhase = <int, List<String>>{
      0: [
        'Hydratez-vous beaucoup, surtout si vous allaitez.',
        'Repos total — pas de sport, laissez votre corps cicatriser.',
        'Dormez quand bébé dort, chaque minute compte.',
        'Acceptez l\'aide. Parler de vos émotions est essentiel.',
      ],
      1: [
        'Fer, protéines et calcium — les bases de la reconstruction.',
        'Marche douce 15 min par jour, pas plus.',
        'Siestes courtes et régulières pour restaurer l\'énergie.',
        'Baby blues ou plus ? N\'hésitez pas à consulter.',
      ],
      2: [
        'Repas équilibrés avec des oméga-3 pour l\'énergie.',
        'Périnée et gainage doux — posez les bases.',
        'Établissez une routine de coucher régulière.',
        'Prenez du temps rien que pour vous, même 10 minutes.',
      ],
      3: [
        'Augmentez les portions si vous êtes active.',
        'Reprise progressive du sport avec validation médicale.',
        'Qualité du sommeil > quantité — rituels du soir.',
        'Reconnectez-vous avec vos passions et vos amies.',
      ],
      4: [
        'Alimentation variée, pas de régime restrictif.',
        'Votre corps est prêt pour une activité régulière.',
        'Le sommeil s\'améliore — profitez-en pour récupérer.',
        'Fierté et bienveillance — regardez tout le chemin parcouru.',
      ],
    };

    int phaseIdx;
    if (_weeks < 2)  phaseIdx = 0;
    else if (_weeks < 6) phaseIdx = 1;
    else if (_weeks < 12) phaseIdx = 2;
    else if (_weeks < 26) phaseIdx = 3;
    else phaseIdx = 4;

    final tips = tipsByPhase[phaseIdx]!;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(
        'CONSEILS RÉCUPÉRATION',
        style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w700,
          color: _sub(dark), letterSpacing: 1.8),
      ),
      const SizedBox(height: 12),
      ...List.generate(categories.length, (i) {
        final (name, icon, color) = categories[i];
        return Padding(
          padding: EdgeInsets.only(bottom: i < 3 ? 10 : 0),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: dark ? const Color(0xFF1A1820) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(
                color: color.withOpacity(dark ? 0.10 : 0.05),
                blurRadius: 12, offset: const Offset(0, 3))],
            ),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                width: 38, height: 38,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                    colors: [color, color.withOpacity(0.7)],
                  ),
                  borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, size: 18, color: Colors.white),
              ),
              const SizedBox(width: 14),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name.toUpperCase(), style: GoogleFonts.inter(
                    fontSize: 9, fontWeight: FontWeight.w700,
                    color: color, letterSpacing: 1.8)),
                  const SizedBox(height: 4),
                  Text(tips[i], style: GoogleFonts.inter(
                    fontSize: 13, height: 1.5,
                    color: _text(dark).withOpacity(0.75)),
                    maxLines: 3, overflow: TextOverflow.ellipsis),
                ],
              )),
            ]),
          ),
        );
      }),
    ]);
  }
}
