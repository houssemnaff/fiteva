// ignore_for_file: deprecated_member_use
import 'package:fiteva/screens/cycle/pregnancy/postpartum/postpartum_insight_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  DESIGN TOKENS — teintes lavande/mauve post-partum
// ─────────────────────────────────────────────────────────────────────────────

abstract class _C {
  static const accent    = Color(0xFF9B7FC7);
  static const accentSoft = Color(0xFFB99FD8);
  static const bg1       = Color(0xFFF5EEFF);
  static const bg2       = Color(0xFFDFC8F5);
  static const textDark  = Color(0xFF2D1B45);
  static const textMuted = Color(0xFF8C7AAA);

  static TextStyle h(double s,
          {FontWeight w = FontWeight.w600, Color c = textDark}) =>
      GoogleFonts.nunito(fontSize: s, fontWeight: w, color: c);

  static TextStyle b(double s,
          {FontWeight w = FontWeight.w400, Color c = textDark}) =>
      GoogleFonts.nunito(fontSize: s, fontWeight: w, color: c);
}

// ─────────────────────────────────────────────────────────────────────────────
//  MAIN SCREEN
// ─────────────────────────────────────────────────────────────────────────────

class PostpartumHubScreen extends StatefulWidget {
  /// Date de naissance du bébé.
  final DateTime birthDate;

  const PostpartumHubScreen({super.key, required this.birthDate});

  @override
  State<PostpartumHubScreen> createState() => _PostpartumHubScreenState();
}

class _PostpartumHubScreenState extends State<PostpartumHubScreen> {
  final DateTime _today = DateTime.now();

  int get _daysSinceBirth =>
      _today.difference(widget.birthDate).inDays.clamp(0, 365);

  int get _currentWeek => ((_daysSinceBirth ~/ 7) + 1).clamp(1, 12);

  int get _currentDayRemainder => _daysSinceBirth % 7;

  static const _monthNames = [
    'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
    'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre',
  ];

  String get _dateLabel =>
      '${_today.day} ${_monthNames[_today.month - 1]}';

  String get _periodLabel {
    if (_currentWeek <= 2)  return '4e trimestre · Phase 1';
    if (_currentWeek <= 6)  return '4e trimestre · Phase 2';
    if (_currentWeek <= 12) return '4e trimestre · Phase 3';
    return 'Au-delà du post-partum';
  }

  @override
  Widget build(BuildContext context) {
    final insight = PostpartumInsightRepository.forWeek(_currentWeek);

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.4),
            radius: 1.2,
            colors: [_C.bg1, _C.bg2],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildTopBar(context),
                const SizedBox(height: 20),
                _buildHeroCard(),
                const SizedBox(height: 16),
                _buildWeekLabel(),
                const SizedBox(height: 8),
                _buildPeriodPill(),
                const SizedBox(height: 28),
                Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(32)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildQuickActions(context),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Divider(color: Color(0xFFEDE6F5), height: 1),
                      ),
                      const SizedBox(height: 20),
                      _buildInsightSection(insight),
                      const SizedBox(height: 48),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Top bar ─────────────────────────────────────────────────────────────────

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: Row(
        children: [
          _GlassBtn(
            icon: Icons.arrow_back_ios_new_rounded,
            onTap: () => Navigator.maybePop(context),
          ),
          const Spacer(),
          Text(_dateLabel,
              style: _C.b(16, w: FontWeight.w700, c: _C.textDark)),
          const Spacer(),
          _GlassBtn(icon: Icons.favorite_outline_rounded, onTap: () {}),
        ],
      ),
    );
  }

  // ── Hero card with baby/mom illustration ────────────────────────────────────

  Widget _buildHeroCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 28),
      height: 220,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFEAD5FF), Color(0xFFF3EAFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: _C.accent.withOpacity(0.18),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Décorations cercles
          Positioned(
            top: -20,
            right: -20,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _C.accent.withOpacity(0.08),
              ),
            ),
          ),
          Positioned(
            bottom: -30,
            left: -10,
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _C.accentSoft.withOpacity(0.12),
              ),
            ),
          ),
          // Contenu
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.7),
                    boxShadow: [
                      BoxShadow(
                        color: _C.accent.withOpacity(0.2),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.child_care_rounded,
                    size: 48,
                    color: _C.accent,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Post-partum',
                  style: _C.h(20, w: FontWeight.w800, c: _C.accent),
                ),
                const SizedBox(height: 4),
                Text(
                  'Le 4e trimestre — prendre soin de vous deux',
                  style: _C.b(12, c: _C.textMuted),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Week label ───────────────────────────────────────────────────────────────

  Widget _buildWeekLabel() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Semaine $_currentWeek · $_currentDayRemainder jours',
          style: _C.h(22, w: FontWeight.w800, c: _C.accent),
        ),
        const SizedBox(width: 6),
        const Icon(Icons.info_outline_rounded, size: 16, color: _C.accent),
      ],
    );
  }

  // ── Period pill ──────────────────────────────────────────────────────────────

  Widget _buildPeriodPill() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.4)),
      ),
      child: Text(
        _periodLabel,
        style: _C.b(12, w: FontWeight.w700, c: _C.accent),
      ),
    );
  }

  // ── Quick action cards ───────────────────────────────────────────────────────

  Widget _buildQuickActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 26, 0, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Row(
              children: [
                Text('Suivi du jour',
                    style: _C.b(15, w: FontWeight.w700)),
                Text(' • ', style: _C.b(15, c: _C.textMuted)),
                Text("Aujourd'hui",
                    style: _C.b(15, c: _C.textMuted)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 152,
            child: ListView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              children: [
                _ActionCard(
                  label: 'Mon\nhumeur',
                  icon: Icons.sentiment_satisfied_alt_rounded,
                  iconColor: _C.accent,
                  bg: const Color(0xFFF3EAFF),
                  showAdd: true,
                  onTap: () => HapticFeedback.lightImpact(),
                ),
                const SizedBox(width: 12),
                _ActionCard(
                  label: 'Exercices\ndoux',
                  icon: Icons.self_improvement_rounded,
                  iconColor: const Color(0xFF7ABB98),
                  bg: const Color(0xFFEFF7F2),
                  onTap: () => HapticFeedback.lightImpact(),
                ),
                const SizedBox(width: 12),
                _ActionCard(
                  label: 'Allaitement\n& nutrition',
                  icon: Icons.local_dining_rounded,
                  iconColor: const Color(0xFFD4A0B0),
                  bg: const Color(0xFFFCEEF3),
                  onTap: () => HapticFeedback.lightImpact(),
                ),
                const SizedBox(width: 12),
                _ActionCard(
                  label: 'Bébé\nce mois',
                  badge: 'S$_currentWeek',
                  icon: Icons.child_friendly_rounded,
                  iconColor: const Color(0xFF9B7FC7),
                  bg: const Color(0xFFF5EEFF),
                  onTap: () => HapticFeedback.lightImpact(),
                ),
                const SizedBox(width: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Insight section ──────────────────────────────────────────────────────────

  Widget _buildInsightSection(PostpartumInsight insight) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Semaine $_currentWeek — ${insight.title}',
            style: _C.h(17, w: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          _InsightBlock(
            icon: Icons.child_care_rounded,
            title: 'Votre bébé',
            color: const Color(0xFF9B7FC7),
            text: insight.babyMilestone,
          ),
          const SizedBox(height: 14),
          _InsightBlock(
            icon: Icons.favorite_rounded,
            title: 'Votre récupération',
            color: const Color(0xFFD4A0B0),
            text: insight.momRecovery,
          ),
          const SizedBox(height: 14),
          _InsightBlock(
            icon: Icons.psychology_rounded,
            title: 'Santé mentale',
            color: const Color(0xFF7ABB98),
            text: insight.mentalHealth,
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFF0E6FF), Color(0xFFFAF5FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Text(
              '"${insight.poeticLine}"',
              style: _C.h(13, w: FontWeight.w400, c: _C.accent).copyWith(
                fontStyle: FontStyle.italic,
                height: 1.65,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 20),
          _buildProgressBar(),
        ],
      ),
    );
  }

  // ── 4th trimester progress bar ───────────────────────────────────────────────

  Widget _buildProgressBar() {
    final progress = (_currentWeek / 12).clamp(0.0, 1.0);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F5FF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE8DEFF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('4e trimestre',
                  style: _C.b(13, w: FontWeight.w700, c: _C.textDark)),
              Text('$_currentWeek / 12 semaines',
                  style: _C.b(12, c: _C.textMuted)),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: const Color(0xFFE8DEFF),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(_C.accent),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _currentWeek < 12
                ? '${12 - _currentWeek} semaines restantes de suivi post-partum'
                : 'Bravo ! Vous avez traversé le 4e trimestre. 🎉',
            style: _C.b(11, c: _C.textMuted),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  ACTION CARD
// ─────────────────────────────────────────────────────────────────────────────

class _ActionCard extends StatelessWidget {
  final String? badge;
  final String label;
  final IconData icon;
  final Color iconColor;
  final Color bg;
  final bool showAdd;
  final VoidCallback onTap;

  const _ActionCard({
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.bg,
    required this.onTap,
    this.badge,
    this.showAdd = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (badge != null)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF9B7FC7).withOpacity(0.18),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  badge!,
                  style: GoogleFonts.nunito(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF6B4FA0),
                  ),
                ),
              )
            else
              const SizedBox(),
            const Spacer(),
            Icon(icon, size: 38, color: iconColor),
            if (showAdd) ...[
              const SizedBox(height: 4),
              Container(
                width: 26,
                height: 26,
                decoration:
                    BoxDecoration(color: iconColor, shape: BoxShape.circle),
                child:
                    const Icon(Icons.add, size: 15, color: Colors.white),
              ),
            ],
            const SizedBox(height: 10),
            Text(
              label,
              style: GoogleFonts.nunito(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF3D2460),
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  INSIGHT BLOCK
// ─────────────────────────────────────────────────────────────────────────────

class _InsightBlock extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final String text;

  const _InsightBlock({
    required this.icon,
    required this.title,
    required this.color,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
              color: color.withOpacity(0.14), shape: BoxShape.circle),
          child: Icon(icon, size: 17, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: GoogleFonts.nunito(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: color)),
              const SizedBox(height: 5),
              Text(text,
                  style: GoogleFonts.nunito(
                      fontSize: 13,
                      color: const Color(0xFF4A3560),
                      height: 1.55)),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  GLASS BUTTON
// ─────────────────────────────────────────────────────────────────────────────

class _GlassBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _GlassBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.55),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.3)),
        ),
        child: Icon(icon, size: 16, color: const Color(0xFF7A5A9E)),
      ),
    );
  }
}
