// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../providers/chat_provider.dart';

// ── Adaptive theme ────────────────────────────────────────────────────────────

const _accent = Color(0xFF3DA85A); // FitEva green — same both modes

class _T {
  final bool dark;
  final Color bg, surface, card, border, text1, text2, accentBg, aiBubble;

  const _T._({
    required this.dark, required this.bg, required this.surface,
    required this.card, required this.border,
    required this.text1, required this.text2,
    required this.accentBg, required this.aiBubble,
  });

  factory _T.of(BuildContext ctx) =>
      Theme.of(ctx).brightness == Brightness.dark ? _dark : _light;

  static const _light = _T._(
    dark: false,
    bg:       Color.fromARGB(255, 255, 255, 255),
    surface:  Colors.white,
    card:     Color(0xFFEEF0F8),
    border:   Color(0xFFE0E3EF),
    text1:    Color(0xFF0E1117),
    text2:    Color(0xFF6B7280),
    accentBg: Color(0xFFE8F5EC),
    aiBubble: Colors.white,
  );

  static const _dark = _T._(
    dark: true,
    bg:       Color(0xFF0D0F15),
    surface:  Color(0xFF161A24),
    card:     Color(0xFF1E2334),
    border:   Color(0xFF252D42),
    text1:    Colors.white,
    text2:    Color(0xFF8A96B0),
    accentBg: Color(0xFF0D2018),
    aiBubble: Color(0xFF1E2334),
  );
}

// ── Bold parser ───────────────────────────────────────────────────────────────

InlineSpan _parseBold(String text, TextStyle base) {
  final spans = <InlineSpan>[];
  final rx = RegExp(r'\*\*(.+?)\*\*');
  int last = 0;
  for (final m in rx.allMatches(text)) {
    if (m.start > last) {
      spans.add(TextSpan(text: text.substring(last, m.start), style: base));
    }
    spans.add(TextSpan(
        text: m.group(1),
        style: base.copyWith(fontWeight: FontWeight.w700)));
    last = m.end;
  }
  if (last < text.length) {
    spans.add(TextSpan(text: text.substring(last), style: base));
  }
  return TextSpan(children: spans);
}

// ── ChatbotSheet ──────────────────────────────────────────────────────────────

class ChatbotSheet extends ConsumerStatefulWidget {
  const ChatbotSheet({super.key});
  @override
  ConsumerState<ChatbotSheet> createState() => _State();
}

class _State extends ConsumerState<ChatbotSheet> {
  final _ctrl   = TextEditingController();
  final _scroll = ScrollController();
  bool        _typing = false;
  AiCategory? _activeCat;

  void _send(String text, {AiCategory? cat}) {
    if (text.trim().isEmpty) return;
    _ctrl.clear();
    setState(() {
      _typing = true;
      if (cat != null) _activeCat = cat;
    });
    ref.read(chatProvider.notifier)
        .sendMessage(text, categoryId: (cat ?? _activeCat)?.id)
        .then((_) {
      if (mounted) setState(() => _typing = false);
      _bottom();
    });
    _bottom();
  }

  void _bottom() {
    Future.delayed(const Duration(milliseconds: 280), () {
      if (_scroll.hasClients) {
        _scroll.animateTo(_scroll.position.maxScrollExtent + 400,
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOut);
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t        = _T.of(context);
    final messages = ref.watch(chatProvider);
    final kbBottom = MediaQuery.of(context).viewInsets.bottom;
    final isEmpty  = messages.isEmpty;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients && !isEmpty) {
        _scroll.jumpTo(_scroll.position.maxScrollExtent);
      }
    });

    return Container(
      margin: const EdgeInsets.only(top: 56),
      decoration: BoxDecoration(
        color: t.bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(children: [

        // Handle
        Center(
          child: Container(
            margin: const EdgeInsets.only(top: 10, bottom: 4),
            width: 34, height: 3,
            decoration: BoxDecoration(
              color: t.border, borderRadius: BorderRadius.circular(2)),
          ),
        ),

        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 16, 14),
          child: Row(children: [
            // Icon
            Container(
              width: 42, height: 42,
              decoration: BoxDecoration(
                color: t.accentBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _accent.withOpacity(0.35))),
              child: const Icon(LucideIcons.wand, color: _accent, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('FitEva AI', style: GoogleFonts.outfit(
                  fontSize: 17, fontWeight: FontWeight.w800,
                  color: t.text1, letterSpacing: -0.4)),
                Row(children: [
                  Container(width: 6, height: 6,
                    decoration: const BoxDecoration(
                      color: Color(0xFF4ADE80), shape: BoxShape.circle)),
                  const SizedBox(width: 5),
                  Text('Assistante personnelle', style: GoogleFonts.inter(
                    fontSize: 11, color: t.text2)),
                ]),
              ],
            )),
            // Back to categories
            if (_activeCat != null && isEmpty)
              GestureDetector(
                onTap: () => setState(() => _activeCat = null),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: t.card,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: t.border)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(LucideIcons.chevronLeft, size: 13, color: t.text2),
                    const SizedBox(width: 3),
                    Text(_activeCat!.emoji,
                        style: const TextStyle(fontSize: 13)),
                  ]),
                ),
              ),
            // Clear
            if (messages.isNotEmpty)
              GestureDetector(
                onTap: () {
                  ref.read(chatProvider.notifier).clearChat();
                  setState(() { _typing = false; _activeCat = null; });
                },
                child: Container(
                  width: 34, height: 34,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: t.card, borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: t.border)),
                  child: Icon(LucideIcons.rotateCcw, size: 15, color: t.text2)),
              ),
            // Close
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 34, height: 34,
                decoration: BoxDecoration(
                  color: t.card, borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: t.border)),
                child: Icon(LucideIcons.x, size: 16, color: t.text2)),
            ),
          ]),
        ),

        Container(height: 0.5, color: t.border),

        // Body
        Expanded(
          child: isEmpty
              ? (_activeCat == null
                  ? _CategoryGrid(t: t, onSelect: (c) => setState(() => _activeCat = c))
                  : _QuestionList(
                      t: t, category: _activeCat!,
                      onTap: (q) => _send(q, cat: _activeCat),
                    ))
              : ListView.builder(
                  controller: _scroll,
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  itemCount: messages.length + (_typing ? 1 : 0),
                  itemBuilder: (_, i) {
                    if (_typing && i == messages.length) {
                      return _TypingRow(t: t);
                    }
                    return _Bubble(
                      t: t,
                      msg: messages[i],
                      onQuickReply: _send,
                      onProgramTap: _navToProgram,
                    );
                  },
                ),
        ),

        // Input
        Container(
          padding: EdgeInsets.fromLTRB(16, 10, 16, kbBottom > 0 ? kbBottom + 8 : 26),
          decoration: BoxDecoration(
            color: t.bg,
            border: Border(top: BorderSide(color: t.border, width: 0.5))),
          child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Expanded(
              child: Container(
                constraints: const BoxConstraints(minHeight: 46),
                decoration: BoxDecoration(
                  color: t.card,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: t.border)),
                child: TextField(
                  controller: _ctrl,
                  onSubmitted: (_) => _send(_ctrl.text),
                  maxLines: 5, minLines: 1,
                  textCapitalization: TextCapitalization.sentences,
                  style: GoogleFonts.inter(fontSize: 14, color: t.text1),
                  decoration: InputDecoration(
                    hintText: 'Pose ta question…',
                    hintStyle: GoogleFonts.inter(fontSize: 14, color: t.text2),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 12),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: _ctrl,
              builder: (_, val, __) {
                final active = val.text.trim().isNotEmpty;
                return GestureDetector(
                  onTap: active ? () => _send(_ctrl.text) : null,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 46, height: 46,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: active ? _accent : t.card,
                      border: Border.all(color: t.border)),
                    child: Icon(LucideIcons.arrowUp, size: 18,
                      color: active ? Colors.white : t.text2),
                  ),
                );
              },
            ),
          ]),
        ),
      ]),
    );
  }

  void _navToProgram(ChatProgramCard card) {
    Navigator.pop(context);
    Navigator.pushNamed(context, '/program-detail', arguments: {
      'programId': card.id, 'programName': card.name,
      'category': card.category, 'imageUrl': card.imageUrl,
      'duration': card.duration, 'sessions': card.sessions,
      'phases': card.phases, 'color': card.color,
    });
  }
}

// ── Category Grid ─────────────────────────────────────────────────────────────

class _CategoryGrid extends StatelessWidget {
  final _T t;
  final void Function(AiCategory) onSelect;
  const _CategoryGrid({required this.t, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Comment puis-je t\'aider ?', style: GoogleFonts.outfit(
          fontSize: 20, fontWeight: FontWeight.w800,
          color: t.text1, letterSpacing: -0.5)),
        const SizedBox(height: 4),
        Text('Choisis une catégorie pour commencer',
          style: GoogleFonts.inter(fontSize: 13, color: t.text2)),
        const SizedBox(height: 22),
        GridView.count(
          crossAxisCount: 2, shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12, mainAxisSpacing: 12,
          childAspectRatio: 1.45,
          children: appCategories.map((cat) => GestureDetector(
            onTap: () => onSelect(cat),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: t.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: t.border)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(
                  width: 38, height: 38,
                  decoration: BoxDecoration(
                    color: cat.color.withOpacity(0.14),
                    borderRadius: BorderRadius.circular(12)),
                  child: Center(child: Text(cat.emoji,
                      style: const TextStyle(fontSize: 18)))),
                const Spacer(),
                Text(cat.label, style: GoogleFonts.outfit(
                  fontSize: 14, fontWeight: FontWeight.w700, color: t.text1)),
                const SizedBox(height: 2),
                Text('${cat.questions.length} questions',
                  style: GoogleFonts.inter(fontSize: 10, color: t.text2)),
              ]),
            ),
          )).toList(),
        ),
      ]),
    );
  }
}

// ── Question List ─────────────────────────────────────────────────────────────

class _QuestionList extends StatelessWidget {
  final _T t;
  final AiCategory category;
  final void Function(String) onTap;
  const _QuestionList({required this.t, required this.category, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 42, height: 42,
            decoration: BoxDecoration(
              color: category.color.withOpacity(0.14),
              borderRadius: BorderRadius.circular(14)),
            child: Center(child: Text(category.emoji,
                style: const TextStyle(fontSize: 20)))),
          const SizedBox(width: 12),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(category.label, style: GoogleFonts.outfit(
              fontSize: 18, fontWeight: FontWeight.w800, color: t.text1)),
            Text('Sélectionne une question', style: GoogleFonts.inter(
              fontSize: 11, color: t.text2)),
          ]),
        ]),
        const SizedBox(height: 20),
        ...category.questions.asMap().entries.map((e) {
          final i = e.key;
          final q = e.value;
          return Padding(
            padding: EdgeInsets.only(
                bottom: i < category.questions.length - 1 ? 10 : 0),
            child: GestureDetector(
              onTap: () => onTap(q),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: t.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: t.border)),
                child: Row(children: [
                  Container(
                    width: 28, height: 28,
                    decoration: BoxDecoration(
                      color: category.color.withOpacity(0.14),
                      borderRadius: BorderRadius.circular(8)),
                    child: Center(child: Text('${i + 1}',
                      style: GoogleFonts.outfit(
                        fontSize: 12, fontWeight: FontWeight.w800,
                        color: category.color)))),
                  const SizedBox(width: 12),
                  Expanded(child: Text(q, style: GoogleFonts.inter(
                    fontSize: 13, color: t.text1,
                    fontWeight: FontWeight.w500, height: 1.4))),
                  Icon(LucideIcons.chevronRight, size: 14, color: t.text2),
                ]),
              ),
            ),
          );
        }),
      ]),
    );
  }
}

// ── Message Bubble ────────────────────────────────────────────────────────────

class _Bubble extends StatelessWidget {
  final _T t;
  final ChatMessage msg;
  final void Function(String) onQuickReply;
  final void Function(ChatProgramCard) onProgramTap;
  const _Bubble({required this.t, required this.msg,
      required this.onQuickReply, required this.onProgramTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: msg.isUser
            ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: msg.isUser
                ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!msg.isUser) ...[
                Container(
                  width: 28, height: 28,
                  margin: const EdgeInsets.only(right: 8, bottom: 2),
                  decoration: BoxDecoration(
                    color: t.accentBg,
                    borderRadius: BorderRadius.circular(9),
                    border: Border.all(color: _accent.withOpacity(0.3))),
                  child: const Icon(LucideIcons.wand,
                      color: _accent, size: 13),
                ),
              ],
              Flexible(
                child: Container(
                  constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.76),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: msg.isUser ? _accent : t.aiBubble,
                    borderRadius: BorderRadius.only(
                      topLeft:     const Radius.circular(20),
                      topRight:    const Radius.circular(20),
                      bottomLeft:  Radius.circular(msg.isUser ? 20 : 4),
                      bottomRight: Radius.circular(msg.isUser ? 4 : 20),
                    ),
                    border: msg.isUser ? null
                        : Border.all(color: t.border, width: 0.8),
                    boxShadow: msg.isUser ? null : [
                      BoxShadow(color: Colors.black.withOpacity(
                          t.dark ? 0.15 : 0.05),
                        blurRadius: 8, offset: const Offset(0, 2))
                    ],
                  ),
                  child: RichText(
                    text: _parseBold(msg.text, GoogleFonts.inter(
                      fontSize: 14, height: 1.55,
                      color: msg.isUser ? Colors.white : t.text1)),
                  ),
                ),
              ),
            ],
          ),

          // Quick replies
          if (!msg.isUser && msg.quickReplies.isNotEmpty) ...[
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(left: 36),
              child: Wrap(spacing: 7, runSpacing: 7,
                children: msg.quickReplies.map((r) => GestureDetector(
                  onTap: () => onQuickReply(r),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: t.accentBg,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: _accent.withOpacity(0.35))),
                    child: Text(r, style: GoogleFonts.inter(
                      fontSize: 12, fontWeight: FontWeight.w600,
                      color: _accent)),
                  ),
                )).toList(),
              ),
            ),
          ],

          // Program cards
          if (!msg.isUser && msg.programCards.isNotEmpty) ...[
            const SizedBox(height: 10),
            SizedBox(
              height: 155,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(left: 36),
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemCount: msg.programCards.length,
                itemBuilder: (_, i) => _ProgramCard(
                  card: msg.programCards[i],
                  onTap: () => onProgramTap(msg.programCards[i])),
              ),
            ),
          ],

          // Workout card
          if (!msg.isUser && msg.workout != null) ...[
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(left: 36),
              child: _WorkoutCard(t: t, workout: msg.workout!),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Generated Workout Card ────────────────────────────────────────────────────

class _WorkoutCard extends StatefulWidget {
  final _T t;
  final GeneratedWorkout workout;
  const _WorkoutCard({required this.t, required this.workout});
  @override
  State<_WorkoutCard> createState() => _WorkoutCardState();
}

class _WorkoutCardState extends State<_WorkoutCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final t = widget.t;
    final w = widget.workout;
    return Container(
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: t.border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: t.accentBg,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20))),
          child: Row(children: [
            const Icon(LucideIcons.dumbbell, color: _accent, size: 18),
            const SizedBox(width: 10),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(w.title, style: GoogleFonts.outfit(
                fontSize: 15, fontWeight: FontWeight.w800,
                color: t.text1, letterSpacing: -0.3)),
              Text(w.subtitle, style: GoogleFonts.inter(
                fontSize: 11, color: t.text2)),
            ])),
            GestureDetector(
              onTap: () => setState(() => _expanded = !_expanded),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: _accent.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(10)),
                child: Text(_expanded ? 'Réduire' : 'Voir tout',
                  style: GoogleFonts.inter(
                    fontSize: 11, fontWeight: FontWeight.w700,
                    color: _accent)),
              ),
            ),
          ]),
        ),

        Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            children: w.sections.asMap().entries.map((e) {
              final i = e.key;
              final s = e.value;
              final exercises = _expanded
                  ? s.exercises : s.exercises.take(2).toList();
              return Padding(
                padding: EdgeInsets.only(
                    bottom: i < w.sections.length - 1 ? 14 : 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Text(s.name, style: GoogleFonts.outfit(
                      fontSize: 13, fontWeight: FontWeight.w700,
                      color: t.text1)),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: t.accentBg,
                        borderRadius: BorderRadius.circular(8)),
                      child: Text(s.duration, style: GoogleFonts.inter(
                        fontSize: 10, fontWeight: FontWeight.w600,
                        color: _accent)),
                    ),
                  ]),
                  const SizedBox(height: 8),
                  ...exercises.map((ex) => Padding(
                    padding: const EdgeInsets.only(bottom: 5),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(width: 5, height: 5,
                          margin: const EdgeInsets.only(top: 5, right: 8),
                          decoration: const BoxDecoration(
                            color: _accent, shape: BoxShape.circle)),
                        Expanded(child: Text(ex, style: GoogleFonts.inter(
                          fontSize: 12, color: t.text1, height: 1.4))),
                      ]),
                  )),
                  if (!_expanded && s.exercises.length > 2)
                    Text('+${s.exercises.length - 2} exercices',
                      style: GoogleFonts.inter(
                        fontSize: 11, color: t.text2,
                        fontStyle: FontStyle.italic)),
                ]),
              );
            }).toList(),
          ),
        ),
      ]),
    );
  }
}

// ── Program Card ──────────────────────────────────────────────────────────────

class _ProgramCard extends StatelessWidget {
  final ChatProgramCard card;
  final VoidCallback onTap;
  const _ProgramCard({required this.card, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(
            color: Colors.black.withOpacity(0.20),
            blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Stack(fit: StackFit.expand, children: [
            Image.asset(card.imageUrl, fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(color: card.color)),
            DecoratedBox(decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter, end: Alignment.bottomCenter,
                colors: [Colors.transparent, card.color.withOpacity(0.95)],
                stops: const [0.3, 1.0]))),
            Padding(padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(7)),
                  child: Text(card.category, style: const TextStyle(
                    color: Colors.white, fontSize: 9,
                    fontWeight: FontWeight.w700))),
                const Spacer(),
                Text(card.name, style: const TextStyle(
                  color: Colors.white, fontSize: 13,
                  fontWeight: FontWeight.w800)),
                const SizedBox(height: 3),
                Text(card.duration, style: const TextStyle(
                  color: Colors.white70, fontSize: 10)),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(9)),
                  child: Text('Voir', textAlign: TextAlign.center,
                    style: TextStyle(color: card.color, fontSize: 11,
                      fontWeight: FontWeight.w700))),
              ])),
          ]),
        ),
      ),
    );
  }
}

// ── Typing indicator ──────────────────────────────────────────────────────────

class _TypingRow extends StatelessWidget {
  final _T t;
  const _TypingRow({required this.t});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Container(
          width: 28, height: 28,
          margin: const EdgeInsets.only(right: 8, bottom: 2),
          decoration: BoxDecoration(
            color: t.accentBg,
            borderRadius: BorderRadius.circular(9),
            border: Border.all(color: _accent.withOpacity(0.3))),
          child: const Icon(LucideIcons.wand, color: _accent, size: 13),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            color: t.aiBubble,
            border: Border.all(color: t.border, width: 0.8),
            borderRadius: const BorderRadius.only(
              topLeft:     Radius.circular(20),
              topRight:    Radius.circular(20),
              bottomLeft:  Radius.circular(4),
              bottomRight: Radius.circular(20))),
          child: const _Dots(),
        ),
      ]),
    );
  }
}

// ── Animated dots ─────────────────────────────────────────────────────────────

class _Dots extends StatefulWidget {
  const _Dots();
  @override
  State<_Dots> createState() => _DotsState();
}

class _DotsState extends State<_Dots> with TickerProviderStateMixin {
  late final List<AnimationController> _ctrls;
  late final List<Animation<double>>   _anims;

  @override
  void initState() {
    super.initState();
    _ctrls = List.generate(3, (_) => AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500)));
    _anims = _ctrls.map((c) => Tween<double>(begin: 0, end: -5)
        .animate(CurvedAnimation(parent: c, curve: Curves.easeInOut))).toList();
    for (int i = 0; i < 3; i++) {
      Future.delayed(Duration(milliseconds: i * 150), () {
        if (mounted) _ctrls[i].repeat(reverse: true);
      });
    }
  }

  @override
  void dispose() {
    for (final c in _ctrls) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      for (int i = 0; i < 3; i++)
        AnimatedBuilder(
          animation: _anims[i],
          builder: (_, __) => Transform.translate(
            offset: Offset(0, _anims[i].value),
            child: Container(
              width: 6, height: 6,
              margin: EdgeInsets.only(right: i < 2 ? 5 : 0),
              decoration: const BoxDecoration(
                color: _accent, shape: BoxShape.circle)),
          ),
        ),
    ]);
  }
}
