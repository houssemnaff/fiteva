// ignore_for_file: deprecated_member_use
import 'dart:math';
import 'package:fiteva/providers/user_profile_provider.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/points_provider.dart';
import '../../widgets/points_toast.dart';
import 'package:fiteva/screens/cycle/cycle_colors.dart';
import 'package:fiteva/widgets/shared_app_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fiteva/screens/cycle/widgets-cycle/calendar_screen.dart';
import 'package:fiteva/screens/cycle/widgets-cycle/cycle_wheel.dart' hide CycleColors;
import 'package:fiteva/services/cycle_log_service.dart';
import 'package:fiteva/services/storage_service.dart';
import 'package:fiteva/screens/cycle/cycle_insights_screen.dart';

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

CycleTheme getTheme(int day, {int cycleDays = 28}) {
  final phase = phaseForDay(day, cycleDays: cycleDays);
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
  // "Me rappeler demain" — persisté (clé datée du jour) au lieu d'être gardé
  // uniquement en mémoire, sinon rouvrir l'app faisait réapparaître l'écran
  // plein écran de retard de règles alors que l'utilisatrice l'avait déjà
  // explicitement masqué pour la journée.
  bool _lateSnoozed = false;
  String get _lateSnoozeKey =>
      'cycle_late_snoozed_${_today.year}-${_today.month}-${_today.day}';

  late final AnimationController _switchAnim = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 550));
  late final Animation<double> _fadeOut =
      Tween<double>(begin: 1, end: 0).animate(
          CurvedAnimation(parent: _switchAnim, curve: Curves.easeInCubic));
  late final Animation<double> _scaleDown =
      Tween<double>(begin: 1, end: 0.94).animate(
          CurvedAnimation(parent: _switchAnim, curve: Curves.easeInCubic));

  // Calcul pur jour-du-cycle pour une date donnée — partagé par
  // _computeCurrentDay (aujourd'hui) et le sélecteur de calendrier (n'importe
  // quelle date passée), pour éviter que deux copies de cette formule
  // divergent silencieusement.
  int _dayForDate(UserProfile profile, DateTime date) {
    final last = profile.lastPeriod;
    if (last == null) return 1;
    final dateNorm = DateTime(date.year, date.month, date.day);
    final elapsed = dateNorm.difference(last).inDays % profile.cycleDays;
    return (elapsed + 1).clamp(1, profile.cycleDays);
  }

  int _computeCurrentDay(UserProfile profile) {
    final todayNorm = DateTime(_today.year, _today.month, _today.day);
    final day = _dayForDate(profile, todayNorm);

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
    _currentDay   = _computeCurrentDay(ref.read(userProfileProvider));
    _lateSnoozed  = StorageService.getBool(_lateSnoozeKey);
    _loadSymptoms();
  }

  Future<void> _loadSymptoms() async {
    final saved = await CycleLogService.loadSymptoms(_today);
    final mood  = await CycleLogService.loadMood(_today);
    if (!mounted) return;
    ref.read(pointsProvider.notifier).rewardDailyCheckin();
    ref.read(pointsProvider.notifier).rewardCycleTracking();
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

  /// Retard = date prévue dépassée et règles non encore loggées aujourd'hui
  ({bool isLate, int delayDays}) _lateStatus(UserProfile profile) {
    final pending = profile.pendingPeriodDate;
    if (pending == null || _logged.contains(FloSymptom.flow)) {
      return (isLate: false, delayDays: 0);
    }
    final todayNorm = DateTime(_today.year, _today.month, _today.day);
    final pendingNorm = DateTime(pending.year, pending.month, pending.day);
    final diff = pendingNorm.difference(todayNorm).inDays;
    if (diff < 0) return (isLate: true, delayDays: -diff);
    return (isLate: false, delayDays: 0);
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
                color: Theme.of(ctx).colorScheme.onSurface)),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(l10n.cycleWhichWeek,
              style: GoogleFonts.inter(fontSize: 13, color: Theme.of(ctx).colorScheme.onSurface.withValues(alpha: 0.5))),
            const SizedBox(height: 20),
            Text('${l10n.cycleWeekLabel} $selectedWeek',
              style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.w800,
                  color: Theme.of(ctx).colorScheme.primary)),
            Slider(
              value: selectedWeek.toDouble(),
              min: 1, max: 42,
              divisions: 41,
              activeColor: Theme.of(ctx).colorScheme.primary,
              inactiveColor: Theme.of(ctx).colorScheme.primary.withValues(alpha: 0.2),
              onChanged: (v) => setDlg(() => selectedWeek = v.round()),
            ),
            Text(
              selectedWeek <= 13 ? l10n.cycleTrimester1
                  : selectedWeek <= 26 ? l10n.cycleTrimester2 : l10n.cycleTrimester3,
              style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600,
                  color: Theme.of(ctx).colorScheme.secondary)),
          ]),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l10n.cancel,
                style: GoogleFonts.inter(color: Theme.of(ctx).colorScheme.onSurface.withValues(alpha: 0.4)))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(ctx).colorScheme.primary,
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
    // La durée de cycle réelle de l'utilisatrice (pas 28j fixe) détermine
    // les plages de phases — sinon les phases affichées sont fausses pour
    // tout cycle qui n'est pas exactement 28 jours.
    final cycleDays = ref.watch(userProfileProvider).cycleDays;
    final theme = getTheme(_currentDay, cycleDays: cycleDays);
    final phase = phaseForDay(_currentDay, cycleDays: cycleDays);

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

    final late = _lateStatus(profile);
    if (late.isLate && !_lateSnoozed) {
      return _buildLateScreen(cc, profile, l10n, late.delayDays);
    }

    return SingleChildScrollView(
      key: const ValueKey('home'),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHero(cc, theme, phase, profile, showPregnancy, l10n),

          // 1. Timeline banner (replaces period + ovulation cards)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: _CycleTimelineBanner(
              currentDay: _currentDay,
              cycleDays: profile.cycleDays,
              nextPeriod: profile.pendingPeriodDate,
              ovulationDate: profile.ovulationDate,
              theme: theme, cc: cc, l10n: l10n,
            ),
          ),

          // 2. Daily insight card
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: _DailyInsightCard(phase: phase, theme: theme, cc: cc, currentDay: _currentDay, cycleDays: profile.cycleDays),
          ),

          const SizedBox(height: 24),
          _buildSectionLabel(l10n.cycleHowDoYouFeel, theme.primary),
          const SizedBox(height: 14),

          // 3. Symptom sliders
          _buildSymptomSliders(cc, theme, l10n),
          const SizedBox(height: 16),

          // 5. Weekly mood chart
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _WeeklyMoodChart(
              moodIndex: _moodIndex,
              theme: theme, cc: cc, l10n: l10n,
              onSelectMood: (i) {
                HapticFeedback.lightImpact();
                setState(() => _moodIndex = i);
                CycleLogService.saveMood(_today, i);
              },
            ),
          ),

          const SizedBox(height: 24),

          // 4. Phase card (kept but refined)
          _PhaseCard(phase: phase, theme: theme, cc: cc, l10n: l10n),

          const SizedBox(height: 16),

          // 6. Swipeable phase tips carousel
          _PhaseTipsCarousel(phase: phase, theme: theme, cc: cc, l10n: l10n),

          const SizedBox(height: 16),
          _CycleStatsCard(profile: profile, currentDay: _currentDay, theme: theme, cc: cc, l10n: l10n),
          const SizedBox(height: 48),
        ],
      ),
    );
  }

  // ── Écran dédié "Règles en retard" ───────────────────────────────────────────
  // Remplace tout l'écran d'accueil (pas seulement le cercle) tant que les
  // règles prévues ne sont ni loggées ni reportées à demain.

  // Vert signature de l'app — le même que Profil / Ovulation / boutons primaires
  Color get _green   => Theme.of(context).colorScheme.primary;
  Color get _greenBg => Theme.of(context).colorScheme.primary.withValues(alpha: 0.08);

  static String _fmtDate(DateTime d, AppL10n l10n) {
    final monthsFr = ['jan','fév','mar','avr','mai','juin','juil','août','sep','oct','nov','déc'];
    final monthsEn = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    final months = l10n.isFrench ? monthsFr : monthsEn;
    return l10n.isFrench ? '${d.day} ${months[d.month - 1]}' : '${months[d.month - 1]} ${d.day}';
  }

  Widget _buildLateScreen(CycleColors cc, UserProfile profile, AppL10n l10n, int delayDays) {
    final pending      = profile.pendingPeriodDate;
    final lastPeriod    = profile.lastPeriod;
    final ovulation     = profile.ovulationDate;
    final todayNorm     = DateTime(_today.year, _today.month, _today.day);
    final cycleActuel   = lastPeriod != null
        ? todayNorm.difference(DateTime(lastPeriod.year, lastPeriod.month, lastPeriod.day)).inDays + 1
        : null;

    return SingleChildScrollView(
      key: const ValueKey('late'),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Header ──────────────────────────────────────────────────────
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter, end: Alignment.bottomCenter,
                colors: [_greenBg.withOpacity(cc.isDark ? 0.14 : 0.6), Colors.transparent],
              ),
            ),
            child: Column(children: [
              SharedAppHeader(
                eyebrow:    l10n.navCycle.toUpperCase(),
                title:      l10n.lateTitle,
                accentColor: _green,
                bgColor:    Colors.transparent,
                onBack: Navigator.canPop(context)
                    ? () => Navigator.of(context).pop()
                    : null,
              ),
              const SizedBox(height: 22),
              Container(
                width: 72, height: 72,
                decoration: BoxDecoration(
                  color: cc.surface,
                  shape: BoxShape.circle,
                  border: Border.all(color: _green.withOpacity(0.22), width: 1.3),
                  boxShadow: [BoxShadow(
                    color: _green.withOpacity(cc.isDark ? 0.18 : 0.10),
                    blurRadius: 24, spreadRadius: 2)],
                ),
                child: Icon(Icons.hourglass_top_rounded, size: 28, color: _green),
              ),
              const SizedBox(height: 18),
              Text(l10n.lateTitle,
                style: GoogleFonts.outfit(fontSize: 19, fontWeight: FontWeight.w700,
                    color: cc.text, letterSpacing: -0.3)),
              const SizedBox(height: 6),
              Text(l10n.lateDelayDays(delayDays),
                style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w500,
                    color: cc.muted, letterSpacing: 0.2)),
              const SizedBox(height: 26),
            ]),
          ),

          // ── Stats clés ──────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Wrap(
              spacing: 10, runSpacing: 10,
              children: [
                if (pending != null)
                  _LateStatChip(label: l10n.lateStatDueDate, value: _fmtDate(pending, l10n), cc: cc),
                _LateStatChip(label: l10n.lateStatDelay, value: '$delayDays j', cc: cc, highlight: true),
                _LateStatChip(label: l10n.lateStatUsualCycle, value: '${profile.cycleDays} j', cc: cc),
                if (cycleActuel != null)
                  _LateStatChip(label: l10n.lateStatCurrentCycle, value: '$cycleActuel j', cc: cc),
                if (lastPeriod != null)
                  _LateStatChip(label: l10n.lateStatLastPeriod, value: _fmtDate(lastPeriod, l10n), cc: cc),
                if (ovulation != null)
                  _LateStatChip(label: l10n.lateStatOvulation, value: _fmtDate(ovulation, l10n), cc: cc),
              ],
            ),
          ),

          const SizedBox(height: 22),

          // ── Message rassurant ───────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _LateInfoTile(
              icon: Icons.info_outline_rounded,
              iconColor: _green,
              cc: cc,
              text: l10n.lateReassurance,
            ),
          ),

          const SizedBox(height: 12),

          // ── Quand consulter ─────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _LateInfoTile(
              icon: Icons.health_and_safety_outlined,
              iconColor: cc.muted,
              cc: cc,
              title: l10n.lateConsultTitle,
              text: l10n.lateConsultText,
            ),
          ),

          const SizedBox(height: 12),

          // ── Test de grossesse ───────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _LateInfoTile(
              icon: Icons.science_outlined,
              iconColor: cc.muted,
              cc: cc,
              text: l10n.latePregnancyTest,
            ),
          ),

          const SizedBox(height: 26),

          // ── Boutons ──────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(children: [
              GestureDetector(
                onTap: () {
                  HapticFeedback.mediumImpact();
                  _logPeriodStart();
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  decoration: BoxDecoration(
                    color: _green,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [BoxShadow(
                      color: _green.withOpacity(0.24),
                      blurRadius: 14, offset: const Offset(0, 5))],
                  ),
                  child: Center(child: Text(l10n.lateBtnLog,
                    style: GoogleFonts.inter(fontSize: 13.5, fontWeight: FontWeight.w600,
                        color: Colors.white, letterSpacing: 0.1))),
                ),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  StorageService.setBool(_lateSnoozeKey, true);
                  setState(() => _lateSnoozed = true);
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: cc.border, width: 1.2),
                  ),
                  child: Center(child: Text(l10n.lateBtnRemindTomorrow,
                    style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600,
                        color: cc.text))),
                ),
              ),
              const SizedBox(height: 18),
              GestureDetector(
                onTap: () => _showLateInfoSheet(context, cc, l10n),
                child: Text(l10n.lateBtnMore,
                  style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w600,
                      color: cc.muted)),
              ),
            ]),
          ),

          const SizedBox(height: 48),
        ],
      ),
    );
  }

  void _showLateInfoSheet(BuildContext context, CycleColors cc, AppL10n l10n) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        decoration: BoxDecoration(
          color: cc.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(
              width: 36, height: 4,
              decoration: BoxDecoration(
                color: cc.muted.withOpacity(0.4),
                borderRadius: BorderRadius.circular(2)),
            )),
            const SizedBox(height: 18),
            Text(l10n.lateCausesTitle, style: GoogleFonts.outfit(
              fontSize: 16, fontWeight: FontWeight.w700, color: cc.text, letterSpacing: -0.2)),
            const SizedBox(height: 14),
            for (final cause in [
              l10n.lateCauseStress,
              l10n.lateCauseFatigue,
              l10n.lateCauseRoutine,
              l10n.lateCauseTravel,
              l10n.lateCauseHormonal,
              l10n.lateCauseMeds,
            ])
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(children: [
                  Container(width: 5, height: 5, margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(color: cc.muted, shape: BoxShape.circle)),
                  Text(cause, style: GoogleFonts.inter(fontSize: 13.5, color: cc.body)),
                ]),
              ),
          ],
        ),
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
                if (v == 'insights') {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const CycleInsightsScreen()));
                }
              },
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              elevation: 4,
              color: Colors.white,
              offset: const Offset(0, 44),
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: 'insights',
                  child: Row(children: [
                    Icon(Icons.insights_rounded, size: 17, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(width: 10),
                    Text(l10n.insightsMenuLabel, style: GoogleFonts.inter(
                      fontSize: 13, fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface)),
                  ]),
                ),
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
                        setState(() => _currentDay = _dayForDate(p, plain));
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

  Widget _buildSymptomSliders(CycleColors cc, CycleTheme theme, AppL10n l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: FloSymptom.values.map((s) {
          final logged = _logged.contains(s);
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                final wasLogged = _logged.contains(s);
                setState(() {
                  wasLogged ? _logged.remove(s) : _logged.add(s);
                });
                CycleLogService.saveSymptoms(
                  _today, _logged.map((e) => e.name).toSet());
                if (!wasLogged) {
                  ref.read(pointsProvider.notifier).rewardSymptomAdded().then((_) {
                    if (context.mounted) maybeShowLevelUpToast(context, ref);
                  });
                  PointsToast.show(context, PointsAmounts.symptomAdded, label: 'Symptôme noté !');
                  if (s == FloSymptom.cramps) {
                    ref.read(pointsProvider.notifier).rewardPainSymptom();
                  }
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: logged
                      ? theme.primary.withOpacity(0.10)
                      : cc.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: logged ? theme.primary.withOpacity(0.4) : cc.border,
                    width: 1.2),
                ),
                child: Row(children: [
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: logged
                          ? theme.primary.withOpacity(0.15)
                          : cc.surface2,
                      borderRadius: BorderRadius.circular(10)),
                    child: Icon(s.icon, size: 18,
                      color: logged ? theme.primary : cc.muted),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(s.labelFor(l10n), style: GoogleFonts.inter(
                      fontSize: 13, fontWeight: FontWeight.w600,
                      color: logged ? theme.primary : cc.text)),
                  ),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: logged
                        ? Icon(Icons.check_circle_rounded,
                            key: const ValueKey('check'),
                            size: 22, color: theme.primary)
                        : Icon(Icons.circle_outlined,
                            key: const ValueKey('circle'),
                            size: 22, color: cc.border),
                  ),
                ]),
              ),
            ),
          );
        }).toList(),
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
  final bool isLate;
  final int delayDays;
  final VoidCallback? onConfirmPeriod;

  static const lateYellow = Color(0xFFE8B93A);
  static const _yellow = lateYellow;

  const _CircularRing({
    required this.day, required this.total,
    required this.theme, required this.phase, required this.cc,
    required this.l10n,
    this.isLate = false,
    this.delayDays = 0,
    this.onConfirmPeriod,
  });

  @override
  Widget build(BuildContext context) {
    final ringSize = (MediaQuery.of(context).size.width * 0.54).clamp(180.0, 230.0);
    final ringColors = isLate
        ? const [_yellow, Color(0xFFF2CB6E), _yellow]
        : theme.gradient;
    final ringPrimary = isLate ? _yellow : theme.primary;

    return SizedBox(
      width: ringSize, height: ringSize,
      child: CustomPaint(
        painter: _RingPainter(
          day: day, total: total,
          colors: ringColors, primary: ringPrimary,
        ),
        child: Center(
          child: isLate
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Retard', style: GoogleFonts.inter(
                      fontSize: 13, color: _yellow, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text('$delayDays j', style: GoogleFonts.outfit(
                      fontSize: 44, fontWeight: FontWeight.w700, color: _yellow)),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.mediumImpact();
                        onConfirmPeriod?.call();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: _yellow.withOpacity(0.16),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: _yellow.withOpacity(0.4)),
                        ),
                        child: Text('Oui, c\'est arrivé', style: GoogleFonts.inter(
                          fontSize: 11, fontWeight: FontWeight.w700, color: _yellow)),
                      ),
                    ),
                  ],
                )
              : Column(
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
    const gap = 0.04; // gap between phase arcs in radians
    final rect = Rect.fromCircle(center: Offset(cx, cy), radius: r);

    final phases = phasesForCycleDays(total);
    final phaseColors = {
      'Règles': const Color(0xFFE58F8A),
      'Folliculaire': const Color(0xFF7ABB98),
      'Ovulation': const Color(0xFF1C4D30),
      'Lutéale': const Color(0xFFA7B8AD),
    };

    // Draw phase arcs as background
    for (final phase in phases) {
      if (phase.days.isEmpty) continue;
      final startDay = phase.days.first;
      final endDay = phase.days.last;
      final startAngle = -pi / 2 + ((startDay - 1) / total) * 2 * pi + gap / 2;
      final sweepAngle = ((endDay - startDay + 1) / total) * 2 * pi - gap;
      final color = phaseColors[phase.name] ?? primary;

      canvas.drawArc(rect, startAngle, sweepAngle, false, Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..color = color.withOpacity(0.18));
    }

    // Draw progress arcs (filled up to current day)
    for (final phase in phases) {
      if (phase.days.isEmpty) continue;
      final startDay = phase.days.first;
      final endDay = phase.days.last;
      if (day < startDay) continue;

      final clampedEnd = day < endDay ? day : endDay;
      final startAngle = -pi / 2 + ((startDay - 1) / total) * 2 * pi + gap / 2;
      final sweepAngle = ((clampedEnd - startDay + 1) / total) * 2 * pi - gap;
      final color = phaseColors[phase.name] ?? primary;

      canvas.drawArc(rect, startAngle, sweepAngle.clamp(0.01, 2 * pi), false, Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..color = color);
    }

    // Current day indicator dot
    final progress = (day / total).clamp(0.0, 1.0);
    final angle = -pi / 2 + progress * 2 * pi;
    final dotX = cx + r * cos(angle);
    final dotY = cy + r * sin(angle);
    canvas.drawCircle(Offset(dotX, dotY), 9, Paint()..color = Colors.white);
    canvas.drawCircle(Offset(dotX, dotY), 6, Paint()..color = primary);
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) =>
      old.day != day || old.total != total;
}

// ─────────────────────────────────────────────────────────────────────────────
//  LATE-STATE STAT CHIP
// ─────────────────────────────────────────────────────────────────────────────

class _LateStatChip extends StatelessWidget {
  final String label, value;
  final CycleColors cc;
  final bool highlight;

  const _LateStatChip({
    required this.label, required this.value, required this.cc,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    final color = highlight ? accent : cc.text;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: cc.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: highlight ? accent.withOpacity(0.3) : cc.border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label.toUpperCase(), style: GoogleFonts.inter(
          fontSize: 9.5, fontWeight: FontWeight.w600, color: cc.muted, letterSpacing: 0.4)),
        const SizedBox(height: 3),
        Text(value, style: GoogleFonts.outfit(
          fontSize: 15, fontWeight: FontWeight.w700, color: color, letterSpacing: -0.2)),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  LATE-STATE INFO TILE
// ─────────────────────────────────────────────────────────────────────────────

class _LateInfoTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final CycleColors cc;
  final String? title;
  final String text;

  const _LateInfoTile({
    required this.icon, required this.iconColor, required this.cc,
    this.title, required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cc.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cc.border),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, size: 18, color: iconColor),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (title != null) ...[
            Text(title!, style: GoogleFonts.inter(
              fontSize: 13, fontWeight: FontWeight.w600, color: cc.text)),
            const SizedBox(height: 4),
          ],
          Text(text, style: GoogleFonts.inter(
            fontSize: 12.5, color: cc.body, height: 1.55)),
        ])),
      ]),
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

class _PhaseTipsCarousel extends StatefulWidget {
  final CyclePhase phase;
  final CycleTheme theme;
  final CycleColors cc;
  final AppL10n l10n;

  const _PhaseTipsCarousel({
    required this.phase, required this.theme, required this.cc, required this.l10n,
  });

  @override
  State<_PhaseTipsCarousel> createState() => _PhaseTipsCarouselState();
}

class _PhaseTipsCarouselState extends State<_PhaseTipsCarousel> {
  int _current = 0;
  late final PageController _pageCtrl;

  @override
  void initState() {
    super.initState();
    _pageCtrl = PageController(viewportFraction: 0.88);
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  static const _tipIcons = [
    Icons.fitness_center_rounded,
    Icons.restaurant_outlined,
    Icons.spa_outlined,
  ];
  static const _tipLabels = ['Entraînement', 'Nutrition', 'Bien-être'];

  List<String> _tipsForPhase() {
    final tip = widget.l10n.cyclePhaseTips(widget.phase.name);
    final wellnessTips = {
      'Règles': 'Privilégie le repos et les étirements doux. Une bouillotte sur le ventre peut soulager les crampes.',
      'Folliculaire': 'C\'est le moment d\'essayer de nouvelles activités ! Ton corps récupère vite et ta motivation est haute.',
      'Ovulation': 'Profite de ton pic d\'énergie sociale. Médite 5 min pour canaliser cette vitalité.',
      'Lutéale': 'Écoute ton corps : yoga doux, bain chaud et sommeil suffisant. Réduis le stress autant que possible.',
    };
    return [tip.workout, tip.nutrition, wellnessTips[widget.phase.name] ?? ''];
  }

  @override
  Widget build(BuildContext context) {
    final tips = _tipsForPhase();
    return Column(children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(children: [
          Container(width: 8, height: 8,
            decoration: BoxDecoration(color: widget.theme.primary, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Text(widget.l10n.cycleDailyTips, style: GoogleFonts.outfit(
            fontSize: 14, fontWeight: FontWeight.w700, color: widget.theme.primary)),
        ]),
      ),
      const SizedBox(height: 12),
      SizedBox(
        height: 140,
        child: PageView.builder(
          controller: _pageCtrl,
          itemCount: tips.length,
          onPageChanged: (i) => setState(() => _current = i),
          itemBuilder: (_, i) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 6),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: _current == i
                    ? widget.theme.primary.withOpacity(widget.cc.isDark ? 0.18 : 0.10)
                    : widget.cc.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _current == i
                      ? widget.theme.primary.withOpacity(0.3)
                      : widget.cc.border),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Container(
                    width: 34, height: 34,
                    decoration: BoxDecoration(
                      color: widget.theme.primary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10)),
                    child: Icon(_tipIcons[i], size: 16, color: widget.theme.primary),
                  ),
                  const SizedBox(width: 10),
                  Text(_tipLabels[i], style: GoogleFonts.inter(
                    fontSize: 12, fontWeight: FontWeight.w700, color: widget.theme.primary)),
                ]),
                const SizedBox(height: 10),
                Expanded(
                  child: Text(tips[i], style: GoogleFonts.inter(
                    fontSize: 12.5, color: widget.cc.body, height: 1.5),
                    maxLines: 3, overflow: TextOverflow.ellipsis),
                ),
              ]),
            );
          },
        ),
      ),
      const SizedBox(height: 10),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(tips.length, (i) => AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: _current == i ? 18 : 6, height: 6,
          decoration: BoxDecoration(
            color: _current == i ? widget.theme.primary : widget.cc.border,
            borderRadius: BorderRadius.circular(3)),
        )),
      ),
    ]);
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

// ─────────────────────────────────────────────────────────────────────────────
//  CYCLE TIMELINE BANNER (replaces period + ovulation cards)
// ─────────────────────────────────────────────────────────────────────────────

class _CycleTimelineBanner extends StatelessWidget {
  final int currentDay, cycleDays;
  final DateTime? nextPeriod, ovulationDate;
  final CycleTheme theme;
  final CycleColors cc;
  final AppL10n l10n;

  const _CycleTimelineBanner({
    required this.currentDay, required this.cycleDays,
    required this.nextPeriod, required this.ovulationDate,
    required this.theme, required this.cc, required this.l10n,
  });

  static const _months = ['jan','fév','mar','avr','mai','juin','juil','août','sep','oct','nov','déc'];
  static const _pink = Color(0xFFE58F8A);

  @override
  Widget build(BuildContext context) {
    final phases = phasesForCycleDays(cycleDays);
    final phaseColors = {
      'Règles': const Color(0xFFE58F8A),
      'Folliculaire': const Color(0xFF7ABB98),
      'Ovulation': const Color(0xFF1C4D30),
      'Lutéale': const Color(0xFFA7B8AD),
    };

    final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    String periodLabel = '—';
    String ovLabel = '—';
    if (nextPeriod != null) {
      final d = nextPeriod!.difference(today).inDays;
      periodLabel = d == 0 ? 'Aujourd\'hui'
          : d < 0 ? 'Retard ${-d}j'
          : '${nextPeriod!.day} ${_months[nextPeriod!.month - 1]}';
    }
    if (ovulationDate != null) {
      final d = ovulationDate!.difference(today).inDays;
      ovLabel = d == 0 ? 'Aujourd\'hui'
          : d < 0 ? 'Passée'
          : '${ovulationDate!.day} ${_months[ovulationDate!.month - 1]}';
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cc.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: cc.border),
        boxShadow: [BoxShadow(
          color: theme.primary.withOpacity(cc.isDark ? 0.10 : 0.06),
          blurRadius: 16, offset: const Offset(0, 4))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Phase bar
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: SizedBox(
            height: 12,
            child: Row(
              children: phases.map((p) {
                final fraction = p.days.length / cycleDays;
                final color = phaseColors[p.name] ?? theme.primary;
                final isCurrent = p.days.contains(currentDay);
                return Expanded(
                  flex: (fraction * 100).round().clamp(1, 100),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 1),
                    decoration: BoxDecoration(
                      color: isCurrent ? color : color.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(6)),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 6),

        // Phase labels
        Row(
          children: phases.map((p) {
            final fraction = p.days.length / cycleDays;
            final color = phaseColors[p.name] ?? theme.primary;
            final isCurrent = p.days.contains(currentDay);
            return Expanded(
              flex: (fraction * 100).round().clamp(1, 100),
              child: Text(
                p.name.substring(0, p.name.length > 4 ? 4 : p.name.length),
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 8, fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                  color: isCurrent ? color : cc.muted),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 14),

        // Info row
        Row(children: [
          _TimelineInfo(
            icon: Icons.water_drop_outlined, color: _pink,
            label: l10n.cycleNextPeriod, value: periodLabel, cc: cc),
          const SizedBox(width: 16),
          Container(width: 1, height: 36, color: cc.border),
          const SizedBox(width: 16),
          _TimelineInfo(
            icon: Icons.spa_outlined, color: theme.primary,
            label: l10n.cycleOvulation, value: ovLabel, cc: cc),
        ]),
      ]),
    );
  }
}

class _TimelineInfo extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label, value;
  final CycleColors cc;

  const _TimelineInfo({
    required this.icon, required this.color,
    required this.label, required this.value, required this.cc,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(children: [
        Container(
          width: 32, height: 32,
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(9)),
          child: Icon(icon, size: 15, color: color),
        ),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: GoogleFonts.inter(
            fontSize: 9, color: cc.muted, fontWeight: FontWeight.w500)),
          Text(value, style: GoogleFonts.inter(
            fontSize: 13, fontWeight: FontWeight.w700, color: cc.text)),
        ])),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  DAILY INSIGHT CARD
// ─────────────────────────────────────────────────────────────────────────────

class _DailyInsightCard extends StatelessWidget {
  final CyclePhase phase;
  final CycleTheme theme;
  final CycleColors cc;
  final int currentDay, cycleDays;

  const _DailyInsightCard({
    required this.phase, required this.theme, required this.cc,
    required this.currentDay, required this.cycleDays,
  });

  static const _insights = {
    'Règles': [
      '🌸 Ton corps se régénère — hydrate-toi bien et privilégie le repos.',
      '💧 Le fer est ton allié cette semaine. Pense aux lentilles et épinards.',
      '🧘 Des étirements doux peuvent soulager les tensions. Écoute ton corps.',
    ],
    'Folliculaire': [
      '🌱 Ton énergie monte ! C\'est le moment idéal pour un entraînement intense.',
      '⚡ Tes œstrogènes grimpent — ta peau brille et ta motivation aussi.',
      '🏃‍♀️ Essaie du HIIT ou de la musculation, ton corps récupère vite.',
    ],
    'Ovulation': [
      '✨ Pic d\'énergie et de confiance ! Profite de cette période pour te dépasser.',
      '💪 Ton corps est au maximum de ses capacités. Sois ambitieuse dans tes objectifs.',
      '🧠 Clarté mentale optimale — idéal pour les décisions importantes.',
    ],
    'Lutéale': [
      '🍂 Ton corps se prépare — augmente les glucides complexes pour stabiliser l\'humeur.',
      '🫖 Envies de sucre ? C\'est normal. Opte pour du chocolat noir et des fruits.',
      '😴 Priorise le sommeil, ton corps en a besoin pour se recharger.',
    ],
  };

  @override
  Widget build(BuildContext context) {
    final tips = _insights[phase.name] ?? _insights['Lutéale']!;
    final tip = tips[currentDay % tips.length];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.primary.withOpacity(cc.isDark ? 0.20 : 0.10),
            theme.primary.withOpacity(cc.isDark ? 0.08 : 0.03),
          ],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.primary.withOpacity(0.18)),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            color: theme.primary.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12)),
          child: Icon(Icons.auto_awesome_rounded, size: 20, color: theme.primary),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Insight du jour', style: GoogleFonts.inter(
            fontSize: 10, fontWeight: FontWeight.w700,
            color: theme.primary, letterSpacing: 1)),
          const SizedBox(height: 6),
          Text(tip, style: GoogleFonts.inter(
            fontSize: 13, color: cc.body, height: 1.5)),
        ])),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  WEEKLY MOOD CHART
// ─────────────────────────────────────────────────────────────────────────────

class _WeeklyMoodChart extends StatelessWidget {
  final int moodIndex;
  final CycleTheme theme;
  final CycleColors cc;
  final AppL10n l10n;
  final void Function(int) onSelectMood;

  const _WeeklyMoodChart({
    required this.moodIndex, required this.theme,
    required this.cc, required this.l10n, required this.onSelectMood,
  });

  static const _moodEmojis = ['😊', '🙂', '😐', '😔', '🧘'];
  static const _moodLabels = ['Super', 'Bien', 'Moyen', 'Bas', 'Calme'];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cc.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: cc.border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(width: 8, height: 8,
            decoration: BoxDecoration(color: theme.primary, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Text('Humeur', style: GoogleFonts.outfit(
            fontSize: 14, fontWeight: FontWeight.w700, color: theme.primary)),
        ]),
        const SizedBox(height: 14),

        // Mood selector row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(_moodEmojis.length, (i) {
            final selected = moodIndex == i;
            return GestureDetector(
              onTap: () => onSelectMood(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                width: 54, height: 68,
                decoration: BoxDecoration(
                  color: selected
                      ? theme.primary.withOpacity(0.12)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: selected ? theme.primary.withOpacity(0.4) : cc.border,
                    width: selected ? 1.5 : 1),
                ),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text(_moodEmojis[i], style: TextStyle(
                    fontSize: selected ? 24 : 20)),
                  const SizedBox(height: 4),
                  Text(_moodLabels[i], style: GoogleFonts.inter(
                    fontSize: 9, fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: selected ? theme.primary : cc.muted)),
                ]),
              ),
            );
          }),
        ),
      ]),
    );
  }
}
