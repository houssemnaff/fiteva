class PostpartumInsight {
  final int week;
  final String title;
  final String babyMilestone;
  final String momRecovery;
  final String mentalHealth;
  final String poeticLine;

  const PostpartumInsight({
    required this.week,
    required this.title,
    required this.babyMilestone,
    required this.momRecovery,
    required this.mentalHealth,
    required this.poeticLine,
  });
}

abstract class PostpartumInsightRepository {
  static PostpartumInsight forWeek(int week) {
    // Au-delà de la semaine 12 (fin du 4e trimestre), le contenu rédigé
    // s'arrête — avant, on répétait silencieusement le texte exact de la
    // semaine 12 ("La fin du 4e trimestre") pour n'importe quelle semaine
    // suivante, y compris très éloignées (jusqu'à ~104 semaines), avec un
    // titre qui ne correspondait plus du tout au numéro de semaine réel
    // affiché à l'écran.
    if (week > 12) return _beyondWeek12(week);
    final w = week.clamp(1, 12);
    return _data.firstWhere((d) => d.week == w, orElse: () => _data.last);
  }

  static PostpartumInsight _beyondWeek12(int week) {
    final months = (week / 4.345).round().clamp(4, 24);
    return PostpartumInsight(
      week: week,
      title: 'Environ $months mois avec bébé',
      babyMilestone:
          'À ce stade, chaque bébé se développe à son rythme propre — motricité, '
          'langage, sommeil. Suis les repères de ton pédiatre plutôt qu\'un '
          'calendrier générique pour évaluer ses progrès.',
      momRecovery: months < 6
          ? 'Le 4e trimestre est terminé, mais la récupération physique '
              'continue en arrière-plan. Continue la rééducation périnéale et '
              'le renforcement du core si ce n\'est pas encore fait.'
          : 'Ton corps a eu le temps de se stabiliser. Si des douleurs, fuites '
              'ou tensions persistent, ce n\'est plus "juste après '
              'l\'accouchement" — c\'est le bon moment d\'en reparler à un '
              'professionnel.',
      mentalHealth:
          'La charge mentale de la maternité évolue mais ne disparaît pas. '
          'Continue à te ménager des moments à toi, et à demander du soutien '
          'si tu en ressens le besoin — à tout moment, pas seulement dans les '
          'premières semaines.',
      poeticLine: '$months mois déjà. Le lien grandit, et toi avec lui.',
    );
  }

  static const _data = [
    PostpartumInsight(
      week: 1,
      title: 'Les premiers jours avec bébé',
      babyMilestone:
          'Bébé découvre le monde avec tous ses sens. Il reconnaît déjà ta voix et ton odeur. Le peau-à-peau renforce votre lien.',
      momRecovery:
          'Ton corps commence à récupérer. Repose-toi autant que possible. Les saignements (lochies) sont normaux. Accepte toute l\'aide proposée.',
      mentalHealth:
          'Le baby blues peut apparaître vers J3–J5 avec des pleurs inexpliqués. C\'est hormonal et temporaire. Parle à ton entourage.',
      poeticLine: 'Le monde s\'est arrêté le temps d\'un souffle, et tu étais là.',
    ),
    PostpartumInsight(
      week: 2,
      title: 'L\'allaitement et le nouveau rythme',
      babyMilestone:
          'Bébé reprend son poids de naissance. Il commence à suivre les visages du regard et peut imiter certaines expressions.',
      momRecovery:
          'La cicatrice (périnée ou césarienne) commence à guérir. Hydrate-toi bien, surtout si tu allaites. Évite de soulever des objets lourds.',
      mentalHealth:
          'Normalise le fait de ne pas tout maîtriser. Chaque nuit difficile est une nuit de moins. Demande de l\'aide si tu te sens dépassée.',
      poeticLine: 'Deux semaines. Déjà une vie entière en commun.',
    ),
    PostpartumInsight(
      week: 3,
      title: 'Les premières routines',
      babyMilestone:
          'Bébé devient plus éveillé et ses périodes d\'éveil s\'allongent. Il peut sourire de façon réflexe. Il adore écouter ta voix.',
      momRecovery:
          'Continue de te reposer dès que bébé dort. Commence des exercices doux du plancher pelvien (Kegel) si tu te sens prête.',
      mentalHealth:
          'Si la tristesse dure plus de 2 semaines, consulte ton médecin. La dépression post-partum se soigne bien avec du soutien adapté.',
      poeticLine: 'Trois semaines à apprendre à s\'aimer dans ce nouveau corps.',
    ),
    PostpartumInsight(
      week: 4,
      title: 'Un mois ensemble',
      babyMilestone:
          'Un mois ! Bébé peut tenir sa tête quelques secondes en tummy time. Ses sourires deviennent plus intentionnels. Il réagit aux sons.',
      momRecovery:
          'La visite post-natale approche. Parle à ton médecin de ta récupération, de la contraception et de tes questions. Tu peux reprendre des marches courtes.',
      mentalHealth:
          'Prends du temps pour toi chaque jour, même 10 minutes. Tu ne peux pas te vider pour remplir les autres.',
      poeticLine: 'Un mois de vie nouvelle. Tu as survécu aux nuits et tu brilles encore.',
    ),
    PostpartumInsight(
      week: 5,
      title: 'Reprendre ses forces',
      babyMilestone:
          'Bébé commence à gazouiller. Il suit les objets du regard et s\'intéresse aux contrastes de couleurs. Le portage peut le calmer.',
      momRecovery:
          'Ton utérus a pratiquement retrouvé sa taille normale. Tu peux commencer des marches plus longues. Écoute ton corps — sans te forcer.',
      mentalHealth:
          'Reconnecte-toi à une activité qui te fait du bien : musique, lecture, appel avec une amie. Tu existes au-delà de ton rôle de maman.',
      poeticLine: 'Cinq semaines. L\'épuisement est réel, et ta force aussi.',
    ),
    PostpartumInsight(
      week: 6,
      title: 'La visite post-natale',
      babyMilestone:
          'Bébé sourit socialement et peut rire. Il suit les visages du regard à 180°. Il aime les interactions courtes et animées.',
      momRecovery:
          'Visite post-natale à J42 : bilan de ta récupération physique, rééducation périnéale si besoin, reprise progressive d\'activité autorisée.',
      mentalHealth:
          'Parle de ton vécu émotionnel à ton médecin. Le retour de couches peut relancer les émotions. Tu n\'es pas seule dans ce chemin.',
      poeticLine: 'Six semaines. Le corps se souvient, l\'âme se reconstruit.',
    ),
    PostpartumInsight(
      week: 7,
      title: 'Retrouver son énergie',
      babyMilestone:
          'Bébé peut se retourner sur le côté. Il attrape les objets de manière plus précise. Ses nuits peuvent commencer à se réguler.',
      momRecovery:
          'Après validation médicale, tu peux reprendre des exercices doux : yoga postnatal, natation, marche rapide. Évite la course avant la rééducation.',
      mentalHealth:
          'La sexualité peut reprendre si tu te sens prête, sans pression. Communique avec ton partenaire sur tes besoins et tes limites.',
      poeticLine: 'Sept semaines. Tu commences à reconnaître le son de ta propre voix.',
    ),
    PostpartumInsight(
      week: 8,
      title: 'Deux mois de complicité',
      babyMilestone:
          'Deux mois ! Bébé rit aux éclats. Il reconnaît ses proches et peut interagir avec des jouets simples. Premier vaccin ce mois-ci.',
      momRecovery:
          'Reprends ta rééducation périnéale si ce n\'est pas encore fait. C\'est essentiel pour éviter les fuites urinaires et préparer ton corps à l\'effort.',
      mentalHealth:
          'Évalue ton humeur avec honnêteté. Si tu te sens anxieuse, en colère ou vide depuis plusieurs semaines, consulte sans culpabilité.',
      poeticLine: 'Deux mois. Tu as tenu, et c\'est magnifique.',
    ),
    PostpartumInsight(
      week: 9,
      title: 'Le retour à soi',
      babyMilestone:
          'Bébé commence à explorer ses mains et pieds. Il apprécie la musique et les livres aux images contrastées. Il gazouille de plus en plus.',
      momRecovery:
          'Mange équilibré, riche en fer et en protéines pour soutenir la récupération. Si tu allaites, continue les compléments de vitamine D.',
      mentalHealth:
          'Reconnecte-toi à des amis ou rejoins un groupe de mamans. L\'isolement aggrave la fatigue émotionnelle. Tu as besoin de ta tribu.',
      poeticLine: 'Semaine 9. Tu apprends à être mère en restant toi-même.',
    ),
    PostpartumInsight(
      week: 10,
      title: 'Corps en transformation',
      babyMilestone:
          'Bébé peut se retourner du ventre au dos. Il aime se regarder dans un miroir et cherche à attraper tout ce qui est à portée.',
      momRecovery:
          'Tu peux progressivement reprendre des exercices plus intenses selon ta récupération et les recommandations de ta sage-femme. Le renforcement du core est prioritaire.',
      mentalHealth:
          'Si tu reprends le travail bientôt, prépare-toi émotionnellement et logistiquement. C\'est normal de ressentir ambivalence et culpabilité.',
      poeticLine: 'Dix semaines. Ton corps porte l\'histoire d\'un miracle.',
    ),
    PostpartumInsight(
      week: 11,
      title: 'Bébé s\'éveille',
      babyMilestone:
          'Bébé interagit de plus en plus avec son environnement. Il peut se tenir assis avec soutien et aime les jeux de coucou-caché.',
      momRecovery:
          'Continue à honorer les besoins de ton corps. Le sommeil reste une priorité. Si les nuits sont encore difficiles, cherche du soutien sans honte.',
      mentalHealth:
          'Trois mois approchent — une étape symbolique. Prends un moment pour réfléchir au chemin parcouru et célébrer ta résilience.',
      poeticLine: 'Onze semaines de vie à deux. Tu as tout appris en faisant.',
    ),
    PostpartumInsight(
      week: 12,
      title: 'La fin du 4e trimestre',
      babyMilestone:
          '3 mois ! Bébé rit, gazouille et reconnaît les visages familiers. Il commence à saisir des objets et son développement s\'accélère.',
      momRecovery:
          'Le 4e trimestre se termine. Ton corps a accompli quelque chose d\'extraordinaire. Continue la rééducation et écoute tes besoins à long terme.',
      mentalHealth:
          'Célèbre les trois mois. Même imparfaits. Même épuisants. Tu as été présente, et c\'est tout ce qui compte.',
      poeticLine: 'Trois mois. Une vie transformée, un amour sans fond.',
    ),
  ];
}
