// ignore_for_file: deprecated_member_use
import 'package:fiteva/providers/user_profile_provider.dart';
import 'package:fiteva/screens/cycle/pregnancy/postpartum/postpartum_insight_repository.dart';
import 'package:fiteva/screens/cycle/pregnancy/pregnancy_colors.dart';
import 'package:fiteva/widgets/custom_date_picker.dart';
import 'package:fiteva/widgets/shared_app_header.dart';
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

  static const _moodLabels = ['Difficile', 'Neutre', 'Bien', 'Tres bien', 'Rayonnante'];
  static const _moodIcons  = [
    LucideIcons.cloudRain,
    LucideIcons.minus,
    LucideIcons.smile,
    LucideIcons.sun,
    LucideIcons.sparkles,
  ];

  @override
  void initState() {
    super.initState();
    _birthDate = widget.birthDate;
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
    return 'Forme retrouvee';
  }

  String get _phaseDesc {
    if (_weeks < 2)  return 'Votre corps cicatrise. Le repos est votre entrainement.';
    if (_weeks < 6)  return 'Mobilite douce, perinee et reconnexion au corps.';
    if (_weeks < 12) return 'Renforcement progressif, posture et energie.';
    if (_weeks < 26) return 'Reprise du sport, reconditionnement musculaire.';
    return 'Retour complet a la forme physique.';
  }

  Color get _phaseColor {
    if (_weeks < 2)  return const Color(0xFFE58F8A);
    if (_weeks < 6)  return const Color(0xFFF4A940);
    if (_weeks < 12) return const Color(0xFF7ABB98);
    if (_weeks < 26) return const Color(0xFF1C4D30);
    return const Color(0xFF1C4D30);
  }

  double get _progress => (_weeks / 12).clamp(0.0, 1.0);

  // ── Pickers ──────────────────────────────────────────────────────────────────
  Future<void> _pickBirthDate() async {
    HapticFeedback.lightImpact();
    final picked = await showCustomDatePicker(
      context: context,
      initialDate: _birthDate,
      firstDate: DateTime.now().subtract(const Duration(days: 730)),
      lastDate: DateTime.now(),
      title: 'Date d\'accouchement',
      subtitle: 'Quand est ne votre bebe ?',
      icon: Icons.child_care_rounded,
      accentColor: const Color(0xFF1C4D30),
    );
    if (picked != null && mounted) setState(() => _birthDate = picked);
  }

  Future<void> _switchToCycle() async {
    HapticFeedback.mediumImpact();

    // Étape 1 — Calendrier custom
    final picked = await showCustomDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 180)),
      lastDate: DateTime.now(),
      title: 'Date de tes regles',
      subtitle: 'Quand ont-elles commence ?',
      icon: Icons.water_drop_rounded,
      accentColor: const Color(0xFFD94F6B),
    );

    if (picked == null || !mounted) return;

    // Étape 2 — Confirmation
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Passer au suivi de cycle ?',
          style: GoogleFonts.outfit(fontSize: 17, fontWeight: FontWeight.w700)),
        content: Text(
          'Votre suivi passera du post-partum au cycle menstruel a partir du '
          '${picked.day}/${picked.month}/${picked.year}.',
          style: GoogleFonts.inter(fontSize: 13, height: 1.5,
              color: const Color(0xFF5A5A5A))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Annuler',
              style: GoogleFonts.inter(color: const Color(0xFF888888)))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD94F6B),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Confirmer',
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

    if (mounted) Navigator.maybePop(context);
  }

  // ── Build ─────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final p       = context.p;
    final insight = PostpartumInsightRepository.forWeek(_weeks.clamp(1, 12));
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
            eyebrow: 'POST-PARTUM',
            title: '4e trimestre',
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
                      Text('Mes regles', style: GoogleFonts.inter(
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

                // ── Hero ─────────────────────────────────────────────────
                _HeroCard(
                  weeks: _weeks,
                  rem: _rem,
                  phaseName: _phaseName,
                  phaseDesc: _phaseDesc,
                  phaseColor: _phaseColor,
                  progress: _progress,
                  p: p,
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
                  ),
                ),

                const SizedBox(height: 16),

                // ── Mood ─────────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _MoodCard(
                    selected: _mood,
                    onSelect: (i) { HapticFeedback.selectionClick(); setState(() => _mood = i); },
                    p: p,
                  ),
                ),

                const SizedBox(height: 16),

                // ── Cette semaine ────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _WeekInsight(insight: insight, weeks: _weeks, p: p),
                ),

                const SizedBox(height: 16),

                // ── Progression ──────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _ProgressCard(
                    weeks: _weeks,
                    progress: _progress,
                    phaseColor: _phaseColor,
                    p: p,
                  ),
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
//  Switch to cycle button (header action)
// ─────────────────────────────────────────────────────────────────────────────
class _CycleSwitchButton extends StatelessWidget {
  final VoidCallback onTap;
  const _CycleSwitchButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFD94F6B).withOpacity(0.10),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: const Color(0xFFD94F6B).withOpacity(0.35), width: 1),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          const Icon(LucideIcons.droplets, size: 13, color: Color(0xFFD94F6B)),
          const SizedBox(width: 5),
          Text('Mes regles',
            style: GoogleFonts.inter(
              fontSize: 11, fontWeight: FontWeight.w700,
              color: const Color(0xFFD94F6B))),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Hero card
// ─────────────────────────────────────────────────────────────────────────────
class _HeroCard extends StatelessWidget {
  final int weeks, rem;
  final String phaseName, phaseDesc;
  final Color phaseColor;
  final double progress;
  final PgColors p;

  const _HeroCard({
    required this.weeks, required this.rem,
    required this.phaseName, required this.phaseDesc,
    required this.phaseColor, required this.progress, required this.p,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: p.green,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: p.green.withOpacity(0.25),
              blurRadius: 20, offset: const Offset(0, 8)),
        ],
      ),
      child: Row(
        children: [
          // Anneau semaines
          Stack(alignment: Alignment.center, children: [
            SizedBox(
              width: 84, height: 84,
              child: CircularProgressIndicator(
                value: progress,
                strokeWidth: 4,
                backgroundColor: Colors.white.withOpacity(0.18),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                strokeCap: StrokeCap.round,
              ),
            ),
            Column(mainAxisSize: MainAxisSize.min, children: [
              Text('S$weeks', style: GoogleFonts.outfit(
                fontSize: 22, fontWeight: FontWeight.w800,
                color: Colors.white, height: 1.1)),
              Text('$rem j', style: GoogleFonts.inter(
                fontSize: 11, color: Colors.white60,
                fontWeight: FontWeight.w500)),
            ]),
          ]),

          const SizedBox(width: 20),

          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(phaseName, style: GoogleFonts.inter(
                  fontSize: 11, fontWeight: FontWeight.w700,
                  color: Colors.white, letterSpacing: 0.3)),
              ),
              const SizedBox(height: 10),
              Text(phaseDesc, style: GoogleFonts.inter(
                fontSize: 13, color: Colors.white.withOpacity(0.80),
                height: 1.5)),
              const SizedBox(height: 12),
              Text('4e trimestre', style: GoogleFonts.inter(
                fontSize: 10, fontWeight: FontWeight.w600,
                color: Colors.white.withOpacity(0.55),
                letterSpacing: 1.4)),
            ],
          )),
        ],
      ),
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

  const _DateCard({
    required this.dateStr, required this.days,
    required this.onEdit, required this.p,
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
            Text('Date d\'accouchement', style: GoogleFonts.inter(
              fontSize: 11, fontWeight: FontWeight.w500, color: p.textSoft)),
            const SizedBox(height: 3),
            Text(dateStr, style: GoogleFonts.outfit(
              fontSize: 17, fontWeight: FontWeight.w700, color: p.textDark)),
            Text('$days jours depuis la naissance', style: GoogleFonts.inter(
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
            child: Text('Modifier', style: GoogleFonts.inter(
              fontSize: 12, fontWeight: FontWeight.w700, color: p.green)),
          ),
        ),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Mood card
// ─────────────────────────────────────────────────────────────────────────────
class _MoodCard extends StatelessWidget {
  final int? selected;
  final ValueChanged<int> onSelect;
  final PgColors p;

  static const _labels = ['Difficile', 'Neutre', 'Bien', 'Tres bien', 'Super'];
  static const _icons  = [
    LucideIcons.cloudRain, LucideIcons.minus,
    LucideIcons.smile, LucideIcons.sun, LucideIcons.sparkles,
  ];

  const _MoodCard({required this.selected, required this.onSelect, required this.p});

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
        Text('Comment vous sentez-vous ?', style: GoogleFonts.inter(
          fontSize: 13, fontWeight: FontWeight.w700, color: p.textDark)),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(5, (i) {
            final sel = selected == i;
            return GestureDetector(
              onTap: () => onSelect(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                decoration: BoxDecoration(
                  color: sel ? p.green.withOpacity(0.10) : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: sel ? p.green : Colors.transparent, width: 1.5),
                ),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Icon(_icons[i], size: 22,
                      color: sel ? p.green : p.textSoft),
                  const SizedBox(height: 5),
                  Text(_labels[i], style: GoogleFonts.inter(
                    fontSize: 9, fontWeight: FontWeight.w600,
                    color: sel ? p.green : p.textSoft)),
                ]),
              ),
            );
          }),
        ),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Week insight
// ─────────────────────────────────────────────────────────────────────────────
class _WeekInsight extends StatelessWidget {
  final PostpartumInsight insight;
  final int weeks;
  final PgColors p;

  const _WeekInsight({required this.insight, required this.weeks, required this.p});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text('Semaine $weeks — ${insight.title}',
          style: GoogleFonts.outfit(
            fontSize: 17, fontWeight: FontWeight.w700, color: p.textDark)),
      ),
      _InsightRow(
        icon: LucideIcons.baby,
        color: p.mint,
        title: 'Votre bebe',
        text: insight.babyMilestone,
        p: p,
      ),
      const SizedBox(height: 10),
      _InsightRow(
        icon: LucideIcons.heartPulse,
        color: p.warmPink,
        title: 'Votre corps',
        text: insight.momRecovery,
        p: p,
      ),
      const SizedBox(height: 10),
      _InsightRow(
        icon: LucideIcons.brain,
        color: p.mint,
        title: 'Votre mental',
        text: insight.mentalHealth,
        p: p,
      ),
      const SizedBox(height: 14),
      Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: p.mintSoft,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: p.border),
        ),
        child: Text('"${insight.poeticLine}"',
          style: GoogleFonts.inter(
            fontSize: 13, fontStyle: FontStyle.italic,
            color: p.textMid, height: 1.7)),
      ),
    ]);
  }
}

class _InsightRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title, text;
  final PgColors p;

  const _InsightRow({
    required this.icon, required this.color,
    required this.title, required this.text, required this.p,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: p.border),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 38, height: 38,
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 17, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: GoogleFonts.inter(
              fontSize: 12, fontWeight: FontWeight.w700, color: color)),
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
//  Progress card
// ─────────────────────────────────────────────────────────────────────────────
class _ProgressCard extends StatelessWidget {
  final int weeks;
  final double progress;
  final Color phaseColor;
  final PgColors p;

  static const _phases = ['0-2 sem.', '2-6 sem.', '6-12 sem.', '3-6 mois', '6+ mois'];
  static const _maxW   = [2, 6, 12, 26, 999];

  const _ProgressCard({
    required this.weeks, required this.progress,
    required this.phaseColor, required this.p,
  });

  int get _activePhase {
    for (int i = 0; i < _maxW.length; i++) {
      if (weeks < _maxW[i]) return i;
    }
    return _phases.length - 1;
  }

  @override
  Widget build(BuildContext context) {
    final active = _activePhase;
    final remaining = (12 - weeks).clamp(0, 12);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: p.border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('4e trimestre', style: GoogleFonts.outfit(
            fontSize: 15, fontWeight: FontWeight.w700, color: p.textDark)),
          Text('$weeks / 12 sem.', style: GoogleFonts.inter(
            fontSize: 12, color: p.textMid, fontWeight: FontWeight.w600)),
        ]),
        const SizedBox(height: 14),

        // Phase segments
        Row(
          children: List.generate(_phases.length, (i) {
            final isActive = i == active;
            final isPast   = i < active;
            return Expanded(child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Column(children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: isActive ? 6 : 4,
                  decoration: BoxDecoration(
                    color: isPast || isActive
                        ? p.green
                        : p.green.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 5),
                Text(_phases[i], style: GoogleFonts.inter(
                  fontSize: 8.5,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                  color: isActive ? p.green : p.textSoft)),
              ]),
            ));
          }),
        ),

        const SizedBox(height: 16),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            backgroundColor: p.mintLight,
            valueColor: AlwaysStoppedAnimation<Color>(p.green),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          weeks >= 12
              ? 'Felicitations ! Vous avez traverse le 4e trimestre.'
              : '$remaining semaines restantes de suivi post-partum',
          style: GoogleFonts.inter(fontSize: 12, color: p.textMid)),
      ]),
    );
  }
}
