// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

// ─── Color tokens ─────────────────────────────────────────────────────────────

class _C {
  static const lBg      = Colors.white;
  static const lSurface = Color(0xFFFFFFFF);
  static const lBorder  = Color(0xFFEAECF0);
  static const lText1   = Color(0xFF0D1117);
  static const lText2   = Color(0xFF6B7280);
  static const lText3   = Color(0xFF9CA3AF);
  static const lAccent  = Color(0xFF1C4D30);
  static const dBg      = Color(0xFF0A0A0A);
  static const dSurface = Color(0xFF141414);
  static const dBorder  = Color(0xFF232323);
  static const dText1   = Color(0xFFFFFFFF);
  static const dText2   = Color(0xFF9CA3AF);
  static const dText3   = Color(0xFF6B7280);
  static const dAccent  = Color(0xFF5CD57A);

  static Color bg(bool d)      => d ? dBg      : lBg;
  static Color surface(bool d) => d ? dSurface : lSurface;
  static Color border(bool d)  => d ? dBorder  : lBorder;
  static Color text1(bool d)   => d ? dText1   : lText1;
  static Color text2(bool d)   => d ? dText2   : lText2;
  static Color text3(bool d)   => d ? dText3   : lText3;
  static Color accent(bool d)  => d ? dAccent  : lAccent;
}

// ─── Models ───────────────────────────────────────────────────────────────────

class _Doctor {
  final String name;
  final String specialty;
  final String location;
  final String hospital;
  final String phone;
  final String email;
  final String initials;
  final Color avatarColor;
  final double rating;
  final int consultations;

  const _Doctor({
    required this.name,
    required this.specialty,
    required this.location,
    required this.hospital,
    required this.phone,
    required this.email,
    required this.initials,
    required this.avatarColor,
    this.rating = 4.8,
    this.consultations = 120,
  });
}

class _Conseil {
  final _Doctor doctor;
  final String title;
  final String body;
  final String category;
  final String postedAgo;
  final int likes;
  final int readMin;

  const _Conseil({
    required this.doctor,
    required this.title,
    required this.body,
    required this.category,
    required this.postedAgo,
    required this.likes,
    this.readMin = 2,
  });
}

class _Question {
  final String question;
  final String postedAgo;
  final int votes;
  final String? doctorAnswer;
  final String? answerDoctor;
  final bool isAnonymous;

  const _Question({
    required this.question,
    required this.postedAgo,
    required this.votes,
    this.doctorAnswer,
    this.answerDoctor,
    this.isAnonymous = true,
  });
}

class _Article {
  final String title;
  final String author;
  final String specialty;
  final String excerpt;
  final String category;
  final int readMin;
  final Color accentColor;

  const _Article({
    required this.title,
    required this.author,
    required this.specialty,
    required this.excerpt,
    required this.category,
    required this.readMin,
    required this.accentColor,
  });
}

class _LexiqueEntry {
  final String term;
  final String definition;
  final String category;

  const _LexiqueEntry({
    required this.term,
    required this.definition,
    required this.category,
  });
}

class _PodcastEntry {
  final String title;
  final String doctor;
  final String specialty;
  final String duration;
  final String category;
  final Color color;

  const _PodcastEntry({
    required this.title,
    required this.doctor,
    required this.specialty,
    required this.duration,
    required this.category,
    required this.color,
  });
}

// ─── Static data ──────────────────────────────────────────────────────────────

const _doctors = [
  _Doctor(
    name: 'Dr. Sarah Mansouri',
    specialty: 'Gynécologie-Obstétrique',
    location: 'Tunis, Tunisie',
    hospital: 'Clinique El Manar',
    phone: '+216 71 000 001',
    email: 's.mansouri@manar.tn',
    initials: 'SM',
    avatarColor: Color(0xFF1C4D30),
    rating: 4.9,
    consultations: 342,
  ),
  _Doctor(
    name: 'Dr. Karim Belhadj',
    specialty: 'Endocrinologie',
    location: 'Sousse, Tunisie',
    hospital: 'CHU Farhat Hached',
    phone: '+216 73 000 002',
    email: 'k.belhadj@chu-sousse.tn',
    initials: 'KB',
    avatarColor: Color(0xFF2980B9),
    rating: 4.7,
    consultations: 215,
  ),
  _Doctor(
    name: 'Dr. Nadia Trabelsi',
    specialty: 'Médecine du Sport',
    location: 'Sfax, Tunisie',
    hospital: 'Centre Médical Sportif',
    phone: '+216 74 000 003',
    email: 'n.trabelsi@cms-sfax.tn',
    initials: 'NT',
    avatarColor: Color(0xFF6D4C9A),
    rating: 4.8,
    consultations: 178,
  ),
  _Doctor(
    name: 'Dr. Amine Chokri',
    specialty: 'Nutrition & Diététique',
    location: 'Ariana, Tunisie',
    hospital: 'Cabinet Privé',
    phone: '+216 70 000 004',
    email: 'a.chokri@nutrition.tn',
    initials: 'AC',
    avatarColor: Color(0xFFB5451B),
    rating: 4.6,
    consultations: 290,
  ),
  _Doctor(
    name: 'Dr. Leila Gharbi',
    specialty: 'Psychiatrie',
    location: 'Tunis, Tunisie',
    hospital: 'Hôpital Razi',
    phone: '+216 71 000 005',
    email: 'l.gharbi@razi.tn',
    initials: 'LG',
    avatarColor: Color(0xFF0E6B8F),
    rating: 4.9,
    consultations: 401,
  ),
];

final _conseils = [
  _Conseil(
    doctor: _doctors[0],
    title: 'Activité physique et cycle menstruel',
    body: 'Pendant la phase folliculaire, votre corps est plus résistant à la douleur et votre endurance est maximale. En phase lutéale, privilégiez le yoga ou la marche.',
    category: 'Sport',
    postedAgo: 'il y a 2h',
    likes: 47,
    readMin: 3,
  ),
  _Conseil(
    doctor: _doctors[1],
    title: 'Résistance à l\'insuline et alimentation',
    body: 'Les femmes souffrant de SOPK bénéficient d\'une alimentation à index glycémique bas. Réduisez les sucres raffinés et augmentez les fibres pour réguler votre insuline.',
    category: 'Nutrition',
    postedAgo: 'il y a 5h',
    likes: 83,
    readMin: 4,
  ),
  _Conseil(
    doctor: _doctors[2],
    title: 'Récupération et sommeil chez la sportive',
    body: 'La mélatonine produite entre 22h et 2h du matin est déterminante pour la récupération musculaire. Évitez les écrans 1h avant le coucher.',
    category: 'Sommeil',
    postedAgo: 'il y a 1 jour',
    likes: 61,
    readMin: 3,
  ),
  _Conseil(
    doctor: _doctors[3],
    title: 'Carences en fer chez la femme active',
    body: 'La carence en fer touche 20% des femmes. Associez les aliments riches en fer à de la vitamine C pour optimiser l\'absorption. Un dosage sanguin annuel est recommandé.',
    category: 'Nutrition',
    postedAgo: 'il y a 2 jours',
    likes: 112,
    readMin: 2,
  ),
  _Conseil(
    doctor: _doctors[4],
    title: 'Anxiété cyclique et hormones',
    body: 'Le pic d\'œstrogènes avant l\'ovulation peut provoquer une anxiété légère. La cohérence cardiaque (5 min, 3 fois/jour) est validée cliniquement pour réguler le système nerveux.',
    category: 'Santé mentale',
    postedAgo: 'il y a 3 jours',
    likes: 95,
    readMin: 4,
  ),
  _Conseil(
    doctor: _doctors[0],
    title: 'Douleurs pelviennes : quand consulter ?',
    body: 'Des douleurs pelviennes persistantes hors des règles méritent une consultation. L\'endométriose touche 1 femme sur 10 et reste sous-diagnostiquée en moyenne 7 ans.',
    category: 'Hormones',
    postedAgo: 'il y a 4 jours',
    likes: 204,
    readMin: 5,
  ),
];

const _questions = [
  _Question(
    question: 'Est-ce normal d\'avoir des crampes pendant toute la semaine des règles ?',
    postedAgo: 'il y a 1h',
    votes: 34,
    doctorAnswer: 'Des douleurs modérées sont normales, mais des crampes invalidantes sur toute la semaine peuvent indiquer une dysménorrhée secondaire (endométriose, fibromes). Consultez un gynécologue pour un bilan.',
    answerDoctor: 'Dr. Sarah Mansouri — Gynécologie',
  ),
  _Question(
    question: 'Mon médecin m\'a prescrit de la progestérone naturelle, y a-t-il des effets secondaires ?',
    postedAgo: 'il y a 3h',
    votes: 21,
    doctorAnswer: 'La progestérone naturelle micronisée est bien tolérée. Les effets possibles sont une légère somnolence (prenez-la le soir), des nausées rares et des seins sensibles. Ces effets disparaissent après quelques semaines.',
    answerDoctor: 'Dr. Karim Belhadj — Endocrinologie',
  ),
  _Question(
    question: 'Je fais du sport 5 fois par semaine mais je prends du poids. Pourquoi ?',
    postedAgo: 'il y a 6h',
    votes: 57,
    doctorAnswer: null,
    answerDoctor: null,
  ),
  _Question(
    question: 'Quelle est la différence entre SOPK et endométriose ?',
    postedAgo: 'il y a 1 jour',
    votes: 89,
    doctorAnswer: 'Le SOPK est un trouble hormonal affectant l\'ovulation (ovaires polykystiques, excès d\'androgènes). L\'endométriose est une maladie inflammatoire où du tissu utérin se développe à l\'extérieur de l\'utérus. Elles peuvent coexister.',
    answerDoctor: 'Dr. Sarah Mansouri — Gynécologie',
  ),
];

const _articles = [
  _Article(
    title: 'Le microbiome intestinal féminin : ce que la science dit en 2025',
    author: 'Dr. Amine Chokri',
    specialty: 'Nutrition & Diététique',
    excerpt: 'Les recherches récentes montrent un lien direct entre la composition du microbiome intestinal et les fluctuations hormonales. Découvrez comment votre alimentation influence vos hormones.',
    category: 'Nutrition',
    readMin: 8,
    accentColor: Color(0xFF2E7D32),
  ),
  _Article(
    title: 'Anxiété prémenstruelle : comprendre le PMDD',
    author: 'Dr. Leila Gharbi',
    specialty: 'Psychiatrie',
    excerpt: 'Le trouble dysphorique prémenstruel (TDPM) touche 3 à 8% des femmes. Il est souvent confondu avec une dépression. Voici comment le diagnostiquer et le traiter.',
    category: 'Santé mentale',
    readMin: 11,
    accentColor: Color(0xFF00695C),
  ),
  _Article(
    title: 'Périménopause et sport : adapter sa pratique',
    author: 'Dr. Nadia Trabelsi',
    specialty: 'Médecine du Sport',
    excerpt: 'La périménopause entraîne des changements physiologiques importants. La musculation devient alors essentielle pour préserver la densité osseuse et le métabolisme.',
    category: 'Sport',
    readMin: 9,
    accentColor: Color(0xFF1565C0),
  ),
];

const _lexique = [
  _LexiqueEntry(
    term: 'SOPK',
    definition: 'Syndrome des Ovaires PolykystiquesKystiques. Trouble hormonal fréquent caractérisé par un excès d\'androgènes, des cycles irréguliers et de petits kystes sur les ovaires.',
    category: 'Hormones',
  ),
  _LexiqueEntry(
    term: 'Endométriose',
    definition: 'Maladie chronique où du tissu semblable à la muqueuse utérine (endomètre) se développe en dehors de l\'utérus, provoquant douleurs et infertilité.',
    category: 'Gynécologie',
  ),
  _LexiqueEntry(
    term: 'Phase folliculaire',
    definition: 'Première phase du cycle menstruel (jours 1 à 14). Les follicules ovariens se développent sous l\'effet de la FSH, préparant l\'ovulation.',
    category: 'Cycle',
  ),
  _LexiqueEntry(
    term: 'Progestérone',
    definition: 'Hormone sexuelle féminine produite après l\'ovulation. Elle prépare l\'utérus à une grossesse et régule le cycle menstruel.',
    category: 'Hormones',
  ),
  _LexiqueEntry(
    term: 'AMH',
    definition: 'Hormone anti-müllérienne. Marqueur de la réserve ovarienne utilisé pour évaluer la fertilité et l\'approche de la ménopause.',
    category: 'Fertilité',
  ),
  _LexiqueEntry(
    term: 'Dysménorrhée',
    definition: 'Douleurs menstruelles. La dysménorrhée primaire est sans cause sous-jacente. La secondaire est liée à une pathologie (endométriose, fibromes).',
    category: 'Gynécologie',
  ),
];

const _podcasts = [
  _PodcastEntry(
    title: 'Comprendre son cycle en 5 minutes',
    doctor: 'Dr. Sarah Mansouri',
    specialty: 'Gynécologie',
    duration: '4 min 32s',
    category: 'Cycle',
    color: Color(0xFF1C4D30),
  ),
  _PodcastEntry(
    title: 'Alimentation anti-inflammatoire',
    doctor: 'Dr. Amine Chokri',
    specialty: 'Nutrition',
    duration: '6 min 15s',
    category: 'Nutrition',
    color: Color(0xFFB5451B),
  ),
  _PodcastEntry(
    title: 'Gérer le stress au quotidien',
    doctor: 'Dr. Leila Gharbi',
    specialty: 'Psychiatrie',
    duration: '5 min 08s',
    category: 'Mental',
    color: Color(0xFF0E6B8F),
  ),
  _PodcastEntry(
    title: 'Récupération après l\'effort',
    doctor: 'Dr. Nadia Trabelsi',
    specialty: 'Médecine du Sport',
    duration: '3 min 47s',
    category: 'Sport',
    color: Color(0xFF6D4C9A),
  ),
];

const _rappels = [
  (title: 'Bilan gynécologique annuel', icon: LucideIcons.calendar, due: 'Dans 3 mois', done: false),
  (title: 'Prise de sang (fer, hormones)', icon: LucideIcons.droplets, due: 'Dans 6 semaines', done: false),
  (title: 'Visite dentiste', icon: LucideIcons.smile, due: 'Fait le 10 mars', done: true),
  (title: 'Mammographie', icon: LucideIcons.activity, due: 'Dans 8 mois', done: false),
  (title: 'Dermatologue', icon: LucideIcons.sun, due: 'Non planifié', done: false),
];

// Doctor map positions (relative 0..1 on a Tunisia outline canvas)
// x=longitude-mapped, y=latitude-mapped roughly
const _doctorPositions = [
  (x: 0.52, y: 0.28), // Tunis  — _doctors[0] SM
  (x: 0.55, y: 0.45), // Sousse — _doctors[1] KB
  (x: 0.54, y: 0.62), // Sfax   — _doctors[2] NT
  (x: 0.50, y: 0.22), // Ariana — _doctors[3] AC
  (x: 0.52, y: 0.28), // Tunis  — _doctors[4] LG (offset handled in painter)
];

const _conseils_cats = ['Tout', 'Nutrition', 'Sport', 'Sommeil', 'Hormones', 'Santé mentale'];
const _doctors_specs = ['Toutes', 'Gynécologie', 'Endocrinologie', 'Sport', 'Nutrition', 'Psychiatrie'];

// ─── Main screen ──────────────────────────────────────────────────────────────

class SanteScreen extends StatefulWidget {
  const SanteScreen({super.key});

  @override
  State<SanteScreen> createState() => _SanteScreenState();
}

class _SanteScreenState extends State<SanteScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;

  // Conseils tab
  String _conseilCat = 'Tout';
  final Set<int> _liked = <int>{};

  // Médecins tab
  String _docSpec = 'Toutes';
  int? _selectedMarker;

  // Lexique search
  String _lexSearch = '';

  // Carnet
  final TextEditingController _weightCtrl = TextEditingController();
  final TextEditingController _bpCtrl     = TextEditingController();
  final List<Map<String, String>> _carnetEntries = [];

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    _weightCtrl.dispose();
    _bpCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final top    = MediaQuery.of(context).padding.top;
    final headerBg = isDark ? const Color(0xFF141414) : Colors.white;

    return Scaffold(
      backgroundColor: _C.bg(isDark),
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [
          SliverToBoxAdapter(
            child: Container(
              color: headerBg,
              padding: EdgeInsets.fromLTRB(20, top + 14, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('SANTÉ & BIEN-ÊTRE',
                              style: GoogleFonts.inter(
                                color: _C.accent(isDark), fontSize: 10,
                                fontWeight: FontWeight.w700, letterSpacing: 2.5)),
                            const SizedBox(height: 4),
                            Text('Espace Médical',
                              style: GoogleFonts.outfit(
                                color: _C.text1(isDark), fontSize: 24,
                                fontWeight: FontWeight.w800, letterSpacing: -0.5,
                                height: 1.1)),
                          ],
                        ),
                      ),
                    
                    ],
                  ),
                  const SizedBox(height: 16),
                  TabBar(
                    controller: _tab,
                    isScrollable: true,
                    tabAlignment: TabAlignment.start,
                    labelStyle: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600),
                    unselectedLabelStyle: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w400),
                    labelColor: _C.accent(isDark),
                    unselectedLabelColor: _C.text2(isDark),
                    indicatorColor: _C.accent(isDark),
                    indicatorSize: TabBarIndicatorSize.label,
                    dividerColor: _C.border(isDark),
                    tabs: const [
                      Tab(text: 'Conseils'),
                      Tab(text: 'Ressources'),
                      Tab(text: 'Q & R'),
                      Tab(text: 'Médecins'),
                      Tab(text: 'Mon Carnet'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tab,
          children: [
            _ConseisTab(
              isDark: isDark,
              selectedCat: _conseilCat,
              liked: _liked,
              onCatChanged: (c) => setState(() => _conseilCat = c),
              onLike: (i) => setState(() {
                if (_liked.contains(i)) _liked.remove(i); else _liked.add(i);
              }),
              onDoctorTap: (doc) => _showDoctorSheet(context, doc, isDark),
            ),
            _RessourcesTab(isDark: isDark, lexSearch: _lexSearch,
              onLexSearch: (s) => setState(() => _lexSearch = s)),
            _QRTab(isDark: isDark),
            _DoctorsTab(
              isDark: isDark,
              selectedSpec: _docSpec,
              selectedMarker: _selectedMarker,
              onSpecChanged: (s) => setState(() => _docSpec = s),
              onMarkerTap: (i) => setState(() => _selectedMarker = _selectedMarker == i ? null : i),
              onDoctorTap: (doc) => _showDoctorSheet(context, doc, isDark),
            ),
            _CarnetTab(
              isDark: isDark,
              weightCtrl: _weightCtrl,
              bpCtrl: _bpCtrl,
              entries: _carnetEntries,
              onSave: (entry) => setState(() => _carnetEntries.insert(0, entry)),
            ),
          ],
        ),
      ),
    );
  }

  void _showDoctorSheet(BuildContext context, _Doctor doc, bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _DoctorSheet(doctor: doc, isDark: isDark),
    );
  }
}

// ─── Tab 1 : Conseils ─────────────────────────────────────────────────────────

class _ConseisTab extends StatelessWidget {
  final bool isDark;
  final String selectedCat;
  final Set<int> liked;
  final ValueChanged<String> onCatChanged;
  final ValueChanged<int> onLike;
  final ValueChanged<_Doctor> onDoctorTap;

  const _ConseisTab({
    required this.isDark, required this.selectedCat, required this.liked,
    required this.onCatChanged, required this.onLike, required this.onDoctorTap,
  });

  List<_Conseil> get _filtered => selectedCat == 'Tout'
      ? _conseils
      : _conseils.where((c) => c.category == selectedCat).toList();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(top: 12, bottom: 110),
      children: [
        // Categories
        SizedBox(
          height: 38,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: _conseils_cats.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final cat = _conseils_cats[i];
              final active = cat == selectedCat;
              return GestureDetector(
                onTap: () => onCatChanged(cat),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: active ? _C.accent(isDark) : _C.surface(isDark),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: active ? _C.accent(isDark) : _C.border(isDark)),
                  ),
                  child: Text(cat,
                    style: GoogleFonts.inter(fontSize: 13,
                      fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                      color: active ? Colors.white : _C.text2(isDark))),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        ..._filtered.asMap().entries.map((e) {
          final idx = _conseils.indexOf(e.value);
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: _ConseilCard(
              conseil: e.value, isDark: isDark,
              isLiked: liked.contains(idx),
              onLike: () => onLike(idx),
              onDoctorTap: () => onDoctorTap(e.value.doctor),
            ),
          );
        }),
      ],
    );
  }
}

class _ConseilCard extends StatelessWidget {
  final _Conseil conseil;
  final bool isDark;
  final bool isLiked;
  final VoidCallback onLike;
  final VoidCallback onDoctorTap;

  const _ConseilCard({
    required this.conseil, required this.isDark,
    required this.isLiked, required this.onLike, required this.onDoctorTap,
  });

  Color _catColor(String cat) {
    switch (cat) {
      case 'Nutrition':     return const Color(0xFF2E7D32);
      case 'Sport':         return const Color(0xFF1565C0);
      case 'Sommeil':       return const Color(0xFF6A1B9A);
      case 'Hormones':      return const Color(0xFFC2185B);
      case 'Santé mentale': return const Color(0xFF00695C);
      default:              return const Color(0xFF455A64);
    }
  }

  @override
  Widget build(BuildContext context) {
    final doc = conseil.doctor;
    final likeCount = conseil.likes + (isLiked ? 1 : 0);
    return Container(
      decoration: BoxDecoration(
        color: _C.surface(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _C.border(isDark)),
        boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Doctor row
          GestureDetector(
            onTap: onDoctorTap,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
              child: Row(
                children: [
                  _Avatar(initials: doc.initials, color: doc.avatarColor, size: 42),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Text(doc.name, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: _C.text1(isDark))),
                          const SizedBox(width: 4),
                          Icon(LucideIcons.badgeCheck, size: 13, color: _C.accent(isDark)),
                        ]),
                        Text(doc.specialty, style: GoogleFonts.inter(fontSize: 12, color: _C.text2(isDark))),
                      ],
                    ),
                  ),
                  Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: _catColor(conseil.category).withOpacity(0.10),
                        borderRadius: BorderRadius.circular(6)),
                      child: Text(conseil.category,
                        style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600,
                          color: _catColor(conseil.category))),
                    ),
                    const SizedBox(height: 4),
                    Text(conseil.postedAgo, style: GoogleFonts.inter(fontSize: 11, color: _C.text3(isDark))),
                  ]),
                ],
              ),
            ),
          ),
          Divider(height: 1, color: _C.border(isDark)),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 13, 16, 13),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(conseil.title,
                  style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w700,
                    color: _C.text1(isDark), height: 1.3)),
                const SizedBox(height: 7),
                Text(conseil.body,
                  style: GoogleFonts.inter(fontSize: 13, color: _C.text2(isDark), height: 1.6)),
              ],
            ),
          ),
          Divider(height: 1, color: _C.border(isDark)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                GestureDetector(
                  onTap: onLike,
                  child: Row(children: [
                    Icon(LucideIcons.heart, size: 15,
                      color: isLiked ? const Color(0xFFE53935) : _C.text3(isDark)),
                    const SizedBox(width: 5),
                    Text('$likeCount', style: GoogleFonts.inter(fontSize: 13,
                      color: isLiked ? const Color(0xFFE53935) : _C.text3(isDark),
                      fontWeight: FontWeight.w500)),
                  ]),
                ),
                const SizedBox(width: 16),
                Icon(LucideIcons.clock, size: 14, color: _C.text3(isDark)),
                const SizedBox(width: 4),
                Text('${conseil.readMin} min',
                  style: GoogleFonts.inter(fontSize: 12, color: _C.text3(isDark))),
                const Spacer(),
                GestureDetector(
                  onTap: onDoctorTap,
                  child: Row(children: [
                    Text('Voir le profil',
                      style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600,
                        color: _C.accent(isDark))),
                    const SizedBox(width: 3),
                    Icon(LucideIcons.chevronRight, size: 14, color: _C.accent(isDark)),
                  ]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// (Symptômes tab removed)

class _SymptomsTab extends StatelessWidget {
  final bool isDark;
  final Map<String, int> symptomLevels;
  final int moodIndex;
  final List<String> selectedSymptoms;
  final ValueChanged<int> onMood;
  final ValueChanged<String> onToggleSymptom;
  final Function(String, int) onSeverity;

  const _SymptomsTab({
    required this.isDark, required this.symptomLevels,
    required this.moodIndex, required this.selectedSymptoms,
    required this.onMood, required this.onToggleSymptom, required this.onSeverity,
  });

  static const _moods = ['Excellent', 'Bien', 'Moyen', 'Fatigué', 'Mauvais'];
  static const _moodIcons = ['😄', '🙂', '😐', '😔', '😞'];
  static const _symptoms = [
    'Fatigue', 'Maux de tête', 'Douleurs pelviennes', 'Ballonnements',
    'Insomnie', 'Anxiété', 'Crampes', 'Nausées', 'Douleurs dorsales', 'Sautes d\'humeur',
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
      children: [
        // Date today
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _C.surface(isDark),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _C.border(isDark)),
          ),
          child: Row(
            children: [
              Icon(LucideIcons.calendarDays, size: 18, color: _C.accent(isDark)),
              const SizedBox(width: 10),
              Text("Aujourd'hui · Dimanche 15 juin 2025",
                style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: _C.text1(isDark))),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Humeur
        _SectionTitle(isDark: isDark, icon: LucideIcons.smile, label: 'Humeur du jour'),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _C.surface(isDark),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _C.border(isDark)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_moods.length, (i) {
              final sel = moodIndex == i;
              return GestureDetector(
                onTap: () => onMood(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: sel ? _C.accent(isDark).withOpacity(0.12) : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: sel ? _C.accent(isDark) : Colors.transparent, width: 1.5),
                  ),
                  child: Column(
                    children: [
                      Text(_moodIcons[i], style: const TextStyle(fontSize: 22)),
                      const SizedBox(height: 4),
                      Text(_moods[i],
                        style: GoogleFonts.inter(fontSize: 10,
                          color: sel ? _C.accent(isDark) : _C.text2(isDark),
                          fontWeight: sel ? FontWeight.w600 : FontWeight.w400)),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 20),

        // Symptoms
        _SectionTitle(isDark: isDark, icon: LucideIcons.thermometer, label: 'Symptômes ressentis'),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _C.surface(isDark),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _C.border(isDark)),
          ),
          child: Wrap(
            spacing: 8, runSpacing: 8,
            children: _symptoms.map((s) {
              final sel = selectedSymptoms.contains(s);
              return GestureDetector(
                onTap: () => onToggleSymptom(s),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: sel ? const Color(0xFFD32F2F).withOpacity(0.10) : _C.bg(isDark),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: sel ? const Color(0xFFD32F2F) : _C.border(isDark),
                      width: sel ? 1.5 : 1),
                  ),
                  child: Text(s,
                    style: GoogleFonts.inter(fontSize: 13,
                      color: sel ? const Color(0xFFD32F2F) : _C.text2(isDark),
                      fontWeight: sel ? FontWeight.w600 : FontWeight.w400)),
                ),
              );
            }).toList(),
          ),
        ),

        // Severity sliders for selected symptoms
        if (selectedSymptoms.isNotEmpty) ...[
          const SizedBox(height: 20),
          _SectionTitle(isDark: isDark, icon: LucideIcons.sliders, label: 'Intensité des symptômes'),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _C.surface(isDark),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _C.border(isDark)),
            ),
            child: Column(
              children: selectedSymptoms.map((s) {
                final val = (symptomLevels[s] ?? 1).toDouble();
                return Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(s, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: _C.text1(isDark))),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: _severityColor(val.toInt()).withOpacity(0.12),
                              borderRadius: BorderRadius.circular(6)),
                            child: Text(_severityLabel(val.toInt()),
                              style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600,
                                color: _severityColor(val.toInt()))),
                          ),
                        ],
                      ),
                      SliderTheme(
                        data: SliderThemeData(
                          activeTrackColor: _severityColor(val.toInt()),
                          thumbColor: _severityColor(val.toInt()),
                          inactiveTrackColor: _C.border(isDark),
                          trackHeight: 3,
                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
                          overlayShape: SliderComponentShape.noOverlay,
                        ),
                        child: Slider(
                          value: val, min: 1, max: 3, divisions: 2,
                          onChanged: (v) => onSeverity(s, v.toInt()),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],

        const SizedBox(height: 20),

        // Share button
        GestureDetector(
          onTap: () {},
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 15),
            decoration: BoxDecoration(
              color: _C.accent(isDark),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(LucideIcons.share2, size: 16, color: Colors.white),
                const SizedBox(width: 10),
                Text('Partager avec mon médecin',
                  style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Votre rapport sera envoyé au médecin de votre choix sous forme de PDF sécurisé.',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(fontSize: 12, color: _C.text3(isDark)),
        ),
      ],
    );
  }

  Color _severityColor(int v) {
    if (v == 1) return const Color(0xFF43A047);
    if (v == 2) return const Color(0xFFFFA726);
    return const Color(0xFFE53935);
  }

  String _severityLabel(int v) {
    if (v == 1) return 'Léger';
    if (v == 2) return 'Modéré';
    return 'Intense';
  }
}

// ─── Tab 3 : Q & R ───────────────────────────────────────────────────────────

class _QRTab extends StatefulWidget {
  final bool isDark;
  const _QRTab({required this.isDark});

  @override
  State<_QRTab> createState() => _QRTabState();
}

class _QRTabState extends State<_QRTab> {
  final Set<int> _voted = <int>{};
  bool _showForm = false;
  final _ctrl = TextEditingController();

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
      children: [
        // Ask button
        GestureDetector(
          onTap: () => setState(() => _showForm = !_showForm),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _C.surface(isDark),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _showForm ? _C.accent(isDark) : _C.border(isDark)),
            ),
            child: _showForm
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Votre question (anonyme)',
                        style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: _C.text1(isDark))),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _ctrl,
                        style: GoogleFonts.inter(fontSize: 14, color: _C.text1(isDark)),
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: 'Décrivez votre situation...',
                          hintStyle: GoogleFonts.inter(color: _C.text3(isDark)),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(children: [
                        Icon(LucideIcons.lockKeyhole, size: 13, color: _C.text3(isDark)),
                        const SizedBox(width: 5),
                        Text('Publication anonyme — votre identité n\'est pas révélée.',
                          style: GoogleFonts.inter(fontSize: 11, color: _C.text3(isDark))),
                      ]),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          color: _C.accent(isDark), borderRadius: BorderRadius.circular(10)),
                        child: Text('Poser la question',
                          style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
                      ),
                    ],
                  )
                : Row(children: [
                    Icon(LucideIcons.messageCirclePlus, size: 18, color: _C.accent(isDark)),
                    const SizedBox(width: 10),
                    Text('Poser une question à un médecin',
                      style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: _C.text2(isDark))),
                    const Spacer(),
                    Icon(LucideIcons.chevronRight, size: 16, color: _C.text3(isDark)),
                  ]),
          ),
        ),
        const SizedBox(height: 20),
        Text('${_questions.length} questions',
          style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: _C.text2(isDark))),
        const SizedBox(height: 12),
        ..._questions.asMap().entries.map((e) {
          final i = e.key;
          final q = e.value;
          final voted = _voted.contains(i);
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              decoration: BoxDecoration(
                color: _C.surface(isDark),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _C.border(isDark)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: _C.bg(isDark), borderRadius: BorderRadius.circular(6)),
                            child: Row(children: [
                              Icon(LucideIcons.userRound, size: 12, color: _C.text3(isDark)),
                              const SizedBox(width: 4),
                              Text('Anonyme', style: GoogleFonts.inter(fontSize: 11, color: _C.text3(isDark))),
                            ]),
                          ),
                          const Spacer(),
                          Text(q.postedAgo, style: GoogleFonts.inter(fontSize: 11, color: _C.text3(isDark))),
                        ]),
                        const SizedBox(height: 10),
                        Text(q.question,
                          style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w600,
                            color: _C.text1(isDark), height: 1.4)),
                      ],
                    ),
                  ),
                  if (q.doctorAnswer != null) ...[
                    Container(
                      margin: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _C.accent(isDark).withOpacity(0.07),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: _C.accent(isDark).withOpacity(0.2)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Icon(LucideIcons.badgeCheck, size: 14, color: _C.accent(isDark)),
                            const SizedBox(width: 6),
                            Text(q.answerDoctor ?? '',
                              style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600,
                                color: _C.accent(isDark))),
                          ]),
                          const SizedBox(height: 8),
                          Text(q.doctorAnswer!,
                            style: GoogleFonts.inter(fontSize: 13, color: _C.text1(isDark), height: 1.55)),
                        ],
                      ),
                    ),
                  ] else
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                      child: Text('En attente de réponse...',
                        style: GoogleFonts.inter(fontSize: 12, color: _C.text3(isDark),
                          fontStyle: FontStyle.italic)),
                    ),
                  Divider(height: 1, color: _C.border(isDark)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: GestureDetector(
                      onTap: () => setState(() {
                        if (voted) _voted.remove(i); else _voted.add(i);
                      }),
                      child: Row(children: [
                        Icon(LucideIcons.thumbsUp, size: 15,
                          color: voted ? _C.accent(isDark) : _C.text3(isDark)),
                        const SizedBox(width: 6),
                        Text('${q.votes + (voted ? 1 : 0)} votes utiles',
                          style: GoogleFonts.inter(fontSize: 13,
                            color: voted ? _C.accent(isDark) : _C.text3(isDark),
                            fontWeight: voted ? FontWeight.w600 : FontWeight.w400)),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}

// ─── Tab 4 : Médecins ─────────────────────────────────────────────────────────

class _DoctorsTab extends StatelessWidget {
  final bool isDark;
  final String selectedSpec;
  final int? selectedMarker;
  final ValueChanged<String> onSpecChanged;
  final ValueChanged<int> onMarkerTap;
  final ValueChanged<_Doctor> onDoctorTap;

  const _DoctorsTab({
    required this.isDark, required this.selectedSpec,
    required this.selectedMarker,
    required this.onSpecChanged, required this.onMarkerTap,
    required this.onDoctorTap,
  });

  List<int> get _filteredIndexes {
    if (selectedSpec == 'Toutes') return List.generate(_doctors.length, (i) => i);
    return List.generate(_doctors.length, (i) => i).where((i) =>
      _doctors[i].specialty.toLowerCase().contains(
        selectedSpec.toLowerCase().replaceAll('é', 'e').replaceAll('ologie', '')
      )).toList();
  }

  @override
  Widget build(BuildContext context) {
    final indexes = _filteredIndexes;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
      children: [
        // Interactive custom map
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Container(
            height: 280,
            decoration: BoxDecoration(
              border: Border.all(color: _C.border(isDark)),
              borderRadius: BorderRadius.circular(16),
            ),
            child: GestureDetector(
              onTapUp: (details) {
                // hit-test each marker
                final box = context.findRenderObject() as RenderBox?;
                if (box == null) return;
                final mapH = 280.0;
                final mapW = box.size.width - 32; // minus padding
                final localPos = details.localPosition;
                for (int i = 0; i < _doctors.length; i++) {
                  final pos = _doctorPositions[i];
                  final cx = pos.x * mapW;
                  final cy = pos.y * mapH + (i == 4 ? 18 : 0);
                  if ((localPos.dx - cx).abs() < 22 && (localPos.dy - cy).abs() < 22) {
                    onMarkerTap(i);
                    return;
                  }
                }
                onMarkerTap(-1);
              },
              child: CustomPaint(
                painter: _TunisiaMapPainter(
                  isDark: isDark,
                  selectedMarker: selectedMarker,
                  filteredIndexes: indexes,
                ),
                child: Stack(
                  children: [
                    // Legend top-left
                    Positioned(
                      top: 12, left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E1E1E).withOpacity(0.92) : Colors.white.withOpacity(0.92),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: _C.border(isDark)),
                        ),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Icon(LucideIcons.mapPin, size: 13, color: _C.accent(isDark)),
                          const SizedBox(width: 5),
                          Text('Spécialistes en Tunisie',
                            style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: _C.text1(isDark))),
                        ]),
                      ),
                    ),
                    // Selected doctor popup
                    if (selectedMarker != null && selectedMarker! >= 0 && selectedMarker! < _doctors.length)
                      _MarkerPopup(
                        doctor: _doctors[selectedMarker!],
                        position: _doctorPositions[selectedMarker!],
                        markerIndex: selectedMarker!,
                        isDark: isDark,
                        onTap: () => onDoctorTap(_doctors[selectedMarker!]),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Specialty filter
        SizedBox(
          height: 36,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _doctors_specs.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final s = _doctors_specs[i];
              final active = s == selectedSpec;
              return GestureDetector(
                onTap: () => onSpecChanged(s),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: active ? _C.accent(isDark) : _C.surface(isDark),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: active ? _C.accent(isDark) : _C.border(isDark))),
                  child: Text(s,
                    style: GoogleFonts.inter(fontSize: 12,
                      fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                      color: active ? Colors.white : _C.text2(isDark))),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        Text('${indexes.length} spécialiste${indexes.length > 1 ? 's' : ''}',
          style: GoogleFonts.inter(fontSize: 13, color: _C.text2(isDark))),
        const SizedBox(height: 12),

        ...indexes.map((i) {
          final doc = _doctors[i];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: GestureDetector(
              onTap: () => onDoctorTap(doc),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _C.surface(isDark),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: selectedMarker == i ? _C.accent(isDark) : _C.border(isDark),
                    width: selectedMarker == i ? 1.5 : 1,
                  ),
                  boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2))],
                ),
                child: Row(
                  children: [
                    _Avatar(initials: doc.initials, color: doc.avatarColor, size: 50),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Text(doc.name, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: _C.text1(isDark))),
                            const SizedBox(width: 4),
                            Icon(LucideIcons.badgeCheck, size: 13, color: _C.accent(isDark)),
                          ]),
                          const SizedBox(height: 2),
                          Text(doc.specialty, style: GoogleFonts.inter(fontSize: 12, color: _C.accent(isDark), fontWeight: FontWeight.w500)),
                          const SizedBox(height: 4),
                          Row(children: [
                            Icon(LucideIcons.mapPin, size: 12, color: _C.text3(isDark)),
                            const SizedBox(width: 4),
                            Text(doc.location, style: GoogleFonts.inter(fontSize: 12, color: _C.text2(isDark))),
                          ]),
                          const SizedBox(height: 4),
                          Row(children: [
                            Icon(LucideIcons.star, size: 12, color: const Color(0xFFF59E0B)),
                            const SizedBox(width: 3),
                            Text('${doc.rating}', style: GoogleFonts.inter(fontSize: 12, color: _C.text2(isDark), fontWeight: FontWeight.w600)),
                            const SizedBox(width: 10),
                            Icon(LucideIcons.users, size: 12, color: _C.text3(isDark)),
                            const SizedBox(width: 3),
                            Text('${doc.consultations} consultations', style: GoogleFonts.inter(fontSize: 12, color: _C.text3(isDark))),
                          ]),
                        ],
                      ),
                    ),
                    Container(
                      width: 38, height: 38,
                      decoration: BoxDecoration(
                        color: _C.accent(isDark).withOpacity(0.10),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(LucideIcons.phone, size: 16, color: _C.accent(isDark)),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}

// ─── Tunisia map painter ──────────────────────────────────────────────────────

class _TunisiaMapPainter extends CustomPainter {
  final bool isDark;
  final int? selectedMarker;
  final List<int> filteredIndexes;

  _TunisiaMapPainter({
    required this.isDark,
    required this.selectedMarker,
    required this.filteredIndexes,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Background
    final bgPaint = Paint()
      ..color = isDark ? const Color(0xFF0D1F14) : const Color(0xFFE8F4EE);
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), bgPaint);

    // Grid lines (subtle)
    final gridPaint = Paint()
      ..color = (isDark ? Colors.white : Colors.black).withOpacity(0.04)
      ..strokeWidth = 1;
    for (double x = 0; x < w; x += w / 8) {
      canvas.drawLine(Offset(x, 0), Offset(x, h), gridPaint);
    }
    for (double y = 0; y < h; y += h / 6) {
      canvas.drawLine(Offset(0, y), Offset(w, y), gridPaint);
    }

    // Tunisia silhouette (simplified polygon — approximate outline)
    final landPaint = Paint()
      ..color = isDark ? const Color(0xFF1A3828) : const Color(0xFFD0EADC);
    final borderPaint = Paint()
      ..color = isDark ? const Color(0xFF2E5A3E) : const Color(0xFF3DA85A).withOpacity(0.4)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final path = Path();
    // Normalized coords [0..1] → scaled to canvas
    // Rough Tunisia shape (north to south, ~37°N to 30°N lat, 8°E to 11.5°E lon)
    final pts = [
      (0.38, 0.05), (0.48, 0.04), (0.56, 0.08), (0.64, 0.06), (0.70, 0.10),
      (0.72, 0.16), (0.68, 0.22), (0.72, 0.28), (0.74, 0.35), (0.70, 0.42),
      (0.66, 0.48), (0.68, 0.55), (0.65, 0.62), (0.60, 0.68), (0.58, 0.76),
      (0.55, 0.84), (0.52, 0.90), (0.48, 0.95), (0.42, 0.97), (0.36, 0.94),
      (0.30, 0.88), (0.26, 0.80), (0.24, 0.72), (0.22, 0.62), (0.20, 0.52),
      (0.22, 0.44), (0.26, 0.36), (0.28, 0.28), (0.30, 0.20), (0.32, 0.13),
      (0.36, 0.07), (0.38, 0.05),
    ];
    path.moveTo(pts[0].$1 * w, pts[0].$2 * h);
    for (final p in pts.skip(1)) path.lineTo(p.$1 * w, p.$2 * h);
    path.close();
    canvas.drawPath(path, landPaint);
    canvas.drawPath(path, borderPaint);

    // City labels
    _drawCityLabel(canvas, w, h, 0.52, 0.28, 'Tunis', isDark);
    _drawCityLabel(canvas, w, h, 0.55, 0.45, 'Sousse', isDark);
    _drawCityLabel(canvas, w, h, 0.54, 0.62, 'Sfax', isDark);

    // Doctor markers
    for (int i = 0; i < _doctors.length; i++) {
      final pos = _doctorPositions[i];
      final cx = pos.x * w;
      // Offset duplicate Tunis doctors slightly
      final cy = pos.y * h + (i == 4 ? 20 : i == 3 ? -18 : 0);
      final doc = _doctors[i];
      final isSelected = selectedMarker == i;
      final isFiltered = filteredIndexes.contains(i);

      _drawMarker(canvas, cx, cy, doc.avatarColor,
        isSelected: isSelected, isFiltered: isFiltered);
    }
  }

  void _drawCityLabel(Canvas canvas, double w, double h, double nx, double ny, String label, bool dark) {
    final tp = TextPainter(
      text: TextSpan(text: label,
        style: TextStyle(
          color: (dark ? Colors.white : Colors.black).withOpacity(0.25),
          fontSize: 10,
          fontWeight: FontWeight.w500,
        )),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(nx * w + 4, ny * h - 10));
  }

  void _drawMarker(Canvas canvas, double cx, double cy, Color color,
      {required bool isSelected, required bool isFiltered}) {
    final alpha = isFiltered ? 1.0 : 0.3;

    // Shadow
    if (isSelected) {
      canvas.drawCircle(Offset(cx, cy), 22,
        Paint()..color = color.withOpacity(0.2));
    }

    // Pin circle
    final pinPaint = Paint()..color = color.withOpacity(alpha);
    canvas.drawCircle(Offset(cx, cy), isSelected ? 16 : 12, pinPaint);

    // White border
    canvas.drawCircle(Offset(cx, cy), isSelected ? 16 : 12,
      Paint()
        ..color = Colors.white.withOpacity(isSelected ? 0.9 : 0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = isSelected ? 2.5 : 1.5,
    );

    // Center dot
    canvas.drawCircle(Offset(cx, cy), isSelected ? 5 : 3,
      Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(_TunisiaMapPainter old) =>
      old.selectedMarker != selectedMarker || old.isDark != isDark ||
      old.filteredIndexes.length != filteredIndexes.length;
}

// ─── Marker popup (shown on selected pin) ────────────────────────────────────

class _MarkerPopup extends StatelessWidget {
  final _Doctor doctor;
  final ({double x, double y}) position;
  final int markerIndex;
  final bool isDark;
  final VoidCallback onTap;

  const _MarkerPopup({
    required this.doctor, required this.position,
    required this.markerIndex, required this.isDark, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Position popup above the marker
    return LayoutBuilder(builder: (_, constraints) {
      final cx = position.x * constraints.maxWidth;
      final cy = position.y * 280.0 + (markerIndex == 4 ? 20 : markerIndex == 3 ? -18 : 0);
      final popupW = 180.0;
      double left = cx - popupW / 2;
      left = left.clamp(8.0, constraints.maxWidth - popupW - 8);
      final top = (cy - 90).clamp(8.0, 200.0);

      return Positioned(
        left: left, top: top,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            width: popupW,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _C.border(isDark)),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 12, offset: const Offset(0, 4)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(children: [
                  Container(
                    width: 28, height: 28,
                    decoration: BoxDecoration(color: doctor.avatarColor, shape: BoxShape.circle),
                    child: Center(child: Text(doctor.initials,
                      style: GoogleFonts.outfit(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700))),
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Text(doctor.name,
                    style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : const Color(0xFF0D1117)),
                    maxLines: 1, overflow: TextOverflow.ellipsis)),
                ]),
                const SizedBox(height: 5),
                Text(doctor.specialty,
                  style: GoogleFonts.inter(fontSize: 10, color: isDark ? const Color(0xFF5CD57A) : const Color(0xFF1C4D30), fontWeight: FontWeight.w500)),
                const SizedBox(height: 3),
                Text(doctor.hospital,
                  style: GoogleFonts.inter(fontSize: 10, color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280))),
                const SizedBox(height: 7),
                Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  Text('Voir le profil',
                    style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600,
                      color: isDark ? const Color(0xFF5CD57A) : const Color(0xFF1C4D30))),
                  const SizedBox(width: 2),
                  Icon(Icons.chevron_right_rounded, size: 14,
                    color: isDark ? const Color(0xFF5CD57A) : const Color(0xFF1C4D30)),
                ]),
              ],
            ),
          ),
        ),
      );
    });
  }
}

// ─── Tab 5 : Mon Carnet ───────────────────────────────────────────────────────

class _CarnetTab extends StatelessWidget {
  final bool isDark;
  final TextEditingController weightCtrl;
  final TextEditingController bpCtrl;
  final List<Map<String, String>> entries;
  final ValueChanged<Map<String, String>> onSave;

  const _CarnetTab({
    required this.isDark, required this.weightCtrl,
    required this.bpCtrl, required this.entries, required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
      children: [
        // Metric entry form
        _SectionTitle(isDark: isDark, icon: LucideIcons.clipboardList, label: 'Saisir mes constantes'),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _C.surface(isDark),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _C.border(isDark)),
          ),
          child: Column(
            children: [
              _MetricField(isDark: isDark, ctrl: weightCtrl, label: 'Poids', hint: '62 kg', icon: LucideIcons.weight),
              const SizedBox(height: 12),
              _MetricField(isDark: isDark, ctrl: bpCtrl, label: 'Tension artérielle', hint: '120/80 mmHg', icon: LucideIcons.activity),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () {
                  if (weightCtrl.text.isEmpty && bpCtrl.text.isEmpty) return;
                  onSave({
                    'date': 'Aujourd\'hui',
                    'poids': weightCtrl.text,
                    'tension': bpCtrl.text,
                  });
                  weightCtrl.clear();
                  bpCtrl.clear();
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: _C.accent(isDark), borderRadius: BorderRadius.circular(10)),
                  child: Center(child: Text('Enregistrer',
                    style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white))),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Rappels
        _SectionTitle(isDark: isDark, icon: LucideIcons.bellRing, label: 'Rappels santé'),
        const SizedBox(height: 12),
        ..._rappels.map((r) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: _C.surface(isDark),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: r.done
                    ? _C.border(isDark)
                    : _C.accent(isDark).withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: r.done
                        ? _C.bg(isDark)
                        : _C.accent(isDark).withOpacity(0.10),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(r.icon, size: 16,
                    color: r.done ? _C.text3(isDark) : _C.accent(isDark)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(r.title,
                        style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600,
                          color: r.done ? _C.text3(isDark) : _C.text1(isDark),
                          decoration: r.done ? TextDecoration.lineThrough : null)),
                      Text(r.due,
                        style: GoogleFonts.inter(fontSize: 12,
                          color: r.done ? _C.text3(isDark) : _C.accent(isDark))),
                    ],
                  ),
                ),
                Icon(
                  r.done ? LucideIcons.circleCheck : LucideIcons.circle,
                  size: 18,
                  color: r.done ? _C.accent(isDark) : _C.text3(isDark),
                ),
              ],
            ),
          ),
        )),

        // Historique
        if (entries.isNotEmpty) ...[
          const SizedBox(height: 20),
          _SectionTitle(isDark: isDark, icon: LucideIcons.history, label: 'Historique'),
          const SizedBox(height: 12),
          ...entries.map((e) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _C.surface(isDark),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _C.border(isDark)),
              ),
              child: Row(children: [
                Text(e['date'] ?? '', style: GoogleFonts.inter(fontSize: 12, color: _C.text3(isDark))),
                const Spacer(),
                if ((e['poids'] ?? '').isNotEmpty)
                  _MetricChip(label: 'Poids', value: e['poids']!, isDark: isDark),
                if ((e['tension'] ?? '').isNotEmpty) ...[
                  const SizedBox(width: 8),
                  _MetricChip(label: 'TA', value: e['tension']!, isDark: isDark),
                ],
              ]),
            ),
          )),
        ],
      ],
    );
  }
}

// ─── Tab 2 : Ressources ───────────────────────────────────────────────────────

class _RessourcesTab extends StatelessWidget {
  final bool isDark;
  final String lexSearch;
  final ValueChanged<String> onLexSearch;

  const _RessourcesTab({required this.isDark, required this.lexSearch, required this.onLexSearch});

  List<_LexiqueEntry> get _filteredLex {
    if (lexSearch.isEmpty) return _lexique;
    final q = lexSearch.toLowerCase();
    return _lexique.where((e) =>
      e.term.toLowerCase().contains(q) || e.definition.toLowerCase().contains(q)
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(0, 16, 0, 110),
      children: [
        // Articles
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _SectionTitle(isDark: isDark, icon: LucideIcons.fileText, label: 'Articles de fond'),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 195,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: _articles.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, i) {
              final a = _articles[i];
              return Container(
                width: 240,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _C.surface(isDark),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _C.border(isDark)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: a.accentColor.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(6)),
                      child: Text(a.category,
                        style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: a.accentColor)),
                    ),
                    const SizedBox(height: 10),
                    Text(a.title,
                      maxLines: 2, overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w700,
                        color: _C.text1(isDark), height: 1.35)),
                    const SizedBox(height: 6),
                    Expanded(
                      child: Text(a.excerpt,
                        maxLines: 3, overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(fontSize: 12, color: _C.text2(isDark), height: 1.5)),
                    ),
                    const SizedBox(height: 10),
                    Row(children: [
                      Text(a.author, style: GoogleFonts.inter(fontSize: 11, color: _C.text3(isDark))),
                      const Spacer(),
                      Icon(LucideIcons.clock, size: 11, color: _C.text3(isDark)),
                      const SizedBox(width: 3),
                      Text('${a.readMin} min', style: GoogleFonts.inter(fontSize: 11, color: _C.text3(isDark))),
                    ]),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 24),

        // Podcasts
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _SectionTitle(isDark: isDark, icon: LucideIcons.mic, label: 'Écouter · Podcasts courts'),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: _podcasts.map((p) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: _C.surface(isDark),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _C.border(isDark)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(color: p.color, borderRadius: BorderRadius.circular(10)),
                      child: const Icon(LucideIcons.play, size: 18, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(p.title,
                            style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: _C.text1(isDark))),
                          const SizedBox(height: 2),
                          Text(p.doctor,
                            style: GoogleFonts.inter(fontSize: 11, color: _C.text2(isDark))),
                        ],
                      ),
                    ),
                    Text(p.duration, style: GoogleFonts.inter(fontSize: 12, color: _C.text3(isDark))),
                  ],
                ),
              ),
            )).toList(),
          ),
        ),
        const SizedBox(height: 24),

        // Lexique
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _SectionTitle(isDark: isDark, icon: LucideIcons.bookMarked, label: 'Lexique médical'),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            decoration: BoxDecoration(
              color: _C.surface(isDark),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _C.border(isDark)),
            ),
            child: TextField(
              onChanged: onLexSearch,
              style: GoogleFonts.inter(fontSize: 14, color: _C.text1(isDark)),
              decoration: InputDecoration(
                hintText: 'Rechercher un terme...',
                hintStyle: GoogleFonts.inter(fontSize: 14, color: _C.text3(isDark)),
                prefixIcon: Icon(LucideIcons.search, size: 16, color: _C.text3(isDark)),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: _filteredLex.map((entry) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: _C.surface(isDark),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _C.border(isDark)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Text(entry.term,
                        style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w700, color: _C.text1(isDark))),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: _C.accent(isDark).withOpacity(0.08),
                          borderRadius: BorderRadius.circular(6)),
                        child: Text(entry.category,
                          style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: _C.accent(isDark))),
                      ),
                    ]),
                    const SizedBox(height: 7),
                    Text(entry.definition,
                      style: GoogleFonts.inter(fontSize: 13, color: _C.text2(isDark), height: 1.55)),
                  ],
                ),
              ),
            )).toList(),
          ),
        ),
      ],
    );
  }
}

// ─── Doctor bottom sheet ──────────────────────────────────────────────────────

class _DoctorSheet extends StatelessWidget {
  final _Doctor doctor;
  final bool isDark;
  const _DoctorSheet({required this.doctor, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final sheetBg = isDark ? const Color(0xFF141414) : Colors.white;
    return Container(
      decoration: BoxDecoration(
        color: sheetBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(width: 36, height: 4,
            decoration: BoxDecoration(color: _C.border(isDark), borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 24),
          _Avatar(initials: doctor.initials, color: doctor.avatarColor, size: 72),
          const SizedBox(height: 14),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(doctor.name, style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w700, color: _C.text1(isDark))),
            const SizedBox(width: 6),
            Icon(LucideIcons.badgeCheck, size: 18, color: _C.accent(isDark)),
          ]),
          const SizedBox(height: 4),
          Text(doctor.specialty, style: GoogleFonts.inter(fontSize: 14, color: _C.text2(isDark))),
          const SizedBox(height: 16),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(LucideIcons.star, size: 14, color: const Color(0xFFF59E0B)),
            const SizedBox(width: 4),
            Text('${doctor.rating}', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: _C.text1(isDark))),
            const SizedBox(width: 16),
            Icon(LucideIcons.users, size: 14, color: _C.text3(isDark)),
            const SizedBox(width: 4),
            Text('${doctor.consultations} consultations', style: GoogleFonts.inter(fontSize: 13, color: _C.text2(isDark))),
          ]),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(children: [
              _InfoRow(isDark: isDark, icon: LucideIcons.building2, label: 'Établissement', value: doctor.hospital),
              const SizedBox(height: 12),
              _InfoRow(isDark: isDark, icon: LucideIcons.mapPin, label: 'Localisation', value: doctor.location),
              const SizedBox(height: 12),
              _InfoRow(isDark: isDark, icon: LucideIcons.phone, label: 'Téléphone', value: doctor.phone),
              const SizedBox(height: 12),
              _InfoRow(isDark: isDark, icon: LucideIcons.mail, label: 'Email', value: doctor.email),
            ]),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: _C.bg(isDark),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: _C.border(isDark)),
                    ),
                    child: Center(child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(LucideIcons.phone, size: 15, color: _C.accent(isDark)),
                      const SizedBox(width: 8),
                      Text('Appeler', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: _C.accent(isDark))),
                    ])),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: _C.accent(isDark), borderRadius: BorderRadius.circular(14)),
                    child: Center(child: Text('Rendez-vous',
                      style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white))),
                  ),
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}

// ─── Shared helpers ───────────────────────────────────────────────────────────

class _Avatar extends StatelessWidget {
  final String initials;
  final Color color;
  final double size;
  const _Avatar({required this.initials, required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: Center(
        child: Text(initials,
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontSize: size * 0.32,
            fontWeight: FontWeight.w700)),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final bool isDark;
  final IconData icon;
  final String label;
  const _SectionTitle({required this.isDark, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Icon(icon, size: 16, color: _C.accent(isDark)),
      const SizedBox(width: 8),
      Text(label, style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700, color: _C.text1(isDark))),
    ]);
  }
}

class _InfoRow extends StatelessWidget {
  final bool isDark;
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow({required this.isDark, required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(
        width: 38, height: 38,
        decoration: BoxDecoration(
          color: _C.bg(isDark), borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _C.border(isDark))),
        child: Icon(icon, size: 16, color: _C.text2(isDark)),
      ),
      const SizedBox(width: 14),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: GoogleFonts.inter(fontSize: 11, color: _C.text3(isDark), fontWeight: FontWeight.w500, letterSpacing: 0.3)),
        const SizedBox(height: 1),
        Text(value, style: GoogleFonts.inter(fontSize: 14, color: _C.text1(isDark), fontWeight: FontWeight.w500)),
      ]),
    ]);
  }
}

class _MetricField extends StatelessWidget {
  final bool isDark;
  final TextEditingController ctrl;
  final String label;
  final String hint;
  final IconData icon;
  const _MetricField({required this.isDark, required this.ctrl, required this.label, required this.hint, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: _C.bg(isDark), borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _C.border(isDark))),
      child: Row(children: [
        Icon(icon, size: 16, color: _C.text3(isDark)),
        const SizedBox(width: 10),
        Expanded(
          child: TextField(
            controller: ctrl,
            style: GoogleFonts.inter(fontSize: 14, color: _C.text1(isDark)),
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
              labelText: label,
              labelStyle: GoogleFonts.inter(fontSize: 12, color: _C.text3(isDark)),
              hintText: hint,
              hintStyle: GoogleFonts.inter(fontSize: 14, color: _C.text3(isDark)),
              border: InputBorder.none,
              isDense: true,
            ),
          ),
        ),
      ]),
    );
  }
}

class _MetricChip extends StatelessWidget {
  final String label;
  final String value;
  final bool isDark;
  const _MetricChip({required this.label, required this.value, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _C.accent(isDark).withOpacity(0.08),
        borderRadius: BorderRadius.circular(8)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
        Text(label, style: GoogleFonts.inter(fontSize: 10, color: _C.text3(isDark))),
        Text(value, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: _C.accent(isDark))),
      ]),
    );
  }
}
