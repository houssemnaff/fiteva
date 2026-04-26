import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:fluttermoji/fluttermoji.dart';
import '../../providers/mock_data_provider.dart';
import '../../theme/app_theme.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);

    return Scaffold(
      backgroundColor:  Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          'Profile',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
            color: Color(0xFF1C1C1E),
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFE5E5EA),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: const Icon(LucideIcons.settings, size: 18, color: Color(0xFF3C3C43)),
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
                            backgroundColor: Colors.grey[200],
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
                              color: AppTheme.primaryColor,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(LucideIcons.edit3, size: 12, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1C1C1E),
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'sarah.martin@icloud.com',
                    style: const TextStyle(fontSize: 14, color: Color(0xFF8E8E93)),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5EE),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(LucideIcons.star, size: 13, color: Color(0xFF1B5E3B)),
                        const SizedBox(width: 6),
                        Text(
                          'Level ${user.level} · Elite',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1B5E3B),
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
                    iconColor: AppTheme.primaryColor,
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
            _buildSettingsSection(context),
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
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 22),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1C1C1E),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: Color(0xFF8E8E93), fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  // ── Weekly progress ──
  Widget _buildWeeklyProgress(BuildContext context) {
    const days = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
    const completed = [true, true, true, true, true, false, false];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Objectif hebdo',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1C1C1E)),
              ),
              const Text(
                '5/6 jours',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1B5E3B)),
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
                    color: completed[i] ? const Color(0xFF1B5E3B) : const Color(0xFFE5E5EA),
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
                  style: const TextStyle(fontSize: 10, color: Color(0xFF8E8E93)),
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
    final badges = [
      _BadgeData(icon: LucideIcons.flame, label: '14 jours', color: const Color(0xFFFF6B35), bg: const Color(0xFFFFF3EE), earned: true),
      _BadgeData(icon: LucideIcons.trophy, label: 'Top 10%', color: const Color(0xFF1B5E3B), bg: const Color(0xFFE8F5EE), earned: true),
      _BadgeData(icon: LucideIcons.zap, label: '50 séances', color: const Color(0xFF5B5FEF), bg: const Color(0xFFEEEEFF), earned: true),
      _BadgeData(icon: LucideIcons.medal, label: 'Marathon', color: const Color(0xFF8E8E93), bg: const Color(0xFFF2F2F7), earned: false),
      _BadgeData(icon: LucideIcons.flag, label: 'Pionnier', color: const Color(0xFF8E8E93), bg: const Color(0xFFF2F2F7), earned: false),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Badges',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Color(0xFF1C1C1E)),
            ),
            Text(
              'Voir tout',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppTheme.primaryColor),
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
            style: const TextStyle(fontSize: 10, color: Color(0xFF3C3C43), fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ── Settings ──
  Widget _buildSettingsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Paramètres',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Color(0xFF1C1C1E)),
        ),
        const SizedBox(height: 12),
        _buildSettingsCard(
          context,
          items: [
            _SettingsItemData(icon: LucideIcons.bell, title: 'Notifications', iconBg: const Color(0xFFE8F5EE), iconColor: const Color(0xFF1B5E3B), onTap: () {}),
            _SettingsItemData(icon: LucideIcons.moon, title: 'Mode sombre', iconBg: const Color(0xFFEEEEFF), iconColor: const Color(0xFF5B5FEF), onTap: () {}),
            _SettingsItemData(icon: LucideIcons.heart, title: 'Santé connectée', iconBg: const Color(0xFFFFF3EE), iconColor: const Color(0xFFFF6B35), onTap: () {}),
            _SettingsItemData(icon: LucideIcons.globe, title: 'Langue', iconBg: const Color(0xFFE8F5EE), iconColor: const Color(0xFF1B5E3B), trailing: 'Français', onTap: () {}),
            _SettingsItemData(icon: LucideIcons.lock, title: 'Confidentialité', iconBg: const Color(0xFFF5F5F5), iconColor: const Color(0xFF8E8E93), onTap: () {}),
            _SettingsItemData(icon: LucideIcons.share2, title: "Partager l'app", iconBg: const Color(0xFFF5F5F5), iconColor: const Color(0xFF8E8E93), onTap: () {}),
            _SettingsItemData(icon: LucideIcons.helpCircle, title: 'Aide & FAQ', iconBg: const Color(0xFFF5F5F5), iconColor: const Color(0xFF8E8E93), onTap: () {}),
            _SettingsItemData(icon: LucideIcons.info, title: 'À propos', iconBg: const Color(0xFFF5F5F5), iconColor: const Color(0xFF8E8E93), trailing: 'v2.4.1', onTap: () {}),
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
              foregroundColor: const Color(0xFFFF3B30),
              side: const BorderSide(color: Color(0xFFE5E5EA)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              backgroundColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsCard(BuildContext context, {required List<_SettingsItemData> items}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
                  color: const Color(0xFFE5E5EA),
                ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildSettingsRow(BuildContext context, {required _SettingsItemData item}) {
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
                style: const TextStyle(fontSize: 15, color: Color(0xFF1C1C1E)),
              ),
            ),
            if (item.trailing != null) ...[
              Text(
                item.trailing!,
                style: const TextStyle(fontSize: 13, color: Color(0xFF8E8E93)),
              ),
              const SizedBox(width: 6),
            ],
            const Icon(LucideIcons.chevronRight, color: Color(0xFFC7C7CC), size: 16),
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
  final VoidCallback onTap;

  _SettingsItemData({
    required this.icon,
    required this.title,
    required this.iconBg,
    required this.iconColor,
    this.trailing,
    required this.onTap,
  });
}