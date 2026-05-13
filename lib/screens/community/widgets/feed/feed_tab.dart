import 'package:fiteva/models/post_model.dart';
import 'package:fiteva/providers/mock_data_provider.dart';
import 'package:fiteva/screens/community/UserProfileScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../theme/app_theme.dart';
import '../shared/community_shared_widgets.dart';
import 'feed_composer_sheet.dart';

// ─────────────────────────────────────────────────────────────
// Feed Tab
// ─────────────────────────────────────────────────────────────
class FeedTab extends ConsumerStatefulWidget {
  const FeedTab({super.key});

  @override
  ConsumerState<FeedTab> createState() => _FeedTabState();
}

class _FeedTabState extends ConsumerState<FeedTab> {
  int _selectedFilter = 0;

  static const _feedFilters = [
    'For you',
    'Workout',
    'Nutrition',
    'Before/After',
    'Challenge',
  ];

  @override
  Widget build(BuildContext context) {
    final posts = ref.watch(postsProvider);

    return CustomScrollView(
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      slivers: [
        // ── Create post bar ───────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: _CreatePostBar(
              onTap: () => showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => const FeedComposerSheet(),
              ),
            ),
          ),
        ),

        // ── Section header ────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
            child: SectionHeaderComm(
              title: 'Top posts',
              actionLabel: 'See all',
              onActionTap: () {},
            ),
          ),
        ),

        // ── Filter pills ──────────────────────────────────────
        SliverToBoxAdapter(
          child: SizedBox(
            height: 34,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _feedFilters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) => _FilterPill(
                label: _feedFilters[index],
                selected: _selectedFilter == index,
                onTap: () => setState(() => _selectedFilter = index),
              ),
            ),
          ),
        ),

        // ── Post list ─────────────────────────────────────────
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
          sliver: SliverToBoxAdapter(
            child: _PostGroup(posts: posts),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Post Group — wraps all cards in one rounded container
// ─────────────────────────────────────────────────────────────
class _PostGroup extends StatelessWidget {
  final List<PostModel> posts;

  const _PostGroup({required this.posts});

  @override
  Widget build(BuildContext context) {
    if (posts.isEmpty) return const SizedBox.shrink();

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Column(
        children: [
          for (int i = 0; i < posts.length; i++) ...[
            _PostCard(post: posts[i]),
            if (i < posts.length - 1)
              const Divider(
                height: 0,
                thickness: 0.5,
                color: Colors.white,
              ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Create Post Bar
// ─────────────────────────────────────────────────────────────
class _CreatePostBar extends StatelessWidget {
  final VoidCallback onTap;

  const _CreatePostBar({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white, width: 0.5),
        ),
        child: Row(
          children: [
            // Avatar placeholder
            Container(
              width: 34,
              height: 34,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: const Icon(
                CupertinoIcons.person_fill,
                color: Color(0xFF1C4D30),
                size: 16,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                "What's on your mind?",
                style: TextStyle(
                  fontSize: 15,
                  color: Color(0xFFAEAEB2),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            const SizedBox(width: 8),
            _ActionIconButton(icon: CupertinoIcons.photo),
            const SizedBox(width: 6),
            _ActionIconButton(icon: CupertinoIcons.video_camera_solid),
          ],
        ),
      ),
    );
  }
}

class _ActionIconButton extends StatelessWidget {
  final IconData icon;

  const _ActionIconButton({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 30,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFFF2F2F7),
      ),
      child: Icon(icon, size: 14, color: const Color(0xFF3C3C43)),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Filter Pill
// ─────────────────────────────────────────────────────────────
class _FilterPill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        height: 30,
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF1C4D30) : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected
                ? const Color(0xFF1C4D30)
                : const Color(0xFFE5E5EA),
            width: 0.5,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: selected ? Colors.white : const Color(0xFF3C3C43),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Post Card
// ─────────────────────────────────────────────────────────────
class _PostCard extends StatefulWidget {
  final PostModel post;

  const _PostCard({required this.post});

  @override
  State<_PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<_PostCard>
    with SingleTickerProviderStateMixin {
  bool _liked = false;
  late int _likeCount;
  late AnimationController _heartController;
  late Animation<double> _heartScale;

  @override
  void initState() {
    super.initState();
    _likeCount = widget.post.likes;
    _heartController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _heartScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.35), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.35, end: 0.9), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 0.9, end: 1.0), weight: 30),
    ]).animate(
      CurvedAnimation(parent: _heartController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _heartController.dispose();
    super.dispose();
  }

  void _toggleLike() {
    setState(() {
      _liked = !_liked;
      _likeCount += _liked ? 1 : -1;
    });
    if (_liked) _heartController.forward(from: 0);
  }

  /// Navigates to the profile of the post author.
  /// Uses [widget.post.username] as the userId fallback if your PostModel
  /// doesn't have a dedicated userId field yet — swap to widget.post.userId
  /// once you add it.
  void _openProfile() {
    // ⚠️  Change widget.post.username → widget.post.userId once that field exists
    final userId = widget.post.username;
    final heroTag = 'avatar_$userId';

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => UserProfileScreen(
          userId: userId,
          heroTag: heroTag,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasImage = widget.post.imageUrl.trim().isNotEmpty;
    // ⚠️  Same note: swap to widget.post.userId once that field exists
    final userId = widget.post.username;
    final heroTag = 'avatar_$userId';

    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 13, 8, 10),
            child: Row(
              children: [
                // ── Avatar (tappable → profile) ───────────────
                GestureDetector(
                  onTap: _openProfile,
                  child: Hero(
                    tag: heroTag,
                    child: CircleAvatar(
                      radius: 19,
                      backgroundImage: NetworkImage(widget.post.userAvatarUrl),
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // ── Name + meta (tappable → profile) ──────────
                Expanded(
                  child: GestureDetector(
                    onTap: _openProfile,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.post.username,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1C1C1E),
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            Text(
                              widget.post.timeAgo,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF8E8E93),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              width: 3,
                              height: 3,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFFC7C7CC),
                              ),
                            ),
                            const SizedBox(width: 6),
                            // Category tag badge
                            if ((widget.post.category ?? '').isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEEF2FF),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Text(
                                  widget.post.category ?? '',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF1C4D30),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // ── More button ───────────────────────────────
                CupertinoButton(
                  padding: const EdgeInsets.all(6),
                  minSize: 0,
                  onPressed: () {},
                  child: const Icon(
                    CupertinoIcons.ellipsis,
                    color: Color(0xFF8E8E93),
                    size: 20,
                  ),
                ),
              ],
            ),
          ),

          // ── Post text ────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
            child: Text(
              widget.post.content,
              style: const TextStyle(
                fontSize: 15,
                color: Color(0xFF1C1C1E),
                height: 1.45,
                letterSpacing: -0.1,
              ),
            ),
          ),

          // ── Image ────────────────────────────────────────────
          if (hasImage)
            GestureDetector(
              onDoubleTap: _toggleLike,
              child: SizedBox(
                height: 210,
                width: double.infinity,
                child: Image.network(
                  widget.post.imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),

          // ── Actions ──────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 4, 12, 10),
            child: Row(
              children: [
                // Like
                CupertinoButton(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  minSize: 0,
                  onPressed: _toggleLike,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ScaleTransition(
                        scale: _heartScale,
                        child: Icon(
                          _liked
                              ? CupertinoIcons.heart_fill
                              : CupertinoIcons.heart,
                          size: 21,
                          color: _liked
                              ? const Color(0xFFFF375F)
                              : const Color(0xFF8E8E93),
                        ),
                      ),
                      const SizedBox(width: 5),
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 180),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _liked
                              ? const Color(0xFFFF375F)
                              : const Color(0xFF8E8E93),
                        ),
                        child: Text('$_likeCount'),
                      ),
                    ],
                  ),
                ),

                // Comment
                CupertinoButton(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  minSize: 0,
                  onPressed: () {},
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        CupertinoIcons.chat_bubble,
                        size: 20,
                        color: Color(0xFF8E8E93),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        '${widget.post.comments}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF8E8E93),
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Share
                CupertinoButton(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  minSize: 0,
                  onPressed: () {},
                  child: const Icon(
                    CupertinoIcons.share,
                    size: 20,
                    color: Color(0xFF8E8E93),
                  ),
                ),

                // Bookmark
                CupertinoButton(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  minSize: 0,
                  onPressed: () {},
                  child: const Icon(
                    CupertinoIcons.bookmark,
                    size: 20,
                    color: Color(0xFF8E8E93),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}