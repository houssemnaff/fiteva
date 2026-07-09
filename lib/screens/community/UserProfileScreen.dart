import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:fiteva/providers/mascot_provider.dart';
import 'package:fiteva/providers/points_provider.dart';
import 'package:fiteva/providers/user_profile_provider.dart'
    hide UserProfile;
import 'package:fiteva/providers/xp_provider.dart';
import 'package:fiteva/screens/community/model/partner_model.dart';
import 'package:fiteva/screens/community/widgets/community_avatar.dart';
import 'package:fiteva/services/comuniter_service.dart';
import 'package:fiteva/services/supabase_config.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fiteva/l10n/app_localizations.dart';

// ─── Models ───────────────────────────────────────────────────
class UserProfile {
  final String id;
  final String name;
  final String username;
  final String mascotType;
  final String mascotMood;
  final String? bio;
  final String niveau;
  final int niveauXp;
  final int niveauMaxXp;
  final String? fitnessLevel;
  final String? frequency;
  final bool isCurrentUser;
  final int etoiles;
  final List<UserPost> posts;
  final List<UserEvent> events;
  final List<PartnerModel> partners;

  const UserProfile({
    required this.id,
    required this.name,
    required this.username,
    this.mascotType = 'blob',
    this.mascotMood = 'happy',
    this.bio,
    required this.niveau,
    required this.niveauXp,
    required this.niveauMaxXp,
    this.fitnessLevel,
    this.frequency,
    this.isCurrentUser = false,
    this.etoiles = 0,
    required this.posts,
    required this.events,
    this.partners = const [],
  });
}


class UserPost {
  final String id;
  final String title;
  final String content;
  final String category;
  final DateTime createdAt;
  final int likes;
  final int comments;
  final String? imageUrl;

  const UserPost({
    required this.id,
    this.title = '',
    required this.content,
    this.category = '',
    required this.createdAt,
    required this.likes,
    required this.comments,
    this.imageUrl,
  });

  /// Un post "Avant/Après" encode ses deux photos en JSON dans [imageUrl]
  /// (voir PostModel.isBeforeAfter dans models/post_model.dart).
  bool get isBeforeAfter {
    final s = imageUrl?.trim() ?? '';
    return s.startsWith('{') && s.contains('"before"') && s.contains('"after"');
  }

  String get beforeImageUrl {
    if (!isBeforeAfter) return '';
    try {
      return (jsonDecode(imageUrl!) as Map<String, dynamic>)['before'] as String? ?? '';
    } catch (_) {
      return '';
    }
  }

  String get afterImageUrl {
    if (!isBeforeAfter) return '';
    try {
      return (jsonDecode(imageUrl!) as Map<String, dynamic>)['after'] as String? ?? '';
    } catch (_) {
      return '';
    }
  }
}

class UserEvent {
  final String id;
  final String title;
  final DateTime date;
  final String location;
  final int participants;
  final String category;
  final String? imageUrl;

  const UserEvent({
    required this.id,
    required this.title,
    required this.date,
    required this.location,
    required this.participants,
    required this.category,
    this.imageUrl,
  });
}

// ─── Provider ─────────────────────────────────────────────────
final communityUserProfileProvider =
    FutureProvider.family<UserProfile, String>((ref, userId) async {
  final currentUid = SupabaseConfig.userId;
  final isSelf     = userId == currentUid;

  // Fetch posts + events + partners + points in parallel
  // regardless of who the user is.
  final postsFuture    = CommunityService.getUserPosts(userId);
  final eventsFuture   = CommunityService.getUserEvents(userId);
  final partnersFuture = CommunityService.getUserPartners(userId);
  final pointsFuture   = CommunityService.getUserPoints(userId);

  final rawResults = await Future.wait([postsFuture, eventsFuture]);
  final userPartners = await partnersFuture;
  final remoteEtoiles = await pointsFuture;

  final userPosts = rawResults[0].map((r) {
    final imgUrl = r['image_url'] as String? ?? '';
    return UserPost(
      id:        r['id'] as String,
      title:     r['title'] as String? ?? '',
      content:   r['content'] as String? ?? '',
      category:  r['category'] as String? ?? '',
      createdAt: DateTime.tryParse(r['created_at'] as String? ?? '') ?? DateTime.now(),
      likes:     r['likes_count'] as int? ?? 0,
      comments:  r['comments_count'] as int? ?? 0,
      imageUrl:  imgUrl.isNotEmpty ? imgUrl : null,
    );
  }).toList();

  final userEvents = rawResults[1].map((r) {
    final dateStr = r['event_date'] as String? ?? '';
    final imgUrl  = r['image_url'] as String? ?? '';
    return UserEvent(
      id:           r['id'] as String,
      title:        r['title'] as String? ?? '',
      date:         DateTime.tryParse(dateStr) ?? DateTime.now(),
      location:     r['location'] as String? ?? '',
      participants: r['joined_count'] as int? ?? 0,
      category:     r['event_type'] as String? ?? '',
      imageUrl:     imgUrl.isNotEmpty ? imgUrl : null,
    );
  }).toList();

  if (isSelf) {
    // Own profile: bio/XP/points from local providers (no extra request).
    final localUser = ref.read(userProfileProvider);
    final mascot    = ref.read(mascotProvider);
    final xp        = ref.read(xpProvider).totalXp;
    final etoiles   = ref.read(pointsProvider);
    final name      = localUser.username.isNotEmpty ? localUser.username : 'User';
    return UserProfile(
      id:            userId,
      name:          name,
      username:      '@${name.toLowerCase().replaceAll(' ', '')}',
      mascotType:    mascot.type.name,
      mascotMood:    mascot.mood.name,
      niveau:        '${_xpToLevel(xp)}',
      niveauXp:      xp,
      niveauMaxXp:   5000,
      fitnessLevel:  localUser.fitnessLevel,
      frequency:     localUser.frequency != null ? '${localUser.frequency}x/sem' : null,
      isCurrentUser: true,
      etoiles:       etoiles,
      posts:         userPosts,
      events:        userEvents,
      partners:      userPartners,
    );
  }

  // Other user: fetch profile data from Supabase.
  final data = await CommunityService.getUserProfile(userId);
  if (data == null) {
    return UserProfile(
      id: userId, name: 'Utilisateur', username: '@utilisateur',
      niveau: '1', niveauXp: 0, niveauMaxXp: 5000,
      etoiles: remoteEtoiles,
      posts: userPosts, events: userEvents, partners: userPartners,
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
    mascotType:    data['mascot_type'] as String? ?? 'blob',
    mascotMood:    data['mascot_mood'] as String? ?? 'happy',
    niveau:        '$lvl',
    niveauXp:      totalXp,
    niveauMaxXp:   5000,
    fitnessLevel:  (data['fitness_level'] as String?)?.isNotEmpty == true
        ? data['fitness_level'] as String : null,
    frequency:     freqDays > 0 ? '${freqDays}x/sem' : null,
    isCurrentUser: false,
    etoiles:       remoteEtoiles,
    posts:         userPosts,
    events:        userEvents,
    partners:      userPartners,
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
                  Tab(text: l10n.profilePosts),
                  Tab(text: l10n.profileEvenements),
                  Tab(text: l10n.profilePartenaires),
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
          _PostsTab(posts: profile.posts, l10n: l10n, owner: profile),
          _EventsTab(events: profile.events, l10n: l10n, owner: profile),
          _PartnersTab(partners: profile.partners, l10n: l10n, owner: profile),
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
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: cs.surface,
                  ),
                  child: CommunityAvatar(
                    avatarUrl: '',
                    name: profile.name,
                    radius: 40,
                    mascotType: profile.mascotType,
                    mascotMood: profile.mascotMood,
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

        // ── Stats strip (posts / événements / partenaires) ────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: cs.outline),
            ),
            child: Row(children: [
              Expanded(child: _StripStat(
                value: '${profile.posts.length}',
                label: widget.l10n.profilePosts, cs: cs)),
              _VertDivider(cs: cs),
              Expanded(child: _StripStat(
                value: '${profile.events.length}',
                label: widget.l10n.profileEvenements, cs: cs)),
              _VertDivider(cs: cs),
              Expanded(child: _StripStat(
                value: '${profile.partners.length}',
                label: widget.l10n.profilePartenaires, cs: cs)),
            ]),
          ),
        ),

        const SizedBox(height: 12),

        // ── Points (étoiles) ──────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: _PointsCard(etoiles: profile.etoiles, l10n: widget.l10n, cs: cs),
        ),

        const SizedBox(height: 12),

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

// ─── Points card (étoiles boutique) ───────────────────────────
class _PointsCard extends StatelessWidget {
  final int etoiles;
  final AppL10n l10n;
  final ColorScheme cs;
  const _PointsCard({required this.etoiles, required this.l10n, required this.cs});

  static const _gold = Color(0xFFF59E0B);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _gold.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _gold.withValues(alpha: 0.25)),
      ),
      child: Row(children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            color: _gold.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(LucideIcons.star, size: 19, color: _gold),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.profileEtoilesLabel, style: GoogleFonts.inter(
              fontSize: 11, fontWeight: FontWeight.w600,
              color: cs.onSurface.withValues(alpha: 0.45))),
            const SizedBox(height: 2),
            Row(crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text('$etoiles', style: GoogleFonts.outfit(
                  fontSize: 24, fontWeight: FontWeight.w800,
                  color: _gold, letterSpacing: -0.5)),
                const SizedBox(width: 5),
                Text(l10n.profileEtoiles, style: GoogleFonts.inter(
                  fontSize: 12, fontWeight: FontWeight.w600,
                  color: _gold.withValues(alpha: 0.7))),
              ]),
          ],
        )),
      ]),
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

// ─── Header partagé — avatar + nom du propriétaire du profil ──
// Utilisé de façon identique par les cartes Post / Événement / Partenaire
// pour un design uniforme entre les trois onglets.
class _ProfileCardHeader extends StatelessWidget {
  final UserProfile owner;
  final Widget meta;
  final ColorScheme cs;
  const _ProfileCardHeader({required this.owner, required this.meta, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
      child: Row(children: [
        CommunityAvatar(
          avatarUrl: '',
          name: owner.name,
          radius: 18,
          mascotType: owner.mascotType,
          mascotMood: owner.mascotMood,
        ),
        const SizedBox(width: 10),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(owner.name, style: GoogleFonts.outfit(
              fontSize: 14, fontWeight: FontWeight.w700,
              color: cs.onSurface, letterSpacing: -0.2)),
            const SizedBox(height: 3),
            meta,
          ],
        )),
      ]),
    );
  }
}

// ─── Tab 1 — Posts (feed) ─────────────────────────────────────
class _PostsTab extends StatelessWidget {
  final List<UserPost> posts;
  final AppL10n l10n;
  final UserProfile owner;
  const _PostsTab({required this.posts, required this.l10n, required this.owner});

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
      itemBuilder: (_, i) => _PostCard(post: posts[i], owner: owner),
    );
  }
}

class _PostCard extends ConsumerStatefulWidget {
  final UserPost post;
  final UserProfile owner;
  const _PostCard({required this.post, required this.owner});
  @override
  ConsumerState<_PostCard> createState() => _PostCardState();
}

class _PostCardState extends ConsumerState<_PostCard> {
  bool _liked = false;

  @override
  Widget build(BuildContext context) {
    final l10n = ref.watch(l10nProvider);
    final cs = Theme.of(context).colorScheme;
    final post = widget.post;
    final hasTitle = post.title.trim().isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.outline),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withValues(alpha: 0.04),
            blurRadius: 14, offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        // ── Header : avatar + nom + catégorie/date ──────────────
        _ProfileCardHeader(
          owner: widget.owner,
          cs: cs,
          meta: Row(children: [
            Text(_timeAgo(post.createdAt, l10n), style: GoogleFonts.inter(
              fontSize: 11, color: cs.onSurface.withValues(alpha: 0.6))),
            if (post.category.isNotEmpty) ...[
              const SizedBox(width: 6),
              Container(width: 3, height: 3,
                decoration: BoxDecoration(
                  shape: BoxShape.circle, color: cs.outline.withValues(alpha: 0.3))),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(post.category, style: GoogleFonts.inter(
                  fontSize: 10, fontWeight: FontWeight.w700, color: cs.primary)),
              ),
            ],
          ]),
        ),

        // ── Titre + contenu ─────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            if (hasTitle) ...[
              Text(post.title, style: GoogleFonts.outfit(
                fontSize: 17, fontWeight: FontWeight.w800,
                color: cs.onSurface, letterSpacing: -0.3, height: 1.3)),
              if (post.content.isNotEmpty) const SizedBox(height: 5),
            ],
            if (post.content.isNotEmpty)
              Text(post.content, style: GoogleFonts.inter(
                fontSize: 14, color: cs.onSurface.withValues(alpha: 0.8),
                height: 1.55, letterSpacing: -0.1)),
          ]),
        ),

        // ── Image(s) ─────────────────────────────────────────────
        if (post.isBeforeAfter)
          SizedBox(
            height: 200, width: double.infinity,
            child: Row(children: [
              Expanded(child: _ProfileBeforeAfterImage(
                url: post.beforeImageUrl, label: 'Avant', cs: cs)),
              Container(width: 2, color: cs.surface),
              Expanded(child: _ProfileBeforeAfterImage(
                url: post.afterImageUrl, label: 'Après', cs: cs)),
            ]),
          )
        else if (post.imageUrl != null && post.imageUrl!.isNotEmpty)
          Container(
            constraints: const BoxConstraints(maxHeight: 320),
            width: double.infinity,
            color: cs.surfaceContainerHighest.withValues(alpha: 0.4),
            child: Image.network(post.imageUrl!,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Container(
                height: 200,
                color: cs.primary.withValues(alpha: 0.08),
              )),
          ),

        // ── Actions ──────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 10, 12, 12),
          child: Row(children: [
            GestureDetector(
              onTap: () => setState(() => _liked = !_liked),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: _liked
                      ? const Color(0xFFFF375F).withValues(alpha: 0.08)
                      : cs.outline.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(_liked ? LucideIcons.heart : LucideIcons.heart,
                    size: 15,
                    color: _liked
                        ? const Color(0xFFFF375F)
                        : cs.onSurface.withValues(alpha: 0.6)),
                  const SizedBox(width: 5),
                  Text('${post.likes + (_liked ? 1 : 0)}',
                    style: GoogleFonts.inter(
                      fontSize: 12, fontWeight: FontWeight.w700,
                      color: _liked
                          ? const Color(0xFFFF375F)
                          : cs.onSurface.withValues(alpha: 0.6))),
                ]),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: cs.outline.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(LucideIcons.messageCircle, size: 15,
                    color: cs.onSurface.withValues(alpha: 0.6)),
                const SizedBox(width: 5),
                Text('${post.comments}', style: GoogleFonts.inter(
                  fontSize: 12, fontWeight: FontWeight.w700,
                  color: cs.onSurface.withValues(alpha: 0.6))),
              ]),
            ),
          ]),
        ),
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

// ─── Before/After image (profil) ─────────────────────────────
class _ProfileBeforeAfterImage extends StatelessWidget {
  final String url;
  final String label;
  final ColorScheme cs;
  const _ProfileBeforeAfterImage({required this.url, required this.label, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Stack(fit: StackFit.expand, children: [
      Container(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.4),
        child: Image.network(
          url,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => Container(
            color: cs.primary.withValues(alpha: 0.08),
          ),
        ),
      ),
      Positioned(
        top: 6, left: 6,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(label, style: GoogleFonts.inter(
            fontSize: 9, fontWeight: FontWeight.w700,
            color: Colors.white, letterSpacing: 0.3,
          )),
        ),
      ),
    ]);
  }
}

// ─── Tab 2 — Events ───────────────────────────────────────────
class _EventsTab extends StatelessWidget {
  final List<UserEvent> events;
  final AppL10n l10n;
  final UserProfile owner;
  const _EventsTab({required this.events, required this.l10n, required this.owner});

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
          for (final e in upcoming) ...[
            _ProfileEventCard(event: e, isPast: false, cs: cs, owner: owner),
            const SizedBox(height: 12),
          ],
          const SizedBox(height: 12),
        ],
        if (past.isNotEmpty) ...[
          _SectionTitle(label: l10n.profilePasses, cs: cs),
          const SizedBox(height: 10),
          for (final e in past) ...[
            _ProfileEventCard(event: e, isPast: true, cs: cs, owner: owner),
            const SizedBox(height: 12),
          ],
        ],
      ],
    );
  }
}

class _ProfileEventCard extends StatelessWidget {
  final UserEvent event;
  final bool isPast;
  final ColorScheme cs;
  final UserProfile owner;
  const _ProfileEventCard({
    required this.event, required this.isPast, required this.cs, required this.owner,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = event.imageUrl != null && event.imageUrl!.isNotEmpty;

    return Opacity(
      opacity: isPast ? 0.55 : 1.0,
      child: Container(
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: cs.outline),
          boxShadow: [
            BoxShadow(
              color: cs.shadow.withValues(alpha: 0.04),
              blurRadius: 14, offset: const Offset(0, 3),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _ProfileCardHeader(
            owner: owner,
            cs: cs,
            meta: Row(children: [
              Icon(LucideIcons.calendarDays, size: 11,
                  color: cs.onSurface.withValues(alpha: 0.4)),
              const SizedBox(width: 4),
              Text('${event.date.day} ${_monthShort(event.date)}', style: GoogleFonts.inter(
                fontSize: 11, color: cs.onSurface.withValues(alpha: 0.6))),
            ]),
          ),
          const SizedBox(height: 10),
          if (hasImage)
            Container(
              constraints: const BoxConstraints(maxHeight: 200),
              width: double.infinity,
              color: cs.surfaceContainerHighest.withValues(alpha: 0.4),
              child: Image.network(event.imageUrl!,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Container(
                  height: 140,
                  color: cs.primary.withValues(alpha: 0.08),
                  child: Icon(LucideIcons.image, size: 28,
                      color: cs.primary.withValues(alpha: 0.3)),
                )),
            ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
                    fontSize: 15, fontWeight: FontWeight.w700,
                    color: cs.onSurface, letterSpacing: -0.2)),
                  const SizedBox(height: 4),
                  Row(children: [
                    Icon(LucideIcons.mapPin, size: 11,
                        color: cs.onSurface.withValues(alpha: 0.4)),
                    const SizedBox(width: 4),
                    Expanded(child: Text(event.location,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: cs.onSurface.withValues(alpha: 0.45)))),
                  ]),
                  const SizedBox(height: 8),
                  Row(children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: cs.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Text(event.category, style: GoogleFonts.inter(
                        fontSize: 10, fontWeight: FontWeight.w700,
                        color: cs.primary)),
                    ),
                    const SizedBox(width: 8),
                    Icon(LucideIcons.users, size: 12,
                        color: cs.onSurface.withValues(alpha: 0.35)),
                    const SizedBox(width: 4),
                    Text('${event.participants}', style: GoogleFonts.inter(
                      fontSize: 11, fontWeight: FontWeight.w600,
                      color: cs.onSurface.withValues(alpha: 0.4))),
                  ]),
                ],
              )),
            ]),
          ),
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

// ─── Tab 3 — Partenaires ──────────────────────────────────────
class _PartnersTab extends StatelessWidget {
  final List<PartnerModel> partners;
  final AppL10n l10n;
  final UserProfile owner;
  const _PartnersTab({required this.partners, required this.l10n, required this.owner});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    if (partners.isEmpty) {
      return _EmptyState(
        icon: LucideIcons.users, message: l10n.profileAucunPartenaire, cs: cs);
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      itemCount: partners.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) => _PartnerCard(partner: partners[i], l10n: l10n, owner: owner),
    );
  }
}

class _PartnerCard extends StatelessWidget {
  final PartnerModel partner;
  final UserProfile owner;
  final AppL10n l10n;
  const _PartnerCard({required this.partner, required this.l10n, required this.owner});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.outline),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withValues(alpha: 0.04),
            blurRadius: 14, offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        // ── Header : avatar + nom + niveau ──────────────────────
        _ProfileCardHeader(
          owner: owner,
          cs: cs,
          meta: partner.region.isNotEmpty
              ? Row(children: [
                  Icon(LucideIcons.mapPin, size: 10,
                      color: cs.onSurface.withValues(alpha: 0.4)),
                  const SizedBox(width: 4),
                  Flexible(child: Text(partner.region,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: cs.onSurface.withValues(alpha: 0.6)))),
                ])
              : Text(l10n.profilePartenaires, style: GoogleFonts.inter(
                  fontSize: 11, color: cs.onSurface.withValues(alpha: 0.6))),
        ),

        Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              if (partner.goal.isNotEmpty)
                Expanded(child: Text(partner.goal, style: GoogleFonts.outfit(
                  fontSize: 16, fontWeight: FontWeight.w800,
                  color: cs.onSurface, letterSpacing: -0.3))),
              if (partner.level.isNotEmpty) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: cs.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Text(partner.level, style: GoogleFonts.inter(
                    fontSize: 10, fontWeight: FontWeight.w700,
                    color: cs.primary)),
                ),
              ],
            ]),
            if (partner.description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(partner.description, style: GoogleFonts.inter(
                fontSize: 14, color: cs.onSurface.withValues(alpha: 0.65),
                height: 1.5)),
            ],
            if (partner.frequency.isNotEmpty || partner.tags.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(spacing: 6, runSpacing: 6, children: [
                if (partner.frequency.isNotEmpty)
                  _MetaPill(
                    icon: LucideIcons.calendar,
                    label: partner.frequency, cs: cs),
                for (final tag in partner.tags)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: cs.surface,
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(color: cs.outline),
                    ),
                    child: Text(tag, style: GoogleFonts.inter(
                      fontSize: 11, fontWeight: FontWeight.w600,
                      color: cs.onSurface.withValues(alpha: 0.6))),
                  ),
              ]),
            ],
          ]),
        ),
      ]),
    );
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