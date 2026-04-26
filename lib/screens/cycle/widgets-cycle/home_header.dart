/*import 'package:fiteva/providers/mock_data_provider.dart';
import 'package:fiteva/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:fluttermoji/fluttermoji.dart';



class HomeHeader extends ConsumerWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final cycle = ref.watch(cycleProvider);

    return Row(
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

        /// 📝 Name + Phase
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hi, ${user.name}!',
                style: Theme.of(context).textTheme.displayMedium,
              ),
              const SizedBox(height: 4),
              Text(
                'Phase: ${cycle.name} (Day ${cycle.dayOfCycle})',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.accentColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        /// 🔔 Notification
        IconButton(icon: const Icon(LucideIcons.bell), onPressed: () {}),
      ],
    );
  }
}*/
