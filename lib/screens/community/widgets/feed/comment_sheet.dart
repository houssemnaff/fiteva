import 'dart:async';
import 'package:fiteva/screens/community/providers/community_providers.dart';
import 'package:fiteva/services/comuniter_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../providers/mascot_provider.dart';
import '../../../../widgets/mascot_widget.dart';
import '../community_avatar.dart';

class CommentSheet extends ConsumerStatefulWidget {
  final String postId;
  final String postAuthor;
  const CommentSheet({super.key, required this.postId, required this.postAuthor});

  @override
  ConsumerState<CommentSheet> createState() => _CommentSheetState();
}

typedef _Comment = ({
  String text,
  String author,
  DateTime createdAt,
  String mascotType,
  String mascotMood,
});

class _CommentSheetState extends ConsumerState<CommentSheet> {
  final _ctrl = TextEditingController();
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
        mascotType: comment.mascotType,
        mascotMood: comment.mascotMood,
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
      final myMascot = ref.read(mascotProvider);
      setState(() {
        _comments = [
          ..._comments,
          (
            text: createdComment?.text ?? text,
            author: createdComment?.author ?? 'Vous',
            createdAt: createdComment?.createdAt ?? DateTime.now(),
            mascotType: createdComment?.mascotType ?? myMascot.type.name,
            mascotMood: createdComment?.mascotMood ?? myMascot.mood.name,
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
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Handle ──────────────────────────────────────────
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 10, bottom: 4),
              width: 36, height: 4,
              decoration: BoxDecoration(
                color: cs.onSurface.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // ── Header ──────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 14, 12),
            child: Row(children: [
              Text(l10n.communityComments,
                style: GoogleFonts.outfit(
                  fontSize: 18, fontWeight: FontWeight.w800,
                  color: cs.onSurface, letterSpacing: -0.3)),
              const SizedBox(width: 8),
              if (!_loading)
                Text('${_comments.length}',
                  style: GoogleFonts.inter(
                    fontSize: 14, fontWeight: FontWeight.w600,
                    color: cs.onSurface.withValues(alpha: 0.35))),
              const Spacer(),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(
                    color: cs.onSurface.withValues(alpha: 0.06),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(LucideIcons.x, size: 14,
                      color: cs.onSurface.withValues(alpha: 0.5)),
                ),
              ),
            ]),
          ),

          // ── Thin divider ────────────────────────────────────
          Container(
            height: 0.5,
            color: cs.onSurface.withValues(alpha: 0.06),
          ),

          // ── Comment list ────────────────────────────────────
          Flexible(
            child: _loading
                ? ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                    itemCount: 4,
                    itemBuilder: (_, __) => _CommentSkeleton(cs: cs),
                  )
                : _comments.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 48),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(CupertinoIcons.chat_bubble_2,
                                size: 36,
                                color: cs.onSurface.withValues(alpha: 0.12)),
                            const SizedBox(height: 12),
                            Text('Sois le premier à commenter',
                              style: GoogleFonts.inter(
                                fontSize: 14, fontWeight: FontWeight.w500,
                                color: cs.onSurface.withValues(alpha: 0.3))),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                        itemCount: _comments.length,
                        itemBuilder: (_, i) => _CommentRow(
                          text: _comments[i].text,
                          author: _comments[i].author,
                          createdAt: _comments[i].createdAt,
                          mascotType: _comments[i].mascotType,
                          mascotMood: _comments[i].mascotMood,
                          cs: cs,
                          isLast: i == _comments.length - 1,
                        ),
                      ),
          ),

          // ── Input bar ───────────────────────────────────────
          Container(
            padding: EdgeInsets.fromLTRB(20, 10, 12, 10 + bottom),
            decoration: BoxDecoration(
              color: cs.surface,
              border: Border(
                top: BorderSide(
                  color: cs.onSurface.withValues(alpha: 0.06),
                ),
              ),
            ),
            child: Row(children: [
              // Mascot avatar
              Consumer(builder: (_, ref2, __) {
                final mascot = ref2.watch(mascotProvider);
                return Container(
                  width: 34, height: 34,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: cs.primary.withValues(alpha: 0.10),
                  ),
                  child: ClipOval(
                    child: MascotWidget(
                      type: mascot.type, mood: mascot.mood, size: 34),
                  ),
                );
              }),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: cs.onSurface.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(22),
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
                          color: cs.onSurface.withValues(alpha: 0.3),
                          fontSize: 13.5),
                      filled: false,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(22),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _sending ? null : _send,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 38, height: 38,
                  decoration: BoxDecoration(
                    color: _sending
                        ? cs.onSurface.withValues(alpha: 0.08)
                        : cs.primary,
                    shape: BoxShape.circle,
                  ),
                  child: _sending
                      ? Center(child: SizedBox(
                          width: 15, height: 15,
                          child: CircularProgressIndicator(
                              strokeWidth: 1.8, color: cs.onPrimary)))
                      : Icon(LucideIcons.arrowUp,
                          color: cs.onPrimary, size: 18),
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}

// ─── Comment Skeleton ────────────────────────────────────────
class _CommentSkeleton extends StatelessWidget {
  final ColorScheme cs;
  const _CommentSkeleton({required this.cs});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Shimmer.fromColors(
        baseColor: cs.onSurface.withValues(alpha: 0.06),
        highlightColor: cs.onSurface.withValues(alpha: 0.12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(width: 34, height: 34,
              decoration: BoxDecoration(
                color: cs.onSurface, shape: BoxShape.circle)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 10, width: 100,
                    decoration: BoxDecoration(
                      color: cs.onSurface,
                      borderRadius: BorderRadius.circular(5))),
                  const SizedBox(height: 8),
                  Container(height: 10, width: double.infinity,
                    decoration: BoxDecoration(
                      color: cs.onSurface,
                      borderRadius: BorderRadius.circular(5))),
                  const SizedBox(height: 6),
                  Container(height: 10, width: 140,
                    decoration: BoxDecoration(
                      color: cs.onSurface,
                      borderRadius: BorderRadius.circular(5))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Avatar Colors ───────────────────────────────────────────
const _kAvatarColors = [
  Color(0xFFFF6B6B),
  Color(0xFF6C5CE7),
  Color(0xFF00B894),
  Color(0xFFFDA085),
  Color(0xFF4A90D9),
  Color(0xFFA55EEA),
  Color(0xFFFF9FF3),
  Color(0xFF2ED573),
];

// ─── Comment Row ─────────────────────────────────────────────
class _CommentRow extends ConsumerWidget {
  final String text;
  final String author;
  final DateTime createdAt;
  final String mascotType;
  final String mascotMood;
  final ColorScheme cs;
  final bool isLast;
  const _CommentRow({
    required this.text, required this.author,
    required this.createdAt, required this.cs,
    this.mascotType = 'blob', this.mascotMood = 'happy',
    this.isLast = false,
  });

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'maintenant';
    if (diff.inHours < 1) return '${diff.inMinutes}min';
    if (diff.inDays < 1) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}j';
    return '${date.day}/${date.month}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Author's mascot avatar
          CommunityAvatar(
            avatarUrl: '',
            name: author,
            radius: 17,
            mascotType: mascotType,
            mascotMood: mascotMood,
          ),
          const SizedBox(width: 12),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name + text in a bubble
                Container(
                  padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
                  decoration: BoxDecoration(
                    color: cs.onSurface.withValues(alpha: 0.04),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(4),
                      topRight: Radius.circular(18),
                      bottomLeft: Radius.circular(18),
                      bottomRight: Radius.circular(18),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(author,
                        style: GoogleFonts.inter(
                          fontSize: 12.5, fontWeight: FontWeight.w700,
                          color: cs.onSurface)),
                      const SizedBox(height: 3),
                      Text(text,
                        style: GoogleFonts.inter(
                          fontSize: 13.5,
                          color: cs.onSurface.withValues(alpha: 0.8),
                          height: 1.4)),
                    ],
                  ),
                ),

                // Meta row: time + reply
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 6, 0, 8),
                  child: Row(children: [
                    Text(_timeAgo(createdAt),
                      style: GoogleFonts.inter(
                        fontSize: 11.5, fontWeight: FontWeight.w500,
                        color: cs.onSurface.withValues(alpha: 0.3))),
                    const SizedBox(width: 16),
                    Text('Répondre',
                      style: GoogleFonts.inter(
                        fontSize: 11.5, fontWeight: FontWeight.w700,
                        color: cs.onSurface.withValues(alpha: 0.3))),
                  ]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
