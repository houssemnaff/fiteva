
import 'package:fiteva/screens/community/providers/community_providers.dart';
import 'package:fiteva/screens/community/widgets/events/create_event_sheet.dart';
import 'package:fiteva/screens/community/widgets/events/events_tab.dart';
import 'package:fiteva/screens/community/widgets/feed/feed_composer_sheet.dart';
import 'package:fiteva/screens/community/widgets/feed/feed_tab.dart';
import 'package:fiteva/screens/community/widgets/partners/create_partner_sheet.dart';
import 'package:fiteva/screens/community/widgets/challenges/challenges_tab.dart';
import 'package:fiteva/screens/community/widgets/partners/partner_tab.dart';
import 'package:fiteva/screens/community/widgets/shared/community_tab_bar.dart';
import 'package:fiteva/widgets/shared_app_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:shimmer/shimmer.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/user_profile_provider.dart';
import '../../services/app_tour_service.dart';
import '../../l10n/lang.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class CommunityScreen extends ConsumerStatefulWidget {
  const CommunityScreen({super.key});

  @override
  ConsumerState<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends ConsumerState<CommunityScreen> {
  final _keyCreate  = GlobalKey();
  final _keyTabBar  = GlobalKey();
  final _keyBell    = GlobalKey();

  @override
  void initState() {
    super.initState();
    _showTutorial();
  }

  void _showTutorial() {
    final isFr = Lang.code == 'fr';
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 600), () {
        if (!mounted) return;
        AppTourService.showSectionTutorial(context,
          section: 'community',
          steps: [
            SpotlightStep(
              key: _keyCreate,
              icon: LucideIcons.penSquare,
              color: const Color(0xFF5B6ABF),
              title: isFr ? 'Creer un post' : 'Create a post',
              description: isFr
                  ? 'Partage tes progres, tes photos et tes victoires avec la communaute.'
                  : 'Share your progress, photos and wins with the community.',
            ),
            SpotlightStep(
              key: _keyTabBar,
              icon: LucideIcons.layoutGrid,
              color: const Color(0xFFE85D3A),
              title: isFr ? 'Les onglets' : 'Tabs',
              description: isFr
                  ? 'Navigue entre le fil, les evenements, les partenaires et les defis.'
                  : 'Navigate between feed, events, partners and challenges.',
              contentAlign: ContentAlign.bottom,
            ),
            SpotlightStep(
              key: _keyBell,
              icon: LucideIcons.bell,
              color: const Color(0xFF2E9E6B),
              title: isFr ? 'Notifications' : 'Notifications',
              description: isFr
                  ? 'Reste informee des likes, commentaires et nouveaux evenements.'
                  : 'Stay informed about likes, comments and new events.',
              shape: ShapeLightFocus.Circle,
            ),
          ],
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final tabIndex = ref.watch(communityTabProvider);
    final cs = Theme.of(context).colorScheme;
    final l10n = ref.watch(l10nProvider);
    final profile = ref.watch(userProfileProvider);

    final actions = [
      // Create button
      GestureDetector(
        key: _keyCreate,
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
        key: _keyBell,
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
              key: _keyTabBar,
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
            PrimaryScrollController.none(child: ChallengesTab()),
          ],
        ),
      ),
    );
  }

  void _openComposer(BuildContext context, int tabIndex) {
    final sheet = switch (tabIndex) {
      1 => const CreateEventSheet(),
      2 =>  CreatePartnerSheet(),
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

class _CommunitySkeleton extends StatelessWidget {
  final ColorScheme colorScheme;
  const _CommunitySkeleton({required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
      highlightColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.95),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          _SkeletonBox(height: 132, radius: 20, colorScheme: colorScheme),
          const SizedBox(height: 12),
          _SkeletonBox(height: 86, radius: 18, colorScheme: colorScheme),
          const SizedBox(height: 12),
          _SkeletonBox(height: 88, radius: 18, colorScheme: colorScheme),
          const SizedBox(height: 12),
          _SkeletonBox(height: 88, radius: 18, colorScheme: colorScheme),
        ],
      ),
    );
  }
}

class _SkeletonBox extends StatelessWidget {
  final double height;
  final double radius;
  final ColorScheme colorScheme;

  const _SkeletonBox({
    required this.height,
    required this.radius,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
