// ignore_for_file: deprecated_member_use
import 'dart:ui';
import 'package:fiteva/l10n/app_localizations.dart';
import 'package:fiteva/providers/user_profile_provider.dart';
import 'package:fiteva/screens/cycle/cycle_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class CycleHistoryScreen extends ConsumerWidget {
  const CycleHistoryScreen({super.key});

  static Color _screenBg(bool isDark) =>
      isDark ? const Color(0xFF111114) : const Color.fromARGB(255, 255, 255, 255);

  static Widget _glassCard({required Widget child, required bool isDark, double radius = 18}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withOpacity(0.07) : Colors.white.withOpacity(0.55),
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: isDark ? Colors.white.withOpacity(0.10) : Colors.white.withOpacity(0.80)),
          ),
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cc = CycleColors.of(context);
    final l10n = ref.watch(l10nProvider);
    final profile = ref.watch(userProfileProvider);
    final lp = profile.lastPeriod;

    return Scaffold(
      backgroundColor: _screenBg(cc.isDark),
      body: SafeArea(
        child: Column(children: [
          _buildHeader(context, cc, l10n),
          Expanded(
            child: lp == null
                ? Center(child: Text(
                    l10n.isFrench ? 'Aucune donnée de cycle' : 'No cycle data',
                    style: GoogleFonts.inter(fontSize: 14, color: cc.muted)))
                : ListView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                    children: _buildCycleCards(cc, l10n, profile),
                  ),
          ),
        ]),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, CycleColors cc, AppL10n l10n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
      child: Row(children: [
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(Icons.arrow_back_rounded, color: cc.text),
        ),
        const SizedBox(width: 4),
        Text(
          l10n.isFrench ? 'Historique du cycle' : 'Cycle history',
          style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w700, color: cc.text),
        ),
      ]),
    );
  }

  List<Widget> _buildCycleCards(CycleColors cc, AppL10n l10n, UserProfile profile) {
    final cycleDays = profile.cycleDays;
    const periodDuration = 5;
    final today = DateTime.now();
    final todayNorm = DateTime(today.year, today.month, today.day);
    final lp = profile.lastPeriod!;
    final lpNorm = DateTime(lp.year, lp.month, lp.day);
    final currentLen = todayNorm.difference(lpNorm).inDays + 1;

    final months = l10n.isFrench
        ? ['jan','fév','mar','avr','mai','juin','juil','août','sep','oct','nov','déc']
        : ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    String fmtFull(DateTime d) => '${d.day} ${months[d.month - 1]} ${d.year}';

    final cards = <Widget>[];

    // Current cycle
    final currentPeriodEnd = lpNorm.add(Duration(days: periodDuration - 1));
    final currentPeriodDone = todayNorm.isAfter(currentPeriodEnd);
    cards.add(_buildCard(
      cc: cc,
      l10n: l10n,
      isCurrent: true,
      periodStart: lpNorm,
      periodEnd: currentPeriodDone ? currentPeriodEnd : todayNorm,
      periodDuration: currentPeriodDone ? periodDuration : todayNorm.difference(lpNorm).inDays + 1,
      cycleDuration: currentLen,
      fmt: fmtFull,
    ));

    // Past cycles
    var cursor = lpNorm;
    for (int i = 0; i < 6; i++) {
      final cycleEnd = cursor.subtract(const Duration(days: 1));
      final cycleStart = cycleEnd.subtract(Duration(days: cycleDays - 1));
      final pEnd = cycleStart.add(Duration(days: periodDuration - 1));
      cards.add(_buildCard(
        cc: cc,
        l10n: l10n,
        isCurrent: false,
        periodStart: cycleStart,
        periodEnd: pEnd,
        periodDuration: periodDuration,
        cycleDuration: cycleDays,
        fmt: fmtFull,
      ));
      cursor = cycleStart;
    }

    return cards;
  }

  static const _periodColor = Color(0xFFE88B8B);

  Widget _buildCard({
    required CycleColors cc,
    required AppL10n l10n,
    required bool isCurrent,
    required DateTime periodStart,
    required DateTime periodEnd,
    required int periodDuration,
    required int cycleDuration,
    required String Function(DateTime) fmt,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: _glassCard(
        isDark: cc.isDark,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Header row
            Row(children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: _periodColor.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.water_drop_rounded, size: 16, color: _periodColor),
              ),
              const SizedBox(width: 10),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.isFrench ? 'Règles' : 'Period',
                    style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w700, color: cc.text)),
                  Text(
                    l10n.isFrench
                        ? 'Cycle de $cycleDuration jours'
                        : '$cycleDuration day cycle',
                    style: GoogleFonts.inter(fontSize: 11, color: cc.muted)),
                ],
              )),
              if (isCurrent)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _periodColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    l10n.isFrench ? 'En cours' : 'Active',
                    style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: _periodColor),
                  ),
                ),
            ]),
            const SizedBox(height: 14),

            // Period details
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: cc.isDark ? Colors.white.withOpacity(0.04) : Colors.black.withOpacity(0.03),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(children: [
                Expanded(child: _detailItem(
                  cc: cc,
                  l10n: l10n,
                  icon: Icons.play_arrow_rounded,
                  label: l10n.isFrench ? 'Début' : 'Start',
                  value: fmt(periodStart),
                )),
                Container(width: 1, height: 32, color: cc.isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.06)),
                Expanded(child: _detailItem(
                  cc: cc,
                  l10n: l10n,
                  icon: Icons.stop_rounded,
                  label: l10n.isFrench ? 'Fin' : 'End',
                  value: fmt(periodEnd),
                )),
                Container(width: 1, height: 32, color: cc.isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.06)),
                Expanded(child: _detailItem(
                  cc: cc,
                  l10n: l10n,
                  icon: Icons.timelapse_rounded,
                  label: l10n.isFrench ? 'Durée' : 'Duration',
                  value: '$periodDuration ${l10n.isFrench ? 'jours' : 'days'}',
                )),
              ]),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _detailItem({
    required CycleColors cc,
    required AppL10n l10n,
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(children: [
      Icon(icon, size: 16, color: _periodColor),
      const SizedBox(height: 4),
      Text(label, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: cc.muted)),
      const SizedBox(height: 2),
      Text(value, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: cc.text),
        textAlign: TextAlign.center),
    ]);
  }
}
