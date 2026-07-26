// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../providers/chat_provider.dart';
import '../providers/mock_data_provider.dart';
import '../l10n/app_localizations.dart';
import '../screens/workout/programme_detail_screen.dart';

const _green = Color(0xFF5CD57A);

class _T {
  final bool dark;
  final Color bg, surface, text1, text2, subtle, divider;

  const _T._({
    required this.dark, required this.bg, required this.surface,
    required this.text1, required this.text2,
    required this.subtle, required this.divider,
  });

  factory _T.of(BuildContext ctx) =>
      Theme.of(ctx).brightness == Brightness.dark ? _dark : _light;

  static const _light = _T._(
    dark: false,
    bg:      Colors.white,
    surface: Color(0xFFF5F6F8),
    text1:   Color(0xFF111318),
    text2:   Color(0xFF8B92A5),
    subtle:  Color(0xFFEEF0F4),
    divider: Color(0xFFEBEDF2),
  );

  static const _dark = _T._(
    dark: true,
    bg:      Color(0xFF0E1015),
    surface: Color(0xFF181C24),
    text1:   Color(0xFFF0F2F5),
    text2:   Color(0xFF6B7590),
    subtle:  Color(0xFF1E2330),
    divider: Color(0xFF1E2330),
  );
}

// ── Bold + emoji-safe parser ─────────────────────────────────────────────────

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

// ═══════════════════════════════════════════════════════════════════════════════
//  ChatbotSheet
// ═══════════════════════════════════════════════════════════════════════════════

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
      margin: const EdgeInsets.only(top: 48),
      decoration: BoxDecoration(
        color: t.bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(children: [
        _buildHandle(t),
        _buildHeader(t),

        // Body
        Expanded(
          child: isEmpty
              ? (_activeCat == null
                  ? _WelcomeView(t: t, onSelectCat: (c) => setState(() => _activeCat = c),
                      onTapQuestion: (q, c) => _send(q, cat: c))
                  : _QuestionList(t: t, category: _activeCat!,
                      onTap: (q) => _send(q, cat: _activeCat)))
              : ListView.builder(
                  controller: _scroll,
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                  itemCount: messages.length + (_typing ? 1 : 0),
                  itemBuilder: (_, i) {
                    if (_typing && i == messages.length) return _TypingRow(t: t);
                    return _Bubble(t: t, msg: messages[i],
                      onQuickReply: _send, onProgramTap: _navToProgram);
                  },
                ),
        ),

        _buildInput(t, kbBottom),
      ]),
    );
  }

  // ── Handle ────────────────────────────────────────────────────
  Widget _buildHandle(_T t) {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(top: 10, bottom: 4),
        width: 36, height: 4,
        decoration: BoxDecoration(
          color: t.divider, borderRadius: BorderRadius.circular(2)),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────
  Widget _buildHeader(_T t) {
    final l10n = ref.watch(l10nProvider);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 6, 14, 12),
      child: Row(children: [
        // AI logo
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            color: _green.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12)),
          child: const Center(
            child: Text('✦', style: TextStyle(fontSize: 20, color: _green))),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.chatFitEvaAI, style: GoogleFonts.outfit(
              fontSize: 17, fontWeight: FontWeight.w800,
              color: t.text1, letterSpacing: -0.4)),
            Row(children: [
              Container(width: 5, height: 5,
                decoration: const BoxDecoration(
                  color: _green, shape: BoxShape.circle)),
              const SizedBox(width: 5),
              Text('En ligne', style: GoogleFonts.inter(
                fontSize: 11, color: _green, fontWeight: FontWeight.w600)),
            ]),
          ],
        )),
        // Actions
        if (_activeCat != null || ref.watch(chatProvider).isNotEmpty)
          _IconBtn(t: t, icon: LucideIcons.rotateCcw, onTap: () {
            ref.read(chatProvider.notifier).clearChat();
            setState(() { _typing = false; _activeCat = null; });
          }),
        const SizedBox(width: 6),
        _IconBtn(t: t, icon: LucideIcons.x, onTap: () => Navigator.pop(context)),
      ]),
    );
  }

  // ── Input ─────────────────────────────────────────────────────
  Widget _buildInput(_T t, double kbBottom) {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 10, 16, kbBottom > 0 ? kbBottom + 8 : 28),
      decoration: BoxDecoration(
        color: t.bg,
        border: Border(top: BorderSide(color: t.divider, width: 0.5))),
      child: Container(
        decoration: BoxDecoration(
          color: t.surface,
          borderRadius: BorderRadius.circular(26),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Expanded(
            child: TextField(
              controller: _ctrl,
              onSubmitted: (_) => _send(_ctrl.text),
              maxLines: 4, minLines: 1,
              textCapitalization: TextCapitalization.sentences,
              style: GoogleFonts.inter(fontSize: 14, color: t.text1),
              decoration: InputDecoration(
                hintText: 'Demande-moi n\'importe quoi…',
                hintStyle: GoogleFonts.inter(fontSize: 14, color: t.text2),
                contentPadding: const EdgeInsets.fromLTRB(20, 14, 8, 14),
                border: InputBorder.none,
              ),
            ),
          ),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: _ctrl,
            builder: (_, val, __) {
              final active = val.text.trim().isNotEmpty;
              return Padding(
                padding: const EdgeInsets.only(right: 5, bottom: 5),
                child: GestureDetector(
                  onTap: active ? () => _send(_ctrl.text) : null,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 42, height: 42,
                    decoration: BoxDecoration(
                      color: active ? _green : Colors.transparent,
                      borderRadius: BorderRadius.circular(21)),
                    child: Icon(LucideIcons.arrowUp, size: 18,
                      color: active ? Colors.white : t.text2),
                  ),
                ),
              );
            },
          ),
        ]),
      ),
    );
  }

  void _navToProgram(ChatProgramCard card) {
    final allPrograms = [
      ...ref.read(salleProgramsProvider),
      ...ref.read(homeProgramsProvider),
      ...ref.read(danceProgramsProvider),
      ...ref.read(recuperationProgramsProvider),
      ...ref.read(grossesseProgramsProvider),
    ];
    final program = allPrograms.cast<dynamic>().firstWhere(
      (p) => p.name.toString().toLowerCase() == card.name.toLowerCase(),
      orElse: () => null,
    );
    Navigator.pop(context);
    if (program != null) {
      Navigator.push(context, MaterialPageRoute(
        builder: (_) => WorkoutDetailScreen(program: program)));
    }
  }
}

// ── Small icon button ────────────────────────────────────────────────────────

class _IconBtn extends StatelessWidget {
  final _T t;
  final IconData icon;
  final VoidCallback onTap;
  const _IconBtn({required this.t, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36, height: 36,
        decoration: BoxDecoration(
          color: t.surface,
          borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, size: 16, color: t.text2),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
//  Welcome View — greeting + horizontal category chips + top questions
// ═══════════════════════════════════════════════════════════════════════════════

class _WelcomeView extends StatefulWidget {
  final _T t;
  final void Function(AiCategory) onSelectCat;
  final void Function(String, AiCategory) onTapQuestion;
  const _WelcomeView({required this.t, required this.onSelectCat,
      required this.onTapQuestion});

  @override
  State<_WelcomeView> createState() => _WelcomeViewState();
}

class _WelcomeViewState extends State<_WelcomeView> {
  int _selectedChip = 0;

  @override
  Widget build(BuildContext context) {
    final t = widget.t;
    final cat = appCategories[_selectedChip];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        // ── Greeting ────────────────────────────────────────────
        const SizedBox(height: 12),
        Center(
          child: Container(
            width: 56, height: 56,
            decoration: BoxDecoration(
              color: _green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(18)),
            child: const Center(
              child: Text('✦', style: TextStyle(fontSize: 28, color: _green))),
          ),
        ),
        const SizedBox(height: 16),
        Consumer(builder: (context, ref, _) {
          final l10n = ref.watch(l10nProvider);
          return Column(children: [
            Center(child: Text(l10n.chatComment, style: GoogleFonts.outfit(
              fontSize: 24, fontWeight: FontWeight.w800,
              color: t.text1, letterSpacing: -0.6))),
            const SizedBox(height: 4),
            Center(child: Text(l10n.chatChoisir,
              style: GoogleFonts.inter(fontSize: 13, color: t.text2))),
          ]);
        }),
        const SizedBox(height: 28),

        // ── Category chips (horizontal scroll) ──────────────────
        SizedBox(
          height: 38,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: appCategories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final c = appCategories[i];
              final selected = i == _selectedChip;
              return GestureDetector(
                onTap: () => setState(() => _selectedChip = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: selected ? _green : t.surface,
                    borderRadius: BorderRadius.circular(20)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Text(c.emoji, style: const TextStyle(fontSize: 15)),
                    const SizedBox(width: 6),
                    Text(c.label, style: GoogleFonts.inter(
                      fontSize: 13, fontWeight: FontWeight.w600,
                      color: selected ? Colors.white : t.text1)),
                  ]),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 20),

        // ── Questions for selected category ─────────────────────
        ...cat.questions.take(4).map((q) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: GestureDetector(
            onTap: () => widget.onTapQuestion(q, cat),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: t.surface,
                borderRadius: BorderRadius.circular(14)),
              child: Row(children: [
                Expanded(child: Text(q, style: GoogleFonts.inter(
                  fontSize: 13.5, color: t.text1,
                  fontWeight: FontWeight.w500, height: 1.35))),
                const SizedBox(width: 8),
                Icon(LucideIcons.arrowRight, size: 15, color: t.text2),
              ]),
            ),
          ),
        )),

        // "See all" link
        const SizedBox(height: 4),
        GestureDetector(
          onTap: () => widget.onSelectCat(cat),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text('Voir toutes les questions', style: GoogleFonts.inter(
              fontSize: 12, fontWeight: FontWeight.w600, color: _green)),
            const SizedBox(width: 4),
            const Icon(LucideIcons.arrowRight, size: 12, color: _green),
          ]),
        ),
      ]),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
//  Question List (full list for a category)
// ═══════════════════════════════════════════════════════════════════════════════

class _QuestionList extends StatelessWidget {
  final _T t;
  final AiCategory category;
  final void Function(String) onTap;
  const _QuestionList({required this.t, required this.category,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Category header
        Row(children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: category.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12)),
            child: Center(child: Text(category.emoji,
                style: const TextStyle(fontSize: 20)))),
          const SizedBox(width: 12),
          Text(category.label, style: GoogleFonts.outfit(
            fontSize: 20, fontWeight: FontWeight.w800, color: t.text1,
            letterSpacing: -0.4)),
        ]),
        const SizedBox(height: 16),

        ...category.questions.asMap().entries.map((e) {
          final i = e.key;
          final q = e.value;
          return Padding(
            padding: EdgeInsets.only(
                bottom: i < category.questions.length - 1 ? 8 : 0),
            child: GestureDetector(
              onTap: () => onTap(q),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: t.surface,
                  borderRadius: BorderRadius.circular(14)),
                child: Row(children: [
                  Expanded(child: Text(q, style: GoogleFonts.inter(
                    fontSize: 13.5, color: t.text1,
                    fontWeight: FontWeight.w500, height: 1.35))),
                  const SizedBox(width: 8),
                  Icon(LucideIcons.arrowRight, size: 15, color: t.text2),
                ]),
              ),
            ),
          );
        }),
      ]),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
//  Message Bubble — AI uses left accent bar, user gets green pill
// ═══════════════════════════════════════════════════════════════════════════════

class _Bubble extends StatelessWidget {
  final _T t;
  final ChatMessage msg;
  final void Function(String) onQuickReply;
  final void Function(ChatProgramCard) onProgramTap;
  const _Bubble({required this.t, required this.msg,
      required this.onQuickReply, required this.onProgramTap});

  @override
  Widget build(BuildContext context) {
    final isUser = msg.isUser;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: isUser
            ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (isUser)
            // ── User bubble ─────────────────────────────────────
            Container(
              constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.75),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
              decoration: BoxDecoration(
                color: _green,
                borderRadius: const BorderRadius.only(
                  topLeft:     Radius.circular(20),
                  topRight:    Radius.circular(20),
                  bottomLeft:  Radius.circular(20),
                  bottomRight: Radius.circular(6)),
              ),
              child: Text(msg.text, style: GoogleFonts.inter(
                fontSize: 14, height: 1.5, color: Colors.white)),
            )
          else
            // ── AI message — accent bar on left ─────────────────
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                width: 3,
                margin: const EdgeInsets.only(top: 4),
                constraints: const BoxConstraints(minHeight: 20),
                decoration: BoxDecoration(
                  color: _green,
                  borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: RichText(
                  text: _parseBold(msg.text, GoogleFonts.inter(
                    fontSize: 14, height: 1.6, color: t.text1)),
                ),
              ),
            ]),

          // Quick replies
          if (!isUser && msg.quickReplies.isNotEmpty) ...[
            const SizedBox(height: 12),
            SizedBox(
              height: 36,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(left: 17),
                itemCount: msg.quickReplies.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final r = msg.quickReplies[i];
                  return GestureDetector(
                    onTap: () => onQuickReply(r),
                    child: Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: _green.withOpacity(0.4))),
                      child: Text(r, style: GoogleFonts.inter(
                        fontSize: 12, fontWeight: FontWeight.w600,
                        color: _green)),
                    ),
                  );
                },
              ),
            ),
          ],

          // Program cards
          if (!isUser && msg.programCards.isNotEmpty) ...[
            const SizedBox(height: 12),
            SizedBox(
              height: 155,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(left: 17),
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemCount: msg.programCards.length,
                itemBuilder: (_, i) => _ProgramCard(
                  card: msg.programCards[i],
                  onTap: () => onProgramTap(msg.programCards[i])),
              ),
            ),
          ],

          // Workout card
          if (!isUser && msg.workout != null) ...[
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.only(left: 17),
              child: _WorkoutCard(t: t, workout: msg.workout!),
            ),
          ],
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
//  Workout Card
// ═══════════════════════════════════════════════════════════════════════════════

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
        borderRadius: BorderRadius.circular(16)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _green.withOpacity(0.08),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16))),
          child: Row(children: [
            const Icon(LucideIcons.dumbbell, color: _green, size: 18),
            const SizedBox(width: 10),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(w.title, style: GoogleFonts.outfit(
                fontSize: 14, fontWeight: FontWeight.w800,
                color: t.text1, letterSpacing: -0.3)),
              Text(w.subtitle, style: GoogleFonts.inter(
                fontSize: 11, color: t.text2)),
            ])),
            GestureDetector(
              onTap: () => setState(() => _expanded = !_expanded),
              child: Text(_expanded ? 'Réduire' : 'Voir tout',
                style: GoogleFonts.inter(
                  fontSize: 11, fontWeight: FontWeight.w700, color: _green)),
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
                    bottom: i < w.sections.length - 1 ? 12 : 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Text(s.name, style: GoogleFonts.outfit(
                      fontSize: 13, fontWeight: FontWeight.w700,
                      color: t.text1)),
                    const Spacer(),
                    Text(s.duration, style: GoogleFonts.inter(
                      fontSize: 10, fontWeight: FontWeight.w600,
                      color: _green)),
                  ]),
                  const SizedBox(height: 8),
                  ...exercises.map((ex) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(width: 4, height: 4,
                          margin: const EdgeInsets.only(top: 6, right: 8),
                          decoration: const BoxDecoration(
                            color: _green, shape: BoxShape.circle)),
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

// ═══════════════════════════════════════════════════════════════════════════════
//  Program Card
// ═══════════════════════════════════════════════════════════════════════════════

class _ProgramCard extends StatelessWidget {
  final ChatProgramCard card;
  final VoidCallback onTap;
  const _ProgramCard({required this.card, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 150,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
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
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(6)),
                  child: Text(card.category, style: const TextStyle(
                    color: Colors.white, fontSize: 9,
                    fontWeight: FontWeight.w700))),
                const Spacer(),
                Text(card.name, style: GoogleFonts.outfit(
                  color: Colors.white, fontSize: 13,
                  fontWeight: FontWeight.w800)),
                const SizedBox(height: 2),
                Text(card.duration, style: const TextStyle(
                  color: Colors.white70, fontSize: 10)),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8)),
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

// ═══════════════════════════════════════════════════════════════════════════════
//  Typing indicator
// ═══════════════════════════════════════════════════════════════════════════════

class _TypingRow extends StatelessWidget {
  final _T t;
  const _TypingRow({required this.t});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 3,
          height: 24,
          margin: const EdgeInsets.only(top: 4),
          decoration: BoxDecoration(
            color: _green,
            borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(width: 14),
        const _Dots(),
      ]),
    );
  }
}

// ── Animated dots ────────────────────────────────────────────────────────────

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
    for (final c in _ctrls) {
      c.dispose();
    }
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
                color: _green, shape: BoxShape.circle)),
          ),
        ),
    ]);
  }
}
