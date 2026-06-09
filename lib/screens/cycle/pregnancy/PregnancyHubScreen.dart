// ignore_for_file: deprecated_member_use
import 'package:fiteva/screens/cycle/pregnancy/PregnancyInsightRepository.dart';
import 'package:fiteva/screens/cycle/pregnancy/baby-story/baby_story_screen.dart';
import 'package:fiteva/screens/cycle/pregnancy/checklist/pregnancy_checklist_screen.dart';
import 'package:fiteva/screens/cycle/pregnancy/daily_insight_model.dart';
import 'package:fiteva/screens/cycle/pregnancy/postpartum/postpartum_hub_screen.dart';
import 'package:fiteva/screens/cycle/pregnancy/symptom/symptoms_home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  DESIGN TOKENS
// ─────────────────────────────────────────────────────────────────────────────

abstract class _C {
  static const accent    = Color(0xFFE8927C);
  static const textDark  = Color(0xFF3D2020);
  static const textMuted = Color(0xFFB89090);

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

class PregnancyHubScreen extends StatefulWidget {
  /// The date the pregnancy started (LMP or conception date).
  final DateTime pregnancyStartDate;

  const PregnancyHubScreen({
    super.key,
    required this.pregnancyStartDate,
  });

  @override
  State<PregnancyHubScreen> createState() => _PregnancyHubScreenState();
}

class _PregnancyHubScreenState extends State<PregnancyHubScreen> {
  final DateTime _today = DateTime.now();

  // ── Computed pregnancy data ───────────────────────────────────────────────
  int get _daysSinceStart =>
      _today.difference(widget.pregnancyStartDate).inDays.clamp(0, 280);

  int get _currentWeek => (_daysSinceStart ~/ 7).clamp(1, 40);

  int get _currentDayRemainder => _daysSinceStart % 7;

  // ── Fetus image padding (shrinks as baby grows) ───────────────────────────
  double get _fetusPadding =>
      (80.0 - (_currentWeek - 1) * (76.0 / 39.0)).clamp(4.0, 80.0);

  // ── Locale helpers ────────────────────────────────────────────────────────
  static const _monthNames = [
    'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
    'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre',
  ];
  static const _weekdayShort = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];

  String get _dateLabel =>
      '${_today.day} ${_monthNames[_today.month - 1]}';

  @override
  Widget build(BuildContext context) {
    final insight = PregnancyInsightRepository.forWeek(_currentWeek);

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.4),
            radius: 1.2,
            colors: [Color(0xFFFDEEE4), Color(0xFFF0B896)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildTopBar(context),
                const SizedBox(height: 4),
                _buildDayStrip(),
                const SizedBox(height: 24),
                _buildFetusHero(),
                const SizedBox(height: 18),
                _buildWeekLabel(),
                const SizedBox(height: 12),
                _buildSettingsBtn(),
                const SizedBox(height: 28),
                // White rounded card area
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
                      _buildDailyTips(context, insight),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Divider(color: Color(0xFFF0E8E8), height: 1),
                      ),
                      const SizedBox(height: 20),
                      _buildWeekDetail(insight),
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
          _GlassBtn(icon: Icons.calendar_today_outlined, onTap: () {}),
        ],
      ),
    );
  }

  // ── 7-day strip ─────────────────────────────────────────────────────────────

  Widget _buildDayStrip() {
    final days =
        List.generate(7, (i) => _today.add(Duration(days: i - 3)));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: days.map((d) {
          final isToday =
              d.day == _today.day && d.month == _today.month;
          final widx = d.weekday - 1;

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _weekdayShort[widx],
                style: _C.b(11, w: FontWeight.w600, c: _C.textMuted),
              ),
              const SizedBox(height: 2),
              if (isToday)
                Text(
                  'AUJ.',
                  style: _C.b(8,
                      w: FontWeight.w800, c: _C.accent),
                )
              else
                const SizedBox(height: 12),
              const SizedBox(height: 3),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isToday ? Colors.white : Colors.transparent,
                  shape: BoxShape.circle,
                  boxShadow: isToday
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.12),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          )
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    '${d.day}',
                    style: _C.b(
                      14,
                      w: isToday ? FontWeight.w800 : FontWeight.w500,
                      c: isToday ? _C.accent : _C.textMuted,
                    ),
                  ),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  // ── Fetus hero with AnimatedSwitcher ─────────────────────────────────────────

  Widget _buildFetusHero() {
    final week = _currentWeek;
    final pad  = _fetusPadding;

    return Container(
      width: double.infinity,
      height: 260,
      margin: const EdgeInsets.symmetric(horizontal: 28),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 600),
        transitionBuilder: (child, anim) => FadeTransition(
          opacity: anim,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.85, end: 1.0).animate(
              CurvedAnimation(parent: anim, curve: Curves.easeOutCubic),
            ),
            child: child,
          ),
        ),
        child: _FetusFrame(
          key: ValueKey(week),
          week: week,
          padding: pad,
        ),
      ),
    );
  }

  // ── Week label ───────────────────────────────────────────────────────────────

  Widget _buildWeekLabel() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '$_currentWeek semaines, $_currentDayRemainder jours',
          style: _C.h(22, w: FontWeight.w800, c: _C.accent),
        ),
        const SizedBox(width: 6),
        const Icon(Icons.info_outline_rounded, size: 16, color: _C.accent),
      ],
    );
  }

  // ── Settings / Born button ────────────────────────────────────────────────────

  Widget _buildSettingsBtn() {
    // Dès la semaine 37 (terme), on propose le passage au post-partum
    if (_currentWeek >= 37) {
      return _BabyBornButton(
        onTap: () {
          HapticFeedback.mediumImpact();
          _navigateToPostpartum(DateTime.now());
        },
      );
    }
    return OutlinedButton(
      onPressed: () {
        HapticFeedback.lightImpact();
      },
      style: OutlinedButton.styleFrom(
        foregroundColor: _C.accent,
        side: const BorderSide(color: Colors.white, width: 1.5),
        backgroundColor: Colors.white.withOpacity(0.6),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 9),
      ),
      child: Text('Paramètres',
          style: _C.b(13, w: FontWeight.w700, c: _C.accent)),
    );
  }

  void _navigateToPostpartum(DateTime birthDate) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, animation, __) =>
            PostpartumHubScreen(birthDate: birthDate),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            ),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  // ── Daily tips horizontal scroll ─────────────────────────────────────────────

  Widget _buildDailyTips(BuildContext context, DailyInsight insight) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 26, 0, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Row(
              children: [
                Text('Mes conseils quotidiens',
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
                // Symptômes
                _TipCard(
                  badge: null,
                  label: 'Enregistrez\nvos symptômes',
                  icon: Icons.favorite_border_rounded,
                  iconColor: _C.accent,
                  bg: const Color(0xFFFFF0EB),
                  showAdd: true,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SymptomsHomeScreen(
                            currentWeek: _currentWeek),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 12),
                // Corps
                _TipCard(
                  badge: null,
                  label: 'Votre corps à\n$_currentWeek sem.',
                  icon: Icons.accessibility_new_rounded,
                  iconColor: const Color(0xFFD4A0B0),
                  bg: const Color(0xFFFCEEF3),
                  bordered: true,
                  onTap: () {},
                ),
                const SizedBox(width: 12),
                // Bébé
                _TipCard(
                  badge: '$_currentWeek sem.',
                  label: 'Votre bébé',
                  icon: Icons.child_care_rounded,
                  iconColor: const Color(0xFF7ABB98),
                  bg: const Color(0xFFEFF7F2),
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BabyStoryScreen(
                            currentWeek: _currentWeek),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 12),
                // Checklist
                _TipCard(
                  badge: null,
                  label: 'Ma liste de\ncontrôle',
                  icon: Icons.checklist_rounded,
                  iconColor: const Color(0xFFA7B8AD),
                  bg: const Color(0xFFF0F4F2),
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PregnancyChecklistScreen(
                            currentWeek: _currentWeek),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Week detail section ──────────────────────────────────────────────────────

  Widget _buildWeekDetail(DailyInsight insight) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$_currentWeek semaines : à quoi s'attendre",
            style: _C.h(17, w: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(insight.title,
              style: _C.b(13, c: _C.textMuted)),
          const SizedBox(height: 16),
          _InsightBlock(
            icon: Icons.child_care_rounded,
            title: 'Votre bébé',
            color: _C.accent,
            text: insight.babyInsight,
          ),
          const SizedBox(height: 14),
          _InsightBlock(
            icon: Icons.favorite_rounded,
            title: 'Pour vous',
            color: const Color(0xFF7ABB98),
            text: insight.momTip,
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFFFDEEE4),
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
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  FETUS FRAME — handles sprite sheet cropping at runtime
// ─────────────────────────────────────────────────────────────────────────────

class _FetusFrame extends StatelessWidget {
  final int week;     // 1-40
  final double padding;

  const _FetusFrame({super.key, required this.week, required this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE8927C).withOpacity(0.18),
            blurRadius: 32,
            offset: const Offset(0, 12),
            spreadRadius: 4,
          ),
        ],
      ),
      child: AnimatedPadding(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(horizontal: padding, vertical: padding * 0.6),
        child: Image.asset(
          'assets/fetus/week_$week.png',
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => _FetusPlaceholder(week: week),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  FETUS PLACEHOLDER — shown until split script is run
// ─────────────────────────────────────────────────────────────────────────────

class _FetusPlaceholder extends StatelessWidget {
  final int week;
  const _FetusPlaceholder({required this.week});

  @override
  Widget build(BuildContext context) {
    // Icon radius grows linearly: week 1 → 12 px, week 40 → 90 px
    final r = (12.0 + (week - 1) * (78.0 / 39.0)).clamp(12.0, 90.0);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: r * 2,
            height: r * 2.4,
            decoration: BoxDecoration(
              color: const Color(0xFFE8927C).withOpacity(0.25),
              borderRadius: BorderRadius.circular(r),
            ),
            child: Icon(
              Icons.child_friendly_rounded,
              size: r,
              color: const Color(0xFFE8927C).withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Semaine $week',
            style: GoogleFonts.nunito(
              fontSize: 11,
              color: const Color(0xFFE8927C).withOpacity(0.7),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  TIP CARD
// ─────────────────────────────────────────────────────────────────────────────

class _TipCard extends StatelessWidget {
  final String? badge;
  final String label;
  final IconData icon;
  final Color iconColor;
  final Color bg;
  final bool showAdd;
  final bool bordered;
  final VoidCallback onTap;

  const _TipCard({
    required this.badge,
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.bg,
    required this.onTap,
    this.showAdd = false,
    this.bordered = false,
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
          border: bordered
              ? Border.all(color: const Color(0xFFD4A0B0), width: 1.5)
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            )
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
                  color: const Color(0xFF7ABB98).withOpacity(0.18),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  badge!,
                  style: GoogleFonts.nunito(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF4A8A6A),
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
                decoration: BoxDecoration(
                    color: iconColor, shape: BoxShape.circle),
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
                color: const Color(0xFF5C3D3D),
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
                      color: const Color(0xFF6B5050),
                      height: 1.55)),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  BABY BORN BUTTON — affiché dès S37
// ─────────────────────────────────────────────────────────────────────────────

class _BabyBornButton extends StatelessWidget {
  final VoidCallback onTap;
  const _BabyBornButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 11),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFB99FD8), Color(0xFF9B7FC7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF9B7FC7).withOpacity(0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.child_friendly_rounded,
                size: 18, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              'Mon bébé est né !',
              style: GoogleFonts.nunito(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
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
        child: Icon(icon, size: 16, color: const Color(0xFF8B6060)),
      ),
    );
  }
}
