// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../providers/mascot_provider.dart';
import '../providers/user_profile_provider.dart';
import '../providers/points_provider.dart';
import '../providers/notifications_provider.dart';
import '../l10n/app_localizations.dart';
import '../widgets/mascot_widget.dart';
import '../screens/home/notifications_sheet.dart';
import '../screens/home/streak_rewards_sheet.dart';

class HomeHeader extends ConsumerWidget {
  const HomeHeader({super.key});

  static String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Bonjour';
    if (h < 18) return 'Bon après-midi';
    return 'Bonne soirée';
  }

  static const _weekdaysFr = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
  static const _monthsFr   = ['janv.', 'févr.', 'mars', 'avr.', 'mai', 'juin',
    'juil.', 'août', 'sept.', 'oct.', 'nov.', 'déc.'];
  static const _weekdaysEn = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  static const _monthsEn   = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

  static String _today(bool isFrench) {
    final now = DateTime.now();
    final weekday = (isFrench ? _weekdaysFr : _weekdaysEn)[now.weekday - 1];
    final month   = (isFrench ? _monthsFr : _monthsEn)[now.month - 1];
    return '$weekday ${now.day} $month';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile   = ref.watch(userProfileProvider);
    final mascot    = ref.watch(mascotProvider);
    final xp        = ref.watch(pointsProvider);
    final isFrench  = ref.watch(l10nProvider).isFrench;
    final firstName = (profile.username.isNotEmpty ? profile.username : 'Toi').split(' ').first;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [

        // Mascot → profile (moved to the left, leading the row)
        GestureDetector(
          onTap: () => context.push('/profile'),
          child: Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black.withOpacity(0.3),
              border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
            ),
            child: ClipOval(
              child: MascotWidget(type: mascot.type, mood: mascot.mood, size: 44),
            ),
          ),
        ),

        const SizedBox(width: 12),

        // Name + greeting/date on one line
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                firstName,
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.3,
                  height: 1.1,
                  shadows: [Shadow(blurRadius: 12, color: Colors.black.withOpacity(0.4))],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${_greeting()} · ${_today(isFrench)}',
                style: GoogleFonts.inter(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withOpacity(0.65),
                ),
              ),
            ],
          ),
        ),

        // Streak + bell merged into one pill cluster
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            borderRadius: BorderRadius.circular(50),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            // Streak = jours CONSÉCUTIFS (flamme) — recalculé côté serveur
            // (trigger fn_track_login_day), fiable même au premier frame.
            if (xp.streak > 0) ...[
              GestureDetector(
                onTap: () => showStreakRewardsSheet(context),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(LucideIcons.flame, size: 14, color: Color(0xFFFFB067)),
                    const SizedBox(width: 4),
                    Text('${xp.streak}', style: GoogleFonts.outfit(
                      fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white)),
                  ]),
                ),
              ),
              Container(width: 1, height: 18, color: Colors.white.withOpacity(0.18)),
            ],
            // Total de jours de connexion (distincts, pas forcément consécutifs)
            if (xp.totalLoginDays > 0) ...[
              GestureDetector(
                onTap: () => showStreakRewardsSheet(context),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(LucideIcons.calendarDays, size: 13, color: Color(0xFF9CC8F5)),
                    const SizedBox(width: 4),
                    Text('${xp.totalLoginDays}j', style: GoogleFonts.outfit(
                      fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white)),
                  ]),
                ),
              ),
              Container(width: 1, height: 18, color: Colors.white.withOpacity(0.18)),
            ],
            GestureDetector(
              onTap: () => showNotificationsSheet(context),
              child: Container(
                width: 32, height: 32,
                alignment: Alignment.center,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Icon(LucideIcons.bell, color: Colors.white.withOpacity(0.9), size: 17),
                    if (ref.watch(notificationsUnreadCountProvider) > 0)
                      Positioned(
                        top: -2, right: -3,
                        child: Container(
                          width: 8, height: 8,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEF4444),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.black.withOpacity(0.3), width: 1.5),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ]),
        ),

      ],
    );
  }
}
