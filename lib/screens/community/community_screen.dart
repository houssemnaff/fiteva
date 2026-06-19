
import 'package:fiteva/screens/community/providers/community_providers.dart';
import 'package:fiteva/screens/community/widgets/events/create_event_sheet.dart';
import 'package:fiteva/screens/community/widgets/events/events_tab.dart';
import 'package:fiteva/screens/community/widgets/feed/feed_composer_sheet.dart';
import 'package:fiteva/screens/community/widgets/feed/feed_tab.dart';
import 'package:fiteva/screens/community/widgets/partners/create_partner_sheet.dart';
import 'package:fiteva/screens/community/widgets/partners/partner_tab.dart';
import 'package:fiteva/screens/community/widgets/shared/community_tab_bar.dart';
import 'package:fiteva/widgets/shared_app_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/user_profile_provider.dart';

class CommunityScreen extends ConsumerWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabIndex = ref.watch(communityTabProvider);
    final cs = Theme.of(context).colorScheme;
    final l10n = ref.watch(l10nProvider);
    final profile = ref.watch(userProfileProvider);

    final actions = [
      // Create button
      GestureDetector(
        onTap: () => _openComposer(context, tabIndex),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            color: cs.primary,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(l10n.communityCreate,
            style: GoogleFonts.outfit(
              color: cs.onPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.2,
            )),
        ),
      ),
      const SizedBox(width: 10),
      // Notification bell
      Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
          color: cs.secondary.withValues(alpha: 0.08),
          shape: BoxShape.circle,
        ),
        child: Icon(LucideIcons.bell, size: 17,
            color: cs.secondary),
      ),
      const SizedBox(width: 10),
    ];

    return Scaffold(
      backgroundColor: cs.surface,
      body: NestedScrollView(
        headerSliverBuilder: (context, _) => [
          SharedAppHeader.sliver(
            eyebrow: l10n.communityEyebrow,
            title: 'Together',
            accentColor: cs.secondary,
            bgColor: cs.surface,
            actions: actions,
            avatarInitial: profile.username.isNotEmpty ? profile.username.substring(0, 1).toUpperCase() : 'Y',
          ),
          // Tab bar as bottom of SliverAppBar
          SliverToBoxAdapter(
            child: CommunityTabBar(
              selectedIndex: tabIndex,
              onTap: (i) => ref.read(communityTabProvider.notifier).state = i,
            ),
          ),
        ],
        body: IndexedStack(
          index: tabIndex,
          children: const [
            PrimaryScrollController.none(child: FeedTab()),
            PrimaryScrollController.none(child: EventsTab()),
            PrimaryScrollController.none(child: PartnerTab()),
          ],
        ),
      ),
    );
  }

  void _openComposer(BuildContext context, int tabIndex) {
    final sheet = switch (tabIndex) {
      1 => const CreateEventSheet(),
      2 => const CreatePartnerSheet(),
      _ => const FeedComposerSheet(),
    };
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (_) => sheet,
    );
  }
}
