// ─────────────────────────────────────────────
// symptoms_home_screen.dart
// ─────────────────────────────────────────────

import 'dart:math' as math;
import 'package:fiteva/screens/cycle/pregnancy/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'symptom_entry.dart';
import 'symptom_insight_engine.dart';
import 'symptom_insight_card.dart';
import 'add_symptom_sheet.dart';

// ── Minimal ThreadTheme shim — replace with your own ─────────────────────────


// ── Main screen ───────────────────────────────────────────────────────────────

class SymptomsHomeScreen extends StatefulWidget {
  const SymptomsHomeScreen({super.key, required this.currentWeek});

  final int currentWeek;

  @override
  State<SymptomsHomeScreen> createState() => _SymptomsHomeScreenState();
}

class _SymptomsHomeScreenState extends State<SymptomsHomeScreen> {
  final List<SymptomEntry> _entries = [];

  Color get _accent => ThreadTheme.threadColorForWeek(widget.currentWeek);

  List<SymptomEntry> get _weekEntries {
    final now = DateTime.now();
    final start = now.subtract(const Duration(days: 6));
    return _entries
        .where((e) =>
            e.date.isAfter(start.subtract(const Duration(days: 1))) &&
            e.date.isBefore(now.add(const Duration(days: 1))))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  @override
  Widget build(BuildContext context) {
    final SymptomInsight insight = SymptomInsightEngine.generate(
      week: widget.currentWeek,
      symptoms: _weekEntries,
    );

    return Scaffold(
      backgroundColor: ThreadTheme.bg,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── App bar ──────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 130,
            pinned: true,
            backgroundColor: ThreadTheme.bg,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded,
                  size: 18, color: _accent),
              onPressed: () => Navigator.of(context).pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: Padding(
                padding: const EdgeInsets.fromLTRB(20, 60, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: _accent.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Week ${widget.currentWeek}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: _accent,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Symptoms',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: ThreadTheme.textPrimary,
                        letterSpacing: -0.6,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── AI Insight card ───────────────────────────────────────────
          SliverToBoxAdapter(
            key: ValueKey(_weekEntries.length), // re-animate on new entry
            child: SymptomInsightCard(
              insight: insight,
              accentColor: _accent,
            ),
          ),

          // ── Weekly trend mini-chart ───────────────────────────────────
          if (_weekEntries.isNotEmpty)
            SliverToBoxAdapter(
              child: _WeeklyTrendChart(
                entries: _weekEntries,
                accent: _accent,
              ),
            ),

          // ── Section header ────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                children: [
                  Text(
                    'THIS WEEK',
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.6,
                      color: _accent.withOpacity(0.7),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${_weekEntries.length} entries',
                    style: const TextStyle(
                      fontSize: 11,
                      color: ThreadTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Timeline list ─────────────────────────────────────────────
          _weekEntries.isEmpty
              ? SliverToBoxAdapter(child: _EmptyState(accent: _accent))
              : SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) => _SymptomTile(
                      entry: _weekEntries[i],
                      accent: _accent,
                      onDelete: () => setState(
                        () => _entries.removeWhere(
                            (e) => e.id == _weekEntries[i].id),
                      ),
                    ),
                    childCount: _weekEntries.length,
                  ),
                ),

          // Extra space so last tile clears FAB + nav bar + home indicator
          const SliverToBoxAdapter(child: SizedBox(height: 140)),
        ],
      ),

      // ── FAB — floats above nav bar automatically ──────────────────────
      floatingActionButton: Padding(
        // Lifts the FAB above whatever bottom chrome exists
        // (nav bar, home indicator, etc.) without hardcoding a value.
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).padding.bottom + 16,
        ),
        child: _LogFAB(
          accent: _accent,
          onTap: () => AddSymptomSheet.show(
            context: context,
            accentColor: _accent,
            onSave: (entry) => setState(() => _entries.add(entry)),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

// ── Weekly trend mini-chart ───────────────────────────────────────────────────

class _WeeklyTrendChart extends StatelessWidget {
  const _WeeklyTrendChart({
    required this.entries,
    required this.accent,
  });

  final List<SymptomEntry> entries;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    // Build daily average intensity for the last 7 days
    final now = DateTime.now();
    final List<double> daily = List.generate(7, (i) {
      final day = now.subtract(Duration(days: 6 - i));
      final dayEntries = entries.where((e) =>
          e.date.year == day.year &&
          e.date.month == day.month &&
          e.date.day == day.day);
      if (dayEntries.isEmpty) return 0;
      return dayEntries.fold(0.0, (s, e) => s + e.intensity) /
          dayEntries.length;
    });

    const List<String> dayLabels = ['6d', '5d', '4d', '3d', '2d', 'Yst', 'Tod'];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: BoxDecoration(
        color: ThreadTheme.bgCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: ThreadTheme.bgCardBorder, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.show_chart_rounded, size: 14, color: accent),
              const SizedBox(width: 6),
              Text(
                'WEEKLY TREND',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.4,
                  color: accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 60,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (i) {
                final pct = daily[i] / 5;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Bar
                        AnimatedContainer(
                          duration: Duration(milliseconds: 400 + i * 50),
                          curve: Curves.easeOutCubic,
                          height: pct == 0 ? 3 : 48 * pct,
                          decoration: BoxDecoration(
                            color: pct == 0
                                ? accent.withOpacity(0.12)
                                : accent.withOpacity(0.2 + pct * 0.6),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          dayLabels[i],
                          style: const TextStyle(
                            fontSize: 8.5,
                            color: ThreadTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Symptom timeline tile ─────────────────────────────────────────────────────

class _SymptomTile extends StatelessWidget {
  const _SymptomTile({
    required this.entry,
    required this.accent,
    required this.onDelete,
  });

  final SymptomEntry entry;
  final Color accent;
  final VoidCallback onDelete;

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    final int intensity = entry.intensity;
    final Color typeColor = entry.type.baseColor;

    return Dismissible(
      key: Key(entry.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        color: const Color(0xFFF5F0EA),
        child: const Icon(Icons.delete_outline_rounded,
            color: Color(0xFFB97A8A), size: 22),
      ),
      onDismissed: (_) => onDelete(),
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: ThreadTheme.bgCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: ThreadTheme.bgCardBorder, width: 1),
        ),
        child: Row(
          children: [
            // Emoji container
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: typeColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Center(
                child: Text(
                  entry.type.emoji,
                  style: const TextStyle(fontSize: 20),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Label + note
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        entry.type.label,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: ThreadTheme.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        _timeAgo(entry.date),
                        style: const TextStyle(
                          fontSize: 11,
                          color: ThreadTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Intensity dots
                  Row(
                    children: List.generate(5, (i) {
                      return Container(
                        width: 7,
                        height: 7,
                        margin: const EdgeInsets.only(right: 4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: i < intensity
                              ? typeColor
                              : typeColor.withOpacity(0.18),
                        ),
                      );
                    }),
                  ),
                  if (entry.note != null) ...[
                    const SizedBox(height: 5),
                    Text(
                      entry.note!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: ThreadTheme.textSecondary,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.accent});
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(40, 20, 40, 40),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: accent.withOpacity(0.08),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text('🌿', style: const TextStyle(fontSize: 28)),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Nothing logged yet',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: ThreadTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tap the button below to log how you\'re feeling today.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              height: 1.55,
              color: ThreadTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ── FAB ───────────────────────────────────────────────────────────────────────

class _LogFAB extends StatelessWidget {
  const _LogFAB({required this.accent, required this.onTap});
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 28),
        decoration: BoxDecoration(
          color: accent,
          borderRadius: BorderRadius.circular(26),
          boxShadow: [
            BoxShadow(
              color: accent.withOpacity(0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.add_rounded, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text(
              'Log Symptom',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 15,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}