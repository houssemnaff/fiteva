import 'package:fiteva/models/post_model.dart';
import 'package:fiteva/screens/community/UserProfileScreen.dart';
import 'package:fiteva/screens/community/providers/community_providers.dart';
import 'package:fiteva/screens/community/widgets/community_avatar.dart';
import 'package:fiteva/screens/community/widgets/feed/comment_sheet.dart';
import 'package:fiteva/screens/community/widgets/feed/feed_composer_sheet.dart';
import 'package:fiteva/services/supabase_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../l10n/app_localizations.dart';

// Color scheme is obtained from Theme.of(context).colorScheme
// No hardcoded colors - all colors are theme-aware

// ─── Feed Tab ─────────────────────────────────────────────────
class FeedTab extends ConsumerStatefulWidget {
  const FeedTab({super.key});

  @override
  ConsumerState<FeedTab> createState() => _FeedTabState();
}

class _FeedTabState extends ConsumerState<FeedTab> {
  int _selectedFilter = 0;

  // index 0 = tous, 1-4 = catégories Supabase ENUM
  static const _filters = ['Pour toi', 'Workout', 'Nutrition', 'Lifestyle', 'Challenge'];
  static const _filterCategories = ['', 'Workout', 'Nutrition', 'Lifestyle', 'Challenge'];

  @override
  Widget build(BuildContext context) {
    final allPosts = ref.watch(postsNotifierProvider);
    final isLoading = ref.watch(postsLoadingProvider);
    final cs    = Theme.of(context).colorScheme;
    final l10n  = ref.watch(l10nProvider);

    final category = _filterCategories[_selectedFilter];
    final posts = category.isEmpty
        ? allPosts
        : allPosts.where((p) => p.category == category).toList();

    return RefreshIndicator(
      color: cs.onSurface,
      backgroundColor: cs.surface,
      onRefresh: () => ref.read(postsNotifierProvider.notifier).refresh(),
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        slivers: [

          // ── Section header ────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.communityEyebrow, style: GoogleFonts.inter(
                        color: cs.secondary, fontSize: 9,
                        fontWeight: FontWeight.w700, letterSpacing: 3,
                      )),
                      const SizedBox(height: 3),
                      Text(l10n.communityTopPosts, style: GoogleFonts.outfit(
                        color: cs.onSurface, fontSize: 24,
                        fontWeight: FontWeight.w800, letterSpacing: -0.5,
                      )),
                    ],
                  ),
                  const Spacer(),
                  Text(l10n.seeAll, style: GoogleFonts.inter(
                    color: cs.primary, fontSize: 11,
                    fontWeight: FontWeight.w700, letterSpacing: 0.3,
                  )),
                ],
              ),
            ),
          ),

          // ── Filter pills ──────────────────────────────────────
          SliverToBoxAdapter(
            child: SizedBox(
              height: 38,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                itemCount: _filters.length,
                itemBuilder: (_, i) => _FilterPill(
                  label: _filters[i],
                  selected: _selectedFilter == i,
                  onTap: () => setState(() => _selectedFilter = i),
                  colorScheme: cs,
                ),
              ),
            ),
          ),

          // ── Post list ─────────────────────────────────────────
          if (isLoading && posts.isEmpty)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
              sliver: SliverList.separated(
                itemCount: 2,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, __) => _FeedSkeletonCard(colorScheme: cs),
              ),
            )
          else if (posts.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(LucideIcons.fileText,
                      size: 40,
                      color: cs.onSurface.withValues(alpha: 0.2)),
                  const SizedBox(height: 12),
                  Text(
                    'Aucun post dans cette catégorie',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: cs.onSurface.withValues(alpha: 0.4),
                    ),
                  ),
                ],
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
              sliver: SliverList.separated(
                itemCount: posts.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, i) => _PostCard(post: posts[i], colorScheme: cs),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Filter Pill ──────────────────────────────────────────────
class _FilterPill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final ColorScheme colorScheme;
  const _FilterPill({required this.label, required this.selected, required this.onTap, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        decoration: BoxDecoration(
          color: selected ? colorScheme.primary : colorScheme.surface,
          borderRadius: BorderRadius.circular(50),
          border: Border.all(
            color: selected ? colorScheme.primary : colorScheme.outline,
          ),
        ),
        child: Text(label, style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: selected ? colorScheme.onPrimary : colorScheme.onSurface.withValues(alpha: 0.6),
        )),
      ),
    );
  }
}

// Mirrors _PostCard's exact structure/paddings/dimensions so the layout
// doesn't jump when the shimmer is swapped for real Supabase post data —
// only the dynamic (Supabase-sourced) content is shimmered; the surrounding
// chrome (header/filters above) stays static and untouched.
class _FeedSkeletonCard extends StatelessWidget {
  final ColorScheme colorScheme;
  const _FeedSkeletonCard({required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    // The card frame (background/border/shadow) stays static, exactly like
    // the real _PostCard — only the placeholder shapes inside shimmer, the
    // same principle used in comment_sheet.dart's _CommentSkeletonRow.
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outline),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Shimmer.fromColors(
        baseColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
        highlightColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.95),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header — matches _PostCard's header padding exactly ──────
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 8, 10),
              child: Row(
                children: [
                  Container(width: 40, height: 40, decoration: BoxDecoration(color: colorScheme.surfaceContainerHighest, shape: BoxShape.circle)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SkeletonBox(height: 12, width: 120, radius: 6, colorScheme: colorScheme),
                        const SizedBox(height: 6),
                        _SkeletonBox(height: 10, width: 90, radius: 6, colorScheme: colorScheme),
                      ],
                    ),
                  ),
                  const SizedBox(width: 36),
                ],
              ),
            ),

            // ── Title + content — matches _PostCard's text padding exactly ──
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SkeletonBox(height: 14, width: double.infinity, radius: 6, colorScheme: colorScheme),
                  const SizedBox(height: 8),
                  _SkeletonBox(height: 14, width: 220, radius: 6, colorScheme: colorScheme),
                ],
              ),
            ),

            // ── Image — full-bleed, same height as the real post image ──
            _SkeletonBox(height: 200, width: double.infinity, radius: 0, colorScheme: colorScheme),

            // ── Actions — matches _PostCard's 4 actions exactly ─────────
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 12, 12),
              child: Row(
                children: [
                  _SkeletonBox(height: 30, width: 68, radius: 50, colorScheme: colorScheme),
                  const SizedBox(width: 8),
                  _SkeletonBox(height: 30, width: 78, radius: 50, colorScheme: colorScheme),
                  const Spacer(),
                  _SkeletonBox(height: 30, width: 30, radius: 15, colorScheme: colorScheme),
                  const SizedBox(width: 8),
                  _SkeletonBox(height: 30, width: 30, radius: 15, colorScheme: colorScheme),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Before/After Image ───────────────────────────────────────
class _BeforeAfterImage extends StatelessWidget {
  final String url;
  final String label;
  final ColorScheme cs;
  const _BeforeAfterImage({required this.url, required this.label, required this.cs});

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
        top: 8, left: 8,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(label, style: GoogleFonts.inter(
            fontSize: 10, fontWeight: FontWeight.w700,
            color: Colors.white, letterSpacing: 0.3,
          )),
        ),
      ),
    ]);
  }
}

class _SkeletonBox extends StatelessWidget {
  final double height;
  final double? width;
  final double radius;
  final ColorScheme colorScheme;

  const _SkeletonBox({required this.height, this.width, required this.radius, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

// ─── Post Card ────────────────────────────────────────────────
class _PostCard extends ConsumerStatefulWidget {
  final PostModel post;
  final ColorScheme colorScheme;
  const _PostCard({required this.post, required this.colorScheme});

  @override
  ConsumerState<_PostCard> createState() => _PostCardState();
}

class _PostCardState extends ConsumerState<_PostCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _heartCtrl;
  late Animation<double> _heartScale;

  @override
  void initState() {
    super.initState();
    _heartCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 280));
    _heartScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.35), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.35, end: 0.9), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 0.9, end: 1.0), weight: 30),
    ]).animate(CurvedAnimation(parent: _heartCtrl, curve: Curves.easeOut));
  }

  @override
  void dispose() { _heartCtrl.dispose(); super.dispose(); }

  void _toggleLike() {
    final notifier = ref.read(postsNotifierProvider.notifier);
    final wasLiked = notifier.isLiked(widget.post.id);
    notifier.toggleLike(widget.post.id);
    if (!wasLiked) _heartCtrl.forward(from: 0);
  }

  void _confirmDelete(String postId) {
    final cs = Theme.of(context).colorScheme;
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Supprimer le post ?',
            style: GoogleFonts.outfit(fontWeight: FontWeight.w800)),
        content: Text(
            'Cette action est irréversible.',
            style: GoogleFonts.inter(fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Annuler',
                style: GoogleFonts.inter(color: cs.onSurface.withValues(alpha: 0.6))),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final ok = await ref
                  .read(postsNotifierProvider.notifier)
                  .deletePost(postId);
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                behavior: SnackBarBehavior.floating,
                backgroundColor: ok ? cs.primary : cs.error,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                content: Text(
                  ok ? 'Post supprimé.' : 'Erreur lors de la suppression.',
                  style: GoogleFonts.inter(
                      color: ok ? cs.onPrimary : cs.onError,
                      fontWeight: FontWeight.w600),
                ),
              ));
            },
            child: Text('Supprimer',
                style: GoogleFonts.inter(
                    color: cs.error, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  void _openComments() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CommentSheet(
        postId: widget.post.id,
        postAuthor: widget.post.username,
      ),
    );
  }

  void _openProfile() {
    final uid = widget.post.userId.isNotEmpty
        ? widget.post.userId
        : widget.post.username;
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => UserProfileScreen(
        userId: uid,
        heroTag: 'avatar_$uid',
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    // Watch the provider so likes/comments update reactively
    final posts = ref.watch(postsNotifierProvider);
    final post  = posts.firstWhere(
      (p) => p.id == widget.post.id,
      orElse: () => widget.post,
    );
    final liked         = ref.read(postsNotifierProvider.notifier).isLiked(post.id);
    final isBeforeAfter = post.isBeforeAfter;
    final hasImage      = !isBeforeAfter && post.imageUrl.trim().isNotEmpty;
    final category      = post.category;
    final cs = widget.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.outline),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ── Header ──────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 8, 10),
            child: Row(children: [
              GestureDetector(
                onTap: _openProfile,
                child: Hero(
                  tag: 'avatar_${post.userId.isNotEmpty ? post.userId : post.username}',
                  child: CommunityAvatar(
                    avatarUrl: post.userAvatarUrl,
                    name: post.username,
                    radius: 20,
                    mascotType: post.mascotType,
                    mascotMood: post.mascotMood,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: _openProfile,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Flexible(child: Text(post.username, overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.outfit(
                            fontSize: 14, fontWeight: FontWeight.w700,
                            color: cs.onSurface, letterSpacing: -0.2,
                          )),
                        ),
                        if (post.isPro) ...[
                          const SizedBox(width: 5),
                          const Icon(LucideIcons.crown, size: 13, color: Color(0xFFF59E0B)),
                        ],
                      ]),
                      const SizedBox(height: 3),
                      Row(children: [
                        Text(post.timeAgo, style: GoogleFonts.inter(
                          fontSize: 11, color: cs.onSurface.withValues(alpha: 0.6),
                        )),
                        if (category.isNotEmpty) ...[
                          const SizedBox(width: 6),
                          Container(width: 3, height: 3,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle, color: cs.outline.withValues(alpha: 0.3))),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: cs.primary.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(category, style: GoogleFonts.inter(
                              fontSize: 10, fontWeight: FontWeight.w700,
                              color: cs.primary,
                            )),
                          ),
                        ],
                      ]),
                    ],
                  ),
                ),
              ),
              if (post.userId.isNotEmpty &&
                  post.userId == SupabaseConfig.userId)
                PopupMenuButton<String>(
                  icon: Icon(CupertinoIcons.ellipsis,
                      color: cs.onSurface.withValues(alpha: 0.6), size: 18),
                  padding: const EdgeInsets.all(6),
                  color: cs.surface,
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  itemBuilder: (_) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(children: [
                        Icon(LucideIcons.pencil, size: 18, color: cs.primary),
                        const SizedBox(width: 12),
                        Text('Modifier', style: GoogleFonts.inter(
                          fontSize: 14, fontWeight: FontWeight.w600, color: cs.onSurface)),
                      ]),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(children: [
                        Icon(LucideIcons.trash2, size: 18, color: cs.error),
                        const SizedBox(width: 12),
                        Text('Supprimer', style: GoogleFonts.inter(
                          fontSize: 14, fontWeight: FontWeight.w600, color: cs.error)),
                      ]),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'edit') {
                      showModalBottomSheet<void>(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) => FeedComposerSheet(post: post),
                      );
                    } else {
                      _confirmDelete(post.id);
                    }
                  },
                )
              else
                const SizedBox(width: 36),
            ]),
          ),

          // ── Post title + content ─────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (post.title.isNotEmpty) ...[
                  Text(post.title, style: GoogleFonts.outfit(
                    fontSize: 16, fontWeight: FontWeight.w800,
                    color: cs.onSurface, letterSpacing: -0.3, height: 1.3,
                  )),
                  if (post.content.isNotEmpty) const SizedBox(height: 4),
                ],
                if (post.content.isNotEmpty)
                  Text(post.content, style: GoogleFonts.inter(
                    fontSize: 14, color: cs.onSurface,
                    height: 1.5, letterSpacing: -0.1,
                  )),
              ],
            ),
          ),

          // ── Image ────────────────────────────────────────────
          if (isBeforeAfter)
            GestureDetector(
              onDoubleTap: _toggleLike,
              child: SizedBox(
                height: 200, width: double.infinity,
                child: Row(children: [
                  Expanded(child: _BeforeAfterImage(
                    url: post.beforeImageUrl, label: 'Avant', cs: cs)),
                  Container(width: 2, color: cs.surface),
                  Expanded(child: _BeforeAfterImage(
                    url: post.afterImageUrl, label: 'Après', cs: cs)),
                ]),
              ),
            )
          else if (hasImage)
            GestureDetector(
              onDoubleTap: _toggleLike,
              child: Container(
                constraints: const BoxConstraints(maxHeight: 320),
                width: double.infinity,
                color: cs.surfaceContainerHighest.withValues(alpha: 0.4),
                child: Image.network(
                  post.imageUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Container(
                    height: 200,
                    color: cs.primary.withValues(alpha: 0.08),
                  ),
                ),
              ),
            ),

          // ── Actions ──────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 12, 12),
            child: Row(children: [
              // Like
              GestureDetector(
                onTap: _toggleLike,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: liked
                        ? const Color(0xFFFF375F).withValues(alpha: 0.08)
                        : cs.outline.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Row(children: [
                    ScaleTransition(
                      scale: _heartScale,
                      child: Icon(
                        liked ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
                        size: 16,
                        color: liked ? const Color(0xFFFF375F) : cs.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text('${post.likes}', style: GoogleFonts.inter(
                      fontSize: 12, fontWeight: FontWeight.w700,
                      color: liked ? const Color(0xFFFF375F) : cs.onSurface.withValues(alpha: 0.6),
                    )),
                  ]),
                ),
              ),
              const SizedBox(width: 8),

              // Comment
              GestureDetector(
                onTap: _openComments,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: cs.outline.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Row(children: [
                    Icon(CupertinoIcons.chat_bubble,
                        size: 15, color: cs.onSurface.withValues(alpha: 0.6)),
                    const SizedBox(width: 5),
                    Text('${post.comments}', style: GoogleFonts.inter(
                      fontSize: 12, fontWeight: FontWeight.w700,
                      color: cs.onSurface.withValues(alpha: 0.6),
                    )),
                  ]),
                ),
              ),

              const Spacer(),

              // Bookmark
              GestureDetector(
                onTap: () {},
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: cs.outline.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Icon(CupertinoIcons.bookmark,
                      size: 15, color: cs.onSurface.withValues(alpha: 0.6)),
                ),
              ),
              const SizedBox(width: 8),

              // Share
              GestureDetector(
                onTap: () {},
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: cs.outline.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Icon(CupertinoIcons.share,
                      size: 15, color: cs.onSurface.withValues(alpha: 0.6)),
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}
