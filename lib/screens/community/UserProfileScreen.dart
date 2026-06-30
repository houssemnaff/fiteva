import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:fiteva/providers/points_provider.dart';
import 'package:fiteva/providers/user_profile_provider.dart'
    hide UserProfile;
import 'package:fiteva/services/comuniter_service.dart';
import 'package:fiteva/services/supabase_config.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fiteva/l10n/app_localizations.dart';

// ─── Models ───────────────────────────────────────────────────
class UserProfile {
  final String id;
  final String name;
  final String username;
  final String? avatarUrl;
  final String? bio;
  final String niveau;
  final int niveauXp;
  final int niveauMaxXp;
  final String? fitnessLevel;
  final String? frequency;
  final bool isCurrentUser;
  final List<UserPost> posts;
  final List<UserEvent> events;

  const UserProfile({
    required this.id,
    required this.name,
    required this.username,
    this.avatarUrl,
    this.bio,
    required this.niveau,
    required this.niveauXp,
    required this.niveauMaxXp,
    this.fitnessLevel,
    this.frequency,
    this.isCurrentUser = false,
    required this.posts,
    required this.events,
  });
}


class UserPost {
  final String id;
  final String content;
  final DateTime createdAt;
  final int likes;
  final int comments;
  final String? imageUrl;

  const UserPost({
    required this.id,
    required this.content,
    required this.createdAt,
    required this.likes,
    required this.comments,
    this.imageUrl,
  });
}

class UserEvent {
  final String id;
  final String title;
  final DateTime date;
  final String location;
  final int participants;
  final String category;

  const UserEvent({
    required this.id,
    required this.title,
    required this.date,
    required this.location,
    required this.participants,
    required this.category,
  });
}

// ─── Provider ─────────────────────────────────────────────────
final communityUserProfileProvider =
    FutureProvider.family<UserProfile, String>((ref, userId) async {
  final currentUid = SupabaseConfig.userId;
  final isSelf     = userId == currentUid;

  // Fetch posts + events in parallel regardless of who the user is.
  final rawResults = await Future.wait([
    CommunityService.getUserPosts(userId),
    CommunityService.getUserEvents(userId),
  ]);

  final userPosts = rawResults[0].map((r) {
    final imgUrl = r['image_url'] as String? ?? '';
    return UserPost(
      id:        r['id'] as String,
      content:   r['content'] as String? ?? '',
      createdAt: DateTime.tryParse(r['created_at'] as String? ?? '') ?? DateTime.now(),
      likes:     r['likes_count'] as int? ?? 0,
      comments:  r['comments_count'] as int? ?? 0,
      imageUrl:  imgUrl.isNotEmpty ? imgUrl : null,
    );
  }).toList();

  final userEvents = rawResults[1].map((r) {
    final dateStr = r['event_date'] as String? ?? '';
    return UserEvent(
      id:           r['id'] as String,
      title:        r['title'] as String? ?? '',
      date:         DateTime.tryParse(dateStr) ?? DateTime.now(),
      location:     r['location'] as String? ?? '',
      participants: r['joined_count'] as int? ?? 0,
      category:     r['event_type'] as String? ?? '',
    );
  }).toList();

  if (isSelf) {
    // Own profile: bio/XP from local providers (no extra request).
    final localUser = ref.read(userProfileProvider);
    final points    = ref.read(pointsProvider);
    final name      = localUser.username.isNotEmpty ? localUser.username : 'User';
    return UserProfile(
      id:            userId,
      name:          name,
      username:      '@${name.toLowerCase().replaceAll(' ', '')}',
      niveau:        localUser.level ?? '1',
      niveauXp:      points,
      niveauMaxXp:   5000,
      fitnessLevel:  localUser.fitnessLevel,
      frequency:     localUser.frequency != null ? '${localUser.frequency}x/sem' : null,
      isCurrentUser: true,
      posts:         userPosts,
      events:        userEvents,
    );
  }

  // Other user: fetch profile data from Supabase.
  final data = await CommunityService.getUserProfile(userId);
  if (data == null) {
    return UserProfile(
      id: userId, name: 'Utilisateur', username: '@utilisateur',
      niveau: '1', niveauXp: 0, niveauMaxXp: 5000,
      posts: userPosts, events: userEvents,
    );
  }

  final name      = (data['username'] as String).isNotEmpty ? data['username'] as String : 'User';
  final freqDays  = data['frequency_days'] as int? ?? 0;
  final totalXp   = data['total_xp'] as int? ?? 0;
  final lvl       = _xpToLevel(totalXp);

  return UserProfile(
    id:            data['id'] as String,
    name:          name,
    username:      '@${name.toLowerCase().replaceAll(' ', '')}',
    niveau:        '$lvl',
    niveauXp:      totalXp,
    niveauMaxXp:   5000,
    fitnessLevel:  (data['fitness_level'] as String?)?.isNotEmpty == true
        ? data['fitness_level'] as String : null,
    frequency:     freqDays > 0 ? '${freqDays}x/sem' : null,
    isCurrentUser: false,
    posts:         userPosts,
    events:        userEvents,
  );
});

int _xpToLevel(int xp) {
  if (xp < 500)  return 1;
  if (xp < 1500) return 2;
  if (xp < 3000) return 3;
  if (xp < 5000) return 4;
  if (xp < 8000) return 5;
  if (xp < 12000) return 6;
  return 7;
}

// ─── Main Screen ──────────────────────────────────────────────
class UserProfileScreen extends ConsumerStatefulWidget {
  final String userId;
  final String? heroTag;

  const UserProfileScreen({
    super.key,
    required this.userId,
    this.heroTag,
  });

  @override
  ConsumerState<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends ConsumerState<UserProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l10n = ref.watch(l10nProvider);
    final profileAsync = ref.watch(communityUserProfileProvider(widget.userId));

    return Scaffold(
      backgroundColor: cs.surface,
      body: profileAsync.when(
        loading: () => _ProfileSkeleton(),
        error: (e, _) => _ProfileError(error: e.toString(), l10n: l10n),
        data: (profile) => _ProfileContent(
          profile: profile,
          tabController: _tabController,
          heroTag: widget.heroTag,
          l10n: l10n,
        ),
      ),
    );
  }
}

// ─── Profile Content ──────────────────────────────────────────
class _ProfileContent extends StatelessWidget {
  final UserProfile profile;
  final TabController tabController;
  final String? heroTag;
  final AppL10n l10n;

  const _ProfileContent({
    required this.profile,
    required this.tabController,
    this.heroTag,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return NestedScrollView(
      headerSliverBuilder: (context, _) => [
        // ── App bar ───────────────────────────────────────────
        SliverAppBar(
          pinned: true,
          floating: false,
          elevation: 0,
          backgroundColor: cs.surface,
          surfaceTintColor: Colors.transparent,
          leading: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              child: Icon(LucideIcons.arrowLeft,
                  size: 16, color: cs.onSurface),
            ),
          ),
          actions: [
            GestureDetector(
              onTap: () => _showOptions(context),
              child: Container(
                margin: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest,
                  shape: BoxShape.circle,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Icon(LucideIcons.ellipsis,
                      size: 16, color: cs.onSurface),
                ),
              ),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(48),
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                      color: cs.outline.withValues(alpha: 0.5), width: 1),
                ),
              ),
              child: TabBar(
                controller: tabController,
                labelColor: cs.primary,
                unselectedLabelColor: cs.onSurface.withValues(alpha: 0.4),
                indicator: UnderlineTabIndicator(
                  borderSide: BorderSide(color: cs.primary, width: 2.5),
                  insets: const EdgeInsets.symmetric(horizontal: 20),
                ),
                labelStyle: GoogleFonts.outfit(
                    fontSize: 13, fontWeight: FontWeight.w700),
                unselectedLabelStyle: GoogleFonts.outfit(
                    fontSize: 13, fontWeight: FontWeight.w500),
                tabs: [
                  Tab(text: l10n.profileApercu),
                  Tab(text: l10n.profilePosts),
                  Tab(text: l10n.profileEvenements),
                ],
              ),
            ),
          ),
        ),

        // ── Header ────────────────────────────────────────────
        SliverToBoxAdapter(
          child: _ProfileHeader(profile: profile, heroTag: heroTag, l10n: l10n),
        ),
      ],
      body: TabBarView(
        controller: tabController,
        children: [
          _OverviewTab(profile: profile, l10n: l10n),
          _PostsTab(posts: profile.posts, l10n: l10n),
          _EventsTab(events: profile.events, l10n: l10n),
        ],
      ),
    );
  }

  void _showOptions(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (_) => CupertinoActionSheet(
        actions: [
          CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.profileSignaler),
          ),
          CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.profileMasquer),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          isDefaultAction: true,
          child: Text(l10n.profileAnnuler),
        ),
      ),
    );
  }
}

// ─── Profile Header ───────────────────────────────────────────
class _ProfileHeader extends ConsumerStatefulWidget {
  final UserProfile profile;
  final String? heroTag;
  final AppL10n l10n;

  const _ProfileHeader({required this.profile, this.heroTag, required this.l10n});

  @override
  ConsumerState<_ProfileHeader> createState() => _ProfileHeaderState();
}

class _ProfileHeaderState extends ConsumerState<_ProfileHeader> {
  bool _following = false;

  String get _initials {
    final name = widget.profile.name.trim();
    if (name.isEmpty) return '?';
    final parts = name.split(' ');
    if (parts.length >= 2 && parts[1].isNotEmpty) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final profile = widget.profile;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        // ── Hero band ──────────────────────────────────────────
        Stack(
          clipBehavior: Clip.none,
          children: [
            // Solid primary banner
            Container(
              height: 130,
              width: double.infinity,
              color: cs.primary,
              child: Stack(children: [
                // Subtle geometric overlay
                Positioned(
                  top: -30, right: -30,
                  child: Container(
                    width: 180, height: 180,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.06),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -20, left: 80,
                  child: Container(
                    width: 100, height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.04),
                    ),
                  ),
                ),
              ]),
            ),

            // Avatar — overlapping bottom of banner
            Positioned(
              bottom: -44,
              left: 20,
              child: Hero(
                tag: widget.heroTag ?? 'avatar_${profile.id}',
                child: Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: cs.surface, width: 4),
                    color: cs.secondary,
                  ),
                  child: ClipOval(
                    child: profile.avatarUrl != null
                        ? Image.network(profile.avatarUrl!, fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _InitialsCircle(
                              initials: _initials, cs: cs))
                        : _InitialsCircle(initials: _initials, cs: cs),
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 56), // avatar overflow space

        // ── Name + follow row ─────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(profile.name, style: GoogleFonts.outfit(
                      fontSize: 24, fontWeight: FontWeight.w800,
                      color: cs.onSurface, letterSpacing: -0.5, height: 1.1)),
                    const SizedBox(height: 2),
                    Text(profile.username, style: GoogleFonts.inter(
                      fontSize: 13, fontWeight: FontWeight.w500,
                      color: cs.onSurface.withValues(alpha: 0.45))),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _following = !_following);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: _following
                        ? Colors.transparent
                        : cs.primary,
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(
                      color: cs.primary,
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    _following ? widget.l10n.profileSuivi : widget.l10n.profileSuivre,
                    style: GoogleFonts.outfit(
                      fontSize: 13, fontWeight: FontWeight.w800,
                      color: _following ? cs.primary : cs.onPrimary,
                      letterSpacing: 0.1),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // ── Bio ───────────────────────────────────────────────
        if (profile.bio != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(profile.bio!, style: GoogleFonts.inter(
              fontSize: 14, color: cs.onSurface.withValues(alpha: 0.65),
              height: 1.55)),
          ),

        const SizedBox(height: 10),

        // ── Meta pills ────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Wrap(spacing: 8, runSpacing: 6, children: [
            if (profile.fitnessLevel != null && profile.fitnessLevel!.isNotEmpty)
              _MetaPill(
                icon: LucideIcons.target,
                label: profile.fitnessLevel!,
                cs: cs),
            if (profile.frequency != null && profile.frequency!.isNotEmpty)
              _MetaPill(
                icon: LucideIcons.dumbbell,
                label: profile.frequency!,
                cs: cs),
            _MetaPill(
              icon: LucideIcons.star,
              label: '${profile.niveauXp} XP',
              cs: cs,
              highlight: true),
          ]),
        ),

        const SizedBox(height: 20),

        // ── Stats strip ───────────────────────────────────────
       
        const SizedBox(height: 16),

        // ── Level progress ────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: _LevelBar(
            niveau: profile.niveau,
            xp: profile.niveauXp,
            maxXp: profile.niveauMaxXp,
            cs: cs,
            l10n: widget.l10n,
          ),
        ),

        const SizedBox(height: 20),
      ],
    );
  }

  String _formatKcal(double kcal) {
    if (kcal >= 1000) return '${(kcal / 1000).toStringAsFixed(1)}k';
    return '${kcal.toInt()}';
  }
}

// ─── Initials circle fallback ─────────────────────────────────
class _InitialsCircle extends StatelessWidget {
  final String initials;
  final ColorScheme cs;
  const _InitialsCircle({required this.initials, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: cs.secondary,
      alignment: Alignment.center,
      child: Text(initials, style: GoogleFonts.outfit(
        fontSize: 30, fontWeight: FontWeight.w800,
        color: Colors.white.withValues(alpha: 0.9), letterSpacing: -1)),
    );
  }
}

// ─── Meta pill ────────────────────────────────────────────────
class _MetaPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final ColorScheme cs;
  final bool highlight;
  const _MetaPill({
    required this.icon, required this.label, required this.cs,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: highlight
            ? cs.primary.withValues(alpha: 0.1)
            : cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(50),
        border: Border.all(
          color: highlight
              ? cs.primary.withValues(alpha: 0.3)
              : cs.outline),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 11,
            color: highlight ? cs.primary : cs.onSurface.withValues(alpha: 0.5)),
        const SizedBox(width: 5),
        Text(label, style: GoogleFonts.inter(
          fontSize: 11, fontWeight: FontWeight.w600,
          color: highlight
              ? cs.primary
              : cs.onSurface.withValues(alpha: 0.6))),
      ]),
    );
  }
}

// ─── Strip stat ───────────────────────────────────────────────
class _StripStat extends StatelessWidget {
  final String value, label;
  final ColorScheme cs;
  const _StripStat({required this.value, required this.label, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text(value, style: GoogleFonts.outfit(
        fontSize: 22, fontWeight: FontWeight.w800,
        color: cs.primary, letterSpacing: -0.5)),
      const SizedBox(height: 2),
      Text(label, style: GoogleFonts.inter(
        fontSize: 11, fontWeight: FontWeight.w500,
        color: cs.onSurface.withValues(alpha: 0.45))),
    ]);
  }
}

class _VertDivider extends StatelessWidget {
  final ColorScheme cs;
  const _VertDivider({required this.cs});
  @override
  Widget build(BuildContext context) => Container(
    width: 1, height: 36,
    color: cs.outline.withValues(alpha: 0.6));
}

// ─── Level bar ────────────────────────────────────────────────
class _LevelBar extends StatelessWidget {
  final String niveau;
  final int xp, maxXp;
  final ColorScheme cs;
  final AppL10n l10n;
  const _LevelBar({
    required this.niveau, required this.xp,
    required this.maxXp, required this.cs, required this.l10n});

  int get _lvl => int.tryParse(niveau) ?? 1;

  Color get _accent {
    if (_lvl <= 2) return const Color(0xFF34D399);
    if (_lvl <= 4) return const Color(0xFF3B82F6);
    if (_lvl <= 6) return const Color(0xFFF59E0B);
    return const Color(0xFFBF5AF2);
  }

  IconData get _icon {
    if (_lvl <= 2) return LucideIcons.sprout;
    if (_lvl <= 4) return LucideIcons.zap;
    if (_lvl <= 6) return LucideIcons.flame;
    return LucideIcons.crown;
  }

  String _levelLabel(AppL10n l10n) {
    if (_lvl <= 2) return l10n.profileDebutant;
    if (_lvl <= 4) return l10n.profileInter;
    if (_lvl <= 6) return l10n.profileAvance;
    return l10n.profileExpert;
  }

  @override
  Widget build(BuildContext context) {
    final progress = (xp / maxXp).clamp(0.0, 1.0);
    final remaining = ((1 - progress) * maxXp).round();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _accent.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _accent.withValues(alpha: 0.2)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 28, height: 28,
            decoration: BoxDecoration(
              color: _accent.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(_icon, size: 14, color: _accent),
          ),
          const SizedBox(width: 10),
          Text(l10n.profileNiveau(_levelLabel(l10n)), style: GoogleFonts.outfit(
            fontSize: 14, fontWeight: FontWeight.w800,
            color: _accent, letterSpacing: -0.2)),
          const Spacer(),
          Text('$xp / $maxXp XP', style: GoogleFonts.inter(
            fontSize: 11, fontWeight: FontWeight.w600,
            color: cs.onSurface.withValues(alpha: 0.45))),
        ]),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(50),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: _accent.withValues(alpha: 0.12),
            valueColor: AlwaysStoppedAnimation<Color>(_accent),
            minHeight: 6,
          ),
        ),
        const SizedBox(height: 8),
        Text(l10n.profileXPToNext(remaining),
          style: GoogleFonts.inter(
            fontSize: 11, color: cs.onSurface.withValues(alpha: 0.4))),
      ]),
    );
  }
}

// ─── Tab 1 — Overview ─────────────────────────────────────────
class _OverviewTab extends ConsumerWidget {
  final UserProfile profile;
  final AppL10n l10n;
  const _OverviewTab({required this.profile, required this.l10n});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
   

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      children: [

        // Section label
        _SectionTitle(label: l10n.profileStats, cs: cs),
        const SizedBox(height: 12),

       
       

        const SizedBox(height: 24),
        _SectionTitle(label: l10n.profileRepartition, cs: cs),
        const SizedBox(height: 12),

     

      ],
    );
  }


}

class _SectionTitle extends StatelessWidget {
  final String label;
  final ColorScheme cs;
  const _SectionTitle({required this.label, required this.cs});
  @override
  Widget build(BuildContext context) => Text(label,
    style: GoogleFonts.inter(
      fontSize: 9, fontWeight: FontWeight.w700,
      color: cs.onSurface.withValues(alpha: 0.4), letterSpacing: 2));
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value, label;
  final Color color;
  final ColorScheme cs;
  const _StatCard({
    required this.icon, required this.value, required this.label,
    required this.color, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cs.outline),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 34, height: 34,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(height: 12),
        Text(value, style: GoogleFonts.outfit(
          fontSize: 22, fontWeight: FontWeight.w800,
          color: cs.onSurface, letterSpacing: -0.5)),
        const SizedBox(height: 2),
        Text(label, style: GoogleFonts.inter(
          fontSize: 11, color: cs.onSurface.withValues(alpha: 0.45),
          fontWeight: FontWeight.w500)),
      ]),
    );
  }
}

class _DistRow extends StatelessWidget {
  final String label;
  final int count;
  final double pct;
  final Color color;
  final ColorScheme cs;
  const _DistRow({
    required this.label, required this.count,
    required this.pct, required this.color, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 8, height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 10),
          Expanded(child: Text(label, style: GoogleFonts.inter(
            fontSize: 14, color: cs.onSurface))),
          Text('$count', style: GoogleFonts.outfit(
            fontSize: 15, fontWeight: FontWeight.w700,
            color: cs.onSurface.withValues(alpha: 0.55))),
        ]),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(50),
          child: LinearProgressIndicator(
            value: pct,
            backgroundColor: color.withValues(alpha: 0.1),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 4,
          ),
        ),
      ]),
    );
  }
}

// ─── Tab 2 — Posts ────────────────────────────────────────────
class _PostsTab extends StatelessWidget {
  final List<UserPost> posts;
  final AppL10n l10n;
  const _PostsTab({required this.posts, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    if (posts.isEmpty) {
      return _EmptyState(
        icon: LucideIcons.fileText, message: l10n.profileAucunPost, cs: cs);
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      itemCount: posts.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) => _PostCard(post: posts[i]),
    );
  }
}

class _PostCard extends ConsumerStatefulWidget {
  final UserPost post;
  const _PostCard({required this.post});
  @override
  ConsumerState<_PostCard> createState() => _PostCardState();
}

class _PostCardState extends ConsumerState<_PostCard> {
  bool _liked = false;

  @override
  Widget build(BuildContext context) {
    final l10n = ref.watch(l10nProvider);
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outline),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(widget.post.content, style: GoogleFonts.inter(
          fontSize: 15, color: cs.onSurface, height: 1.55,
          letterSpacing: -0.1)),
        if (widget.post.imageUrl != null) ...[
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(widget.post.imageUrl!,
              fit: BoxFit.cover, width: double.infinity, height: 180)),
        ],
        const SizedBox(height: 14),
        Row(children: [
          Text(_timeAgo(widget.post.createdAt, l10n), style: GoogleFonts.inter(
            fontSize: 12,
            color: cs.onSurface.withValues(alpha: 0.4))),
          const Spacer(),
          GestureDetector(
            onTap: () => setState(() => _liked = !_liked),
            child: Row(children: [
              Icon(
                _liked ? LucideIcons.heart : LucideIcons.heart,
                size: 16,
                color: _liked
                    ? const Color(0xFFFF375F)
                    : cs.onSurface.withValues(alpha: 0.4)),
              const SizedBox(width: 5),
              Text('${widget.post.likes + (_liked ? 1 : 0)}',
                style: GoogleFonts.inter(
                  fontSize: 13, fontWeight: FontWeight.w600,
                  color: _liked
                      ? const Color(0xFFFF375F)
                      : cs.onSurface.withValues(alpha: 0.4))),
            ]),
          ),
          const SizedBox(width: 16),
          Row(children: [
            Icon(LucideIcons.messageCircle, size: 16,
                color: cs.onSurface.withValues(alpha: 0.4)),
            const SizedBox(width: 5),
            Text('${widget.post.comments}', style: GoogleFonts.inter(
              fontSize: 13, fontWeight: FontWeight.w600,
              color: cs.onSurface.withValues(alpha: 0.4))),
          ]),
        ]),
      ]),
    );
  }

  String _timeAgo(DateTime dt, AppL10n l10n) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return l10n.profileTimeAgoMin(diff.inMinutes);
    if (diff.inHours < 24) return l10n.profileTimeAgoH(diff.inHours);
    return l10n.profileTimeAgoD(diff.inDays);
  }
}

// ─── Tab 3 — Events ───────────────────────────────────────────
class _EventsTab extends StatelessWidget {
  final List<UserEvent> events;
  final AppL10n l10n;
  const _EventsTab({required this.events, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    if (events.isEmpty) {
      return _EmptyState(
        icon: LucideIcons.calendarX, message: l10n.profileAucunEvt, cs: cs);
    }

    final now = DateTime.now();
    final upcoming = events.where((e) => e.date.isAfter(now)).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    final past = events.where((e) => !e.date.isAfter(now)).toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      children: [
        if (upcoming.isNotEmpty) ...[
          _SectionTitle(label: l10n.profileAVenir, cs: cs),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: cs.outline),
            ),
            child: Column(children: [
              for (int i = 0; i < upcoming.length; i++) ...[
                _EventRow(event: upcoming[i], isPast: false, cs: cs),
                if (i < upcoming.length - 1)
                  Divider(height: 1,
                    color: cs.outline.withValues(alpha: 0.5),
                    indent: 16, endIndent: 16),
              ],
            ]),
          ),
          const SizedBox(height: 24),
        ],
        if (past.isNotEmpty) ...[
          _SectionTitle(label: l10n.profilePasses, cs: cs),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: cs.outline),
            ),
            child: Column(children: [
              for (int i = 0; i < past.length; i++) ...[
                _EventRow(event: past[i], isPast: true, cs: cs),
                if (i < past.length - 1)
                  Divider(height: 1,
                    color: cs.outline.withValues(alpha: 0.5),
                    indent: 16, endIndent: 16),
              ],
            ]),
          ),
        ],
      ],
    );
  }
}

class _EventRow extends StatelessWidget {
  final UserEvent event;
  final bool isPast;
  final ColorScheme cs;
  const _EventRow({required this.event, required this.isPast, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isPast ? 0.5 : 1.0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(children: [
          Container(
            width: 46, height: 46,
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: isPast ? 0.05 : 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: cs.primary.withValues(alpha: isPast ? 0.1 : 0.25)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(_monthShort(event.date), style: GoogleFonts.inter(
                  fontSize: 9, fontWeight: FontWeight.w700,
                  color: cs.primary.withValues(alpha: isPast ? 0.5 : 1))),
                Text('${event.date.day}', style: GoogleFonts.outfit(
                  fontSize: 18, fontWeight: FontWeight.w800,
                  color: cs.primary.withValues(alpha: isPast ? 0.5 : 1),
                  height: 1.1)),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(event.title, style: GoogleFonts.outfit(
                fontSize: 14, fontWeight: FontWeight.w700,
                color: cs.onSurface)),
              const SizedBox(height: 3),
              Row(children: [
                Icon(LucideIcons.mapPin, size: 10,
                    color: cs.onSurface.withValues(alpha: 0.4)),
                const SizedBox(width: 4),
                Expanded(child: Text(event.location,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: cs.onSurface.withValues(alpha: 0.45)))),
              ]),
            ],
          )),
          const SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Text(event.category, style: GoogleFonts.inter(
                fontSize: 10, fontWeight: FontWeight.w700,
                color: cs.primary)),
            ),
            const SizedBox(height: 5),
            Row(children: [
              Icon(LucideIcons.users, size: 11,
                  color: cs.onSurface.withValues(alpha: 0.35)),
              const SizedBox(width: 4),
              Text('${event.participants}', style: GoogleFonts.inter(
                fontSize: 11,
                color: cs.onSurface.withValues(alpha: 0.35))),
            ]),
          ]),
        ]),
      ),
    );
  }

  String _monthShort(DateTime dt) {
    const m = ['JAN','FÉV','MAR','AVR','MAI','JUN',
                'JUL','AOÛ','SEP','OCT','NOV','DÉC'];
    return m[dt.month - 1];
  }
}

// ─── Empty state ──────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  final ColorScheme cs;
  const _EmptyState({required this.icon, required this.message, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 40, color: cs.onSurface.withValues(alpha: 0.15)),
      const SizedBox(height: 12),
      Text(message, style: GoogleFonts.inter(
        fontSize: 14, color: cs.onSurface.withValues(alpha: 0.35))),
    ]));
  }
}

// ─── Loading skeleton ─────────────────────────────────────────
class _ProfileSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: cs.surface,
      body: ListView(padding: EdgeInsets.zero, children: [
        _Shimmer(width: double.infinity, height: 130, radius: 0, cs: cs),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 56, 20, 20),
          child: Column(children: [
            Row(children: [
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Shimmer(width: 160, height: 24, radius: 6, cs: cs),
                  const SizedBox(height: 8),
                  _Shimmer(width: 100, height: 14, radius: 6, cs: cs),
                ])),
              _Shimmer(width: 80, height: 38, radius: 50, cs: cs),
            ]),
            const SizedBox(height: 20),
            _Shimmer(width: double.infinity, height: 80, radius: 20, cs: cs),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: _Shimmer(
                  width: double.infinity, height: 100, radius: 18, cs: cs)),
              const SizedBox(width: 12),
              Expanded(child: _Shimmer(
                  width: double.infinity, height: 100, radius: 18, cs: cs)),
            ]),
          ]),
        ),
      ]),
    );
  }
}

class _Shimmer extends StatefulWidget {
  final double width, height, radius;
  final ColorScheme cs;
  const _Shimmer({
    required this.width, required this.height,
    required this.radius, required this.cs});
  @override
  State<_Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<_Shimmer> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1100))
      ..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.4, end: 0.9).animate(_ctrl);
  }
  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        width: widget.width, height: widget.height,
        decoration: BoxDecoration(
          color: Color.lerp(widget.cs.surface,
              widget.cs.surfaceContainerHighest, _anim.value),
          borderRadius: BorderRadius.circular(widget.radius),
        ),
      ),
    );
  }
}

// ─── Started Programs Section ─────────────────────────────────

// ─── Error state ──────────────────────────────────────────────
class _ProfileError extends StatelessWidget {
  final String error;
  final AppL10n l10n;
  const _ProfileError({required this.error, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(LucideIcons.circleAlert, size: 44, color: cs.error),
        const SizedBox(height: 16),
        Text(l10n.profileImpossible, style: GoogleFonts.outfit(
          fontSize: 17, fontWeight: FontWeight.w700,
          color: cs.onSurface), textAlign: TextAlign.center),
        const SizedBox(height: 8),
        Text(error, style: GoogleFonts.inter(
          fontSize: 13, color: cs.onSurface.withValues(alpha: 0.5)),
          textAlign: TextAlign.center),
      ]),
    ));
  }
}