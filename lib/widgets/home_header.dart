import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:fluttermoji/fluttermoji.dart';

import '../providers/mock_data_provider.dart';
import '../theme/app_theme.dart';

class HomeHeader extends ConsumerWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final cycle = ref.watch(cycleProvider);

    return Container(
     
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          /// 👤 Avatar
          GestureDetector(
            onTap: () => context.push('/profile'),
            child: Consumer(
              builder: (context, ref, child) {
                ref.watch(avatarProvider);
                return FluttermojiCircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.grey[200],
                );
              },
            ),
          ),

          const SizedBox(width: 12),

          /// 📝 Greeting + Phase
          Expanded(
            child: _GreetingSection(user: user, cycle: cycle),
          ),

          /// 🔔 Notification
          GestureDetector(
            onTap: () {},
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF2D4B30).withValues(alpha: 0.60),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(LucideIcons.bell, color: AppTheme.accentColor, size: 20),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () => context.push('/profile'),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF2D4B30).withValues(alpha: 0.60),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(LucideIcons.user, color: AppTheme.accentColor, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}

class _GreetingSection extends StatelessWidget {
  final dynamic user;
  final dynamic cycle;

  const _GreetingSection({required this.user, required this.cycle});

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Greeting + name ────────────────────────────────────────────────
        Row(
          children: [
            Text(
              '${_greeting()}, ',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppTheme.accentColor.withValues(alpha: 0.7),
                letterSpacing: 0.2,
              ),
            ),
            Flexible(
              child: Text(
                user.name,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.accentColor,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 4),

        // ── Cycle phase chip ───────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: AppTheme.accentColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppTheme.accentColor.withValues(alpha: 0.35),
              width: 1,
            ),
          ),
          child: Text(
            '${cycle.name} · Day ${cycle.dayOfCycle}',
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppTheme.accentColor,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    );
  }
}
