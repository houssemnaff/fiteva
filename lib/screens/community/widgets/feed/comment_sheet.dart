import 'dart:async';
import 'package:fiteva/screens/community/providers/community_providers.dart';
import 'package:fiteva/services/comuniter_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';


class CommentSheet extends ConsumerStatefulWidget {
  final String postId;
  final String postAuthor;
  const CommentSheet({super.key, required this.postId, required this.postAuthor});

  @override
  ConsumerState<CommentSheet> createState() => _CommentSheetState();
}

class _CommentSheetState extends ConsumerState<CommentSheet> {
  final _ctrl  = TextEditingController();
  final _focus = FocusNode();
  List<String> _comments = [];
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
    if (mounted) setState(() { _comments = list; _loading = false; });
  }

  Future<void> _send() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    HapticFeedback.lightImpact();
    setState(() => _sending = true);
    await CommunityService.addComment(widget.postId, text);
    await ref.read(postsNotifierProvider.notifier).incrementComments(widget.postId);
    _ctrl.clear();
    if (mounted) {
      setState(() {
        _comments = [..._comments, text];
        _sending = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.80),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 4),
            width: 38, height: 4,
            decoration: BoxDecoration(
              color: cs.outline, borderRadius: BorderRadius.circular(2)),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: Row(children: [
              Expanded(
                child: Text('Commentaires',
                  style: GoogleFonts.outfit(
                    fontSize: 17, fontWeight: FontWeight.w700,
                    color: cs.onSurface, letterSpacing: -0.3)),
              ),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(
                    color: cs.outline.withValues(alpha: 0.1), shape: BoxShape.circle),
                  child: Icon(LucideIcons.x, size: 14, color: cs.onSurface.withValues(alpha: 0.6)),
                ),
              ),
            ]),
          ),
          Divider(height: 1, color: cs.outline),

          // Comment list
          Flexible(
            child: _loading
                ? Center(child: CircularProgressIndicator(
                    strokeWidth: 2, color: cs.primary))
                : _comments.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(32),
                        child: Text('Aucun commentaire pour l\'instant.\nSois le premier ! 💬',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(color: cs.onSurface.withValues(alpha: 0.6), fontSize: 13, height: 1.5)),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 14),
                        itemCount: _comments.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 14),
                        itemBuilder: (_, i) => _CommentRow(
                          text: _comments[i],
                          author: i == 0 ? widget.postAuthor : 'Moi',
                          colorScheme: cs,
                        ),
                      ),
          ),

          // Input bar
          Container(
            padding: EdgeInsets.fromLTRB(14, 10, 14, 10 + bottom),
            decoration: BoxDecoration(
              color: cs.surface,
              border: Border(top: BorderSide(color: cs.outline))),
            child: Row(children: [
              Expanded(
                child: TextField(
                  controller: _ctrl,
                  focusNode: _focus,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _send(),
                  style: GoogleFonts.inter(fontSize: 14, color: cs.onSurface),
                  decoration: InputDecoration(
                    hintText: 'Ajouter un commentaire…',
                    hintStyle: GoogleFonts.inter(
                        color: cs.onSurface.withValues(alpha: 0.6), fontSize: 13),
                    filled: true,
                    fillColor: cs.outline.withValues(alpha: 0.1),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 11),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: _sending ? null : _send,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: _sending
                        ? cs.secondary
                        : cs.primary,
                    shape: BoxShape.circle,
                  ),
                  child: _sending
                      ? Center(child: SizedBox(
                          width: 16, height: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: cs.onPrimary)))
                      : Icon(LucideIcons.send,
                          color: cs.onPrimary, size: 16),
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}

class _CommentRow extends StatelessWidget {
  final String text;
  final String author;
  final ColorScheme colorScheme;
  const _CommentRow({required this.text, required this.author, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: colorScheme.secondary.withValues(alpha: 0.20),
          child: Text(author[0].toUpperCase(),
            style: GoogleFonts.outfit(
              color: colorScheme.primary, fontSize: 13, fontWeight: FontWeight.w700)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(author,
                style: GoogleFonts.inter(
                  fontSize: 12, fontWeight: FontWeight.w700, color: colorScheme.onSurface)),
              const SizedBox(height: 3),
              Text(text,
                style: GoogleFonts.inter(
                  fontSize: 13, color: colorScheme.onSurface, height: 1.45)),
            ],
          ),
        ),
      ],
    );
  }
}
