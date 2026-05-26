import 'package:flutter/material.dart';

class PregnancyWeekData {
  final int week;
  final String babySize;
  final double lengthCm;
  final double weightG;
  final String description;
  final String poeticLine;
  final String milestone;
  final int trimester;
  final int fetalHeartRateBpm;

  const PregnancyWeekData({
    required this.week,
    required this.babySize,
    required this.lengthCm,
    required this.weightG,
    required this.description,
    required this.poeticLine,
    required this.milestone,
    required this.trimester,
    required this.fetalHeartRateBpm,
  });

  String get weightLabel {
    if (weightG < 1000) return '${weightG.round()} g';
    return '${(weightG / 1000).toStringAsFixed(1)} kg';
  }

  String get sizeLabel => '${lengthCm.toStringAsFixed(1)} cm · $weightLabel';
Color get threadColor {
  if (week <= 13) {
    final t = (week - 1) / 12.0;

    return Color.lerp(
      const Color(0xFF1C4D30), // deep primary green
      const Color(0xFF4F7D66), // balanced forest green
      t,
    )!;
  } else if (week <= 27) {
    final t = (week - 14) / 13.0;

    return Color.lerp(
      const Color(0xFF1C4D30), // deep primary green
      const Color(0xFF4F7D66), // balanced forest green
      t,
    )!;
  } else {
    final t = (week - 28) / 12.0;

    return Color.lerp(
        const Color(0xFF1C4D30), // deep primary green
      const Color(0xFF4F7D66), // balanced forest green
      t,
    )!;
  }
}

  Color get glowColor => threadColor.withOpacity(0.4);
}
class PregnancyDataRepository {
  static const List<PregnancyWeekData> weeks = [
    PregnancyWeekData(
      week: 1,
      babySize: 'Grain de pavot',
      lengthCm: 0.1,
      weightG: 0,
      description: 'Le voyage commence. Une seule cellule contient déjà le plan complet d’un être humain.',
      poeticLine: '"De un, tout commence."',
      milestone: 'Conception',
      trimester: 1,
      fetalHeartRateBpm: 0,
    ),
    PregnancyWeekData(
      week: 2,
      babySize: 'Grain de sésame',
      lengthCm: 0.2,
      weightG: 0,
      description: 'L’œuf fécondé se dirige vers l’utérus en se divisant progressivement.',
      poeticLine: '"Se diviser pour devenir."',
      milestone: 'Implantation',
      trimester: 1,
      fetalHeartRateBpm: 0,
    ),
    PregnancyWeekData(
      week: 3,
      babySize: 'Grain de riz',
      lengthCm: 0.15,
      weightG: 0,
      description: 'L’implantation est terminée. Le placenta commence à se former.',
      poeticLine: '"Elle a trouvé son foyer."',
      milestone: 'Implantation terminée',
      trimester: 1,
      fetalHeartRateBpm: 0,
    ),
    PregnancyWeekData(
      week: 4,
      babySize: 'Grain de pavot',
      lengthCm: 0.4,
      weightG: 0,
      description: 'Trois couches fondamentales se forment : cerveau, cœur et squelette.',
      poeticLine: '"Trois couches de devenir."',
      milestone: 'Début formation organes',
      trimester: 1,
      fetalHeartRateBpm: 0,
    ),
    PregnancyWeekData(
      week: 5,
      babySize: 'Graine de pomme',
      lengthCm: 0.5,
      weightG: 0,
      description: 'Le cœur commence à se former et peut déjà battre. Les membres apparaissent.',
      poeticLine: '"Le premier battement. Tout commence ici."',
      milestone: 'Début du cœur',
      trimester: 1,
      fetalHeartRateBpm: 80,
    ),
    PregnancyWeekData(
      week: 6,
      babySize: 'Myrtille',
      lengthCm: 0.6,
      weightG: 0,
      description: 'Le cœur bat pour la première fois. Les mains commencent à apparaître.',
      poeticLine: '"Un battement de cœur comme un souffle."',
      milestone: 'Battement détectable',
      trimester: 1,
      fetalHeartRateBpm: 110,
    ),
    PregnancyWeekData(
      week: 7,
      babySize: 'Framboise',
      lengthCm: 1.3,
      weightG: 1,
      description: 'Les doigts se forment. Le cerveau se développe rapidement.',
      poeticLine: '"Des mains qui tiendront un jour les tiennes."',
      milestone: 'Formation des doigts',
      trimester: 1,
      fetalHeartRateBpm: 130,
    ),
    PregnancyWeekData(
      week: 8,
      babySize: 'Haricot',
      lengthCm: 1.6,
      weightG: 1,
      description: 'Elle devient officiellement un fœtus. Tous les organes commencent à se former.',
      poeticLine: '"Un commencement sans retour."',
      milestone: 'Embryon → fœtus',
      trimester: 1,
      fetalHeartRateBpm: 150,
    ),
    PregnancyWeekData(
      week: 9,
      babySize: 'Cerise',
      lengthCm: 2.3,
      weightG: 2,
      description: 'Les muscles se forment. De petits mouvements apparaissent.',
      poeticLine: '"Bouger en secret."',
      milestone: 'Premiers mouvements',
      trimester: 1,
      fetalHeartRateBpm: 165,
    ),
    PregnancyWeekData(
      week: 10,
      babySize: 'Fraise',
      lengthCm: 3.1,
      weightG: 4,
      description: 'Tous les organes sont formés. Les doigts et orteils se séparent.',
      poeticLine: '"Dix doigts. Dix possibles chemins."',
      milestone: 'Organes formés',
      trimester: 1,
      fetalHeartRateBpm: 170,
    ),
    PregnancyWeekData(
      week: 11,
      babySize: 'Citron vert',
      lengthCm: 4.1,
      weightG: 7,
      description: 'Les os commencent à durcir. Les dents se forment.',
      poeticLine: '"Grandir en silence."',
      milestone: 'Début ossification',
      trimester: 1,
      fetalHeartRateBpm: 165,
    ),
    PregnancyWeekData(
      week: 12,
      babySize: 'Prune',
      lengthCm: 5.4,
      weightG: 14,
      description: 'Les réflexes apparaissent. Elle peut fermer ses poings.',
      poeticLine: '"Le premier chapitre se termine."',
      milestone: 'Réflexes',
      trimester: 1,
      fetalHeartRateBpm: 160,
    ),
    PregnancyWeekData(
      week: 13,
      babySize: 'Pêche',
      lengthCm: 7.4,
      weightG: 23,
      description: 'Les empreintes digitales apparaissent — uniques au monde.',
      poeticLine: '"Déjà unique."',
      milestone: 'Empreintes digitales',
      trimester: 1,
      fetalHeartRateBpm: 155,
    ),

    // ───────────── TRIMESTRE 2 ─────────────

    PregnancyWeekData(
      week: 14,
      babySize: 'Citron',
      lengthCm: 8.7,
      weightG: 43,
      description: 'Elle peut grimacer. Un fin duvet protège sa peau.',
      poeticLine: '"Le deuxième chapitre commence."',
      milestone: 'Début 2e trimestre',
      trimester: 2,
      fetalHeartRateBpm: 150,
    ),
    PregnancyWeekData(
      week: 15,
      babySize: 'Pomme',
      lengthCm: 10.1,
      weightG: 70,
      description: 'Elle perçoit la lumière à travers les paupières.',
      poeticLine: '"La lumière la touche déjà."',
      milestone: 'Sens lumière',
      trimester: 2,
      fetalHeartRateBpm: 148,
    ),
    PregnancyWeekData(
      week: 16,
      babySize: 'Avocat',
      lengthCm: 11.6,
      weightG: 100,
      description: 'Les jambes grandissent plus vite que les bras.',
      poeticLine: '"Elle écoute."',
      milestone: 'Ouïe',
      trimester: 2,
      fetalHeartRateBpm: 145,
    ),
    PregnancyWeekData(
      week: 17,
      babySize: 'Poire',
      lengthCm: 13.0,
      weightG: 140,
      description: 'Des graisses se forment pour réguler la température.',
      poeticLine: '"Se préparer au monde."',
      milestone: 'Graisse',
      trimester: 2,
      fetalHeartRateBpm: 143,
    ),
    PregnancyWeekData(
      week: 18,
      babySize: 'Patate douce',
      lengthCm: 14.2,
      weightG: 190,
      description: 'Elle bouge, avale et réagit. Tu peux la sentir.',
      poeticLine: '"Le mouvement devient langage."',
      milestone: 'Premiers mouvements ressentis',
      trimester: 2,
      fetalHeartRateBpm: 142,
    ),
    PregnancyWeekData(
      week: 19,
      babySize: 'Mangue',
      lengthCm: 15.3,
      weightG: 240,
      description: 'Une couche protectrice recouvre sa peau.',
      poeticLine: '"Protégée."',
      milestone: 'Vernix',
      trimester: 2,
      fetalHeartRateBpm: 140,
    ),
    PregnancyWeekData(
      week: 20,
      babySize: 'Banane',
      lengthCm: 25.0,
      weightG: 300,
      description: 'Mi-parcours. Elle bouge selon son propre rythme.',
      poeticLine: '"Elle danse dans le silence."',
      milestone: 'Mi-parcours',
      trimester: 2,
      fetalHeartRateBpm: 140,
    ),
    PregnancyWeekData(
      week: 21,
      babySize: 'Carotte',
      lengthCm: 26.7,
      weightG: 360,
      description: 'Elle goûte déjà ce que tu manges.',
      poeticLine: '"Elle partage ta vie."',
      milestone: 'Goût',
      trimester: 2,
      fetalHeartRateBpm: 138,
    ),
    PregnancyWeekData(
      week: 22,
      babySize: 'Papaye',
      lengthCm: 27.8,
      weightG: 430,
      description: 'Le visage devient plus défini.',
      poeticLine: '"Un visage en devenir."',
      milestone: 'Traits',
      trimester: 2,
      fetalHeartRateBpm: 138,
    ),
    PregnancyWeekData(
      week: 23,
      babySize: 'Pamplemousse',
      lengthCm: 28.9,
      weightG: 501,
      description: 'Elle réagit à ta voix.',
      poeticLine: '"Ta voix la guide."',
      milestone: 'Voix',
      trimester: 2,
      fetalHeartRateBpm: 137,
    ),
    PregnancyWeekData(
      week: 24,
      babySize: 'Épi de maïs',
      lengthCm: 30.0,
      weightG: 600,
      description: 'Elle peut entendre ton cœur.',
      poeticLine: '"Deux cœurs, un lien."',
      milestone: 'Viabilité',
      trimester: 2,
      fetalHeartRateBpm: 136,
    ),

    // ───────────── TRIMESTRE 3 ─────────────

    PregnancyWeekData(
      week: 25,
      babySize: 'Navet',
      lengthCm: 34.6,
      weightG: 660,
      description: 'Elle peut sucer son pouce.',
      poeticLine: '"Le réconfort intérieur."',
      milestone: 'Pouce',
      trimester: 3,
      fetalHeartRateBpm: 135,
    ),
    PregnancyWeekData(
      week: 26,
      babySize: 'Oignon vert',
      lengthCm: 35.6,
      weightG: 760,
      description: 'Les yeux s’ouvrent.',
      poeticLine: '"Voir pour la première fois."',
      milestone: 'Vision',
      trimester: 3,
      fetalHeartRateBpm: 134,
    ),
    PregnancyWeekData(
      week: 27,
      babySize: 'Chou-fleur',
      lengthCm: 36.6,
      weightG: 875,
      description: 'Elle rêve.',
      poeticLine: '"Elle rêve déjà."',
      milestone: 'REM',
      trimester: 3,
      fetalHeartRateBpm: 133,
    ),
    PregnancyWeekData(
      week: 28,
      babySize: 'Aubergine',
      lengthCm: 37.6,
      weightG: 1005,
      description: 'Début du dernier chapitre.',
      poeticLine: '"Presque là."',
      milestone: '3e trimestre',
      trimester: 3,
      fetalHeartRateBpm: 132,
    ),
    PregnancyWeekData(
      week: 29,
      babySize: 'Courge',
      lengthCm: 38.6,
      weightG: 1153,
      description: 'Prise de poids rapide.',
      poeticLine: '"Grandir vers la lumière."',
      milestone: 'Croissance',
      trimester: 3,
      fetalHeartRateBpm: 131,
    ),
    PregnancyWeekData(
      week: 30,
      babySize: 'Chou',
      lengthCm: 39.9,
      weightG: 1319,
      description: 'Le cerveau se complexifie.',
      poeticLine: '"Une pensée en formation."',
      milestone: 'Cerveau',
      trimester: 3,
      fetalHeartRateBpm: 130,
    ),
    PregnancyWeekData(
      week: 31,
      babySize: 'Noix de coco',
      lengthCm: 41.1,
      weightG: 1502,
      description: 'Elle réagit à la lumière.',
      poeticLine: '"Curiosité."',
      milestone: 'Réflexes',
      trimester: 3,
      fetalHeartRateBpm: 130,
    ),
    PregnancyWeekData(
      week: 32,
      babySize: 'Courge musquée',
      lengthCm: 42.4,
      weightG: 1702,
      description: 'Elle s’entraîne à respirer.',
      poeticLine: '"Préparation."',
      milestone: 'Respiration',
      trimester: 3,
      fetalHeartRateBpm: 130,
    ),
    PregnancyWeekData(
      week: 33,
      babySize: 'Ananas',
      lengthCm: 43.7,
      weightG: 1918,
      description: 'Les os durcissent.',
      poeticLine: '"Structure."',
      milestone: 'Os',
      trimester: 3,
      fetalHeartRateBpm: 129,
    ),
    PregnancyWeekData(
      week: 34,
      babySize: 'Melon',
      lengthCm: 45.0,
      weightG: 2146,
      description: 'Elle reconnaît ta voix.',
      poeticLine: '"Elle te connaît."',
      milestone: 'Reconnaissance',
      trimester: 3,
      fetalHeartRateBpm: 129,
    ),
    PregnancyWeekData(
      week: 35,
      babySize: 'Melon miel',
      lengthCm: 46.2,
      weightG: 2383,
      description: 'Elle manque d’espace.',
      poeticLine: '"Presque prête."',
      milestone: 'Finalisation',
      trimester: 3,
      fetalHeartRateBpm: 128,
    ),
    PregnancyWeekData(
      week: 36,
      babySize: 'Papaye',
      lengthCm: 47.4,
      weightG: 2622,
      description: 'Presque à terme.',
      poeticLine: '"Tout est prêt."',
      milestone: 'Terme proche',
      trimester: 3,
      fetalHeartRateBpm: 128,
    ),
    PregnancyWeekData(
      week: 37,
      babySize: 'Melon d’hiver',
      lengthCm: 48.6,
      weightG: 2859,
      description: 'Début du terme.',
      poeticLine: '"À la frontière du monde."',
      milestone: 'Terme précoce',
      trimester: 3,
      fetalHeartRateBpm: 127,
    ),
    PregnancyWeekData(
      week: 38,
      babySize: 'Poireau',
      lengthCm: 49.8,
      weightG: 3083,
      description: 'Les hormones du travail commencent.',
      poeticLine: '"Prête."',
      milestone: 'Travail hormonal',
      trimester: 3,
      fetalHeartRateBpm: 127,
    ),
    PregnancyWeekData(
      week: 39,
      babySize: 'Pastèque',
      lengthCm: 50.7,
      weightG: 3288,
      description: 'À terme complet.',
      poeticLine: '"Le temps est venu."',
      milestone: 'Terme',
      trimester: 3,
      fetalHeartRateBpm: 126,
    ),
    PregnancyWeekData(
      week: 40,
      babySize: 'Petit potiron',
      lengthCm: 51.2,
      weightG: 3462,
      description: 'Le cycle est complet. Elle est prête.',
      poeticLine: '"Le fil est achevé."',
      milestone: 'Naissance',
      trimester: 3,
      fetalHeartRateBpm: 126,
    ),
  ];

  static PregnancyWeekData forWeek(int week) {
    final clamped = week.clamp(1, 40);
    return weeks[clamped - 1];
  }
}