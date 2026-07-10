import 'package:fiteva/providers/points_provider.dart';
import 'package:fiteva/providers/xp_provider.dart';
import 'package:fiteva/providers/locale_provider.dart';
import 'package:fiteva/services/auth_service.dart';
import 'package:fiteva/services/storage_service.dart';
import 'package:fiteva/services/local_reminder_service.dart';
import 'package:fiteva/services/privacy_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../providers/user_profile_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/mascot_provider.dart';
import '../../providers/onboarding_provider.dart';
import '../../providers/subscription_provider.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/mascot_widget.dart';
import '../../widgets/paywall_sheet.dart';
import 'stripe_integration.dart';
import 'theme_screen.dart';
import 'trends_screen.dart';

const _days = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];

final expandBadgesProvider  = StateProvider<bool>((ref) => false);
final chatbotVisibilityProvider = StateProvider<bool>(
  (ref) => StorageService.getChatbotVisible(),
);
final remindersEnabledProvider = StateProvider<bool>(
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
      ref.read(xpProvider.notifier).reload();
      ref.read(pointsProvider.notifier).loadPoints();
    });
  }

  @override
  Widget build(BuildContext context) {
    final user       = ref.watch(userProfileProvider);
    final profile    = ref.watch(userProfileProvider);
    final isDarkMode = ref.watch(themeModeProvider) == ThemeMode.dark;
    final cs         = Theme.of(context).colorScheme;
    final l10n       = ref.watch(l10nProvider);
    final points     = ref.watch(pointsProvider);
    final xp         = ref.watch(xpProvider);
    final mascot     = ref.watch(mascotProvider);

    final displayName = profile.username.isNotEmpty ? profile.username : user.username;
    final displayEmail = profile.email.isNotEmpty ? profile.email : '';

    final bg     = isDarkMode ? const Color(0xFF0D0D0D) : const Color(0xFFF6F7F5);
    final ink    = isDarkMode ? const Color(0xFFF0F0EE) : const Color(0xFF111110);
    final muted  = isDarkMode ? const Color(0xFF888886) : const Color(0xFF6B6B68);
    final surf   = isDarkMode ? const Color(0xFF1A1A1A) : Colors.white;
    final green  = const Color(0xFF22C55E);

    return Scaffold(
      backgroundColor: bg,
      body: CustomScrollView(
        slivers: [
          // ── Header ──────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => context.go('/'),
                      child: Container(
                        width: 38, height: 38,
                        decoration: BoxDecoration(
                          color: surf,
                          shape: BoxShape.circle,
                          boxShadow: [BoxShadow(
                            color: Colors.black.withValues(alpha: isDarkMode ? 0.3 : 0.06),
                            blurRadius: 8, offset: const Offset(0, 2))],
                        ),
                        child: Icon(LucideIcons.chevronLeft, size: 20, color: ink),
                      ),
                    ),
                    Text(l10n.profileTitle,
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800,
                        color: ink, letterSpacing: -0.5)),
                    GestureDetector(
                      onTap: () => _showEditProfile(context, ref, profile, cs),
                      child: Container(
                        width: 38, height: 38,
                        decoration: BoxDecoration(
                          color: surf,
                          shape: BoxShape.circle,
                          boxShadow: [BoxShadow(
                            color: Colors.black.withValues(alpha: isDarkMode ? 0.3 : 0.06),
                            blurRadius: 8, offset: const Offset(0, 2))],
                        ),
                        child: Icon(LucideIcons.settings, size: 18, color: muted),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Avatar hero ─────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: Column(
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 100, height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDarkMode ? const Color(0xFF1E2A1E) : const Color(0xFFE8F5E9),
                          boxShadow: [BoxShadow(
                            color: green.withValues(alpha: 0.25),
                            blurRadius: 20, spreadRadius: 2)],
                        ),
                        child: ClipOval(
                          child: MascotWidget(
                            type: mascot.type,
                            mood: mascot.mood,
                            size: 100,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0, right: 0,
                        child: GestureDetector(
                          onTap: () => context.push('/edit-avatar'),
                          child: Container(
                            width: 28, height: 28,
                            decoration: BoxDecoration(
                              color: green, shape: BoxShape.circle,
                              border: Border.all(color: bg, width: 2.5),
                              boxShadow: [BoxShadow(
                                color: green.withValues(alpha: 0.4),
                                blurRadius: 6, offset: const Offset(0, 2))],
                            ),
                            child: const Icon(LucideIcons.edit3, size: 12, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(displayName.isNotEmpty ? displayName : l10n.profileUser,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800,
                            color: ink, letterSpacing: -0.4)),
                      ),
                      Consumer(builder: (_, ref2, __) {
                        if (!ref2.watch(isProProvider)) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(left: 6),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(LucideIcons.crown, size: 11, color: Color(0xFFF59E0B)),
                                SizedBox(width: 3),
                                Text('PRO', style: TextStyle(fontSize: 10,
                                    fontWeight: FontWeight.w800, color: Color(0xFFF59E0B),
                                    letterSpacing: 0.4)),
                              ],
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                  if (displayEmail.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(displayEmail,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 13, color: muted)),
                  ],
                 
              
                ],
              ),
            ),
          ),

          // ── Stats chips ─────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: LayoutBuilder(
                builder: (_, constraints) {
                  final itemWidth = (constraints.maxWidth - 20) / 3;
                  return Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      SizedBox(
                        width: itemWidth,
                        child: _StatChip(
                          icon: LucideIcons.flame,
                          value: '${xp.streak}',
                          label: l10n.profileStreak,
                          color: const Color(0xFFFF6B35),
                          bg: surf, ink: ink, muted: muted,
                        ),
                      ),
                      SizedBox(
                        width: itemWidth,
                        child: _StatChip(
                          icon: LucideIcons.dumbbell,
                          value: '48',
                          label: l10n.profileSessions,
                          color: const Color(0xFF6366F1),
                          bg: surf, ink: ink, muted: muted,
                        ),
                      ),
                      SizedBox(
                        width: itemWidth,
                        child: _StatChip(
                          icon: LucideIcons.star,
                          value: '$points',
                          label: 'pts',
                          color: const Color(0xFFF59E0B),
                          bg: surf, ink: ink, muted: muted,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),

          // ── XP bar ──────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: surf,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(
                    color: Colors.black.withValues(alpha: isDarkMode ? 0.2 : 0.04),
                    blurRadius: 8, offset: const Offset(0, 2))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Level ${xp.level}',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
                            color: green)),
                        Text('${xp.totalXp} / ${xp.xpForNextLevel} XP',
                          style: TextStyle(fontSize: 12, color: muted)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: xp.levelProgress.clamp(0.0, 1.0),
                        minHeight: 6,
                        backgroundColor: isDarkMode
                            ? const Color(0xFF2A2A2A) : const Color(0xFFE8F5E9),
                        valueColor: AlwaysStoppedAnimation<Color>(green),
                      ),
                    ),
                    if (xp.xpForNextLevel - xp.totalXp > 0) ...[
                      const SizedBox(height: 6),
                      Text(l10n.profileXpToNext(xp.xpForNextLevel - xp.totalXp),
                        style: TextStyle(fontSize: 11, color: muted)),
                    ],
                  ],
                ),
              ),
            ),
          ),

          // ── Abonnement (Stripe) ─────────────────────────────────────────
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: SubscriptionButton(),
            ),
          ),

          // ── Weekly tracker ──────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: surf,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(
                    color: Colors.black.withValues(alpha: isDarkMode ? 0.2 : 0.04),
                    blurRadius: 8, offset: const Offset(0, 2))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            l10n.profileWeeklyGoal,
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: ink),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            l10n.profileWeeklyDays(5),
                            textAlign: TextAlign.right,
                            style: TextStyle(fontSize: 12, color: muted),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    LayoutBuilder(
                      builder: (_, constraints) {
                        final itemWidth = constraints.maxWidth / 7;
                        return Row(
                          children: List.generate(7, (i) {
                            final done = i < 5;
                            final today = i == 4;
                            return SizedBox(
                              width: itemWidth,
                              child: Column(
                                children: [
                                  LayoutBuilder(builder: (_, c) {
                                    final size = (c.maxWidth * 0.72).clamp(24.0, 38.0);
                                    return AnimatedContainer(
                                      duration: const Duration(milliseconds: 300),
                                      width: size,
                                      height: size,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: done
                                            ? green
                                            : (isDarkMode ? const Color(0xFF2A2A2A) : const Color(0xFFF0F0EE)),
                                        border: today ? Border.all(color: green, width: 2.5) : null,
                                        boxShadow: done ? [BoxShadow(
                                          color: green.withValues(alpha: 0.3),
                                          blurRadius: 6, offset: const Offset(0, 2))] : [],
                                      ),
                                      child: Center(
                                        child: done
                                            ? Icon(Icons.check_rounded, color: Colors.white,
                                                size: size * 0.4)
                                            : null,
                                      ),
                                    );
                                  }),
                                  const SizedBox(height: 5),
                                  Text(_days[i],
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600,
                                      color: done ? green : muted)),
                                ],
                              ),
                            );
                          }),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Dark mode toggle ────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: _SettingsTile(
                icon: LucideIcons.moon,
                label: l10n.darkMode,
                color: const Color(0xFF6366F1),
                surf: surf, ink: ink, muted: muted, isDark: isDarkMode,
                trailing: GestureDetector(
                  onTap: () => ref.read(themeModeProvider.notifier).toggleThemeMode(),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 42, height: 24,
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? const Color(0xFF22C55E)
                          : const Color(0xFFD0D0CE),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: AnimatedAlign(
                      duration: const Duration(milliseconds: 200),
                      alignment: isDarkMode ? Alignment.centerRight : Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: Container(
                          width: 20, height: 20,
                          decoration: const BoxDecoration(
                            color: Colors.white, shape: BoxShape.circle),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Themes ───────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: GestureDetector(
                onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const ThemeScreen())),
                child: _SettingsTile(
                  icon: LucideIcons.palette,
                  label: 'Thèmes',
                  color: const Color(0xFFE91E63),
                  surf: surf, ink: ink, muted: muted, isDark: isDarkMode,
                  trailing: Consumer(builder: (_, ref2, __) {
                    final palette = ref2.watch(colorPaletteProvider);
                    return Row(mainAxisSize: MainAxisSize.min, children: [
                      Container(
                        width: 18, height: 18,
                        decoration: BoxDecoration(
                          color: palette.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(LucideIcons.chevronRight, size: 14,
                        color: cs.onSurface.withValues(alpha: 0.3)),
                    ]);
                  }),
                ),
              ),
            ),
          ),

          // ── Language toggle ─────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Consumer(builder: (_, ref2, __) {
                final isFr = ref2.watch(localeProvider).languageCode == 'fr';
                return _SettingsTile(
                  icon: LucideIcons.globe,
                  label: isFr ? 'Langue : Français' : 'Language: English',
                  color: const Color(0xFF0EA5E9),
                  surf: surf, ink: ink, muted: muted, isDark: isDarkMode,
                  trailing: GestureDetector(
                    onTap: () => ref2.read(localeProvider.notifier)
                        .setLocale(isFr ? const Locale('en') : const Locale('fr')),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0EA5E9).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFF0EA5E9).withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        isFr ? 'FR → EN' : 'EN → FR',
                        style: TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w700,
                          color: const Color(0xFF0EA5E9)),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),

          // ── AI Assistant toggle ─────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: _SettingsTile(
                icon: LucideIcons.bot,
                label: l10n.profileAiAssistant,
                color: const Color(0xFF5B5FEF),
                surf: surf, ink: ink, muted: muted, isDark: isDarkMode,
                trailing: Consumer(builder: (_, ref2, __) {
                  final visible = ref2.watch(chatbotVisibilityProvider);
                  return GestureDetector(
                    onTap: () {
                      final next = !visible;
                      ref2.read(chatbotVisibilityProvider.notifier).state = next;
                      StorageService.setChatbotVisible(next);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 42, height: 24,
                      decoration: BoxDecoration(
                        color: visible ? green : (isDarkMode ? const Color(0xFF2A2A2A) : const Color(0xFFD0D0CE)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: AnimatedAlign(
                        duration: const Duration(milliseconds: 200),
                        alignment: visible ? Alignment.centerRight : Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          child: Container(
                            width: 20, height: 20,
                            decoration: const BoxDecoration(
                              color: Colors.white, shape: BoxShape.circle),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),

          // ── Rappels quotidiens (eau, repas, séance) ────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: _SettingsTile(
                icon: LucideIcons.bellRing,
                label: l10n.isFrench ? 'Rappels quotidiens' : 'Daily reminders',
                color: const Color(0xFFF4A940),
                surf: surf, ink: ink, muted: muted, isDark: isDarkMode,
                trailing: Consumer(builder: (_, ref2, __) {
                  final enabled = ref2.watch(remindersEnabledProvider);
                  return GestureDetector(
                    onTap: () async {
                      final next = !enabled;
                      if (next) {
                        final granted = await LocalReminderService.requestPermission();
                        if (!granted) return; // permission refusée : on ne change pas l'état
                      }
                      await LocalReminderService.setEnabled(next);
                      ref2.read(remindersEnabledProvider.notifier).state = next;
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 42, height: 24,
                      decoration: BoxDecoration(
                        color: enabled ? green : (isDarkMode ? const Color(0xFF2A2A2A) : const Color(0xFFD0D0CE)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: AnimatedAlign(
                        duration: const Duration(milliseconds: 200),
                        alignment: enabled ? Alignment.centerRight : Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          child: Container(
                            width: 20, height: 20,
                            decoration: const BoxDecoration(
                              color: Colors.white, shape: BoxShape.circle),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),

          // ── Tendances / analytics (Pro) ─────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Consumer(builder: (_, ref2, __) {
                final isPro = ref2.watch(isProProvider);
                return GestureDetector(
                  onTap: () {
                    if (isPro) {
                      Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const TrendsScreen()));
                    } else {
                      showPaywallSheet(
                        context,
                        feature: l10n.isFrench ? 'Mes tendances' : 'My trends',
                        description: l10n.isFrench
                            ? 'Visualise tes calories, ton eau et ton humeur sur 14 jours.'
                            : 'Visualize your calories, water and mood over 14 days.',
                      );
                    }
                  },
                  child: _SettingsTile(
                    icon: LucideIcons.trendingUp,
                    label: l10n.isFrench ? 'Mes tendances' : 'My trends',
                    color: const Color(0xFF22C55E),
                    surf: surf, ink: ink, muted: muted, isDark: isDarkMode,
                    trailing: isPro
                        ? Icon(LucideIcons.chevronRight, size: 16, color: muted)
                        : const Icon(LucideIcons.crown, size: 16, color: Color(0xFFF4A940)),
                  ),
                );
              }),
            ),
          ),

          // ── Confidentialité (RGPD) ─────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: GestureDetector(
                onTap: () => _exportData(context, ref),
                child: _SettingsTile(
                  icon: LucideIcons.download,
                  label: l10n.isFrench ? 'Exporter mes données' : 'Export my data',
                  color: const Color(0xFF3B7FD4),
                  surf: surf, ink: ink, muted: muted, isDark: isDarkMode,
                  trailing: Icon(LucideIcons.chevronRight, size: 16, color: muted),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: GestureDetector(
                onTap: () => _confirmDeleteAccount(context, ref),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? const Color(0xFF1E0A0A)
                        : const Color(0xFFFFF0F0),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFE53935).withValues(alpha: 0.30),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(LucideIcons.trash2,
                          color: Color(0xFFE53935), size: 18),
                      const SizedBox(width: 10),
                      Text(
                        l10n.isFrench ? 'Supprimer mon compte' : 'Delete my account',
                        style: const TextStyle(
                          color: Color(0xFFE53935),
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Déconnexion ──────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: GestureDetector(
                onTap: () => _confirmSignOut(context, ref),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? const Color(0xFF1E0A0A)
                        : const Color(0xFFFFF0F0),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFE53935).withValues(alpha: 0.30),
                      width: 1,
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(LucideIcons.logOut,
                          color: Color(0xFFE53935), size: 18),
                      SizedBox(width: 10),
                      Text(
                        'Se déconnecter',
                        style: TextStyle(
                          color: Color(0xFFE53935),
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Bottom padding ───────────────────────────────────────────────
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
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

// ── Stat chip ────────────────────────────────────────────────────────────────
class _StatChip extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final Color bg, ink, muted;
  const _StatChip({required this.icon, required this.value, required this.label,
    required this.color, required this.bg, required this.ink, required this.muted});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 6, offset: const Offset(0, 2))],
        ),
        child: Column(
          children: [
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 15, color: color),
            ),
            const SizedBox(height: 6),
            Text(value, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: ink)),
            Text(label, style: TextStyle(fontSize: 10, color: muted, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

// ── Settings tile (for AI toggle standalone card) ────────────────────────────
class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget trailing;
  final Color color, surf, ink, muted;
  final bool isDark;
  const _SettingsTile({required this.icon, required this.label, required this.trailing,
    required this.color, required this.surf, required this.ink, required this.muted,
    required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: surf,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(
          color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
          blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            width: 34, height: 34,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(label,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: ink))),
          trailing,
        ],
      ),
    );
  }
}

// ── Settings row (inside grouped card) ───────────────────────────────────────
class _SettingsRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget trailing;
  final Color color, ink, muted;
  final bool isFirst, isLast, isDark;
  final VoidCallback? onTap;
  const _SettingsRow({required this.icon, required this.label, required this.trailing,
    required this.color, required this.ink, required this.muted,
    required this.isFirst, required this.isLast, required this.isDark, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 34, height: 34,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 16, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(label,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: ink))),
            trailing,
          ],
        ),
      ),
    );
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
    widget.ref.read(xpProvider.notifier).rewardProfileCompleted();
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

class _Field extends StatelessWidget {
  final String label;
  final TextEditingController ctrl;
  final IconData icon;
  final ColorScheme cs;
  final TextInputType keyboardType;
  const _Field({required this.label, required this.ctrl, required this.icon,
      required this.cs, required this.keyboardType});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: ctrl,
      keyboardType: keyboardType,
      style: TextStyle(fontSize: 15, color: cs.onSurface, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(fontSize: 13, color: cs.onSurface.withValues(alpha: 0.55)),
        prefixIcon: Icon(icon, size: 18, color: cs.primary.withValues(alpha: 0.7)),
        filled: true,
        fillColor: cs.surfaceContainerHighest.withValues(alpha: 0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: cs.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: cs.outline.withValues(alpha: 0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: cs.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
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

// ── Legacy helpers kept for _StepperBtn references ────────────────────────────
class _SectionTitle extends StatelessWidget {
  final String label;
  final IconData icon;
  final ColorScheme cs;
  const _SectionTitle({required this.label, required this.icon, required this.cs});

  @override
  Widget build(BuildContext context) => Row(children: [
    Container(
      width: 28, height: 28,
      decoration: BoxDecoration(
        color: cs.primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, size: 14, color: cs.primary),
    ),
    const SizedBox(width: 10),
    Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: cs.onSurface)),
  ]);
}

class _Chip extends StatelessWidget {
  final String label;
  final bool selected;
  final ColorScheme cs;
  const _Chip({required this.label, required this.selected, required this.cs});

  @override
  Widget build(BuildContext context) => AnimatedContainer(
    duration: const Duration(milliseconds: 160),
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
    decoration: BoxDecoration(
      color: selected ? cs.primary : cs.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(50),
      border: Border.all(color: selected ? cs.primary : cs.outline),
    ),
    child: Text(label, style: TextStyle(
      fontSize: 12, fontWeight: FontWeight.w600,
      color: selected ? cs.onPrimary : cs.onSurface.withValues(alpha: 0.7),
    )),
  );
}

class _CsDivider extends StatelessWidget {
  final ColorScheme cs;
  const _CsDivider({required this.cs});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 20),
    child: Divider(color: cs.outlineVariant.withValues(alpha: 0.5), height: 1),
  );
}

class _StepperBtn extends StatelessWidget {
  final IconData icon;
  final ColorScheme cs;
  const _StepperBtn({required this.icon, required this.cs});

  @override
  Widget build(BuildContext context) => Container(
    width: 42, height: 42,
    decoration: BoxDecoration(
      color: cs.primary.withValues(alpha: 0.10),
      shape: BoxShape.circle,
      border: Border.all(color: cs.primary.withValues(alpha: 0.25)),
    ),
    child: Icon(icon, size: 18, color: cs.primary),
  );
}
