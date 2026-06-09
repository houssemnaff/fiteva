import 'dart:async';
import 'package:fiteva/screens/community/providers/community_providers.dart';
import 'package:fiteva/services/comuniter_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

const _kGreen  = Color(0xFF1C4D30);
const _kMint   = Color(0xFF7ABB98);
const _kBorder = Color(0xFFECECEC);
const _kText1  = Color(0xFF1A1A1A);
const _kText2  = Color(0xFF757575);
const _kChip   = Color(0xFFF4F4F2);

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
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.80),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 4),
            width: 38, height: 4,
            decoration: BoxDecoration(
              color: _kBorder, borderRadius: BorderRadius.circular(2)),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: Row(children: [
              Expanded(
                child: Text('Commentaires',
                  style: GoogleFonts.outfit(
                    fontSize: 17, fontWeight: FontWeight.w700,
                    color: _kText1, letterSpacing: -0.3)),
              ),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(
                    color: _kChip, shape: BoxShape.circle),
                  child: const Icon(LucideIcons.x, size: 14, color: _kText2),
                ),
              ),
            ]),
          ),
          const Divider(height: 1, color: _kBorder),

          // Comment list
          Flexible(
            child: _loading
                ? const Center(child: CircularProgressIndicator(
                    strokeWidth: 2, color: _kGreen))
                : _comments.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(32),
                        child: Text('Aucun commentaire pour l\'instant.\nSois le premier ! 💬',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(color: _kText2, fontSize: 13, height: 1.5)),
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
                        ),
                      ),
          ),

          // Input bar
          Container(
            padding: EdgeInsets.fromLTRB(14, 10, 14, 10 + bottom),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: _kBorder))),
            child: Row(children: [
              Expanded(
                child: TextField(
                  controller: _ctrl,
                  focusNode: _focus,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _send(),
                  style: GoogleFonts.inter(fontSize: 14, color: _kText1),
                  decoration: InputDecoration(
                    hintText: 'Ajouter un commentaire…',
                    hintStyle: GoogleFonts.inter(
                        color: _kText2, fontSize: 13),
                    filled: true,
                    fillColor: _kChip,
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
                        ? _kMint
                        : _kGreen,
                    shape: BoxShape.circle,
                  ),
                  child: _sending
                      ? const Center(child: SizedBox(
                          width: 16, height: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white)))
                      : const Icon(LucideIcons.send,
                          color: Colors.white, size: 16),
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
  const _CommentRow({required this.text, required this.author});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: _kMint.withValues(alpha: 0.20),
          child: Text(author[0].toUpperCase(),
            style: GoogleFonts.outfit(
              color: _kGreen, fontSize: 13, fontWeight: FontWeight.w700)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(author,
                style: GoogleFonts.inter(
                  fontSize: 12, fontWeight: FontWeight.w700, color: _kText1)),
              const SizedBox(height: 3),
              Text(text,
                style: GoogleFonts.inter(
                  fontSize: 13, color: _kText1, height: 1.45)),
            ],
          ),
        ),
      ],
    );
  }
}
