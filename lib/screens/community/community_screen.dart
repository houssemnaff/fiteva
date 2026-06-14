
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

class CommunityScreen extends ConsumerWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabIndex = ref.watch(communityTabProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFEFEFE),
      body: NestedScrollView(
        headerSliverBuilder: (context, _) => [
          SliverAppBar(
            pinned: true,
            floating: false,
            elevation: 0,
            scrolledUnderElevation: 0,
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.transparent,
            automaticallyImplyLeading: false,
            flexibleSpace: SharedAppHeader(
              eyebrow: 'COMMUNAUTÉ',
              title: 'Together',
              accentColor: const Color(0xFF7ABB98),
              actions: [
                GestureDetector(
                  onTap: () => _openComposer(context, tabIndex),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1C4D30),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Row(children: [
                      const Icon(LucideIcons.plus, size: 13, color: Colors.white),
                      const SizedBox(width: 6),
                      Text('Créer',
                        style: GoogleFonts.inter(
                          color: Colors.white, fontSize: 12,
                          fontWeight: FontWeight.w700, letterSpacing: 0.3)),
                    ]),
                  ),
                ),
              ],
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(54),
              child: CommunityTabBar(
                selectedIndex: tabIndex,
                onTap: (i) => ref.read(communityTabProvider.notifier).state = i,
              ),
            ),
          ),
        ],
        body: IndexedStack(
          index: tabIndex,
          children: const [FeedTab(), EventsTab(), PartnerTab()],
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
      backgroundColor: Colors.white,
      builder: (_) => sheet,
    );
  }
}

