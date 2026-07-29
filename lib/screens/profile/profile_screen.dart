import 'dart:math' as math;
import 'package:fiteva/models/points_model.dart';
import 'package:fiteva/providers/diamonds_provider.dart';
import 'package:fiteva/providers/points_provider.dart';
import 'package:fiteva/providers/locale_provider.dart';
import 'package:fiteva/services/auth_service.dart';
import 'package:fiteva/services/storage_service.dart';
import 'package:fiteva/services/local_reminder_service.dart';
import 'package:fiteva/services/privacy_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Clipboard, ClipboardData, HapticFeedback;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../providers/user_profile_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/mascot_provider.dart';
import '../../providers/onboarding_provider.dart';
import '../../providers/subscription_provider.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/mascot_widget.dart';
import '../../widgets/paywall_sheet.dart';
import 'notification_settings_screen.dart';
import 'stripe_integration.dart';
import 'theme_screen.dart';
import 'trends_screen.dart';
import 'workout_history_screen.dart';

class _P {
  _P._();
  static const main   = Color(0xFF1C4D30);
  static const sage   = Color(0xFF7ABB98);
  static const bgL    = Colors.white;
  static const cardL  = Colors.white;
  static const borderL = Color(0xFFE8ECE9);
  static const t1L    = Color(0xFF1A1A1A);
  static const t2L    = Color(0xFF6B7B73);
  static const bgD    = Color(0xFF0F1A14);
  static const cardD  = Color(0xFF162119);
  static const borderD = Color(0xFF253D2E);
  static const t1D    = Color(0xFFF0F0EE);
  static const t2D    = Color(0xFF8A9B92);
  static Color bg(bool d)     => d ? bgD : bgL;
  static Color card(bool d)   => d ? cardD : cardL;
  static Color border(bool d) => d ? borderD : borderL;
  static Color t1(bool d)     => d ? t1D : t1L;
  static Color t2(bool d)     => d ? t2D : t2L;
  static Color accent(bool d) => d ? sage : main;
}

const _days = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];

final expandBadgesProvider  = StateProvider<bool>((ref) => false);
final chatbotVisibilityProvider = StateProvider<bool>(
  (ref) => StorageService.getChatbotVisible(),
);
final remindersEnabledProvider = StateProvider<bool>( // kept for backward compat
  (ref) => LocalReminderService.remindersEnabled,
);

// ─── ProfileScreen ──────────────────────────────────────────────────────────
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(pointsProvider.notifier).reload();
      ref.read(diamondsProvider.notifier).loadDiamonds();
    });
  }

  void _showLevelsSheet(BuildContext context, PointsModel xp) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _LevelsSheet(xp: xp),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user       = ref.watch(userProfileProvider);
    final profile    = ref.watch(userProfileProvider);
    final isDarkMode = ref.watch(themeModeProvider) == ThemeMode.dark;
    final cs         = Theme.of(context).colorScheme;
    final l10n       = ref.watch(l10nProvider);
    final diamonds   = ref.watch(diamondsProvider);
    final xp         = ref.watch(pointsProvider);
    final mascot     = ref.watch(mascotProvider);
    final d          = isDarkMode;

    final displayName  = profile.username.isNotEmpty ? profile.username : user.username;
    final displayEmail = profile.email.isNotEmpty ? profile.email : '';

    final bg    = _P.bg(d);
    final ink   = _P.t1(d);
    final muted = _P.t2(d);
    final surf  = _P.card(d);
    final bdr   = _P.border(d);
    final accent = _P.accent(d);

    Widget buildToggle(bool on, VoidCallback onTap) => GestureDetector(
      onTap: () { HapticFeedback.selectionClick(); onTap(); },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 44, height: 26,
        decoration: BoxDecoration(
          color: on ? _P.main : (d ? const Color(0xFF2A3A30) : const Color(0xFFD4DDD8)),
          borderRadius: BorderRadius.circular(13),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          alignment: on ? Alignment.centerRight : Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Container(width: 22, height: 22,
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
          ),
        ),
      ),
    );

    Widget groupedSection(List<Widget> rows) => Container(
      decoration: BoxDecoration(
        color: surf,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: bdr, width: 0.5),
        boxShadow: [BoxShadow(
          color: Colors.black.withValues(alpha: d ? 0.18 : 0.04),
          blurRadius: 12, offset: const Offset(0, 3))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(children: [
          for (int i = 0; i < rows.length; i++) ...[
            rows[i],
            if (i < rows.length - 1)
              Divider(height: 0.5, thickness: 0.5, color: bdr, indent: 56, endIndent: 16),
          ],
        ]),
      ),
    );

    Widget buildRow({
      required IconData icon,
      required String label,
      Widget? trailing,
      VoidCallback? onTap,
    }) => GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(9)),
            child: Icon(icon, size: 15, color: accent)),
          const SizedBox(width: 12),
          Expanded(child: Text(label,
            style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: ink))),
          if (trailing != null) trailing
          else Icon(LucideIcons.chevronRight, size: 15, color: muted.withValues(alpha: 0.5)),
        ]),
      ),
    );

    return Scaffold(
      backgroundColor: bg,
      body: CustomScrollView(
        slivers: [
          // ── Top bar ─────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: Row(children: [
                  GestureDetector(
                    onTap: () => context.go('/'),
                    child: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: surf, shape: BoxShape.circle,
                        border: Border.all(color: bdr, width: 0.5)),
                      child: Icon(LucideIcons.arrowLeft, size: 18, color: ink)),
                  ),
                  const Spacer(),
                  Text(l10n.profileTitle,
                    style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700,
                      color: ink, letterSpacing: -0.3)),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => _showEditProfile(context, ref, profile, cs),
                    child: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: surf, shape: BoxShape.circle,
                        border: Border.all(color: bdr, width: 0.5)),
                      child: Icon(LucideIcons.penLine, size: 16, color: muted)),
                  ),
                ]),
              ),
            ),
          ),

          // ── Profile hero card ─────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: surf,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: accent.withValues(alpha: 0.15)),
                  boxShadow: [BoxShadow(
                    color: accent.withValues(alpha: d ? 0.08 : 0.06),
                    blurRadius: 24, offset: const Offset(0, 8))],
                ),
                child: Column(children: [
                  Stack(clipBehavior: Clip.none, children: [
                    Container(
                      width: 80, height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft, end: Alignment.bottomRight,
                          colors: [accent.withValues(alpha: 0.15), accent.withValues(alpha: 0.05)]),
                        border: Border.all(color: accent.withValues(alpha: 0.3), width: 2.5)),
                      child: ClipOval(child: MascotWidget(
                        type: mascot.type, mood: mascot.mood, size: 76)),
                    ),
                    Positioned(bottom: -2, right: -2,
                      child: GestureDetector(
                        onTap: () => context.push('/edit-avatar'),
                        child: Container(
                          width: 28, height: 28,
                          decoration: BoxDecoration(
                            color: _P.main, shape: BoxShape.circle,
                            border: Border.all(color: surf, width: 2.5)),
                          child: const Icon(LucideIcons.camera, size: 12, color: Colors.white)),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 14),
                  Row(mainAxisSize: MainAxisSize.min, children: [
                    Flexible(
                      child: Text(
                        displayName.isNotEmpty ? displayName : l10n.profileUser,
                        maxLines: 1, overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w700,
                          color: ink, letterSpacing: -0.4)),
                    ),
                    Consumer(builder: (_, ref2, __) {
                      if (!ref2.watch(isProProvider)) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF1C4D30), Color(0xFF7ABB98)]),
                            borderRadius: BorderRadius.circular(8)),
                          child: Text('PRO',
                            style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w800,
                              color: Colors.white, letterSpacing: 0.6)),
                        ),
                      );
                    }),
                  ]),
                  if (displayEmail.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(displayEmail, maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(fontSize: 13, color: muted)),
                  ],
                ]),
              ),
            ),
          ),

          // ── Stats bar (unified) ───────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: surf,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: bdr, width: 0.5),
                  boxShadow: [BoxShadow(
                    color: Colors.black.withValues(alpha: d ? 0.18 : 0.04),
                    blurRadius: 12, offset: const Offset(0, 3))],
                ),
                child: IntrinsicHeight(
                  child: Row(children: [
                    _UnifiedStat(icon: LucideIcons.flame, value: '${xp.streak}',
                      label: l10n.profileStreak, color: const Color(0xFFE8734A), d: d),
                    VerticalDivider(width: 1, thickness: 1,
                      color: bdr, indent: 8, endIndent: 8),
                    _UnifiedStat(icon: LucideIcons.dumbbell, value: '48',
                      label: l10n.profileSessions, color: _P.sage, d: d),
                    VerticalDivider(width: 1, thickness: 1,
                      color: bdr, indent: 8, endIndent: 8),
                    _UnifiedStat(icon: LucideIcons.gem, value: '$diamonds',
                      label: l10n.profileDiamonds, color: const Color(0xFF6BA3D6), d: d),
                  ]),
                ),
              ),
            ),
          ),

          // ── Level hero (gradient ring + diamond wallet) ──────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
              child: GestureDetector(
                onTap: () => _showLevelsSheet(context, xp),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft, end: Alignment.bottomRight,
                      colors: d
                        ? [const Color(0xFF152A1D), const Color(0xFF0F1A14)]
                        : [const Color(0xFFF0F7F2), const Color(0xFFFFFFFF)]),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: accent.withValues(alpha: 0.15), width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: accent.withValues(alpha: d ? 0.12 : 0.08),
                        blurRadius: 20, offset: const Offset(0, 6)),
                      BoxShadow(
                        color: Colors.black.withValues(alpha: d ? 0.2 : 0.04),
                        blurRadius: 10, offset: const Offset(0, 3)),
                    ],
                  ),
                  child: Column(children: [
                    Row(children: [
                      SizedBox(
                        width: 80, height: 80,
                        child: CustomPaint(
                          painter: _LevelRingPainter(
                            progress: xp.levelProgress.clamp(0.0, 1.0),
                            trackColor: accent.withValues(alpha: d ? 0.12 : 0.10),
                            ringColor: accent,
                            glowColor: accent.withValues(alpha: 0.3),
                          ),
                          child: Center(
                            child: Text(PointsModel.levelEmojis[xp.level],
                              style: const TextStyle(fontSize: 30)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(children: [
                          Expanded(child: Text(
                            'Niveau ${xp.level}',
                            style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w800,
                              color: ink, letterSpacing: -0.3))),
                          // diamond wallet pill
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF60A5FA).withValues(alpha: d ? 0.15 : 0.10),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: const Color(0xFF60A5FA).withValues(alpha: 0.2)),
                            ),
                            child: Row(mainAxisSize: MainAxisSize.min, children: [
                              const Text('💎', style: TextStyle(fontSize: 12)),
                              const SizedBox(width: 4),
                              Text('$diamonds', style: GoogleFonts.outfit(
                                fontSize: 13, fontWeight: FontWeight.w800,
                                color: const Color(0xFF3B82F6))),
                            ]),
                          ),
                        ]),
                        const SizedBox(height: 2),
                        Text(PointsModel.levelTitles[xp.level],
                          style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500,
                            color: accent)),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(5),
                          child: LinearProgressIndicator(
                            value: xp.levelProgress.clamp(0.0, 1.0),
                            minHeight: 7,
                            backgroundColor: accent.withValues(alpha: d ? 0.12 : 0.10),
                            valueColor: AlwaysStoppedAnimation<Color>(accent)),
                        ),
                        const SizedBox(height: 6),
                        if (xp.pointsForNextLevel - xp.totalPoints > 0)
                          Text(
                            '${xp.totalPoints} / ${xp.pointsForNextLevel} pts',
                            style: GoogleFonts.inter(fontSize: 11, color: muted, fontWeight: FontWeight.w500),
                            maxLines: 1, overflow: TextOverflow.ellipsis)
                        else
                          Text('Niveau maximum atteint ✨',
                            style: GoogleFonts.inter(fontSize: 11, color: _P.sage, fontWeight: FontWeight.w600)),
                      ])),
                    ]),
                    // XP breakdown strip
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: (d ? Colors.white : Colors.black).withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(14)),
                      child: Row(children: [
                        _XpSource(icon: LucideIcons.dumbbell, label: 'Entraînements', color: const Color(0xFFE8734A), d: d),
                        Container(width: 1, height: 20, color: _P.border(d)),
                        _XpSource(icon: LucideIcons.flame, label: 'Séries', color: const Color(0xFFF59E0B), d: d),
                        Container(width: 1, height: 20, color: _P.border(d)),
                        _XpSource(icon: LucideIcons.userCheck, label: 'Profil', color: const Color(0xFF6BA3D6), d: d),
                      ]),
                    ),
                    const SizedBox(height: 8),
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Text('Voir tous les niveaux', style: GoogleFonts.inter(
                        fontSize: 11, fontWeight: FontWeight.w600, color: accent)),
                      const SizedBox(width: 4),
                      Icon(LucideIcons.chevronRight, size: 12, color: accent),
                    ]),
                  ]),
                ),
              ),
            ),
          ),

          // ── Weekly tracker (pill style) ──────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: surf,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: bdr, width: 0.5),
                  boxShadow: [BoxShadow(
                    color: Colors.black.withValues(alpha: d ? 0.18 : 0.04),
                    blurRadius: 12, offset: const Offset(0, 3))],
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Container(
                      width: 28, height: 28,
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(8)),
                      child: Icon(LucideIcons.calendarCheck, size: 14, color: accent)),
                    const SizedBox(width: 10),
                    Expanded(child: Text(l10n.profileWeeklyGoal,
                      style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w700,
                        color: ink), overflow: TextOverflow.ellipsis)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(12)),
                      child: Text('5/7',
                        style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w800,
                          color: accent)),
                    ),
                  ]),
                  const SizedBox(height: 16),
                  Row(children: List.generate(7, (i) {
                    final done = i < 5;
                    final today = i == 4;
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(right: i < 6 ? 6 : 0),
                        child: Column(children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            height: 38,
                            decoration: BoxDecoration(
                              color: done
                                  ? accent
                                  : (d ? const Color(0xFF1E2D23) : const Color(0xFFEDF1EE)),
                              borderRadius: BorderRadius.circular(12),
                              border: today && !done
                                  ? Border.all(color: accent, width: 2) : null),
                            child: Center(child: done
                              ? const Icon(Icons.check_rounded, color: Colors.white, size: 16)
                              : null),
                          ),
                          const SizedBox(height: 6),
                          Text(_days[i], textAlign: TextAlign.center,
                            style: GoogleFonts.inter(fontSize: 10,
                              fontWeight: done || today ? FontWeight.w700 : FontWeight.w500,
                              color: done ? accent : muted)),
                        ]),
                      ),
                    );
                  })),
                ]),
              ),
            ),
          ),

          // ── Subscription ────────────────────────────────────────────────
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 14, 20, 0),
              child: SubscriptionButton(),
            ),
          ),

          // ── Trophy case grid ──────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
              child: _TrophyCase(xp: xp, d: d, accent: accent),
            ),
          ),

          // ── Section: Préférences ────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _SectionHeader(icon: LucideIcons.settings, label: 'PRÉFÉRENCES',
                  color: _P.sage, d: d),
                const SizedBox(height: 10),
                groupedSection([
                  buildRow(
                    icon: LucideIcons.moon, label: l10n.darkMode,
                    trailing: buildToggle(isDarkMode,
                      () => ref.read(themeModeProvider.notifier).toggleThemeMode())),
                  buildRow(
                    icon: LucideIcons.palette, label: 'Thèmes',
                    onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const ThemeScreen())),
                    trailing: Consumer(builder: (_, ref2, __) {
                      final palette = ref2.watch(colorPaletteProvider);
                      return Row(mainAxisSize: MainAxisSize.min, children: [
                        Container(width: 16, height: 16,
                          decoration: BoxDecoration(
                            color: palette.primary, shape: BoxShape.circle,
                            border: Border.all(color: bdr, width: 1.5))),
                        const SizedBox(width: 6),
                        Icon(LucideIcons.chevronRight, size: 14,
                          color: muted.withValues(alpha: 0.5)),
                      ]);
                    })),
                  Consumer(builder: (_, ref2, __) {
                    final isFr = ref2.watch(localeProvider).languageCode == 'fr';
                    return buildRow(
                      icon: LucideIcons.globe,
                      label: isFr ? 'Langue' : 'Language',
                      onTap: () => ref2.read(localeProvider.notifier)
                          .setLocale(isFr ? const Locale('en') : const Locale('fr')),
                      trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                        Text(isFr ? 'Français' : 'English',
                          style: GoogleFonts.inter(fontSize: 13, color: muted)),
                        const SizedBox(width: 6),
                        Icon(LucideIcons.chevronRight, size: 14,
                          color: muted.withValues(alpha: 0.5)),
                      ]));
                  }),
                  buildRow(
                    icon: LucideIcons.bot, label: l10n.profileAiAssistant,
                    trailing: Consumer(builder: (_, ref2, __) {
                      final visible = ref2.watch(chatbotVisibilityProvider);
                      return buildToggle(visible, () {
                        final next = !visible;
                        ref2.read(chatbotVisibilityProvider.notifier).state = next;
                        StorageService.setChatbotVisible(next);
                      });
                    })),
                ]),
              ]),
            ),
          ),

          // ── Section: Activité ───────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _SectionHeader(icon: LucideIcons.activity, label: 'ACTIVITÉ',
                  color: const Color(0xFFE8734A), d: d),
                const SizedBox(height: 10),
                groupedSection([
                  buildRow(icon: LucideIcons.calendarDays, label: 'Historique',
                    onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const WorkoutHistoryScreen()))),
                  buildRow(icon: LucideIcons.bellRing,
                    label: l10n.isFrench ? 'Notifications' : 'Notifications',
                    onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const NotificationSettingsScreen()))),
                  Consumer(builder: (_, ref2, __) {
                    final isPro = ref2.watch(isProProvider);
                    return buildRow(
                      icon: LucideIcons.trendingUp,
                      label: l10n.isFrench ? 'Mes tendances' : 'My trends',
                      onTap: () {
                        if (isPro) {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const TrendsScreen()));
                        } else {
                          showPaywallSheet(context,
                            feature: l10n.isFrench ? 'Mes tendances' : 'My trends',
                            description: l10n.isFrench
                              ? 'Visualise tes calories, ton eau et ton humeur sur 14 jours.'
                              : 'Visualize your calories, water and mood over 14 days.');
                        }
                      },
                      trailing: isPro
                        ? Icon(LucideIcons.chevronRight, size: 15,
                            color: muted.withValues(alpha: 0.5))
                        : Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: _P.sage.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6)),
                            child: Text('PRO',
                              style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700,
                                color: _P.main, letterSpacing: 0.4))),
                    );
                  }),
                ]),
              ]),
            ),
          ),

          // ── Section: Données & confidentialité ──────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _SectionHeader(icon: LucideIcons.shield, label: 'DONNÉES',
                  color: const Color(0xFF6BA3D6), d: d),
                const SizedBox(height: 10),
                groupedSection([
                  buildRow(icon: LucideIcons.download,
                    label: l10n.isFrench ? 'Exporter mes données' : 'Export my data',
                    onTap: () => _exportData(context, ref)),
                ]),
              ]),
            ),
          ),

          // ── Danger zone ─────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _SectionHeader(icon: LucideIcons.userCog, label: 'COMPTE',
                  color: const Color(0xFFE53935), d: d),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    color: surf,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFE53935).withValues(alpha: 0.15)),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Column(children: [
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => _confirmDeleteAccount(context, ref),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          child: Row(children: [
                            Container(width: 32, height: 32,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE53935).withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(9)),
                              child: const Icon(LucideIcons.trash2, size: 15,
                                color: Color(0xFFE53935))),
                            const SizedBox(width: 12),
                            Expanded(child: Text(
                              l10n.isFrench ? 'Supprimer mon compte' : 'Delete my account',
                              style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500,
                                color: const Color(0xFFE53935)))),
                          ]),
                        ),
                      ),
                      Divider(height: 0.5, thickness: 0.5,
                        color: const Color(0xFFE53935).withValues(alpha: 0.1),
                        indent: 56, endIndent: 16),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => _confirmSignOut(context, ref),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          child: Row(children: [
                            Container(width: 32, height: 32,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE53935).withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(9)),
                              child: const Icon(LucideIcons.logOut, size: 15,
                                color: Color(0xFFE53935))),
                            const SizedBox(width: 12),
                            Expanded(child: Text('Se déconnecter',
                              style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500,
                                color: const Color(0xFFE53935)))),
                          ]),
                        ),
                      ),
                    ]),
                  ),
                ),
              ]),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 48)),
        ],
      ),
    );
  }

  Future<void> _exportData(BuildContext context, WidgetRef ref) async {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
    final data = await PrivacyService.exportUserData();
    final json = PrivacyService.exportUserDataAsJson(data);
    if (!context.mounted) return;
    Navigator.of(context, rootNavigator: true).pop(); // ferme le loader

    await Clipboard.setData(ClipboardData(text: json));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(ref.read(l10nProvider).isFrench
          ? 'Données copiées (format JSON) — colle-les où tu veux les garder.'
          : 'Data copied (JSON format) — paste it wherever you want to keep it.'),
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 4),
    ));
  }

  void _confirmDeleteAccount(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final l10n = ref.read(l10nProvider);
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: cs.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          l10n.isFrench ? 'Supprimer définitivement ton compte ?' : 'Permanently delete your account?',
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
        ),
        content: Text(
          l10n.isFrench
              ? 'Toutes tes données (profil, cycle, nutrition, symptômes, points, XP…) '
                'seront supprimées. Cette action est irréversible.'
              : 'All your data (profile, cycle, nutrition, symptoms, points, XP…) '
                'will be deleted. This action is irreversible.',
          style: TextStyle(fontSize: 14, color: cs.onSurface.withValues(alpha: 0.7)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.isFrench ? 'Annuler' : 'Cancel',
                style: TextStyle(color: cs.onSurface.withValues(alpha: 0.6))),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              showDialog<void>(
                context: context,
                barrierDismissible: false,
                builder: (_) => const Center(child: CircularProgressIndicator()),
              );
              await PrivacyService.deleteAllUserData();
              if (!context.mounted) return;
              Navigator.of(context, rootNavigator: true).pop(); // ferme le loader
              ref.read(onboardingProvider.notifier).reset();
              if (context.mounted) context.go('/onboarding');
            },
            child: Text(l10n.isFrench ? 'Supprimer définitivement' : 'Delete permanently',
                style: const TextStyle(
                    color: Color(0xFFE53935), fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  void _confirmSignOut(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: cs.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Se déconnecter ?',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
        content: Text(
          'Tu devras te reconnecter pour accéder à ton compte.',
          style: TextStyle(fontSize: 14, color: cs.onSurface.withValues(alpha: 0.7)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Annuler',
                style: TextStyle(color: cs.onSurface.withValues(alpha: 0.6))),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await AuthService.signOut();
              ref.read(onboardingProvider.notifier).reset();
              if (context.mounted) context.go('/onboarding');
            },
            child: const Text('Déconnecter',
                style: TextStyle(
                    color: Color(0xFFE53935), fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  void _showEditProfile(BuildContext context, WidgetRef ref, UserProfile profile, ColorScheme cs) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EditProfileSheet(profile: profile, ref: ref),
    );
  }
}

// ── Unified stat (inside single bar) ─────────────────────────────────────────
class _UnifiedStat extends StatelessWidget {
  final IconData icon;
  final String value, label;
  final Color color;
  final bool d;
  const _UnifiedStat({required this.icon, required this.value, required this.label,
    required this.color, required this.d});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(height: 6),
        Text(value, style: GoogleFonts.outfit(
          fontSize: 20, fontWeight: FontWeight.w800, color: _P.t1(d))),
        const SizedBox(height: 1),
        Text(label, style: GoogleFonts.inter(
          fontSize: 10, color: _P.t2(d), fontWeight: FontWeight.w500)),
      ]),
    );
  }
}

// ── Section header with colored icon ─────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool d;
  const _SectionHeader({required this.icon, required this.label,
    required this.color, required this.d});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(
        width: 24, height: 24,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(6)),
        child: Icon(icon, size: 12, color: color),
      ),
      const SizedBox(width: 8),
      Text(label, style: GoogleFonts.inter(
        fontSize: 11, fontWeight: FontWeight.w600,
        color: _P.t2(d), letterSpacing: 0.8)),
    ]);
  }
}

// ── XP source chip (inside breakdown strip) ─────────────────────────────────
class _XpSource extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool d;
  const _XpSource({required this.icon, required this.label, required this.color, required this.d});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 5),
        Flexible(
          child: Text(label, style: GoogleFonts.inter(
            fontSize: 10, fontWeight: FontWeight.w600, color: _P.t2(d)),
            maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
      ]),
    );
  }
}

// ── Level ring painter with glow ─────────────────────────────────────────────
class _LevelRingPainter extends CustomPainter {
  final double progress;
  final Color trackColor, ringColor, glowColor;
  _LevelRingPainter({required this.progress, required this.trackColor,
    required this.ringColor, required this.glowColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.shortestSide - 10) / 2;
    const stroke = 6.0;
    const start = -math.pi / 2;
    final sweep = 2 * math.pi * progress;

    final trackPaint = Paint()
      ..color = trackColor ..style = PaintingStyle.stroke
      ..strokeWidth = stroke ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, trackPaint);

    if (progress > 0) {
      final glowPaint = Paint()
        ..color = glowColor ..style = PaintingStyle.stroke
        ..strokeWidth = stroke + 6 ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      canvas.drawArc(Rect.fromCircle(center: center, radius: radius),
        start, sweep, false, glowPaint);

      final ringPaint = Paint()
        ..color = ringColor ..style = PaintingStyle.stroke
        ..strokeWidth = stroke ..strokeCap = StrokeCap.round;
      canvas.drawArc(Rect.fromCircle(center: center, radius: radius),
        start, sweep, false, ringPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _LevelRingPainter old) =>
      old.progress != progress || old.ringColor != ringColor;
}

// ── Trophy case grid ─────────────────────────────────────────────────────────
class _TrophyCase extends StatelessWidget {
  final PointsModel xp;
  final bool d;
  final Color accent;
  const _TrophyCase({required this.xp, required this.d, required this.accent});

  static const _badges = [
    ('🏋️', 'Premier entraînement', 1, 'workout'),
    ('🔥', 'Série de 7 jours', 7, 'streak'),
    ('👤', 'Profil complété', 1, 'profile'),
    ('⭐', '100 points', 100, 'points'),
    ('💎', 'Niveau 5', 5, 'level'),
    ('🏆', 'Niveau 10', 10, 'level'),
  ];

  static const _badgeColors = [
    Color(0xFFE8734A), Color(0xFFF59E0B), Color(0xFF6BA3D6),
    Color(0xFF22C55E), Color(0xFF60A5FA), Color(0xFFA855F7),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _P.card(d),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _P.border(d), width: 0.5),
        boxShadow: [BoxShadow(
          color: Colors.black.withValues(alpha: d ? 0.18 : 0.04),
          blurRadius: 12, offset: const Offset(0, 3))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 24, height: 24,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(6)),
            child: Icon(LucideIcons.trophy, size: 12, color: accent),
          ),
          const SizedBox(width: 8),
          Text('TROPHÉES', style: GoogleFonts.inter(
            fontSize: 11, fontWeight: FontWeight.w600,
            color: _P.t2(d), letterSpacing: 0.8)),
          const Spacer(),
          Text('${_badges.where((b) {
            final i = _badges.indexOf(b);
            return _isUnlocked(i, b.$3, b.$4);
          }).length}/${_badges.length}', style: GoogleFonts.outfit(
            fontSize: 12, fontWeight: FontWeight.w700, color: accent)),
        ]),
        const SizedBox(height: 14),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 0.85,
          children: List.generate(_badges.length, (i) {
            final (emoji, label, threshold, type) = _badges[i];
            final unlocked = _isUnlocked(i, threshold, type);
            final color = _badgeColors[i];
            return Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: unlocked
                    ? color.withValues(alpha: d ? 0.10 : 0.06)
                    : (d ? const Color(0xFF1A1A1A) : const Color(0xFFF5F5F5)),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: unlocked
                      ? color.withValues(alpha: 0.25)
                      : _P.border(d)),
                boxShadow: unlocked ? [BoxShadow(
                  color: color.withValues(alpha: 0.15),
                  blurRadius: 12, offset: const Offset(0, 3))] : [],
              ),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: unlocked ? 1.0 : 0.4,
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text(emoji, style: const TextStyle(fontSize: 28)),
                  const SizedBox(height: 6),
                  Text(label, style: GoogleFonts.inter(
                    fontSize: 9, fontWeight: FontWeight.w600,
                    color: unlocked ? _P.t1(d) : _P.t2(d),
                    height: 1.2),
                    textAlign: TextAlign.center,
                    maxLines: 2, overflow: TextOverflow.ellipsis),
                  if (!unlocked) ...[
                    const SizedBox(height: 4),
                    Icon(LucideIcons.lock, size: 10,
                      color: _P.t2(d).withValues(alpha: 0.5)),
                  ],
                ]),
              ),
            );
          }),
        ),
      ]),
    );
  }

  bool _isUnlocked(int i, int threshold, String type) {
    if (i < 3) return true;
    if (type == 'points') return xp.totalPoints >= threshold;
    if (type == 'level') return xp.level >= threshold;
    return false;
  }
}

// ─── Edit Profile Sheet ──────────────────────────────────────────────────────
class _EditProfileSheet extends StatefulWidget {
  final UserProfile profile;
  final WidgetRef ref;
  const _EditProfileSheet({required this.profile, required this.ref});

  @override
  State<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<_EditProfileSheet> {
  late TextEditingController _nameCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _heightCtrl;
  late TextEditingController _weightCtrl;
  late TextEditingController _ageCtrl;
  bool _saving = false;
  int  _focusIndex = -1;

  @override
  void initState() {
    super.initState();
    _nameCtrl   = TextEditingController(text: widget.profile.username);
    _emailCtrl  = TextEditingController(text: widget.profile.email);
    _heightCtrl = TextEditingController(text: '${widget.profile.heightCm}');
    _weightCtrl = TextEditingController(text: widget.profile.weightKg.toStringAsFixed(1));
    _ageCtrl    = TextEditingController(text: '${widget.profile.age}');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _heightCtrl.dispose();
    _weightCtrl.dispose();
    _ageCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving) return;
    final name   = _nameCtrl.text.trim();
    final height = int.tryParse(_heightCtrl.text);
    final weight = double.tryParse(_weightCtrl.text);
    final age    = int.tryParse(_ageCtrl.text);

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Le nom ne peut pas être vide.')));
      return;
    }
    if (height != null && (height < 100 || height > 250)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La taille doit être entre 100 et 250 cm.')));
      return;
    }
    if (weight != null && (weight < 30 || weight > 300)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Le poids doit être entre 30 et 300 kg.')));
      return;
    }
    if (age != null && (age < 13 || age > 100)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('L\'âge doit être entre 13 et 100 ans.')));
      return;
    }

    setState(() => _saving = true);
    final notifier = widget.ref.read(userProfileProvider.notifier);
    await notifier.updateField('username', name);
    await notifier.updateField('email', _emailCtrl.text.trim());
    await notifier.updateField('height_cm', height ?? widget.profile.heightCm);
    await notifier.updateField('weight_kg', weight ?? widget.profile.weightKg);
    await notifier.updateField('age', age ?? widget.profile.age);
    widget.ref.read(pointsProvider.notifier).rewardProfileCompleted();
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final dark  = Theme.of(context).brightness == Brightness.dark;
    final green = const Color(0xFF22C55E);
    final surf  = dark ? const Color(0xFF1A1A1A) : Colors.white;
    final ink   = dark ? const Color(0xFFF0F0EE) : const Color(0xFF111110);
    final muted = dark ? const Color(0xFF888886) : const Color(0xFF6B6B68);
    final div   = dark ? const Color(0xFF2A2A2A) : const Color(0xFFF0F0EE);
    final l10n  = widget.ref.read(l10nProvider);
    final mascot = widget.ref.read(mascotProvider);

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: surf,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 14, 24, 36),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            // ── Handle ──────────────────────────────────────────────────
            Center(child: Container(
              width: 36, height: 4,
              decoration: BoxDecoration(color: div,
                borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 20),

            // ── Avatar + Title row ───────────────────────────────────────
            Row(children: [
              Stack(children: [
                Container(
                  width: 56, height: 56,
                  decoration: BoxDecoration(
                    color: green.withValues(alpha: 0.10),
                    shape: BoxShape.circle,
                    border: Border.all(color: green.withValues(alpha: 0.25), width: 2)),
                  child: ClipOval(child: MascotWidget(
                    type: mascot.type, mood: mascot.mood, size: 52))),
                Positioned(right: 0, bottom: 0,
                  child: Container(
                    width: 20, height: 20,
                    decoration: BoxDecoration(
                      color: green, shape: BoxShape.circle,
                      border: Border.all(color: surf, width: 2)),
                    child: const Icon(Icons.edit_rounded,
                      size: 10, color: Colors.white))),
              ]),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.editProfileTitle,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800,
                      color: ink, letterSpacing: -0.4)),
                  const SizedBox(height: 2),
                  Text(l10n.editProfileSubtitle,
                    style: TextStyle(fontSize: 12, color: muted)),
                ])),
            ]),

            const SizedBox(height: 24),

            // ── Section: Informations ────────────────────────────────────
            _SectionLabel(label: l10n.editUsername.toUpperCase().split(' ').first == l10n.editUsername.toUpperCase()
                ? 'INFORMATIONS' : 'INFORMATIONS',
              color: muted),
            const SizedBox(height: 10),
            _EditCard(dark: dark, surf: surf, div: div, children: [
              _EditRow(
                icon: LucideIcons.user, label: l10n.editUsername,
                ctrl: _nameCtrl, keyboardType: TextInputType.name,
                green: green, ink: ink, muted: muted, focused: _focusIndex == 0,
                onFocus: (v) => setState(() => _focusIndex = v ? 0 : -1)),
              _Divider(color: div),
              _EditRow(
                icon: LucideIcons.mail, label: 'Email',
                ctrl: _emailCtrl, keyboardType: TextInputType.emailAddress,
                green: green, ink: ink, muted: muted, focused: _focusIndex == 1,
                onFocus: (v) => setState(() => _focusIndex = v ? 1 : -1)),
            ]),

            const SizedBox(height: 20),

            // ── Section: Physique ────────────────────────────────────────
            _SectionLabel(label: l10n.editPhysicalData.toUpperCase(), color: muted),
            const SizedBox(height: 10),
            _EditCard(dark: dark, surf: surf, div: div, children: [
              Row(children: [
                Expanded(child: _EditRow(
                  icon: LucideIcons.ruler, label: l10n.editHeight,
                  ctrl: _heightCtrl, keyboardType: TextInputType.number,
                  green: green, ink: ink, muted: muted, focused: _focusIndex == 2,
                  onFocus: (v) => setState(() => _focusIndex = v ? 2 : -1),
                  suffix: 'cm')),
                Container(width: 1, height: 56, color: div),
                Expanded(child: _EditRow(
                  icon: LucideIcons.scale, label: l10n.editWeight,
                  ctrl: _weightCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  green: green, ink: ink, muted: muted, focused: _focusIndex == 3,
                  onFocus: (v) => setState(() => _focusIndex = v ? 3 : -1),
                  suffix: 'kg')),
              ]),
              _Divider(color: div),
              _EditRow(
                icon: LucideIcons.cake, label: l10n.editAge,
                ctrl: _ageCtrl, keyboardType: TextInputType.number,
                green: green, ink: ink, muted: muted, focused: _focusIndex == 4,
                onFocus: (v) => setState(() => _focusIndex = v ? 4 : -1),
                suffix: 'ans'),
            ]),

            const SizedBox(height: 14),

            // ── Advanced button ──────────────────────────────────────────
            GestureDetector(
              onTap: () => showModalBottomSheet<void>(
                context: context, isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => _AdvancedEditSheet(
                  profile: widget.profile, ref: widget.ref)),
              child: Row(mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(LucideIcons.settings2, size: 13, color: muted),
                  const SizedBox(width: 6),
                  Text(l10n.editAdvanced,
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                      color: muted)),
                  const SizedBox(width: 3),
                  Icon(LucideIcons.chevronRight, size: 12, color: muted),
                ]),
            ),

            const SizedBox(height: 20),

            // ── Save button ──────────────────────────────────────────────
            GestureDetector(
              onTap: _saving ? null : _save,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: double.infinity,
                height: 52,
                decoration: BoxDecoration(
                  color: _saving ? green.withValues(alpha: 0.6) : green,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: _saving ? [] : [BoxShadow(
                    color: green.withValues(alpha: 0.28),
                    blurRadius: 12, offset: const Offset(0, 4))],
                ),
                child: Center(child: _saving
                  ? const SizedBox(width: 20, height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2.5))
                  : Text(l10n.editSave,
                      style: const TextStyle(fontSize: 15,
                        fontWeight: FontWeight.w800, color: Colors.white))),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

// ── Section label ─────────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String label;
  final Color  color;
  const _SectionLabel({required this.label, required this.color});
  @override
  Widget build(BuildContext context) => Text(label,
    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
      color: color, letterSpacing: 1.2));
}

// ── Grouped card ──────────────────────────────────────────────────────────────
class _EditCard extends StatelessWidget {
  final bool          dark;
  final Color         surf, div;
  final List<Widget>  children;
  const _EditCard({required this.dark, required this.surf,
    required this.div, required this.children});
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: surf,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: div, width: 1),
      boxShadow: [BoxShadow(
        color: Colors.black.withValues(alpha: dark ? 0.12 : 0.04),
        blurRadius: 8, offset: const Offset(0, 2))]),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Column(children: children)));
}

// ── Single row field ──────────────────────────────────────────────────────────
class _EditRow extends StatefulWidget {
  final IconData icon;
  final String   label;
  final TextEditingController ctrl;
  final TextInputType keyboardType;
  final Color    green, ink, muted;
  final bool     focused;
  final String?  suffix;
  final ValueChanged<bool> onFocus;
  const _EditRow({required this.icon, required this.label, required this.ctrl,
    required this.keyboardType, required this.green, required this.ink,
    required this.muted, required this.focused,
    required this.onFocus, this.suffix});

  @override
  State<_EditRow> createState() => _EditRowState();
}

class _EditRowState extends State<_EditRow> {
  late FocusNode _focus;
  @override
  void initState() {
    super.initState();
    _focus = FocusNode();
    _focus.addListener(() => widget.onFocus(_focus.hasFocus));
  }
  @override
  void dispose() { _focus.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final active = widget.focused;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 32, height: 32,
          decoration: BoxDecoration(
            color: active
                ? widget.green.withValues(alpha: 0.12)
                : widget.muted.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8)),
          child: Icon(widget.icon, size: 15,
            color: active ? widget.green : widget.muted)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min, children: [
          Text(widget.label,
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600,
              color: active ? widget.green : widget.muted, letterSpacing: 0.3)),
          const SizedBox(height: 2),
          Row(children: [
            Expanded(child: TextField(
              controller: widget.ctrl,
              focusNode: _focus,
              keyboardType: widget.keyboardType,
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600,
                color: widget.ink),
              cursorColor: widget.green,
              cursorWidth: 1.5,
              decoration: const InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.zero,
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none),
            )),
            if (widget.suffix != null) ...[
              const SizedBox(width: 4),
              Text(widget.suffix!,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500,
                  color: widget.muted)),
            ],
          ]),
        ])),
      ]),
    );
  }
}

// ── Thin divider ──────────────────────────────────────────────────────────────
class _Divider extends StatelessWidget {
  final Color color;
  const _Divider({required this.color});
  @override
  Widget build(BuildContext context) =>
      Divider(height: 1, thickness: 1, color: color, indent: 16, endIndent: 16);
}

// ─── Advanced Edit Sheet ─────────────────────────────────────────────────────
class _AdvancedEditSheet extends StatefulWidget {
  final UserProfile profile;
  final WidgetRef ref;
  const _AdvancedEditSheet({required this.profile, required this.ref});

  @override
  State<_AdvancedEditSheet> createState() => _AdvancedEditSheetState();
}

class _AdvancedEditSheetState extends State<_AdvancedEditSheet> {
  // ── Training
  late List<String> _goals;
  late String? _fitnessLevel;
  late String? _frequency;
  late String? _trainingLocation;
  late List<String> _equipment;
  // ── Health
  late String? _healthStatus;
  late String? _cycleDuration;
  late String? _ppRecovery;
  late String? _ppDuration;
  late int? _pregnancyWeek;

  bool _saving = false;

  // ── Option lists (matching onboarding)
  static const _goalOptions = [
    'Perte de poids',
    'Maintien',
    'Prise de masse',
  ];
  static const _goalLabels = [
    '🔥 Perdre du poids',
    '⚖️ Maintenir le poids',
    '💪 Prendre du poids / muscle',
  ];
  static const _levelOptions   = ['Débutant', 'Intermédiaire', 'Avancé'];
  static const _freqOptions    = ['2 jours', '3 jours', '4 jours', '5 jours', '6 jours'];
  static const _locOptions     = ['gym', 'home', 'both'];
  static const _locLabels      = ['Salle de sport', 'Maison', 'Mixte'];
  static const _equipOptions   = ['Aucun matériel', 'Haltères', 'Barre & poids', 'Machines', 'Résistances', 'Tapis de yoga'];
  static const _cycleOptions   = ['24 jours', '26 jours', '28 jours', '30 jours', '32 jours'];
  static const _ppRecovOptions = ['recent', 'slowly', 'active'];
  static const _ppRecovLabels  = ['Récente', 'Progressive', 'Active'];
  static const _ppDurOptions   = ['0-2', '2-6', '6-12', '3-6m', '6m+'];

  @override
  void initState() {
    super.initState();
    final p = widget.profile;
    _goals           = List<String>.from(p.goals);
    _fitnessLevel    = p.fitnessLevel;
    _frequency       = p.frequency;
    _trainingLocation = p.healthStatus; // misnamed — stored separately below
    _equipment       = List<String>.from(
        StorageService.getOnboardingData()['equipment'] != null
            ? List<String>.from(StorageService.getOnboardingData()['equipment'] as List)
            : []);
    _trainingLocation = StorageService.getOnboardingData()['training_location'] as String?;
    _healthStatus    = p.healthStatus;
    _cycleDuration   = p.cycleDuration;
    _ppRecovery      = p.ppRecovery;
    _ppDuration      = p.ppDuration;
    _pregnancyWeek   = p.pregnancyWeekSA;
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);
    final n = widget.ref.read(userProfileProvider.notifier);
    await n.updateField('goals',             _goals);
    await n.updateField('fitness_level',     _fitnessLevel);
    await n.updateField('frequency',         _frequency);
    await n.updateField('training_location', _trainingLocation);
    await n.updateField('equipment',         _equipment);
    await n.updateField('health_status',     _healthStatus);
    await n.updateField('cycle_duration',    _cycleDuration);
    await n.updateField('pp_recovery',       _ppRecovery);
    await n.updateField('pp_duration',       _ppDuration);
    await n.updateField('pregnancy_week',    _pregnancyWeek);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final dark  = Theme.of(context).brightness == Brightness.dark;
    final green = const Color(0xFF22C55E);
    final surf  = dark ? const Color(0xFF1A1A1A) : Colors.white;
    final ink   = dark ? const Color(0xFFF0F0EE) : const Color(0xFF111110);
    final muted = dark ? const Color(0xFF888886) : const Color(0xFF6B6B68);
    final div   = dark ? const Color(0xFF2A2A2A) : const Color(0xFFF0F0EE);

    return Container(
      decoration: BoxDecoration(
        color: surf,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.90,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, scrollCtrl) => ListView(
          controller: scrollCtrl,
          padding: const EdgeInsets.fromLTRB(24, 14, 24, 36),
          children: [
            // ── Handle ──────────────────────────────────────────────────
            Center(child: Container(
              width: 36, height: 4,
              decoration: BoxDecoration(color: div,
                borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 20),

            // ── Header ──────────────────────────────────────────────────
            Row(children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: green.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(12)),
                child: Icon(LucideIcons.settings2, size: 18, color: green)),
              const SizedBox(width: 12),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Édition avancée',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800,
                    color: ink, letterSpacing: -0.4)),
                Text('Objectifs, entraînement & santé',
                  style: TextStyle(fontSize: 12, color: muted)),
              ]),
            ]),
            const SizedBox(height: 24),

            // ── Objectifs ────────────────────────────────────────────────
            _SectionLabel(label: 'OBJECTIF', color: muted),
            const SizedBox(height: 10),
            _AdvCard(dark: dark, surf: surf, div: div,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Wrap(spacing: 8, runSpacing: 8,
                  children: List.generate(_goalOptions.length, (i) {
                    final g   = _goalOptions[i];
                    final sel = _goals.contains(g);
                    return _AdvChip(
                      label: _goalLabels[i], selected: sel, green: green,
                      ink: ink, muted: muted, div: div,
                      // Choix unique — l'objectif pilote directement le calcul
                      // des calories, un seul peut être actif à la fois.
                      onTap: () => setState(() {
                        _goals.removeWhere((x) => _goalOptions.contains(x));
                        if (!sel) _goals.add(g);
                      }));
                  }).toList()),
              )),

            const SizedBox(height: 16),

            // ── Fitness & Fréquence ──────────────────────────────────────
            _SectionLabel(label: 'ENTRAÎNEMENT', color: muted),
            const SizedBox(height: 10),
            _AdvCard(dark: dark, surf: surf, div: div,
              child: Column(children: [
                _AdvSection(
                  icon: LucideIcons.barChart2, label: 'Niveau de fitness',
                  green: green, ink: ink, muted: muted,
                  child: Wrap(spacing: 8, runSpacing: 8,
                    children: _levelOptions.map((l) => _AdvChip(
                      label: l, selected: _fitnessLevel == l,
                      green: green, ink: ink, muted: muted, div: div,
                      onTap: () => setState(() => _fitnessLevel = l),
                    )).toList())),
                Divider(height: 1, color: div, indent: 16, endIndent: 16),
                _AdvSection(
                  icon: LucideIcons.calendarDays, label: 'Fréquence',
                  green: green, ink: ink, muted: muted,
                  child: Wrap(spacing: 8, runSpacing: 8,
                    children: _freqOptions.map((f) => _AdvChip(
                      label: f, selected: _frequency == f,
                      green: green, ink: ink, muted: muted, div: div,
                      onTap: () => setState(() => _frequency = f),
                    )).toList())),
                Divider(height: 1, color: div, indent: 16, endIndent: 16),
                _AdvSection(
                  icon: LucideIcons.mapPin, label: 'Lieu',
                  green: green, ink: ink, muted: muted,
                  child: Wrap(spacing: 8, runSpacing: 8,
                    children: List.generate(_locOptions.length, (i) => _AdvChip(
                      label: _locLabels[i],
                      selected: _trainingLocation == _locOptions[i],
                      green: green, ink: ink, muted: muted, div: div,
                      onTap: () => setState(() => _trainingLocation = _locOptions[i]),
                    )))),
                Divider(height: 1, color: div, indent: 16, endIndent: 16),
                _AdvSection(
                  icon: LucideIcons.dumbbell, label: 'Équipement',
                  green: green, ink: ink, muted: muted,
                  child: Wrap(spacing: 8, runSpacing: 8,
                    children: _equipOptions.map((e) {
                      final sel = _equipment.contains(e);
                      return _AdvChip(
                        label: e, selected: sel,
                        green: green, ink: ink, muted: muted, div: div,
                        onTap: () => setState(() =>
                          sel ? _equipment.remove(e) : _equipment.add(e)));
                    }).toList())),
              ])),

            const SizedBox(height: 16),

            // ── Santé ────────────────────────────────────────────────────
            _SectionLabel(label: 'PROFIL DE SANTÉ', color: muted),
            const SizedBox(height: 10),
            _AdvCard(dark: dark, surf: surf, div: div,
              child: Column(children: [
                ...[
                  ('cycle',      'Cycle menstruel', LucideIcons.moon),
                  ('pregnant',   'Enceinte',        LucideIcons.baby),
                  ('postpartum', 'Post-partum',     LucideIcons.heart),
                ].asMap().entries.map((e) {
                  final idx   = e.key;
                  final item  = e.value;
                  final sel   = _healthStatus == item.$1;
                  final last  = idx == 2;
                  return Column(children: [
                    GestureDetector(
                      onTap: () => setState(() =>
                        _healthStatus = sel ? null : item.$1),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                        child: Row(children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            width: 34, height: 34,
                            decoration: BoxDecoration(
                              color: sel
                                ? green.withValues(alpha: 0.12)
                                : muted.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(10)),
                            child: Icon(item.$3, size: 16,
                              color: sel ? green : muted)),
                          const SizedBox(width: 12),
                          Expanded(child: Text(item.$2,
                            style: TextStyle(fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: sel ? green : ink))),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            width: 20, height: 20,
                            decoration: BoxDecoration(
                              color: sel ? green : Colors.transparent,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: sel ? green : div, width: 1.5)),
                            child: sel
                              ? const Icon(Icons.check_rounded,
                                  size: 12, color: Colors.white)
                              : null),
                        ]),
                      ),
                    ),
                    if (!last) Divider(height: 1, color: div,
                      indent: 16, endIndent: 16),
                  ]);
                }),
              ])),

            // ── Conditional: Cycle ───────────────────────────────────────
            if (_healthStatus == 'cycle') ...[
              const SizedBox(height: 12),
              _SectionLabel(label: 'DURÉE DU CYCLE', color: muted),
              const SizedBox(height: 10),
              _AdvCard(dark: dark, surf: surf, div: div,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Wrap(spacing: 8, runSpacing: 8,
                    children: _cycleOptions.map((d) => _AdvChip(
                      label: d, selected: _cycleDuration == d,
                      green: green, ink: ink, muted: muted, div: div,
                      onTap: () => setState(() => _cycleDuration = d),
                    )).toList()))),
            ],

            // ── Conditional: Pregnant ────────────────────────────────────
            if (_healthStatus == 'pregnant') ...[
              const SizedBox(height: 12),
              _SectionLabel(label: 'SEMAINE DE GROSSESSE', color: muted),
              const SizedBox(height: 10),
              _AdvCard(dark: dark, surf: surf, div: div,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 20),
                  child: Row(children: [
                    _StepBtn(
                      icon: LucideIcons.minus, green: green, div: div,
                      onTap: () => setState(() =>
                        _pregnancyWeek = ((_pregnancyWeek ?? 12) - 1).clamp(1, 42))),
                    Expanded(child: Center(child: Column(children: [
                      Text('${_pregnancyWeek ?? 12}',
                        style: TextStyle(fontSize: 32,
                          fontWeight: FontWeight.w900, color: green)),
                      Text('semaines d\'aménorrhée',
                        style: TextStyle(fontSize: 11, color: muted)),
                    ]))),
                    _StepBtn(
                      icon: LucideIcons.plus, green: green, div: div,
                      onTap: () => setState(() =>
                        _pregnancyWeek = ((_pregnancyWeek ?? 12) + 1).clamp(1, 42))),
                  ]))),
            ],

            // ── Conditional: Postpartum ──────────────────────────────────
            if (_healthStatus == 'postpartum') ...[
              const SizedBox(height: 12),
              _SectionLabel(label: 'RÉCUPÉRATION', color: muted),
              const SizedBox(height: 10),
              _AdvCard(dark: dark, surf: surf, div: div,
                child: Column(children: [
                  _AdvSection(
                    icon: LucideIcons.activity, label: 'Type de récupération',
                    green: green, ink: ink, muted: muted,
                    child: Wrap(spacing: 8, runSpacing: 8,
                      children: List.generate(_ppRecovOptions.length, (i) =>
                        _AdvChip(
                          label: _ppRecovLabels[i],
                          selected: _ppRecovery == _ppRecovOptions[i],
                          green: green, ink: ink, muted: muted, div: div,
                          onTap: () => setState(
                            () => _ppRecovery = _ppRecovOptions[i]))))),
                  Divider(height: 1, color: div, indent: 16, endIndent: 16),
                  _AdvSection(
                    icon: LucideIcons.clock3, label: 'Durée post-partum',
                    green: green, ink: ink, muted: muted,
                    child: Wrap(spacing: 8, runSpacing: 8,
                      children: _ppDurOptions.map((d) => _AdvChip(
                        label: d, selected: _ppDuration == d,
                        green: green, ink: ink, muted: muted, div: div,
                        onTap: () => setState(() => _ppDuration = d),
                      )).toList())),
                ])),
            ],

            const SizedBox(height: 24),

            // ── Save ─────────────────────────────────────────────────────
            GestureDetector(
              onTap: _saving ? null : _save,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: double.infinity, height: 52,
                decoration: BoxDecoration(
                  color: _saving ? green.withValues(alpha: 0.6) : green,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: _saving ? [] : [BoxShadow(
                    color: green.withValues(alpha: 0.28),
                    blurRadius: 12, offset: const Offset(0, 4))]),
                child: Center(child: _saving
                  ? const SizedBox(width: 20, height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2.5))
                  : const Text('Enregistrer',
                      style: TextStyle(fontSize: 15,
                        fontWeight: FontWeight.w800, color: Colors.white))),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Helpers for the advanced sheet ────────────────────────────────────────────

class _AdvCard extends StatelessWidget {
  final bool dark;
  final Color surf, div;
  final Widget child;
  const _AdvCard({required this.dark, required this.surf,
    required this.div, required this.child});
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: surf,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: div, width: 1),
      boxShadow: [BoxShadow(
        color: Colors.black.withValues(alpha: dark ? 0.12 : 0.04),
        blurRadius: 8, offset: const Offset(0, 2))]),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: child));
}

class _AdvSection extends StatelessWidget {
  final IconData icon;
  final String   label;
  final Color    green, ink, muted;
  final Widget   child;
  const _AdvSection({required this.icon, required this.label,
    required this.green, required this.ink, required this.muted,
    required this.child});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(16),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Container(
          width: 28, height: 28,
          decoration: BoxDecoration(
            color: green.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, size: 13, color: green)),
        const SizedBox(width: 10),
        Text(label, style: TextStyle(fontSize: 13,
          fontWeight: FontWeight.w700, color: ink)),
      ]),
      const SizedBox(height: 12),
      child,
    ]));
}

class _AdvChip extends StatelessWidget {
  final String   label;
  final bool     selected;
  final Color    green, ink, muted, div;
  final VoidCallback onTap;
  const _AdvChip({required this.label, required this.selected,
    required this.green, required this.ink, required this.muted,
    required this.div, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: selected ? green.withValues(alpha: 0.10) : div,
        borderRadius: BorderRadius.circular(50),
        border: Border.all(
          color: selected ? green.withValues(alpha: 0.4) : Colors.transparent,
          width: 1.2)),
      child: Text(label, style: TextStyle(fontSize: 12,
        fontWeight: FontWeight.w600,
        color: selected ? green : muted))));
}

class _StepBtn extends StatelessWidget {
  final IconData icon;
  final Color    green, div;
  final VoidCallback onTap;
  const _StepBtn({required this.icon, required this.green,
    required this.div, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 40, height: 40,
      decoration: BoxDecoration(
        color: div, borderRadius: BorderRadius.circular(12)),
      child: Icon(icon, size: 18, color: green)));
}

// ── Bottom sheet : niveaux & récompenses (timeline style) ───────────────────
class _LevelsSheet extends StatelessWidget {
  final PointsModel xp;
  const _LevelsSheet({required this.xp});

  @override
  Widget build(BuildContext context) {
    final d     = Theme.of(context).brightness == Brightness.dark;
    final bg    = _P.bg(d);
    final ink   = _P.t1(d);
    final muted = _P.t2(d);
    final accent = _P.accent(d);

    return DraggableScrollableSheet(
      initialChildSize: 0.78,
      minChildSize: 0.45,
      maxChildSize: 0.92,
      builder: (_, ctrl) => Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(children: [
          const SizedBox(height: 12),
          Container(width: 40, height: 4,
            decoration: BoxDecoration(
              color: ink.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(2))),

          // gradient trophy banner
          Container(
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft, end: Alignment.bottomRight,
                colors: d
                  ? [const Color(0xFF152A1D), const Color(0xFF0F1A14)]
                  : [const Color(0xFFEEF6F0), const Color(0xFFFFFFFF)]),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: accent.withValues(alpha: 0.15)),
              boxShadow: [BoxShadow(
                color: accent.withValues(alpha: d ? 0.12 : 0.06),
                blurRadius: 16, offset: const Offset(0, 4))],
            ),
            child: Row(children: [
              SizedBox(
                width: 64, height: 64,
                child: CustomPaint(
                  painter: _LevelRingPainter(
                    progress: xp.levelProgress.clamp(0.0, 1.0),
                    trackColor: accent.withValues(alpha: 0.12),
                    ringColor: accent,
                    glowColor: accent.withValues(alpha: 0.3)),
                  child: Center(
                    child: Text(PointsModel.levelEmojis[xp.level],
                      style: const TextStyle(fontSize: 26))),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Niveaux & Récompenses', style: GoogleFonts.outfit(
                  fontSize: 17, fontWeight: FontWeight.w800, color: ink, letterSpacing: -0.3)),
                const SizedBox(height: 3),
                Text('Niveau ${xp.level} · ${xp.totalPoints} pts', style: GoogleFonts.inter(
                  fontSize: 12, fontWeight: FontWeight.w600, color: accent)),
                const SizedBox(height: 2),
                Text('Gagne des points, passe des niveaux, reçois des 💎',
                  style: GoogleFonts.inter(fontSize: 10.5, color: muted)),
              ])),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: ink.withValues(alpha: 0.08),
                    shape: BoxShape.circle),
                  child: Icon(LucideIcons.x, size: 16,
                    color: ink.withValues(alpha: 0.55)),
                ),
              ),
            ]),
          ),

          const SizedBox(height: 12),
          // timeline list
          Expanded(
            child: ListView.builder(
              controller: ctrl,
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
              itemCount: PointsModel.maxLevel,
              itemBuilder: (_, i) {
                final level     = i + 1;
                final threshold = PointsModel.thresholdForLevel(level);
                final lvlDiamonds = PointsModel.diamondsForLevel(level);
                final isCurrent = level == xp.level;
                final isDone    = level < xp.level;
                final isLocked  = level > xp.level;
                final isLast    = level == PointsModel.maxLevel;

                return IntrinsicHeight(
                  child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                    // timeline connector
                    SizedBox(
                      width: 32,
                      child: Column(children: [
                        if (i > 0)
                          Expanded(child: Container(width: 2,
                            color: isDone || isCurrent
                                ? accent.withValues(alpha: 0.4)
                                : _P.border(d))),
                        Container(
                          width: isCurrent ? 18 : 12, height: isCurrent ? 18 : 12,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isDone ? accent
                                : isCurrent ? accent
                                : _P.border(d),
                            border: isCurrent ? Border.all(
                              color: accent.withValues(alpha: 0.3), width: 3) : null,
                            boxShadow: isCurrent ? [BoxShadow(
                              color: accent.withValues(alpha: 0.3),
                              blurRadius: 8)] : [],
                          ),
                          child: isDone
                              ? const Icon(LucideIcons.check, size: 8, color: Colors.white)
                              : null,
                        ),
                        if (!isLast)
                          Expanded(child: Container(width: 2,
                            color: isDone
                                ? accent.withValues(alpha: 0.4)
                                : _P.border(d))),
                      ]),
                    ),
                    const SizedBox(width: 10),
                    // card
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: EdgeInsets.all(isCurrent ? 16 : 12),
                        decoration: BoxDecoration(
                          color: isCurrent
                              ? accent.withValues(alpha: d ? 0.10 : 0.06)
                              : _P.card(d),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isCurrent
                                ? accent.withValues(alpha: 0.3)
                                : _P.border(d), width: isCurrent ? 1.5 : 0.5),
                          boxShadow: isCurrent ? [BoxShadow(
                            color: accent.withValues(alpha: d ? 0.12 : 0.06),
                            blurRadius: 12, offset: const Offset(0, 3))] : [],
                        ),
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 200),
                          opacity: isLocked ? 0.55 : 1.0,
                          child: Row(children: [
                            Container(
                              width: isCurrent ? 48 : 40,
                              height: isCurrent ? 48 : 40,
                              decoration: BoxDecoration(
                                color: (isDone || isCurrent ? accent : muted)
                                    .withValues(alpha: 0.10),
                                borderRadius: BorderRadius.circular(12)),
                              child: Center(
                                child: Text(PointsModel.levelEmojis[level],
                                  style: TextStyle(fontSize: isCurrent ? 24 : 18))),
                            ),
                            const SizedBox(width: 12),
                            Expanded(child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(children: [
                                  Flexible(child: Text(
                                    PointsModel.levelTitles[level],
                                    maxLines: 1, overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.outfit(
                                      fontSize: isCurrent ? 15 : 13,
                                      fontWeight: FontWeight.w700,
                                      color: isLocked ? ink.withValues(alpha: 0.45) : ink))),
                                  if (isCurrent) ...[
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: accent,
                                        borderRadius: BorderRadius.circular(20)),
                                      child: Text('LV.${xp.level}',
                                        style: GoogleFonts.outfit(fontSize: 9,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white, letterSpacing: 0.3)),
                                    ),
                                  ],
                                ]),
                                const SizedBox(height: 2),
                                Text(level == 1 ? 'Départ' : 'dès $threshold pts',
                                  style: GoogleFonts.inter(fontSize: 10.5, color: muted)),
                                if (isCurrent) ...[
                                  const SizedBox(height: 8),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: xp.levelProgress.clamp(0.0, 1.0),
                                      minHeight: 5,
                                      backgroundColor: accent.withValues(alpha: 0.15),
                                      valueColor: AlwaysStoppedAnimation<Color>(accent)),
                                  ),
                                  const SizedBox(height: 4),
                                  Text('${xp.totalPoints} / ${xp.pointsForNextLevel} pts',
                                    style: GoogleFonts.inter(fontSize: 10, color: muted,
                                      fontWeight: FontWeight.w500)),
                                ],
                              ],
                            )),
                            const SizedBox(width: 8),
                            if (lvlDiamonds > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF60A5FA)
                                      .withValues(alpha: isLocked ? 0.06 : 0.12),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: const Color(0xFF60A5FA)
                                      .withValues(alpha: isLocked ? 0.1 : 0.2))),
                                child: Text('+$lvlDiamonds 💎',
                                  style: GoogleFonts.outfit(fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF3B82F6)
                                        .withValues(alpha: isLocked ? 0.5 : 1))),
                              )
                            else if (isDone)
                              Icon(LucideIcons.checkCircle, size: 16, color: accent)
                            else if (isLocked)
                              Icon(LucideIcons.lock, size: 13,
                                color: ink.withValues(alpha: 0.2)),
                          ]),
                        ),
                      ),
                    ),
                  ]),
                );
              },
            ),
          ),
        ]),
      ),
    );
  }
}
