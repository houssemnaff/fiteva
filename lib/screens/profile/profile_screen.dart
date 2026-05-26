import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:fluttermoji/fluttermoji.dart';
import '../../providers/mock_data_provider.dart';
import '../../providers/theme_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final isDarkMode = ref.watch(themeModeProvider) == ThemeMode.dark;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final surface = colorScheme.surface;
    final background = colorScheme.background;
    final textPrimary = colorScheme.onSurface;
    final textSecondary = theme.textTheme.bodyMedium?.color ?? colorScheme.onSurface.withOpacity(0.72);
    final borderColor = colorScheme.outlineVariant;

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: surface,
        elevation: 0,
        centerTitle: false,
        title: Text(
          'Profile',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
            color: textPrimary,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: Icon(LucideIcons.settings, size: 18, color: textSecondary),
              onPressed: () {},
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),

            // ── Avatar + identity ──
            Center(
              child: Column(
                children: [
                  Stack(
                    children: [
                      Consumer(
                        builder: (context, ref, child) {
                          ref.watch(avatarProvider);
                          return FluttermojiCircleAvatar(
                            radius: 44,
                            backgroundColor: colorScheme.surfaceContainerHighest,
                          );
                        },
                      ),
                      Positioned(
                        bottom: 2,
                        right: 2,
                        child: GestureDetector(
                          onTap: () async {
                            await context.push('/edit-avatar');
                            ref.read(avatarProvider.notifier).increment();
                          },
                          child: Container(
                            width: 26,
                            height: 26,
                            decoration: BoxDecoration(
                              color: colorScheme.primary,
                              shape: BoxShape.circle,
                              border: Border.all(color: background, width: 2),
                            ),
                            child: Icon(LucideIcons.edit3, size: 12, color: colorScheme.onPrimary),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user.name,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: textPrimary,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'sarah.martin@icloud.com',
                    style: TextStyle(fontSize: 14, color: textSecondary),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                    decoration: BoxDecoration(
                      color: colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(LucideIcons.star, size: 13, color: colorScheme.primary),
                        const SizedBox(width: 6),
                        Text(
                          'Level ${user.level} · Elite',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── 3 stat cards ──
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    label: 'XP total',
                    value: '${user.xp}',
                    icon: LucideIcons.star,
                    iconColor: colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildStatCard(
                    context,
                    label: 'Streak',
                    value: '${user.streak}',
                    icon: LucideIcons.flame,
                    iconColor: const Color(0xFFFF6B35),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildStatCard(
                    context,
                    label: 'Séances',
                    value: '48',
                    icon: LucideIcons.calendar,
                    iconColor: const Color(0xFF007AFF),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ── Weekly progress ──
            _buildWeeklyProgress(context),
            const SizedBox(height: 20),

            // ── Badges ──
            _buildBadgesSection(context),
            const SizedBox(height: 20),

            // ── Settings ──
            _buildSettingsSection(context, ref, isDarkMode),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // ── Stat card ──
  Widget _buildStatCard(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
    required Color iconColor,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final surface = colorScheme.surface;
    final textPrimary = colorScheme.onSurface;
    final textSecondary = theme.textTheme.bodyMedium?.color ?? colorScheme.onSurface.withOpacity(0.72);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 22),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(fontSize: 11, color: textSecondary, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  // ── Weekly progress ──
  Widget _buildWeeklyProgress(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final surface = colorScheme.surface;
    final textPrimary = colorScheme.onSurface;
    final textSecondary = theme.textTheme.bodyMedium?.color ?? colorScheme.onSurface.withOpacity(0.72);

    const days = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
    const completed = [true, true, true, true, true, false, false];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.08),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Objectif hebdo',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textPrimary),
              ),
              Text(
                '5/6 jours',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: colorScheme.primary),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: List.generate(7, (i) {
              return Expanded(
                child: Container(
                  margin: EdgeInsets.only(right: i < 6 ? 6 : 0),
                  height: 8,
                  decoration: BoxDecoration(
                    color: completed[i] ? colorScheme.primary : colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 6),
          Row(
            children: List.generate(7, (i) {
              return Expanded(
                child: Text(
                  days[i],
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 10, color: textSecondary),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // ── Badges ──
  Widget _buildBadgesSection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textSecondary = Theme.of(context).textTheme.bodyMedium?.color ?? colorScheme.onSurface.withOpacity(0.72);
    final badges = [
      _BadgeData(icon: LucideIcons.flame, label: '14 jours', color: const Color(0xFFFF6B35), bg: colorScheme.surfaceContainerHighest, earned: true),
      _BadgeData(icon: LucideIcons.trophy, label: 'Top 10%', color: colorScheme.primary, bg: colorScheme.surfaceContainerHighest, earned: true),
      _BadgeData(icon: LucideIcons.zap, label: '50 séances', color: const Color(0xFF5B5FEF), bg: colorScheme.surfaceContainerHighest, earned: true),
      _BadgeData(icon: LucideIcons.medal, label: 'Marathon', color: textSecondary, bg: colorScheme.surfaceContainerHighest, earned: false),
      _BadgeData(icon: LucideIcons.flag, label: 'Pionnier', color: textSecondary, bg: colorScheme.surfaceContainerHighest, earned: false),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Badges',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: colorScheme.onSurface),
            ),
            Text(
              'Voir tout',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: colorScheme.primary),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: badges.map((b) => _buildBadge(context, b)).toList(),
        ),
      ],
    );
  }

  Widget _buildBadge(BuildContext context, _BadgeData badge) {
    final colorScheme = Theme.of(context).colorScheme;
    final textSecondary = Theme.of(context).textTheme.bodyMedium?.color ?? colorScheme.onSurface.withOpacity(0.72);
    return Opacity(
      opacity: badge.earned ? 1.0 : 0.4,
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: badge.bg,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(badge.icon, color: badge.color, size: 24),
          ),
          const SizedBox(height: 6),
          Text(
            badge.label,
            style: TextStyle(fontSize: 10, color: textSecondary, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ── Settings ──
  Widget _buildSettingsSection(BuildContext context, WidgetRef ref, bool isDarkMode) {
    final colorScheme = Theme.of(context).colorScheme;
    final textPrimary = colorScheme.onSurface;
    final textSecondary = Theme.of(context).textTheme.bodyMedium?.color ?? colorScheme.onSurface.withOpacity(0.72);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Paramètres',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: textPrimary),
        ),
        const SizedBox(height: 12),
        _buildSettingsCard(
          context,
          items: [
            _SettingsItemData(icon: LucideIcons.bell, title: 'Notifications', iconBg: colorScheme.surfaceContainerHighest, iconColor: colorScheme.primary, onTap: () {}),
            _SettingsItemData(
              icon: isDarkMode ? LucideIcons.sunMedium : LucideIcons.moon,
              title: 'Mode sombre',
              iconBg: colorScheme.surfaceContainerHighest,
              iconColor: colorScheme.primary,
              trailing: isDarkMode ? 'Activé' : 'Désactivé',
              trailingWidget: Switch.adaptive(
                value: isDarkMode,
                onChanged: (_) => ref.read(themeModeProvider.notifier).toggleThemeMode(),
              ),
              onTap: () => ref.read(themeModeProvider.notifier).toggleThemeMode(),
            ),
            _SettingsItemData(icon: LucideIcons.heart, title: 'Santé connectée', iconBg: colorScheme.surfaceContainerHighest, iconColor: const Color(0xFFFF6B35), onTap: () {}),
            _SettingsItemData(icon: LucideIcons.globe, title: 'Langue', iconBg: colorScheme.surfaceContainerHighest, iconColor: colorScheme.primary, trailing: 'Français', onTap: () {}),
            _SettingsItemData(icon: LucideIcons.lock, title: 'Confidentialité', iconBg: colorScheme.surfaceContainerHighest, iconColor: textSecondary, onTap: () {}),
            _SettingsItemData(icon: LucideIcons.share2, title: "Partager l'app", iconBg: colorScheme.surfaceContainerHighest, iconColor: textSecondary, onTap: () {}),
            _SettingsItemData(icon: LucideIcons.helpCircle, title: 'Aide & FAQ', iconBg: colorScheme.surfaceContainerHighest, iconColor: textSecondary, onTap: () {}),
            _SettingsItemData(icon: LucideIcons.info, title: 'À propos', iconBg: colorScheme.surfaceContainerHighest, iconColor: textSecondary, trailing: 'v2.4.1', onTap: () {}),
          ],
        ),
        const SizedBox(height: 16),

        // Community button
      
        const SizedBox(height: 10),

        // Logout button
        SizedBox(
          width: double.infinity,
          height: 52,
          child: OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(LucideIcons.logOut, size: 18),
            label: const Text(
              'Se déconnecter',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: colorScheme.error,
              side: BorderSide(color: colorScheme.outlineVariant),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              backgroundColor: colorScheme.surface,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsCard(BuildContext context, {required List<_SettingsItemData> items}) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.08),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: List.generate(items.length, (index) {
          final item = items[index];
          final isLast = index == items.length - 1;
          return Column(
            children: [
              _buildSettingsRow(context, item: item),
              if (!isLast)
                Container(
                  height: 0.5,
                  margin: const EdgeInsets.only(left: 60),
                  color: colorScheme.outlineVariant,
                ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildSettingsRow(BuildContext context, {required _SettingsItemData item}) {
    final colorScheme = Theme.of(context).colorScheme;
    final textPrimary = colorScheme.onSurface;
    final textSecondary = Theme.of(context).textTheme.bodyMedium?.color ?? colorScheme.onSurface.withOpacity(0.72);
    return InkWell(
      onTap: item.onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: item.iconBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(item.icon, color: item.iconColor, size: 16),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                item.title,
                style: TextStyle(fontSize: 15, color: textPrimary),
              ),
            ),
            if (item.trailing != null) ...[
              Text(
                item.trailing!,
                style: TextStyle(fontSize: 13, color: textSecondary),
              ),
              const SizedBox(width: 6),
            ],
            if (item.trailingWidget != null) ...[
              item.trailingWidget!,
            ] else ...[
              Icon(LucideIcons.chevronRight, color: colorScheme.outlineVariant, size: 16),
            ],
          ],
        ),
      ),
    );
  }
}

class _BadgeData {
  final IconData icon;
  final String label;
  final Color color;
  final Color bg;
  final bool earned;
  _BadgeData({required this.icon, required this.label, required this.color, required this.bg, required this.earned});
}

class _SettingsItemData {
  final IconData icon;
  final String title;
  final Color iconBg;
  final Color iconColor;
  final String? trailing;
  final Widget? trailingWidget;
  final VoidCallback onTap;

  _SettingsItemData({
    required this.icon,
    required this.title,
    required this.iconBg,
    required this.iconColor,
    this.trailing,
    this.trailingWidget,
    required this.onTap,
  });
}