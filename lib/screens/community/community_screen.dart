
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

class CommunityScreen extends ConsumerWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabIndex = ref.watch(communityTabProvider);
    final cs = Theme.of(context).colorScheme;
    final l10n = ref.watch(l10nProvider);

    return Scaffold(
      backgroundColor: cs.surface,
      body: NestedScrollView(
        headerSliverBuilder: (context, _) => [
          _CommunityAppBar(
            tabIndex: tabIndex,
            onComposerTap: () => _openComposer(context, tabIndex),
            onTabTap: (i) => ref.read(communityTabProvider.notifier).state = i,
            colorScheme: cs,
            l10n: l10n,
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
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (_) => sheet,
    );
  }
}

// SliverAppBar unique avec header partagé + tab bar dans bottom:
class _CommunityAppBar extends StatelessWidget {
  final int tabIndex;
  final VoidCallback onComposerTap;
  final ValueChanged<int> onTabTap;
  final ColorScheme colorScheme;
  final AppL10n l10n;

  const _CommunityAppBar({
    required this.tabIndex,
    required this.onComposerTap,
    required this.onTabTap,
    required this.colorScheme,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return SliverAppBar(
      pinned: true,
      floating: false,
      elevation: 0,
      backgroundColor: colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      expandedHeight: top + 72,
      collapsedHeight: top + 64,
      automaticallyImplyLeading: false,
      flexibleSpace: LayoutBuilder(builder: (_, __) {
        return Container(
          color: colorScheme.surface,
          padding: EdgeInsets.fromLTRB(20, top + 14, 20, 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l10n.communityEyebrow,
                      style: GoogleFonts.inter(
                        color: colorScheme.secondary,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 3.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Together',
                      style: GoogleFonts.outfit(
                        color: colorScheme.onSurface,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                        height: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
              // Bouton Créer
              GestureDetector(
                onTap: onComposerTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(l10n.communityCreate,
                    style: GoogleFonts.outfit(
                      color: colorScheme.onPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.2,
                    )),
                ),
              ),
              const SizedBox(width: 10),
              // Cloche notif
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: colorScheme.secondary.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(LucideIcons.bell, size: 17,
                    color: colorScheme.secondary),
              ),
              const SizedBox(width: 10),
              // Avatar
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: colorScheme.secondary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                  border: Border.all(color: colorScheme.secondary, width: 1.5),
                ),
                child: Center(
                  child: Text('Y',
                    style: GoogleFonts.outfit(
                      color: colorScheme.secondary,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    )),
                ),
              ),
            ],
          ),
        );
      }),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(54),
        child: CommunityTabBar(
          selectedIndex: tabIndex,
          onTap: onTabTap,
        ),
      ),
    );
  }
}
