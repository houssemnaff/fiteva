// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../providers/mock_data_provider.dart';
import '../providers/mascot_provider.dart';
import '../widgets/mascot_widget.dart';

class HomeHeader extends ConsumerWidget {
  const HomeHeader({super.key});

  static String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Bonjour';
    if (h < 18) return 'Bon après-midi';
    return 'Bonne soirée';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user    = ref.watch(userProvider);
    final mascot  = ref.watch(mascotProvider);
    final firstName = user.name.split(' ').first;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [

        // Greeting + name
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _greeting(),
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 1),
              Text(
                firstName,
                style: GoogleFonts.outfit(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.3,
                  height: 1.1,
                  shadows: [Shadow(blurRadius: 12, color: Colors.black.withOpacity(0.4))],
                ),
              ),
            ],
          ),
        ),

        // Bell
        GestureDetector(
          onTap: () {},
          child: Container(
            width: 38, height: 38,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(LucideIcons.bell, color: Colors.white.withOpacity(0.9), size: 18),
          ),
        ),

        const SizedBox(width: 10),

        // Mascot → profile
        GestureDetector(
          onTap: () => context.push('/profile'),
          child: Container(
            width: 42, height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black.withOpacity(0.3),
              border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
            ),
            child: ClipOval(
              child: MascotWidget(type: mascot.type, mood: mascot.mood, size: 42),
            ),
          ),
        ),

      ],
    );
  }
}
