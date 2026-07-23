// ignore_for_file: deprecated_member_use


import 'package:chewie/chewie.dart';
import 'package:fiteva/widgets/shared_app_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:video_player/video_player.dart';
import '../../l10n/app_localizations.dart';
import '../../services/sante_service.dart';
import '../../providers/points_provider.dart';
import '../../widgets/points_toast.dart';
import 'qr_screen.dart';

// ─── Tokens ───────────────────────────────────────────────────────────────────

/// Tokens dérivés du ColorScheme actif (thème + palette de couleurs Pro),
/// même logique que community_screen.dart / theme_screen.dart.
class _T {
  static Color bg(BuildContext c)     => Theme.of(c).colorScheme.surface;
  static Color card(BuildContext c)   => Theme.of(c).colorScheme.surfaceContainerHighest;
  static Color border(BuildContext c) => Theme.of(c).colorScheme.outline;
  static Color t1(BuildContext c)     => Theme.of(c).colorScheme.onSurface;
  static Color t2(BuildContext c)     => Theme.of(c).colorScheme.onSurface.withValues(alpha: 0.5);
  static Color t3(BuildContext c)     => Theme.of(c).colorScheme.onSurface.withValues(alpha: 0.25);
  static Color accent(BuildContext c) => Theme.of(c).colorScheme.primary;
  static Color onAccent(BuildContext c) => Theme.of(c).colorScheme.onPrimary;
}

// ─── Models ───────────────────────────────────────────────────────────────────

class _Doctor {
  final String name, specialty, location, hospital, phone, email, initials;
  final String? photoAsset;
  final Color color;
  final double rating;
  final int consultations;
  const _Doctor({
    required this.name, required this.specialty, required this.location,
    required this.hospital, required this.phone, required this.email,
    required this.initials, required this.color,
    this.photoAsset,
    this.rating = 4.8, this.consultations = 120,
  });
}

class _Conseil {
  final _Doctor doctor;
  final String title, body, category, postedAgo;
  final int likes, readMin;
  const _Conseil({
    required this.doctor, required this.title, required this.body,
    required this.category, required this.postedAgo, required this.likes,
    this.readMin = 2,
  });
}

class _Question {
  final String question, postedAgo;
  final int votes;
  final String? doctorAnswer, answerDoctor;
  const _Question({
    required this.question, required this.postedAgo, required this.votes,
    this.doctorAnswer, this.answerDoctor,
  });
}

class _Article {
  final String title, author, excerpt, category, body;
  final int readMin;
  final Color color;
  final String? photoAsset;
  const _Article({
    required this.title, required this.author, required this.excerpt,
    required this.category, required this.readMin, required this.color,
    required this.body, this.photoAsset,
  });
}

class _LexiqueEntry {
  final String term, definition, category;
  const _LexiqueEntry({required this.term, required this.definition, required this.category});
}

class _VideoEpisode {
  final int episode;
  final String title, duration, asset;
  const _VideoEpisode({required this.episode, required this.title, required this.duration, required this.asset});
}

class _VideoSeries {
  final _Doctor doctor;
  final String title;
  final Color color;
  final String? coverAsset;
  final List<_VideoEpisode> episodes;
  const _VideoSeries({required this.doctor, required this.title, required this.color,
    this.coverAsset, required this.episodes});
}

// ─── Data ─────────────────────────────────────────────────────────────────────

const _doctors = [
  _Doctor(name: 'Dr. Sarah Mansouri', specialty: 'Gynécologie',
    location: 'Tunis', hospital: 'Clinique El Manar',
    phone: '+216 71 000 001', email: 's.mansouri@manar.tn',
    initials: 'SM', color: Color(0xFF1C4D30), rating: 4.9, consultations: 342,
    photoAsset: 'assets/images/gynecologue.jpg'),
  _Doctor(name: 'Dr. Karim Belhadj', specialty: 'Endocrinologie',
    location: 'Sousse', hospital: 'CHU Farhat Hached',
    phone: '+216 73 000 002', email: 'k.belhadj@chu-sousse.tn',
    initials: 'KB', color: Color(0xFF2563EB), rating: 4.7, consultations: 215,
    photoAsset: 'assets/images/medecin3.jpg'),
  _Doctor(name: 'Dr. Nadia Trabelsi', specialty: 'Médecine du Sport',
    location: 'Sfax', hospital: 'Centre Médical Sportif',
    phone: '+216 74 000 003', email: 'n.trabelsi@cms-sfax.tn',
    initials: 'NT', color: Color(0xFF7C3AED), rating: 4.8, consultations: 178,
    photoAsset: 'assets/images/medecin4.jpg'),
  _Doctor(name: 'Dr. Amine Chokri', specialty: 'Nutrition',
    location: 'Ariana', hospital: 'Cabinet Privé',
    phone: '+216 70 000 004', email: 'a.chokri@nutrition.tn',
    initials: 'AC', color: Color(0xFFB45309), rating: 4.6, consultations: 290,
    photoAsset: 'assets/images/cover_nutrition.jpg'),
  _Doctor(name: 'Dr. Leila Gharbi', specialty: 'Psychiatrie',
    location: 'Tunis', hospital: 'Hôpital Razi',
    phone: '+216 71 000 005', email: 'l.gharbi@razi.tn',
    initials: 'LG', color: Color(0xFF0369A1), rating: 4.9, consultations: 401,
    photoAsset: 'assets/images/medecin5.jpg'),
];

final _conseils = [
  _Conseil(doctor: _doctors[0], category: 'Sport',
    title: 'Activité physique et cycle menstruel',
    body: 'Pendant la phase folliculaire, votre endurance est maximale. En phase lutéale, privilégiez le yoga ou la marche.',
    postedAgo: '2h', likes: 47, readMin: 3),
  _Conseil(doctor: _doctors[1], category: 'Nutrition',
    title: 'Résistance à l\'insuline et alimentation',
    body: 'Les femmes souffrant de SOPK bénéficient d\'une alimentation à index glycémique bas. Réduisez les sucres raffinés.',
    postedAgo: '5h', likes: 83, readMin: 4),
  _Conseil(doctor: _doctors[2], category: 'Sommeil',
    title: 'Récupération et sommeil chez la sportive',
    body: 'La mélatonine produite entre 22h et 2h est déterminante pour la récupération musculaire. Évitez les écrans 1h avant le coucher.',
    postedAgo: '1j', likes: 61, readMin: 3),
  _Conseil(doctor: _doctors[3], category: 'Nutrition',
    title: 'Carences en fer chez la femme active',
    body: 'La carence en fer touche 20% des femmes. Associez les aliments riches en fer à de la vitamine C pour optimiser l\'absorption.',
    postedAgo: '2j', likes: 112, readMin: 2),
  _Conseil(doctor: _doctors[4], category: 'Mental',
    title: 'Anxiété cyclique et hormones',
    body: 'Le pic d\'œstrogènes avant l\'ovulation peut provoquer une anxiété légère. La cohérence cardiaque (5 min, 3×/jour) régule le système nerveux.',
    postedAgo: '3j', likes: 95, readMin: 4),
  _Conseil(doctor: _doctors[0], category: 'Hormones',
    title: 'Douleurs pelviennes : quand consulter ?',
    body: 'Des douleurs pelviennes persistantes hors des règles méritent une consultation. L\'endométriose touche 1 femme sur 10.',
    postedAgo: '4j', likes: 204, readMin: 5),
];

const _questions = [
  _Question(question: 'Est-ce normal d\'avoir des crampes pendant toute la semaine des règles ?',
    postedAgo: '1h', votes: 34,
    doctorAnswer: 'Des douleurs modérées sont normales, mais des crampes invalidantes sur toute la semaine peuvent indiquer une dysménorrhée secondaire. Consultez un gynécologue.',
    answerDoctor: 'Dr. Sarah Mansouri'),
  _Question(question: 'Mon médecin m\'a prescrit de la progestérone naturelle, y a-t-il des effets secondaires ?',
    postedAgo: '3h', votes: 21,
    doctorAnswer: 'La progestérone naturelle micronisée est bien tolérée. Les effets possibles : légère somnolence (prenez-la le soir), nausées rares. Ces effets disparaissent après quelques semaines.',
    answerDoctor: 'Dr. Karim Belhadj'),
  _Question(question: 'Je fais du sport 5 fois par semaine mais je prends du poids. Pourquoi ?',
    postedAgo: '6h', votes: 57),
  _Question(question: 'Quelle est la différence entre SOPK et endométriose ?',
    postedAgo: '1j', votes: 89,
    doctorAnswer: 'Le SOPK est un trouble hormonal affectant l\'ovulation. L\'endométriose est une maladie inflammatoire où du tissu utérin se développe à l\'extérieur de l\'utérus. Elles peuvent coexister.',
    answerDoctor: 'Dr. Sarah Mansouri'),
];

const _articles = [
  _Article(title: 'Le microbiome intestinal féminin', author: 'Dr. Amine Chokri',
    excerpt: 'Les recherches récentes montrent un lien direct entre la composition du microbiome et les fluctuations hormonales.',
    category: 'Nutrition', readMin: 8, color: Color(0xFFB45309),
    photoAsset: 'assets/images/microbiomee.jpg',
    body: 'Le microbiome intestinal joue un rôle central dans la santé féminine. Des études récentes révèlent que la composition bactérienne de l\'intestin est directement influencée par les hormones sexuelles — œstrogènes, progestérone et testostérone — et que cette relation est bidirectionnelle.\n\n'
      'L\'estrobolome, un sous-ensemble du microbiome, est responsable de la métabolisation des œstrogènes. Lorsque cet équilibre est perturbé (dysbiose), les niveaux d\'œstrogènes circulants peuvent augmenter ou diminuer de manière significative, contribuant à des conditions telles que l\'endométriose, le SOPK ou le syndrome prémenstruel sévère.\n\n'
      'Au cours du cycle menstruel, la diversité bactérienne fluctue. Pendant la phase folliculaire, lorsque les œstrogènes augmentent, on observe une plus grande diversité microbienne et une meilleure perméabilité intestinale. En revanche, la phase lutéale, dominée par la progestérone, peut ralentir le transit et modifier la composition bactérienne.\n\n'
      'Pour soutenir un microbiome sain :\n'
      '• Consommez des aliments fermentés (kéfir, kimchi, choucroute)\n'
      '• Augmentez les fibres prébiotiques (ail, oignon, asperges, bananes vertes)\n'
      '• Limitez les sucres raffinés et les aliments ultra-transformés\n'
      '• Gérez votre stress — le cortisol altère directement la flore intestinale\n\n'
      'La recherche sur le microbiome féminin est encore jeune, mais les résultats sont prometteurs. En prenant soin de votre intestin, vous prenez soin de votre équilibre hormonal global.'),
  _Article(title: 'Anxiété prémenstruelle : comprendre le PMDD', author: 'Dr. Leila Gharbi',
    excerpt: 'Le trouble dysphorique prémenstruel touche 3 à 8% des femmes et est souvent confondu avec une dépression.',
    category: 'Mental', readMin: 11, color: Color(0xFF0369A1),
    photoAsset: 'assets/images/pmdd.png',
    body: 'Le trouble dysphorique prémenstruel (PMDD) est une forme sévère du syndrome prémenstruel qui affecte 3 à 8% des femmes en âge de procréer. Contrairement au SPM classique, le PMDD provoque des symptômes émotionnels intenses qui peuvent sérieusement impacter la vie quotidienne.\n\n'
      'Les symptômes apparaissent typiquement 7 à 10 jours avant les règles et disparaissent dans les premiers jours du cycle. Ils incluent :\n'
      '• Anxiété sévère ou crises de panique\n'
      '• Tristesse profonde, sentiment de désespoir\n'
      '• Irritabilité extrême, colère disproportionnée\n'
      '• Difficulté de concentration\n'
      '• Fatigue intense, troubles du sommeil\n'
      '• Sensation de perte de contrôle\n\n'
      'Le PMDD est causé par une sensibilité anormale du cerveau aux fluctuations normales de progestérone et d\'œstrogènes. Ce n\'est pas un manque de volonté ni un trouble psychologique — c\'est une réponse neurobiologique.\n\n'
      'Le diagnostic repose sur un suivi quotidien des symptômes sur au moins deux cycles consécutifs. Les traitements incluent :\n'
      '• Les ISRS (inhibiteurs sélectifs de la recapture de la sérotonine), efficaces même en prise intermittente\n'
      '• La thérapie cognitivo-comportementale (TCC)\n'
      '• Les modifications du mode de vie : exercice régulier, réduction de la caféine, supplémentation en calcium et magnésium\n'
      '• Dans les cas sévères, les agonistes de la GnRH pour supprimer temporairement l\'ovulation\n\n'
      'Si vous vous reconnaissez dans ces symptômes, consultez un professionnel de santé. Le PMDD est une condition médicale reconnue qui mérite une prise en charge adaptée.'),
  _Article(title: 'Périménopause et sport : adapter sa pratique', author: 'Dr. Nadia Trabelsi',
    excerpt: 'La musculation devient essentielle pendant la périménopause pour préserver la densité osseuse et le métabolisme.',
    category: 'Sport', readMin: 9, color: Color(0xFF7C3AED),
    photoAsset: 'assets/images/perimenopause.png',
    body: 'La périménopause, qui débute généralement entre 40 et 45 ans, marque une transition hormonale majeure. Les fluctuations d\'œstrogènes et de progestérone modifient la composition corporelle, la récupération et les capacités physiques. Adapter sa pratique sportive devient alors essentiel.\n\n'
      'Pourquoi la musculation est cruciale :\n'
      'La baisse des œstrogènes accélère la perte de masse osseuse (ostéopénie) et musculaire (sarcopénie). La musculation avec charges est le moyen le plus efficace de contrer ces deux phénomènes.\n'
      '• Visez 2 à 3 séances par semaine avec des charges progressives\n'
      '• Privilégiez les mouvements composés : squats, soulevés de terre, développés, tractions\n'
      '• N\'ayez pas peur des charges lourdes — c\'est la stimulation mécanique qui renforce les os\n\n'
      'L\'entraînement par intervalles (HIIT) :\n'
      'Les séances courtes et intenses améliorent la sensibilité à l\'insuline, souvent altérée pendant la périménopause. 2 séances de 20-30 minutes par semaine suffisent. Écoutez votre corps — la récupération peut être plus longue qu\'avant.\n\n'
      'Mobilité et récupération :\n'
      'La diminution des œstrogènes affecte la qualité du collagène et donc la souplesse articulaire. Intégrez :\n'
      '• 10-15 minutes de mobilité quotidienne\n'
      '• Du yoga ou du Pilates 1 à 2 fois par semaine\n'
      '• Un sommeil de qualité (7-8h) — la récupération se fait principalement la nuit\n\n'
      'Ce qu\'il faut éviter :\n'
      '• Le cardio excessif à intensité modérée (peut augmenter le cortisol)\n'
      '• Les régimes très restrictifs (aggravent la perte musculaire)\n'
      '• Ignorer les signaux de fatigue — le surentraînement est plus fréquent à cette période\n\n'
      'La périménopause n\'est pas une fin, c\'est une adaptation. Avec une approche intelligente, vous pouvez maintenir — et même améliorer — votre forme physique.'),
];

const _lexique = [
  _LexiqueEntry(term: 'SOPK', category: 'Hormones',
    definition: 'Syndrome des Ovaires Polykystiques. Trouble hormonal fréquent caractérisé par un excès d\'androgènes et des cycles irréguliers.'),
  _LexiqueEntry(term: 'Endométriose', category: 'Gynécologie',
    definition: 'Maladie chronique où du tissu semblable à la muqueuse utérine se développe en dehors de l\'utérus.'),
  _LexiqueEntry(term: 'Phase folliculaire', category: 'Cycle',
    definition: 'Première phase du cycle (jours 1–14). Les follicules ovariens se développent sous l\'effet de la FSH.'),
  _LexiqueEntry(term: 'Progestérone', category: 'Hormones',
    definition: 'Hormone produite après l\'ovulation. Elle prépare l\'utérus à une grossesse et régule le cycle.'),
  _LexiqueEntry(term: 'AMH', category: 'Fertilité',
    definition: 'Hormone anti-müllérienne. Marqueur de la réserve ovarienne pour évaluer la fertilité.'),
  _LexiqueEntry(term: 'Dysménorrhée', category: 'Gynécologie',
    definition: 'Douleurs menstruelles. Primaire (sans cause) ou secondaire (endométriose, fibromes).'),
];

const _rappels = [
  (title: 'Bilan gynécologique annuel', icon: LucideIcons.calendar, due: 'Dans 3 mois', done: false),
  (title: 'Prise de sang (fer, hormones)', icon: LucideIcons.droplets, due: 'Dans 6 semaines', done: false),
  (title: 'Visite dentiste', icon: LucideIcons.smile, due: 'Fait le 10 mars', done: true),
  (title: 'Mammographie', icon: LucideIcons.activity, due: 'Dans 8 mois', done: false),
  (title: 'Dermatologue', icon: LucideIcons.sun, due: 'Non planifié', done: false),
];

// ─── Supabase Providers ───────────────────────────────────────────────────────

final _santeDoctorsProvider = FutureProvider<List<_Doctor>>((ref) async {
  try {
    final rows = await SanteService.fetchDoctors();
    if (rows.isEmpty) return _doctors;
    return rows.map(_doctorFromRow).toList();
  } catch (_) {
    return _doctors;
  }
});

final _santeArticlesProvider = FutureProvider<List<_Article>>((ref) async {
  try {
    final rows = await SanteService.fetchArticles();
    if (rows.isEmpty) return _articles;
    return rows.map(_articleFromRow).toList();
  } catch (_) {
    return _articles;
  }
});

final _santeQuestionsProvider = FutureProvider<List<_Question>>((ref) async {
  try {
    final rows = await SanteService.fetchQuestions();
    if (rows.isEmpty) return _questions;
    return rows.map(_questionFromRow).toList();
  } catch (_) {
    return _questions;
  }
});

final _santeVideosProvider = FutureProvider<List<_VideoSeries>>((ref) async {
  try {
    final rows = await SanteService.fetchSanteVideos();
    if (rows.isEmpty) return _videoSeries;

    final Map<String, List<_VideoEpisode>> supaEpisodes = {};
    for (final r in rows) {
      final series = r['series_title'] as String;
      supaEpisodes.putIfAbsent(series, () => []);
      supaEpisodes[series]!.add(_VideoEpisode(
        episode: (r['episode'] as num).toInt(),
        title: r['title'] as String,
        duration: r['duration'] as String,
        asset: r['video_url'] as String,
      ));
    }

    return _videoSeries.map((s) {
      final extra = supaEpisodes[s.title];
      if (extra == null) return s;
      final existing = s.episodes.map((e) => e.episode).toSet();
      final newEps = extra.where((e) => !existing.contains(e.episode)).toList();
      if (newEps.isEmpty) return s;
      return _VideoSeries(
        doctor: s.doctor, title: s.title, color: s.color,
        coverAsset: s.coverAsset,
        episodes: [...s.episodes, ...newEps]..sort((a, b) => a.episode.compareTo(b.episode)),
      );
    }).toList();
  } catch (_) {
    return _videoSeries;
  }
});

_Doctor _doctorFromRow(Map<String, dynamic> r) {
  final hex = (r['color_hex'] as String? ?? '#1C4D30').replaceFirst('#', '');
  final colorVal = int.tryParse('0xFF$hex') ?? 0xFF1C4D30;
  return _Doctor(
    name: r['name'] as String? ?? '',
    specialty: r['specialty'] as String? ?? '',
    location: r['location'] as String? ?? '',
    hospital: r['hospital'] as String? ?? '',
    phone: r['phone'] as String? ?? '',
    email: r['email'] as String? ?? '',
    initials: r['initials'] as String? ?? '?',
    color: Color(colorVal),
    rating: (r['rating'] as num? ?? 4.8).toDouble(),
    consultations: (r['consultations'] as num? ?? 0).toInt(),
    photoAsset: r['photo_asset'] as String?,
  );
}

_Article _articleFromRow(Map<String, dynamic> r) {
  final cat = r['category'] as String? ?? '';
  final color = _catColor(cat);
  return _Article(
    title: r['title'] as String? ?? '',
    author: r['author'] as String? ?? '',
    excerpt: r['excerpt'] as String? ?? '',
    body: r['body'] as String? ?? '',
    category: cat,
    readMin: (r['read_min'] as num? ?? 5).toInt(),
    color: color,
    photoAsset: r['photo_asset'] as String?,
  );
}

_Question _questionFromRow(Map<String, dynamic> r) => _Question(
  question: r['question'] as String? ?? '',
  postedAgo: r['posted_ago'] as String? ?? '',
  votes: (r['votes'] as num? ?? 0).toInt(),
  doctorAnswer: r['doctor_answer'] as String?,
  answerDoctor: r['answer_doctor'] as String?,
);

Color _catColor(String c) => switch (c) {
  'Sport'    => const Color(0xFF2563EB),
  'Nutrition'=> const Color(0xFFD97706),
  'Sommeil'  => const Color(0xFF7C3AED),
  'Mental'   => const Color(0xFF0D9488),
  'Hormones' => const Color(0xFFDB2777),
  _          => const Color(0xFF1C4D30),
};

final _videoSeries = [
  _VideoSeries(doctor: _doctors[3], title: 'Nutrition Féminine',
    color: const Color(0xFFB45309), coverAsset: 'assets/images/cover_nutrition.jpg', episodes: const [
      _VideoEpisode(episode: 1, title: 'Carences & SPM : ce que ton assiette dit de toi', duration: '4:32', asset: 'assets/videos/sante.mov'),
      _VideoEpisode(episode: 2, title: 'Carence en fer : reconnaître les signes', duration: '5:10', asset: 'assets/videos/sante.mov'),
      _VideoEpisode(episode: 3, title: 'Alimentation anti-inflammatoire', duration: '6:15', asset: 'assets/videos/sante.mov'),
      _VideoEpisode(episode: 4, title: 'Envies de sucre avant les règles : pourquoi et comment gérer', duration: '5:20', asset: 'https://res.cloudinary.com/dmzvbqocs/video/upload/v1784400265/IMG_3454_pedwzm.mov'),
      _VideoEpisode(episode: 5, title: 'Ballonnements : causes et solutions naturelles', duration: '4:50', asset: 'https://res.cloudinary.com/dmzvbqocs/video/upload/v1784388477/copy_4EA7AC78-599E-4E74-8C80-C42DA9CA3A59_pjfeln.mov'),
      _VideoEpisode(episode: 6, title: 'Cycle et protéines : combien et quand en consommer', duration: '5:30', asset: 'https://res.cloudinary.com/dmzvbqocs/video/upload/v1784407262/IMG_3449_pliy1d.mov'),
    ]),
  _VideoSeries(doctor: _doctors[0], title: 'Comprendre ton corps',
    color: const Color(0xFF1C4D30), coverAsset: 'assets/images/gynecologue.jpg', episodes: const [
      _VideoEpisode(episode: 1, title: 'Le cycle menstruel en 5 min', duration: '5:00', asset: 'assets/videos/sante.mov'),
      _VideoEpisode(episode: 2, title: 'SOPK : symptômes & traitement', duration: '7:20', asset: 'assets/videos/sante.mov'),
      _VideoEpisode(episode: 3, title: 'Endométriose : briser le tabou', duration: '8:45', asset: 'assets/videos/sante.mov'),
    ]),
  _VideoSeries(doctor: _doctors[1], title: 'Hormones & Équilibre',
    color: const Color(0xFF2563EB), coverAsset: 'assets/images/medecin3.jpg',episodes: const [
      _VideoEpisode(episode: 1, title: 'Résistance à l\'insuline', duration: '6:05', asset: 'assets/videos/sante.mov'),
      _VideoEpisode(episode: 2, title: 'Thyroïde et prise de poids', duration: '5:48', asset: 'assets/videos/sante.mov'),
    ]),
  _VideoSeries(doctor: _doctors[2], title: 'Bouger Mieux',
    color: const Color(0xFF7C3AED), coverAsset: 'assets/images/medecin4.jpg',episodes: const [
      _VideoEpisode(episode: 1, title: 'Sport et cycle menstruel', duration: '4:50', asset: 'assets/videos/sante.mov'),
      _VideoEpisode(episode: 2, title: 'Récupération active', duration: '3:47', asset: 'assets/videos/sante.mov'),
      _VideoEpisode(episode: 3, title: 'Périménopause et musculation', duration: '7:30', asset: 'assets/videos/sante.mov'),
    ]),
  _VideoSeries(doctor: _doctors[4], title: 'Santé Mentale',
    color: const Color(0xFF0369A1),coverAsset: 'assets/images/medecin5.jpg', episodes: const [
      _VideoEpisode(episode: 1, title: 'Anxiété et hormones', duration: '5:08', asset: 'assets/videos/sante.mov'),
      _VideoEpisode(episode: 2, title: 'Cohérence cardiaque guidée', duration: '5:00', asset: 'assets/videos/sante.mov'),
    ]),
];

const _doctorPositions = [
  (x: 0.52, y: 0.28), (x: 0.55, y: 0.45), (x: 0.54, y: 0.62),
  (x: 0.50, y: 0.22), (x: 0.52, y: 0.28),
];

const _cats   = ['Tout', 'Nutrition', 'Sport', 'Sommeil', 'Mental', 'Hormones'];
const _specs  = ['Toutes', 'Gynécologie', 'Endocrinologie', 'Sport', 'Nutrition', 'Psychiatrie'];

// ─── Screen ───────────────────────────────────────────────────────────────────

class SanteScreen extends ConsumerStatefulWidget {
  const SanteScreen({super.key});
  @override
  ConsumerState<SanteScreen> createState() => _SanteScreenState();
}

class _SanteScreenState extends ConsumerState<SanteScreen> with SingleTickerProviderStateMixin {
  late final TabController _tab;
  String _cat = 'Tout';
  final Set<int> _liked = {};
  String _spec = 'Toutes';
  int? _marker;
  String _lex = '';
  final _wCtrl = TextEditingController();
  final _bCtrl = TextEditingController();
  final List<Map<String, String>> _history = [];

  @override
  void initState() { super.initState(); _tab = TabController(length: 4, vsync: this); }
  @override
  void dispose() { _tab.dispose(); _wCtrl.dispose(); _bCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final l10n = ref.watch(l10nProvider);

    final doctors      = ref.watch(_santeDoctorsProvider).asData?.value   ?? _doctors;
    final articles     = ref.watch(_santeArticlesProvider).asData?.value  ?? _articles;
    final questions    = ref.watch(_santeQuestionsProvider).asData?.value ?? _questions;
    final videoSeries  = ref.watch(_santeVideosProvider).asData?.value    ?? _videoSeries;

    return Scaffold(
      backgroundColor: _T.bg(context),
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [
          SharedAppHeader.sliver(
            eyebrow: l10n.santeSanteEyebrow,
            title: l10n.santeMySpace,
            accentColor: _T.accent(context),
            bgColor: _T.bg(context),
            actions: [
              GestureDetector(
                onTap: () {},
                child: Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: _T.accent(context).withOpacity(0.10),
                    shape: BoxShape.circle),
                  child: Icon(LucideIcons.bookmark, size: 17, color: _T.accent(context)))),
            ],
          ),

          SliverToBoxAdapter(
            child: Container(
              color: _T.bg(context),
              child: TabBar(
                controller: _tab,
                isScrollable: false,
                labelPadding: const EdgeInsets.symmetric(horizontal: 4),
                labelStyle: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w600),
                unselectedLabelStyle: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w400),
                labelColor: _T.accent(context),
                unselectedLabelColor: _T.t3(context),
                indicatorColor: _T.accent(context),
                indicatorSize: TabBarIndicatorSize.tab,
                indicatorWeight: 2,
                dividerColor: Colors.transparent,
                tabs: const [
                  Tab(icon: Icon(LucideIcons.stethoscope, size: 14), text: 'Conseils'),
                  Tab(icon: Icon(LucideIcons.video, size: 14), text: 'Ressources'),
                  Tab(icon: Icon(LucideIcons.messageCircleQuestion, size: 14), text: 'Q & R'),
                  Tab(icon: Icon(LucideIcons.userRound, size: 14), text: 'Médecins'),
                ],
              ),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tab,
          children: [
            _ConseisTab(dark: dark, cat: _cat, liked: _liked,
              onCat: (c) => setState(() => _cat = c),
              onLike: (i) => setState(() { if (_liked.contains(i)) _liked.remove(i); else _liked.add(i); }),
              onDoctor: (d) => _sheet(context, _DoctorSheet(doctor: d, dark: dark, l10n: l10n))),
            _RessourcesTab(dark: dark, lex: _lex, l10n: l10n, articles: articles, videoSeries: videoSeries,
              onLex: (s) => setState(() => _lex = s),
              onArticleTap: (article) {
                ref.read(pointsProvider.notifier).rewardHealthTipRead().then((_) {
                  if (context.mounted) maybeShowLevelUpToast(context, ref);
                });
                PointsToast.show(context, PointsAmounts.healthTipRead, label: 'Article lu !');
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => _ArticleDetailScreen(article: article),
                ));
              }),
            QrFeedTab(
              questions: questions.map((q) => QrQuestion(
                question: q.question,
                postedAgo: q.postedAgo,
                votes: q.votes,
                category: 'Cycle',
                answers: q.doctorAnswer != null ? [QrAnswer(
                  doctorName: q.answerDoctor ?? '',
                  specialty: 'Médecin',
                  answer: q.doctorAnswer!,
                )] : [],
              )).toList(),
              onSubmit: (text) => SanteService.submitQuestion(text),
            ),
            _DoctorsTab(
              dark: dark, spec: _spec, marker: _marker, l10n: l10n,
              doctors: doctors,
              onSpec: (s) => setState(() => _spec = s),
              onMarker: (i) => setState(() => _marker = _marker == i ? null : i),
              onDoctor: (d) => _sheet(context, _DoctorSheet(doctor: d, dark: dark, l10n: l10n))),
          ],
        ),
      ),
    );
  }

  void _sheet(BuildContext ctx, Widget child) => showModalBottomSheet(
    context: ctx, isScrollControlled: true, backgroundColor: Colors.transparent,
    builder: (_) => child,
  );
}

// ─── Health Banner ────────────────────────────────────────────────────────────



class _StatPill extends StatelessWidget {
  final IconData icon; final String label, sub; final Color color; final bool dark;
  const _StatPill({required this.icon, required this.label, required this.sub, required this.color, required this.dark});
  @override
  Widget build(BuildContext context) => Expanded(child: Column(children: [
    Container(
      width: 36, height: 36,
      decoration: BoxDecoration(color: color.withOpacity(0.12), shape: BoxShape.circle),
      child: Icon(icon, size: 16, color: color),
    ),
    const SizedBox(height: 6),
    Text(label, style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w700, color: _T.t1(context))),
    Text(sub, style: GoogleFonts.inter(fontSize: 10, color: _T.t2(context))),
  ]));
}

class _Divider extends StatelessWidget {
  final bool dark;
  const _Divider({required this.dark});
  @override
  Widget build(BuildContext context) => Container(width: 1, height: 40, color: _T.border(context));
}

// ─── Tab 1 · Conseils ─────────────────────────────────────────────────────────

class _ConseisTab extends StatelessWidget {
  final bool dark;
  final String cat;
  final Set<int> liked;
  final ValueChanged<String> onCat;
  final ValueChanged<int> onLike;
  final ValueChanged<_Doctor> onDoctor;
  const _ConseisTab({required this.dark, required this.cat, required this.liked,
    required this.onCat, required this.onLike, required this.onDoctor});

  List<_Conseil> get _list => cat == 'Tout'
      ? _conseils : _conseils.where((c) => c.category == cat).toList();

  void _showFilterSheet(BuildContext context, Color accent) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: _T.bg(context),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20))),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const SizedBox(height: 8),
          Container(width: 36, height: 4,
            decoration: BoxDecoration(
              color: _T.t3(context), borderRadius: BorderRadius.circular(2))),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(children: [
              Text('Filtrer par catégorie', style: GoogleFonts.outfit(
                fontSize: 17, fontWeight: FontWeight.w700, color: _T.t1(context))),
            ])),
          ...List.generate(_cats.length, (i) {
            final c = _cats[i];
            final active = c == cat;
            final color = c == 'Tout' ? accent : _catColor(c);
            return ListTile(
              leading: Container(
                width: 34, height: 34,
                decoration: BoxDecoration(
                  color: color.withOpacity(active ? 0.15 : 0.08),
                  shape: BoxShape.circle),
                child: Icon(_catIcon(c), size: 15, color: color)),
              title: Text(c, style: GoogleFonts.inter(
                fontSize: 14, fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                color: active ? color : _T.t1(context))),
              trailing: active
                ? Icon(LucideIcons.check, size: 16, color: color)
                : null,
              onTap: () { onCat(c); Navigator.pop(context); },
            );
          }),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 12),
        ]),
      ),
    );
  }

  static Color _catColor(String c) => switch (c) {
    'Sport'    => const Color(0xFF4A6FA5),
    'Nutrition'=> const Color(0xFFB8860B),
    'Sommeil'  => const Color(0xFF8E7BA6),
    'Mental'   => const Color(0xFF5A8A6E),
    'Hormones' => const Color(0xFFC97B84),
    _          => const Color(0xFF1C4D30),
  };

  static IconData _catIcon(String c) => switch (c) {
    'Sport'    => LucideIcons.dumbbell,
    'Nutrition'=> LucideIcons.salad,
    'Sommeil'  => LucideIcons.moon,
    'Mental'   => LucideIcons.brain,
    'Hormones' => LucideIcons.activity,
    _          => LucideIcons.layoutGrid,
  };

  @override
  Widget build(BuildContext context) {
    final accent = _T.accent(context);
    return CustomScrollView(
      slivers: [
        // ── Filter button ──
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
            child: Row(children: [
              GestureDetector(
                onTap: () => _showFilterSheet(context, accent),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: cat != 'Tout' ? accent : accent.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(20)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(LucideIcons.slidersHorizontal, size: 13,
                      color: cat != 'Tout' ? Colors.white : accent),
                    const SizedBox(width: 6),
                    Text(cat == 'Tout' ? 'Filtres' : cat,
                      style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w600,
                        color: cat != 'Tout' ? Colors.white : accent)),
                    if (cat != 'Tout') ...[
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: () => onCat('Tout'),
                        child: const Icon(LucideIcons.x, size: 12, color: Colors.white)),
                    ],
                  ])),
              ),
              const Spacer(),
              Text('${_list.length} conseil${_list.length != 1 ? 's' : ''}',
                style: GoogleFonts.inter(fontSize: 11,
                  color: _T.t3(context), fontWeight: FontWeight.w500)),
            ]),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 110),
          sliver: SliverList.separated(
            itemCount: _list.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) {
              final c = _list[i]; final idx = _conseils.indexOf(c);
              final isLiked = liked.contains(idx);
              return _ConseilTile(conseil: c, dark: dark, isLiked: isLiked,
                onLike: () => onLike(idx), onDoctor: () => onDoctor(c.doctor));
            },
          ),
        ),
      ],
    );
  }
}

class _ConseilTile extends StatelessWidget {
  final _Conseil conseil;
  final bool dark, isLiked;
  final VoidCallback onLike, onDoctor;
  const _ConseilTile({required this.conseil, required this.dark, required this.isLiked,
    required this.onLike, required this.onDoctor});

  static Color _catColor(String c) => switch (c) {
    'Sport'    => const Color(0xFF4A6FA5),
    'Nutrition'=> const Color(0xFFB8860B),
    'Sommeil'  => const Color(0xFF8E7BA6),
    'Mental'   => const Color(0xFF5A8A6E),
    'Hormones' => const Color(0xFFC97B84),
    _          => const Color(0xFF1C4D30),
  };
  static IconData _catIcon(String c) => switch (c) {
    'Sport'    => LucideIcons.dumbbell,
    'Nutrition'=> LucideIcons.salad,
    'Sommeil'  => LucideIcons.moon,
    'Mental'   => LucideIcons.brain,
    'Hormones' => LucideIcons.activity,
    _          => LucideIcons.sparkles,
  };

  @override
  Widget build(BuildContext context) {
    final doc   = conseil.doctor;
    final color = _catColor(conseil.category);
    final cardBg = Theme.of(context).colorScheme.surfaceContainerLow;
    final borderColor = Theme.of(context).colorScheme.outline;

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
        boxShadow: dark ? null : [
          BoxShadow(color: Colors.black.withOpacity(0.04),
            blurRadius: 12, offset: const Offset(0, 3)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: IntrinsicHeight(
          child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            // ── Colored left bar ──
            Container(width: 4, color: color),

            // ── Content ──
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                  // Top row: category pill + time
                  Row(children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20)),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(_catIcon(conseil.category), size: 11, color: color),
                        const SizedBox(width: 4),
                        Text(conseil.category, style: GoogleFonts.inter(
                          fontSize: 11, fontWeight: FontWeight.w700, color: color)),
                      ]),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(20)),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(LucideIcons.clock, size: 10, color: _T.t3(context)),
                        const SizedBox(width: 3),
                        Text('${conseil.readMin} min', style: GoogleFonts.inter(
                          fontSize: 11, color: _T.t2(context))),
                      ]),
                    ),
                    const Spacer(),
                    Text(conseil.postedAgo, style: GoogleFonts.inter(
                      fontSize: 11, color: _T.t3(context))),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: onLike,
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(isLiked ? LucideIcons.heartHandshake : LucideIcons.heart,
                          size: 14, color: isLiked ? const Color(0xFFE53935) : _T.t3(context)),
                        const SizedBox(width: 4),
                        Text('${conseil.likes + (isLiked ? 1 : 0)}',
                          style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600,
                            color: isLiked ? const Color(0xFFE53935) : _T.t2(context))),
                      ]),
                    ),
                  ]),

                  const SizedBox(height: 12),

                  // Title
                  Text(conseil.title, style: GoogleFonts.outfit(
                    fontSize: 16, fontWeight: FontWeight.w700,
                    color: _T.t1(context), height: 1.3)),

                  const SizedBox(height: 7),

                  // Body
                  Text(conseil.body, style: GoogleFonts.inter(
                    fontSize: 13.5, color: _T.t2(context), height: 1.6),
                    maxLines: 3, overflow: TextOverflow.ellipsis),

                  const SizedBox(height: 14),

                  // Footer: doctor only (le like a été déplacé en haut avec la date)
                  GestureDetector(
                    onTap: onDoctor,
                    child: Row(children: [
                      _Ava(initials: doc.initials, color: doc.color, size: 28, photoAsset: doc.photoAsset),
                      const SizedBox(width: 8),
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(doc.name, style: GoogleFonts.inter(
                          fontSize: 12, fontWeight: FontWeight.w600, color: _T.t1(context))),
                        Text(doc.specialty, style: GoogleFonts.inter(
                          fontSize: 11, color: _T.t2(context))),
                      ]),
                    ]),
                  ),
                ]),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

// ─── Tab 2 · Ressources ───────────────────────────────────────────────────────

class _RessourcesTab extends StatelessWidget {
  final bool dark;
  final String lex;
  final AppL10n l10n;
  final List<_Article> articles;
  final List<_VideoSeries> videoSeries;
  final ValueChanged<String> onLex;
  final ValueChanged<_Article>? onArticleTap;
  const _RessourcesTab({required this.dark, required this.lex, required this.l10n,
    required this.articles, required this.videoSeries, required this.onLex, this.onArticleTap});

  List<_LexiqueEntry> get _lexFiltered {
    if (lex.isEmpty) return _lexique;
    final q = lex.toLowerCase();
    return _lexique.where((e) =>
      e.term.toLowerCase().contains(q) || e.definition.toLowerCase().contains(q)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 110),
      children: [
        // ── Section header: Séries vidéo ──
        const SizedBox(height: 24),
        _SectionHeader(title: l10n.santeSeriesSection, icon: LucideIcons.playCircle,
          subtitle: l10n.santeSeriesCount(videoSeries.length), dark: dark),
        const SizedBox(height: 16),
        SizedBox(
          height: 230,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemCount: videoSeries.length,
            itemBuilder: (ctx, i) {
              final s = videoSeries[i];
              return Padding(
                padding: EdgeInsets.only(right: i < videoSeries.length - 1 ? 14 : 0),
                child: GestureDetector(
                  onTap: () => showModalBottomSheet(
                    context: ctx, isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => _SeriesSheet(series: s, dark: dark)),
                  child: _SeriesCard(series: s, dark: dark, l10n: l10n),
                ),
              );
            },
          ),
        ),

        // ── Section header: Articles ──
        const SizedBox(height: 32),
        _SectionHeader(title: l10n.santeArticlesSection, icon: LucideIcons.bookOpen,
          subtitle: l10n.santeArticlesCount(articles.length), dark: dark),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: articles.asMap().entries.map((e) =>
              Padding(
                padding: EdgeInsets.only(bottom: e.key < articles.length - 1 ? 10 : 0),
                child: GestureDetector(
                  onTap: () => onArticleTap?.call(e.value),
                  child: _ArticleCard(article: e.value, dark: dark),
                ),
              )
            ).toList(),
          ),
        ),

        // ── Section header: Lexique ──
        const SizedBox(height: 32),
        _SectionHeader(title: l10n.santeLexiqueSection, icon: LucideIcons.microscope,
          subtitle: l10n.santeLexiqueSubtitle, dark: dark),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            decoration: BoxDecoration(
              color: dark ? const Color(0xFF1A1A1A) : const Color(0xFFF8F8F8),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _T.border(context))),
            child: TextField(
              onChanged: onLex,
              style: GoogleFonts.inter(fontSize: 14, color: _T.t1(context)),
              decoration: InputDecoration(
                hintText: l10n.santeLexiqueHint,
                hintStyle: GoogleFonts.inter(fontSize: 14, color: _T.t3(context)),
                prefixIcon: Icon(LucideIcons.search, size: 16, color: _T.t3(context)),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 14)),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: _lexFiltered.asMap().entries.map((e) =>
              Padding(
                padding: EdgeInsets.only(bottom: e.key < _lexFiltered.length - 1 ? 8 : 0),
                child: _LexCard(entry: e.value, dark: dark),
              )
            ).toList(),
          ),
        ),
      ],
    );
  }
}

// ── Section header widget ──────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title, subtitle; final IconData icon; final bool dark;
  const _SectionHeader({required this.title, required this.subtitle,
    required this.icon, required this.dark});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Row(children: [
      Container(
        width: 36, height: 36,
        decoration: BoxDecoration(
          color: _T.accent(context).withOpacity(0.10),
          borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, size: 16, color: _T.accent(context)),
      ),
      const SizedBox(width: 10),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: GoogleFonts.outfit(
          fontSize: 17, fontWeight: FontWeight.w700, color: _T.t1(context))),
        Text(subtitle, style: GoogleFonts.inter(fontSize: 12, color: _T.t2(context))),
      ]),
    ]),
  );
}

// ── Series card ───────────────────────────────────────────────────────────────
class _SeriesCard extends StatelessWidget {
  final _VideoSeries series; final bool dark; final AppL10n l10n;
  const _SeriesCard({required this.series, required this.dark, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final doc = series.doctor;
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: SizedBox(
        width: 180,
        child: Stack(fit: StackFit.expand, children: [
          // Background photo or color
          if (series.coverAsset != null)
            Image.asset(series.coverAsset!, fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(color: series.color))
          else
            Container(color: series.color),

          // Gradient overlay
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter, end: Alignment.bottomCenter,
                stops: const [0.0, 0.4, 1.0],
                colors: [
                  Colors.black.withOpacity(0.08),
                  Colors.black.withOpacity(0.25),
                  Colors.black.withOpacity(0.88),
                ],
              ),
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Top row: specialty pill + episode count badge
              Row(children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: series.color,
                    borderRadius: BorderRadius.circular(20)),
                  child: Text(doc.specialty, style: GoogleFonts.inter(
                    color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700)),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.35),
                    borderRadius: BorderRadius.circular(20)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(LucideIcons.play, size: 9, color: Colors.white),
                    const SizedBox(width: 4),
                    Text('${series.episodes.length}', style: GoogleFonts.inter(
                      color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600)),
                  ]),
                ),
              ]),
              const Spacer(),

              // Doctor avatar + name row
              Row(children: [
                _Ava(initials: doc.initials, color: doc.color, size: 26, photoAsset: doc.photoAsset),
                const SizedBox(width: 6),
                Expanded(child: Text(doc.name, style: GoogleFonts.inter(
                  color: Colors.white.withOpacity(0.8), fontSize: 10,
                  fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis)),
              ]),
              const SizedBox(height: 8),

              // Title
              Text(series.title, style: GoogleFonts.outfit(
                color: Colors.white, fontSize: 15,
                fontWeight: FontWeight.w800, height: 1.2),
                maxLines: 2, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 10),

              // Watch button
              Container(
                height: 32,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(LucideIcons.play, size: 11, color: series.color),
                  const SizedBox(width: 6),
                  Text(l10n.santeWatch, style: GoogleFonts.inter(
                    fontSize: 12, fontWeight: FontWeight.w700, color: series.color)),
                ]),
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}

// ── Article card ──────────────────────────────────────────────────────────────
class _ArticleCard extends StatelessWidget {
  final _Article article; final bool dark;
  const _ArticleCard({required this.article, required this.dark});

  @override
  Widget build(BuildContext context) {
    final cardBg = Theme.of(context).colorScheme.surfaceContainerLow;
    final border = Theme.of(context).colorScheme.outline;
    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
        boxShadow: dark ? null : [
          BoxShadow(color: Colors.black.withOpacity(0.04),
            blurRadius: 10, offset: const Offset(0, 2)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Row(children: [
          // Thumbnail — photo or colored fallback
          SizedBox(
            width: 90, height: 100,
            child: Stack(fit: StackFit.expand, children: [
              if (article.photoAsset != null)
                Image.asset(article.photoAsset!, fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: article.color.withOpacity(dark ? 0.25 : 0.12),
                    child: Icon(LucideIcons.fileText, size: 28, color: article.color)))
              else
                Container(
                  color: article.color.withOpacity(dark ? 0.25 : 0.12),
                  child: Icon(LucideIcons.fileText, size: 28, color: article.color)),
              // read-time badge bottom-right
              Positioned(bottom: 6, right: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.55),
                    borderRadius: BorderRadius.circular(8)),
                  child: Text('${article.readMin} min', style: GoogleFonts.inter(
                    fontSize: 9, fontWeight: FontWeight.w700, color: Colors.white)),
                )),
            ]),
          ),
          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: article.color.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(12)),
                  child: Text(article.category, style: GoogleFonts.inter(
                    fontSize: 10, fontWeight: FontWeight.w700, color: article.color)),
                ),
                const SizedBox(height: 7),
                Text(article.title, style: GoogleFonts.outfit(
                  fontSize: 14, fontWeight: FontWeight.w700,
                  color: _T.t1(context), height: 1.3),
                  maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 5),
                Text(article.excerpt, style: GoogleFonts.inter(
                  fontSize: 12, color: _T.t2(context), height: 1.5),
                  maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 6),
                Text(article.author, style: GoogleFonts.inter(
                  fontSize: 11, color: _T.t3(context), fontWeight: FontWeight.w500)),
              ]),
            ),
          ),
          // Arrow
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Icon(LucideIcons.chevronRight, size: 16, color: _T.t3(context)),
          ),
        ]),
      ),
    );
  }
}

// ── Lex card ──────────────────────────────────────────────────────────────────
class _LexCard extends StatefulWidget {
  final _LexiqueEntry entry; final bool dark;
  const _LexCard({required this.entry, required this.dark});
  @override
  State<_LexCard> createState() => _LexCardState();
}

class _LexCardState extends State<_LexCard> {
  bool _open = false;
  @override
  Widget build(BuildContext context) {
    final dark = widget.dark;
    final e = widget.entry;
    final cardBg = Theme.of(context).colorScheme.surfaceContainerLow;
    final border = Theme.of(context).colorScheme.outline;
    return GestureDetector(
      onTap: () => setState(() => _open = !_open),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _open ? _T.accent(context) : border, width: _open ? 1.5 : 1),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(
                width: 28, height: 28,
                decoration: BoxDecoration(
                  color: _T.accent(context).withOpacity(0.10),
                  borderRadius: BorderRadius.circular(8)),
                child: Center(child: Text(e.term[0], style: GoogleFonts.outfit(
                  fontSize: 13, fontWeight: FontWeight.w800,
                  color: _T.accent(context)))),
              ),
              const SizedBox(width: 10),
              Expanded(child: Text(e.term, style: GoogleFonts.outfit(
                fontSize: 14, fontWeight: FontWeight.w700, color: _T.t1(context)))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(10)),
                child: Text(e.category, style: GoogleFonts.inter(
                  fontSize: 10, color: _T.t2(context))),
              ),
              const SizedBox(width: 6),
              AnimatedRotation(
                turns: _open ? 0.5 : 0,
                duration: const Duration(milliseconds: 200),
                child: Icon(LucideIcons.chevronDown, size: 16, color: _T.t3(context)),
              ),
            ]),
            if (_open) ...[
              const SizedBox(height: 10),
              Divider(height: 1, color: _T.border(context)),
              const SizedBox(height: 10),
              Text(e.definition, style: GoogleFonts.inter(
                fontSize: 13, color: _T.t2(context), height: 1.65)),
            ],
          ]),
        ),
      ),
    );
  }
}

// ─── Tab 4 · Médecins ─────────────────────────────────────────────────────────

class _DoctorsTab extends StatelessWidget {
  final bool dark;
  final String spec;
  final int? marker;
  final AppL10n l10n;
  final List<_Doctor> doctors;
  final ValueChanged<String> onSpec;
  final ValueChanged<int> onMarker;
  final ValueChanged<_Doctor> onDoctor;
  const _DoctorsTab({required this.dark, required this.spec, required this.marker,
    required this.l10n, required this.doctors, required this.onSpec,
    required this.onMarker, required this.onDoctor});

  List<int> get _indexes {
    if (spec == 'Toutes') return List.generate(doctors.length, (i) => i);
    return List.generate(doctors.length, (i) => i).where((i) =>
      doctors[i].specialty.toLowerCase().contains(
        spec.toLowerCase().replaceAll('é','e').replaceAll('ologie',''))).toList();
  }

  @override
  Widget build(BuildContext context) {
    final idx = _indexes;
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 110),
      children: [
        // Map
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: SizedBox(
            height: 240,
            child: GestureDetector(
              onTapUp: (d) {
                final box = context.findRenderObject() as RenderBox?;
                if (box == null) return;
                final mw = box.size.width - 48;
                final lp = d.localPosition;
                for (int i = 0; i < doctors.length; i++) {
                  final p = _doctorPositions[i < _doctorPositions.length ? i : 0];
                  final cx = p.x * mw; final cy = p.y * 240 + (i == 4 ? 18 : 0);
                  if ((lp.dx - cx).abs() < 22 && (lp.dy - cy).abs() < 22) {
                    onMarker(i); return;
                  }
                }
                onMarker(-1);
              },
              child: CustomPaint(
                painter: _MapPainter(dark: dark, marker: marker, indexes: idx, doctors: doctors),
                child: Stack(children: [
                  Positioned(top: 12, left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: (dark ? const Color(0xFF1A1A1A) : Colors.white).withOpacity(0.92),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: _T.border(context))),
                      child: Text(l10n.santeSpecialistsCount(doctors.length),
                        style: GoogleFonts.inter(fontSize: 11, color: _T.t2(context))))),
                  if (marker != null && marker! >= 0 && marker! < doctors.length)
                    _MapPopup(doctor: doctors[marker!],
                      pos: _doctorPositions[marker! < _doctorPositions.length ? marker! : 0],
                      idx: marker!, dark: dark,
                      onTap: () => onDoctor(doctors[marker!])),
                ]),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        // Spec filter
        SizedBox(
          height: 32,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _specs.length,
            separatorBuilder: (_, __) => const SizedBox(width: 6),
            itemBuilder: (_, i) {
              final s = _specs[i]; final active = s == spec;
              return GestureDetector(
                onTap: () => onSpec(s),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: active ? _T.accent(context) : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: active ? _T.accent(context) : _T.border(context))),
                  child: Text(s, style: GoogleFonts.inter(fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: active ? _T.onAccent(context) : _T.t2(context))),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 20),
        ...idx.map((i) {
          final doc = doctors[i]; final sel = marker == i;
          return Padding(
            padding: const EdgeInsets.only(bottom: 1),
            child: GestureDetector(
              onTap: () => onDoctor(doc),
              child: Column(children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Row(children: [
                    _Ava(initials: doc.initials, color: doc.color, size: 46,
                      bordered: sel, photoAsset: doc.photoAsset),
                    const SizedBox(width: 14),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(doc.name, style: GoogleFonts.inter(
                        fontSize: 14, fontWeight: FontWeight.w600, color: _T.t1(context))),
                      const SizedBox(height: 2),
                      Text(doc.specialty, style: GoogleFonts.inter(
                        fontSize: 13, color: _T.t2(context))),
                      const SizedBox(height: 4),
                      Row(children: [
                        Icon(LucideIcons.mapPin, size: 11, color: _T.t3(context)),
                        const SizedBox(width: 3),
                        Text(doc.location, style: GoogleFonts.inter(fontSize: 12, color: _T.t3(context))),
                        const SizedBox(width: 10),
                        Icon(LucideIcons.star, size: 11, color: const Color(0xFFF59E0B)),
                        const SizedBox(width: 3),
                        Text('${doc.rating}', style: GoogleFonts.inter(
                          fontSize: 12, color: _T.t3(context))),
                      ]),
                    ])),
                    Icon(LucideIcons.chevronRight, size: 16, color: _T.t3(context)),
                  ]),
                ),
                Divider(height: 1, color: _T.border(context)),
              ]),
            ),
          );
        }),
      ],
    );
  }
}

class _MapPainter extends CustomPainter {
  final bool dark; final int? marker; final List<int> indexes; final List<_Doctor> doctors;
  _MapPainter({required this.dark, required this.marker, required this.indexes, required this.doctors});

  @override
  void paint(Canvas c, Size s) {
    final w = s.width; final h = s.height;
    c.drawRect(Rect.fromLTWH(0,0,w,h),
      Paint()..color = dark ? const Color(0xFF0F180F) : const Color(0xFFEDF7F0));
    final land = Paint()..color = dark ? const Color(0xFF1A3020) : const Color(0xFFCCE8D5);
    final border = Paint()..color = dark ? const Color(0xFF2E5040) : const Color(0xFF3DA85A)
      ..style = PaintingStyle.stroke ..strokeWidth = 1.2;
    final path = Path();
    final pts = [(0.38,.05),(0.48,.04),(0.56,.08),(0.64,.06),(0.70,.10),(0.72,.16),
      (0.68,.22),(0.72,.28),(0.74,.35),(0.70,.42),(0.66,.48),(0.68,.55),(0.65,.62),
      (0.60,.68),(0.58,.76),(0.55,.84),(0.52,.90),(0.48,.95),(0.42,.97),(0.36,.94),
      (0.30,.88),(0.26,.80),(0.24,.72),(0.22,.62),(0.20,.52),(0.22,.44),(0.26,.36),
      (0.28,.28),(0.30,.20),(0.32,.13),(0.36,.07),(0.38,.05)];
    path.moveTo(pts[0].$1*w, pts[0].$2*h);
    for (final p in pts.skip(1)) path.lineTo(p.$1*w, p.$2*h);
    path.close();
    c.drawPath(path, land); c.drawPath(path, border);
    for (int i = 0; i < doctors.length && i < _doctorPositions.length; i++) {
      final p = _doctorPositions[i];
      final cx = p.x*w; final cy = p.y*h+(i==4?20:i==3?-18:0);
      final sel = marker==i; final filt = indexes.contains(i);
      final col = doctors[i].color;
      if (sel) c.drawCircle(Offset(cx,cy), 20, Paint()..color=col.withOpacity(0.15));
      c.drawCircle(Offset(cx,cy), sel?15:10, Paint()..color=col.withOpacity(filt?1:.2));
      c.drawCircle(Offset(cx,cy), sel?15:10, Paint()
        ..color=Colors.white.withOpacity(sel ? 0.85 : 0.5)
        ..style=PaintingStyle.stroke ..strokeWidth=sel?2:1.5);
      c.drawCircle(Offset(cx,cy), sel?5:3, Paint()..color=Colors.white);
    }
  }

  @override
  bool shouldRepaint(_MapPainter old) =>
    old.marker != marker || old.dark != dark || old.indexes.length != indexes.length
    || old.doctors.length != doctors.length;
}

class _MapPopup extends StatelessWidget {
  final _Doctor doctor;
  final ({double x, double y}) pos;
  final int idx; final bool dark; final VoidCallback onTap;
  const _MapPopup({required this.doctor, required this.pos, required this.idx,
    required this.dark, required this.onTap});

  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (_, c) {
    final cx = pos.x * c.maxWidth;
    final cy = pos.y * 240.0 + (idx==4?20:idx==3?-18:0);
    const pw = 170.0;
    final left = (cx - pw/2).clamp(8.0, c.maxWidth - pw - 8);
    final top  = (cy - 85).clamp(8.0, 160.0);
    return Positioned(left: left, top: top,
      child: GestureDetector(onTap: onTap,
        child: Container(width: pw, padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: dark ? const Color(0xFF1A1A1A) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _T.border(context)),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 14, offset: const Offset(0,4))]),
          child: Row(children: [
            _Ava(initials: doctor.initials, color: doctor.color, size: 32, photoAsset: doctor.photoAsset),
            const SizedBox(width: 8),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(doctor.name, style: GoogleFonts.inter(fontSize: 11,
                fontWeight: FontWeight.w600, color: _T.t1(context)),
                maxLines: 1, overflow: TextOverflow.ellipsis),
              Text(doctor.specialty, style: GoogleFonts.inter(fontSize: 10, color: _T.t2(context))),
            ])),
          ]),
        ),
      ),
    );
  });
}

// ─── Tab 5 · Carnet ───────────────────────────────────────────────────────────


// ─── Doctor sheet ─────────────────────────────────────────────────────────────

class _DoctorSheet extends StatelessWidget {
  final _Doctor doctor; final bool dark; final AppL10n l10n;
  const _DoctorSheet({required this.doctor, required this.dark, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _T.card(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom + 24),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const SizedBox(height: 12),
        Container(width: 36, height: 4, decoration: BoxDecoration(
          color: _T.border(context), borderRadius: BorderRadius.circular(2))),
        const SizedBox(height: 28),
        _Ava(initials: doctor.initials, color: doctor.color, size: 70, photoAsset: doctor.photoAsset),
        const SizedBox(height: 14),
        Text(doctor.name, style: GoogleFonts.outfit(
          fontSize: 20, fontWeight: FontWeight.w800, color: _T.t1(context))),
        const SizedBox(height: 4),
        Text(doctor.specialty, style: GoogleFonts.inter(fontSize: 14, color: _T.t2(context))),
        const SizedBox(height: 8),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(LucideIcons.star, size: 13, color: const Color(0xFFF59E0B)),
          const SizedBox(width: 4),
          Text('${doctor.rating}', style: GoogleFonts.inter(
            fontSize: 13, fontWeight: FontWeight.w600, color: _T.t1(context))),
          const SizedBox(width: 12),
          Text('·', style: GoogleFonts.inter(color: _T.t3(context))),
          const SizedBox(width: 12),
          Text(l10n.santeConsultationsCount(doctor.consultations), style: GoogleFonts.inter(
            fontSize: 13, color: _T.t2(context))),
        ]),
        const SizedBox(height: 28),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(children: [
            _InfoRow2(icon: LucideIcons.building2, label: doctor.hospital, dark: dark),
            _InfoRow2(icon: LucideIcons.mapPin, label: doctor.location, dark: dark),
            _InfoRow2(icon: LucideIcons.phone, label: doctor.phone, dark: dark),
            _InfoRow2(icon: LucideIcons.mail, label: doctor.email, dark: dark),
            const SizedBox(height: 20),
            Row(children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      border: Border.all(color: _T.border(context)),
                      borderRadius: BorderRadius.circular(14)),
                    child: Center(child: Text(l10n.santeCall, style: GoogleFonts.inter(
                      fontSize: 14, fontWeight: FontWeight.w600, color: _T.t1(context)))))),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: _T.t1(context), borderRadius: BorderRadius.circular(14)),
                    child: Center(child: Text(l10n.santeAppointment, style: GoogleFonts.inter(
                      fontSize: 14, fontWeight: FontWeight.w600, color: _T.card(context)))))),
              ),
            ]),
          ]),
        ),
      ]),
    );
  }
}

// ─── Series sheet ─────────────────────────────────────────────────────────────

class _SeriesSheet extends ConsumerWidget {
  final _VideoSeries series; final bool dark;
  const _SeriesSheet({required this.series, required this.dark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(l10nProvider);
    final bg = dark ? const Color(0xFF111111) : Colors.white;
    final doc = series.doctor;
    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28))),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const SizedBox(height: 10),
        Container(width: 40, height: 4, decoration: BoxDecoration(
          color: dark ? const Color(0xFF333333) : const Color(0xFFDDDDDD),
          borderRadius: BorderRadius.circular(2))),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: SizedBox(
              height: 160, width: double.infinity,
              child: Stack(fit: StackFit.expand, children: [
                if (series.coverAsset != null)
                  Image.asset(series.coverAsset!, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(color: series.color))
                else
                  Container(color: series.color),
                DecoratedBox(decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter, end: Alignment.bottomCenter,
                    colors: [Colors.black.withOpacity(0.1), Colors.black.withOpacity(0.75)]))),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: series.color, borderRadius: BorderRadius.circular(20)),
                      child: Text(doc.specialty, style: GoogleFonts.inter(
                        color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                    ),
                    const Spacer(),
                    Text(series.title, style: GoogleFonts.outfit(
                      color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800, height: 1.2)),
                    const SizedBox(height: 10),
                    Row(children: [
                      _Ava(initials: doc.initials, color: doc.color, size: 28, photoAsset: doc.photoAsset),
                      const SizedBox(width: 8),
                      Text(doc.name, style: GoogleFonts.inter(
                        color: Colors.white.withOpacity(0.85), fontSize: 12, fontWeight: FontWeight.w500)),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.35),
                          borderRadius: BorderRadius.circular(20)),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          const Icon(LucideIcons.play, size: 10, color: Colors.white),
                          const SizedBox(width: 5),
                          Text(l10n.santeEpisodes(series.episodes.length), style: GoogleFonts.inter(
                            color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                        ]),
                      ),
                    ]),
                  ]),
                ),
              ]),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Flexible(
          child: ListView.builder(
            shrinkWrap: true,
            padding: EdgeInsets.fromLTRB(20, 0, 20, MediaQuery.of(context).padding.bottom + 24),
            itemCount: series.episodes.length,
            itemBuilder: (ctx, i) {
              final ep = series.episodes[i];
              final isFirst = i == 0;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(
                      builder: (_) => _PlayerPage(episode: ep, series: series)));
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isFirst
                        ? series.color.withOpacity(dark ? 0.18 : 0.08)
                        : (dark ? const Color(0xFF1A1A1A) : const Color(0xFFF8F8F8)),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isFirst ? series.color.withOpacity(0.4) : _T.border(context),
                        width: isFirst ? 1.5 : 1)),
                    padding: const EdgeInsets.all(14),
                    child: Row(children: [
                      Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(
                          color: isFirst ? series.color : series.color.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12)),
                        child: Center(child: Text('${ep.episode}'.padLeft(2, '0'),
                          style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w800,
                            color: isFirst ? Colors.white : series.color))),
                      ),
                      const SizedBox(width: 14),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(ep.title, style: GoogleFonts.inter(
                          fontSize: 13, fontWeight: FontWeight.w600,
                          color: _T.t1(context), height: 1.35),
                          maxLines: 2, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 5),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(8)),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            Icon(LucideIcons.clock3, size: 10, color: _T.t3(context)),
                            const SizedBox(width: 4),
                            Text(ep.duration, style: GoogleFonts.inter(
                              fontSize: 11, color: _T.t2(context), fontWeight: FontWeight.w500)),
                          ]),
                        ),
                      ])),
                      const SizedBox(width: 12),
                      Container(
                        width: 34, height: 34,
                        decoration: BoxDecoration(
                          color: series.color.withOpacity(isFirst ? 1 : 0.12),
                          shape: BoxShape.circle),
                        child: Icon(LucideIcons.play, size: 14,
                          color: isFirst ? Colors.white : series.color),
                      ),
                    ]),
                  ),
                ),
              );
            },
          ),
        ),
      ]),
    );
  }
}

// ─── Video player page ────────────────────────────────────────────────────────

class _PlayerPage extends ConsumerStatefulWidget {
  final _VideoEpisode episode; final _VideoSeries series;
  const _PlayerPage({required this.episode, required this.series});
  @override
  ConsumerState<_PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends ConsumerState<_PlayerPage> {
  late VideoPlayerController _vpc;
  ChewieController? _chewie;
  bool _liked = false;

  @override
  void initState() {
    super.initState();
    final src = widget.episode.asset;
    _vpc = src.startsWith('http://') || src.startsWith('https://')
        ? VideoPlayerController.networkUrl(Uri.parse(src))
        : VideoPlayerController.asset(src);
    _vpc.initialize().then((_) {
      _chewie = ChewieController(
        videoPlayerController: _vpc,
        autoPlay: true,
        looping: false,
        aspectRatio: _vpc.value.aspectRatio,
        allowFullScreen: true,
        showControls: true,
        materialProgressColors: ChewieProgressColors(
          playedColor: widget.series.color,
          handleColor: widget.series.color,
          bufferedColor: Colors.white30,
          backgroundColor: Colors.white12,
        ),
      );
      setState(() {});
    });
  }

  @override
  void dispose() {
    _vpc.dispose();
    _chewie?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final l10n = ref.watch(l10nProvider);
    final s = widget.series;
    final ep = widget.episode;
    final doc = s.doctor;
    final bg = dark ? const Color(0xFF0A0A0A) : const Color(0xFFF5F5F5);
    final cardBg = Theme.of(context).colorScheme.surfaceContainerLow;

    // other episodes excluding current
    final others = s.episodes.where((e) => e.episode != ep.episode).toList();

    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(children: [
        // ── Video player (black zone) ──────────────────────────────────────
        Container(
          color: Colors.black,
          child: SafeArea(
            bottom: false,
            child: Column(children: [
              // back button row
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
                child: Row(children: [
                  IconButton(
                    icon: const Icon(LucideIcons.chevronDown, color: Colors.white, size: 22),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: s.color, borderRadius: BorderRadius.circular(20)),
                    child: Text(doc.specialty, style: GoogleFonts.inter(
                      color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700)),
                  ),
                  const SizedBox(width: 12),
                ]),
              ),
              // player
              AspectRatio(
                aspectRatio: 16 / 9,
                child: _chewie != null
                  ? Chewie(controller: _chewie!)
                  : Center(child: CircularProgressIndicator(color: s.color)),
              ),
            ]),
          ),
        ),

        // ── Scrollable content (below player) ─────────────────────────────
        Expanded(
          child: Container(
            color: bg,
            child: SingleChildScrollView(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom + 24),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                // ── Episode info card ──
                Container(
                  color: cardBg,
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    // episode number + series name pill
                    Row(children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                        decoration: BoxDecoration(
                          color: s.color.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10)),
                        child: Text(l10n.santeEpisode(ep.episode), style: GoogleFonts.inter(
                          color: s.color, fontSize: 11, fontWeight: FontWeight.w700)),
                      ),
                      const SizedBox(width: 8),
                      Expanded(child: Text(s.title, style: GoogleFonts.inter(
                        fontSize: 11, color: _T.t3(context)), overflow: TextOverflow.ellipsis)),
                      // duration pill
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.outline,
                          borderRadius: BorderRadius.circular(10)),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Icon(LucideIcons.clock3, size: 10, color: _T.t3(context)),
                          const SizedBox(width: 4),
                          Text(ep.duration, style: GoogleFonts.inter(
                            fontSize: 11, color: _T.t2(context), fontWeight: FontWeight.w500)),
                        ]),
                      ),
                    ]),
                    const SizedBox(height: 12),

                    // episode title
                    Text(ep.title, style: GoogleFonts.outfit(
                      fontSize: 18, fontWeight: FontWeight.w800,
                      color: _T.t1(context), height: 1.25)),
                    const SizedBox(height: 16),

                    // action row: like + share
                    Row(children: [
                      GestureDetector(
                        onTap: () => setState(() => _liked = !_liked),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: _liked ? s.color.withOpacity(0.12) : (Theme.of(context).colorScheme.surfaceContainerHighest),
                            borderRadius: BorderRadius.circular(20),
                            border: _liked ? Border.all(color: s.color.withOpacity(0.4)) : null),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            Icon(LucideIcons.heart, size: 15,
                              color: _liked ? s.color : _T.t2(context)),
                            const SizedBox(width: 6),
                            Text(l10n.santeLike, style: GoogleFonts.inter(
                              fontSize: 13, fontWeight: FontWeight.w600,
                              color: _liked ? s.color : _T.t2(context))),
                          ]),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(20)),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Icon(LucideIcons.share2, size: 15, color: _T.t2(context)),
                          const SizedBox(width: 6),
                          Text(l10n.santeShare, style: GoogleFonts.inter(
                            fontSize: 13, fontWeight: FontWeight.w600, color: _T.t2(context))),
                        ]),
                      ),
                    ]),

                    const SizedBox(height: 16),
                    Divider(height: 1, color: _T.border(context)),
                    const SizedBox(height: 16),

                    // doctor row
                    Row(children: [
                      _Ava(initials: doc.initials, color: doc.color,
                        size: 44, bordered: true, photoAsset: doc.photoAsset),
                      const SizedBox(width: 12),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(doc.name, style: GoogleFonts.outfit(
                          fontSize: 15, fontWeight: FontWeight.w700, color: _T.t1(context))),
                        Text(doc.specialty, style: GoogleFonts.inter(
                          fontSize: 12, color: _T.t2(context))),
                      ])),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: s.color, borderRadius: BorderRadius.circular(20)),
                        child: Text(l10n.santeFollow, style: GoogleFonts.inter(
                          fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
                      ),
                    ]),
                  ]),
                ),

                // ── Dans cette série ──
                if (others.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                    child: Text(l10n.santeDansCetteSerie, style: GoogleFonts.outfit(
                      fontSize: 16, fontWeight: FontWeight.w700, color: _T.t1(context))),
                  ),
                  ...others.map((other) => Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(context, MaterialPageRoute(
                          builder: (_) => _PlayerPage(episode: other, series: s)));
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: _T.border(context))),
                        padding: const EdgeInsets.all(12),
                        child: Row(children: [
                          // thumbnail with play overlay
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: SizedBox(
                              width: 90, height: 58,
                              child: Stack(fit: StackFit.expand, children: [
                                s.coverAsset != null
                                  ? Image.asset(s.coverAsset!, fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(color: s.color))
                                  : Container(color: s.color),
                                DecoratedBox(decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.3))),
                                Center(child: Container(
                                  width: 28, height: 28,
                                  decoration: const BoxDecoration(
                                    color: Colors.white, shape: BoxShape.circle),
                                  child: Icon(LucideIcons.play, size: 12, color: s.color),
                                )),
                                Positioned(bottom: 4, right: 4,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.7),
                                      borderRadius: BorderRadius.circular(4)),
                                    child: Text(other.duration, style: GoogleFonts.inter(
                                      color: Colors.white, fontSize: 9, fontWeight: FontWeight.w600)),
                                  )),
                              ]),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: s.color.withOpacity(0.10),
                                borderRadius: BorderRadius.circular(8)),
                              child: Text(l10n.santeEpShort(other.episode), style: GoogleFonts.inter(
                                fontSize: 10, fontWeight: FontWeight.w700, color: s.color)),
                            ),
                            const SizedBox(height: 5),
                            Text(other.title, style: GoogleFonts.inter(
                              fontSize: 13, fontWeight: FontWeight.w600,
                              color: _T.t1(context), height: 1.3),
                              maxLines: 2, overflow: TextOverflow.ellipsis),
                          ])),
                        ]),
                      ),
                    ),
                  )),
                ],
              ]),
            ),
          ),
        ),
      ]),
    );
  }
}

// ─── Shared ───────────────────────────────────────────────────────────────────

class _Ava extends StatelessWidget {
  final String initials; final Color color; final double size; final bool bordered;
  final String? photoAsset;
  const _Ava({required this.initials, required this.color, required this.size,
    this.bordered = false, this.photoAsset});

  @override
  Widget build(BuildContext context) {
    final border = bordered ? Border.all(color: color, width: 2.5) : null;
    if (photoAsset != null) {
      return Container(
        width: size, height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, border: border),
        child: ClipOval(child: Image.asset(photoAsset!, fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _fallback(border))),
      );
    }
    return _fallback(border);
  }

  Widget _fallback(Border? border) => Container(
    width: size, height: size,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle, border: border),
    child: Center(child: Text(initials, style: GoogleFonts.outfit(
      color: Colors.white, fontSize: size * 0.33, fontWeight: FontWeight.w700))),
  );
}

class _Label extends StatelessWidget {
  final String text; final bool dark;
  const _Label({required this.text, required this.dark});
  @override
  Widget build(BuildContext context) => Text(text, style: GoogleFonts.outfit(
    fontSize: 20, fontWeight: FontWeight.w700, color: _T.t1(context), letterSpacing: -0.3));
}

class _InfoRow2 extends StatelessWidget {
  final IconData icon; final String label; final bool dark;
  const _InfoRow2({required this.icon, required this.label, required this.dark});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(children: [
      Icon(icon, size: 15, color: _T.t3(context)),
      const SizedBox(width: 12),
      Flexible(child: Text(label, style: GoogleFonts.inter(fontSize: 14, color: _T.t1(context)))),
    ]),
  );
}

class _InputBox extends StatelessWidget {
  final TextEditingController ctrl; final String label, hint; final IconData icon; final bool dark;
  const _InputBox({required this.ctrl, required this.label, required this.hint,
    required this.icon, required this.dark});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
    decoration: BoxDecoration(
      color: _T.card(context), borderRadius: BorderRadius.circular(14),
      border: Border.all(color: _T.border(context))),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Icon(icon, size: 12, color: _T.t3(context)),
        const SizedBox(width: 5),
        Text(label, style: GoogleFonts.inter(fontSize: 11, color: _T.t3(context))),
      ]),
      const SizedBox(height: 4),
      TextField(controller: ctrl,
        style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: _T.t1(context)),
        decoration: InputDecoration(
          hintText: hint, hintStyle: GoogleFonts.inter(
            fontSize: 16, color: _T.t3(context), fontWeight: FontWeight.w400),
          border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.zero)),
    ]),
  );
}

// ─── Article Detail Screen ───────────────────────────────────────────────────

class _ArticleDetailScreen extends StatefulWidget {
  final _Article article;
  const _ArticleDetailScreen({required this.article});
  @override
  State<_ArticleDetailScreen> createState() => _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends State<_ArticleDetailScreen> {
  final _scrollController = ScrollController();
  double _progress = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final max = _scrollController.position.maxScrollExtent;
    if (max <= 0) return;
    setState(() => _progress = (_scrollController.offset / max).clamp(0.0, 1.0));
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.article;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final top = MediaQuery.of(context).padding.top;
    final bot = MediaQuery.of(context).padding.bottom;
    final bg = dark ? const Color(0xFF0A0A0A) : Colors.white;

    final paragraphs = a.body.split('\n\n').where((p) => p.trim().isNotEmpty).toList();

    return Scaffold(
      backgroundColor: bg,
      body: Stack(children: [
        CustomScrollView(
          controller: _scrollController,
          slivers: [
            // ── Hero image with overlay ──
            SliverToBoxAdapter(
              child: Stack(children: [
                SizedBox(
                  width: double.infinity,
                  height: 300,
                  child: a.photoAsset != null
                    ? Image.asset(a.photoAsset!, fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _coloredFallback(a, dark))
                    : _coloredFallback(a, dark),
                ),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter, end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.15),
                          Colors.black.withOpacity(0.02),
                          bg.withOpacity(0.6),
                          bg,
                        ],
                        stops: const [0.0, 0.35, 0.8, 1.0],
                      ),
                    ),
                  ),
                ),
              ]),
            ),

            // ── Title block ──
            SliverToBoxAdapter(
              child: Transform.translate(
                offset: const Offset(0, -32),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    // Category pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: a.color,
                        borderRadius: BorderRadius.circular(20)),
                      child: Text(a.category, style: GoogleFonts.inter(
                        fontSize: 11, fontWeight: FontWeight.w700,
                        color: Colors.white, letterSpacing: 0.3)),
                    ),
                    const SizedBox(height: 16),
                    // Title
                    Text(a.title, style: GoogleFonts.outfit(
                      fontSize: 26, fontWeight: FontWeight.w800,
                      color: _T.t1(context), height: 1.2, letterSpacing: -0.5)),
                    const SizedBox(height: 16),
                    // Excerpt / lede
                    Text(a.excerpt, style: GoogleFonts.inter(
                      fontSize: 15, fontWeight: FontWeight.w400,
                      color: _T.t2(context), height: 1.55)),
                    const SizedBox(height: 20),
                    // Author row
                    Row(children: [
                      Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(
                          color: a.color.withOpacity(dark ? 0.25 : 0.10),
                          borderRadius: BorderRadius.circular(12)),
                        child: Center(
                          child: Text(
                            a.author.split(' ').last[0].toUpperCase(),
                            style: GoogleFonts.outfit(
                              fontSize: 16, fontWeight: FontWeight.w700, color: a.color)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(a.author, style: GoogleFonts.inter(
                            fontSize: 13, fontWeight: FontWeight.w600,
                            color: _T.t1(context))),
                          const SizedBox(height: 2),
                          Row(children: [
                            Icon(LucideIcons.clock, size: 11,
                              color: _T.t2(context)),
                            const SizedBox(width: 4),
                            Text('${a.readMin} min de lecture', style: GoogleFonts.inter(
                              fontSize: 11, color: _T.t2(context))),
                          ]),
                        ]),
                      ),
                      // Bookmark button
                      Container(
                        width: 38, height: 38,
                        decoration: BoxDecoration(
                          color: _T.t1(context).withOpacity(0.06),
                          borderRadius: BorderRadius.circular(12)),
                        child: Icon(LucideIcons.bookmark, size: 18,
                          color: _T.t2(context)),
                      ),
                    ]),
                    const SizedBox(height: 20),
                    // Thin accent divider
                    Container(
                      height: 3, width: 40,
                      decoration: BoxDecoration(
                        color: a.color,
                        borderRadius: BorderRadius.circular(2)),
                    ),
                  ]),
                ),
              ),
            ),

            // ── Body paragraphs ──
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(24, 0, 24, bot + 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: paragraphs.asMap().entries.map((entry) {
                    final text = entry.value.trim();
                    final isBullet = text.startsWith('•');
                    final isHeading = !isBullet
                        && text.length < 80
                        && !text.endsWith('.')
                        && !text.contains('•');

                    if (isBullet) {
                      final bullets = text.split('\n').where((l) => l.trim().isNotEmpty).toList();
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: a.color.withOpacity(dark ? 0.08 : 0.04),
                            borderRadius: BorderRadius.circular(14),
                            border: Border(left: BorderSide(
                              color: a.color.withOpacity(0.4), width: 3)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: bullets.map((b) {
                              final clean = b.replaceFirst('• ', '').trim();
                              return Padding(
                                padding: EdgeInsets.only(
                                  bottom: b != bullets.last ? 10 : 0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(top: 6),
                                      child: Container(
                                        width: 5, height: 5,
                                        decoration: BoxDecoration(
                                          color: a.color,
                                          shape: BoxShape.circle)),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(clean, style: GoogleFonts.inter(
                                        fontSize: 14, color: _T.t1(context),
                                        height: 1.6, fontWeight: FontWeight.w400)),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      );
                    }

                    if (isHeading) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8, bottom: 10),
                        child: Text(text, style: GoogleFonts.outfit(
                          fontSize: 18, fontWeight: FontWeight.w700,
                          color: _T.t1(context), height: 1.3)),
                      );
                    }

                    // Mixed paragraph (text + inline bullets)
                    if (text.contains('\n•')) {
                      final lines = text.split('\n');
                      final lead = <String>[];
                      final bullets = <String>[];
                      for (final line in lines) {
                        if (line.trimLeft().startsWith('•')) {
                          bullets.add(line.replaceFirst('•', '').trim());
                        } else {
                          if (bullets.isEmpty) {
                            lead.add(line);
                          }
                        }
                      }
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          if (lead.isNotEmpty) ...[
                            Text(lead.join('\n'), style: GoogleFonts.inter(
                              fontSize: 15, color: _T.t1(context),
                              height: 1.7, fontWeight: FontWeight.w400)),
                            const SizedBox(height: 12),
                          ],
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: a.color.withOpacity(dark ? 0.08 : 0.04),
                              borderRadius: BorderRadius.circular(14),
                              border: Border(left: BorderSide(
                                color: a.color.withOpacity(0.4), width: 3)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: bullets.map((b) => Padding(
                                padding: EdgeInsets.only(
                                  bottom: b != bullets.last ? 10 : 0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(top: 6),
                                      child: Container(
                                        width: 5, height: 5,
                                        decoration: BoxDecoration(
                                          color: a.color,
                                          shape: BoxShape.circle)),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(b, style: GoogleFonts.inter(
                                        fontSize: 14, color: _T.t1(context),
                                        height: 1.6, fontWeight: FontWeight.w400)),
                                    ),
                                  ],
                                ),
                              )).toList(),
                            ),
                          ),
                        ]),
                      );
                    }

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Text(text, style: GoogleFonts.inter(
                        fontSize: 15, color: _T.t1(context),
                        height: 1.7, fontWeight: FontWeight.w400)),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),

        // ── Top bar: back + share + progress ──
        Positioned(
          top: 0, left: 0, right: 0,
          child: Container(
            padding: EdgeInsets.fromLTRB(16, top + 8, 16, 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter, end: Alignment.bottomCenter,
                colors: [
                  bg.withOpacity(0.95),
                  bg.withOpacity(0.0),
                ]),
            ),
            child: Column(children: [
              Row(children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 38, height: 38,
                    decoration: BoxDecoration(
                      color: _T.t1(context).withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12)),
                    child: Icon(LucideIcons.chevronLeft,
                      size: 20, color: _T.t1(context)),
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  child: Container(
                    width: 38, height: 38,
                    decoration: BoxDecoration(
                      color: _T.t1(context).withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12)),
                    child: Icon(LucideIcons.share2,
                      size: 17, color: _T.t1(context)),
                  ),
                ),
              ]),
              const SizedBox(height: 8),
              // Reading progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: _progress,
                  minHeight: 2.5,
                  backgroundColor: _T.t1(context).withOpacity(0.06),
                  valueColor: AlwaysStoppedAnimation(a.color),
                ),
              ),
            ]),
          ),
        ),
      ]),
    );
  }

  Widget _coloredFallback(_Article a, bool dark) {
    return Container(
      color: a.color.withOpacity(dark ? 0.20 : 0.10),
      child: Center(child: Icon(LucideIcons.fileText,
        size: 48, color: a.color.withOpacity(0.5))),
    );
  }
}
