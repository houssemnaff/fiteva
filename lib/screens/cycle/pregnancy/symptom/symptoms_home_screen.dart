// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../pregnancy_colors.dart';
import 'symptom_entry.dart';
import 'add_symptom_sheet.dart';

extension _Pg on BuildContext {
  PgColors get _p => PgColors.of(this);
}

// ─────────────────────────────────────────────────────────────────────────────
class SymptomsHomeScreen extends StatefulWidget {
  final int currentWeek;
  const SymptomsHomeScreen({super.key, required this.currentWeek});

  @override
  State<SymptomsHomeScreen> createState() => _SymptomsHomeScreenState();
}

class _SymptomsHomeScreenState extends State<SymptomsHomeScreen> {
  final List<SymptomEntry> _entries = [];

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

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return 'il y a ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'il y a ${diff.inHours}h';
    return 'il y a ${diff.inDays}j';
  }

  @override
  Widget build(BuildContext context) {
    final top    = MediaQuery.of(context).padding.top;
    final bottom = MediaQuery.of(context).padding.bottom;
    final entries = _weekEntries;

    return Scaffold(
      backgroundColor: context._p.bg,
      body: Stack(children: [
        SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(children: [
            // ── HEADER ──────────────────────────────────────────────────
            _Header(
              top: top,
              week: widget.currentWeek,
              count: entries.length,
              onBack: () => Navigator.maybePop(context),
            ),

            const SizedBox(height: 20),

            // ── INSIGHT CARD ─────────────────────────────────────────────
            _InsightBanner(
              week: widget.currentWeek,
              entries: entries,
            ),

            const SizedBox(height: 16),

            // ── WEEKLY TREND ─────────────────────────────────────────────
            if (entries.isNotEmpty) ...[
              _WeeklyChart(entries: entries),
              const SizedBox(height: 16),
            ],

            // ── SECTION LABEL ─────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Row(children: [
                Text('CETTE SEMAINE', style: GoogleFonts.inter(
                  fontSize: 10, fontWeight: FontWeight.w600,
                  color: context._p.textSoft, letterSpacing: 2)),
                const Spacer(),
                Text('${entries.length} entrée${entries.length != 1 ? "s" : ""}',
                  style: GoogleFonts.inter(fontSize: 12, color: context._p.textSoft)),
              ]),
            ),

            // ── LIST ─────────────────────────────────────────────────────
            if (entries.isEmpty)
              _EmptyState()
            else
              ...List.generate(entries.length, (i) => _SymptomTile(
                entry: entries[i],
                timeAgo: _timeAgo(entries[i].date),
                index: i,
                onDelete: () => setState(() =>
                    _entries.removeWhere((e) => e.id == entries[i].id)),
              )),

            SizedBox(height: bottom + 120),
          ]),
        ),

        // ── FAB ──────────────────────────────────────────────────────────
        Positioned(
          bottom: bottom + 24,
          left: 24, right: 24,
          child: _LogFAB(onTap: () => AddSymptomSheet.show(
            context: context,
            onSave: (entry) => setState(() => _entries.add(entry)),
          )),
        ),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  HEADER
// ─────────────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final double top;
  final int week, count;
  final VoidCallback onBack;
  const _Header({required this.top, required this.week,
      required this.count, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: context._p.surface,
      padding: EdgeInsets.fromLTRB(20, top + 12, 20, 20),
      child: Row(children: [
        GestureDetector(
          onTap: onBack,
          child: Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: context._p.mintLight,
              borderRadius: BorderRadius.circular(10)),
            child: Icon(Icons.chevron_left_rounded, size: 22, color: context._p.green),
          ),
        ),
        const SizedBox(width: 14),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('MES SYMPTÔMES', style: GoogleFonts.inter(
            fontSize: 9, fontWeight: FontWeight.w600,
            color: context._p.textSoft, letterSpacing: 2.5)),
          const SizedBox(height: 1),
          Text('Semaine $week', style: GoogleFonts.inter(
            fontSize: 15, fontWeight: FontWeight.w700, color: context._p.textDark)),
        ]),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: context._p.mintLight, borderRadius: BorderRadius.circular(20)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.favorite_outline_rounded, size: 13, color: context._p.green),
            const SizedBox(width: 5),
            Text('$count ce mois', style: GoogleFonts.inter(
              fontSize: 11, fontWeight: FontWeight.w600, color: context._p.green)),
          ]),
        ),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  INSIGHT BANNER
// ─────────────────────────────────────────────────────────────────────────────

class _InsightBanner extends StatelessWidget {
  final int week;
  final List<SymptomEntry> entries;
  const _InsightBanner({required this.week, required this.entries});

  String _insightText() {
    if (week <= 13) {
      return 'Les nausées et la fatigue sont très communes au premier trimestre. Tu n\'es pas seule — ton corps travaille fort pour ton bébé.';
    } else if (week <= 26) {
      return 'Le deuxième trimestre apporte souvent plus d\'énergie. Les douleurs dorsales peuvent apparaître à mesure que ton ventre grandit.';
    } else {
      return 'En fin de grossesse, les insomnies et l\'essoufflement sont normaux. Repose-toi autant que possible et écoute ton corps.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1C4D30), Color(0xFF2E7050)],
            begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [BoxShadow(
            color: Color(0x301C4D30), blurRadius: 20, offset: Offset(0, 6))],
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.auto_awesome_rounded,
                size: 20, color: Colors.white),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Conseil de la semaine', style: GoogleFonts.inter(
                fontSize: 10, fontWeight: FontWeight.w600,
                color: Colors.white70, letterSpacing: 1.2)),
              const SizedBox(height: 6),
              Text(_insightText(), style: GoogleFonts.inter(
                fontSize: 13, color: Colors.white,
                height: 1.55, fontWeight: FontWeight.w400)),
            ],
          )),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  WEEKLY CHART
// ─────────────────────────────────────────────────────────────────────────────

class _WeeklyChart extends StatelessWidget {
  final List<SymptomEntry> entries;
  const _WeeklyChart({required this.entries});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final labels = ['−6j', '−5j', '−4j', '−3j', '−2j', 'Hier', "Auj'"];
    final daily = List.generate(7, (i) {
      final day = now.subtract(Duration(days: 6 - i));
      final dayE = entries.where((e) =>
          e.date.year == day.year &&
          e.date.month == day.month &&
          e.date.day == day.day);
      if (dayE.isEmpty) return 0.0;
      return dayE.fold(0.0, (s, e) => s + e.intensity) / dayE.length;
    });

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
        decoration: BoxDecoration(
          color: context._p.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [BoxShadow(
            color: Color(0x081C4D30), blurRadius: 16, offset: Offset(0, 4))],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              width: 28, height: 28,
              decoration: BoxDecoration(
                color: context._p.mintLight, borderRadius: BorderRadius.circular(8)),
              child: Icon(Icons.bar_chart_rounded, size: 15, color: context._p.green),
            ),
            const SizedBox(width: 10),
            Text('Tendance hebdomadaire', style: GoogleFonts.inter(
              fontSize: 13, fontWeight: FontWeight.w700, color: context._p.textDark)),
          ]),
          const SizedBox(height: 16),
          SizedBox(
            height: 70,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (i) {
                final pct = daily[i] / 5;
                return Expanded(child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      AnimatedContainer(
                        duration: Duration(milliseconds: 400 + i * 60),
                        curve: Curves.easeOutCubic,
                        height: pct == 0 ? 3 : 54 * pct,
                        decoration: BoxDecoration(
                          gradient: pct == 0
                              ? null
                              : LinearGradient(
                                  colors: [context._p.mint.withOpacity(0.5), context._p.green],
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter),
                          color: pct == 0 ? context._p.mintLight : null,
                          borderRadius: BorderRadius.circular(6)),
                      ),
                      const SizedBox(height: 6),
                      Text(labels[i], style: GoogleFonts.inter(
                        fontSize: 8, color: context._p.textSoft)),
                    ],
                  ),
                ));
              }),
            ),
          ),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  SYMPTOM TILE
// ─────────────────────────────────────────────────────────────────────────────

class _SymptomTile extends StatefulWidget {
  final SymptomEntry entry;
  final String timeAgo;
  final int index;
  final VoidCallback onDelete;
  const _SymptomTile({
    required this.entry, required this.timeAgo,
    required this.index, required this.onDelete,
  });

  @override
  State<_SymptomTile> createState() => _SymptomTileState();
}

class _SymptomTileState extends State<_SymptomTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 450));
    _fade  = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween(begin: const Offset(0, 0.06), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    Future.delayed(Duration(milliseconds: 50 * widget.index),
        () { if (mounted) _ctrl.forward(); });
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final type  = widget.entry.type;
    final color = type.baseColor;
    final intensity = widget.entry.intensity;

    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: Dismissible(
          key: Key(widget.entry.id),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            padding: const EdgeInsets.only(right: 20),
            decoration: BoxDecoration(
              color: context._p.pinkSoft,
              borderRadius: BorderRadius.circular(18)),
            child: Icon(Icons.delete_outline_rounded,
                color: context._p.warmPink, size: 22),
          ),
          onDismissed: (_) => widget.onDelete(),
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context._p.surface,
              borderRadius: BorderRadius.circular(18),
              boxShadow: const [BoxShadow(
                color: Color(0x081C4D30),
                blurRadius: 14, offset: Offset(0, 3))],
            ),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // icon circle
              Container(
                width: 46, height: 46,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14)),
                child: Icon(type.icon, size: 21, color: color),
              ),
              const SizedBox(width: 14),

              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Text(type.label, style: GoogleFonts.inter(
                      fontSize: 14, fontWeight: FontWeight.w700,
                      color: context._p.textDark)),
                    const Spacer(),
                    Text(widget.timeAgo, style: GoogleFonts.inter(
                      fontSize: 11, color: context._p.textSoft)),
                  ]),
                  const SizedBox(height: 8),
                  // intensity dots
                  Row(children: List.generate(5, (i) => Container(
                    width: 8, height: 8,
                    margin: const EdgeInsets.only(right: 5),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: i < intensity
                          ? color : color.withOpacity(0.15)),
                  ))),
                  if (widget.entry.note != null) ...[
                    const SizedBox(height: 8),
                    Text(widget.entry.note!, style: GoogleFonts.inter(
                      fontSize: 12, color: context._p.textMid, height: 1.5),
                      maxLines: 2, overflow: TextOverflow.ellipsis),
                  ],
                ],
              )),
            ]),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  EMPTY STATE
// ─────────────────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: context._p.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [BoxShadow(
            color: Color(0x081C4D30),
            blurRadius: 16, offset: Offset(0, 4))],
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 64, height: 64,
            decoration: BoxDecoration(
              color: context._p.mintLight, borderRadius: BorderRadius.circular(20)),
            child: Icon(Icons.spa_outlined, size: 30, color: context._p.green),
          ),
          const SizedBox(height: 18),
          Text('Rien de noté cette semaine',
            style: GoogleFonts.outfit(
              fontSize: 16, fontWeight: FontWeight.w600, color: context._p.textDark),
            textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text('Appuie sur le bouton ci-dessous\npour enregistrer comment tu te sens.',
            style: GoogleFonts.inter(
              fontSize: 13, color: context._p.textMid, height: 1.6),
            textAlign: TextAlign.center),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  FAB
// ─────────────────────────────────────────────────────────────────────────────

class _LogFAB extends StatelessWidget {
  final VoidCallback onTap;
  const _LogFAB({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () { HapticFeedback.lightImpact(); onTap(); },
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [context._p.mint, context._p.green],
            begin: Alignment.centerLeft, end: Alignment.centerRight),
          borderRadius: BorderRadius.circular(27),
          boxShadow: const [BoxShadow(
            color: Color(0x501C4D30),
            blurRadius: 18, offset: Offset(0, 6))],
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.add_rounded, color: Colors.white, size: 22),
          const SizedBox(width: 8),
          Text('Ajouter un symptôme', style: GoogleFonts.inter(
            color: Colors.white, fontWeight: FontWeight.w700,
            fontSize: 15, letterSpacing: 0.2)),
        ]),
      ),
    );
  }
}
