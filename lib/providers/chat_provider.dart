import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ── Program Card Data (embeddable in messages) ───────────────────────────────

class ChatProgramCard {
  final String id;
  final String name;
  final String duration;
  final String sessions;
  final String phases;
  final String category;
  final Color color;
  final String imageUrl;
  final List<String> compatibleCycles;

  const ChatProgramCard({
    required this.id,
    required this.name,
    required this.duration,
    required this.sessions,
    required this.phases,
    required this.category,
    required this.color,
    required this.imageUrl,
    required this.compatibleCycles,
  });
}

// ── Message Model ────────────────────────────────────────────────────────────

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  /// Optional list of program cards to display below the text bubble
  final List<ChatProgramCard> programCards;

  ChatMessage({
    required this.text,
    required this.isUser,
    DateTime? timestamp,
    this.programCards = const [],
  }) : timestamp = timestamp ?? DateTime.now();
}

// ── Cycle Phase Info ─────────────────────────────────────────────────────────

class _CyclePhaseData {
  final String name;
  final String emoji;
  final String description;
  final List<String> recommendedCategories;
  final List<String> avoidCategories;
  final String nutritionTip;
  final String energyLevel;

  const _CyclePhaseData({
    required this.name,
    required this.emoji,
    required this.description,
    required this.recommendedCategories,
    required this.avoidCategories,
    required this.nutritionTip,
    required this.energyLevel,
  });
}

const Map<String, _CyclePhaseData> _cyclePhases = {
  'follicular': _CyclePhaseData(
    name: 'Folliculaire',
    emoji: '🌱',
    description: 'Phase de haute énergie ! Ton corps produit plus d\'œstrogènes, ce qui booste ta force et ton endurance.',
    recommendedCategories: ['HIIT', 'musculation', 'SALLE', 'Running', 'Dance'],
    avoidCategories: [],
    nutritionTip: 'Favorise les protéines maigres (poulet, tofu) et les glucides complexes pour soutenir tes entraînements intensifs.',
    energyLevel: 'Élevée',
  ),
  'ovulation': _CyclePhaseData(
    name: 'Ovulation',
    emoji: '✨',
    description: 'Ton pic d\'énergie ! C\'est le meilleur moment pour te dépasser et tenter de nouveaux défis.',
    recommendedCategories: ['HIIT', 'Running', 'Dance', 'SALLE', 'musculation'],
    avoidCategories: [],
    nutritionTip: 'Mange des aliments riches en zinc (graines de citrouille, légumineuses) et en fibres pour équilibrer tes hormones.',
    energyLevel: 'Maximum',
  ),
  'luteal': _CyclePhaseData(
    name: 'Lutéale',
    emoji: '🍂',
    description: 'Phase de transition. L\'énergie diminue progressivement — écoute ton corps et adapte l\'intensité.',
    recommendedCategories: ['Pilates', 'MAISON', 'RECUPERATION'],
    avoidCategories: ['HIIT'],
    nutritionTip: 'Privilégie le magnésium (chocolat noir, épinards) pour réduire les crampes et améliorer l\'humeur.',
    energyLevel: 'Modérée',
  ),
  'menstrual': _CyclePhaseData(
    name: 'Menstruelle',
    emoji: '🌊',
    description: 'Phase de repos et de récupération. Sois douce avec toi-même et favorise les mouvements doux.',
    recommendedCategories: ['RECUPERATION', 'Pilates', 'MAISON'],
    avoidCategories: ['HIIT', 'Running', 'musculation'],
    nutritionTip: 'Consomme des aliments riches en fer (lentilles, viande rouge maigre) et hydrate-toi bien pour compenser les pertes.',
    energyLevel: 'Faible',
  ),
};

// ── All Programs Data ────────────────────────────────────────────────────────

final List<ChatProgramCard> _allPrograms = [
  // ── MAISON ──
  const ChatProgramCard(
    id: 'home_glow',
    name: 'Home Glow',
    duration: '4 semaines',
    sessions: '3 séances / sem.',
    phases: 'Règles + Foll. + Ovul.',
    category: 'MAISON',
    color: Color(0xFF3B7DD8),
    imageUrl: 'assets/images/fullbody.jpg',
    compatibleCycles: ['Folliculaire', 'Ovulation'],
  ),
  const ChatProgramCard(
    id: 'pilates_reset',
    name: 'Pilates Reset',
    duration: '8 semaines',
    sessions: '3 séances / sem.',
    phases: 'Toutes phases',
    category: 'Pilates',
    color: Color(0xFF1565C0),
    imageUrl: 'assets/images/pilates.jpg',
    compatibleCycles: ['Règles', 'Lutéale'],
  ),
  const ChatProgramCard(
    id: 'booty_home',
    name: 'Booty From Home',
    duration: '4 semaines',
    sessions: '4 séances / sem.',
    phases: 'Toutes phases',
    category: 'MAISON',
    color: Color(0xFF283593),
    imageUrl: 'assets/images/strength.jpg',
    compatibleCycles: ['Folliculaire', 'Lutéale'],
  ),
  // ── SALLE ──
  const ChatProgramCard(
    id: 'body_builder',
    name: 'Body Builder',
    duration: '6 semaines',
    sessions: '4 séances / sem.',
    phases: 'Follic. + Ovul.',
    category: 'SALLE',
    color: Color(0xFF1C4D30),
    imageUrl: 'assets/images/strength.jpg',
    compatibleCycles: ['Folliculaire', 'Ovulation'],
  ),
  const ChatProgramCard(
    id: 'stronger_you',
    name: 'Stronger You',
    duration: '4 semaines',
    sessions: '3 séances / sem.',
    phases: 'Toutes phases',
    category: 'SALLE',
    color: Color(0xFF2E7D32),
    imageUrl: 'assets/images/upper.jpg',
    compatibleCycles: ['Règles', 'Ovulation'],
  ),
  const ChatProgramCard(
    id: 'lean_4_life',
    name: 'Lean 4 Life',
    duration: '4 semaines',
    sessions: '3 séances / sem.',
    phases: 'Toutes phases',
    category: 'SALLE',
    color: Color(0xFF00695C),
    imageUrl: 'assets/images/fullbody.jpg',
    compatibleCycles: ['Règles', 'Folliculaire', 'Lutéale'],
  ),
];

// ── Intent Detection ─────────────────────────────────────────────────────────

enum _Intent {
  programCycle,
  programHome,
  programSalle,
  programAll,
  cycleCurrent,
  cycleExplain,
  nutritionTip,
  workoutCategories,
  greeting,
  unknown,
}

_Intent _detectIntent(String message) {
  final m = message.toLowerCase();

  if ((m.contains('programme') || m.contains('program')) &&
      (m.contains('cycle') || m.contains('phase') || m.contains('règles') ||
          m.contains('follicul') || m.contains('ovul') || m.contains('lutéal'))) {
    return _Intent.programCycle;
  }
  if ((m.contains('programme') || m.contains('program')) &&
      (m.contains('maison') || m.contains('home') || m.contains('chez moi'))) {
    return _Intent.programHome;
  }
  if ((m.contains('programme') || m.contains('program')) &&
      (m.contains('salle') || m.contains('gym') || m.contains('musculation'))) {
    return _Intent.programSalle;
  }
  if (m.contains('programme') || m.contains('program')) return _Intent.programAll;
  if (m.contains('cycle') && (m.contains('quelle') || m.contains('actuel') || m.contains('suis'))) {
    return _Intent.cycleCurrent;
  }
  if (m.contains('cycle') || m.contains('phase') || m.contains('follicul') ||
      m.contains('ovul') || m.contains('lutéal') || m.contains('règles')) {
    return _Intent.cycleExplain;
  }
  if (m.contains('nutrition') || m.contains('manger') || m.contains('aliment') ||
      m.contains('repas') || m.contains('calories') || m.contains('diète')) {
    return _Intent.nutritionTip;
  }
  if (m.contains('entraîn') || m.contains('workout') || m.contains('exercice') ||
      m.contains('sport') || m.contains('séance')) {
    return _Intent.workoutCategories;
  }
  if (m.contains('bonjour') || m.contains('salut') || m.contains('hello') ||
      m.contains('hi ') || m == 'hi' || m.contains('bonsoir')) {
    return _Intent.greeting;
  }
  return _Intent.unknown;
}

// ── Response Generator ───────────────────────────────────────────────────────

class _ChatResponse {
  final String text;
  final List<ChatProgramCard> cards;
  const _ChatResponse(this.text, {this.cards = const []});
}

_ChatResponse _generateResponse(String userMessage) {
  final intent = _detectIntent(userMessage);
  final m = userMessage.toLowerCase();

  switch (intent) {
    case _Intent.greeting:
      return _ChatResponse(
        '👋 Bonjour ! Je suis ton assistante FitEva.\n\n'
        'Je peux t\'aider avec :\n'
        '• 🔄 Programmes adaptés à ton cycle\n'
        '• 🏠 Programmes maison\n'
        '• 🏋️ Programmes en salle\n'
        '• 🥗 Conseils nutritionnels\n\n'
        'Que voudrais-tu savoir ?',
      );

    case _Intent.programCycle:
      return _buildCycleProgramResponse(m);

    case _Intent.programHome:
      final cards = _allPrograms.where((p) =>
          p.category == 'MAISON' || p.category == 'Pilates').toList();
      return _ChatResponse(
        '🏠 **Programmes Maison**\n\nVoici tous les programmes que tu peux faire chez toi, sans équipement :',
        cards: cards,
      );

    case _Intent.programSalle:
      final cards = _allPrograms.where((p) => p.category == 'SALLE').toList();
      return _ChatResponse(
        '🏋️ **Programmes en Salle**\n\nVoici les programmes disponibles pour la salle de sport :',
        cards: cards,
      );

    case _Intent.programAll:
      return _ChatResponse(
        '📋 **Tous les programmes**\n\nTu peux choisir parmi nos programmes maison et salle. Appuie sur une carte pour démarrer !',
        cards: _allPrograms,
      );

    case _Intent.cycleCurrent:
      final phase = _cyclePhases['follicular']!;
      final cards = _allPrograms.where((p) =>
          p.compatibleCycles.any((c) => c.toLowerCase().contains('follicul') ||
              c.toLowerCase().contains('ovul'))).toList();
      return _ChatResponse(
        '🌱 Tu es en phase **${phase.name}** (Jour 8).\n\n'
        '${phase.description}\n\n'
        '⚡ Énergie : ${phase.energyLevel}\n\n'
        'Voici les programmes recommandés pour toi :',
        cards: cards,
      );

    case _Intent.cycleExplain:
      return _ChatResponse(_buildCycleExplainText(m));

    case _Intent.nutritionTip:
      return _ChatResponse(_buildNutritionText(m));

    case _Intent.workoutCategories:
      return _ChatResponse(
        '💪 Voici les catégories d\'entraînement disponibles :\n\n'
        '🔥 **HIIT** — Cardio intense, brûle-graisses\n'
        '🧘 **Pilates** — Gainage, posture, souplesse\n'
        '💪 **Musculation** — Force et définition\n'
        '💃 **Dance** — Cardio fun, bonne humeur\n'
        '🏃 **Running** — Endurance et cardio\n'
        '🏋️ **Salle** — Machines et poids libres\n'
        '🏠 **Maison** — Sans équipement\n'
        '🤰 **Grossesse** — Spécial prénatal\n'
        '🌿 **Récupération** — Étirements, yoga, méditation\n\n'
        'Tu veux un programme pour une catégorie ?',
      );

    case _Intent.unknown:
    default:
      return _ChatResponse(
        '🤔 Je ne suis pas sûre de comprendre.\n\n'
        'Tu peux me demander :\n'
        '• "Programmes pour la phase folliculaire"\n'
        '• "Programmes maison"\n'
        '• "Programmes en salle"\n'
        '• "Conseils nutrition pour les règles"',
      );
  }
}

_ChatResponse _buildCycleProgramResponse(String m) {
  String? phaseKey;
  if (m.contains('follicul')) phaseKey = 'follicular';
  else if (m.contains('ovul')) phaseKey = 'ovulation';
  else if (m.contains('lutéal') || m.contains('luteal')) phaseKey = 'luteal';
  else if (m.contains('règles') || m.contains('menstruel')) phaseKey = 'menstrual';

  if (phaseKey == null) phaseKey = 'follicular';

  final phase = _cyclePhases[phaseKey]!;
  final phaseLabel = phase.name.toLowerCase();

  final cards = _allPrograms.where((p) {
    return p.compatibleCycles.any((c) {
      final cl = c.toLowerCase();
      if (phaseKey == 'follicular') return cl.contains('follicul');
      if (phaseKey == 'ovulation') return cl.contains('ovul');
      if (phaseKey == 'luteal') return cl.contains('lutéal') || cl.contains('luteal');
      if (phaseKey == 'menstrual') return cl.contains('règles');
      return cl.contains(phaseLabel);
    });
  }).toList();

  final avoidText = phase.avoidCategories.isNotEmpty
      ? '\n⚠️ À éviter : ${phase.avoidCategories.join(', ')}'
      : '';

  final text = '${phase.emoji} **Phase ${phase.name}**\n\n'
      '${phase.description}\n\n'
      '⚡ Énergie : ${phase.energyLevel}$avoidText\n\n'
      '${cards.isNotEmpty ? 'Programmes recommandés pour toi :' : 'Aucun programme trouvé pour cette phase.'}';

  return _ChatResponse(text, cards: cards);
}

String _buildCycleExplainText(String m) {
  if (m.contains('follicul')) {
    final p = _cyclePhases['follicular']!;
    return '${p.emoji} **Phase Folliculaire** (Jours 6–13)\n\n${p.description}\n\n'
        '🏋️ Idéal pour : ${p.recommendedCategories.join(', ')}\n'
        '⚡ Énergie : ${p.energyLevel}';
  }
  if (m.contains('ovul')) {
    final p = _cyclePhases['ovulation']!;
    return '${p.emoji} **Phase d\'Ovulation** (Jours 14–16)\n\n${p.description}\n\n'
        '🏋️ Idéal pour : ${p.recommendedCategories.join(', ')}\n'
        '⚡ Énergie : ${p.energyLevel}';
  }
  if (m.contains('lutéal') || m.contains('luteal')) {
    final p = _cyclePhases['luteal']!;
    return '${p.emoji} **Phase Lutéale** (Jours 17–28)\n\n${p.description}\n\n'
        '🏋️ Idéal pour : ${p.recommendedCategories.join(', ')}\n'
        '⚠️ Éviter : ${p.avoidCategories.join(', ')}\n'
        '⚡ Énergie : ${p.energyLevel}';
  }
  if (m.contains('règles') || m.contains('menstruel')) {
    final p = _cyclePhases['menstrual']!;
    return '${p.emoji} **Phase Menstruelle** (Jours 1–5)\n\n${p.description}\n\n'
        '🏋️ Idéal pour : ${p.recommendedCategories.join(', ')}\n'
        '⚠️ Éviter : ${p.avoidCategories.join(', ')}\n'
        '⚡ Énergie : ${p.energyLevel}';
  }
  return '🔄 **Les 4 phases de ton cycle :**\n\n'
      '🌊 **Menstruelle** (J1–5) : Repos, récupération, yoga doux\n'
      '🌱 **Folliculaire** (J6–13) : Énergie montante, parfaite pour le HIIT\n'
      '✨ **Ovulation** (J14–16) : Pic d\'énergie, dépassement de soi\n'
      '🍂 **Lutéale** (J17–28) : Transition, privilégie le Pilates\n\n'
      'Quelle phase veux-tu explorer ?';
}

String _buildNutritionText(String m) {
  if (m.contains('follicul')) return '🌱 **Nutrition — Phase Folliculaire**\n\n${_cyclePhases['follicular']!.nutritionTip}';
  if (m.contains('ovul')) return '✨ **Nutrition — Phase Ovulation**\n\n${_cyclePhases['ovulation']!.nutritionTip}';
  if (m.contains('lutéal') || m.contains('luteal')) return '🍂 **Nutrition — Phase Lutéale**\n\n${_cyclePhases['luteal']!.nutritionTip}';
  if (m.contains('règles') || m.contains('menstruel')) return '🌊 **Nutrition — Phase Menstruelle**\n\n${_cyclePhases['menstrual']!.nutritionTip}';
  return '🥗 **Conseils nutritionnels par phase :**\n\n'
      '🌊 **Règles** : Fer (lentilles, viande maigre) + hydratation\n'
      '🌱 **Folliculaire** : Protéines maigres + glucides complexes\n'
      '✨ **Ovulation** : Zinc (graines) + fibres\n'
      '🍂 **Lutéale** : Magnésium (chocolat noir, épinards)\n\n'
      'Demande-moi pour une phase spécifique !';
}

// ── Chat Notifier ─────────────────────────────────────────────────────────────

class ChatNotifier extends Notifier<List<ChatMessage>> {
  @override
  List<ChatMessage> build() => [];

  Future<void> sendMessage(String text) async {
    state = [...state, ChatMessage(text: text, isUser: true)];
    await Future.delayed(const Duration(milliseconds: 700));
    final response = _generateResponse(text);
    state = [
      ...state,
      ChatMessage(
        text: response.text,
        isUser: false,
        programCards: response.cards,
      ),
    ];
  }
}

final chatProvider = NotifierProvider<ChatNotifier, List<ChatMessage>>(
  ChatNotifier.new,
);