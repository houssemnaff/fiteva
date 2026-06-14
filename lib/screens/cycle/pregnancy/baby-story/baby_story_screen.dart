// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../pregnancy_colors.dart';
import 'baby_story_repository.dart';

extension _Pg on BuildContext {
  PgColors get _p => PgColors.of(this);
}

// ─────────────────────────────────────────────────────────────────────────────
class BabyStoryScreen extends StatefulWidget {
  final int currentWeek;
  const BabyStoryScreen({super.key, required this.currentWeek});

  @override
  State<BabyStoryScreen> createState() => _BabyStoryScreenState();
}

class _BabyStoryScreenState extends State<BabyStoryScreen>
    with TickerProviderStateMixin {
  late int _week;
  late AnimationController _fadeCtrl;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _week = widget.currentWeek;
    _fadeCtrl = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 350));
    _fade = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();
  }

  @override
  void dispose() { _fadeCtrl.dispose(); super.dispose(); }

  void _go(int delta) {
    final next = (_week + delta).clamp(1, 40);
    if (next == _week) return;
    HapticFeedback.selectionClick();
    _fadeCtrl.reverse().then((_) {
      setState(() => _week = next);
      _fadeCtrl.forward();
    });
  }

  String get _trimestre => _week <= 13
      ? '1er trimestre'
      : _week <= 26
          ? '2e trimestre'
          : '3e trimestre';

  String _icon() {
    if (_week <= 2)  return '✨';
    if (_week <= 4)  return '🌱';
    if (_week <= 6)  return '💛';
    if (_week <= 8)  return '🌸';
    if (_week <= 10) return '🦋';
    if (_week <= 12) return '🌿';
    if (_week <= 14) return '🌙';
    if (_week <= 16) return '⭐';
    if (_week <= 18) return '🌟';
    if (_week <= 20) return '💫';
    if (_week <= 22) return '🕊️';
    if (_week <= 24) return '🌺';
    if (_week <= 26) return '🌙';
    if (_week <= 28) return '💝';
    if (_week <= 30) return '🦢';
    if (_week <= 32) return '🌸';
    if (_week <= 34) return '🧸';
    if (_week <= 36) return '👼';
    if (_week <= 38) return '💕';
    return '👶';
  }

  @override
  Widget build(BuildContext context) {
    final top    = MediaQuery.of(context).padding.top;
    final bottom = MediaQuery.of(context).padding.bottom;
    final story  = BabyStoryRepository.forWeek(_week);
    final progress = _week / 40;

    return Scaffold(
      backgroundColor: context._p.bg,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(children: [

          // ── HEADER ────────────────────────────────────────────────────
          Container(
            color: context._p.surface,
            padding: EdgeInsets.fromLTRB(20, top + 12, 20, 20),
            child: Column(children: [
              // nav row
              Row(children: [
                GestureDetector(
                  onTap: () => Navigator.maybePop(context),
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
                  Text('L\'HISTOIRE DE BÉBÉ', style: GoogleFonts.inter(
                    fontSize: 9, fontWeight: FontWeight.w600,
                    color: context._p.textSoft, letterSpacing: 2.5)),
                  const SizedBox(height: 1),
                  Text(_trimestre, style: GoogleFonts.inter(
                    fontSize: 14, fontWeight: FontWeight.w700,
                    color: context._p.textDark)),
                ]),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: context._p.mintLight,
                    borderRadius: BorderRadius.circular(20)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.favorite_rounded,
                        size: 12, color: context._p.warmPink),
                    const SizedBox(width: 5),
                    Text('S. $_week / 40', style: GoogleFonts.inter(
                      fontSize: 11, fontWeight: FontWeight.w700,
                      color: context._p.green)),
                  ]),
                ),
              ]),

              const SizedBox(height: 20),

              // progress bar
              Stack(children: [
                Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: context._p.mintLight,
                    borderRadius: BorderRadius.circular(3)),
                ),
                AnimatedFractionallySizedBox(
                  widthFactor: progress,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeOutCubic,
                  child: Container(
                    height: 6,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                          colors: [context._p.mint, context._p.green]),
                      borderRadius: BorderRadius.circular(3)),
                  ),
                ),
              ]),

              const SizedBox(height: 10),

              // week navigator
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _NavBtn(
                    icon: Icons.chevron_left_rounded,
                    enabled: _week > 1,
                    onTap: () => _go(-1),
                  ),
                  const SizedBox(width: 16),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    transitionBuilder: (child, anim) =>
                        ScaleTransition(scale: anim, child: child),
                    child: Text('Semaine $_week',
                      key: ValueKey(_week),
                      style: GoogleFonts.outfit(
                        fontSize: 18, fontWeight: FontWeight.w600,
                        color: context._p.green)),
                  ),
                  const SizedBox(width: 16),
                  _NavBtn(
                    icon: Icons.chevron_right_rounded,
                    enabled: _week < 40,
                    onTap: () => _go(1),
                  ),
                ],
              ),
            ]),
          ),

          const SizedBox(height: 20),

          FadeTransition(
            opacity: _fade,
            child: Column(children: [

              // ── FRUIT + TITRE ───────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1C4D30), Color(0xFF2E7050)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: const [BoxShadow(
                      color: Color(0x301C4D30),
                      blurRadius: 24, offset: Offset(0, 8))],
                  ),
                  child: Column(children: [
                    // fruit circle
                    Container(
                      width: 80, height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        shape: BoxShape.circle),
                      child: Center(child: Text(_icon(),
                          style: const TextStyle(fontSize: 40))),
                    ),
                    const SizedBox(height: 16),
                    Text(story.title, style: GoogleFonts.outfit(
                      fontSize: 20, fontWeight: FontWeight.w600,
                      color: Colors.white, height: 1.25),
                      textAlign: TextAlign.center),
                    const SizedBox(height: 8),
                    Text('Semaine $_week · ${(progress * 100).round()}% du chemin',
                      style: GoogleFonts.inter(
                        fontSize: 12, color: Colors.white60)),
                  ]),
                ),
              ),

              const SizedBox(height: 16),

              // ── HISTOIRE RACONTÉE PAR BÉBÉ ──────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: context._p.surface,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: const [BoxShadow(
                      color: Color(0x081C4D30),
                      blurRadius: 16, offset: Offset(0, 4))],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Container(
                          width: 28, height: 28,
                          decoration: BoxDecoration(
                            color: context._p.pinkSoft,
                            borderRadius: BorderRadius.circular(8)),
                          child: Icon(Icons.favorite_rounded,
                              size: 14, color: context._p.warmPink),
                        ),
                        const SizedBox(width: 10),
                        Text('Bébé te raconte…', style: GoogleFonts.inter(
                          fontSize: 10, fontWeight: FontWeight.w600,
                          color: context._p.warmPink, letterSpacing: 1.2)),
                      ]),
                      const SizedBox(height: 14),
                      Text(story.story, style: GoogleFonts.outfit(
                        fontSize: 15, height: 1.75,
                        color: context._p.textDark,
                        fontStyle: FontStyle.italic)),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // ── FAIT DU MÉDECIN ─────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: context._p.mintLight,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 34, height: 34,
                        decoration: BoxDecoration(
                          color: context._p.surface,
                          borderRadius: BorderRadius.circular(10)),
                        child: Icon(Icons.auto_awesome_rounded,
                            size: 16, color: context._p.green),
                      ),
                      const SizedBox(width: 14),
                      Expanded(child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Le saviez-vous ?', style: GoogleFonts.inter(
                            fontSize: 10, fontWeight: FontWeight.w700,
                            color: context._p.green, letterSpacing: 1.2)),
                          const SizedBox(height: 6),
                          Text(story.fact, style: GoogleFonts.inter(
                            fontSize: 13, color: context._p.textDark,
                            height: 1.6)),
                        ],
                      )),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // ── MILESTONES ──────────────────────────────────────────────
              if (story.milestones.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: const EdgeInsets.all(18),
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
                        Row(children: [
                          Container(
                            width: 28, height: 28,
                            decoration: BoxDecoration(
                              color: context._p.mintLight,
                              borderRadius: BorderRadius.circular(8)),
                            child: Icon(
                                Icons.checklist_rounded,
                                size: 14, color: context._p.green),
                          ),
                          const SizedBox(width: 10),
                          Text('Développement cette semaine',
                            style: GoogleFonts.inter(
                              fontSize: 10, fontWeight: FontWeight.w600,
                              color: context._p.textSoft, letterSpacing: 1.2)),
                        ]),
                        const SizedBox(height: 14),
                        ...story.milestones.map((m) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 7, height: 7,
                                margin: const EdgeInsets.only(top: 5, right: 12),
                                decoration: BoxDecoration(
                                  color: context._p.mint,
                                  shape: BoxShape.circle),
                              ),
                              Expanded(child: Text(m, style: GoogleFonts.inter(
                                fontSize: 13, color: context._p.textDark,
                                fontWeight: FontWeight.w500, height: 1.4))),
                            ],
                          ),
                        )),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // ── NAVIGATION SEMAINES ─────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(children: [
                 
                  const SizedBox(width: 10),
                  
                ]),
              ),

              SizedBox(height: bottom + 40),
            ]),
          ),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _NavBtn extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;
  const _NavBtn({required this.icon, required this.enabled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 38, height: 38,
        decoration: BoxDecoration(
          color: enabled ? context._p.mintLight : context._p.border.withOpacity(0.4),
          borderRadius: BorderRadius.circular(11)),
        child: Icon(icon, size: 22,
            color: enabled ? context._p.green : context._p.textSoft),
      ),
    );
  }
}

class _WeekNavCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool enabled, trailing;
  final VoidCallback onTap;
  const _WeekNavCard({
    required this.label, required this.icon,
    required this.enabled, required this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? () { HapticFeedback.lightImpact(); onTap(); } : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: enabled ? context._p.surface : context._p.bg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: enabled ? context._p.border : Colors.transparent),
          boxShadow: enabled
              ? const [BoxShadow(
                  color: Color(0x081C4D30),
                  blurRadius: 12, offset: Offset(0, 3))]
              : null,
        ),
        child: Row(
          mainAxisAlignment: trailing
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          children: trailing
              ? [
                  Text(label, style: GoogleFonts.inter(
                    fontSize: 12, fontWeight: FontWeight.w600,
                    color: enabled ? context._p.textDark : context._p.textSoft)),
                  const SizedBox(width: 8),
                  Icon(icon, size: 16,
                      color: enabled ? context._p.green : context._p.textSoft),
                ]
              : [
                  Icon(icon, size: 16,
                      color: enabled ? context._p.green : context._p.textSoft),
                  const SizedBox(width: 8),
                  Text(label, style: GoogleFonts.inter(
                    fontSize: 12, fontWeight: FontWeight.w600,
                    color: enabled ? context._p.textDark : context._p.textSoft)),
                ],
        ),
      ),
    );
  }
}
