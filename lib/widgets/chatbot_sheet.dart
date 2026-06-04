import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/chat_provider.dart';
import '../../models/home_program_model.dart';

// ── Quick Suggestions ─────────────────────────────────────────────────────────

const List<Map<String, String>> _quickSuggestions = [
  {'label': '🔄 Mon cycle actuel', 'message': 'Quel programme pour mon cycle actuel ?'},
  {'label': '🌱 Folliculaire',     'message': 'Quels programmes pour la phase folliculaire ?'},
  {'label': '🌊 Règles',           'message': 'Quels programmes pendant les règles ?'},
  {'label': '🍂 Lutéale',          'message': 'Quels programmes pour la phase lutéale ?'},
  {'label': '🏠 Maison',           'message': 'Montre-moi les programmes maison'},
  {'label': '🏋️ Salle',           'message': 'Montre-moi les programmes en salle'},
  {'label': '🥗 Nutrition',        'message': 'Conseils nutrition par phase de cycle'},
];

// ── Bold text parser ──────────────────────────────────────────────────────────

InlineSpan _parseBold(String text, TextStyle base) {
  final spans = <InlineSpan>[];
  final rx = RegExp(r'\*\*(.+?)\*\*');
  int last = 0;
  for (final m in rx.allMatches(text)) {
    if (m.start > last) spans.add(TextSpan(text: text.substring(last, m.start), style: base));
    spans.add(TextSpan(text: m.group(1), style: base.copyWith(fontWeight: FontWeight.w700)));
    last = m.end;
  }
  if (last < text.length) spans.add(TextSpan(text: text.substring(last), style: base));
  return TextSpan(children: spans);
}

// ── ChatbotSheet ──────────────────────────────────────────────────────────────

class ChatbotSheet extends ConsumerStatefulWidget {
  const ChatbotSheet({super.key});
  @override
  ConsumerState<ChatbotSheet> createState() => _ChatbotSheetState();
}

class _ChatbotSheetState extends ConsumerState<ChatbotSheet> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;

  void _sendMessage([String? override]) {
    final text = override ?? _controller.text;
    if (text.trim().isEmpty) return;
    setState(() => _isTyping = true);
    ref.read(chatProvider.notifier).sendMessage(text).then((_) {
      if (mounted) setState(() => _isTyping = false);
      _scrollToBottom();
    });
    _controller.clear();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 250), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 300,
          duration: const Duration(milliseconds: 380),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(chatProvider);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });

    return Container(
      margin: const EdgeInsets.only(top: kToolbarHeight),
      decoration: const BoxDecoration(
        color: Color(0xFFF2F2F7),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 10, bottom: 6),
              width: 36, height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFD1D1D6),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(20, 8, 8, 12),
            child: Row(
              children: [
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5EE),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.auto_awesome_rounded, color: Color(0xFF1B5E3B), size: 18),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('AI Assistant',
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17,
                              color: Color(0xFF1C1C1E), letterSpacing: -0.3)),
                      Text('Toujours disponible',
                          style: TextStyle(fontSize: 12, color: Color(0xFF8E8E93))),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 32, height: 32,
                    decoration: const BoxDecoration(color: Color(0xFFE5E5EA), shape: BoxShape.circle),
                    child: const Icon(Icons.close_rounded, color: Color(0xFF3C3C43), size: 16),
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),

          const Divider(height: 0.5, thickness: 0.5, color: Color(0xFFE5E5EA)),

          // Chat list
          Expanded(
            child: messages.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    itemCount: messages.length + (_isTyping ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (_isTyping && index == messages.length) {
                        return _buildTypingIndicator();
                      }
                      final msg = messages[index];
                      return _MessageRow(
                        message: msg,
                        onProgramTap: (card) => _navigateToProgram(card),
                      );
                    },
                  ),
          ),

          // Quick chips — always visible below chat
          _buildQuickChips(),

          // Input area
          Container(
            padding: EdgeInsets.only(
              left: 16, right: 16, top: 10,
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            decoration: const BoxDecoration(
              color: Color(0xFFF2F2F7),
              border: Border(top: BorderSide(color: Color(0xFFE5E5EA), width: 0.5)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Container(
                    constraints: const BoxConstraints(minHeight: 44),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: const Color(0xFFE5E5EA), width: 0.5),
                    ),
                    child: TextField(
                      controller: _controller,
                      onSubmitted: (_) => _sendMessage(),
                      maxLines: 5, minLines: 1,
                      textCapitalization: TextCapitalization.sentences,
                      style: const TextStyle(fontSize: 15, color: Color(0xFF1C1C1E)),
                      decoration: const InputDecoration(
                        hintText: 'Posez-moi une question…',
                        hintStyle: TextStyle(color: Color(0xFFAEAEB2), fontSize: 15),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _controller,
                  builder: (context, value, _) {
                    final canSend = value.text.trim().isNotEmpty;
                    return GestureDetector(
                      onTap: canSend ? _sendMessage : null,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        width: 44, height: 44,
                        decoration: BoxDecoration(
                          color: canSend ? const Color(0xFF1B5E3B) : const Color(0xFFE5E5EA),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.arrow_upward_rounded,
                            color: canSend ? Colors.white : const Color(0xFFAEAEB2), size: 20),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Navigate to program detail ─────────────────────────────────────────────

  void _navigateToProgram(ChatProgramCard card) {
    // Close the chatbot sheet first, then push the program detail route.
    // Adjust the route name / arguments to match your app's router.
    Navigator.pop(context);
    Navigator.pushNamed(
      context,
      '/program-detail',
      arguments: {
        'programId': card.id,
        'programName': card.name,
        'category': card.category,
        'imageUrl': card.imageUrl,
        'duration': card.duration,
        'sessions': card.sessions,
        'phases': card.phases,
        'color': card.color,
      },
    );
  }

  // ── Quick chips ────────────────────────────────────────────────────────────

  Widget _buildQuickChips() {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _quickSuggestions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final s = _quickSuggestions[i];
          return GestureDetector(
            onTap: () => _sendMessage(s['message']),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5EE),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF1B5E3B).withOpacity(0.2)),
              ),
              child: Text(s['label']!,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500,
                      color: Color(0xFF1B5E3B))),
            ),
          );
        },
      ),
    );
  }

  // ── Typing indicator ───────────────────────────────────────────────────────

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: 28, height: 28,
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5EE),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.auto_awesome_rounded, color: Color(0xFF1B5E3B), size: 14),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18), topRight: Radius.circular(18),
                bottomLeft: Radius.circular(4), bottomRight: Radius.circular(18),
              ),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))],
            ),
            child: _TypingDots(),
          ),
        ],
      ),
    );
  }

  // ── Empty state ────────────────────────────────────────────────────────────

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64, height: 64,
            decoration: BoxDecoration(color: const Color(0xFFE8F5EE), borderRadius: BorderRadius.circular(18)),
            child: const Icon(Icons.auto_awesome_rounded, color: Color(0xFF1B5E3B), size: 30),
          ),
          const SizedBox(height: 16),
          const Text('Comment puis-je vous aider ?',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: Color(0xFF1C1C1E))),
          const SizedBox(height: 6),
          const Text('Posez une question sur votre cycle,\nvos programmes ou votre nutrition.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Color(0xFF8E8E93), height: 1.4)),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

// ── Message Row (bubble + optional program cards) ─────────────────────────────

class _MessageRow extends StatelessWidget {
  final ChatMessage message;
  final void Function(ChatProgramCard) onProgramTap;

  const _MessageRow({required this.message, required this.onProgramTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: message.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          // Text bubble
          Row(
            mainAxisAlignment: message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!message.isUser) ...[
                Container(
                  width: 28, height: 28,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                      color: const Color(0xFFE8F5EE), borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.auto_awesome_rounded, color: Color(0xFF1B5E3B), size: 14),
                ),
              ],
              Flexible(
                child: Container(
                  constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: message.isUser ? const Color(0xFF1B5E3B) : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(18),
                      topRight: const Radius.circular(18),
                      bottomLeft: Radius.circular(message.isUser ? 18 : 4),
                      bottomRight: Radius.circular(message.isUser ? 4 : 18),
                    ),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))],
                  ),
                  child: RichText(
                    text: _parseBold(
                      message.text,
                      TextStyle(
                        color: message.isUser ? Colors.white : const Color(0xFF1C1C1E),
                        fontSize: 15, height: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Program cards (only on AI messages)
          if (!message.isUser && message.programCards.isNotEmpty) ...[
            const SizedBox(height: 10),
            SizedBox(
              height: 156,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(left: 36),
                itemCount: message.programCards.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, i) {
                  return _ProgramCard(
                    card: message.programCards[i],
                    onTap: () => onProgramTap(message.programCards[i]),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Program Card Widget ───────────────────────────────────────────────────────

class _ProgramCard extends StatelessWidget {
  final ChatProgramCard card;
  final VoidCallback onTap;

  const _ProgramCard({required this.card, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 190,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.10), blurRadius: 8, offset: const Offset(0, 3)),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background image
              Image.asset(
                card.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(color: card.color),
              ),

              // Dark gradient overlay
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      card.color.withOpacity(0.55),
                      card.color.withOpacity(0.92),
                    ],
                    stops: const [0.25, 0.6, 1.0],
                  ),
                ),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category chip
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        card.category,
                        style: const TextStyle(
                          color: Colors.white, fontSize: 10,
                          fontWeight: FontWeight.w600, letterSpacing: 0.5,
                        ),
                      ),
                    ),

                    const Spacer(),

                    // Program name
                    Text(
                      card.name,
                      style: const TextStyle(
                        color: Colors.white, fontSize: 15,
                        fontWeight: FontWeight.w700, letterSpacing: -0.2,
                        shadows: [Shadow(blurRadius: 4, color: Colors.black38)],
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Meta row
                    Row(
                      children: [
                        const Icon(Icons.schedule_rounded, size: 11, color: Colors.white70),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            '${card.duration} · ${card.sessions}',
                            style: const TextStyle(color: Colors.white70, fontSize: 11),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Cycle badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.white24, width: 0.5),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.autorenew_rounded, size: 10, color: Colors.white70),
                          const SizedBox(width: 3),
                          Flexible(
                            child: Text(
                              card.phases,
                              style: const TextStyle(color: Colors.white70, fontSize: 10),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Start button
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 7),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Voir le programme',
                            style: TextStyle(
                              color: card.color,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(Icons.arrow_forward_rounded, size: 12, color: card.color),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Animated typing dots ──────────────────────────────────────────────────────

class _TypingDots extends StatefulWidget {
  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots> with TickerProviderStateMixin {
  late final List<AnimationController> _ctrls;
  late final List<Animation<double>> _anims;

  @override
  void initState() {
    super.initState();
    _ctrls = List.generate(3, (i) => AnimationController(
      vsync: this, duration: const Duration(milliseconds: 500)));
    _anims = _ctrls.map((c) => Tween<double>(begin: 0, end: -6)
        .animate(CurvedAnimation(parent: c, curve: Curves.easeInOut))).toList();
    for (int i = 0; i < 3; i++) {
      Future.delayed(Duration(milliseconds: i * 160), () {
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
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) => AnimatedBuilder(
        animation: _anims[i],
        builder: (_, __) => Transform.translate(
          offset: Offset(0, _anims[i].value),
          child: Container(
            width: 6, height: 6,
            margin: EdgeInsets.only(right: i < 2 ? 4 : 0),
            decoration: const BoxDecoration(color: Color(0xFF8E8E93), shape: BoxShape.circle),
          ),
        ),
      )),
    );
  }
}