// ignore_for_file: deprecated_member_use


import 'package:chewie/chewie.dart';
import 'package:fiteva/widgets/shared_app_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:video_player/video_player.dart';

// ─── Tokens ───────────────────────────────────────────────────────────────────

class _T {
  // Light
  static const lBg      = Color.fromARGB(255, 255, 255, 255);
  static const lCard    = Color(0xFFFFFFFF);
  static const lBorder  = Color(0xFFF0F0F0);
  static const lT1      = Color(0xFF111111);
  static const lT2      = Color(0xFF888888);
  static const lT3      = Color(0xFFBBBBBB);
  static const lAccent  = Color(0xFF1C4D30);

  // Dark
  static const dBg      = Color(0xFF0C0C0C);
  static const dCard    = Color(0xFF161616);
  static const dBorder  = Color(0xFF242424);
  static const dT1      = Color(0xFFF5F5F5);
  static const dT2      = Color(0xFF888888);
  static const dT3      = Color(0xFF444444);
  static const dAccent  = Color(0xFF4ADE80);

  static Color bg(bool d)     => d ? dBg     : lBg;
  static Color card(bool d)   => d ? dCard   : lCard;
  static Color border(bool d) => d ? dBorder : lBorder;
  static Color t1(bool d)     => d ? dT1     : lT1;
  static Color t2(bool d)     => d ? dT2     : lT2;
  static Color t3(bool d)     => d ? dT3     : lT3;
  static Color accent(bool d) => d ? dAccent : lAccent;


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
  final String title, author, excerpt, category;
  final int readMin;
  final Color color;
  final String? photoAsset;
  const _Article({
    required this.title, required this.author, required this.excerpt,
    required this.category, required this.readMin, required this.color,
    this.photoAsset,
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
    photoAsset: 'assets/images/microbiomee.jpg'),
  _Article(title: 'Anxiété prémenstruelle : comprendre le PMDD', author: 'Dr. Leila Gharbi',
    excerpt: 'Le trouble dysphorique prémenstruel touche 3 à 8% des femmes et est souvent confondu avec une dépression.',
    category: 'Mental', readMin: 11, color: Color(0xFF0369A1),
    photoAsset: 'assets/images/pmdd.png'),
  _Article(title: 'Périménopause et sport : adapter sa pratique', author: 'Dr. Nadia Trabelsi',
    excerpt: 'La musculation devient essentielle pendant la périménopause pour préserver la densité osseuse et le métabolisme.',
    category: 'Sport', readMin: 9, color: Color(0xFF7C3AED),
    photoAsset: 'assets/images/perimenopause.png'),
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

final _videoSeries = [
  _VideoSeries(doctor: _doctors[3], title: 'Nutrition Féminine',
    color: const Color(0xFFB45309), coverAsset: 'assets/images/cover_nutrition.jpg', episodes: const [
      _VideoEpisode(episode: 1, title: 'Carences & SPM : ce que ton assiette dit de toi', duration: '4:32', asset: 'assets/videos/sante.mov'),
      _VideoEpisode(episode: 2, title: 'Carence en fer : reconnaître les signes', duration: '5:10', asset: 'assets/videos/sante.mov'),
      _VideoEpisode(episode: 3, title: 'Alimentation anti-inflammatoire', duration: '6:15', asset: 'assets/videos/sante.mov'),
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
  void initState() { super.initState(); _tab = TabController(length: 5, vsync: this); }
  @override
  void dispose() { _tab.dispose(); _wCtrl.dispose(); _bCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: _T.bg(dark),
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [
          SharedAppHeader.sliver(
            eyebrow: 'SANTÉ',
            title: 'Mon Espace Santé',
            accentColor: const Color(0xFF0D9488),
            bgColor: Colors.white,
          ),
       
          SliverToBoxAdapter(
            child: Container(
              color: _T.card(dark),
              child: TabBar(
                controller: _tab,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                labelPadding: const EdgeInsets.symmetric(horizontal: 8),
                labelStyle: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600),
                unselectedLabelStyle: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w400),
                labelColor: _T.t1(dark),
                unselectedLabelColor: _T.t3(dark),
                indicatorColor: const Color(0xFF0D9488),
                indicatorSize: TabBarIndicatorSize.label,
                indicatorWeight: 2,
                dividerColor: _T.border(dark),
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
              onDoctor: (d) => _sheet(context, _DoctorSheet(doctor: d, dark: dark))),
            _RessourcesTab(dark: dark, lex: _lex, onLex: (s) => setState(() => _lex = s)),
            _QRTab(dark: dark),
            _DoctorsTab(
              dark: dark, spec: _spec, marker: _marker,
              onSpec: (s) => setState(() => _spec = s),
              onMarker: (i) => setState(() => _marker = _marker == i ? null : i),
              onDoctor: (d) => _sheet(context, _DoctorSheet(doctor: d, dark: dark))),
            
            
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
    Text(label, style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w700, color: _T.t1(dark))),
    Text(sub, style: GoogleFonts.inter(fontSize: 10, color: _T.t2(dark))),
  ]));
}

class _Divider extends StatelessWidget {
  final bool dark;
  const _Divider({required this.dark});
  @override
  Widget build(BuildContext context) => Container(width: 1, height: 40, color: _T.border(dark));
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

  static Color _catColor(String c) => switch (c) {
    'Sport'    => const Color(0xFF2563EB),
    'Nutrition'=> const Color(0xFFD97706),
    'Sommeil'  => const Color(0xFF7C3AED),
    'Mental'   => const Color(0xFF0D9488),
    'Hormones' => const Color(0xFFDB2777),
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
    return CustomScrollView(
      slivers: [
        // ── Filter chips ──
        SliverToBoxAdapter(
          child: SizedBox(
            height: 48,
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 6),
              scrollDirection: Axis.horizontal,
              itemCount: _cats.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final c = _cats[i]; final active = c == cat;
                final color = _catColor(c);
                return GestureDetector(
                  onTap: () => onCat(c),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: active ? color : (dark ? const Color(0xFF1E1E1E) : const Color(0xFFF5F5F5)),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: active ? color : Colors.transparent, width: 1.5)),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(_catIcon(c), size: 12,
                        color: active ? Colors.white : _T.t2(dark)),
                      const SizedBox(width: 5),
                      Text(c, style: GoogleFonts.inter(
                        fontSize: 13, fontWeight: FontWeight.w600,
                        color: active ? Colors.white : _T.t2(dark))),
                    ]),
                  ),
                );
              },
            ),
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
    'Sport'    => const Color(0xFF2563EB),
    'Nutrition'=> const Color(0xFFD97706),
    'Sommeil'  => const Color(0xFF7C3AED),
    'Mental'   => const Color(0xFF0D9488),
    'Hormones' => const Color(0xFFDB2777),
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
    final cardBg = dark ? const Color(0xFF161616) : Colors.white;
    final borderColor = dark ? const Color(0xFF242424) : const Color(0xFFF0F0F0);

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
                        color: dark ? const Color(0xFF242424) : const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(20)),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(LucideIcons.clock, size: 10, color: _T.t3(dark)),
                        const SizedBox(width: 3),
                        Text('${conseil.readMin} min', style: GoogleFonts.inter(
                          fontSize: 11, color: _T.t2(dark))),
                      ]),
                    ),
                    const Spacer(),
                    Text(conseil.postedAgo, style: GoogleFonts.inter(
                      fontSize: 11, color: _T.t3(dark))),
                  ]),

                  const SizedBox(height: 12),

                  // Title
                  Text(conseil.title, style: GoogleFonts.outfit(
                    fontSize: 16, fontWeight: FontWeight.w700,
                    color: _T.t1(dark), height: 1.3)),

                  const SizedBox(height: 7),

                  // Body
                  Text(conseil.body, style: GoogleFonts.inter(
                    fontSize: 13.5, color: _T.t2(dark), height: 1.6),
                    maxLines: 3, overflow: TextOverflow.ellipsis),

                  const SizedBox(height: 14),

                  // Footer: doctor + like
                  Row(children: [
                    GestureDetector(
                      onTap: onDoctor,
                      child: Row(children: [
                        _Ava(initials: doc.initials, color: doc.color, size: 28, photoAsset: doc.photoAsset),
                        const SizedBox(width: 8),
                        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(doc.name, style: GoogleFonts.inter(
                            fontSize: 12, fontWeight: FontWeight.w600, color: _T.t1(dark))),
                          Text(doc.specialty, style: GoogleFonts.inter(
                            fontSize: 11, color: _T.t2(dark))),
                        ]),
                      ]),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: onLike,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: isLiked
                            ? const Color(0xFFE53935).withOpacity(0.10)
                            : (dark ? const Color(0xFF242424) : const Color(0xFFF5F5F5)),
                          borderRadius: BorderRadius.circular(20)),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Icon(isLiked ? LucideIcons.heartHandshake : LucideIcons.heart,
                            size: 13, color: isLiked ? const Color(0xFFE53935) : _T.t3(dark)),
                          const SizedBox(width: 4),
                          Text('${conseil.likes + (isLiked ? 1 : 0)}',
                            style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600,
                              color: isLiked ? const Color(0xFFE53935) : _T.t2(dark))),
                        ]),
                      ),
                    ),
                  ]),
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
  final ValueChanged<String> onLex;
  const _RessourcesTab({required this.dark, required this.lex, required this.onLex});

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
        _SectionHeader(title: 'Séries vidéo', icon: LucideIcons.playCircle,
          subtitle: '${_videoSeries.length} séries · médecins experts', dark: dark),
        const SizedBox(height: 16),
        SizedBox(
          height: 230,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemCount: _videoSeries.length,
            itemBuilder: (ctx, i) {
              final s = _videoSeries[i];
              return Padding(
                padding: EdgeInsets.only(right: i < _videoSeries.length - 1 ? 14 : 0),
                child: GestureDetector(
                  onTap: () => showModalBottomSheet(
                    context: ctx, isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => _SeriesSheet(series: s, dark: dark)),
                  child: _SeriesCard(series: s, dark: dark),
                ),
              );
            },
          ),
        ),

        // ── Section header: Articles ──
        const SizedBox(height: 32),
        _SectionHeader(title: 'Articles', icon: LucideIcons.bookOpen,
          subtitle: '${_articles.length} articles scientifiques', dark: dark),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: _articles.asMap().entries.map((e) =>
              Padding(
                padding: EdgeInsets.only(bottom: e.key < _articles.length - 1 ? 10 : 0),
                child: _ArticleCard(article: e.value, dark: dark),
              )
            ).toList(),
          ),
        ),

        // ── Section header: Lexique ──
        const SizedBox(height: 32),
        _SectionHeader(title: 'Lexique médical', icon: LucideIcons.microscope,
          subtitle: 'Termes & définitions', dark: dark),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            decoration: BoxDecoration(
              color: dark ? const Color(0xFF1A1A1A) : const Color(0xFFF8F8F8),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _T.border(dark))),
            child: TextField(
              onChanged: onLex,
              style: GoogleFonts.inter(fontSize: 14, color: _T.t1(dark)),
              decoration: InputDecoration(
                hintText: 'Rechercher un terme…',
                hintStyle: GoogleFonts.inter(fontSize: 14, color: _T.t3(dark)),
                prefixIcon: Icon(LucideIcons.search, size: 16, color: _T.t3(dark)),
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
          color: const Color(0xFF0D9488).withOpacity(0.10),
          borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, size: 16, color: const Color(0xFF0D9488)),
      ),
      const SizedBox(width: 10),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: GoogleFonts.outfit(
          fontSize: 17, fontWeight: FontWeight.w700, color: _T.t1(dark))),
        Text(subtitle, style: GoogleFonts.inter(fontSize: 12, color: _T.t2(dark))),
      ]),
    ]),
  );
}

// ── Series card ───────────────────────────────────────────────────────────────
class _SeriesCard extends StatelessWidget {
  final _VideoSeries series; final bool dark;
  const _SeriesCard({required this.series, required this.dark});

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
                  Text('Regarder', style: GoogleFonts.inter(
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
    final cardBg = dark ? const Color(0xFF161616) : Colors.white;
    final border = dark ? const Color(0xFF242424) : const Color(0xFFF0F0F0);
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
                  color: _T.t1(dark), height: 1.3),
                  maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 5),
                Text(article.excerpt, style: GoogleFonts.inter(
                  fontSize: 12, color: _T.t2(dark), height: 1.5),
                  maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 6),
                Text(article.author, style: GoogleFonts.inter(
                  fontSize: 11, color: _T.t3(dark), fontWeight: FontWeight.w500)),
              ]),
            ),
          ),
          // Arrow
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Icon(LucideIcons.chevronRight, size: 16, color: _T.t3(dark)),
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
    final cardBg = dark ? const Color(0xFF161616) : Colors.white;
    final border = dark ? const Color(0xFF242424) : const Color(0xFFF0F0F0);
    return GestureDetector(
      onTap: () => setState(() => _open = !_open),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _open ? const Color(0xFF0D9488) : border, width: _open ? 1.5 : 1),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(
                width: 28, height: 28,
                decoration: BoxDecoration(
                  color: const Color(0xFF0D9488).withOpacity(0.10),
                  borderRadius: BorderRadius.circular(8)),
                child: Center(child: Text(e.term[0], style: GoogleFonts.outfit(
                  fontSize: 13, fontWeight: FontWeight.w800,
                  color: const Color(0xFF0D9488)))),
              ),
              const SizedBox(width: 10),
              Expanded(child: Text(e.term, style: GoogleFonts.outfit(
                fontSize: 14, fontWeight: FontWeight.w700, color: _T.t1(dark)))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: dark ? const Color(0xFF242424) : const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(10)),
                child: Text(e.category, style: GoogleFonts.inter(
                  fontSize: 10, color: _T.t2(dark))),
              ),
              const SizedBox(width: 6),
              AnimatedRotation(
                turns: _open ? 0.5 : 0,
                duration: const Duration(milliseconds: 200),
                child: Icon(LucideIcons.chevronDown, size: 16, color: _T.t3(dark)),
              ),
            ]),
            if (_open) ...[
              const SizedBox(height: 10),
              Divider(height: 1, color: _T.border(dark)),
              const SizedBox(height: 10),
              Text(e.definition, style: GoogleFonts.inter(
                fontSize: 13, color: _T.t2(dark), height: 1.65)),
            ],
          ]),
        ),
      ),
    );
  }
}

// ─── Tab 3 · Q & R ───────────────────────────────────────────────────────────

class _QRTab extends StatefulWidget {
  final bool dark;
  const _QRTab({required this.dark});
  @override
  State<_QRTab> createState() => _QRTabState();
}

class _QRTabState extends State<_QRTab> {
  final Set<int> _voted = {};
  bool _open = false;
  final _ctrl = TextEditingController();
  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final dark = widget.dark;
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 110),
      children: [
        // Ask box
        GestureDetector(
          onTap: () => setState(() => _open = !_open),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _T.card(dark),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _open ? _T.accent(dark).withOpacity(0.4) : _T.border(dark))),
            child: _open
                ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Votre question', style: GoogleFonts.inter(
                      fontSize: 13, fontWeight: FontWeight.w600, color: _T.t1(dark))),
                    const SizedBox(height: 10),
                    TextField(controller: _ctrl, maxLines: 3,
                      style: GoogleFonts.inter(fontSize: 14, color: _T.t1(dark)),
                      decoration: InputDecoration(
                        hintText: 'Décrivez votre situation…',
                        hintStyle: GoogleFonts.inter(color: _T.t3(dark)),
                        border: InputBorder.none, contentPadding: EdgeInsets.zero)),
                    const SizedBox(height: 14),
                    Row(children: [
                      Icon(LucideIcons.lockKeyhole, size: 12, color: _T.t3(dark)),
                      const SizedBox(width: 5),
                      Text('Publication anonyme', style: GoogleFonts.inter(
                        fontSize: 12, color: _T.t3(dark))),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                        decoration: BoxDecoration(
                          color: _T.t1(dark), borderRadius: BorderRadius.circular(10)),
                        child: Text('Envoyer', style: GoogleFonts.inter(
                          fontSize: 13, fontWeight: FontWeight.w600,
                          color: _T.card(dark)))),
                    ]),
                  ])
                : Row(children: [
                    Icon(LucideIcons.pencil, size: 16, color: _T.t3(dark)),
                    const SizedBox(width: 12),
                    Text('Poser une question à un médecin…',
                      style: GoogleFonts.inter(fontSize: 14, color: _T.t2(dark))),
                  ]),
          ),
        ),
        const SizedBox(height: 28),
        ..._questions.asMap().entries.map((e) {
          final i = e.key; final q = e.value; final voted = _voted.contains(i);
          return Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Question
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(
                  width: 28, height: 28,
                  decoration: BoxDecoration(color: _T.border(dark), shape: BoxShape.circle),
                  child: Icon(LucideIcons.userRound, size: 14, color: _T.t3(dark))),
                const SizedBox(width: 10),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Anonyme · ${q.postedAgo}', style: GoogleFonts.inter(
                    fontSize: 12, color: _T.t3(dark))),
                  const SizedBox(height: 6),
                  Text(q.question, style: GoogleFonts.outfit(
                    fontSize: 15, fontWeight: FontWeight.w600,
                    color: _T.t1(dark), height: 1.4)),
                ])),
              ]),
              // Answer
              if (q.doctorAnswer != null) ...[
                const SizedBox(height: 12),
                Container(
                  margin: const EdgeInsets.only(left: 38),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: _T.card(dark),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _T.border(dark))),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Icon(LucideIcons.badgeCheck, size: 13, color: _T.accent(dark)),
                      const SizedBox(width: 6),
                      Text(q.answerDoctor ?? '', style: GoogleFonts.inter(
                        fontSize: 12, fontWeight: FontWeight.w600, color: _T.accent(dark))),
                    ]),
                    const SizedBox(height: 8),
                    Text(q.doctorAnswer!, style: GoogleFonts.inter(
                      fontSize: 13, color: _T.t2(dark), height: 1.6)),
                  ]),
                ),
              ] else ...[
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.only(left: 38),
                  child: Text('En attente de réponse…', style: GoogleFonts.inter(
                    fontSize: 12, color: _T.t3(dark), fontStyle: FontStyle.italic))),
              ],
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.only(left: 38),
                child: GestureDetector(
                  onTap: () => setState(() { if (voted) _voted.remove(i); else _voted.add(i); }),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(LucideIcons.thumbsUp, size: 14,
                      color: voted ? _T.accent(dark) : _T.t3(dark)),
                    const SizedBox(width: 5),
                    Text('${q.votes + (voted ? 1 : 0)} utiles',
                      style: GoogleFonts.inter(fontSize: 12,
                        color: voted ? _T.accent(dark) : _T.t3(dark))),
                  ]),
                ),
              ),
              const SizedBox(height: 20),
              Divider(height: 1, color: _T.border(dark)),
            ]),
          );
        }),
      ],
    );
  }
}

// ─── Tab 4 · Médecins ─────────────────────────────────────────────────────────

class _DoctorsTab extends StatelessWidget {
  final bool dark;
  final String spec;
  final int? marker;
  final ValueChanged<String> onSpec;
  final ValueChanged<int> onMarker;
  final ValueChanged<_Doctor> onDoctor;
  const _DoctorsTab({required this.dark, required this.spec, required this.marker,
    required this.onSpec, required this.onMarker, required this.onDoctor});

  List<int> get _indexes {
    if (spec == 'Toutes') return List.generate(_doctors.length, (i) => i);
    return List.generate(_doctors.length, (i) => i).where((i) =>
      _doctors[i].specialty.toLowerCase().contains(
        spec.toLowerCase().replaceAll('é','e').replaceAll('ologie',''))).toList();
  }

  @override
  Widget build(BuildContext context) {
    final idx = _indexes;
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 110),
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
                for (int i = 0; i < _doctors.length; i++) {
                  final p = _doctorPositions[i];
                  final cx = p.x * mw; final cy = p.y * 240 + (i == 4 ? 18 : 0);
                  if ((lp.dx - cx).abs() < 22 && (lp.dy - cy).abs() < 22) {
                    onMarker(i); return;
                  }
                }
                onMarker(-1);
              },
              child: CustomPaint(
                painter: _MapPainter(dark: dark, marker: marker, indexes: idx),
                child: Stack(children: [
                  Positioned(top: 12, left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: (dark ? const Color(0xFF1A1A1A) : Colors.white).withOpacity(0.92),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: _T.border(dark))),
                      child: Text('Tunisie · ${_doctors.length} spécialistes',
                        style: GoogleFonts.inter(fontSize: 11, color: _T.t2(dark))))),
                  if (marker != null && marker! >= 0 && marker! < _doctors.length)
                    _MapPopup(doctor: _doctors[marker!], pos: _doctorPositions[marker!],
                      idx: marker!, dark: dark,
                      onTap: () => onDoctor(_doctors[marker!])),
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
                    color: active ? _T.t1(dark) : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: active ? _T.t1(dark) : _T.border(dark))),
                  child: Text(s, style: GoogleFonts.inter(fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: active ? _T.card(dark) : _T.t2(dark))),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 20),
        ...idx.map((i) {
          final doc = _doctors[i]; final sel = marker == i;
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
                        fontSize: 14, fontWeight: FontWeight.w600, color: _T.t1(dark))),
                      const SizedBox(height: 2),
                      Text(doc.specialty, style: GoogleFonts.inter(
                        fontSize: 13, color: _T.t2(dark))),
                      const SizedBox(height: 4),
                      Row(children: [
                        Icon(LucideIcons.mapPin, size: 11, color: _T.t3(dark)),
                        const SizedBox(width: 3),
                        Text(doc.location, style: GoogleFonts.inter(fontSize: 12, color: _T.t3(dark))),
                        const SizedBox(width: 10),
                        Icon(LucideIcons.star, size: 11, color: const Color(0xFFF59E0B)),
                        const SizedBox(width: 3),
                        Text('${doc.rating}', style: GoogleFonts.inter(
                          fontSize: 12, color: _T.t3(dark))),
                      ]),
                    ])),
                    Icon(LucideIcons.chevronRight, size: 16, color: _T.t3(dark)),
                  ]),
                ),
                Divider(height: 1, color: _T.border(dark)),
              ]),
            ),
          );
        }),
      ],
    );
  }
}

class _MapPainter extends CustomPainter {
  final bool dark; final int? marker; final List<int> indexes;
  _MapPainter({required this.dark, required this.marker, required this.indexes});

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
    for (int i = 0; i < _doctors.length; i++) {
      final p = _doctorPositions[i];
      final cx = p.x*w; final cy = p.y*h+(i==4?20:i==3?-18:0);
      final sel = marker==i; final filt = indexes.contains(i);
      final col = _doctors[i].color;
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
    old.marker != marker || old.dark != dark || old.indexes.length != indexes.length;
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
            border: Border.all(color: _T.border(dark)),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 14, offset: const Offset(0,4))]),
          child: Row(children: [
            _Ava(initials: doctor.initials, color: doctor.color, size: 32, photoAsset: doctor.photoAsset),
            const SizedBox(width: 8),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(doctor.name, style: GoogleFonts.inter(fontSize: 11,
                fontWeight: FontWeight.w600, color: _T.t1(dark)),
                maxLines: 1, overflow: TextOverflow.ellipsis),
              Text(doctor.specialty, style: GoogleFonts.inter(fontSize: 10, color: _T.t2(dark))),
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
  final _Doctor doctor; final bool dark;
  const _DoctorSheet({required this.doctor, required this.dark});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _T.card(dark),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom + 24),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const SizedBox(height: 12),
        Container(width: 36, height: 4, decoration: BoxDecoration(
          color: _T.border(dark), borderRadius: BorderRadius.circular(2))),
        const SizedBox(height: 28),
        _Ava(initials: doctor.initials, color: doctor.color, size: 70, photoAsset: doctor.photoAsset),
        const SizedBox(height: 14),
        Text(doctor.name, style: GoogleFonts.outfit(
          fontSize: 20, fontWeight: FontWeight.w800, color: _T.t1(dark))),
        const SizedBox(height: 4),
        Text(doctor.specialty, style: GoogleFonts.inter(fontSize: 14, color: _T.t2(dark))),
        const SizedBox(height: 8),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(LucideIcons.star, size: 13, color: const Color(0xFFF59E0B)),
          const SizedBox(width: 4),
          Text('${doctor.rating}', style: GoogleFonts.inter(
            fontSize: 13, fontWeight: FontWeight.w600, color: _T.t1(dark))),
          const SizedBox(width: 12),
          Text('·', style: GoogleFonts.inter(color: _T.t3(dark))),
          const SizedBox(width: 12),
          Text('${doctor.consultations} consultations', style: GoogleFonts.inter(
            fontSize: 13, color: _T.t2(dark))),
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
                      border: Border.all(color: _T.border(dark)),
                      borderRadius: BorderRadius.circular(14)),
                    child: Center(child: Text('Appeler', style: GoogleFonts.inter(
                      fontSize: 14, fontWeight: FontWeight.w600, color: _T.t1(dark)))))),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: _T.t1(dark), borderRadius: BorderRadius.circular(14)),
                    child: Center(child: Text('Rendez-vous', style: GoogleFonts.inter(
                      fontSize: 14, fontWeight: FontWeight.w600, color: _T.card(dark)))))),
              ),
            ]),
          ]),
        ),
      ]),
    );
  }
}

// ─── Series sheet ─────────────────────────────────────────────────────────────

class _SeriesSheet extends StatelessWidget {
  final _VideoSeries series; final bool dark;
  const _SeriesSheet({required this.series, required this.dark});

  @override
  Widget build(BuildContext context) {
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
                          Text('${series.episodes.length} épisodes', style: GoogleFonts.inter(
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
                        color: isFirst ? series.color.withOpacity(0.4) : _T.border(dark),
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
                          color: _T.t1(dark), height: 1.35),
                          maxLines: 2, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 5),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: dark ? const Color(0xFF242424) : const Color(0xFFEEEEEE),
                            borderRadius: BorderRadius.circular(8)),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            Icon(LucideIcons.clock3, size: 10, color: _T.t3(dark)),
                            const SizedBox(width: 4),
                            Text(ep.duration, style: GoogleFonts.inter(
                              fontSize: 11, color: _T.t2(dark), fontWeight: FontWeight.w500)),
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

class _PlayerPage extends StatefulWidget {
  final _VideoEpisode episode; final _VideoSeries series;
  const _PlayerPage({required this.episode, required this.series});
  @override
  State<_PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends State<_PlayerPage> {
  late VideoPlayerController _vpc;
  ChewieController? _chewie;
  bool _liked = false;

  @override
  void initState() {
    super.initState();
    _vpc = VideoPlayerController.asset(widget.episode.asset);
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
    final s = widget.series;
    final ep = widget.episode;
    final doc = s.doctor;
    final bg = dark ? const Color(0xFF0A0A0A) : const Color(0xFFF5F5F5);
    final cardBg = dark ? const Color(0xFF161616) : Colors.white;

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
                        child: Text('Épisode ${ep.episode}', style: GoogleFonts.inter(
                          color: s.color, fontSize: 11, fontWeight: FontWeight.w700)),
                      ),
                      const SizedBox(width: 8),
                      Expanded(child: Text(s.title, style: GoogleFonts.inter(
                        fontSize: 11, color: _T.t3(dark)), overflow: TextOverflow.ellipsis)),
                      // duration pill
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: dark ? const Color(0xFF242424) : const Color(0xFFF0F0F0),
                          borderRadius: BorderRadius.circular(10)),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Icon(LucideIcons.clock3, size: 10, color: _T.t3(dark)),
                          const SizedBox(width: 4),
                          Text(ep.duration, style: GoogleFonts.inter(
                            fontSize: 11, color: _T.t2(dark), fontWeight: FontWeight.w500)),
                        ]),
                      ),
                    ]),
                    const SizedBox(height: 12),

                    // episode title
                    Text(ep.title, style: GoogleFonts.outfit(
                      fontSize: 18, fontWeight: FontWeight.w800,
                      color: _T.t1(dark), height: 1.25)),
                    const SizedBox(height: 16),

                    // action row: like + share
                    Row(children: [
                      GestureDetector(
                        onTap: () => setState(() => _liked = !_liked),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: _liked ? s.color.withOpacity(0.12) : (dark ? const Color(0xFF242424) : const Color(0xFFF2F2F2)),
                            borderRadius: BorderRadius.circular(20),
                            border: _liked ? Border.all(color: s.color.withOpacity(0.4)) : null),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            Icon(LucideIcons.heart, size: 15,
                              color: _liked ? s.color : _T.t2(dark)),
                            const SizedBox(width: 6),
                            Text('J\'aime', style: GoogleFonts.inter(
                              fontSize: 13, fontWeight: FontWeight.w600,
                              color: _liked ? s.color : _T.t2(dark))),
                          ]),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: dark ? const Color(0xFF242424) : const Color(0xFFF2F2F2),
                          borderRadius: BorderRadius.circular(20)),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Icon(LucideIcons.share2, size: 15, color: _T.t2(dark)),
                          const SizedBox(width: 6),
                          Text('Partager', style: GoogleFonts.inter(
                            fontSize: 13, fontWeight: FontWeight.w600, color: _T.t2(dark))),
                        ]),
                      ),
                    ]),

                    const SizedBox(height: 16),
                    Divider(height: 1, color: _T.border(dark)),
                    const SizedBox(height: 16),

                    // doctor row
                    Row(children: [
                      _Ava(initials: doc.initials, color: doc.color,
                        size: 44, bordered: true, photoAsset: doc.photoAsset),
                      const SizedBox(width: 12),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(doc.name, style: GoogleFonts.outfit(
                          fontSize: 15, fontWeight: FontWeight.w700, color: _T.t1(dark))),
                        Text(doc.specialty, style: GoogleFonts.inter(
                          fontSize: 12, color: _T.t2(dark))),
                      ])),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: s.color, borderRadius: BorderRadius.circular(20)),
                        child: Text('Suivre', style: GoogleFonts.inter(
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
                    child: Text('Dans cette série', style: GoogleFonts.outfit(
                      fontSize: 16, fontWeight: FontWeight.w700, color: _T.t1(dark))),
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
                          border: Border.all(color: _T.border(dark))),
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
                              child: Text('Ep. ${other.episode}', style: GoogleFonts.inter(
                                fontSize: 10, fontWeight: FontWeight.w700, color: s.color)),
                            ),
                            const SizedBox(height: 5),
                            Text(other.title, style: GoogleFonts.inter(
                              fontSize: 13, fontWeight: FontWeight.w600,
                              color: _T.t1(dark), height: 1.3),
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
    fontSize: 20, fontWeight: FontWeight.w700, color: _T.t1(dark), letterSpacing: -0.3));
}

class _InfoRow2 extends StatelessWidget {
  final IconData icon; final String label; final bool dark;
  const _InfoRow2({required this.icon, required this.label, required this.dark});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(children: [
      Icon(icon, size: 15, color: _T.t3(dark)),
      const SizedBox(width: 12),
      Flexible(child: Text(label, style: GoogleFonts.inter(fontSize: 14, color: _T.t1(dark)))),
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
      color: _T.card(dark), borderRadius: BorderRadius.circular(14),
      border: Border.all(color: _T.border(dark))),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Icon(icon, size: 12, color: _T.t3(dark)),
        const SizedBox(width: 5),
        Text(label, style: GoogleFonts.inter(fontSize: 11, color: _T.t3(dark))),
      ]),
      const SizedBox(height: 4),
      TextField(controller: ctrl,
        style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: _T.t1(dark)),
        decoration: InputDecoration(
          hintText: hint, hintStyle: GoogleFonts.inter(
            fontSize: 16, color: _T.t3(dark), fontWeight: FontWeight.w400),
          border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.zero)),
    ]),
  );
}
