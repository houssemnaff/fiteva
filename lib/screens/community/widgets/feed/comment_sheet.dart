import 'dart:async';
import 'package:fiteva/screens/community/providers/community_providers.dart';
import 'package:fiteva/services/comuniter_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../l10n/app_localizations.dart';


class CommentSheet extends ConsumerStatefulWidget {
  final String postId;
  final String postAuthor;
  const CommentSheet({super.key, required this.postId, required this.postAuthor});

  @override
  ConsumerState<CommentSheet> createState() => _CommentSheetState();
}

typedef _Comment = ({String text, String author, DateTime createdAt});

class _CommentSheetState extends ConsumerState<CommentSheet> {
  final _ctrl  = TextEditingController();
  final _focus = FocusNode();
  List<_Comment> _comments = [];
  bool _loading = false;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  Future<void> _loadComments() async {
    setState(() => _loading = true);
    final list = await CommunityService.loadComments(widget.postId);
    if (mounted) setState(() {
      _comments = list.map<_Comment>((comment) => (
        text: comment.text,
        author: comment.author,
        createdAt: comment.createdAt,
      )).toList();
      _loading = false;
    });
  }

  Future<void> _send() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    HapticFeedback.lightImpact();
    setState(() => _sending = true);
    final createdComment = await CommunityService.addComment(widget.postId, text);
    await ref.read(postsNotifierProvider.notifier).incrementComments(widget.postId);
    _ctrl.clear();
    if (mounted) {
      setState(() {
        _comments = [
          ..._comments,
          (
            text: createdComment?.text ?? text,
            author: createdComment?.author ?? 'Vous',
            createdAt: createdComment?.createdAt ?? DateTime.now(),
          ),
        ];
        _sending = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l10n = ref.watch(l10nProvider);
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withValues(alpha: 0.10),
            blurRadius: 24,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 6),
            width: 36, height: 4,
            decoration: BoxDecoration(
              color: cs.outline.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 14, 14),
            child: Row(children: [
              Text(l10n.communityComments,
                style: GoogleFonts.outfit(
                  fontSize: 19, fontWeight: FontWeight.w800,
                  color: cs.onSurface, letterSpacing: -0.4)),
              const SizedBox(width: 8),
              if (!_loading)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                  decoration: BoxDecoration(
                    color: cs.primary.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('${_comments.length}',
                    style: GoogleFonts.inter(
                      fontSize: 12, fontWeight: FontWeight.w700, color: cs.primary)),
                ),
              const Spacer(),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 34, height: 34,
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHighest, shape: BoxShape.circle),
                  child: Icon(LucideIcons.x, size: 15, color: cs.onSurface.withValues(alpha: 0.7)),
                ),
              ),
            ]),
          ),

          // Comment list
          Flexible(
            child: _loading
                ? ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                    itemCount: 3,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, __) => _CommentSkeletonRow(colorScheme: cs),
                  )
                : _comments.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 56, height: 56,
                              decoration: BoxDecoration(
                                color: cs.primary.withValues(alpha: 0.08),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(LucideIcons.messageCircle,
                                  size: 24, color: cs.primary.withValues(alpha: 0.6)),
                            ),
                            const SizedBox(height: 14),
                            Text(l10n.communityNoComments,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                  color: cs.onSurface.withValues(alpha: 0.6),
                                  fontSize: 13, height: 1.5)),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                        itemCount: _comments.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 10),
                        itemBuilder: (_, i) => _CommentRow(
                          text: _comments[i].text,
                          author: _comments[i].author,
                          createdAt: _comments[i].createdAt,
                          colorScheme: cs,
                        ),
                      ),
          ),

          // Input bar
          Container(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + bottom),
            decoration: BoxDecoration(
              color: cs.surface,
              border: Border(top: BorderSide(color: cs.outline.withValues(alpha: 0.4))),
            ),
            child: Row(children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHighest.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(color: cs.outline.withValues(alpha: 0.3)),
                  ),
                  child: TextField(
                    controller: _ctrl,
                    focusNode: _focus,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _send(),
                    style: GoogleFonts.inter(fontSize: 14, color: cs.onSurface),
                    decoration: InputDecoration(
                      hintText: l10n.communityAddComment,
                      hintStyle: GoogleFonts.inter(
                          color: cs.onSurface.withValues(alpha: 0.5), fontSize: 13),
                      filled: false,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: _sending ? null : _send,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft, end: Alignment.bottomRight,
                      colors: _sending
                          ? [cs.secondary, cs.secondary]
                          : [cs.primary, cs.primary.withValues(alpha: 0.75)],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: cs.primary.withValues(alpha: 0.28),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: _sending
                      ? Center(child: SizedBox(
                          width: 17, height: 17,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: cs.onPrimary)))
                      : Icon(LucideIcons.send,
                          color: cs.onPrimary, size: 17),
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}

class _CommentSkeletonRow extends StatelessWidget {
  final ColorScheme colorScheme;
  const _CommentSkeletonRow({required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    // Card frame stays static — only the placeholder shapes shimmer.
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Shimmer.fromColors(
        baseColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
        highlightColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.95),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 10, width: 90, decoration: BoxDecoration(color: colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(999))),
                  const SizedBox(height: 8),
                  Container(height: 10, width: double.infinity, decoration: BoxDecoration(color: colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(999))),
                  const SizedBox(height: 6),
                  Container(height: 10, width: 180, decoration: BoxDecoration(color: colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(999))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Deterministic accent color per author — gives each avatar a distinct,
// consistent gradient instead of a single flat tint for every commenter.
const _kAvatarGradients = [
  [Color(0xFFFF6B6B), Color(0xFFEE5A6F)],
  [Color(0xFF6C5CE7), Color(0xFF4834D4)],
  [Color(0xFF00B894), Color(0xFF00CEC9)],
  [Color(0xFFFDA085), Color(0xFFF6784E)],
  [Color(0xFF4A90D9), Color(0xFF2E6FBE)],
  [Color(0xFFA55EEA), Color(0xFF8854D0)],
];

class _CommentRow extends StatelessWidget {
  final String text;
  final String author;
  final DateTime createdAt;
  final ColorScheme colorScheme;
  const _CommentRow({required this.text, required this.author, required this.createdAt, required this.colorScheme});

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'à l\'instant';
    if (diff.inHours < 1) return 'il y a ${diff.inMinutes} min';
    if (diff.inDays < 1) return 'il y a ${diff.inHours}h';
    if (diff.inDays < 7) return 'il y a ${diff.inDays}j';
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final gradient = _kAvatarGradients[author.hashCode.abs() % _kAvatarGradients.length];

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34, height: 34,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft, end: Alignment.bottomRight,
                colors: gradient,
              ),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(author.isNotEmpty ? author[0].toUpperCase() : '?',
                style: GoogleFonts.outfit(
                  color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(author,
                      style: GoogleFonts.inter(
                        fontSize: 12.5, fontWeight: FontWeight.w700, color: colorScheme.onSurface)),
                    const SizedBox(width: 8),
                    Text(_timeAgo(createdAt),
                      style: GoogleFonts.inter(
                        fontSize: 11, color: colorScheme.onSurface.withValues(alpha: 0.5))),
                  ],
                ),
                const SizedBox(height: 4),
                Text(text,
                  style: GoogleFonts.inter(
                    fontSize: 13.5, color: colorScheme.onSurface, height: 1.45)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
