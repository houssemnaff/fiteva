// ─────────────────────────────────────────────
// pregnancy_insight_repository.dart
// ─────────────────────────────────────────────

import 'daily_insight_model.dart';

class PregnancyInsightRepository {
  PregnancyInsightRepository._();

  static DailyInsight forWeek(int week) {
    final clamped = week.clamp(1, 40);
    return _insights.firstWhere(
      (i) => i.week == clamped,
      orElse: () => _insights.last,
    );
  }

    static const List<DailyInsight> _insights = [
  // ── SEMAINE 1 ──────────────────────────────────────────────────────────
  DailyInsight(
    week: 1,
    title: 'Le voyage commence',
    babyInsight:
        'À la semaine 1, la grossesse est comptée à partir du premier jour '
        'de vos dernières règles. La conception n’a pas encore eu lieu — '
        'votre corps se prépare silencieusement, en libérant des hormones '
        'qui orchestreront bientôt une transformation extraordinaire.',
    momTip:
        'Commencez à prendre une vitamine prénatale avec au moins 400 µg '
        'd’acide folique chaque jour. Pris avant la conception, il réduit '
        'fortement le risque de malformations du tube neural.',
    poeticLine:
        'Avant le premier mot, il y a un souffle — et dans ce souffle, tout commence.',
  ),

  // ── SEMAINE 2 ──────────────────────────────────────────────────────────
  DailyInsight(
    week: 2,
    title: 'L’étincelle de l’ovulation',
    babyInsight:
        'Votre corps approche de l’ovulation. L’ovule qui pourra devenir '
        'votre bébé mûrit dans un follicule de la taille d’une myrtille. '
        'Dans quelques jours, il sera libéré pour commencer son voyage.',
    momTip:
        'Si ce n’est pas déjà fait, réduisez la caféine et éliminez totalement '
        'l’alcool. Votre corps va devenir un véritable sanctuaire.',
    poeticLine:
        'Chaque océan commence par une seule goutte parfaite.',
  ),

  // ── SEMAINE 3 ──────────────────────────────────────────────────────────
  DailyInsight(
    week: 3,
    title: 'Une nouvelle vie s’allume',
    babyInsight:
        'La fécondation a eu lieu ! Un spermatozoïde a fusionné avec votre '
        'ovule, créant un zygote avec un ADN totalement unique. En 24 heures, '
        'le plan d’un être humain est déjà écrit.',
    momTip:
        'Évitez les jacuzzis et saunas pendant ce trimestre. Une température '
        'corporelle élevée peut affecter le développement du fœtus.',
    poeticLine:
        'De deux, un. De rien, tout.',
  ),

  // ── SEMAINE 4 ──────────────────────────────────────────────────────────
  DailyInsight(
    week: 4,
    title: 'Implantation — Tu es chez toi',
    babyInsight:
        'Votre embryon, maintenant un blastocyste d’environ 100 cellules, '
        's’implante dans la paroi de l’utérus. C’est le moment où votre bébé '
        'devient officiellement “chez lui”.',
    momTip:
        'Un test de grossesse peut maintenant détecter l’hormone hCG. '
        'Faites-le avec les premières urines du matin pour plus de précision.',
    poeticLine:
        'Elle a trouvé l’endroit le plus doux et y est restée.',
  ),

  // ── SEMAINE 5 ──────────────────────────────────────────────────────────
  DailyInsight(
    week: 5,
    title: 'Le cœur se prépare',
    babyInsight:
        'Votre embryon a la taille d’une graine de pomme. Trois couches '
        'se forment déjà : peau et cerveau, cœur et muscles, poumons et intestins. '
        'Un petit tube cardiaque commence à battre.',
    momTip:
        'Les nausées peuvent commencer. Prenez de petits repas fréquents. '
        'Le gingembre peut aider à soulager naturellement.',
    poeticLine:
        'Entre l’espoir et la certitude, un cœur apprend à battre.',
  ),

  // ── SEMAINE 6 ──────────────────────────────────────────────────────────
  DailyInsight(
    week: 6,
    title: 'Un cœur qui frémit',
    babyInsight:
        'Le cœur bat déjà à environ 110 battements par minute. '
        'Les bras et jambes commencent à apparaître. Le tube neural '
        'se ferme pour former le cerveau et la moelle épinière.',
    momTip:
        'La fatigue est intense — c’est normal. Reposez-vous sans culpabilité.',
    poeticLine:
        'Un univers minuscule bat déjà son propre rythme.',
  ),

  // ── SEMAINE 7 ──────────────────────────────────────────────────────────
  DailyInsight(
    week: 7,
    title: 'Les mains se forment',
    babyInsight:
        'Les mains apparaissent comme de petites palettes. Le cerveau grandit '
        'très vite. Le bébé mesure environ 10 mm.',
    momTip:
        'Prenez rendez-vous pour votre premier suivi prénatal si ce n’est pas fait.',
    poeticLine:
        'Le premier dessin de mains qui un jour toucheront le monde.',
  ),

  // ── SEMAINE 8 ──────────────────────────────────────────────────────────
  DailyInsight(
    week: 8,
    title: 'Les doigts apparaissent',
    babyInsight:
        'Les doigts et orteils commencent à se former. Les yeux se développent. '
        'Le bébé a la taille d’une framboise.',
    momTip:
        'La vitamine B6 peut aider contre les nausées (avec avis médical).',
    poeticLine:
        'Ce qui était mer devient doigts pour toucher la rive.',
  ),

  // ── SEMAINE 9 ──────────────────────────────────────────────────────────
  DailyInsight(
    week: 9,
    title: 'Tous les organes sont là',
    babyInsight:
        'Tous les organes essentiels sont en place. Le bébé commence à bouger. '
        'Il a la taille d’un raisin.',
    momTip:
        'Votre utérus grandit — ce n’est pas du gras, c’est de la vie.',
    poeticLine:
        'Tous les instruments sont prêts. La musique commence bientôt.',
  ),

  // ── SEMAINE 10 ─────────────────────────────────────────────────────────
  DailyInsight(
    week: 10,
    title: 'Premiers mouvements',
    babyInsight:
        'Le bébé bouge déjà doucement. Les ongles et follicules pileux se forment.',
    momTip:
        'Le risque de fausse couche diminue fortement après cette semaine.',
    poeticLine:
        'Elle danse déjà dans un monde trop petit pour être vu.',
  ),

  // ── SEMAINE 11 ─────────────────────────────────────────────────────────
  DailyInsight(
    week: 11,
    title: 'Des petits hoquets',
    babyInsight:
        'Le bébé pratique des mouvements respiratoires. Les dents commencent '
        'à se former sous les gencives.',
    momTip:
        'Les changements de peau sont normaux à ce stade.',
    poeticLine:
        'Même dans le silence, elle trouve son rythme.',
  ),

  // ── SEMAINE 12 ─────────────────────────────────────────────────────────
  DailyInsight(
    week: 12,
    title: 'Fin du premier trimestre',
    babyInsight:
        'Le bébé mesure environ 6 cm. Tous les systèmes fonctionnent.',
    momTip:
        'L’énergie revient souvent à cette période. Profitez-en.',
    poeticLine:
        'Trois mois de devenir. Vous avez déjà parcouru un long chemin.',
  ),

  // ── SEMAINE 13 ─────────────────────────────────────────────────────────
  DailyInsight(
    week: 13,
    title: 'Début du deuxième trimestre',
    babyInsight:
        'Le bébé a la taille d’une pêche. Les empreintes digitales se forment.',
    momTip:
        'C’est souvent la période la plus confortable.',
    poeticLine:
        'Une petite pêche qui laisse déjà sa trace dans le monde.',
  ),

  // ── SEMAINE 14 ─────────────────────────────────────────────────────────
  DailyInsight(
    week: 14,
    title: 'Les premières expressions',
    babyInsight:
        'Le bébé peut maintenant faire des grimaces, sucer et plisser le visage. '
        'Le foie et la rate fonctionnent déjà. Il mesure environ 9 cm.',
    momTip:
        'Les douleurs ligamentaires sont normales avec la croissance de l’utérus.',
    poeticLine:
        'Elle apprend la joie avant même de connaître le mot.',
  ),

  // ── SEMAINE 15 ─────────────────────────────────────────────────────────
  DailyInsight(
    week: 15,
    title: 'Des os plus solides',
    babyInsight:
        'Le squelette du bébé se renforce et devient visible à l’échographie.',
    momTip:
        'Le calcium est essentiel pendant cette période.',
    poeticLine:
        'Ta voix est la première musique qu’elle entend.',
  ),

  // ── SEMAINE 16 ─────────────────────────────────────────────────────────
  DailyInsight(
    week: 16,
    title: 'Premiers mouvements ressentis',
    babyInsight:
        'Le bébé commence à bouger de façon plus coordonnée. Il mesure environ 11 cm.',
    momTip:
        'Tu peux commencer à sentir les premières “bulles” dans le ventre.',
    poeticLine:
        'Le premier salut venu de l’intérieur du monde.',
  ),

  // ── SEMAINE 17 ─────────────────────────────────────────────────────────
  DailyInsight(
    week: 17,
    title: 'Début des rêves',
    babyInsight:
        'Le bébé développe des cycles de sommeil et commence à rêver.',
    momTip:
        'Augmente ton hydratation pour éviter les étourdissements.',
    poeticLine:
        'Dans ton silence, elle apprend à rêver.',
  ),

  // ── SEMAINE 18 ─────────────────────────────────────────────────────────
  DailyInsight(
    week: 18,
    title: 'Échographie morphologique',
    babyInsight:
        'Les traits du visage sont visibles et le système nerveux évolue rapidement.',
    momTip:
        'Prépare tes questions pour l’échographie.',
    poeticLine:
        'La première photo prise dans le son et la lumière.',
  ),

  // ── SEMAINE 19 ─────────────────────────────────────────────────────────
  DailyInsight(
    week: 19,
    title: 'Les sens s’éveillent',
    babyInsight:
        'Le bébé commence à entendre et reconnaître les sons.',
    momTip:
        'Parle à ton bébé, il reconnaît déjà ta voix.',
    poeticLine:
        'Elle découvre le monde à travers toi.',
  ),

  // ── SEMAINE 20 ─────────────────────────────────────────────────────────
  DailyInsight(
    week: 20,
    title: 'La moitié du chemin',
    babyInsight:
        'Le bébé mesure environ 25 cm et pèse 300 g.',
    momTip:
        'Prends un moment pour célébrer ce cap important.',
    poeticLine:
        'Déjà à mi-chemin de la rencontre.',
  ),

  // ── SEMAINE 21 ─────────────────────────────────────────────────────────
  DailyInsight(
    week: 21,
    title: 'Les coups deviennent visibles',
    babyInsight:
        'Les mouvements sont assez forts pour être ressentis par le papa.',
    momTip:
        'Les crampes nocturnes sont fréquentes.',
    poeticLine:
        'Elle frappe doucement à la porte du monde.',
  ),

  // ── SEMAINE 22 ─────────────────────────────────────────────────────────
  DailyInsight(
    week: 22,
    title: 'Un visage complet',
    babyInsight:
        'Le visage est entièrement formé, les yeux sont sensibles à la lumière.',
    momTip:
        'Surveille les gonflements des pieds.',
    poeticLine:
        'Un visage qui n’a jamais vu le soleil mais déjà lumineux.',
  ),

  // ── SEMAINE 23 ─────────────────────────────────────────────────────────
  DailyInsight(
    week: 23,
    title: 'Il entend le monde',
    babyInsight:
        'Le bébé entend les sons extérieurs comme les voix et la musique.',
    momTip:
        'Le reflux et brûlures d’estomac sont fréquents.',
    poeticLine:
        'Chaque chanson arrive jusqu’à elle.',
  ),

  // ── SEMAINE 24 ─────────────────────────────────────────────────────────
  DailyInsight(
    week: 24,
    title: 'Viabilité',
    babyInsight:
        'Le bébé atteint un stade où il peut survivre avec assistance médicale.',
    momTip:
        'Test de diabète gestationnel entre 24 et 28 semaines.',
    poeticLine:
        'Entre la possibilité et la promesse.',
  ),

  // ── SEMAINE 25 ─────────────────────────────────────────────────────────
  DailyInsight(
    week: 25,
    title: 'Développement des sens',
    babyInsight:
        'Le bébé explore avec ses mains et développe ses sens.',
    momTip:
        'Les douleurs pelviennes sont normales.',
    poeticLine:
        'Elle découvre son propre visage.',
  ),

  // ── SEMAINE 26 ─────────────────────────────────────────────────────────
  DailyInsight(
    week: 26,
    title: 'Les yeux s’ouvrent',
    babyInsight:
        'Le bébé ouvre les yeux et réagit à la lumière.',
    momTip:
        'Les contractions de Braxton Hicks peuvent commencer.',
    poeticLine:
        'Elle ouvre les yeux sur ton monde chaud.',
  ),

  // ── SEMAINE 27 ─────────────────────────────────────────────────────────
  DailyInsight(
    week: 27,
    title: 'Fin du 2e trimestre',
    babyInsight:
        'Le bébé dort beaucoup et rêve déjà.',
    momTip:
        'Un coussin de grossesse peut améliorer ton sommeil.',
    poeticLine:
        'Elle rêve de la voix qu’elle aime déjà.',
  ),

  // ── SEMAINE 28 ─────────────────────────────────────────────────────────
  DailyInsight(
    week: 28,
    title: 'Début du 3e trimestre',
    babyInsight:
        'Le cerveau se développe rapidement.',
    momTip:
        'Commence à suivre les mouvements du bébé.',
    poeticLine:
        'Le dernier chapitre commence.',
  ),

  // ── SEMAINE 29 ─────────────────────────────────────────────────────────
  DailyInsight(
    week: 29,
    title: 'Renforcement du corps',
    babyInsight:
        'Les muscles et les os se renforcent rapidement.',
    momTip:
        'Essoufflement normal à ce stade.',
    poeticLine:
        'Elle se construit elle-même.',
  ),

  // ── SEMAINE 30 ─────────────────────────────────────────────────────────
  DailyInsight(
    week: 30,
    title: 'Plus que 10 semaines',
    babyInsight:
        'Le bébé prend rapidement du poids.',
    momTip:
        'Prépare ton plan de naissance.',
    poeticLine:
        'Chaque semaine est une rencontre plus proche.',
  ),

  // ── SEMAINE 31 ─────────────────────────────────────────────────────────
  DailyInsight(
    week: 31,
    title: 'Tous les sens actifs',
    babyInsight:
        'Le bébé utilise ses 5 sens en développement.',
    momTip:
        'Les envies fréquentes d’uriner sont normales.',
    poeticLine:
        'Elle goûte ton monde.',
  ),

  // ── SEMAINE 32 ─────────────────────────────────────────────────────────
  DailyInsight(
    week: 32,
    title: 'Entraînement à la respiration',
    babyInsight:
        'Le bébé s’entraîne à respirer.',
    momTip:
        'Prépare ta valise de maternité.',
    poeticLine:
        'Elle s’entraîne à vivre.',
  ),

  // ── SEMAINE 33 ─────────────────────────────────────────────────────────
  DailyInsight(
    week: 33,
    title: 'Position de naissance',
    babyInsight:
        'Le bébé commence à se placer tête en bas.',
    momTip:
        'Le colostrum peut commencer à apparaître.',
    poeticLine:
        'Elle se prépare à sortir vers la lumière.',
  ),

  // ── SEMAINE 34 ─────────────────────────────────────────────────────────
  DailyInsight(
    week: 34,
    title: 'Presque prêt',
    babyInsight:
        'Les poumons sont presque matures.',
    momTip:
        'Discute de la gestion de la douleur.',
    poeticLine:
        'Prête avant même le monde.',
  ),

  // ── SEMAINE 35 ─────────────────────────────────────────────────────────
  DailyInsight(
    week: 35,
    title: 'Derniers ajustements',
    babyInsight:
        'Le bébé continue de prendre du poids rapidement.',
    momTip:
        'Test du streptocoque B cette semaine.',
    poeticLine:
        'Elle remplit tout l’espace disponible.',
  ),

  // ── SEMAINE 36 ─────────────────────────────────────────────────────────
  DailyInsight(
    week: 36,
    title: 'Presque là',
    babyInsight:
        'Le bébé est souvent tête en bas et prêt.',
    momTip:
        'Douleurs de pression pelvienne normales.',
    poeticLine:
        'Dans un mois, tu verras son visage.',
  ),

  // ── SEMAINE 37 ─────────────────────────────────────────────────────────
  DailyInsight(
    week: 37,
    title: 'Début du terme',
    babyInsight:
        'Le bébé peut naître à tout moment.',
    momTip:
        'Apprends les signes du travail.',
    poeticLine:
        'Elle choisira son moment.',
  ),

  // ── SEMAINE 38 ─────────────────────────────────────────────────────────
  DailyInsight(
    week: 38,
    title: 'Prête à naître',
    babyInsight:
        'Tous les organes sont matures.',
    momTip:
        'L’instinct de “nidification” est normal.',
    poeticLine:
        'Elle n’a plus qu’à arriver.',
  ),

  // ── SEMAINE 39 ─────────────────────────────────────────────────────────
  DailyInsight(
    week: 39,
    title: 'L’attente',
    babyInsight:
        'Le cerveau continue de se développer.',
    momTip:
        'Sois patiente avec ton corps.',
    poeticLine:
        'Les plus belles choses font attendre.',
  ),

  // ── SEMAINE 40 ─────────────────────────────────────────────────────────
  DailyInsight(
    week: 40,
    title: 'La porte s’ouvre',
    babyInsight:
        'Ton bébé est complètement formé et prêt à naître.',
    momTip:
        'Seulement 5% des bébés naissent exactement à 40 semaines.',
    poeticLine:
        'Après 40 semaines de devenir, elle ouvre les yeux.',
  ),
];
}