// ignore_for_file: deprecated_member_use
import 'dart:math';
import 'package:fiteva/providers/user_profile_provider.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/xp_provider.dart';
import '../../widgets/xp_toast.dart';
import 'package:fiteva/screens/cycle/cycle_colors.dart';
import 'package:fiteva/widgets/shared_app_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fiteva/screens/cycle/pregnancy/PregnancyHubScreen.dart';
import 'package:fiteva/screens/cycle/widgets-cycle/calendar_screen.dart';
import 'package:fiteva/screens/cycle/widgets-cycle/cycle_wheel.dart' hide CycleColors;
import 'package:fiteva/services/cycle_log_service.dart';
import 'package:fiteva/screens/cycle/widgets-cycle/mood_section.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  TYPOGRAPHY HELPERS (pass colors explicitly — theme-unaware by design)
// ─────────────────────────────────────────────────────────────────────────────

abstract class FloTypo {
  static TextStyle heading(double size,
          {FontWeight w = FontWeight.w600, required Color c}) =>
      GoogleFonts.outfit(fontSize: size, fontWeight: w, color: c);

  static TextStyle body(double size,
          {FontWeight w = FontWeight.w400, required Color c}) =>
      GoogleFonts.inter(fontSize: size, fontWeight: w, color: c);
}

// ─────────────────────────────────────────────────────────────────────────────
//  SYMPTOM MODEL
// ─────────────────────────────────────────────────────────────────────────────

enum FloSymptom { flow, mood, energy, cramps }

extension FloSymptomX on FloSymptom {
  String get label {
    switch (this) {
      case FloSymptom.flow:   return 'Flux';
      case FloSymptom.mood:   return 'Humeur';
      case FloSymptom.energy: return 'Énergie';
      case FloSymptom.cramps: return 'Crampes';
    }
  }

  String labelFor(AppL10n l10n) {
    switch (this) {
      case FloSymptom.flow:   return l10n.cycleSymptomFlow;
      case FloSymptom.mood:   return l10n.cycleSymptomMood;
      case FloSymptom.energy: return l10n.cycleSymptomEnergy;
      case FloSymptom.cramps: return l10n.cycleSymptomCramps;
    }
  }

  IconData get icon {
    switch (this) {
      case FloSymptom.flow:   return Icons.water_drop_outlined;
      case FloSymptom.mood:   return Icons.sentiment_satisfied_outlined;
      case FloSymptom.energy: return Icons.bolt_outlined;
      case FloSymptom.cramps: return Icons.favorite_border_rounded;
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  PHASE THEME
// ─────────────────────────────────────────────────────────────────────────────

class CycleTheme {
  final List<Color> gradient;
  final Color primary;
  final Color glow;
  const CycleTheme({required this.gradient, required this.primary, required this.glow});
}

CycleTheme getTheme(int day) {
  final phase = phaseForDay(day);
  switch (phase.name) {
    case 'Règles':
      return const CycleTheme(
        gradient: [Color(0xFFE58F8A), Color(0xFFDE7A7A), Color(0xFFF2B6B2)],
        primary: Color(0xFFE58F8A),
        glow: Color(0x55E58F8A),
      );
    case 'Folliculaire':
      return const CycleTheme(
        gradient: [Color(0xFF7ABB98), Color(0xFF5FAE87), Color(0xFFBFE6D2)],
        primary: Color(0xFF7ABB98),
        glow: Color(0x557ABB98),
      );
    case 'Ovulation':
      return const CycleTheme(
        gradient: [Color(0xFF1C4D30), Color(0xFF2E6B45), Color(0xFF4A8F66)],
        primary: Color(0xFF1C4D30),
        glow: Color(0x551C4D30),
      );
    default:
      return const CycleTheme(
        gradient: [Color(0xFFA7B8AD), Color(0xFF8FA79A), Color(0xFFD6E2DB)],
        primary: Color(0xFFA7B8AD),
        glow: Color(0x55A7B8AD),
      );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  APP ENTRY
// ─────────────────────────────────────────────────────────────────────────────

class CycleApp extends StatelessWidget {
  const CycleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cycle Tracker',
      debugShowCheckedModeBanner: false,
      home: const CycleScreen(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  MAIN CYCLE SCREEN
// ─────────────────────────────────────────────────────────────────────────────

class CycleScreen extends ConsumerStatefulWidget {
  const CycleScreen({super.key});

  @override
  ConsumerState<CycleScreen> createState() => _CycleScreenState();
}

class _CycleScreenState extends ConsumerState<CycleScreen>
    with SingleTickerProviderStateMixin {
  late int _currentDay;
  final Set<FloSymptom> _logged = {};
  int _moodIndex = -1; // -1 = non sélectionné
  final DateTime _today = DateTime.now();
  bool _switching = false;

  late final AnimationController _switchAnim = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 550));
  late final Animation<double> _fadeOut =
      Tween<double>(begin: 1, end: 0).animate(
          CurvedAnimation(parent: _switchAnim, curve: Curves.easeInCubic));
  late final Animation<double> _scaleDown =
      Tween<double>(begin: 1, end: 0.94).animate(
          CurvedAnimation(parent: _switchAnim, curve: Curves.easeInCubic));

  int _computeCurrentDay(UserProfile profile) {
    final last = profile.lastPeriod;
    if (last == null) return 1;
    final todayNorm = DateTime(_today.year, _today.month, _today.day);
    final elapsed = todayNorm.difference(last).inDays % profile.cycleDays;
    final day = (elapsed + 1).clamp(1, profile.cycleDays);

    // Si le calcul dit "jour 1" mais l'utilisatrice n'a pas encore confirmé ses règles,
    // on reste au dernier jour du cycle précédent pour ne pas afficher "Règles" de force.
    if (day == 1 && !_logged.contains(FloSymptom.flow)) {
      final pending = profile.pendingPeriodDate;
      if (pending != null) {
        final pendingNorm = DateTime(pending.year, pending.month, pending.day);
        if (!pendingNorm.isAfter(todayNorm)) {
          return profile.cycleDays;
        }
      }
    }
    return day;
  }

  @override
  void initState() {
    super.initState();
    _currentDay = _computeCurrentDay(ref.read(userProfileProvider));
    _loadSymptoms();
  }

  Future<void> _loadSymptoms() async {
    final saved = await CycleLogService.loadSymptoms(_today);
    final mood  = await CycleLogService.loadMood(_today);
    if (!mounted) return;
    ref.read(xpProvider.notifier).rewardDailyCheckin();
    ref.read(xpProvider.notifier).rewardCycleTracking();
    setState(() {
      _logged.addAll(saved.map((s) => FloSymptom.values.firstWhere(
        (e) => e.name == s, orElse: () => FloSymptom.flow)));
      if (mood != null) _moodIndex = mood;
      // Recalcul après chargement des symptômes (flow confirmé ou pas change le jour affiché)
      _currentDay = _computeCurrentDay(ref.read(userProfileProvider));
    });
  }

  @override
  void dispose() {
    _switchAnim.dispose();
    super.dispose();
  }

  Future<void> _logPeriodStart() async {
    setState(() {
      _logged.add(FloSymptom.flow);
      _currentDay = 1; // règles confirmées → jour 1
    });
    await CycleLogService.saveSymptoms(_today, _logged.map((s) => s.name).toSet());
    // Mettre à jour lastPeriod → le cycle repart d'aujourd'hui
    final todayStr =
        '${_today.year}-${_today.month.toString().padLeft(2, '0')}-${_today.day.toString().padLeft(2, '0')}';
    await ref.read(userProfileProvider.notifier).updateField('last_period', todayStr);
  }

  Future<void> _switchToPregnancy() async {
    HapticFeedback.mediumImpact();

    // Semaine de grossesse
    int selectedWeek = 12;
    final l10n = ref.read(l10nProvider);
    final week = await showDialog<int>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlg) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(l10n.cycleIAmPregnant,
            style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700,
                color: const Color(0xFF1A2E20))),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(l10n.cycleWhichWeek,
              style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF5A7A65))),
            const SizedBox(height: 20),
            Text('${l10n.cycleWeekLabel} $selectedWeek',
              style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.w800,
                  color: const Color(0xFF1C4D30))),
            Slider(
              value: selectedWeek.toDouble(),
              min: 1, max: 42,
              divisions: 41,
              activeColor: const Color(0xFF1C4D30),
              inactiveColor: const Color(0xFFD0E8D8),
              onChanged: (v) => setDlg(() => selectedWeek = v.round()),
            ),
            Text(
              selectedWeek <= 13 ? l10n.cycleTrimester1
                  : selectedWeek <= 26 ? l10n.cycleTrimester2 : l10n.cycleTrimester3,
              style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600,
                  color: const Color(0xFF7ABB98))),
          ]),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l10n.cancel,
                style: GoogleFonts.inter(color: const Color(0xFF888888)))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1C4D30),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              onPressed: () => Navigator.pop(ctx, selectedWeek),
              child: Text(l10n.confirm,
                style: GoogleFonts.inter(fontWeight: FontWeight.w700))),
          ],
        ),
      ),
    );

    if (week == null || !mounted) return;

    // Animation de sortie
    setState(() => _switching = true);
    await _switchAnim.forward();
    if (!mounted) return;

    // Sauvegarder
    final notifier = ref.read(userProfileProvider.notifier);
    await notifier.updateField('health_status', 'pregnant');
    await notifier.updateField('pregnancy_week', week);
  }

  @override
  Widget build(BuildContext context) {
    final cc    = CycleColors.of(context);
    final theme = getTheme(_currentDay);
    final phase = phaseForDay(_currentDay);

    return Scaffold(
      backgroundColor: cc.bg,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _switchAnim,
          builder: (context, child) => FadeTransition(
            opacity: _fadeOut,
            child: ScaleTransition(scale: _scaleDown, child: child),
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 320),
            transitionBuilder: (child, anim) =>
                FadeTransition(opacity: anim, child: child),
            child: _buildHome(cc, theme, phase, ref.watch(l10nProvider)),
          ),
        ),
      ),
    );
  }

  // ── Home view ──────────────────────────────────────────────────────────────

  Widget _buildHome(CycleColors cc, CycleTheme theme, CyclePhase phase, AppL10n l10n) {
    final profile      = ref.watch(userProfileProvider);
    final showPregnancy = profile.showPregnancyContent;

    return SingleChildScrollView(
      key: const ValueKey('home'),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHero(cc, theme, phase, profile, showPregnancy, l10n),

          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Row(children: [
              Expanded(child: _PeriodCard(
                nextDate: profile.pendingPeriodDate,
                cc: cc, l10n: l10n,
                periodLoggedToday: _logged.contains(FloSymptom.flow),
                onLogPeriodStart: _logPeriodStart,
              )),
              const SizedBox(width: 12),
              Expanded(child: _OvulationCard(
                ovulationDate: profile.ovulationDate,
                cc:            cc,
                l10n:          l10n,
              )),
            ]),
          ),

          const SizedBox(height: 28),
          _buildSectionLabel(l10n.cycleHowDoYouFeel, theme.primary),
          const SizedBox(height: 14),
          _buildChips(cc, theme, l10n),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: MoodSection(
              selectedMood: _moodIndex,
              phaseColor: theme.primary,
              onSelect: (i) {
                setState(() => _moodIndex = i);
                CycleLogService.saveMood(_today, i);
              },
            ),
          ),

          const SizedBox(height: 28),
          _PhaseCard(phase: phase, theme: theme, cc: cc, l10n: l10n),

          const SizedBox(height: 16),
          _PhaseTipsCard(phase: phase, theme: theme, cc: cc, l10n: l10n),

          const SizedBox(height: 16),
          _CycleStatsCard(profile: profile, currentDay: _currentDay, theme: theme, cc: cc, l10n: l10n),
          const SizedBox(height: 48),
        ],
      ),
    );
  }

  // ── Hero section ───────────────────────────────────────────────────────────

  Widget _buildHero(
    CycleColors cc,
    CycleTheme theme,
    CyclePhase phase,
    UserProfile profile,
    bool showPregnancy,
    AppL10n l10n,
  ) {
    // In dark mode the hero gradient overlays the dark bg
    final heroOpacityTop = cc.isDark ? 0.22 : 0.16;
    final heroOpacityMid = cc.isDark ? 0.10 : 0.06;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            theme.primary.withOpacity(heroOpacityTop),
            theme.primary.withOpacity(heroOpacityMid),
            cc.bg,
          ],
          stops: const [0.0, 0.52, 1.0],
        ),
      ),
      child: Column(children: [
        SharedAppHeader(
          eyebrow:    l10n.navCycle.toUpperCase(),
          title:      l10n.cycleTitle,
          accentColor: theme.primary,
          bgColor:    Colors.transparent,
          onBack: Navigator.canPop(context)
              ? () => Navigator.of(context).pop()
              : null,
          actions: [
            PopupMenuButton<String>(
              enabled: !_switching,
              onSelected: (v) {
                if (v == 'pregnancy') _switchToPregnancy();
              },
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              elevation: 4,
              color: Colors.white,
              offset: const Offset(0, 44),
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: 'pregnancy',
                  child: Row(children: [
                    const Text('🤰', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 10),
                    Text(l10n.navPregnancy, style: GoogleFonts.inter(
                      fontSize: 13, fontWeight: FontWeight.w600,
                      color: const Color(0xFF1A2E20))),
                  ]),
                ),
              ],
              child: Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: cc.surface.withOpacity(0.65),
                  shape: BoxShape.circle,
                  border: Border.all(color: theme.primary.withOpacity(0.22)),
                ),
                child: Icon(Icons.more_horiz_rounded,
                    size: 18, color: theme.primary),
              ),
            ),
            const SizedBox(width: 6),
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                Navigator.of(context).push(PageRouteBuilder(
                  pageBuilder: (_, a, __) => CycleCalendar(
                    displayYear:      _today.year,
                    displayMonth:     _today.month,
                    today:            _today,
                    todayCycleDay:    _currentDay,
                    selectedCycleDay: _currentDay,
                    lastPeriodDate:   profile.lastPeriod,
                    onDaySelected: (date) {
                      final today = DateTime(_today.year, _today.month, _today.day);
                      final plain = DateTime(date.year, date.month, date.day);
                      if (!plain.isAfter(today)) {
                        final p = ref.read(userProfileProvider);
                        final elapsed = today.difference(p.lastPeriod ?? today).inDays;
                        final cd = elapsed % p.cycleDays + 1;
                        setState(() => _currentDay = cd.clamp(1, p.cycleDays));
                      }
                      Navigator.of(context).pop();
                    },
                    onSavePeriod: (newDate) async {
                      await ref.read(userProfileProvider.notifier)
                          .updateField('last_period', newDate.toIso8601String());
                      if (!mounted) return;
                      setState(() {
                        _currentDay = _computeCurrentDay(ref.read(userProfileProvider));
                      });
                      Navigator.of(context).pop();
                    },
                  ),
                  transitionsBuilder: (_, a, __, child) => SlideTransition(
                    position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
                        .animate(CurvedAnimation(parent: a, curve: Curves.easeOutCubic)),
                    child: child,
                  ),
                ));
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: cc.surface.withOpacity(0.65),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: theme.primary.withOpacity(0.22)),
                ),
                child: Row(children: [
                  Icon(Icons.calendar_month_rounded, size: 15, color: theme.primary),
                  const SizedBox(width: 5),
                  Text(l10n.cycleCalendar, style: GoogleFonts.inter(
                    fontSize: 12, fontWeight: FontWeight.w600, color: theme.primary)),
                ]),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(
              color: theme.primary.withOpacity(cc.isDark ? 0.30 : 0.22),
              blurRadius: 55, spreadRadius: 8,
            )],
          ),
          child: _CircularRing(
            day: _currentDay, total: profile.cycleDays,
            theme: theme, phase: phase, cc: cc, l10n: l10n,
          ),
        ),
        const SizedBox(height: 28),
      ]),
    );
  }

  Widget _buildSectionLabel(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(text.toUpperCase(), style: GoogleFonts.inter(
        fontSize: 10, fontWeight: FontWeight.w700,
        letterSpacing: 2.8, color: color.withOpacity(0.75))),
    );
  }

  Widget _buildChips(CycleColors cc, CycleTheme theme, AppL10n l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: FloSymptom.values.map((s) => _SymptomChip(
          symptom: s,
          logged:  _logged.contains(s),
          color:   theme.primary,
          cc:      cc,
          l10n:    l10n,
          onTap: () {
            HapticFeedback.lightImpact();
            final wasLogged = _logged.contains(s);
            setState(() {
              wasLogged ? _logged.remove(s) : _logged.add(s);
            });
            CycleLogService.saveSymptoms(
              _today,
              _logged.map((e) => e.name).toSet(),
            );
            if (!wasLogged) {
              ref.read(xpProvider.notifier).rewardSymptomAdded();
              XpToast.show(context, XpAmounts.symptomAdded, label: 'Symptôme noté !');
              if (s == FloSymptom.cramps) {
                ref.read(xpProvider.notifier).rewardPainSymptom();
              }
            }
          },
        )).toList(),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  CIRCULAR RING
// ─────────────────────────────────────────────────────────────────────────────

class _CircularRing extends StatelessWidget {
  final int day, total;
  final CycleTheme theme;
  final CyclePhase phase;
  final CycleColors cc;
  final AppL10n l10n;

  const _CircularRing({
    required this.day, required this.total,
    required this.theme, required this.phase, required this.cc,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final ringSize = (MediaQuery.of(context).size.width * 0.54).clamp(180.0, 230.0);
    return SizedBox(
      width: ringSize, height: ringSize,
      child: CustomPaint(
        painter: _RingPainter(
          day: day, total: total,
          colors: theme.gradient, primary: theme.primary,
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.cycleJour, style: GoogleFonts.inter(
                fontSize: 13, color: cc.muted)),
              const SizedBox(height: 2),
              Text('$day', style: GoogleFonts.outfit(
                fontSize: 52, fontWeight: FontWeight.w700, color: theme.primary)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                decoration: BoxDecoration(
                  color: theme.primary.withOpacity(0.13),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(phase.name, style: GoogleFonts.inter(
                  fontSize: 11, fontWeight: FontWeight.w600, color: theme.primary)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final int day, total;
  final List<Color> colors;
  final Color primary;

  const _RingPainter({
    required this.day, required this.total,
    required this.colors, required this.primary,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r  = (size.width / 2) - 18;
    const stroke = 13.0;

    canvas.drawCircle(Offset(cx, cy), r, Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..color = primary.withOpacity(0.10));

    final progress = (day / total).clamp(0.0, 1.0);
    final sweep = progress * 2 * pi;
    final rect  = Rect.fromCircle(center: Offset(cx, cy), radius: r);

    canvas.drawArc(rect, -pi / 2, sweep, false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..shader = SweepGradient(
          startAngle: -pi / 2, endAngle: -pi / 2 + 2 * pi,
          colors: [colors.first, colors.last, colors.first],
        ).createShader(rect));

    final angle = -pi / 2 + sweep;
    final dotX = cx + r * cos(angle);
    final dotY = cy + r * sin(angle);
    canvas.drawCircle(Offset(dotX, dotY), 8, Paint()..color = colors.first);
    canvas.drawCircle(Offset(dotX, dotY), 4, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) =>
      old.day != day || old.total != total;
}

// ─────────────────────────────────────────────────────────────────────────────
//  INFO CARD BASE
// ─────────────────────────────────────────────────────────────────────────────

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title, value, subtitle;
  final CycleColors cc;

  const _InfoCard({
    required this.icon, required this.color,
    required this.title, required this.value,
    required this.subtitle, required this.cc,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cc.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.22), width: 1),
        boxShadow: [BoxShadow(
          color: color.withOpacity(cc.isDark ? 0.12 : 0.08),
          blurRadius: 14, offset: const Offset(0, 4),
        )],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(
              color: color.withOpacity(0.14),
              borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, size: 17, color: color),
          ),
          const SizedBox(height: 12),
          Text(title, style: GoogleFonts.inter(
            fontSize: 11, color: cc.muted)),
          const SizedBox(height: 3),
          Text(value, style: GoogleFonts.inter(
            fontSize: 16, fontWeight: FontWeight.w800, color: cc.text)),
          if (subtitle.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(subtitle, style: GoogleFonts.inter(
              fontSize: 11, fontWeight: FontWeight.w500, color: color)),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  PERIOD CARD
// ─────────────────────────────────────────────────────────────────────────────

class _PeriodCard extends StatelessWidget {
  final DateTime? nextDate;
  final CycleColors cc;
  final AppL10n l10n;
  final bool periodLoggedToday;
  final VoidCallback onLogPeriodStart;

  static const _months = [
    'jan','fév','mar','avr','mai','juin','juil','août','sep','oct','nov','déc'
  ];

  const _PeriodCard({
    required this.nextDate,
    required this.cc,
    required this.l10n,
    required this.periodLoggedToday,
    required this.onLogPeriodStart,
  });

  static const _pink = Color(0xFFE58F8A);

  @override
  Widget build(BuildContext context) {
    final todayDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    String value = '—', sub = '';
    bool showConfirmBtn = false;
    Color valueColor = cc.text;

    if (nextDate != null) {
      final daysLeft = nextDate!.difference(todayDate).inDays;
      final dateLabel = '${nextDate!.day} ${_months[nextDate!.month - 1]}';

      if (periodLoggedToday) {
        value      = 'Règles ✓';
        sub        = dateLabel;
        valueColor = _pink;
      } else if (daysLeft == 0) {
        value          = 'Peut-être auj.';
        sub            = dateLabel;
        valueColor     = _pink;
        showConfirmBtn = true;
      } else if (daysLeft < 0) {
        final delay = -daysLeft;
        value          = 'Retard $delay j';
        sub            = dateLabel;
        valueColor     = const Color(0xFFE57373); // rouge retard
        showConfirmBtn = true;
      } else {
        value = l10n.cycleDaysLeft(daysLeft);
        sub   = dateLabel;
      }
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cc.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _pink.withOpacity(0.22), width: 1),
        boxShadow: [BoxShadow(
          color: _pink.withOpacity(cc.isDark ? 0.12 : 0.08),
          blurRadius: 14, offset: const Offset(0, 4),
        )],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(
              color: _pink.withOpacity(0.14),
              borderRadius: BorderRadius.circular(12)),
            child: Icon(Icons.water_drop_outlined, size: 17, color: _pink),
          ),
          const SizedBox(height: 12),
          Text(l10n.cycleNextPeriod,
              style: GoogleFonts.inter(fontSize: 11, color: cc.muted)),
          const SizedBox(height: 3),
          Text(value,
              style: GoogleFonts.inter(
                  fontSize: 16, fontWeight: FontWeight.w800, color: valueColor)),
          if (sub.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(sub,
                style: GoogleFonts.inter(
                    fontSize: 11, fontWeight: FontWeight.w500, color: _pink)),
          ],
          if (showConfirmBtn) ...[
            const SizedBox(height: 8),
            GestureDetector(
              onTap: onLogPeriodStart,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: _pink.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('Oui, c\'est arrivé',
                    style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: _pink)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  OVULATION CARD
// ─────────────────────────────────────────────────────────────────────────────

class _OvulationCard extends StatelessWidget {
  final DateTime? ovulationDate;
  final CycleColors cc;
  final AppL10n l10n;

  static const _months = [
    'jan','fév','mar','avr','mai','juin','juil','août','sep','oct','nov','déc'
  ];

  const _OvulationCard({
    required this.ovulationDate, required this.cc, required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    String value = '—', sub = '';
    if (ovulationDate != null) {
      final daysLeft = ovulationDate!.difference(today).inDays;
      value = daysLeft < 0 ? l10n.cyclePast
          : daysLeft == 0 ? l10n.cycleToday : l10n.cycleDaysLeft(daysLeft);
      sub = '${ovulationDate!.day} ${_months[ovulationDate!.month - 1]}';
    }
    return _InfoCard(
      icon: Icons.spa_outlined,
      color: const Color(0xFF7ABB98),
      title: l10n.cycleOvulation,
      value: value, subtitle: sub, cc: cc,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  SYMPTOM CHIP
// ─────────────────────────────────────────────────────────────────────────────

class _SymptomChip extends StatelessWidget {
  final FloSymptom symptom;
  final bool logged;
  final Color color;
  final CycleColors cc;
  final VoidCallback onTap;
  final AppL10n l10n;

  const _SymptomChip({
    required this.symptom, required this.logged,
    required this.color, required this.cc, required this.onTap, required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final inactiveIcon = cc.isDark
        ? const Color(0xFF5A4D52)
        : const Color(0xFFBBAFB4);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeInOut,
        width: 76,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: logged ? color.withOpacity(0.12) : cc.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: logged ? color : cc.border, width: 1.5),
          boxShadow: [BoxShadow(
            color: logged
                ? color.withOpacity(0.18)
                : Colors.black.withOpacity(cc.isDark ? 0.15 : 0.04),
            blurRadius: logged ? 12 : 6,
            offset: const Offset(0, 3),
          )],
        ),
        child: Column(children: [
          Icon(symptom.icon, size: 22,
              color: logged ? color : inactiveIcon),
          const SizedBox(height: 7),
          Text(symptom.labelFor(l10n), style: GoogleFonts.inter(
            fontSize: 10, fontWeight: FontWeight.w600,
            color: logged ? color : inactiveIcon),
            textAlign: TextAlign.center),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  PHASE CARD
// ─────────────────────────────────────────────────────────────────────────────

class _PhaseCard extends StatelessWidget {
  final CyclePhase phase;
  final CycleTheme theme;
  final CycleColors cc;
  final AppL10n l10n;

  const _PhaseCard({required this.phase, required this.theme, required this.cc, required this.l10n});

  static const _emojis = {
    'Règles': '🌸', 'Folliculaire': '🌱', 'Ovulation': '✨', 'Lutéale': '🍂',
  };

  @override
  Widget build(BuildContext context) {
    final desc  = l10n.cyclePhaseDesc(phase.name);
    final emoji = _emojis[phase.name] ?? '🌙';
    final gradOpacity = cc.isDark ? 0.22 : 0.18;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.gradient[0].withOpacity(gradOpacity),
              theme.gradient[2].withOpacity(gradOpacity * 0.4),
            ],
            begin: Alignment.topLeft, end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: theme.primary.withOpacity(0.22)),
          boxShadow: [BoxShadow(
            color: theme.primary.withOpacity(cc.isDark ? 0.12 : 0.08),
            blurRadius: 20, offset: const Offset(0, 6),
          )],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 58, height: 58,
              decoration: BoxDecoration(
                color: theme.primary.withOpacity(0.15),
                shape: BoxShape.circle),
              child: Center(child: Text(emoji,
                  style: const TextStyle(fontSize: 26))),
            ),
            const SizedBox(width: 18),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10)),
                  child: Text('Phase ${phase.name}', style: GoogleFonts.inter(
                    fontSize: 11, fontWeight: FontWeight.w700,
                    color: theme.primary)),
                ),
                const SizedBox(height: 9),
                Text(desc, style: GoogleFonts.inter(
                  fontSize: 13, color: cc.body)),
              ],
            )),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  PHASE TIPS CARD
// ─────────────────────────────────────────────────────────────────────────────

class _PhaseTipsCard extends StatelessWidget {
  final CyclePhase phase;
  final CycleTheme theme;
  final CycleColors cc;
  final AppL10n l10n;

  const _PhaseTipsCard({
    required this.phase, required this.theme, required this.cc, required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final tip = l10n.cyclePhaseTips(phase.name);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cc.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: theme.primary.withOpacity(0.12)),
          boxShadow: [BoxShadow(
            color: theme.primary.withOpacity(cc.isDark ? 0.10 : 0.07),
            blurRadius: 18, offset: const Offset(0, 5),
          )],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Container(width: 8, height: 8,
                  decoration: BoxDecoration(
                      color: theme.primary, shape: BoxShape.circle)),
              const SizedBox(width: 8),
              Text(l10n.cycleDailyTips, style: GoogleFonts.outfit(
                fontSize: 14, fontWeight: FontWeight.w700, color: theme.primary)),
            ]),
            const SizedBox(height: 16),
            _TipRow(icon: Icons.fitness_center_rounded,
                label: l10n.cycleWorkout, text: tip.workout,
                color: theme.primary, cc: cc),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Divider(color: cc.border, height: 1),
            ),
            _TipRow(icon: Icons.restaurant_outlined,
                label: l10n.cycleNutrition, text: tip.nutrition,
                color: theme.primary, cc: cc),
          ],
        ),
      ),
    );
  }
}

class _TipRow extends StatelessWidget {
  final IconData icon;
  final String label, text;
  final Color color;
  final CycleColors cc;

  const _TipRow({
    required this.icon, required this.label, required this.text,
    required this.color, required this.cc,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 34, height: 34,
          decoration: BoxDecoration(
              color: color.withOpacity(0.10),
              borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: GoogleFonts.inter(
              fontSize: 11, fontWeight: FontWeight.w700, color: color)),
            const SizedBox(height: 3),
            Text(text, style: GoogleFonts.inter(
              fontSize: 13, color: cc.body)),
          ],
        )),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  CYCLE STATS CARD
// ─────────────────────────────────────────────────────────────────────────────

class _CycleStatsCard extends StatelessWidget {
  final dynamic profile;
  final int currentDay;
  final CycleTheme theme;
  final CycleColors cc;
  final AppL10n l10n;

  const _CycleStatsCard({
    required this.profile, required this.currentDay,
    required this.theme, required this.cc, required this.l10n,
  });

  static const _months = [
    'jan','fév','mar','avr','mai','juin','juil','août','sep','oct','nov','déc'
  ];

  @override
  Widget build(BuildContext context) {
    final lastPeriod = profile.lastPeriod as DateTime?;
    final cycleDays  = profile.cycleDays as int;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        decoration: BoxDecoration(
          color: cc.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: theme.primary.withOpacity(0.12)),
          boxShadow: [BoxShadow(
            color: theme.primary.withOpacity(cc.isDark ? 0.10 : 0.07),
            blurRadius: 18, offset: const Offset(0, 5),
          )],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Container(width: 8, height: 8,
                  decoration: BoxDecoration(
                      color: theme.primary, shape: BoxShape.circle)),
              const SizedBox(width: 8),
              Text(l10n.cycleMyCycle, style: GoogleFonts.outfit(
                fontSize: 14, fontWeight: FontWeight.w700, color: theme.primary)),
            ]),
            const SizedBox(height: 18),
            IntrinsicHeight(
              child: Row(children: [
                Expanded(child: _StatCell(label: l10n.cycleDuration,
                    value: '$cycleDays j', icon: Icons.loop_rounded,
                    color: theme.primary, cc: cc)),
                VerticalDivider(color: cc.border, width: 1, thickness: 1),
                Expanded(child: _StatCell(label: l10n.cycleCurrentDay,
                    value: 'J$currentDay', icon: Icons.today_outlined,
                    color: theme.primary, cc: cc)),
                VerticalDivider(color: cc.border, width: 1, thickness: 1),
                Expanded(child: _StatCell(
                  label: l10n.cycleLastPeriod,
                  value: lastPeriod != null
                      ? '${lastPeriod.day} ${_months[lastPeriod.month - 1]}'
                      : '—',
                  icon: Icons.water_drop_outlined,
                  color: const Color(0xFFE58F8A),
                  cc: cc,
                )),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  final CycleColors cc;

  const _StatCell({
    required this.label, required this.value,
    required this.icon, required this.color, required this.cc,
  });

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Container(
        width: 38, height: 38,
        decoration: BoxDecoration(
            color: color.withOpacity(0.10),
            borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, size: 17, color: color),
      ),
      const SizedBox(height: 8),
      Text(value, style: GoogleFonts.inter(
        fontSize: 15, fontWeight: FontWeight.w800, color: cc.text)),
      const SizedBox(height: 3),
      Text(label, textAlign: TextAlign.center,
          style: GoogleFonts.inter(fontSize: 10, color: cc.muted)),
    ]);
  }
}
