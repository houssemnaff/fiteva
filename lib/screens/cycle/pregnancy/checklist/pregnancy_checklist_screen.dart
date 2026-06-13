// ignore_for_file: deprecated_member_use
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../pregnancy_colors.dart';
import 'pregnancy_checklist_repository.dart';

extension _Pg on BuildContext {
  PgColors get _p => PgColors.of(this);
}

// catégorie → couleur + label
({Color bg, Color fg, String label}) _catStyle(String cat, BuildContext context) {
  switch (cat) {
    case 'medical':   return (bg: context._p.mintLight, fg: context._p.green,    label: 'Médical');
    case 'bienetre':  return (bg: context._p.pinkSoft,  fg: context._p.warmPink, label: 'Bien-être');
    default:          return (bg: context._p.amberSoft, fg: context._p.amber,    label: 'Pratique');
  }
}

IconData _catIcon(String cat) {
  switch (cat) {
    case 'medical':  return Icons.local_hospital_outlined;
    case 'bienetre': return Icons.favorite_border_rounded;
    default:         return Icons.checklist_rounded;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
class PregnancyChecklistScreen extends StatefulWidget {
  final int currentWeek;
  const PregnancyChecklistScreen({super.key, required this.currentWeek});

  @override
  State<PregnancyChecklistScreen> createState() =>
      _PregnancyChecklistScreenState();
}

class _PregnancyChecklistScreenState
    extends State<PregnancyChecklistScreen> {
  late final List<ChecklistTask> _tasks;
  final Set<String> _done = {};

  int get _doneCount  => _done.length;
  int get _total      => _tasks.length;
  double get _progress => _total == 0 ? 0 : _doneCount / _total;

  @override
  void initState() {
    super.initState();
    _tasks = PregnancyChecklistRepository.forWeek(widget.currentWeek);
  }

  void _toggle(String id) {
    HapticFeedback.lightImpact();
    setState(() => _done.contains(id) ? _done.remove(id) : _done.add(id));
  }

  @override
  Widget build(BuildContext context) {
    final top    = MediaQuery.of(context).padding.top;
    final bottom = MediaQuery.of(context).padding.bottom;

    // groupe par catégorie
    final medical  = _tasks.where((t) => t.category == 'medical').toList();
    final bienetre = _tasks.where((t) => t.category == 'bienetre').toList();
    final pratique = _tasks.where((t) => t.category == 'pratique').toList();

    return Scaffold(
      backgroundColor: context._p.bg,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(children: [

          // ── HEADER ──────────────────────────────────────────────────
          _Header(
            top: top,
            week: widget.currentWeek,
            done: _doneCount,
            total: _total,
            progress: _progress,
            onBack: () => Navigator.maybePop(context),
          ),

          const SizedBox(height: 20),

          // ── GROUPES ─────────────────────────────────────────────────
          if (medical.isNotEmpty) ...[
            _GroupSection(
              category: 'medical',
              tasks: medical,
              done: _done,
              onToggle: _toggle,
            ),
            const SizedBox(height: 12),
          ],
          if (bienetre.isNotEmpty) ...[
            _GroupSection(
              category: 'bienetre',
              tasks: bienetre,
              done: _done,
              onToggle: _toggle,
            ),
            const SizedBox(height: 12),
          ],
          if (pratique.isNotEmpty) ...[
            _GroupSection(
              category: 'pratique',
              tasks: pratique,
              done: _done,
              onToggle: _toggle,
            ),
            const SizedBox(height: 12),
          ],

          if (_tasks.isEmpty) _EmptyState(week: widget.currentWeek),

          // ── À VENIR ─────────────────────────────────────────────────
          _UpcomingSection(currentWeek: widget.currentWeek),

          SizedBox(height: bottom + 40),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  HEADER
// ─────────────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final double top;
  final int week, done, total;
  final double progress;
  final VoidCallback onBack;

  const _Header({
    required this.top, required this.week,
    required this.done, required this.total,
    required this.progress, required this.onBack,
  });

  String get _tri => week <= 13 ? '1er trimestre'
      : week <= 26 ? '2e trimestre' : '3e trimestre';

  @override
  Widget build(BuildContext context) {
    return Container(
      color: context._p.surface,
      padding: EdgeInsets.fromLTRB(20, top + 12, 20, 24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // top row
        Row(children: [
          GestureDetector(
            onTap: onBack,
            child: Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: context._p.mintLight,
                borderRadius: BorderRadius.circular(10)),
              child: Icon(Icons.chevron_left_rounded,
                  size: 22, color: context._p.green),
            ),
          ),
          const SizedBox(width: 14),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('MA CHECKLIST', style: GoogleFonts.inter(
              fontSize: 9, fontWeight: FontWeight.w600,
              color: context._p.textSoft, letterSpacing: 2.5)),
            const SizedBox(height: 1),
            Text('Semaine $week · $_tri',
                style: GoogleFonts.inter(
                  fontSize: 15, fontWeight: FontWeight.w700,
                  color: context._p.textDark)),
          ]),
          const Spacer(),
          // ring de progression
          SizedBox(width: 56, height: 56,
            child: Stack(alignment: Alignment.center, children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: progress),
                duration: const Duration(milliseconds: 900),
                curve: Curves.easeOutCubic,
                builder: (_, v, __) => CustomPaint(
                  size: const Size(56, 56),
                  painter: _RingPainter(v, context._p.green, context._p.mintLight)),
              ),
              Column(mainAxisSize: MainAxisSize.min, children: [
                Text('$done', style: GoogleFonts.inter(
                  fontSize: 16, fontWeight: FontWeight.w800,
                  color: context._p.green, height: 1)),
                Text('/$total', style: GoogleFonts.inter(
                  fontSize: 9, color: context._p.textSoft)),
              ]),
            ]),
          ),
        ]),

        const SizedBox(height: 20),

        // progress bar + label
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(total == 0
              ? 'Aucune tâche cette semaine'
              : done == total
                  ? 'Tout est fait — bravo !'
                  : '$done sur $total tâches complétées',
              style: GoogleFonts.inter(
                fontSize: 12, color: context._p.textMid, fontWeight: FontWeight.w500)),
          Text('${(progress * 100).round()}%',
              style: GoogleFonts.inter(
                fontSize: 12, color: context._p.green, fontWeight: FontWeight.w700)),
        ]),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Stack(children: [
            Container(height: 7, color: context._p.mintLight),
            AnimatedFractionallySizedBox(
              widthFactor: progress,
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutCubic,
              child: Container(
                height: 7,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [context._p.mint, context._p.green]),
                  borderRadius: const BorderRadius.all(Radius.circular(4)),
                )),
            ),
          ]),
        ),
      ]),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color fill, track;
  const _RingPainter(this.progress, this.fill, this.track);

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = (size.width - 8) / 2;
    final rect = Rect.fromCircle(center: c, radius: r);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, -math.pi / 2, math.pi * 2, false,
        paint..color = track);
    if (progress > 0) {
      canvas.drawArc(rect, -math.pi / 2, math.pi * 2 * progress, false,
          paint..color = fill);
    }
  }

  @override
  bool shouldRepaint(_RingPainter o) => o.progress != progress;
}

// ─────────────────────────────────────────────────────────────────────────────
//  GROUP SECTION
// ─────────────────────────────────────────────────────────────────────────────

class _GroupSection extends StatelessWidget {
  final String category;
  final List<ChecklistTask> tasks;
  final Set<String> done;
  final void Function(String) onToggle;

  const _GroupSection({
    required this.category, required this.tasks,
    required this.done, required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final style = _catStyle(category, context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: context._p.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [BoxShadow(
            color: Color(0x081C4D30),
            blurRadius: 16, offset: Offset(0, 4))],
        ),
        child: Column(children: [
          // group header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(children: [
              Container(
                width: 32, height: 32,
                decoration: BoxDecoration(
                  color: style.bg,
                  borderRadius: BorderRadius.circular(9)),
                child: Icon(_catIcon(category), size: 16, color: style.fg),
              ),
              const SizedBox(width: 10),
              Text(style.label, style: GoogleFonts.inter(
                fontSize: 13, fontWeight: FontWeight.w700,
                color: style.fg)),
              const Spacer(),
              Text('${done.where((id) => tasks.any((t)=>t.id==id)).length}/${tasks.length}',
                style: GoogleFonts.inter(
                  fontSize: 12, color: context._p.textSoft,
                  fontWeight: FontWeight.w500)),
            ]),
          ),

          Divider(height: 1, color: context._p.border),

          // tasks
          ...List.generate(tasks.length, (i) {
            final task = tasks[i];
            final isDone = done.contains(task.id);
            return _TaskTile(
              task: task,
              isDone: isDone,
              catColor: style.fg,
              isLast: i == tasks.length - 1,
              index: i,
              onToggle: () => onToggle(task.id),
            );
          }),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  TASK TILE
// ─────────────────────────────────────────────────────────────────────────────

class _TaskTile extends StatefulWidget {
  final ChecklistTask task;
  final bool isDone, isLast;
  final Color catColor;
  final int index;
  final VoidCallback onToggle;

  const _TaskTile({
    required this.task, required this.isDone, required this.isLast,
    required this.catColor, required this.index, required this.onToggle,
  });

  @override
  State<_TaskTile> createState() => _TaskTileState();
}

class _TaskTileState extends State<_TaskTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 450));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    Future.delayed(Duration(milliseconds: 50 * widget.index),
        () { if (mounted) _ctrl.forward(); });
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: Column(children: [
        GestureDetector(
          onTap: widget.onToggle,
          behavior: HitTestBehavior.opaque,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            color: widget.isDone
                ? widget.catColor.withOpacity(0.04)
                : Colors.transparent,
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // checkbox
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutBack,
                margin: const EdgeInsets.only(top: 1),
                width: 22, height: 22,
                decoration: BoxDecoration(
                  color: widget.isDone
                      ? widget.catColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: widget.isDone
                        ? widget.catColor : context._p.border, width: 1.5),
                ),
                child: widget.isDone
                    ? const Icon(Icons.check_rounded,
                        size: 13, color: Colors.white)
                    : null,
              ),

              const SizedBox(width: 12),

              // texte
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 250),
                    style: GoogleFonts.inter(
                      fontSize: 14, fontWeight: FontWeight.w600,
                      height: 1.3,
                      color: widget.isDone ? context._p.textSoft : context._p.textDark,
                      decoration: widget.isDone
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                      decorationColor: widget.catColor.withOpacity(0.5)),
                    child: Text(widget.task.title),
                  ),
                  const SizedBox(height: 4),
                  AnimatedOpacity(
                    opacity: widget.isDone ? 0.45 : 1.0,
                    duration: const Duration(milliseconds: 250),
                    child: Text(widget.task.description,
                      style: GoogleFonts.inter(
                        fontSize: 12, color: context._p.textMid, height: 1.55)),
                  ),
                ],
              )),
            ]),
          ),
        ),
        if (!widget.isLast)
          Divider(height: 1, indent: 50, color: context._p.border),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  UPCOMING SECTION — prochaines semaines
// ─────────────────────────────────────────────────────────────────────────────

class _UpcomingSection extends StatelessWidget {
  final int currentWeek;
  const _UpcomingSection({required this.currentWeek});

  List<MapEntry<int, List<ChecklistTask>>> _upcoming() {
    final out = <MapEntry<int, List<ChecklistTask>>>[];
    for (int w = currentWeek + 1; w <= 42 && out.length < 3; w++) {
      final t = PregnancyChecklistRepository.forWeek(w);
      if (t.isNotEmpty) out.add(MapEntry(w, t));
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    final weeks = _upcoming();
    if (weeks.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: context._p.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [BoxShadow(
            color: Color(0x081C4D30),
            blurRadius: 16, offset: Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
              child: Row(children: [
                Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(
                    color: context._p.mintLight,
                    borderRadius: BorderRadius.circular(9)),
                  child: Icon(Icons.calendar_month_outlined,
                      size: 16, color: context._p.green),
                ),
                const SizedBox(width: 10),
                Text('À venir', style: GoogleFonts.inter(
                  fontSize: 13, fontWeight: FontWeight.w700,
                  color: context._p.green)),
              ]),
            ),
            Divider(height: 1, color: context._p.border),

            ...weeks.map((e) => _UpcomingWeekTile(week: e.key, tasks: e.value)),
          ],
        ),
      ),
    );
  }
}

class _UpcomingWeekTile extends StatelessWidget {
  final int week;
  final List<ChecklistTask> tasks;
  const _UpcomingWeekTile({required this.week, required this.tasks});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // semaine label
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: context._p.mintLight,
            borderRadius: BorderRadius.circular(6)),
          child: Text('Semaine $week', style: GoogleFonts.inter(
            fontSize: 10, fontWeight: FontWeight.w600,
            color: context._p.green, letterSpacing: 0.5)),
        ),
        const SizedBox(height: 10),
        ...tasks.map((t) {
          final style = _catStyle(t.category, context);
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(children: [
              Container(
                width: 6, height: 6,
                decoration: BoxDecoration(
                  color: style.fg, shape: BoxShape.circle),
              ),
              const SizedBox(width: 10),
              Expanded(child: Text(t.title, style: GoogleFonts.inter(
                fontSize: 13, color: context._p.textMid,
                fontWeight: FontWeight.w500))),
            ]),
          );
        }),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  EMPTY STATE
// ─────────────────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final int week;
  const _EmptyState({required this.week});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(48),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 64, height: 64,
          decoration: BoxDecoration(
            color: context._p.mintLight, borderRadius: BorderRadius.circular(20)),
          child: Icon(Icons.spa_outlined, size: 30, color: context._p.green),
        ),
        const SizedBox(height: 18),
        Text('Rien de prévu cette semaine', style: GoogleFonts.outfit(
          fontSize: 16, fontWeight: FontWeight.w600, color: context._p.textDark),
          textAlign: TextAlign.center),
        const SizedBox(height: 8),
        Text('Profite de ce moment de calme.\nLes prochaines tâches arrivent bientôt.',
          style: GoogleFonts.inter(
            fontSize: 13, color: context._p.textMid, height: 1.6),
          textAlign: TextAlign.center),
      ]),
    );
  }
}
