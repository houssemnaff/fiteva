import 'package:fiteva/screens/community/providers/community_providers.dart';
import 'package:fiteva/screens/community/widgets/events/create_event_sheet.dart';
import 'package:fiteva/screens/community/widgets/events/events_tab.dart';
import 'package:fiteva/screens/community/widgets/feed/feed_composer_sheet.dart';
import 'package:fiteva/screens/community/widgets/feed/feed_tab.dart';
import 'package:fiteva/screens/community/widgets/partners/create_partner_sheet.dart';
import 'package:fiteva/screens/community/widgets/partners/partner_tab.dart';
import 'package:fiteva/screens/community/widgets/shared/community_shared_widgets.dart';
import 'package:fiteva/screens/community/widgets/shared/community_tab_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';



class CommunityScreen extends ConsumerWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabIndex = ref.watch(communityTabProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF8FAFC), Color(0xFFF3F6FB)],
          ),
        ),
        child: NestedScrollView(
          headerSliverBuilder: (context, _) => [
            SliverAppBar(
              pinned: true,
              floating: false,
              elevation: 0,
              backgroundColor: colorScheme.surface.withOpacity(0.95),
              surfaceTintColor: colorScheme.surface,
              title: Text(
                'Communauté',
                style: TextStyle(color: colorScheme.onSurface),
              ),
              centerTitle: false,
              actions: [
                IconButton(
                  onPressed: () => _openComposer(context, tabIndex),
                  icon: Icon(LucideIcons.penTool, size: 20, color: colorScheme.onSurface),
                ),
              ],
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(52),
                child: CommunityTabBar(
                  selectedIndex: tabIndex,
                  onTap: (i) =>
                      ref.read(communityTabProvider.notifier).state = i,
                ),
              ),
            ),
          ],
          body: IndexedStack(
            index: tabIndex,
            children: const [
              FeedTab(),
              EventsTab(),
              PartnerTab(),
            ],
          ),
        ),
      ),
    );
  }

  /// Opens the appropriate composer sheet based on the active tab.
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