import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fiteva/providers/user_profile_provider.dart';
import 'package:fiteva/l10n/app_localizations.dart';
import 'package:fiteva/services/cycle_log_service.dart';
import 'package:fiteva/widgets/shared_app_header.dart';
import 'package:fiteva/screens/cycle/cycle_colors.dart';
import 'package:fiteva/screens/cycle/widgets-cycle/cycle_wheel.dart' hide CycleColors;

/// Dashboard "Insights" — analyse des logs de cycle_daily_logs :
/// fréquence des symptômes, corrélation humeur/phase, tendances mensuelles.
class CycleInsightsScreen extends ConsumerStatefulWidget {
  const CycleInsightsScreen({super.key});

  @override
  ConsumerState<CycleInsightsScreen> createState() => _CycleInsightsScreenState();
}

class _CycleInsightsScreenState extends ConsumerState<CycleInsightsScreen> {
  static const _green = Color(0xFF1C4D30);

  bool _loading = true;
  List<CycleDailyLog> _logs = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final now  = DateTime.now();
    final from = DateTime(now.year, now.month - 3, now.day);
    final logs = await CycleLogService.loadLogsRange(from, now);
    if (!mounted) return;
    setState(() {
      _logs    = logs;
      _loading = false;
    });
  }

  int _dayInCycle(DateTime date, DateTime lastPeriod, int cycleDays) {
    final diff = date.difference(DateTime(lastPeriod.year, lastPeriod.month, lastPeriod.day)).inDays;
    final mod  = diff % cycleDays;
    return (mod < 0 ? mod + cycleDays : mod) + 1;
  }

  @override
  Widget build(BuildContext context) {
    final cc      = CycleColors.of(context);
    final l10n    = ref.watch(l10nProvider);
    final profile = ref.watch(userProfileProvider);

    return Scaffold(
      backgroundColor: cc.bg,
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: _green))
            : SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SharedAppHeader(
                      eyebrow:     l10n.navCycle.toUpperCase(),
                      title:       l10n.insightsTitle,
                      accentColor: _green,
                      bgColor:     Colors.transparent,
                      onBack: Navigator.canPop(context)
                          ? () => Navigator.of(context).pop()
                          : null,
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
                      child: Text(l10n.insightsSubtitle,
                        style: GoogleFonts.inter(fontSize: 12.5, color: cc.muted)),
                    ),
                    const SizedBox(height: 20),

                    if (_logs.isEmpty)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 40, 20, 40),
                        child: Column(children: [
                          Icon(Icons.insights_rounded, size: 40, color: cc.muted.withOpacity(0.4)),
                          const SizedBox(height: 14),
                          Text(l10n.insightsEmpty, textAlign: TextAlign.center,
                            style: GoogleFonts.inter(fontSize: 13, color: cc.muted, height: 1.5)),
                        ]),
                      )
                    else ...[
                      _SectionCard(
                        cc: cc,
                        title: l10n.insightsSymptomsChart,
                        subtitle: l10n.insightsSymptomsSub,
                        child: _SymptomsChart(logs: _logs, cc: cc, l10n: l10n),
                      ),
                      const SizedBox(height: 16),
                      _SectionCard(
                        cc: cc,
                        title: l10n.insightsMoodCorrelation,
                        subtitle: l10n.insightsMoodSub,
                        child: _MoodCorrelationChart(
                          logs: _logs, cc: cc, l10n: l10n, profile: profile,
                          dayInCycle: _dayInCycle,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _SectionCard(
                        cc: cc,
                        title: l10n.insightsMonthlyTrends,
                        subtitle: l10n.insightsMonthlySub,
                        child: _MonthlyTrendsChart(logs: _logs, cc: cc, l10n: l10n),
                      ),
                    ],

                    const SizedBox(height: 48),
                  ],
                ),
              ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  SECTION CARD
// ─────────────────────────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final CycleColors cc;
  final String title, subtitle;
  final Widget child;

  const _SectionCard({
    required this.cc, required this.title, required this.subtitle, required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: cc.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: cc.border),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: GoogleFonts.outfit(
            fontSize: 15, fontWeight: FontWeight.w700, color: cc.text, letterSpacing: -0.2)),
          const SizedBox(height: 2),
          Text(subtitle, style: GoogleFonts.inter(fontSize: 11.5, color: cc.muted)),
          const SizedBox(height: 18),
          child,
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  1) SYMPTOMS FREQUENCY CHART
// ─────────────────────────────────────────────────────────────────────────────

class _SymptomsChart extends StatelessWidget {
  final List<CycleDailyLog> logs;
  final CycleColors cc;
  final AppL10n l10n;

  static const _green = Color(0xFF1C4D30);

  const _SymptomsChart({required this.logs, required this.cc, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final counts = <String, int>{'flow': 0, 'mood': 0, 'energy': 0, 'cramps': 0};
    for (final log in logs) {
      for (final s in log.symptoms) {
        if (counts.containsKey(s)) counts[s] = counts[s]! + 1;
      }
    }
    final maxCount = counts.values.fold(0, (a, b) => a > b ? a : b).clamp(1, 1 << 30);
    final labels = {
      'flow':    l10n.cycleSymptomFlow,
      'mood':    l10n.cycleSymptomMood,
      'energy':  l10n.cycleSymptomEnergy,
      'cramps':  l10n.cycleSymptomCramps,
    };
    final icons = {
      'flow':    Icons.water_drop_outlined,
      'mood':    Icons.sentiment_satisfied_outlined,
      'energy':  Icons.bolt_outlined,
      'cramps':  Icons.favorite_border_rounded,
    };

    return Column(children: [
      for (final key in const ['flow', 'mood', 'energy', 'cramps'])
        Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Row(children: [
            Icon(icons[key], size: 15, color: cc.muted),
            const SizedBox(width: 8),
            SizedBox(width: 62, child: Text(labels[key]!,
              style: GoogleFonts.inter(fontSize: 12, color: cc.body))),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: counts[key]! / maxCount,
                  minHeight: 8,
                  backgroundColor: cc.isDark ? const Color(0xFF242424) : const Color(0xFFF0EBEC),
                  valueColor: const AlwaysStoppedAnimation(_green),
                ),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(width: 20, child: Text('${counts[key]}',
              textAlign: TextAlign.right,
              style: GoogleFonts.inter(fontSize: 11.5, fontWeight: FontWeight.w700, color: cc.text))),
          ]),
        ),
    ]);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  2) MOOD / CYCLE CORRELATION
// ─────────────────────────────────────────────────────────────────────────────

class _MoodCorrelationChart extends StatelessWidget {
  final List<CycleDailyLog> logs;
  final CycleColors cc;
  final AppL10n l10n;
  final UserProfile profile;
  final int Function(DateTime, DateTime, int) dayInCycle;

  const _MoodCorrelationChart({
    required this.logs, required this.cc, required this.l10n,
    required this.profile, required this.dayInCycle,
  });

  @override
  Widget build(BuildContext context) {
    final lastPeriod = profile.lastPeriod;
    if (lastPeriod == null) {
      return Text(l10n.insightsNoMoodData,
        style: GoogleFonts.inter(fontSize: 12.5, color: cc.muted));
    }

    // phase.name -> (sum, count)
    final sums   = <String, double>{};
    final counts = <String, int>{};
    for (final log in logs) {
      if (log.moodIndex == null) continue;
      final day   = dayInCycle(log.date, lastPeriod, profile.cycleDays);
      final phase = phaseForDay(day, cycleDays: profile.cycleDays);
      sums[phase.name]   = (sums[phase.name] ?? 0) + log.moodIndex!;
      counts[phase.name] = (counts[phase.name] ?? 0) + 1;
    }

    if (counts.isEmpty) {
      return Text(l10n.insightsNoMoodData,
        style: GoogleFonts.inter(fontSize: 12.5, color: cc.muted));
    }

    final phaseColors = {
      'Règles':      const Color(0xFFE58F8A),
      'Folliculaire': const Color(0xFF7ABB98),
      'Ovulation':   const Color(0xFF1C4D30),
      'Lutéale':     const Color(0xFFA7B8AD),
    };

    return Column(children: [
      for (final phase in kPhases)
        if (counts.containsKey(phase.name))
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Row(children: [
              Container(width: 8, height: 8, margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: phaseColors[phase.name], shape: BoxShape.circle)),
              SizedBox(width: 78, child: Text(phase.name,
                style: GoogleFonts.inter(fontSize: 12, color: cc.body))),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    // mood_index 0 (bas) .. 4 (haut) → inversé pour que "haut" = barre longue,
                    // ici on affiche simplement la moyenne normalisée sur 5 niveaux.
                    value: (sums[phase.name]! / counts[phase.name]!) / 4,
                    minHeight: 8,
                    backgroundColor: cc.isDark ? const Color(0xFF242424) : const Color(0xFFF0EBEC),
                    valueColor: AlwaysStoppedAnimation(phaseColors[phase.name]!),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(width: 38, child: Text(
                l10n.insightsMoodLabels[
                  (sums[phase.name]! / counts[phase.name]!).round().clamp(0, 4)],
                textAlign: TextAlign.right,
                style: GoogleFonts.inter(fontSize: 10.5, fontWeight: FontWeight.w600, color: cc.text))),
            ]),
          ),
    ]);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  3) MONTHLY TRENDS
// ─────────────────────────────────────────────────────────────────────────────

class _MonthlyTrendsChart extends StatelessWidget {
  final List<CycleDailyLog> logs;
  final CycleColors cc;
  final AppL10n l10n;

  static const _green = Color(0xFF1C4D30);
  static const _monthsFr = ['jan','fév','mar','avr','mai','juin','juil','août','sep','oct','nov','déc'];
  static const _monthsEn = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];

  const _MonthlyTrendsChart({required this.logs, required this.cc, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    // Les 3 derniers mois, dans l'ordre chronologique
    final months = List.generate(3, (i) => DateTime(now.year, now.month - 2 + i, 1));
    final counts = <String, int>{};
    for (final m in months) {
      counts['${m.year}-${m.month}'] = 0;
    }
    for (final log in logs) {
      final key = '${log.date.year}-${log.date.month}';
      if (counts.containsKey(key)) counts[key] = counts[key]! + 1;
    }
    final maxCount = counts.values.fold(0, (a, b) => a > b ? a : b).clamp(1, 1 << 30);
    final monthLabels = l10n.isFrench ? _monthsFr : _monthsEn;

    return SizedBox(
      height: 130,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          for (final m in months)
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text('${counts['${m.year}-${m.month}']}',
                  style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: cc.text)),
                const SizedBox(height: 6),
                Container(
                  width: 34,
                  height: 70 * (counts['${m.year}-${m.month}']! / maxCount).clamp(0.06, 1.0),
                  decoration: BoxDecoration(
                    color: _green.withOpacity(0.85),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                  ),
                ),
                const SizedBox(height: 8),
                Text(monthLabels[m.month - 1],
                  style: GoogleFonts.inter(fontSize: 10.5, color: cc.muted)),
              ],
            ),
        ],
      ),
    );
  }
}
