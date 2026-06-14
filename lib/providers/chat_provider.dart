import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ── Program Card ──────────────────────────────────────────────────────────────

class ChatProgramCard {
  final String id, name, duration, sessions, phases, category, imageUrl;
  final Color color;
  final List<String> compatibleCycles;
  const ChatProgramCard({
    required this.id, required this.name, required this.duration,
    required this.sessions, required this.phases, required this.category,
    required this.color, required this.imageUrl, required this.compatibleCycles,
  });
}

// ── Generated Workout ─────────────────────────────────────────────────────────

class GeneratedWorkout {
  final String title, subtitle;
  final List<WorkoutSection> sections;
  const GeneratedWorkout({required this.title, required this.subtitle, required this.sections});
}

class WorkoutSection {
  final String name, duration;
  final List<String> exercises;
  const WorkoutSection({required this.name, required this.duration, required this.exercises});
}

// ── App Category (for home grid) ──────────────────────────────────────────────

class AiCategory {
  final String id, label, emoji;
  final Color color;
  final List<String> questions;
  const AiCategory({
    required this.id, required this.label, required this.emoji,
    required this.color, required this.questions,
  });
}

const appCategories = <AiCategory>[
  AiCategory(
    id: 'workout', label: 'Workout', emoji: '💪',
    color: Color(0xFF7C6AFA),
    questions: [
      'Génère-moi une séance personnalisée',
      'Quels programmes sont disponibles ?',
      'Programme maison sans équipement',
      'Programme pour la salle de sport',
      'Exercices adaptés à mon cycle',
    ],
  ),
  AiCategory(
    id: 'nutrition', label: 'Nutrition', emoji: '🥗',
    color: Color(0xFF22C55E),
    questions: [
      'Comment calculer mon objectif calorique ?',
      'Que manger pendant la phase folliculaire ?',
      'Aliments riches en protéines pour se muscler',
      'Repas équilibré avant l\'entraînement',
      'Que manger pendant les règles ?',
    ],
  ),
  AiCategory(
    id: 'cycle', label: 'Mon Cycle', emoji: '🌊',
    color: Color(0xFFF472B6),
    questions: [
      'Explique-moi les 4 phases du cycle',
      'Comment s\'entraîner pendant les règles ?',
      'Quelle phase booste le plus l\'énergie ?',
      'Sport conseillé en phase lutéale',
      'Comment suivre mon cycle dans l\'app ?',
    ],
  ),
  AiCategory(
    id: 'grossesse', label: 'Grossesse', emoji: '🤰',
    color: Color(0xFF34D399),
    questions: [
      'Exercices sûrs au 1er trimestre',
      'Sport au 2e et 3e trimestre ?',
      'Nutrition pendant la grossesse',
      'Quand dois-je arrêter l\'exercice ?',
      'Respiration et périnée en grossesse',
    ],
  ),
  AiCategory(
    id: 'postpartum', label: 'Post-partum', emoji: '🤱',
    color: Color(0xFFFBBF24),
    questions: [
      'Quand puis-je reprendre le sport ?',
      'Exercices doux pour le post-partum',
      'Rééducation du périnée : par où commencer ?',
      'Nutrition pour les mamans allaitantes',
      'Comment regagner de l\'énergie après l\'accouchement ?',
    ],
  ),
  AiCategory(
    id: 'boutique', label: 'Boutique', emoji: '🛍️',
    color: Color(0xFFF97316),
    questions: [
      'Quels équipements pour débuter chez moi ?',
      'Haltères : quel poids choisir ?',
      'Élastiques de résistance : comment les utiliser ?',
      'Tapis de yoga : lequel choisir ?',
      'Équipement essentiel pour la musculation',
    ],
  ),
];

// ── Message Model ─────────────────────────────────────────────────────────────

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final List<ChatProgramCard> programCards;
  final List<String> quickReplies;
  final GeneratedWorkout? workout;

  ChatMessage({
    required this.text, required this.isUser,
    DateTime? timestamp,
    this.programCards = const [],
    this.quickReplies = const [],
    this.workout,
  }) : timestamp = timestamp ?? DateTime.now();
}

// ── Programs ──────────────────────────────────────────────────────────────────

const _allPrograms = <ChatProgramCard>[
  ChatProgramCard(id: 'home_glow', name: 'Home Glow',
    duration: '4 semaines', sessions: '3 séances / sem.', phases: 'Foll. + Ovul.',
    category: 'MAISON', color: Color(0xFF3B7DD8), imageUrl: 'assets/images/fullbody.jpg',
    compatibleCycles: ['Folliculaire', 'Ovulation']),
  ChatProgramCard(id: 'pilates_reset', name: 'Pilates Reset',
    duration: '8 semaines', sessions: '3 séances / sem.', phases: 'Toutes phases',
    category: 'Pilates', color: Color(0xFF1565C0), imageUrl: 'assets/images/pilates.jpg',
    compatibleCycles: ['Règles', 'Lutéale']),
  ChatProgramCard(id: 'booty_home', name: 'Booty From Home',
    duration: '4 semaines', sessions: '4 séances / sem.', phases: 'Toutes phases',
    category: 'MAISON', color: Color(0xFF283593), imageUrl: 'assets/images/strength.jpg',
    compatibleCycles: ['Folliculaire', 'Lutéale']),
  ChatProgramCard(id: 'body_builder', name: 'Body Builder',
    duration: '6 semaines', sessions: '4 séances / sem.', phases: 'Follic. + Ovul.',
    category: 'SALLE', color: Color(0xFF1C4D30), imageUrl: 'assets/images/strength.jpg',
    compatibleCycles: ['Folliculaire', 'Ovulation']),
  ChatProgramCard(id: 'stronger_you', name: 'Stronger You',
    duration: '4 semaines', sessions: '3 séances / sem.', phases: 'Toutes phases',
    category: 'SALLE', color: Color(0xFF2E7D32), imageUrl: 'assets/images/upper.jpg',
    compatibleCycles: ['Règles', 'Ovulation']),
  ChatProgramCard(id: 'lean_4_life', name: 'Lean 4 Life',
    duration: '4 semaines', sessions: '3 séances / sem.', phases: 'Toutes phases',
    category: 'SALLE', color: Color(0xFF00695C), imageUrl: 'assets/images/fullbody.jpg',
    compatibleCycles: ['Règles', 'Folliculaire', 'Lutéale']),
];

// ── Workout Q&A ───────────────────────────────────────────────────────────────

enum _WStep { type, duration, level, equipment, done }

class _WorkoutData {
  String? type, duration, level, equipment;
}

GeneratedWorkout _buildWorkout(_WorkoutData d) {
  final t   = d.type ?? 'Full Body';
  final dur = int.tryParse(d.duration?.replaceAll(' min', '') ?? '30') ?? 30;
  final lvl = d.level ?? 'Intermédiaire';
  final mainMin = dur - 10;

  final Map<String, List<String>> bank = {
    'HIIT': ['Burpees — 40s / repos 20s', 'Squats sautés — 40s / repos 20s',
      'Mountain climbers — 40s / repos 20s', 'Jumping jacks — 40s / repos 20s',
      'Fentes sautées — 40s / repos 20s', 'High knees — 40s / repos 20s',
      'Push-ups explosifs — 40s / repos 20s'],
    'Pilates': ['Roll-up — 12 rép.', 'Hundred — 60s', 'Bridge — 15 rép.',
      'Single leg stretch — 12 rép.', 'Plank — 45s', 'Side kick series — 12 rép.'],
    'Musculation': ['Squats haltères — 4×12', 'Soulevé de terre — 3×10',
      'Presse épaules — 3×12', 'Curl biceps — 3×15',
      'Hip thrust — 4×15', 'Rowing haltères — 3×12'],
    'Full Body': ['Squats — 3×15', 'Push-ups — 3×12', 'Fentes — 3×12 / jambe',
      'Plank — 3×45s', 'Hip thrust — 3×15', 'Mountain climbers — 3×30s'],
    'Yoga / Étirements': ['Salutation au soleil — 3 cycles', 'Guerrier I & II — 5 respirations',
      'Chien tête en bas — 30s', 'Pigeon — 1 min / côté',
      'Torsion assise — 30s', 'Savasana — 3 min'],
    'Cardio Doux': ['Marche rapide sur place — 2 min', 'Genoux hauts lents — 1 min',
      'Talons fesses — 1 min', 'Stepping latéral — 2 min', 'Rotation des hanches — 1 min'],
  };

  final exercises = bank[t] ?? bank['Full Body']!;
  final count     = (mainMin / 3).round().clamp(3, exercises.length);

  return GeneratedWorkout(
    title: '$t · ${d.duration}',
    subtitle: '$lvl · ${d.equipment ?? 'Sans équipement'}',
    sections: [
      WorkoutSection(name: '🔥 Échauffement', duration: '5 min',
        exercises: ['Rotations articulaires — 1 min', 'Marche sur place — 2 min',
          if (lvl != 'Débutante') 'Jumping jacks légers — 2 min']),
      WorkoutSection(name: '💪 Circuit principal', duration: '$mainMin min',
        exercises: exercises.sublist(0, count)),
      WorkoutSection(name: '🧘 Retour au calme', duration: '5 min',
        exercises: ['Étirements quadriceps — 30s / jambe',
          'Étirements ischio-jambiers — 30s', 'Respiration profonde — 1 min']),
    ],
  );
}

// ── Response Generator ────────────────────────────────────────────────────────

class _Resp {
  final String text;
  final List<ChatProgramCard> cards;
  final List<String> quickReplies;
  final GeneratedWorkout? workout;
  const _Resp(this.text, {this.cards = const [], this.quickReplies = const [], this.workout});
}

_Resp _generateResponse(String msg, String? categoryId) {
  final m   = msg.toLowerCase();
  final cat = categoryId ?? _guessCategory(m);

  switch (cat) {
    // ── WORKOUT ──────────────────────────────────────────────────────────────
    case 'workout':
      if (m.contains('génère') || m.contains('personnalis') || m.contains('séance')) {
        return const _Resp(
          '💪 Je vais créer une séance sur mesure.\n\nQuel type d\'entraînement ?',
          quickReplies: ['HIIT', 'Pilates', 'Musculation', 'Full Body', 'Yoga / Étirements', 'Cardio Doux'],
        );
      }
      if (m.contains('maison') || m.contains('sans équipement')) {
        final cards = _allPrograms.where((p) =>
            p.category == 'MAISON' || p.category == 'Pilates').toList();
        return _Resp('🏠 **Programmes Maison**\n\nTu peux faire ces programmes chez toi, sans équipement :', cards: cards);
      }
      if (m.contains('salle') || m.contains('gym')) {
        final cards = _allPrograms.where((p) => p.category == 'SALLE').toList();
        return _Resp('🏋️ **Programmes Salle**\n\nVoici les programmes disponibles pour la salle :', cards: cards);
      }
      if (m.contains('cycle') || m.contains('phase')) {
        final cards = _allPrograms.where((p) =>
            p.compatibleCycles.any((c) => c.contains('Follic') || c.contains('Ovul'))).toList();
        return _Resp(
          '🔄 **Programmes adaptés au cycle**\n\nEn ce moment (phase folliculaire), ces programmes sont idéaux pour toi :',
          cards: cards,
          quickReplies: ['Phase lutéale', 'Phase des règles'],
        );
      }
      return _Resp('📋 Voici tous les programmes disponibles dans l\'app :', cards: List.from(_allPrograms),
        quickReplies: ['Générer une séance', 'Programmes maison', 'Programmes salle']);

    // ── NUTRITION ─────────────────────────────────────────────────────────────
    case 'nutrition':
      if (m.contains('calorique') || m.contains('objectif')) {
        return const _Resp(
          '🎯 **Objectif calorique**\n\nTon objectif est calculé dans l\'app selon ton poids, ta taille, ton niveau d\'activité et ton but (perdre, maintenir ou prendre du poids).\n\n📍 **Où le voir** → Section Nutrition > icône paramètre en haut\n\n💡 En moyenne pour une femme active : **1 800–2 200 kcal / jour**',
          quickReplies: ['Que manger avant l\'entraînement ?', 'Macros recommandées'],
        );
      }
      if (m.contains('follicul') || m.contains('après les règles')) {
        return const _Resp(
          '🌱 **Nutrition — Phase Folliculaire**\n\nTon corps a de l\'énergie ! Booste tes performances avec :\n\n• 🥩 **Protéines maigres** : poulet, tofu, œufs\n• 🌾 **Glucides complexes** : riz complet, patate douce, avoine\n• 🥑 **Bons lipides** : avocat, noix\n\n📍 Retrouve des recettes adaptées dans **Nutrition > Recettes**',
        );
      }
      if (m.contains('règles') || m.contains('menstruel')) {
        return const _Resp(
          '🌊 **Nutrition — Pendant les règles**\n\nPrioritaire : reconstituer les pertes.\n\n• 🫘 **Fer** : lentilles, épinards, viande rouge maigre\n• 💧 **Hydratation** : 2L+ d\'eau / jour\n• 🍫 **Magnésium** : chocolat noir 70%, banane\n• ❌ Évite caféine et sucre raffiné (amplifient les crampes)',
        );
      }
      if (m.contains('protéine') || m.contains('muscl')) {
        return const _Resp(
          '💪 **Protéines pour se muscler**\n\nVise **1.6–2g de protéines par kg** de poids corporel.\n\nMeilleures sources :\n• Blanc de poulet : 31g / 100g\n• Yaourt grec : 10g / 100g\n• Lentilles cuites : 9g / 100g\n• Œufs : 13g / 100g\n• Fromage blanc 0% : 11g / 100g\n\n📍 Ajoute ces aliments dans **Nutrition > Suivi**',
        );
      }
      if (m.contains('avant') && m.contains('entraîn')) {
        return const _Resp(
          '⚡ **Repas pré-entraînement**\n\n**2h avant :**\n• Riz + poulet + légumes\n• Pâtes complètes + thon\n\n**30–45 min avant :**\n• Banane + amandes\n• Yaourt grec + miel\n• Flocons d\'avoine + fruits\n\n💡 Évite les aliments gras et très fibreux juste avant le sport',
        );
      }
      return const _Resp(
        '🥗 **Nutrition dans FitEva**\n\nL\'app te permet de :\n• 📊 Suivre tes calories et macros\n• 🍽️ Enregistrer tes repas\n• 📅 Voir ton bilan journalier\n\n📍 Accède à la section **Nutrition** depuis le menu principal',
        quickReplies: ['Objectif calorique', 'Que manger pendant les règles ?', 'Protéines pour se muscler'],
      );

    // ── CYCLE ─────────────────────────────────────────────────────────────────
    case 'cycle':
      if (m.contains('4 phases') || m.contains('explique')) {
        return const _Resp(
          '🔄 **Les 4 phases de ton cycle :**\n\n🌊 **Menstruelle** (J1–5)\nRepos, yoga doux, récupération. Énergie faible.\n\n🌱 **Folliculaire** (J6–13)\nÉnergie montante. Parfaite pour le HIIT et la muscu.\n\n✨ **Ovulation** (J14–16)\nPic d\'énergie. Repousse tes limites !\n\n🍂 **Lutéale** (J17–28)\nTransition. Privilégie Pilates et sport doux.\n\n📍 Suis ton cycle dans **Cycle > Mon Calendrier**',
          quickReplies: ['Sport pendant les règles', 'Phase folliculaire', 'Phase lutéale'],
        );
      }
      if (m.contains('règles') || m.contains('menstruel')) {
        return const _Resp(
          '🌊 **Sport pendant les règles**\n\nC\'est OK de bouger — écoute ton corps.\n\n✅ **Recommandés** :\n• Yoga / stretching\n• Marche rapide\n• Pilates doux\n• Natation légère\n\n❌ **À éviter** :\n• HIIT intense\n• Musculation lourde\n• Exercices abdominaux intenses\n\n📍 Retrouve les programmes adaptés dans **Workout > Récupération**',
        );
      }
      if (m.contains('lutéal') || m.contains('luteal')) {
        return const _Resp(
          '🍂 **Phase Lutéale (J17–28)**\n\nL\'énergie diminue progressivement. Ton corps se prépare aux règles.\n\n✅ **Idéal** : Pilates, yoga, marche, MAISON\n❌ **Évite** : HIIT, sessions très intenses\n\n💡 C\'est normal de te sentir plus fatiguée. Réduis l\'intensité, pas la fréquence.',
          quickReplies: ['Programmes Pilates', 'Nutrition phase lutéale'],
        );
      }
      if (m.contains('suivre') || m.contains('calendrier') || m.contains('app')) {
        return const _Resp(
          '📅 **Suivi du cycle dans FitEva**\n\nDans la section **Cycle**, tu peux :\n• 📌 Enregistrer le début et la durée de tes règles\n• 📊 Voir ta phase actuelle en temps réel\n• 🏋️ Recevoir des recommandations d\'entraînement par phase\n• 💊 Suivre tes symptômes et ton humeur\n\n📍 Accède via l\'onglet **Cycle** dans le menu bas',
        );
      }
      if (m.contains('follicul')) {
        return const _Resp(
          '🌱 **Phase Folliculaire (J6–13)**\n\nLes œstrogènes montent — tu as plus d\'énergie et de force.\n\n✅ **Parfait pour** : HIIT, musculation, running, dance\n⚡ Énergie : **Élevée**\n\n💡 C\'est le meilleur moment pour augmenter tes charges ou tenter de nouveaux défis !',
          quickReplies: ['Programmes folliculaire', 'Nutrition folliculaire'],
        );
      }
      return const _Resp(
        '🌙 **Mon Cycle dans FitEva**\n\nL\'app adapte tes programmes et conseils selon ta phase menstruelle.',
        quickReplies: ['Explique les 4 phases', 'Sport pendant les règles', 'Suivre mon cycle dans l\'app'],
      );

    // ── GROSSESSE ─────────────────────────────────────────────────────────────
    case 'grossesse':
      if (m.contains('1er') || m.contains('premier') || m.contains('trimestre 1')) {
        return const _Resp(
          '🤰 **Sport au 1er trimestre (0–12 sem.)**\n\nEn général sûr si ta grossesse est normale.\n\n✅ **Recommandés** :\n• Marche rapide\n• Natation\n• Yoga prénatal\n• Pilates adapté\n• Renforcement doux\n\n⚠️ **À éviter** :\n• Sports de contact\n• Exercices sur le dos après 12 sem.\n• HIIT intense\n• Abdominaux traditionnels\n\n📍 Retrouve les programmes **Grossesse** dans l\'app\n\n⚕️ Consulte toujours ton médecin avant de commencer.',
        );
      }
      if (m.contains('2e') || m.contains('3e') || m.contains('deuxième') || m.contains('troisième')) {
        return const _Resp(
          '🤰 **Sport au 2e & 3e trimestre**\n\n**2e trimestre (13–26 sem.)** :\nSouvent le plus confortable. Continue avec yoga, marche, aquagym.\n\n**3e trimestre (27–40 sem.)** :\nRéduis l\'intensité. Privilégie : respiration, périnée, étirements doux, marche.\n\n⚠️ Arrête si : contractions, saignements, essoufflement fort, douleurs.\n\n📍 Section **Grossesse** dans l\'app pour des exercices adaptés.',
        );
      }
      if (m.contains('nutrition') || m.contains('manger')) {
        return const _Resp(
          '🥗 **Nutrition pendant la grossesse**\n\n• +200–300 kcal/jour (pas "manger pour deux")\n• 🥩 Fer : 27mg/jour (viande, légumineuses)\n• 🥛 Calcium : 1000mg/jour (laitages, sardines)\n• 🐟 Oméga-3 : sardines, noix (évite les poissons crus)\n• 🌿 Acide folique : légumes verts, légumineuses\n• ❌ Évite : charcuterie, fromages au lait cru, alcool, caféine excessive',
        );
      }
      if (m.contains('arrêter') || m.contains('quand')) {
        return const _Resp(
          '⚕️ **Quand arrêter l\'exercice ?**\n\nArrête immédiatement et consulte si tu ressens :\n\n🚨 Saignements ou pertes inhabituelles\n🚨 Contractions avant terme\n🚨 Essoufflement excessif au repos\n🚨 Douleurs pelviennes ou abdominales\n🚨 Diminution des mouvements du bébé\n🚨 Vertiges ou évanouissements\n\n💡 En l\'absence de symptômes, un exercice modéré est bénéfique tout au long de la grossesse.',
        );
      }
      if (m.contains('périnée') || m.contains('respiration')) {
        return const _Resp(
          '🌸 **Périnée & Respiration en grossesse**\n\n**Exercices de Kegel** (périnée) :\nContracter le périnée 5–10 sec, relâcher. 10 répétitions, 3x/jour.\n\n**Respiration diaphragmatique** :\nInspire par le nez en gonflant le ventre, expire lentement par la bouche. Réduit le stress et prépare à l\'accouchement.\n\n📍 Section **Grossesse > Exercices** dans l\'app',
        );
      }
      return const _Resp(
        '🤰 **Section Grossesse dans FitEva**\n\nL\'app propose des programmes adaptés à chaque trimestre.',
        quickReplies: ['Sport au 1er trimestre', 'Nutrition grossesse', 'Périnée et respiration', 'Quand arrêter l\'exercice ?'],
      );

    // ── POST-PARTUM ───────────────────────────────────────────────────────────
    case 'postpartum':
      if (m.contains('reprendre') || m.contains('quand')) {
        return const _Resp(
          '🤱 **Reprendre le sport après l\'accouchement**\n\n**Accouchement naturel** :\n• J1–6 sem. : Marche douce, respiration, Kegel\n• 6–8 sem. : Après accord médical, reprendre progressivement\n\n**Césarienne** :\n• 8–12 sem. : Cicatrisation avant tout effort abdominal\n• Toujours avis médical avant de reprendre\n\n⚕️ La rééducation périnéale est **prioritaire avant tout sport**.\n\n📍 Programme Post-partum disponible dans l\'app',
        );
      }
      if (m.contains('exercice') || m.contains('doux') || m.contains('programme')) {
        return const _Resp(
          '🌸 **Exercices doux post-partum**\n\n**Phase 1 (0–6 sem.)** :\n• Respiration abdominale profonde\n• Exercices de Kegel\n• Marche légère\n\n**Phase 2 (6–12 sem., après feu vert médecin)** :\n• Pilates doux\n• Yoga postnatal\n• Renforcement progressif du core\n\n⚠️ Évite : abdominaux traditionnels, sauts, sports d\'impact jusqu\'à rééducation complète\n\n📍 Section **Post-partum** dans l\'app',
          quickReplies: ['Rééducation périnée', 'Nutrition allaitement'],
        );
      }
      if (m.contains('périnée') || m.contains('rééducation')) {
        return const _Resp(
          '🌸 **Rééducation du périnée**\n\nElle est recommandée pour **toutes les femmes** après l\'accouchement.\n\n**Par où commencer :**\n1. Consulte un kinésithérapeute spécialisé\n2. En France : 10 séances remboursées à 100%\n3. Commence les Kegel dès J2 (douceur)\n\n**Exercices à faire chez soi :**\n• Kegel : contracter 5 sec, relâcher, ×10\n• Respiration diaphragmatique\n• Pont fessier très doux\n\n📍 Programme dédié dans **Post-partum > Périnée**',
        );
      }
      if (m.contains('allait') || m.contains('nutrition')) {
        return const _Resp(
          '🥛 **Nutrition pendant l\'allaitement**\n\n• **+500 kcal/jour** supplémentaires\n• 💧 **Hydratation** : 3L+ d\'eau / jour\n• 🥩 **Protéines** : 70g+/jour\n• 🐟 **Oméga-3** : DHA pour le développement du bébé\n• 🥛 **Calcium** : 1 000mg/jour\n• ☕ Caféine : max 200mg/jour (1–2 cafés)\n\n💡 Ne fais pas de régime restrictif pendant l\'allaitement',
        );
      }
      if (m.contains('énergie') || m.contains('fatigue')) {
        return const _Resp(
          '⚡ **Regagner de l\'énergie post-partum**\n\n• 😴 Dors quand bébé dort (priorité absolue)\n• 🥗 Mange des repas riches en fer (lentilles, viande, épinards)\n• 💧 Hydrate-toi bien\n• 🚶 Marche douce : booste l\'énergie sans épuiser\n• 🌞 Expose-toi à la lumière naturelle\n• 🫂 N\'hésite pas à demander de l\'aide\n\n📍 Programmes doux dans **Post-partum** dans l\'app',
        );
      }
      return const _Resp(
        '🤱 **Section Post-partum dans FitEva**\n\nL\'app propose un programme progressif adapté à ta récupération.',
        quickReplies: ['Quand reprendre le sport ?', 'Exercices doux post-partum', 'Rééducation périnée', 'Énergie et fatigue'],
      );

    // ── BOUTIQUE ──────────────────────────────────────────────────────────────
    case 'boutique':
      if (m.contains('débuter') || m.contains('commencer') || m.contains('essentiel')) {
        return const _Resp(
          '🛍️ **Équipements essentiels pour débuter**\n\nPour commencer chez toi sans te ruiner :\n\n1. 🏋️ **Haltères ajustables** (2–10 kg) — le plus polyvalent\n2. 🟢 **Élastiques de résistance** (set 3 niveaux) — idéal pour fessiers/cuisses\n3. 🧘 **Tapis de yoga** (épaisseur 6mm+) — confort et grip\n4. 🎯 **Bande de résistance** — abdos, périnée, yoga\n\n💡 Budget débutante : 50–80€ pour avoir l\'essentiel\n\n📍 Retrouve ces produits dans la section **Boutique** de l\'app',
        );
      }
      if (m.contains('haltère') || m.contains('poids')) {
        return const _Resp(
          '🏋️ **Quel poids d\'haltères choisir ?**\n\n**Débutante :**\n• Exercices du bas du corps : 4–6 kg\n• Exercices du haut du corps : 2–4 kg\n\n**Intermédiaire :**\n• Bas du corps : 8–12 kg\n• Haut du corps : 4–8 kg\n\n**Avancée :**\n• Bas du corps : 14–20 kg\n• Haut du corps : 8–14 kg\n\n💡 Règle d\'or : la dernière répétition doit être difficile mais réalisable avec une bonne forme.',
        );
      }
      if (m.contains('élastique') || m.contains('résistance')) {
        return const _Resp(
          '🟢 **Utiliser les élastiques de résistance**\n\n**Types d\'élastiques :**\n• 🟡 Léger (bandes plates) : abdos, Pilates, périnée\n• 🟢 Moyen (boucle) : squats, fentes, hip thrust\n• 🔴 Fort (tubulaire) : épaules, dos, poitrine\n\n**Exercices populaires :**\n• Hip thrust avec élastique : 3×15\n• Squat sumo + élastique : 3×12\n• Kickback debout : 3×15 / côté\n\n📍 Voir les workouts avec élastiques dans **Workout > Maison**',
        );
      }
      if (m.contains('tapis') || m.contains('yoga mat')) {
        return const _Resp(
          '🧘 **Choisir son tapis de yoga**\n\n**Épaisseur :**\n• 4mm — voyage, yoga fluide\n• 6mm — usage polyvalent ✅\n• 8–10mm — Pilates, sol dur\n\n**Matière :**\n• TPE ou caoutchouc naturel — meilleur grip, éco-friendly\n• PVC — moins cher mais moins durable\n\n**Budget :** 20–60€ pour un bon tapis\n\n💡 Vérifie le grip antidérapant — essentiel pour les poses debout',
        );
      }
      if (m.contains('musculation') || m.contains('salle')) {
        return const _Resp(
          '💪 **Équipement pour la musculation**\n\n**Indispensables :**\n• Haltères 2×(2–12 kg)\n• Barre + disques (si espace)\n• Banc de musculation pliable\n• Élastiques lourds\n\n**En plus :**\n• Ceinture lumbaire (charges lourdes)\n• Gants de musculation\n• Straps de poignet\n\n📍 Retrouve ces produits dans la **Boutique** de l\'app',
        );
      }
      return const _Resp(
        '🛍️ **Boutique FitEva**\n\nTrouve tous les équipements dont tu as besoin pour t\'entraîner.',
        quickReplies: ['Équipements pour débuter', 'Quel poids d\'haltères ?', 'Élastiques de résistance', 'Choisir un tapis de yoga'],
      );

    default:
      return const _Resp(
        'Je suis là pour t\'aider ! Choisis une catégorie pour commencer.',
      );
  }
}

String _guessCategory(String m) {
  if (m.contains('grossesse') || m.contains('enceinte') || m.contains('trimestre') || m.contains('prénatal')) return 'grossesse';
  if (m.contains('post-partum') || m.contains('accouchement') || m.contains('périnée') || m.contains('allaitement')) return 'postpartum';
  if (m.contains('cycle') || m.contains('règles') || m.contains('lutéal') || m.contains('follicul') || m.contains('ovul')) return 'cycle';
  if (m.contains('nutrition') || m.contains('calorie') || m.contains('manger') || m.contains('repas') || m.contains('protéine')) return 'nutrition';
  if (m.contains('boutique') || m.contains('haltère') || m.contains('élastique') || m.contains('tapis') || m.contains('équipement')) return 'boutique';
  if (m.contains('workout') || m.contains('programme') || m.contains('séance') || m.contains('entraîn') || m.contains('exercice')) return 'workout';
  return 'workout';
}

// ── Workout Q&A notifier helper ───────────────────────────────────────────────

const _durationOptions  = ['20 min', '30 min', '45 min', '60 min'];
const _levelOptions     = ['Débutante', 'Intermédiaire', 'Avancée'];
const _equipmentOptions = ['Sans équipement', 'Haltères', 'Élastiques', 'Salle complète'];

// ── Chat Notifier ─────────────────────────────────────────────────────────────

class ChatNotifier extends Notifier<List<ChatMessage>> {
  @override
  List<ChatMessage> build() => [];

  _WStep? _wStep;
  final _wData = _WorkoutData();
  String? _activeCategoryId;

  Future<void> sendMessage(String text, {String? categoryId}) async {
    state = [...state, ChatMessage(text: text, isUser: true)];
    await Future.delayed(const Duration(milliseconds: 600));

    // ── Workout Q&A ───────────────────────────────────────────────────────────
    if (_wStep != null) {
      _handleWorkoutStep(text);
      return;
    }

    final effectiveCat = categoryId ?? _activeCategoryId;
    _activeCategoryId  = effectiveCat;

    // Start workout generator
    if ((text.toLowerCase().contains('génère') || text.toLowerCase().contains('personnalis')) &&
        (effectiveCat == 'workout' || effectiveCat == null)) {
      _wStep = _WStep.type;
      _activeCategoryId = 'workout';
      state = [...state, ChatMessage(
        text: '💪 Je vais créer une séance sur mesure.\n\nQuel type d\'entraînement ?',
        isUser: false,
        quickReplies: ['HIIT', 'Pilates', 'Musculation', 'Full Body', 'Yoga / Étirements', 'Cardio Doux'],
      )];
      return;
    }

    final r = _generateResponse(text, effectiveCat);
    state = [...state, ChatMessage(
      text: r.text, isUser: false,
      programCards: r.cards,
      quickReplies: r.quickReplies,
      workout: r.workout,
    )];
  }

  void _handleWorkoutStep(String text) {
    switch (_wStep) {
      case _WStep.type:
        _wData.type = text;
        _wStep = _WStep.duration;
        state = [...state, ChatMessage(
          text: 'Combien de temps as-tu ?',
          isUser: false, quickReplies: _durationOptions)];

      case _WStep.duration:
        _wData.duration = text;
        _wStep = _WStep.level;
        state = [...state, ChatMessage(
          text: 'Quel est ton niveau ?',
          isUser: false, quickReplies: _levelOptions)];

      case _WStep.level:
        _wData.level = text;
        _wStep = _WStep.equipment;
        state = [...state, ChatMessage(
          text: 'Quel équipement as-tu ?',
          isUser: false, quickReplies: _equipmentOptions)];

      case _WStep.equipment:
        _wData.equipment = text;
        _wStep = null;
        final w = _buildWorkout(_wData);
        state = [...state, ChatMessage(
          text: '✅ Voici ta séance personnalisée ! Bonne séance 💪',
          isUser: false, workout: w,
          quickReplies: ['Générer une autre séance'])];

      default:
        _wStep = null;
    }
  }

  void clearChat() {
    state = [];
    _wStep = null;
    _activeCategoryId = null;
    _wData.type = null;
    _wData.duration = null;
    _wData.level = null;
    _wData.equipment = null;
  }
}

final chatProvider = NotifierProvider<ChatNotifier, List<ChatMessage>>(ChatNotifier.new);
