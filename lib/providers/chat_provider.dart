import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../services/storage_service.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({required this.text, required this.isUser, DateTime? timestamp})
    : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'text': text,
    'isUser': isUser,
    'timestamp': timestamp.toIso8601String(),
  };

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      text: json['text'] ?? '',
      isUser: json['isUser'] ?? false,
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
    );
  }
}

class ChatNotifier extends StateNotifier<List<ChatMessage>> {
  ChatNotifier() : super([]) {
    _loadHistory();
  }

  void _loadHistory() {
    final history = StorageService.getChatHistory();
    if (history.isNotEmpty) {
      state = history.map((e) => ChatMessage.fromJson(e)).toList();
    } else {
      state = [
        ChatMessage(
          text:
              'Bonjour! Je suis votre assistant FITEVA. Comment puis-je vous aider aujourd\'hui?',
          isUser: false,
        ),
      ];
    }
  }

  void _saveHistory() {
    StorageService.saveChatHistory(state.map((m) => m.toJson()).toList());
  }

  void sendMessage(String text) {
    if (text.trim().isEmpty) return;

    // Add user message
    final userMsg = ChatMessage(text: text, isUser: true);
    state = [...state, userMsg];
    _saveHistory();

    // Mock AI Response after a slight delay
    Future.delayed(const Duration(seconds: 1), () {
      String reply =
          'Je ne suis pas sûr de comprendre, mais continuez à vous entraîner !';
      final lowerText = text.toLowerCase();

      if (lowerText.contains('workout') || lowerText.contains('entrainement')) {
        reply =
            'Basé sur votre niveau, je recommande une session de yoga réparateur aujourd\'hui.';
      } else if (lowerText.contains('cycle') || lowerText.contains('phase')) {
        reply =
            'Pendant cette phase de votre cycle, il est recommandé de privilégier des exercices doux et de bien vous hydrater.';
      } else if (lowerText.contains('diet') || lowerText.contains('manger')) {
        reply =
            'Une alimentation riche en fer et en magnésium est idéale aujourd\'hui !';
      }

      state = [...state, ChatMessage(text: reply, isUser: false)];
      _saveHistory();
    });
  }
}

final chatProvider = StateNotifierProvider<ChatNotifier, List<ChatMessage>>((
  ref,
) {
  return ChatNotifier();
});
