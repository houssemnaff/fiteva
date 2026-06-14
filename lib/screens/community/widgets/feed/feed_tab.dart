import 'package:fiteva/models/post_model.dart';
import 'package:fiteva/screens/community/UserProfileScreen.dart';
import 'package:fiteva/screens/community/providers/community_providers.dart';
import 'package:fiteva/screens/community/widgets/feed/comment_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

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

  static const _filters = ['For you', 'Workout', 'Nutrition', 'Before/After', 'Challenge'];

  @override
  Widget build(BuildContext context) {
    final posts = ref.watch(postsNotifierProvider);
    final cs = Theme.of(context).colorScheme;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      slivers: [

        // ── Section header ────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('COMMUNITY', style: GoogleFonts.inter(
                      color: cs.secondary, fontSize: 9,
                      fontWeight: FontWeight.w700, letterSpacing: 3,
                    )),
                    const SizedBox(height: 3),
                    Text('Top Posts', style: GoogleFonts.outfit(
                      color: cs.onSurface, fontSize: 24,
                      fontWeight: FontWeight.w800, letterSpacing: -0.5,
                    )),
                  ],
                ),
                const Spacer(),
                Text('See all', style: GoogleFonts.inter(
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
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
          sliver: SliverList.separated(
            itemCount: posts.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) => _PostCard(post: posts[i], colorScheme: cs),
          ),
        ),
      ],
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
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => UserProfileScreen(
        userId: widget.post.username,
        heroTag: 'avatar_${widget.post.username}',
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
    final liked    = ref.read(postsNotifierProvider.notifier).isLiked(post.id);
    final hasImage = post.imageUrl.trim().isNotEmpty;
    final category = post.category;
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
                  tag: 'avatar_${post.username}',
                  child: CircleAvatar(
                    radius: 20,
                    backgroundImage: NetworkImage(post.userAvatarUrl),
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
                      Text(post.username, style: GoogleFonts.outfit(
                        fontSize: 14, fontWeight: FontWeight.w700,
                        color: cs.onSurface, letterSpacing: -0.2,
                      )),
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
              CupertinoButton(
                padding: const EdgeInsets.all(6),
                minimumSize: Size.zero,
                onPressed: () {},
                child: Icon(CupertinoIcons.ellipsis,
                    color: cs.onSurface.withValues(alpha: 0.6), size: 18),
              ),
            ]),
          ),

          // ── Post text ────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
            child: Text(post.content, style: GoogleFonts.inter(
              fontSize: 14, color: cs.onSurface,
              height: 1.5, letterSpacing: -0.1,
            )),
          ),

          // ── Image ────────────────────────────────────────────
          if (hasImage)
            GestureDetector(
              onDoubleTap: _toggleLike,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(0)),
                child: SizedBox(
                  height: 200, width: double.infinity,
                  child: Image.network(post.imageUrl, fit: BoxFit.cover),
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