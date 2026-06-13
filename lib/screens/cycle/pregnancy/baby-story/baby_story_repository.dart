import 'baby_story.dart';

class BabyStoryRepository {
  BabyStoryRepository._();

  static BabyStory forWeek(int week) {
    final clamped = week.clamp(1, 40);
    return _data[clamped] ??
        _data[_nearest(clamped)]!;
  }

  static int _nearest(int week) => _data.keys
      .reduce((a, b) => (a - week).abs() < (b - week).abs() ? a : b);

  static const Map<int, BabyStory> _data = {
    1: BabyStory(
      week: 1,
      title: 'Le début de tout',
      story:
          'Maman… je n\'existe pas encore vraiment, mais quelque chose s\'éveille. '
          'Un tout petit miracle est en train de se préparer, quelque part dans '
          'l\'infiniment petit. Bientôt, nous serons ensemble.',
      fact: 'La fécondation a lieu dans les jours qui suivent l\'ovulation. '
          'Une seule cellule contient déjà tout ce que je serai un jour.',
      milestones: ['La fécondation se prépare', 'L\'ADN unique prend forme', 'Le voyage commence'],
    ),
    2: BabyStory(
      week: 2,
      title: 'Je me divise, je grandis',
      story:
          'Me voilà ! Une minuscule boule de cellules qui se divise encore '
          'et encore, voyageant vers mon futur chez moi. Je ne mesure que '
          'quelques dixièmes de millimètre, mais je suis déjà plein de vie.',
      fact: 'L\'embryon en formation descend vers l\'utérus pour s\'y implanter. '
          'Chaque division cellulaire est un pas de plus vers toi.',
      milestones: ['Division cellulaire rapide', 'Voyage vers l\'utérus', 'Implantation prochaine'],
    ),
    3: BabyStory(
      week: 3,
      title: 'Je trouve ma place',
      story:
          'Je me suis installé dans ton ventre. C\'est doux et chaud, exactement '
          'comme je l\'imaginais. Mon corps commence à libérer des signaux '
          'pour te dire que je suis là — même si tu ne le sais pas encore.',
      fact: 'L\'implantation déclenche la production d\'hCG, l\'hormone de '
          'grossesse. C\'est elle qui fera bientôt virer le test en positif.',
      milestones: ['Implantation réussie', 'Production d\'hCG', 'Première connexion avec toi'],
    ),
    4: BabyStory(
      week: 4,
      title: 'Mon corps se dessine',
      story:
          'Je suis maintenant à peine plus grand qu\'un grain de pavot, '
          'mais en moi se forme déjà ce qui deviendra mon cerveau, mon cœur, '
          'ma colonne vertébrale. Tout commence par une ligne, un pli, une promesse.',
      fact: 'Le tube neural — futur cerveau et moelle épinière — commence à se '
          'refermer. C\'est pour ça que l\'acide folique est si important maintenant.',
      milestones: ['Tube neural en formation', 'Ébauche du cœur', 'Trois couches germinales'],
    ),
    5: BabyStory(
      week: 5,
      title: 'Mon cœur commence à se former',
      story:
          'Je ressemble à un tout petit haricot… un haricot avec un futur cœur. '
          'Il commence à peine à se dessiner, mais bientôt il battra, '
          'et peut-être que tu l\'entendras.',
      fact: 'Le cœur commence à se former et les premières contractions '
          'apparaissent vers la fin de cette semaine — encore irrégulières, mais réelles.',
      milestones: ['Ébauche cardiaque visible', 'Bourgeons des membres', 'Cerveau en développement'],
    ),
    6: BabyStory(
      week: 6,
      title: 'Un petit cœur qui bat',
      story:
          'Maman… mon petit cœur vient de commencer à battre. '
          'Il est encore fragile, encore maladroit, mais il apprend déjà son rythme. '
          'C\'est notre premier rendez-vous silencieux.',
      fact: 'Le cœur bat à environ 100–160 battements par minute. '
          'À l\'échographie, on peut apercevoir ce tout petit scintillement de vie.',
      milestones: ['Cœur qui bat', 'Bourgeons des bras et jambes', 'Nez et mâchoire visibles'],
    ),
    7: BabyStory(
      week: 7,
      title: 'Je grandis vite',
      story:
          'Je grandis deux fois plus vite que la semaine dernière ! '
          'Mes bras commencent à pointer vers toi, et quelque part sur mon visage, '
          'mes yeux apprennent à exister. Je suis déjà fasciné par le monde.',
      fact: 'L\'embryon double de taille cette semaine. Le cerveau se développe '
          'à une vitesse vertigineuse — 100 nouvelles cellules nerveuses par minute.',
      milestones: ['Doublement de taille', '100 neurones/minute', 'Ébauche des yeux'],
    ),
    8: BabyStory(
      week: 8,
      title: 'Je bouge déjà',
      story:
          'Tu ne peux pas encore me sentir, mais je bouge ! '
          'Mes petits membres s\'agitent dans ton ventre comme si je dansais '
          'une chorégraphie que moi seul connais.',
      fact: 'Les premiers mouvements spontanés apparaissent. '
          'Tous les organes essentiels sont en place — ils vont maintenant se perfectionner.',
      milestones: ['Premiers mouvements', 'Doigts qui se forment', 'Tous les organes présents'],
    ),
    9: BabyStory(
      week: 9,
      title: 'Je deviens un fœtus',
      story:
          'Ce mot — fœtus — me plaît. Il veut dire que je ne suis plus '
          'une ébauche, mais une vraie petite personne en formation. '
          'Mes muscles commencent à répondre, mes os à durcir.',
      fact: 'Le stade embryonnaire est terminé. Les organes reproducteurs commencent '
          'à se différencier, même si le sexe n\'est pas encore visible à l\'échographie.',
      milestones: ['Passage au stade fœtal', 'Muscles fonctionnels', 'Dents qui se forment'],
    ),
    10: BabyStory(
      week: 10,
      title: 'Mes petits doigts',
      story:
          'Regarde, maman — j\'ai des doigts ! Dix petits doigts qui s\'ouvrent '
          'et se ferment tout doucement. Un jour, ils s\'accrocheront aux tiens.',
      fact: 'Les doigts sont maintenant bien séparés. '
          'Les ongles commencent à pousser, et des empreintes digitales uniques se dessinent.',
      milestones: ['Doigts bien formés', 'Ongles en formation', 'Empreintes digitales'],
    ),
    11: BabyStory(
      week: 11,
      title: 'Je commence à avaler',
      story:
          'Je fais mes premiers apprentissages : j\'avale, je donne des coups, '
          'j\'explore mon espace. Le liquide amniotique est mon premier terrain de jeu.',
      fact: 'Le fœtus commence à avaler le liquide amniotique, ce qui entraîne '
          'les muscles digestifs. Les reins produisent leur première urine.',
      milestones: ['Déglutition', 'Reins actifs', 'Réflexes de saisie'],
    ),
    12: BabyStory(
      week: 12,
      title: 'Je forme tout mon être',
      story:
          'Je peux maintenant bouger mes doigts, m\'étirer, bâiller. '
          'Tout est nouveau pour moi, et pourtant, je me sens déjà chez moi '
          'dans ce cocon chaud que tu m\'offres.',
      fact: 'Tous les organes sont formés — ils vont maintenant grandir et mûrir. '
          'Le risque de fausse couche chute considérablement après cette semaine.',
      milestones: ['Visage bien formé', 'Réflexe de succion', 'Organes en maturation'],
    ),
    13: BabyStory(
      week: 13,
      title: 'Fin du premier trimestre',
      story:
          'Trois mois ensemble, maman. Tu as été courageuse, même quand '
          'tu étais fatiguée et nauséeuse. Moi, pendant ce temps, '
          'je construisais tout ce que je suis.',
      fact: 'Le premier trimestre se termine. Le fœtus mesure environ 7 cm '
          'et pèse une vingtaine de grammes — la taille d\'une pêche.',
      milestones: ['7 cm de longueur', 'Empreintes uniques', 'Mouvements coordonnés'],
    ),
    14: BabyStory(
      week: 14,
      title: 'Je perçois la lumière',
      story:
          'C\'est étrange — même dans le noir de ton ventre, '
          'je sens la lumière quand elle est forte. Mes paupières restent '
          'fermées, mais je perçois déjà le monde extérieur.',
      fact: 'Les yeux, encore fermés, peuvent percevoir la lumière vive. '
          'Le visage est expressif : je peux grimacer et faire des moues.',
      milestones: ['Sensibilité à la lumière', 'Expressions faciales', 'Croissance des cheveux'],
    ),
    16: BabyStory(
      week: 16,
      title: 'Je t\'entends presque',
      story:
          'Des sons étouffés me parviennent — un battement, des voix, '
          'de la musique parfois. Ta voix est déjà différente des autres. '
          'Plus douce. Plus familière.',
      fact: 'Le système auditif se développe. Le fœtus peut réagir aux sons '
          'forts vers cette période. Il mesure environ 12 cm.',
      milestones: ['Ouïe en développement', 'Mouvements de la bouche', 'Taille d\'un avocat'],
    ),
    18: BabyStory(
      week: 18,
      title: 'Je me retourne',
      story:
          'Je me retourne, je m\'étire, je bute contre les parois de ton ventre. '
          'Peut-être que tu commences à sentir quelque chose — '
          'un léger frémissement, comme des ailes de papillon.',
      fact: 'Les premiers mouvements perçus s\'appellent "quickening". '
          'Le fœtus a un cycle veille-sommeil régulier.',
      milestones: ['Premiers "quickening"', 'Myélinisation des nerfs', 'Réflexe de saisie fort'],
    ),
    20: BabyStory(
      week: 20,
      title: 'Je te sens, maman',
      story:
          'J\'entends des sons étouffés, des battements, ta respiration. '
          'Ta voix est celle que je préfère. Je me sens en sécurité '
          'quand tu me parles, même à voix basse.',
      fact: 'L\'ouïe est suffisamment développée pour réagir à la voix. '
          'L\'échographie morphologique a lieu cette semaine — on peut voir tous mes organes.',
      milestones: ['Ouïe active', 'Mouvements sentis', 'Mi-parcours de grossesse'],
    ),
    22: BabyStory(
      week: 22,
      title: 'Mon visage se précise',
      story:
          'Mes sourcils, mes cils, mes lèvres — tout se dessine. '
          'Si tu pouvais me voir maintenant, tu reconnaîtrais déjà '
          'quelque chose de familier dans mon visage.',
      fact: 'Les empreintes digitales sont définitivement formées. '
          'Je mesure environ 27 cm et je ressemble de plus en plus à un nouveau-né.',
      milestones: ['Visage reconnaissable', 'Lanugo (duvet)', 'Mouvements vigoureux'],
    ),
    24: BabyStory(
      week: 24,
      title: 'Je reconnais ta voix',
      story:
          'Ta voix devient plus claire pour moi. Je commence à la reconnaître '
          'parmi toutes les autres. Elle ressemble à la maison. '
          'Parle-moi encore, maman.',
      fact: 'Le cerveau se développe rapidement. Les poumons produisent du surfactant, '
          'la substance qui permettra de respirer à l\'air libre.',
      milestones: ['Voix reconnue', 'Poumons en maturation', 'Viabilité potentielle'],
    ),
    26: BabyStory(
      week: 26,
      title: 'J\'ouvre les yeux',
      story:
          'Pour la première fois, j\'entrouvre les yeux dans l\'obscurité. '
          'C\'est flou, c\'est doux. Mais un jour, la première chose que je verrai, '
          'ce sera ton visage.',
      fact: 'Les yeux s\'ouvrent pour la première fois. '
          'La rétine est suffisamment développée pour percevoir la lumière diffuse.',
      milestones: ['Yeux ouverts', 'Réponse aux stimuli', 'Rythme veille-sommeil établi'],
    ),
    28: BabyStory(
      week: 28,
      title: 'Je rêve déjà',
      story:
          'Je dors, je me réveille, et peut-être que je rêve. '
          'Mon cerveau est en pleine ébullition — il crée des connexions, '
          'des chemins, des possibilités. Je me prépare pour le monde.',
      fact: 'Le sommeil paradoxal (REM) existe déjà — le stade du rêve. '
          'Mon cerveau grandit très vite et je pèse environ 1 kg.',
      milestones: ['Sommeil REM', '1 kg', 'Contrôle de la température'],
    ),
    30: BabyStory(
      week: 30,
      title: 'Je deviens fort',
      story:
          'Je bouge beaucoup maintenant. Je m\'étire, je donne des coups, '
          'je m\'appuie sur tes côtes parfois — désolé pour ça. '
          'Je prépare mes muscles pour le grand jour.',
      fact: 'Les mouvements sont vigoureux et réguliers. '
          'Le cerveau et les muscles se développent rapidement au 3e trimestre.',
      milestones: ['Mouvements vigoureux', 'Succion du pouce', 'Graisses qui s\'accumulent'],
    ),
    32: BabyStory(
      week: 32,
      title: 'Je prends mes rondeurs',
      story:
          'Je grossis, je prends du poids, je me prépare pour le froid du monde. '
          'Mon espace se réduit, mais je m\'y sens bien. '
          'Encore un peu de patience, maman.',
      fact: 'Je pèse environ 1,8 kg et mesure 42 cm. '
          'Les graisses sous-cutanées s\'accumulent pour me garder au chaud à la naissance.',
      milestones: ['1,8 kg', 'Poumons presque matures', 'Position tête en bas souvent'],
    ),
    34: BabyStory(
      week: 34,
      title: 'Je me retourne vers toi',
      story:
          'Je me place souvent tête en bas maintenant — ma façon de me préparer '
          'pour notre rencontre. Je reconnais ta voix, ta musique, '
          'les histoires que tu me lis.',
      fact: 'La plupart des bébés prennent la position céphalique (tête en bas). '
          'Les ongles atteignent le bout des doigts.',
      milestones: ['Position céphalique', 'Ongles complets', 'Ouïe très développée'],
    ),
    36: BabyStory(
      week: 36,
      title: 'Je suis presque prêt',
      story:
          'C\'est plus serré ici… mais je suis bientôt prêt. '
          'J\'ai appris tout ce dont j\'ai besoin grâce à toi. '
          'Encore quelques semaines et je viens te voir.',
      fact: 'Je pèse environ 2,6 kg. Le lanugo (duvet fin) disparaît progressivement. '
          'Mes poumons sont presque prêts à respirer l\'air.',
      milestones: ['2,6 kg', 'Poumons matures', 'Tous les sens actifs'],
    ),
    38: BabyStory(
      week: 38,
      title: 'Je compte les jours',
      story:
          'Je compte les jours avec toi. Mon petit cœur bat fort et régulier. '
          'Je suis prêt, maman — prêt pour ta chaleur, tes bras, '
          'ta voix sans l\'écho de ton ventre.',
      fact: 'Un bébé né à 38 semaines est considéré à terme. '
          'Je pèse environ 3 kg et mesure 50 cm.',
      milestones: ['Bébé à terme', '≈ 3 kg / 50 cm', 'Prêt pour la naissance'],
    ),
    39: BabyStory(
      week: 39,
      title: 'Tout est prêt',
      story:
          'Mes poumons, mon cœur, mon cerveau, mes mains — tout est prêt. '
          'Je t\'attends, tu m\'attends. '
          'Ce moment qui approche sera le plus beau de nos vies.',
      fact: 'Le cerveau, les poumons et le foie sont complètement matures. '
          'Je prends encore 14 grammes de graisse par jour.',
      milestones: ['Organes matures', 'Graisse protectrice', 'En attente du grand jour'],
    ),
    40: BabyStory(
      week: 40,
      title: 'Il est temps de te rencontrer',
      story:
          'Maman… je suis prêt. Je t\'entends. Je te connais. '
          'Ta voix, ton cœur, ta chaleur — je les connais par cœur. '
          'Allons enfin nous rencontrer.',
      fact: 'Grossesse à terme. Je pèse en moyenne 3,4 kg et mesure 51 cm. '
          'Le plus beau chapitre commence maintenant.',
      milestones: ['Terme complet', '≈ 3,4 kg / 51 cm', 'Prêt pour le monde'],
    ),
  };

  // legacy helpers kept for compatibility
  static List<BabyStory> get stories => _data.values.toList();
  static String getStory(int week) => forWeek(week).story;
}
