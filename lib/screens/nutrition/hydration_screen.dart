// ignore_for_file: deprecated_member_use
import 'dart:math';
import 'package:fiteva/core/nutrition/nutrition_provider.dart';
import 'package:fiteva/services/trends_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

const _kWaterBlue = Color(0xFF378ADD);
const _kWaterBlueBg = Color(0xFFEBF5FF);
const _kStep = 250;

class HydrationScreen extends ConsumerStatefulWidget {
  const HydrationScreen({super.key});

  @override
  ConsumerState<HydrationScreen> createState() => _HydrationScreenState();
}

class _HydrationScreenState extends ConsumerState<HydrationScreen> {
  List<DayPoint> _history = [];
  bool _loadingHistory = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final data = await TrendsService.waterByDay(days: 7);
    if (mounted) setState(() { _history = data; _loadingHistory = false; });
  }

  @override
  Widget build(BuildContext context) {
    final d = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;
    final currentMl = ref.watch(waterProvider);
    final goalMl = ref.watch(userProfileProvider).waterGoalMl;
    final notifier = ref.read(nutritionProvider.notifier);

    final pct = goalMl > 0 ? (currentMl / goalMl).clamp(0.0, 1.0) : 0.0;
    final glasses = (currentMl / _kStep).floor();
    final goalGlasses = (goalMl / _kStep).ceil();

    final bg = d ? const Color(0xFF0F1A14) : const Color(0xFFF7F8F6);
    final surf = d ? const Color(0xFF162119) : Colors.white;
    final bdr = d ? const Color(0xFF253D2E) : const Color(0xFFE8ECE9);
    final ink = d ? const Color(0xFFF0F0EE) : const Color(0xFF1A1A1A);
    final muted = d ? const Color(0xFF8A9B92) : const Color(0xFF6B7B73);

    return Scaffold(
      backgroundColor: bg,
      body: CustomScrollView(
        slivers: [
          // ── Top bar
          SliverToBoxAdapter(
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: Row(children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: surf, shape: BoxShape.circle,
                        border: Border.all(color: bdr, width: 0.5)),
                      child: Icon(LucideIcons.arrowLeft, size: 18, color: ink)),
                  ),
                  const Spacer(),
                  Text('Hydratation',
                    style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700,
                      color: ink, letterSpacing: -0.3)),
                  const Spacer(),
                  const SizedBox(width: 40),
                ]),
              ),
            ),
          ),

          // ── Circular progress
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: surf,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: bdr, width: 0.5),
                  boxShadow: [BoxShadow(
                    color: Colors.black.withOpacity(d ? 0.18 : 0.04),
                    blurRadius: 16, offset: const Offset(0, 4))],
                ),
                child: Column(children: [
                  SizedBox(
                    width: 180, height: 180,
                    child: Stack(alignment: Alignment.center, children: [
                      SizedBox(
                        width: 180, height: 180,
                        child: CustomPaint(
                          painter: _RingPainter(
                            progress: pct,
                            trackColor: d ? bdr : _kWaterBlueBg,
                            progressColor: _kWaterBlue,
                          ),
                        ),
                      ),
                      Column(mainAxisSize: MainAxisSize.min, children: [
                        Icon(LucideIcons.droplets, size: 28,
                          color: _kWaterBlue.withOpacity(0.7)),
                        const SizedBox(height: 6),
                        Text('${(currentMl / 1000).toStringAsFixed(1)} L',
                          style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.w800,
                            color: _kWaterBlue)),
                        Text('/ ${(goalMl / 1000).toStringAsFixed(1)} L',
                          style: GoogleFonts.inter(fontSize: 13, color: muted)),
                      ]),
                    ]),
                  ),

                  const SizedBox(height: 20),

                  // Status text
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: (pct >= 0.8 ? cs.primary : _kWaterBlue).withOpacity(0.08),
                      borderRadius: BorderRadius.circular(20)),
                    child: Text(
                      pct >= 1.0 ? 'Objectif atteint !' :
                      pct >= 0.8 ? 'Presque ! Continue.' :
                      pct >= 0.5 ? 'Bon début, continue !' :
                      'Pense à boire plus d\'eau',
                      style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600,
                        color: pct >= 0.8 ? cs.primary : _kWaterBlue)),
                  ),

                  const SizedBox(height: 20),

                  // +/- buttons
                  Row(children: [
                    Expanded(child: _ActionButton(
                      label: '-${_kStep} ml',
                      icon: LucideIcons.minus,
                      onTap: currentMl >= _kStep ? () {
                        HapticFeedback.selectionClick();
                        notifier.addWater(-_kStep);
                      } : null,
                      d: d, bdr: bdr, muted: muted, ink: ink,
                    )),
                    const SizedBox(width: 12),
                    Expanded(child: _ActionButton(
                      label: '+${_kStep} ml',
                      icon: LucideIcons.plus,
                      onTap: () {
                        HapticFeedback.mediumImpact();
                        notifier.addWater(_kStep);
                        _loadHistory();
                      },
                      isPrimary: true,
                      d: d, bdr: bdr, muted: muted, ink: ink,
                    )),
                  ]),
                ]),
              ),
            ),
          ),

          // ── Glasses grid
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: surf,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: bdr, width: 0.5),
                  boxShadow: [BoxShadow(
                    color: Colors.black.withOpacity(d ? 0.18 : 0.04),
                    blurRadius: 12, offset: const Offset(0, 3))],
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Icon(LucideIcons.glassWater, size: 15, color: _kWaterBlue),
                    const SizedBox(width: 8),
                    Text('$glasses / $goalGlasses verres',
                      style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w700, color: ink)),
                    const Spacer(),
                    Text('${_kStep} ml / verre',
                      style: GoogleFonts.inter(fontSize: 11, color: muted)),
                  ]),
                  const SizedBox(height: 14),
                  Wrap(spacing: 8, runSpacing: 8,
                    children: List.generate(goalGlasses, (i) {
                      final filled = i < glasses;
                      return GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          final newMl = filled
                              ? (i * _kStep).clamp(0, goalMl)
                              : ((i + 1) * _kStep).clamp(0, goalMl);
                          notifier.setWater(newMl);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          width: 38, height: 42,
                          decoration: BoxDecoration(
                            color: filled ? _kWaterBlueBg : (d ? const Color(0xFF1A2A20) : const Color(0xFFF4F4F4)),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: filled ? _kWaterBlue : bdr,
                              width: filled ? 1.5 : 1)),
                          child: Icon(LucideIcons.glassWater,
                            size: 17,
                            color: filled ? _kWaterBlue : muted.withOpacity(0.5)),
                        ),
                      );
                    }),
                  ),
                ]),
              ),
            ),
          ),

          // ── 7-day history
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: surf,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: bdr, width: 0.5),
                  boxShadow: [BoxShadow(
                    color: Colors.black.withOpacity(d ? 0.18 : 0.04),
                    blurRadius: 12, offset: const Offset(0, 3))],
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Icon(LucideIcons.barChart3, size: 15, color: _kWaterBlue),
                    const SizedBox(width: 8),
                    Text('7 derniers jours',
                      style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w700, color: ink)),
                  ]),
                  const SizedBox(height: 16),
                  _loadingHistory
                    ? const Center(child: Padding(
                        padding: EdgeInsets.all(20),
                        child: CircularProgressIndicator(strokeWidth: 2)))
                    : SizedBox(
                        height: 140,
                        child: _WaterBarChart(
                          points: _history,
                          goalMl: goalMl,
                          d: d,
                          ink: ink,
                          muted: muted,
                          bdr: bdr,
                        ),
                      ),
                ]),
              ),
            ),
          ),

          // ── Tips card
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _kWaterBlue.withOpacity(d ? 0.08 : 0.06),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _kWaterBlue.withOpacity(0.15))),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Icon(LucideIcons.lightbulb, size: 16, color: _kWaterBlue),
                  const SizedBox(width: 12),
                  Expanded(child: Text(
                    'Ton objectif est basé sur ton poids (35 ml/kg). '
                    'Bois régulièrement tout au long de la journée pour rester bien hydratée.',
                    style: GoogleFonts.inter(fontSize: 12, color: muted, height: 1.5))),
                ]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onTap;
  final bool isPrimary;
  final bool d;
  final Color bdr, muted, ink;

  const _ActionButton({
    required this.label,
    required this.icon,
    this.onTap,
    this.isPrimary = false,
    required this.d,
    required this.bdr,
    required this.muted,
    required this.ink,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isPrimary
            ? _kWaterBlue
            : (d ? const Color(0xFF1A2A20) : const Color(0xFFF4F4F4)),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isPrimary ? _kWaterBlue : bdr, width: 0.5)),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, size: 16,
            color: isPrimary ? Colors.white : (enabled ? ink : muted.withOpacity(0.4))),
          const SizedBox(width: 8),
          Text(label,
            style: GoogleFonts.inter(
              fontSize: 14, fontWeight: FontWeight.w700,
              color: isPrimary ? Colors.white : (enabled ? ink : muted.withOpacity(0.4)))),
        ]),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color trackColor;
  final Color progressColor;

  _RingPainter({required this.progress, required this.trackColor, required this.progressColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;
    const strokeWidth = 12.0;

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    final sweepAngle = 2 * pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) =>
      old.progress != progress || old.trackColor != trackColor;
}

class _WaterBarChart extends StatelessWidget {
  final List<DayPoint> points;
  final int goalMl;
  final bool d;
  final Color ink, muted, bdr;

  const _WaterBarChart({
    required this.points,
    required this.goalMl,
    required this.d,
    required this.ink,
    required this.muted,
    required this.bdr,
  });

  static const _dayLabels = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) {
      return Center(child: Text('Pas encore de données',
        style: GoogleFonts.inter(fontSize: 13, color: muted)));
    }

    final maxVal = points.fold<double>(goalMl.toDouble(),
      (prev, p) => p.value > prev ? p.value : prev);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: points.map((p) {
        final ratio = maxVal > 0 ? (p.value / maxVal).clamp(0.0, 1.0) : 0.0;
        final isToday = _isToday(p.date);
        final reachedGoal = p.value >= goalMl;

        return Expanded(child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3),
          child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
            Text('${(p.value / 1000).toStringAsFixed(1)}',
              style: GoogleFonts.inter(
                fontSize: 9, fontWeight: FontWeight.w600,
                color: isToday ? _kWaterBlue : muted)),
            const SizedBox(height: 4),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: (ratio * 80).clamp(4.0, 80.0),
              decoration: BoxDecoration(
                color: reachedGoal
                  ? _kWaterBlue
                  : (isToday ? _kWaterBlue.withOpacity(0.7) : _kWaterBlue.withOpacity(0.3)),
                borderRadius: BorderRadius.circular(6)),
            ),
            const SizedBox(height: 6),
            Text(_dayLabels[p.date.weekday - 1],
              style: GoogleFonts.inter(
                fontSize: 10, fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
                color: isToday ? ink : muted)),
          ]),
        ));
      }).toList(),
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }
}
