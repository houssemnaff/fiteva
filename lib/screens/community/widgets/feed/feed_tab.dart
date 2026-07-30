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

// ─── Feed Tab ─────────────────────────────────────────────────
class FeedTab extends ConsumerStatefulWidget {
  const FeedTab({super.key});

  @override
  ConsumerState<FeedTab> createState() => _FeedTabState();
}

class _FeedTabState extends ConsumerState<FeedTab> {
  int _selectedFilter = 0;

  static const _filters = ['Pour toi', 'Workout', 'Nutrition', 'Lifestyle', 'Challenge'];
  static const _filterCategories = ['', 'Workout', 'Nutrition', 'Lifestyle', 'Challenge'];

  @override
  Widget build(BuildContext context) {
    final allPosts = ref.watch(postsNotifierProvider);
    final isLoading = ref.watch(postsLoadingProvider);
    final cs = Theme.of(context).colorScheme;
    final l10n = ref.watch(l10nProvider);

    final category = _filterCategories[_selectedFilter];
    final posts = category.isEmpty
        ? allPosts
        : allPosts.where((p) => p.category == category).toList();

    return RefreshIndicator(
      color: cs.primary,
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
                  GestureDetector(
                    onTap: () => _showFilterSheet(context, cs),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _selectedFilter == 0
                            ? cs.onSurface.withValues(alpha: 0.05)
                            : cs.primary.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(LucideIcons.slidersHorizontal, size: 13,
                            color: _selectedFilter == 0
                                ? cs.onSurface.withValues(alpha: 0.45)
                                : cs.primary),
                          const SizedBox(width: 5),
                          Text(
                            _selectedFilter == 0 ? 'Filtres' : _filters[_selectedFilter],
                            style: GoogleFonts.inter(
                              fontSize: 12, fontWeight: FontWeight.w600,
                              color: _selectedFilter == 0
                                  ? cs.onSurface.withValues(alpha: 0.5)
                                  : cs.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 8)),

          // ── Post list ─────────────────────────────────────────
          if (isLoading && posts.isEmpty)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(0, 8, 0, 100),
              sliver: SliverList.separated(
                itemCount: 3,
                separatorBuilder: (_, __) => _Divider(cs: cs),
                itemBuilder: (_, __) => _FeedSkeletonCard(cs: cs),
              ),
            )
          else if (posts.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(LucideIcons.fileText,
                      size: 40, color: cs.onSurface.withValues(alpha: 0.15)),
                  const SizedBox(height: 12),
                  Text('Aucun post dans cette catégorie',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: cs.onSurface.withValues(alpha: 0.35),
                    )),
                ],
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(0, 8, 0, 100),
              sliver: SliverList.separated(
                itemCount: posts.length,
                separatorBuilder: (_, __) => _Divider(cs: cs),
                itemBuilder: (_, i) => _PostCard(post: posts[i]),
              ),
            ),
        ],
      ),
    );
  }

  void _showFilterSheet(BuildContext context, ColorScheme cs) {
    showModalBottomSheet(
      context: context,
      backgroundColor: cs.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36, height: 4,
                decoration: BoxDecoration(
                  color: cs.onSurface.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text('Filtrer par catégorie', style: GoogleFonts.outfit(
                fontSize: 16, fontWeight: FontWeight.w700, color: cs.onSurface)),
              const SizedBox(height: 16),
              ...List.generate(_filters.length, (i) {
                final active = _selectedFilter == i;
                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedFilter = i);
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                    margin: const EdgeInsets.only(bottom: 6),
                    decoration: BoxDecoration(
                      color: active ? cs.primary.withValues(alpha: 0.08) : Colors.transparent,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: active ? cs.primary.withValues(alpha: 0.3) : cs.onSurface.withValues(alpha: 0.06),
                      ),
                    ),
                    child: Row(children: [
                      Text(_filters[i], style: GoogleFonts.inter(
                        fontSize: 14, fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                        color: active ? cs.primary : cs.onSurface.withValues(alpha: 0.6),
                      )),
                      const Spacer(),
                      if (active)
                        Icon(LucideIcons.check, size: 16, color: cs.primary),
                    ]),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Divider ─────────────────────────────────────────────────
class _Divider extends StatelessWidget {
  final ColorScheme cs;
  const _Divider({required this.cs});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 0.5,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      color: cs.outline.withValues(alpha: 0.15),
    );
  }
}

// ─── Filter Chip ─────────────────────────────────────────────
class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final ColorScheme cs;
  const _FilterChip({required this.label, required this.selected, required this.onTap, required this.cs});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? cs.onSurface : Colors.transparent,
          borderRadius: BorderRadius.circular(50),
          border: Border.all(
            color: selected
                ? cs.onSurface
                : cs.onSurface.withValues(alpha: 0.12),
          ),
        ),
        child: Text(label, style: GoogleFonts.inter(
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
          color: selected ? cs.surface : cs.onSurface.withValues(alpha: 0.5),
        )),
      ),
    );
  }
}

// ─── Skeleton ────────────────────────────────────────────────
class _FeedSkeletonCard extends StatelessWidget {
  final ColorScheme cs;
  const _FeedSkeletonCard({required this.cs});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: cs.surfaceContainerHighest.withValues(alpha: 0.5),
      highlightColor: cs.surfaceContainerHighest.withValues(alpha: 0.9),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Container(width: 40, height: 40, decoration: BoxDecoration(
                color: cs.surfaceContainerHighest, shape: BoxShape.circle)),
              const SizedBox(width: 12),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(width: 110, height: 12, decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest, borderRadius: BorderRadius.circular(6))),
                const SizedBox(height: 6),
                Container(width: 70, height: 10, decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest, borderRadius: BorderRadius.circular(6))),
              ]),
            ]),
            const SizedBox(height: 14),
            Container(width: double.infinity, height: 14, decoration: BoxDecoration(
              color: cs.surfaceContainerHighest, borderRadius: BorderRadius.circular(6))),
            const SizedBox(height: 8),
            Container(width: 200, height: 14, decoration: BoxDecoration(
              color: cs.surfaceContainerHighest, borderRadius: BorderRadius.circular(6))),
            const SizedBox(height: 14),
            Container(width: double.infinity, height: 220,
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
              )),
            const SizedBox(height: 14),
            Row(children: [
              Container(width: 60, height: 12, decoration: BoxDecoration(
                color: cs.surfaceContainerHighest, borderRadius: BorderRadius.circular(6))),
              const SizedBox(width: 20),
              Container(width: 60, height: 12, decoration: BoxDecoration(
                color: cs.surfaceContainerHighest, borderRadius: BorderRadius.circular(6))),
            ]),
          ],
        ),
      ),
    );
  }
}

// ─── Before/After Image ──────────────────────────────────────
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
        child: Image.network(url, fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            color: cs.primary.withValues(alpha: 0.08))),
      ),
      Positioned(
        top: 8, left: 8,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.6),
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

// ─── Post Card ───────────────────────────────────────────────
class _PostCard extends ConsumerStatefulWidget {
  final PostModel post;
  const _PostCard({required this.post});

  @override
  ConsumerState<_PostCard> createState() => _PostCardState();
}

class _PostCardState extends ConsumerState<_PostCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _heartCtrl;
  late Animation<double> _heartScale;
  bool _showBigHeart = false;

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

  void _doubleTapLike() {
    final notifier = ref.read(postsNotifierProvider.notifier);
    final wasLiked = notifier.isLiked(widget.post.id);
    if (!wasLiked) {
      notifier.toggleLike(widget.post.id);
      _heartCtrl.forward(from: 0);
    }
    setState(() => _showBigHeart = true);
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) setState(() => _showBigHeart = false);
    });
  }

  void _confirmDelete(String postId) {
    final cs = Theme.of(context).colorScheme;
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Supprimer le post ?',
            style: GoogleFonts.outfit(fontWeight: FontWeight.w800)),
        content: Text('Cette action est irréversible.',
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
              final ok = await ref.read(postsNotifierProvider.notifier).deletePost(postId);
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                behavior: SnackBarBehavior.floating,
                backgroundColor: ok ? cs.primary : cs.error,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                content: Text(
                  ok ? 'Post supprimé.' : 'Erreur lors de la suppression.',
                  style: GoogleFonts.inter(
                      color: ok ? cs.onPrimary : cs.onError,
                      fontWeight: FontWeight.w600)),
              ));
            },
            child: Text('Supprimer',
                style: GoogleFonts.inter(color: cs.error, fontWeight: FontWeight.w700)),
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
      builder: (_) => UserProfileScreen(userId: uid, heroTag: 'avatar_$uid'),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final posts = ref.watch(postsNotifierProvider);
    final post = posts.firstWhere(
      (p) => p.id == widget.post.id,
      orElse: () => widget.post,
    );
    final liked = ref.read(postsNotifierProvider.notifier).isLiked(post.id);
    final isBeforeAfter = post.isBeforeAfter;
    final hasImage = !isBeforeAfter && post.imageUrl.trim().isNotEmpty;
    final category = post.category;
    final cs = Theme.of(context).colorScheme;
    final isOwn = post.userId.isNotEmpty && post.userId == SupabaseConfig.userId;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────────────
          Row(children: [
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
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: _openProfile,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Flexible(
                        child: Text(post.username,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.outfit(
                            fontSize: 14.5, fontWeight: FontWeight.w700,
                            color: cs.onSurface, letterSpacing: -0.2,
                          )),
                      ),
                      if (post.isPro) ...[
                        const SizedBox(width: 5),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text('PRO', style: GoogleFonts.inter(
                            fontSize: 8.5, fontWeight: FontWeight.w800,
                            color: const Color(0xFFF59E0B), letterSpacing: 0.5,
                          )),
                        ),
                      ],
                      if (category.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Container(
                          width: 3, height: 3,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: cs.onSurface.withValues(alpha: 0.2),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(category, style: GoogleFonts.inter(
                          fontSize: 12, fontWeight: FontWeight.w500,
                          color: cs.primary,
                        )),
                      ],
                    ]),
                    const SizedBox(height: 2),
                    Text(post.timeAgo, style: GoogleFonts.inter(
                      fontSize: 12, color: cs.onSurface.withValues(alpha: 0.4),
                    )),
                  ],
                ),
              ),
            ),
            if (isOwn)
              PopupMenuButton<String>(
                icon: Icon(CupertinoIcons.ellipsis,
                    color: cs.onSurface.withValues(alpha: 0.4), size: 18),
                padding: EdgeInsets.zero,
                color: cs.surface,
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                itemBuilder: (_) => [
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(children: [
                      Icon(LucideIcons.pencil, size: 16, color: cs.primary),
                      const SizedBox(width: 10),
                      Text('Modifier', style: GoogleFonts.inter(
                        fontSize: 13, fontWeight: FontWeight.w600, color: cs.onSurface)),
                    ]),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(children: [
                      Icon(LucideIcons.trash2, size: 16, color: cs.error),
                      const SizedBox(width: 10),
                      Text('Supprimer', style: GoogleFonts.inter(
                        fontSize: 13, fontWeight: FontWeight.w600, color: cs.error)),
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
              ),
          ]),

          // ── Text content ────────────────────────────────────
          if (post.title.isNotEmpty || post.content.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (post.title.isNotEmpty)
                    Text(post.title, style: GoogleFonts.outfit(
                      fontSize: 16, fontWeight: FontWeight.w700,
                      color: cs.onSurface, letterSpacing: -0.3, height: 1.3,
                    )),
                  if (post.title.isNotEmpty && post.content.isNotEmpty)
                    const SizedBox(height: 4),
                  if (post.content.isNotEmpty)
                    Text(post.content, style: GoogleFonts.inter(
                      fontSize: 14.5, color: cs.onSurface.withValues(alpha: 0.85),
                      height: 1.5, letterSpacing: -0.1,
                    )),
                ],
              ),
            ),

          // ── Image ───────────────────────────────────────────
          if (isBeforeAfter)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: GestureDetector(
                onDoubleTap: _doubleTapLike,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(children: [
                    SizedBox(
                      height: 220, width: double.infinity,
                      child: Row(children: [
                        Expanded(child: _BeforeAfterImage(
                          url: post.beforeImageUrl, label: 'Avant', cs: cs)),
                        Container(width: 2, color: cs.surface),
                        Expanded(child: _BeforeAfterImage(
                          url: post.afterImageUrl, label: 'Après', cs: cs)),
                      ]),
                    ),
                    if (_showBigHeart) _BigHeartOverlay(height: 220),
                  ]),
                ),
              ),
            )
          else if (hasImage)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: GestureDetector(
                onDoubleTap: _doubleTapLike,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(children: [
                    Container(
                      constraints: const BoxConstraints(maxHeight: 360),
                      width: double.infinity,
                      color: cs.surfaceContainerHighest.withValues(alpha: 0.3),
                      child: Image.network(post.imageUrl, fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          height: 200,
                          color: cs.primary.withValues(alpha: 0.06),
                        )),
                    ),
                    if (_showBigHeart) _BigHeartOverlay(height: 360),
                  ]),
                ),
              ),
            ),

          // ── Actions ─────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Row(children: [
              // Like
              GestureDetector(
                onTap: _toggleLike,
                child: Row(children: [
                  ScaleTransition(
                    scale: _heartScale,
                    child: Icon(
                      liked ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
                      size: 22,
                      color: liked
                          ? const Color(0xFFFF375F)
                          : cs.onSurface.withValues(alpha: 0.45),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text('${post.likes}', style: GoogleFonts.inter(
                    fontSize: 13, fontWeight: FontWeight.w600,
                    color: liked
                        ? const Color(0xFFFF375F)
                        : cs.onSurface.withValues(alpha: 0.45),
                  )),
                ]),
              ),

              const SizedBox(width: 22),

              // Comment
              GestureDetector(
                onTap: _openComments,
                child: Row(children: [
                  Icon(CupertinoIcons.chat_bubble,
                      size: 20, color: cs.onSurface.withValues(alpha: 0.45)),
                  const SizedBox(width: 6),
                  Text('${post.comments}', style: GoogleFonts.inter(
                    fontSize: 13, fontWeight: FontWeight.w600,
                    color: cs.onSurface.withValues(alpha: 0.45),
                  )),
                ]),
              ),

            ]),
          ),
        ],
      ),
    );
  }
}

// ─── Big Heart Overlay (double-tap like Instagram) ───────────
class _BigHeartOverlay extends StatefulWidget {
  final double height;
  const _BigHeartOverlay({required this.height});

  @override
  State<_BigHeartOverlay> createState() => _BigHeartOverlayState();
}

class _BigHeartOverlayState extends State<_BigHeartOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();

    _scale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.2), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 1.2, end: 0.95), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 0.95, end: 1.0), weight: 15),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 35),
    ]).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));

    _opacity = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 30),
    ]).animate(_ctrl);
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) => Opacity(
          opacity: _opacity.value,
          child: Center(
            child: Transform.scale(
              scale: _scale.value,
              child: const Icon(
                CupertinoIcons.heart_fill,
                size: 80,
                color: Colors.white,
                shadows: [
                  Shadow(color: Colors.black26, blurRadius: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
