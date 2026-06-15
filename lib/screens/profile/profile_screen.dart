import 'package:fiteva/providers/onboarding_provider.dart';
import 'package:fiteva/providers/points_provider.dart';
import 'package:fiteva/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:dice_bear/dice_bear.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../providers/mock_data_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/locale_provider.dart';
import '../../l10n/app_localizations.dart';

// ─── DiceBear avatar state ──────────────────────────────────────────────────
// Replaces the old avatarProvider counter — now we store actual avatar params.
final avatarSeedProvider    = StateProvider<String>((ref) => 'sarah');
final avatarStyleProvider   = StateProvider<String>((ref) => 'lorelei');
final avatarBgColorProvider = StateProvider<String>((ref) => 'b6e3f4');

String _buildDiceBearUrl(String seed, String styleName, String bgColor) {
  final style = DiceBearStyle.values.firstWhere(
    (s) => s.name == styleName,
    orElse: () => DiceBearStyle.lorelei,
  );
  return DiceBearRequest(
    style: style,
    format: DiceBearFormat.svg,
    coreOptions: DiceBearCoreOptions(
      seed: seed,
      backgroundColor: [bgColor],
      radius: 50,
    ),
  ).uri.toString();
}

// ─── ProfileScreen ──────────────────────────────────────────────────────────
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user       = ref.watch(userProvider);
    final isDarkMode = ref.watch(themeModeProvider) == ThemeMode.dark;
    final theme      = Theme.of(context);
    final cs         = theme.colorScheme;
    final textSub    = theme.textTheme.bodyMedium?.color
        ?? cs.onSurface.withOpacity(0.55);

    final seed      = ref.watch(avatarSeedProvider);
    final styleName = ref.watch(avatarStyleProvider);
    final bgColor   = ref.watch(avatarBgColorProvider);
    final avatarUrl = _buildDiceBearUrl(seed, styleName, bgColor);
        final points = ref.watch(pointsProvider);

    return Scaffold(
      backgroundColor: cs.background,
      appBar: AppBar(
        backgroundColor: cs.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        title: Text(
          'Profil',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
            color: cs.onSurface,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: Icon(LucideIcons.settings, size: 18, color: textSub),
              onPressed: () {},
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),

            // ── Hero card ──
            _buildHeroCard(context, ref, user, avatarUrl, cs, theme, textSub, seed, styleName),
            const SizedBox(height: 14),

            // ── 3 stat cards ──
            _buildStatsRow(context, user, cs, theme,points),
            const SizedBox(height: 14),

            // ── Weekly tracker ──
            _buildWeeklyProgress(context, cs, theme, textSub),
            const SizedBox(height: 20),

            // ── Badges ──
            _buildBadgesSection(context, cs, theme, textSub),
            const SizedBox(height: 20),

            // ── Settings ──
            _buildSettingsSection(context, ref, isDarkMode, cs, theme, textSub),
            const SizedBox(height: 36),
          ],
        ),
      ),
    );
  }

  // ─── Hero Card ─────────────────────────────────────────────────────────────
  Widget _buildHeroCard(
    BuildContext context,
    WidgetRef ref,
    dynamic user,
    String avatarUrl,
    ColorScheme cs,
    ThemeData theme,
    Color textSub,
    String seed,
    String styleName,
  ) {
    const int xp     = 2340;
    const int xpGoal = 3000;
    const double progress = xp / xpGoal;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            cs.primary.withOpacity(0.10),
            cs.secondaryContainer.withOpacity(0.45),
          ],
        ),
        border: Border.all(color: cs.primary.withOpacity(0.14), width: 1),
        boxShadow: [
          BoxShadow(
            color: cs.primary.withOpacity(0.07),
            blurRadius: 28,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Avatar + edit button ──
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 92,
                height: 92,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: cs.primary.withOpacity(0.30),
                    width: 2.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: cs.primary.withOpacity(0.20),
                      blurRadius: 22,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: ClipOval(
                  child: SvgPicture.network(
                    avatarUrl,
                    width: 92,
                    height: 92,
                    fit: BoxFit.cover,
                    placeholderBuilder: (_) => Container(
                      color: cs.surfaceContainerHighest,
                      child: Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: cs.primary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () async {
                    final result = await context
                        .push<Map<String, dynamic>>('/edit-avatar');
                    if (result != null) {
                      ref.read(avatarSeedProvider.notifier).state =
                          result['seed'] as String? ?? seed;
                      ref.read(avatarStyleProvider.notifier).state =
                          result['sprite'] as String? ?? styleName;
                    }
                  },
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: cs.primary,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: cs.background,
                        width: 2.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: cs.primary.withOpacity(0.35),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(LucideIcons.edit3, size: 13, color: cs.onPrimary),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // ── Name ──
          Text(
            user.name,
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'sarah.martin@icloud.com',
            style: TextStyle(fontSize: 13, color: textSub),
          ),

          const SizedBox(height: 12),

          // ── Level pill ──
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: cs.primary,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(LucideIcons.star, size: 12, color: cs.onPrimary),
                const SizedBox(width: 5),
                Text(
                  'Niveau ${user.level} · Élite',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: cs.onPrimary,
                    letterSpacing: 0.1,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // ── XP progress bar ──
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Progression XP',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: textSub,
                    ),
                  ),
                  Text(
                    '$xp / $xpGoal XP',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: cs.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 9,
                  backgroundColor: cs.outlineVariant.withOpacity(0.35),
                  valueColor: AlwaysStoppedAnimation<Color>(cs.primary),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${xpGoal - xp} XP avant le prochain niveau',
                style: TextStyle(fontSize: 11, color: textSub),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Stats Row ─────────────────────────────────────────────────────────────
  Widget _buildStatsRow(
    BuildContext context,
    dynamic user,
    ColorScheme cs,
    ThemeData theme, int points,
  ) {
    final textSub = theme.textTheme.bodyMedium?.color
        ?? cs.onSurface.withOpacity(0.55);


    Widget statCard({
      required String value,
      required String label,
      required IconData icon,
      required Color color,
    }) {

      return Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: cs.shadow.withOpacity(0.07),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.13),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(icon, color: color, size: 19),
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: cs.onSurface,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: textSub,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Row(
      children: [
       statCard(
  value: '$points',
  label: 'XP Total',
  icon: LucideIcons.star,
  color: cs.primary,
),
        const SizedBox(width: 10),
        statCard(
          value: '${user.streak}j',
          label: 'Streak',
          icon: LucideIcons.flame,
          color: const Color(0xFFFF6B35),
        ),
        const SizedBox(width: 10),
        statCard(
          value: '48',
          label: 'Séances',
          icon: LucideIcons.calendar,
          color: const Color(0xFF007AFF),
        ),
      ],
    );
  }

  // ─── Weekly Progress ───────────────────────────────────────────────────────
  Widget _buildWeeklyProgress(
    BuildContext context,
    ColorScheme cs,
    ThemeData theme,
    Color textSub,
  ) {
    const days      = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];
    const completed = [true, true, true, true, true, false, false];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withOpacity(0.07),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Objectif hebdomadaire',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '5 jours complétés cette semaine',
                    style: TextStyle(fontSize: 12, color: textSub),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: cs.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '5 / 7',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: cs.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (i) {
              final done = completed[i];
              return Column(
                children: [
                  AnimatedContainer(
                    duration: Duration(milliseconds: 300 + i * 50),
                    curve: Curves.easeOutBack,
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: done ? cs.primary : cs.surfaceContainerHighest,
                      shape: BoxShape.circle,
                      boxShadow: done
                          ? [
                              BoxShadow(
                                color: cs.primary.withOpacity(0.30),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ]
                          : [],
                    ),
                    child: Icon(
                      done ? LucideIcons.check : LucideIcons.minus,
                      size: 14,
                      color: done ? cs.onPrimary : cs.outlineVariant,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    days[i],
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: done ? FontWeight.w700 : FontWeight.w400,
                      color: done ? cs.primary : textSub,
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  // ─── Badges Section ────────────────────────────────────────────────────────
  Widget _buildBadgesSection(
    BuildContext context,
    ColorScheme cs,
    ThemeData theme,
    Color textSub,
  ) {
    final badges = [
      _BadgeData(
        icon: LucideIcons.flame,
        label: '14 jours',
        color: const Color(0xFFFF6B35),
        earned: true,
      ),
      _BadgeData(
        icon: LucideIcons.trophy,
        label: 'Top 10%',
        color: cs.primary,
        earned: true,
      ),
      _BadgeData(
        icon: LucideIcons.zap,
        label: '50 séances',
        color: const Color(0xFF5B5FEF),
        earned: true,
      ),
      _BadgeData(
        icon: LucideIcons.medal,
        label: 'Marathon',
        color: textSub,
        earned: false,
      ),
      _BadgeData(
        icon: LucideIcons.flag,
        label: 'Pionnier',
        color: textSub,
        earned: false,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Badges',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: cs.onSurface,
              ),
            ),
            Text(
              'Voir tout',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: cs.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: badges.map((b) {
            return Opacity(
              opacity: b.earned ? 1.0 : 0.32,
              child: Column(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: b.earned
                          ? b.color.withOpacity(0.13)
                          : cs.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: b.earned
                            ? b.color.withOpacity(0.30)
                            : cs.outlineVariant,
                        width: 1.5,
                      ),
                      boxShadow: b.earned
                          ? [
                              BoxShadow(
                                color: b.color.withOpacity(0.22),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : [],
                    ),
                    child: Icon(b.icon, color: b.color, size: 24),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    b.label,
                    style: TextStyle(
                      fontSize: 10,
                      color: textSub,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ─── Settings Section ──────────────────────────────────────────────────────
  Widget _buildSettingsSection(
    BuildContext context,
    WidgetRef ref,
    bool isDarkMode,
    ColorScheme cs,
    ThemeData theme,
    Color textSub,
  ) {
    final l10n     = ref.watch(l10nProvider);
    final isFrench = ref.watch(localeProvider).languageCode == 'fr';

    final items = [
      _SettingsItemData(
        icon: LucideIcons.bell,
        title: l10n.notifications,
        iconColor: cs.primary,
        onTap: () {},
      ),
      _SettingsItemData(
        icon: isDarkMode ? LucideIcons.sunMedium : LucideIcons.moon,
        title: l10n.darkMode,
        iconColor: const Color(0xFF8A6FE8),
        trailing: isDarkMode ? l10n.darkModeOn : l10n.darkModeOff,
        trailingWidget: Switch.adaptive(
          value: isDarkMode,
          onChanged: (_) =>
              ref.read(themeModeProvider.notifier).toggleThemeMode(),
        ),
        onTap: () => ref.read(themeModeProvider.notifier).toggleThemeMode(),
      ),
      _SettingsItemData(
        icon: LucideIcons.heart,
        title: l10n.connectedHealth,
        iconColor: const Color(0xFFFF6B35),
        onTap: () {},
      ),
      _SettingsItemData(
        icon: LucideIcons.globe,
        title: l10n.language,
        iconColor: const Color(0xFF007AFF),
        trailing: isFrench ? l10n.langFrench : l10n.langEnglish,
        onTap: () => _showLanguagePicker(context, ref, l10n, cs, isFrench),
      ),
      _SettingsItemData(
        icon: LucideIcons.lock,
        title: l10n.privacy,
        iconColor: textSub,
        onTap: () {},
      ),
      _SettingsItemData(
        icon: LucideIcons.share2,
        title: l10n.shareApp,
        iconColor: textSub,
        onTap: () {},
      ),
      _SettingsItemData(
        icon: LucideIcons.helpCircle,
        title: l10n.helpFaq,
        iconColor: textSub,
        onTap: () {},
      ),
      _SettingsItemData(
        icon: LucideIcons.info,
        title: l10n.about,
        iconColor: textSub,
        trailing: 'v2.4.1',
        onTap: () {},
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.settings,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: cs.onSurface,
          ),
        ),
        const SizedBox(height: 12),

        // Settings card
        Container(
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: cs.shadow.withOpacity(0.07),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: List.generate(items.length, (i) {
              final item   = items[i];
              final isLast = i == items.length - 1;
              return Column(
                children: [
                  _buildSettingsRow(context, item, cs, textSub, isFirst: i == 0, isLast: isLast),
                  if (!isLast)
                    Divider(
                      height: 0.5,
                      indent: 60,
                      color: cs.outlineVariant.withOpacity(0.45),
                    ),
                ],
              );
            }),
          ),
        ),

        const SizedBox(height: 16),

        // Logout button
        SizedBox(
          width: double.infinity,
          height: 52,
          child: OutlinedButton.icon(
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  title: Text(l10n.logoutConfirm,
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                  content: Text(
                    l10n.logoutMessage,
                    style: const TextStyle(fontSize: 13, height: 1.55,
                        color: Color(0xFF666666))),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: Text(l10n.cancel,
                        style: const TextStyle(color: Color(0xFF888888)))),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: cs.error,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => Navigator.pop(ctx, true),
                      child: Text(l10n.confirm,
                        style: const TextStyle(fontWeight: FontWeight.w700))),
                  ],
                ),
              );
              if (confirm != true || !context.mounted) return;
              await StorageService.clearAll();
              ref.read(onboardingProvider.notifier).reset();
            },
            icon: const Icon(LucideIcons.logOut, size: 18),
            label: Text(
              l10n.logout,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: cs.error,
              side: BorderSide(color: cs.error.withOpacity(0.35)),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              backgroundColor: cs.error.withOpacity(0.05),
            ),
          ),
        ),
      ],
    );
  }

  void _showLanguagePicker(
    BuildContext context,
    WidgetRef ref,
    AppL10n l10n,
    ColorScheme cs,
    bool isFrench,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: cs.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                width: 38, height: 4,
                decoration: BoxDecoration(
                  color: cs.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                l10n.chooseLanguage,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              _LangOption(
                label: 'Français',
                flag: '🇫🇷',
                isSelected: isFrench,
                cs: cs,
                onTap: () {
                  ref.read(localeProvider.notifier).setLocale(const Locale('fr'));
                  Navigator.pop(ctx);
                },
              ),
              const SizedBox(height: 10),
              _LangOption(
                label: 'English',
                flag: '🇬🇧',
                isSelected: !isFrench,
                cs: cs,
                onTap: () {
                  ref.read(localeProvider.notifier).setLocale(const Locale('en'));
                  Navigator.pop(ctx);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSettingsRow(
    BuildContext context,
    _SettingsItemData item,
    ColorScheme cs,
    Color textSub, {
    bool isFirst = false,
    bool isLast  = false,
  }) {
    return InkWell(
      onTap: item.onTap,
      borderRadius: BorderRadius.vertical(
        top:    isFirst ? const Radius.circular(20) : Radius.zero,
        bottom: isLast  ? const Radius.circular(20) : Radius.zero,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(
          children: [
            // Coloured icon box
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: item.iconColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(item.icon, color: item.iconColor, size: 17),
            ),
            const SizedBox(width: 14),

            // Title
            Expanded(
              child: Text(
                item.title,
                style: TextStyle(
                  fontSize: 15,
                  color: cs.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            // Trailing text or widget
            if (item.trailingWidget != null) ...[
              item.trailingWidget!,
            ] else ...[
              if (item.trailing != null) ...[
                Text(
                  item.trailing!,
                  style: TextStyle(fontSize: 13, color: textSub),
                ),
                const SizedBox(width: 4),
              ],
              Icon(LucideIcons.chevronRight,
                  color: cs.outlineVariant, size: 16),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Data models ─────────────────────────────────────────────────────────────
class _BadgeData {
  final IconData icon;
  final String   label;
  final Color    color;
  final bool     earned;

  const _BadgeData({
    required this.icon,
    required this.label,
    required this.color,
    required this.earned,
  });
}

class _SettingsItemData {
  final IconData      icon;
  final String        title;
  final Color         iconColor;
  final String?       trailing;
  final Widget?       trailingWidget;
  final VoidCallback  onTap;

  const _SettingsItemData({
    required this.icon,
    required this.title,
    required this.iconColor,
    this.trailing,
    this.trailingWidget,
    required this.onTap,
  });
}

class _LangOption extends StatelessWidget {
  final String label;
  final String flag;
  final bool isSelected;
  final ColorScheme cs;
  final VoidCallback onTap;

  const _LangOption({
    required this.label,
    required this.flag,
    required this.isSelected,
    required this.cs,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? cs.primary.withOpacity(0.10) : cs.surfaceContainerHighest.withOpacity(0.4),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? cs.primary : cs.outlineVariant.withOpacity(0.5),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface,
                ),
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle_rounded, color: cs.primary, size: 22),
          ],
        ),
      ),
    );
  }
}