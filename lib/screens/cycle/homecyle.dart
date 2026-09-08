// ignore_for_file: deprecated_member_use
import 'dart:async';
import 'dart:math';
import 'dart:ui';
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
import 'package:fiteva/screens/cycle/cycle_history_screen.dart';
import '../../services/app_tour_service.dart';
import '../../l10n/lang.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

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

  Color get tint {
    switch (this) {
      case FloSymptom.flow:   return const Color(0xFF4FC3F7);
      case FloSymptom.mood:   return const Color(0xFFFFCA28);
      case FloSymptom.energy: return const Color(0xFFFF8A65);
      case FloSymptom.cramps: return const Color(0xFFEF9A9A);
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

CycleTheme getTheme(int day, {int cycleDays = 28, Color? accent}) {
  final phase = phaseForDay(day, cycleDays: cycleDays);
  switch (phase.name) {
    case 'Règles':
      const c = Color(0xFFE88B8B);
      return const CycleTheme(
        gradient: [c, Color(0xFFD97B7B), Color(0xFFF2AAAA)],
        primary: c,
        glow: Color(0x40E88B8B),
      );
    case 'Folliculaire':
      const c = Color(0xFF7EB6E6);
      return const CycleTheme(
        gradient: [c, Color(0xFF6BA8DD), Color(0xFFA4CCF0)],
        primary: c,
        glow: Color(0x407EB6E6),
      );
    case 'Ovulation':
      const c = Color(0xFFE8AD6E);
      return const CycleTheme(
        gradient: [c, Color(0xFFD99E5E), Color(0xFFF0C494)],
        primary: c,
        glow: Color(0x40E8AD6E),
      );
    default:
      const c = Color(0xFFA99ED4);
      return const CycleTheme(
        gradient: [c, Color(0xFF9A8EC8), Color(0xFFBFB6E0)],
        primary: c,
        glow: Color(0x40A99ED4),
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
  final _keyCycleWheel = GlobalKey();
  final _keySymptoms   = GlobalKey();
  final _keyCalendar   = GlobalKey();
  final _keyCoach      = GlobalKey();

  late int _currentDay;
  DateTime? _selectedDate;
  final Set<FloSymptom> _logged = {};
  int _moodIndex = -1; // -1 = non sélectionné
  final DateTime _today = DateTime.now();
  bool _switching = false;
  // "Me rappeler demain" — persisté (clé datée du jour) au lieu d'être gardé
  // uniquement en mémoire, sinon rouvrir l'app faisait réapparaître l'écran
  // plein écran de retard de règles alors que l'utilisatrice l'avait déjà
  // explicitement masqué pour la journée.
  bool _lateSnoozed = false;
  final PageController _weekPageCtrl = PageController(initialPage: 26);
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
    _showTutorial();
  }

  void _showTutorial() {
    final isFr = Lang.code == 'fr';
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 600), () {
        if (!mounted) return;
        AppTourService.showSectionTutorial(context,
          section: 'cycle',
          steps: [
            SpotlightStep(
              key: _keyCycleWheel,
              icon: LucideIcons.heartPulse,
              color: const Color(0xFFE91E63),
              title: isFr ? 'Suivi du Cycle' : 'Cycle Tracking',
              description: isFr
                  ? 'Visualise ou tu en es dans ton cycle avec la roue interactive.'
                  : 'See where you are in your cycle with the interactive wheel.',
              shape: ShapeLightFocus.Circle,
            ),
            SpotlightStep(
              key: _keySymptoms,
              icon: LucideIcons.stethoscope,
              color: const Color(0xFF7C4DFF),
              title: isFr ? 'Symptômes & Humeur' : 'Symptoms & Mood',
              description: isFr
                  ? 'Note tes symptômes et ton humeur chaque jour pour des conseils personnalisés.'
                  : 'Log your symptoms and mood daily for personalized advice.',
              contentAlign: ContentAlign.top,
            ),
            SpotlightStep(
              key: _keyCalendar,
              icon: LucideIcons.calendarDays,
              color: const Color(0xFF1E88E5),
              title: isFr ? 'Calendrier' : 'Calendar',
              description: isFr
                  ? 'Consulte ton historique et prevois tes prochaines regles.'
                  : 'Check your history and predict your next period.',
            ),
            SpotlightStep(
              key: _keyCoach,
              icon: LucideIcons.lightbulb,
              color: const Color(0xFFFF9800),
              title: isFr ? 'Coach IA' : 'AI Coach',
              description: isFr
                  ? 'Recois des conseils adaptes a ta phase de cycle actuelle.'
                  : 'Get tips adapted to your current cycle phase.',
              contentAlign: ContentAlign.top,
            ),
          ],
        );
      });
    });
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
    _weekPageCtrl.dispose();
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
    final theme = getTheme(_currentDay, cycleDays: cycleDays, accent: Theme.of(context).colorScheme.primary);
    final phase = phaseForDay(_currentDay, cycleDays: cycleDays);

    return Scaffold(
      backgroundColor: _screenBg(cc.isDark),
      body: AnimatedBuilder(
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
    );
  }


  static Color _screenBg(bool isDark) =>
      isDark ? const Color(0xFF111114) : const Color(0xFFF5F0EB);

  static List<Color> _phaseGradient(CycleTheme theme, bool isDark) {
    final base = theme.primary;
    if (isDark) {
      return [
        base.withOpacity(0.35),
        base.withOpacity(0.15),
        base.withOpacity(0.05),
        const Color(0xFF111114),
      ];
    }
    return [
      base.withOpacity(0.25),
      base.withOpacity(0.12),
      base.withOpacity(0.04),
      const Color(0xFFF5F0EB),
    ];
  }

  static Widget _glassCard({required Widget child, required bool isDark, double radius = 18}) {
    return Container(
      decoration: BoxDecoration(
        color: _screenBg(isDark),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.06)
              : Colors.black.withOpacity(0.05),
        ),
      ),
      child: child,
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
          // ── Dark immersive hero ──
          _buildHero(cc, theme, phase, profile, showPregnancy, l10n),

          // ── Action buttons ──
          _buildActionButtons(cc, theme, phase, l10n),

          const SizedBox(height: 18),

          // ── Stats (glass card) ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _glassCard(isDark: cc.isDark, child: Padding(
              padding: const EdgeInsets.all(12),
              child: _InfoPillsRow(
                currentDay: _currentDay,
                cycleDays: profile.cycleDays,
                nextPeriod: profile.pendingPeriodDate,
                ovulationDate: profile.ovulationDate,
                theme: theme, cc: cc, l10n: l10n,
              ),
            )),
          ),

          const SizedBox(height: 18),

          // ── Symptoms (glass card) ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _glassCard(isDark: cc.isDark, child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(l10n.cycleHowDoYouFeel, style: GoogleFonts.outfit(
                  fontSize: 15, fontWeight: FontWeight.w700, color: cc.text)),
                const SizedBox(height: 12),
                KeyedSubtree(key: _keySymptoms, child: _buildSymptomBubbles(cc, theme, l10n, Colors.transparent)),
              ]),
            )),
          ),

          const SizedBox(height: 18),

          // ── Daily insights (glass card) ──
          Padding(
            key: _keyCoach,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _glassCard(isDark: cc.isDark, child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 4),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(l10n.isFrench ? 'Mes conseils · Aujourd\'hui' : 'My daily insights · Today',
                  style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w700, color: cc.text)),
                const SizedBox(height: 10),
                _PhaseTipsCarousel(phase: phase, theme: theme, cc: cc, l10n: l10n),
              ]),
            )),
          ),

          const SizedBox(height: 18),

          // ── Cycle history (glass card) ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _glassCard(isDark: cc.isDark, child: _buildCycleHistory(cc, profile, l10n)),
          ),

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
    final heroText = cc.isDark ? Colors.white : const Color(0xFF2D1B33);
    final heroMuted = cc.isDark ? Colors.white60 : const Color(0xFF8A7E80);
    final iconColor = heroText.withOpacity(0.7);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: _phaseGradient(theme, cc.isDark),
          stops: const [0.0, 0.4, 0.7, 1.0],
        ),
      ),
      child: Column(children: [
        SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 16, 0),
            child: Row(children: [
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.navCycle.toUpperCase(), style: GoogleFonts.inter(
                    fontSize: 10, fontWeight: FontWeight.w600,
                    letterSpacing: 1.5, color: heroMuted)),
                  const SizedBox(height: 2),
                  Text(l10n.cycleTitle, style: GoogleFonts.outfit(
                    fontSize: 22, fontWeight: FontWeight.w700, color: heroText)),
                ],
              )),
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
                    value: 'pregnancy',
                    child: Row(children: [
                      const Text('\u{1F930}', style: TextStyle(fontSize: 16)),
                      const SizedBox(width: 10),
                      Text(l10n.navPregnancy, style: GoogleFonts.inter(
                        fontSize: 13, fontWeight: FontWeight.w600,
                        color: const Color(0xFF1A2E20))),
                    ]),
                  ),
                ],
                child: Icon(Icons.more_horiz_rounded,
                    size: 22, color: iconColor),
              ),
              const SizedBox(width: 6),
              GestureDetector(
                key: _keyCalendar,
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
                child: Icon(Icons.calendar_month_rounded,
                    size: 22, color: iconColor),
              ),
            ]),
          ),
        ),

        // ── Week strip ──
        const SizedBox(height: 14),
        _buildWeekStrip(theme, profile, cc),

        const SizedBox(height: 16),

        // ── Ring ──
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: theme.primary.withOpacity(0.35),
                blurRadius: 60, spreadRadius: 10,
              ),
            ],
          ),
          child: _CircularRing(
            key: _keyCycleWheel,
            day: _currentDay, total: profile.cycleDays,
            theme: theme, phase: phase, cc: cc, l10n: l10n,
          ),
        ),

        const SizedBox(height: 16),

        // ── Phase chip ──
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: theme.primary.withOpacity(0.18),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '${phase.name} · ${l10n.isFrench ? 'Jour' : 'Day'} $_currentDay',
            style: GoogleFonts.inter(
              fontSize: 12, fontWeight: FontWeight.w700, color: theme.primary)),
        ),

        const SizedBox(height: 20),
      ]),
    );
  }

  static const _periodColor = Color(0xFFE88B8B);
  static const _ovulationColor = Color(0xFFE8AD6E);

  Widget _buildWeekStrip(CycleTheme theme, UserProfile profile, CycleColors cc) {
    final l10n = ref.watch(l10nProvider);
    final now = DateTime(_today.year, _today.month, _today.day);
    final dayLetters = l10n.isFrench
        ? ['L', 'M', 'M', 'J', 'V', 'S', 'D']
        : ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final monthNames = l10n.isFrench
        ? ['Janvier','Février','Mars','Avril','Mai','Juin','Juillet','Août','Septembre','Octobre','Novembre','Décembre']
        : ['January','February','March','April','May','June','July','August','September','October','November','December'];
    final periodStart = profile.lastPeriod;
    final cycleDays = profile.cycleDays;
    final dayColor = cc.isDark ? Colors.white54 : const Color(0xFF8A7080);
    final labelColor = cc.isDark ? Colors.white38 : const Color(0xFFAA96A2);
    final sel = _selectedDate;

    const totalWeeks = 53;
    const initialPage = 26;

    // The displayed date: selected day or today
    final displayDate = sel ?? now;

    return Column(mainAxisSize: MainAxisSize.min, children: [
      // Month + day header (centered)
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
        child: Center(
          child: Text(
            '${monthNames[displayDate.month - 1]} ${displayDate.day}',
            style: GoogleFonts.outfit(
              fontSize: 16, fontWeight: FontWeight.w700, color: cc.text),
          ),
        ),
      ),
      // Week strip
      SizedBox(
        height: 62,
        child: PageView.builder(
          controller: _weekPageCtrl,
          itemCount: totalWeeks,
          itemBuilder: (context, pageIndex) {
            final weekOffset = pageIndex - initialPage;
            final monday = now.subtract(Duration(days: now.weekday - 1)).add(Duration(days: weekOffset * 7));
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(7, (i) {
                  final day = monday.add(Duration(days: i));
                  final isToday = day.day == now.day && day.month == now.month && day.year == now.year;
                  final isSelected = sel != null && day.day == sel.day && day.month == sel.month && day.year == sel.year;
                  final isPeriod = _isDayInPeriod(day, periodStart, cycleDays);
                  final isOvulation = _isDayInOvulation(day, periodStart, cycleDays);

                  final isFilled = isSelected || (isToday && sel == null);
                  Color bgColor = Colors.transparent;
                  Color textColor = dayColor;
                  Color? dotColor;

                  if (isFilled) {
                    bgColor = isPeriod ? _periodColor : isOvulation ? _ovulationColor : theme.primary;
                    textColor = Colors.white;
                  } else if (isPeriod) {
                    textColor = _periodColor;
                    dotColor = _periodColor;
                  } else if (isOvulation) {
                    textColor = _ovulationColor;
                    dotColor = _ovulationColor;
                  }

                  final showTodayRing = isToday && sel != null && !isSelected;

                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      final tappedNorm = DateTime(day.year, day.month, day.day);
                      final isSameAsToday = tappedNorm.isAtSameMomentAs(now);
                      setState(() {
                        if (isSameAsToday && sel != null) {
                          _selectedDate = null;
                          _currentDay = _computeCurrentDay(profile);
                        } else if (!isSameAsToday) {
                          _selectedDate = tappedNorm;
                          _currentDay = _dayForDate(profile, tappedNorm);
                        }
                      });
                    },
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Text(dayLetters[i], style: GoogleFonts.inter(
                        fontSize: 10, fontWeight: FontWeight.w600,
                        color: isFilled
                            ? (cc.isDark ? Colors.white : cc.text) : labelColor)),
                      const SizedBox(height: 6),
                      SizedBox(
                        width: 36, height: 36,
                        child: CustomPaint(
                          painter: dotColor != null && !isFilled
                              ? _DottedCirclePainter(color: dotColor)
                              : null,
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: bgColor,
                              border: showTodayRing
                                  ? Border.all(color: cc.text.withOpacity(0.35), width: 1.5)
                                  : null,
                            ),
                            child: Center(child: Text(
                              '${day.day}',
                              style: GoogleFonts.inter(
                                fontSize: 14, fontWeight: FontWeight.w600,
                                color: textColor),
                            )),
                          ),
                        ),
                      ),
                    ]),
                  );
                }),
              ),
            );
          },
        ),
      ),
    ]);
  }

  bool _isDayInPeriod(DateTime day, DateTime? periodStart, int cycleDays) {
    if (periodStart == null) return false;
    final ps = DateTime(periodStart.year, periodStart.month, periodStart.day);
    final d = DateTime(day.year, day.month, day.day);
    final diff = d.difference(ps).inDays;
    if (diff < 0) return false;
    final dayInCycle = (diff % cycleDays) + 1;
    return dayInCycle <= 5;
  }

  bool _isDayInOvulation(DateTime day, DateTime? periodStart, int cycleDays) {
    if (periodStart == null) return false;
    final ps = DateTime(periodStart.year, periodStart.month, periodStart.day);
    final d = DateTime(day.year, day.month, day.day);
    final diff = d.difference(ps).inDays;
    if (diff < 0) return false;
    final dayInCycle = (diff % cycleDays) + 1;
    final ovDay = (cycleDays - 14).clamp(1, cycleDays);
    return dayInCycle >= ovDay - 1 && dayInCycle <= ovDay + 1;
  }

  Widget _buildActionButtons(CycleColors cc, CycleTheme theme, CyclePhase phase, AppL10n l10n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(30, 18, 30, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _ActionBtn(
            icon: Icons.edit_calendar_rounded,
            label: l10n.isFrench ? 'Modifier\nrègles' : 'Edit\nperiod',
            color: const Color(0xFFE88B8B),
            cc: cc,
            onTap: () {
              HapticFeedback.lightImpact();
              final profile = ref.read(userProfileProvider);
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
                  },
                ),
                transitionsBuilder: (_, a, __, child) =>
                    FadeTransition(opacity: a, child: child),
              ));
            },
          ),
          _ActionBtn(
            icon: Icons.add_rounded,
            label: l10n.isFrench ? 'Symptômes' : 'Symptoms',
            color: cc.text,
            cc: cc,
            onTap: () {
              HapticFeedback.lightImpact();
              Scrollable.ensureVisible(
                _keySymptoms.currentContext ?? context,
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOut,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCycleHistory(CycleColors cc, UserProfile profile, AppL10n l10n) {
    final lp = profile.lastPeriod;
    if (lp == null) return const SizedBox.shrink();

    final cycleDays = profile.cycleDays;
    final today = DateTime(_today.year, _today.month, _today.day);
    final lpNorm = DateTime(lp.year, lp.month, lp.day);
    final currentLen = today.difference(lpNorm).inDays + 1;

    final months = l10n.isFrench
        ? ['jan','fév','mar','avr','mai','juin','juil','août','sep','oct','nov','déc']
        : ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    String fmt(DateTime d) => '${d.day} ${months[d.month - 1]}';

    // Build past cycles going backwards
    final cycles = <_CycleEntry>[];
    cycles.add(_CycleEntry(
      label: l10n.isFrench ? 'Cycle actuel : $currentLen jours' : 'Current cycle: $currentLen days',
      sub: l10n.isFrench ? 'Début ${fmt(lpNorm)}' : 'Started ${fmt(lpNorm)}',
      days: currentLen,
      isCurrent: true,
    ));

    var cursor = lpNorm;
    for (int i = 0; i < 3; i++) {
      final end = cursor.subtract(const Duration(days: 1));
      final start = end.subtract(Duration(days: cycleDays - 1));
      cycles.add(_CycleEntry(
        label: '$cycleDays ${l10n.isFrench ? 'jours' : 'days'}',
        sub: '${fmt(start)} – ${fmt(end)}',
        days: cycleDays,
        isCurrent: false,
      ));
      cursor = start;
    }

    final accent = Theme.of(context).colorScheme.primary;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
          child: Row(children: [
            Expanded(child: Text(
              l10n.isFrench ? 'Historique du cycle' : 'Cycle history',
              style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w700, color: cc.text))),
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => const CycleHistoryScreen()));
              },
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Text(l10n.isFrench ? 'Tout voir' : 'See all', style: GoogleFonts.inter(
                  fontSize: 12, fontWeight: FontWeight.w600, color: cc.muted)),
                const SizedBox(width: 4),
                Icon(Icons.chevron_right_rounded, size: 16, color: cc.muted),
              ]),
            ),
          ]),
        ),
        ...cycles.map((c) => _buildCycleRow(cc, c, cycleDays, accent)),
        const SizedBox(height: 10),
      ]);
  }

  Widget _buildCycleRow(CycleColors cc, _CycleEntry entry, int cycleDays, Color accent) {
    final phases = phasesForCycleDays(cycleDays, accent: accent);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Divider(height: 1, color: cc.border.withOpacity(0.4)),
        const SizedBox(height: 10),
        Text(entry.label, style: GoogleFonts.outfit(
          fontSize: 14, fontWeight: FontWeight.w700, color: cc.text)),
        const SizedBox(height: 2),
        Text(entry.sub, style: GoogleFonts.inter(
          fontSize: 12, color: cc.muted)),
        const SizedBox(height: 8),
        // Colored dots strip
        Row(children: List.generate(
          entry.isCurrent ? entry.days.clamp(1, cycleDays) : cycleDays,
          (i) {
            final dayNum = i + 1;
            Color dotColor = cc.muted.withOpacity(0.25);
            for (final p in phases) {
              if (p.days.contains(dayNum)) {
                dotColor = p.color;
                break;
              }
            }
            return Expanded(child: Container(
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 0.5),
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
              ),
            ));
          },
        )),
      ]),
    );
  }

  static const _moodEmojis = ['😊', '🙂', '😐', '😔', '🧘'];
  static const _moodLabels = ['Super', 'Bien', 'Moyen', 'Bas', 'Calme'];

  Widget _buildSymptomBubbles(CycleColors cc, CycleTheme theme, AppL10n l10n, Color pageBg) {
    return Column(children: [
      Row(
          children: FloSymptom.values.map((s) {
            final logged = _logged.contains(s);
            final isMood = s == FloSymptom.mood;
            final clr = logged ? theme.primary : s.tint;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    final wasLogged = _logged.contains(s);
                    setState(() {
                      wasLogged ? _logged.remove(s) : _logged.add(s);
                      if (isMood && wasLogged) _moodIndex = -1;
                    });
                    CycleLogService.saveSymptoms(
                      _today, _logged.map((e) => e.name).toSet());
                    if (isMood && wasLogged) {
                      CycleLogService.saveMood(_today, -1);
                    }
                    if (!wasLogged) {
                      ref.read(pointsProvider.notifier).rewardSymptomAdded().then((_) {
                        if (context.mounted) maybeShowLevelUpToast(context, ref);
                      });
                      PointsToast.show(context, PointsAmounts.symptomAdded, label: 'Symptome note !');
                      if (s == FloSymptom.cramps) {
                        ref.read(pointsProvider.notifier).rewardPainSymptom();
                      }
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: logged
                          ? clr.withOpacity(cc.isDark ? 0.18 : 0.10)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: logged ? clr.withOpacity(0.45) : cc.isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.06),
                        width: logged ? 1.5 : 1),
                    ),
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Icon(s.icon, size: 26, color: clr),
                      const SizedBox(height: 6),
                      Text(s.labelFor(l10n), style: GoogleFonts.inter(
                        fontSize: 11, fontWeight: logged ? FontWeight.w700 : FontWeight.w500,
                        color: logged ? clr : cc.muted),
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                      if (isMood && _moodIndex >= 0) ...[
                        const SizedBox(height: 2),
                        Text(_moodLabels[_moodIndex], style: GoogleFonts.inter(
                          fontSize: 9, fontWeight: FontWeight.w600, color: clr)),
                      ],
                      if (logged) ...[
                        const SizedBox(height: 4),
                        Icon(Icons.check_circle_rounded, size: 14, color: clr),
                      ],
                    ]),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      // Mood emoji picker
      AnimatedCrossFade(
        duration: const Duration(milliseconds: 250),
        crossFadeState: _logged.contains(FloSymptom.mood)
            ? CrossFadeState.showSecond
            : CrossFadeState.showFirst,
        firstChild: const SizedBox.shrink(),
        secondChild: Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
            decoration: BoxDecoration(
              color: pageBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: theme.primary.withOpacity(0.15)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(_moodEmojis.length, (i) {
                final selected = _moodIndex == i;
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    setState(() => _moodIndex = i);
                    CycleLogService.saveMood(_today, i);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    width: 52, height: 62,
                    decoration: BoxDecoration(
                      color: selected
                          ? theme.primary.withOpacity(0.15)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: selected ? theme.primary.withOpacity(0.4) : Colors.transparent,
                        width: 2),
                    ),
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Text(_moodEmojis[i], style: TextStyle(
                        fontSize: selected ? 24 : 20)),
                      const SizedBox(height: 3),
                      Text(_moodLabels[i], style: GoogleFonts.inter(
                        fontSize: 9, fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                        color: selected ? theme.primary : cc.muted)),
                    ]),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    ]);
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
    super.key,
    required this.day, required this.total,
    required this.theme, required this.phase, required this.cc,
    required this.l10n,
    this.isLate = false,
    this.delayDays = 0,
    this.onConfirmPeriod,
  });

  @override
  Widget build(BuildContext context) {
    final ringSize = (MediaQuery.of(context).size.width * 0.62).clamp(200.0, 260.0);
    final ringPrimary = isLate ? _yellow : theme.primary;

    return SizedBox(
      width: ringSize, height: ringSize,
      child: CustomPaint(
        painter: _RingPainter(
          day: day, total: total,
          colors: theme.gradient, primary: ringPrimary,
          accent: Theme.of(context).colorScheme.primary,
          isDark: cc.isDark,
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
              : _buildCountdownCenter(),
        ),
      ),
    );
  }

  Widget _buildCountdownCenter() {
    final textColor = cc.isDark ? Colors.white : const Color(0xFF2D1B33);
    final mutedColor = cc.isDark ? Colors.white54 : const Color(0xFF8A7E80);
    final ovDay = (total - 14).clamp(1, total);
    final periodDays = 5;

    String topLabel;
    String bigNumber;
    String bottomLabel;

    if (day <= periodDays) {
      topLabel = phase.name;
      bigNumber = '$day';
      bottomLabel = l10n.isFrench ? 'jour' : 'day';
    } else if (day < ovDay - 1) {
      final daysToOv = ovDay - day;
      topLabel = l10n.isFrench ? 'Ovulation dans' : 'Ovulation in';
      bigNumber = '$daysToOv';
      bottomLabel = l10n.isFrench
          ? '${daysToOv == 1 ? 'jour' : 'jours'}'
          : '${daysToOv == 1 ? 'day' : 'days'}';
    } else if (day >= ovDay - 1 && day <= ovDay + 1) {
      final ovDayNum = day - (ovDay - 1) + 1;
      topLabel = 'Ovulation';
      bigNumber = '$ovDayNum';
      bottomLabel = l10n.isFrench ? 'Fertilité maximale' : 'Peak fertility';
    } else {
      final daysToNext = total - day + 1;
      topLabel = l10n.isFrench ? 'Règles dans' : 'Period in';
      bigNumber = '$daysToNext';
      bottomLabel = l10n.isFrench
          ? '${daysToNext == 1 ? 'jour' : 'jours'}'
          : '${daysToNext == 1 ? 'day' : 'days'}';
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(topLabel, style: GoogleFonts.inter(
          fontSize: 13, color: mutedColor,
          fontWeight: FontWeight.w600, letterSpacing: 0.3)),
        const SizedBox(height: 2),
        Text(bigNumber, style: GoogleFonts.outfit(
          fontSize: 52, fontWeight: FontWeight.w800,
          color: textColor, height: 1.0)),
        const SizedBox(height: 2),
        Text(bottomLabel, style: GoogleFonts.inter(
          fontSize: 13, color: mutedColor, fontWeight: FontWeight.w500)),
      ],
    );
  }
}

class _DottedCirclePainter extends CustomPainter {
  final Color color;
  const _DottedCirclePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = (size.width / 2) - 1;
    const dotCount = 16;
    const dotRadius = 1.4;
    final paint = Paint()..color = color;
    for (int i = 0; i < dotCount; i++) {
      final angle = (i / dotCount) * 2 * pi - pi / 2;
      canvas.drawCircle(
        Offset(cx + r * cos(angle), cy + r * sin(angle)),
        dotRadius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _DottedCirclePainter old) => old.color != color;
}

class _RingPainter extends CustomPainter {
  final int day, total;
  final List<Color> colors;
  final Color primary;
  final Color accent;
  final bool isDark;

  const _RingPainter({
    required this.day, required this.total,
    required this.colors, required this.primary,
    required this.accent,
    this.isDark = false,
  });

  static const _periodColor = Color(0xFFE88B8B);
  static const _ovulationColor = Color(0xFFE8AD6E);

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r  = (size.width / 2) - 20;
    const stroke = 18.0;
    const gap = 0.04;
    final rect = Rect.fromCircle(center: Offset(cx, cy), radius: r);
    final grayBg = isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.06);

    final phases = phasesForCycleDays(total, accent: accent);

    // Background: full gray ring
    canvas.drawArc(rect, -pi / 2, 2 * pi, false, Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..color = grayBg);

    // Background arcs — only period + ovulation visible
    for (final phase in phases) {
      if (phase.days.isEmpty) continue;
      final isPeriod = phase.name == 'Règles';
      final isOvulation = phase.name == 'Ovulation';
      if (!isPeriod && !isOvulation) continue;

      final startDay = phase.days.first;
      final endDay = phase.days.last;
      final startAngle = -pi / 2 + ((startDay - 1) / total) * 2 * pi + gap / 2;
      final sweepAngle = ((endDay - startDay + 1) / total) * 2 * pi - gap;
      final color = isPeriod ? _periodColor : _ovulationColor;

      canvas.drawArc(rect, startAngle, sweepAngle, false, Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..color = color.withOpacity(0.20));
    }

    // Progress arcs — only period + ovulation filled
    for (final phase in phases) {
      if (phase.days.isEmpty) continue;
      final isPeriod = phase.name == 'Règles';
      final isOvulation = phase.name == 'Ovulation';
      if (!isPeriod && !isOvulation) continue;

      final startDay = phase.days.first;
      final endDay = phase.days.last;
      if (day < startDay) continue;

      final isCurrent = day >= startDay && day <= endDay;
      final clampedEnd = day < endDay ? day : endDay;
      final startAngle = -pi / 2 + ((startDay - 1) / total) * 2 * pi + gap / 2;
      final sweepAngle = ((clampedEnd - startDay + 1) / total) * 2 * pi - gap;
      final color = isPeriod ? _periodColor : _ovulationColor;

      if (isCurrent) {
        canvas.drawArc(rect, startAngle, sweepAngle.clamp(0.01, 2 * pi), false, Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke + 12
          ..strokeCap = StrokeCap.round
          ..color = color.withOpacity(0.18)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8));
      }

      canvas.drawArc(rect, startAngle, sweepAngle.clamp(0.01, 2 * pi), false, Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke + 4
        ..strokeCap = StrokeCap.round
        ..color = color.withOpacity(0.12)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3));

      canvas.drawArc(rect, startAngle, sweepAngle.clamp(0.01, 2 * pi), false, Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..color = color);
    }

    // Progress arc for non-highlighted phases (gray fill to show progress)
    for (final phase in phases) {
      if (phase.days.isEmpty) continue;
      final isPeriod = phase.name == 'Règles';
      final isOvulation = phase.name == 'Ovulation';
      if (isPeriod || isOvulation) continue;

      final startDay = phase.days.first;
      final endDay = phase.days.last;
      if (day < startDay) continue;

      final clampedEnd = day < endDay ? day : endDay;
      final startAngle = -pi / 2 + ((startDay - 1) / total) * 2 * pi + gap / 2;
      final sweepAngle = ((clampedEnd - startDay + 1) / total) * 2 * pi - gap;
      final grayFill = isDark ? Colors.white.withOpacity(0.18) : Colors.black.withOpacity(0.12);

      canvas.drawArc(rect, startAngle, sweepAngle.clamp(0.01, 2 * pi), false, Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..color = grayFill);
    }

    // Position indicator
    final progress = (day / total).clamp(0.0, 1.0);
    final angle = -pi / 2 + progress * 2 * pi;
    final dotX = cx + r * cos(angle);
    final dotY = cy + r * sin(angle);
    final dotPos = Offset(dotX, dotY);

    canvas.drawCircle(dotPos, 16, Paint()
      ..color = primary.withOpacity(0.30)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8));
    canvas.drawCircle(dotPos, 12, Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill);
    canvas.drawCircle(dotPos, 12, Paint()
      ..color = Colors.black.withOpacity(0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5);
    canvas.drawCircle(dotPos, 8, Paint()..color = primary);
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) =>
      old.day != day || old.total != total || old.isDark != isDark;
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
//  PHASE TIPS & INFO CARD (combined)
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
  late final _autoTimer = _startAutoSwipe();

  Timer _startAutoSwipe() {
    return Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted || !_pageCtrl.hasClients) return;
      final next = (_current + 1) % 3;
      _pageCtrl.animateToPage(next,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut);
    });
  }

  @override
  void initState() {
    super.initState();
    _pageCtrl = PageController(viewportFraction: 0.88);
  }

  @override
  void dispose() {
    _autoTimer.cancel();
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
            final active = _current == i;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 6),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                  colors: active
                      ? [
                          widget.theme.primary.withOpacity(widget.cc.isDark ? 0.20 : 0.12),
                          widget.theme.primary.withOpacity(widget.cc.isDark ? 0.08 : 0.04),
                        ]
                      : [
                          widget.cc.surface,
                          widget.cc.surface,
                        ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: active
                      ? widget.theme.primary.withOpacity(0.35)
                      : widget.cc.border),
                boxShadow: active ? [BoxShadow(
                  color: widget.theme.primary.withOpacity(0.12),
                  blurRadius: 10, offset: const Offset(0, 3),
                )] : null,
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Container(
                    width: 38, height: 38,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft, end: Alignment.bottomRight,
                        colors: [
                          widget.theme.primary.withOpacity(0.22),
                          widget.theme.primary.withOpacity(0.08),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(11)),
                    child: Icon(_tipIcons[i], size: 18, color: widget.theme.primary),
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

// ─────────────────────────────────────────────────────────────────────────────
//  ACTION BUTTON — Flo-style circular action
// ─────────────────────────────────────────────────────────────────────────────

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final CycleColors cc;
  final VoidCallback onTap;

  const _ActionBtn({
    required this.icon, required this.label, required this.color,
    required this.cc, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 56, height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withOpacity(cc.isDark ? 0.14 : 0.10),
            border: Border.all(color: color.withOpacity(0.20)),
          ),
          child: Icon(icon, size: 24, color: color),
        ),
        const SizedBox(height: 8),
        Text(label, style: GoogleFonts.inter(
          fontSize: 11, fontWeight: FontWeight.w500, color: cc.muted, height: 1.3),
          textAlign: TextAlign.center),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  INFO PILLS — compact period + ovulation info
// ─────────────────────────────────────────────────────────────────────────────

class _InfoPillsRow extends StatelessWidget {
  final int currentDay, cycleDays;
  final DateTime? nextPeriod, ovulationDate;
  final CycleTheme theme;
  final CycleColors cc;
  final AppL10n l10n;

  const _InfoPillsRow({
    required this.currentDay, required this.cycleDays,
    required this.nextPeriod, required this.ovulationDate,
    required this.theme, required this.cc, required this.l10n,
  });

  static const _months = ['jan','fev','mar','avr','mai','juin','juil','aout','sep','oct','nov','dec'];
  static const _pink = Color(0xFFE88B8B);

  @override
  Widget build(BuildContext context) {
    final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

    String periodText = '--';
    String periodSub = '';
    if (nextPeriod != null) {
      final d = nextPeriod!.difference(today).inDays;
      periodText = d == 0 ? (l10n.isFrench ? 'Aujourd\'hui' : 'Today')
          : d < 0 ? '${l10n.isFrench ? 'Retard' : 'Late'} ${-d}j'
          : '${nextPeriod!.day} ${_months[nextPeriod!.month - 1]}';
      if (d > 0) periodSub = '${l10n.isFrench ? 'dans' : 'in'} $d j';
    }

    String ovText = '--';
    final ovDay = (cycleDays - 14).clamp(1, cycleDays);
    if (ovulationDate != null) {
      final d = ovulationDate!.difference(today).inDays;
      ovText = d == 0 ? (l10n.isFrench ? 'Aujourd\'hui' : 'Today')
          : d < 0 ? (l10n.isFrench ? 'Passee' : 'Passed')
          : '${ovulationDate!.day} ${_months[ovulationDate!.month - 1]}';
    }

    return Row(children: [
      Expanded(child: _InfoPill(
        icon: Icons.water_drop_outlined,
        color: _pink,
        label: l10n.isFrench ? 'Prochaines règles' : 'Next period',
        value: periodText,
        sub: periodSub,
        cc: cc,
      )),
      const SizedBox(width: 8),
      Expanded(child: _InfoPill(
        icon: Icons.spa_outlined,
        color: const Color(0xFFE8AD6E),
        label: l10n.isFrench ? 'Ovulation prévue' : 'Expected ovulation',
        value: ovText,
        sub: l10n.isFrench ? 'Jour $ovDay' : 'Day $ovDay',
        cc: cc,
      )),
      const SizedBox(width: 8),
      Expanded(child: _InfoPill(
        icon: Icons.loop_rounded,
        color: const Color(0xFF7EB6E6),
        label: l10n.isFrench ? 'Jour du cycle' : 'Cycle day',
        value: 'J$currentDay',
        sub: l10n.isFrench ? 'sur $cycleDays' : 'of $cycleDays',
        cc: cc,
      )),
    ]);
  }
}

class _InfoPill extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label, value;
  final String sub;
  final CycleColors cc;

  const _InfoPill({
    required this.icon, required this.color,
    required this.label, required this.value,
    this.sub = '', required this.cc,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(children: [
            Container(
              width: 22, height: 22,
              decoration: BoxDecoration(
                color: color.withOpacity(cc.isDark ? 0.20 : 0.12),
                borderRadius: BorderRadius.circular(6)),
              child: Icon(icon, size: 12, color: color),
            ),
            const SizedBox(width: 6),
            Expanded(child: Text(label, style: GoogleFonts.inter(
              fontSize: 10, fontWeight: FontWeight.w600,
              color: cc.muted),
              maxLines: 2, overflow: TextOverflow.ellipsis)),
          ]),
          const SizedBox(height: 8),
          Text(value, style: GoogleFonts.outfit(
            fontSize: 17, fontWeight: FontWeight.w700, color: cc.text),
            maxLines: 1, overflow: TextOverflow.ellipsis),
          if (sub.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 3),
              child: Text(sub, style: GoogleFonts.inter(
                fontSize: 11, fontWeight: FontWeight.w500, color: color)),
            ),
        ],
      ),
    );
  }
}

class _CycleEntry {
  final String label, sub;
  final int days;
  final bool isCurrent;
  const _CycleEntry({required this.label, required this.sub, required this.days, this.isCurrent = false});
}
