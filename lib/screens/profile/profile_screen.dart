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
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.settings),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // User Avatar and Name
            Center(
              child: Column(
                children: [
                  Consumer(
                    builder: (context, ref, child) {
                      ref.watch(avatarProvider);
                      return FluttermojiCircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey[200],
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: () async {
                      await context.push('/edit-avatar');
                      ref.read(avatarProvider.notifier).increment();
                    },
                    icon: const Icon(LucideIcons.edit3, size: 16),
                    label: const Text('Edit Avatar'),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    user.name,
                    style: Theme.of(context).textTheme.displayMedium,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.accentColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Level ${user.level}',
                      style: const TextStyle(
                        color: AppTheme.accentColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // Stats Grid
            Row(
              children: [
                Expanded(child: _buildStatCard(context, 'XP', '${user.xp}', LucideIcons.star)),
                const SizedBox(width: 16),
                Expanded(child: _buildStatCard(context, 'Streak', '${user.streak}', LucideIcons.flame)),
              ],
            ),
            const SizedBox(height: 40),

            // Badges
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Badges',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: [
                _buildBadge(context, '7 Day Streak', LucideIcons.flame, true),
                _buildBadge(context, 'Early Bird', LucideIcons.sunrise, true),
                _buildBadge(context, 'Marathon', LucideIcons.footprints, false),
                _buildBadge(context, 'Strength', LucideIcons.dumbbell, true),
                _buildBadge(context, 'Expert', LucideIcons.award, false),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: AppTheme.primaryColor, size: 32),
          const SizedBox(height: 12),
          Text(
            value,
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(BuildContext context, String name, IconData icon, bool earned) {
    return Container(
      decoration: BoxDecoration(
        color: earned ? AppTheme.accentColor.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: earned ? AppTheme.primaryColor : Colors.grey,
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            name,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              color: earned ? AppTheme.primaryColor : Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
