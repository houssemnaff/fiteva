// ignore_for_file: deprecated_member_use
import 'dart:math' as math;
import 'package:fiteva/providers/user_profile_provider.dart';
import 'package:fiteva/providers/points_provider.dart';
import 'package:fiteva/screens/cycle/pregnancy/postpartum/postpartum_insight_repository.dart';
import 'package:fiteva/services/pregnancy_content_service.dart';
import 'package:fiteva/screens/cycle/pregnancy/pregnancy_colors.dart';
import 'package:fiteva/services/cycle_log_service.dart';
import 'package:fiteva/widgets/custom_date_picker.dart';
import 'package:fiteva/widgets/shared_app_header.dart';
import 'package:fiteva/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

extension _Pg on BuildContext {
  PgColors get p => PgColors.of(this);
}

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
  late final Animation<double> _scaleDown =
      Tween<double>(begin: 1, end: 0.94).animate(
          CurvedAnimation(parent: _switchAnim, curve: Curves.easeInCubic));

  @override
  void initState() {
    super.initState();
    _birthDate = widget.birthDate;
    Future.microtask(() => ref.read(pointsProvider.notifier).rewardPostpartumTask());
    // L'humeur n'était jamais sauvegardée (setState local uniquement) —
    // on réutilise le même stockage que le suivi de cycle (cycle_daily_logs).
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

  // Au-delà de 26 semaines, tout se regroupait dans un unique bucket
  // "Forme retrouvee" jusqu'à 730 jours (~104 semaines) — deux ajouts pour
  // que le contenu continue d'évoluer sur le long terme au lieu de rester
  // figé pendant ~1 an et demi.
  String get _phaseName {
    if (_weeks < 2)  return 'Repos absolu';
    if (_weeks < 6)  return 'Reconstruction';
    if (_weeks < 12) return 'Renforcement';
    if (_weeks < 26) return 'Retour actif';
    if (_weeks < 52) return 'Stabilisation';
    return 'Suivi long terme';
  }

  String get _phaseDesc {
    if (_weeks < 2)  return 'Votre corps cicatrise. Le repos est votre entrainement.';
    if (_weeks < 6)  return 'Mobilite douce, perinee et reconnexion au corps.';
    if (_weeks < 12) return 'Renforcement progressif, posture et energie.';
    if (_weeks < 26) return 'Reprise du sport, reconditionnement musculaire.';
    if (_weeks < 52) return 'Forme retrouvee, corps stabilise sur la duree.';
    return 'Plus d\'un an deja — continue d\'ecouter ton corps.';
  }

  Color get _phaseColor {
    if (_weeks < 2)  return const Color(0xFFE58F8A);
    if (_weeks < 6)  return const Color(0xFFF4A940);
    if (_weeks < 12) return const Color(0xFF7ABB98);
    if (_weeks < 26) return Theme.of(context).colorScheme.primary;
    if (_weeks < 52) return Theme.of(context).colorScheme.primary;
    return const Color(0xFF5A7A9E);
  }

  // Progression du 4e trimestre (0-12 semaines) — reste pertinente pour la
  // carte dédiée. Au-delà, on ne la laisse plus figée à 100% indéfiniment
  // (ce qui donnait l'impression trompeuse d'une "récupération terminée"
  // pour une utilisatrice à 50+ semaines) : l'anneau principal bascule sur
  // une échelle longue durée jusqu'à 1 an, avec un habillage différent.
  double get _progress => (_weeks / 12).clamp(0.0, 1.0);
  double get _longTermProgress => (_weeks / 52).clamp(0.0, 1.0);
  bool get _isBeyondFourthTrimester => _weeks >= 12;

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
      accentColor: Theme.of(context).colorScheme.primary,
    );
    if (picked == null || !mounted) return;
    setState(() => _birthDate = picked);
    // La correction manuelle de la date n'était jusqu'ici jamais sauvegardée
    // (setState local uniquement) — elle se perdait à la moindre reconstruction.
    await ref.read(userProfileProvider.notifier)
        .updateField('pp_birth_date', picked.toIso8601String());
  }

  Future<void> _switchToCycle() async {
    HapticFeedback.mediumImpact();

    // Étape 1 — Calendrier custom
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

    // Étape 2 — Confirmation
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(l10n2.ppPasserCycle,
          style: GoogleFonts.outfit(fontSize: 17, fontWeight: FontWeight.w700)),
        content: Text(
          'Votre suivi passera du post-partum au cycle menstruel a partir du '
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

    // Étape 3 — Animation de sortie
    setState(() => _switching = true);
    await _switchAnim.forward();
    if (!mounted) return;

    // Étape 4 — Sauvegarder et recharger le profil
    final notifier = ref.read(userProfileProvider.notifier);
    await notifier.updateField('health_status', 'cycle');
    await notifier.updateField('last_period', picked.toIso8601String());
    await notifier.updateField('pp_recovery', null);
    await notifier.updateField('pp_duration', null);
    // Oubliée précédemment : laissait une date de naissance fantôme sur le
    // profil après un passage explicite au mode cycle.
    await notifier.updateField('pp_birth_date', null);

    if (mounted) Navigator.maybePop(context);
  }

  // ── Build ─────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final l10n    = ref.watch(l10nProvider);
    final p       = context.p;
    final insightWeek = _weeks.clamp(1, 104);
    final insight = ref.watch(postpartumInsightProvider(insightWeek)).asData?.value
        ?? PostpartumInsightRepository.forWeek(insightWeek);
    final d       = _birthDate;
    final months  = ['janv.','fevr.','mars','avr.','mai','juin',
                     'juil.','aout','sept.','oct.','nov.','dec.'];
    final dateStr = '${d.day} ${months[d.month - 1]} ${d.year}';

    return Scaffold(
      backgroundColor: p.bg,
      body: AnimatedBuilder(
        animation: _switchAnim,
        builder: (context, child) => FadeTransition(
          opacity: _fadeOut,
          child: ScaleTransition(scale: _scaleDown, child: child),
        ),
        child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Shared header ────────────────────────────────────────────────
          SharedAppHeader.sliver(
            eyebrow: l10n.ppTitle,
            title: l10n.ppTrim4,
            accentColor: p.green,
            bgColor: p.surface,
            actions: [
              PopupMenuButton<String>(
                enabled: !_switching,
                onSelected: (v) {
                  if (v == 'cycle') _switchToCycle();
                },
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                elevation: 4,
                color: Colors.white,
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
                child: Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: p.mintLight,
                    shape: BoxShape.circle,
                    border: Border.all(color: p.border),
                  ),
                  child: Icon(Icons.more_horiz_rounded,
                      size: 18, color: p.green),
                ),
              ),
            ],
          ),

          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ── Hero ring ────────────────────────────────────────────
                _RingHero(
                  weeks: _weeks,
                  rem: _rem,
                  phaseName: _phaseName,
                  phaseDesc: _phaseDesc,
                  phaseColor: _phaseColor,
                  progress: _isBeyondFourthTrimester ? _longTermProgress : _progress,
                  p: p,
                ),

                // ── Countdown numbers ────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _CountdownRow(
                    weeks: _weeks, days: _days,
                    phaseName: _phaseName, p: p,
                  ),
                ),

                const SizedBox(height: 16),

                // ── Recovery timeline ────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _RecoveryTimeline(weeks: _weeks, p: p),
                ),

                const SizedBox(height: 16),

                // ── Date d'accouchement ──────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _DateCard(
                    dateStr: dateStr,
                    days: _days,
                    onEdit: _pickBirthDate,
                    p: p,
                    l10n: l10n,
                  ),
                ),

                const SizedBox(height: 16),

                // ── Mood (emoji) ─────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _EmojiMoodCard(
                    selected: _mood,
                    onSelect: (i) {
                      HapticFeedback.selectionClick();
                      setState(() => _mood = i);
                      CycleLogService.saveMood(DateTime.now(), i);
                    },
                    p: p,
                    l10n: l10n,
                  ),
                ),

                const SizedBox(height: 20),

                // ── Week insight (3 separate cards) ──────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _SplitInsights(
                    insight: insight, weeks: _weeks, p: p, l10n: l10n,
                  ),
                ),

                const SizedBox(height: 20),

                // ── Recovery tips carousel ───────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _RecoveryTipsCarousel(weeks: _weeks, p: p),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
        ), // CustomScrollView
      ), // AnimatedBuilder
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  RING HERO  (centered circular recovery ring)
// ─────────────────────────────────────────────────────────────────────────────
class _RingHero extends StatelessWidget {
  final int weeks, rem;
  final String phaseName, phaseDesc;
  final Color phaseColor;
  final double progress;
  final PgColors p;

  const _RingHero({
    required this.weeks, required this.rem,
    required this.phaseName, required this.phaseDesc,
    required this.phaseColor, required this.progress, required this.p,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(children: [
        SizedBox(
          width: 160, height: 160,
          child: CustomPaint(
            painter: _RecoveryRingPainter(
              progress: progress,
              trackColor: p.green.withOpacity(0.12),
              fillColor: p.green,
              dotColor: phaseColor,
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('🌿', style: const TextStyle(fontSize: 32)),
                  const SizedBox(height: 2),
                  Text('S$weeks', style: GoogleFonts.outfit(
                    fontSize: 26, fontWeight: FontWeight.w900,
                    color: p.textDark)),
                  Text('+$rem j', style: GoogleFonts.inter(
                    fontSize: 12, color: p.textMid,
                    fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: phaseColor.withOpacity(0.10),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: phaseColor.withOpacity(0.25)),
          ),
          child: Text(phaseName.toUpperCase(), style: GoogleFonts.inter(
            fontSize: 10, fontWeight: FontWeight.w700,
            color: phaseColor, letterSpacing: 2)),
        ),
        const SizedBox(height: 8),
        Text(phaseDesc, style: GoogleFonts.inter(
          fontSize: 13, color: p.textMid, height: 1.5),
          textAlign: TextAlign.center),
      ]),
    );
  }
}

class _RecoveryRingPainter extends CustomPainter {
  final double progress;
  final Color trackColor, fillColor, dotColor;

  _RecoveryRingPainter({
    required this.progress, required this.trackColor,
    required this.fillColor, required this.dotColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;
    const strokeWidth = 9.0;
    const startAngle = -math.pi / 2;

    canvas.drawCircle(center, radius, Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round);

    final sweepAngle = 2 * math.pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle, sweepAngle, false,
      Paint()
        ..color = fillColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );

    final dotAngle = startAngle + sweepAngle;
    final dx = center.dx + radius * math.cos(dotAngle);
    final dy = center.dy + radius * math.sin(dotAngle);
    canvas.drawCircle(Offset(dx, dy), 6,
      Paint()..color = Colors.white);
    canvas.drawCircle(Offset(dx, dy), 4,
      Paint()..color = dotColor);
  }

  @override
  bool shouldRepaint(_RecoveryRingPainter old) =>
      old.progress != progress || old.fillColor != fillColor;
}

// ─────────────────────────────────────────────────────────────────────────────
//  COUNTDOWN ROW  (3 key numbers)
// ─────────────────────────────────────────────────────────────────────────────
class _CountdownRow extends StatelessWidget {
  final int weeks, days;
  final String phaseName;
  final PgColors p;

  const _CountdownRow({
    required this.weeks, required this.days,
    required this.phaseName, required this.p,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      ('$weeks', 'Semaines', p.green),
      ('$days', 'Jours', p.mint),
      (phaseName, 'Phase', p.textMid),
    ];

    return Row(children: List.generate(items.length, (i) {
      final (value, label, color) = items[i];
      return Expanded(
        child: Container(
          margin: EdgeInsets.only(right: i < 2 ? 8 : 0),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          decoration: BoxDecoration(
            color: p.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: p.border),
          ),
          child: Column(children: [
            Text(value, style: GoogleFonts.outfit(
              fontSize: value.length > 6 ? 11 : 24,
              fontWeight: FontWeight.w800,
              color: color),
              textAlign: TextAlign.center,
              maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 3),
            Text(label, style: GoogleFonts.inter(
              fontSize: 10, color: p.textSoft),
              textAlign: TextAlign.center),
          ]),
        ),
      );
    }));
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  RECOVERY TIMELINE  (visual phase segments with marker)
// ─────────────────────────────────────────────────────────────────────────────
class _RecoveryTimeline extends StatelessWidget {
  final int weeks;
  final PgColors p;

  const _RecoveryTimeline({required this.weeks, required this.p});

  static const _phases = [
    ('Repos', 0, 2, Color(0xFFE58F8A)),
    ('Reconstruction', 2, 6, Color(0xFFF4A940)),
    ('Renforcement', 6, 12, Color(0xFF7ABB98)),
    ('Retour actif', 12, 26, Color(0xFF1C4D30)),
    ('Stabilisation', 26, 52, Color(0xFF5A7A9E)),
  ];

  @override
  Widget build(BuildContext context) {
    int activeIdx = 0;
    for (int i = 0; i < _phases.length; i++) {
      if (weeks >= _phases[i].$2) activeIdx = i;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: p.border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('PARCOURS DE RÉCUPÉRATION', style: GoogleFonts.inter(
          fontSize: 9, fontWeight: FontWeight.w700,
          color: p.textSoft, letterSpacing: 1.8)),
        const SizedBox(height: 14),
        Row(children: List.generate(_phases.length, (i) {
          final (_, start, end, color) = _phases[i];
          final isActive = i == activeIdx;
          final isPast = i < activeIdx;
          return Expanded(
            flex: end - start,
            child: Container(
              margin: EdgeInsets.only(right: i < _phases.length - 1 ? 3 : 0),
              height: isActive ? 8 : 5,
              decoration: BoxDecoration(
                color: isPast || isActive
                    ? color
                    : color.withOpacity(0.18),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          );
        })),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('S0', style: GoogleFonts.inter(
              fontSize: 9, color: p.textSoft)),
            Text('S$weeks', style: GoogleFonts.inter(
              fontSize: 9, fontWeight: FontWeight.w700,
              color: _phases[activeIdx].$4)),
            Text('S52', style: GoogleFonts.inter(
              fontSize: 9, color: p.textSoft)),
          ],
        ),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Date card
// ─────────────────────────────────────────────────────────────────────────────
class _DateCard extends StatelessWidget {
  final String dateStr;
  final int days;
  final VoidCallback onEdit;
  final PgColors p;
  final AppL10n l10n;

  const _DateCard({
    required this.dateStr, required this.days,
    required this.onEdit, required this.p, required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: p.border),
      ),
      child: Row(children: [
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(
            color: p.mintLight,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(LucideIcons.calendar, size: 20, color: p.green),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.ppDateAccouch, style: GoogleFonts.inter(
              fontSize: 11, fontWeight: FontWeight.w500, color: p.textSoft)),
            const SizedBox(height: 3),
            Text(dateStr, style: GoogleFonts.outfit(
              fontSize: 17, fontWeight: FontWeight.w700, color: p.textDark)),
            Text(l10n.ppDaysNaissance(days), style: GoogleFonts.inter(
              fontSize: 11, color: p.textMid)),
          ],
        )),
        GestureDetector(
          onTap: onEdit,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: p.mintLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(l10n.ppModifier, style: GoogleFonts.inter(
              fontSize: 12, fontWeight: FontWeight.w700, color: p.green)),
          ),
        ),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  EMOJI MOOD CARD
// ─────────────────────────────────────────────────────────────────────────────
class _EmojiMoodCard extends StatelessWidget {
  final int? selected;
  final ValueChanged<int> onSelect;
  final PgColors p;
  final AppL10n l10n;

  static const _emojis = ['😣', '😐', '😊', '☀️', '✨'];
  static const _labels = ['Difficile', 'Neutre', 'Bien', 'Très bien', 'Super'];

  const _EmojiMoodCard({
    required this.selected, required this.onSelect,
    required this.p, required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: p.border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(l10n.ppCommentSentez, style: GoogleFonts.inter(
          fontSize: 13, fontWeight: FontWeight.w700, color: p.textDark)),
        const SizedBox(height: 14),
        Row(children: List.generate(5, (i) {
          final sel = selected == i;
          return Expanded(
            child: GestureDetector(
              onTap: () => onSelect(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: EdgeInsets.only(right: i < 4 ? 6 : 0),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: sel ? p.green : p.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: sel ? p.green : p.border, width: 1),
                ),
                child: Column(children: [
                  Text(_emojis[i], style: TextStyle(fontSize: sel ? 24 : 20)),
                  const SizedBox(height: 4),
                  Text(_labels[i], style: GoogleFonts.inter(
                    fontSize: 9, fontWeight: FontWeight.w600,
                    color: sel ? Colors.white : p.textSoft),
                    textAlign: TextAlign.center),
                ]),
              ),
            ),
          );
        })),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  SPLIT INSIGHTS  (3 separate colored cards)
// ─────────────────────────────────────────────────────────────────────────────
class _SplitInsights extends StatelessWidget {
  final PostpartumInsight insight;
  final int weeks;
  final PgColors p;
  final AppL10n l10n;

  const _SplitInsights({
    required this.insight, required this.weeks,
    required this.p, required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Semaine $weeks — ${insight.title}',
        style: GoogleFonts.outfit(
          fontSize: 17, fontWeight: FontWeight.w700, color: p.textDark)),
      const SizedBox(height: 12),

      // Baby milestone (mint)
      _ColoredInsightCard(
        icon: LucideIcons.baby,
        label: l10n.ppVotreBebe,
        text: insight.babyMilestone,
        color: p.mint,
        bgColor: p.mintLight,
        p: p,
      ),
      const SizedBox(height: 10),

      // Body recovery (pink)
      _ColoredInsightCard(
        icon: LucideIcons.heartPulse,
        label: l10n.ppVotreCorps,
        text: insight.momRecovery,
        color: p.warmPink,
        bgColor: p.pinkSoft,
        p: p,
      ),
      const SizedBox(height: 10),

      // Mental health (green)
      _ColoredInsightCard(
        icon: LucideIcons.brain,
        label: l10n.ppVotreMental,
        text: insight.mentalHealth,
        color: p.green,
        bgColor: p.mintSoft,
        p: p,
      ),

      if (insight.poeticLine.isNotEmpty) ...[
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: p.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: p.border),
          ),
          child: Row(children: [
            const Text('✨', style: TextStyle(fontSize: 18)),
            const SizedBox(width: 12),
            Expanded(child: Text('"${insight.poeticLine}"',
              style: GoogleFonts.inter(
                fontSize: 13, fontStyle: FontStyle.italic,
                color: p.textMid, height: 1.7))),
          ]),
        ),
      ],
    ]);
  }
}

class _ColoredInsightCard extends StatelessWidget {
  final IconData icon;
  final String label, text;
  final Color color, bgColor;
  final PgColors p;

  const _ColoredInsightCard({
    required this.icon, required this.label, required this.text,
    required this.color, required this.bgColor, required this.p,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, size: 17, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label.toUpperCase(), style: GoogleFonts.inter(
              fontSize: 9, fontWeight: FontWeight.w700,
              color: color, letterSpacing: 1.8)),
            const SizedBox(height: 5),
            Text(text, style: GoogleFonts.inter(
              fontSize: 13, color: p.textDark, height: 1.55)),
          ],
        )),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  RECOVERY TIPS CAROUSEL
// ─────────────────────────────────────────────────────────────────────────────
class _RecoveryTipsCarousel extends StatefulWidget {
  final int weeks;
  final PgColors p;
  const _RecoveryTipsCarousel({required this.weeks, required this.p});

  @override
  State<_RecoveryTipsCarousel> createState() => _RecoveryTipsCarouselState();
}

class _RecoveryTipsCarouselState extends State<_RecoveryTipsCarousel> {
  final _controller = PageController();
  int _page = 0;

  static const _categories = [
    ('Nutrition', LucideIcons.apple, Color(0xFF7ABB98)),
    ('Exercice', LucideIcons.dumbbell, Color(0xFF1C4D30)),
    ('Repos', LucideIcons.moon, Color(0xFFF4A940)),
    ('Mental', LucideIcons.brain, Color(0xFFE58F8A)),
  ];

  static const _tipsByPhase = <int, List<String>>{
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

  int get _phaseIdx {
    if (widget.weeks < 2) return 0;
    if (widget.weeks < 6) return 1;
    if (widget.weeks < 12) return 2;
    if (widget.weeks < 26) return 3;
    return 4;
  }

  @override
  void dispose() { _controller.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final p = widget.p;
    final tips = _tipsByPhase[_phaseIdx]!;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('CONSEILS RÉCUPÉRATION', style: GoogleFonts.inter(
        fontSize: 9, fontWeight: FontWeight.w700,
        color: p.textSoft, letterSpacing: 1.8)),
      const SizedBox(height: 10),
      SizedBox(
        height: 120,
        child: PageView.builder(
          controller: _controller,
          itemCount: _categories.length,
          onPageChanged: (i) => setState(() => _page = i),
          itemBuilder: (context, i) {
            final (name, icon, color) = _categories[i];
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: color.withOpacity(0.2)),
              ),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12)),
                  child: Icon(icon, size: 20, color: color),
                ),
                const SizedBox(width: 14),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name.toUpperCase(), style: GoogleFonts.inter(
                      fontSize: 9, fontWeight: FontWeight.w700,
                      color: color, letterSpacing: 1.8)),
                    const SizedBox(height: 6),
                    Expanded(child: Text(tips[i], style: GoogleFonts.inter(
                      fontSize: 13, height: 1.5,
                      color: p.textDark.withOpacity(0.75)),
                      maxLines: 3, overflow: TextOverflow.ellipsis)),
                  ],
                )),
              ]),
            );
          },
        ),
      ),
      const SizedBox(height: 10),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(_categories.length, (i) =>
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: _page == i ? 18 : 6,
            height: 6,
            decoration: BoxDecoration(
              color: _page == i ? p.green : p.green.withOpacity(0.2),
              borderRadius: BorderRadius.circular(3)),
          ),
        ),
      ),
    ]);
  }
}
