// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

// ─── Design Tokens ───────────────────────────────────────────────────────────

class _C {
  _C._();
  static const main = Color(0xFF1C4D30);
  static const secondary = Color(0xFF7ABB98);

  static bool _dk(BuildContext c) => Theme.of(c).brightness == Brightness.dark;

  static Color bg(BuildContext c)       => _dk(c) ? const Color(0xFF0C0C0C) : const Color.fromARGB(255, 255, 255, 255);
  static Color card(BuildContext c)     => _dk(c) ? const Color(0xFF161616) : Colors.white;
  static Color t1(BuildContext c)       => _dk(c) ? const Color(0xFFF0F0F0) : const Color(0xFF1A1C1B);
  static Color t2(BuildContext c)       => _dk(c) ? const Color(0xFF999999) : const Color(0xFF5F6368);
  static Color t3(BuildContext c)       => _dk(c) ? const Color(0xFF555555) : const Color(0xFF9CA3AF);
  static Color accent(BuildContext c)   => _dk(c) ? secondary : main;
  static Color accentBg(BuildContext c) => _dk(c) ? main.withOpacity(0.12) : const Color(0xFFEDF5F0);
  static Color border(BuildContext c)   => _dk(c) ? const Color(0xFF222222) : const Color.fromARGB(255, 255, 255, 255);
  static Color field(BuildContext c)    => _dk(c) ? const Color(0xFF1E1E1E) : const Color.fromARGB(255, 255, 255, 255);

  static List<BoxShadow> cardShadow(BuildContext c) => _dk(c)
    ? [] : [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 4))];
}

// ─── Models ──────────────────────────────────────────────────────────────────

class QrQuestion {
  final String question;
  final String? description;
  final String category;
  final String postedAgo;
  final int votes;
  final List<QrAnswer> answers;

  const QrQuestion({
    required this.question,
    this.description,
    this.category = '',
    required this.postedAgo,
    required this.votes,
    this.answers = const [],
  });

  int get replyCount => answers.length;
  bool get hasAnswer => answers.isNotEmpty;
}

class QrAnswer {
  final String doctorName;
  final String specialty;
  final String answer;
  final String answeredAgo;
  final int helpfulCount;
  final int yearsExp;
  final String? hospital;

  const QrAnswer({
    required this.doctorName,
    required this.specialty,
    required this.answer,
    this.answeredAgo = '',
    this.helpfulCount = 0,
    this.yearsExp = 0,
    this.hospital,
  });
}

// ─── Categories ──────────────────────────────────────────────────────────────

class _Cat {
  final String label;
  final IconData icon;
  final Color color;
  const _Cat(this.label, this.icon, this.color);
}

const _categories = [
  _Cat('Tout',        LucideIcons.layoutGrid,            Color(0xFF6B7280)),
  _Cat('Cycle',       LucideIcons.moon,                  Color(0xFF7C3AED)),
  _Cat('Grossesse',   LucideIcons.baby,                  Color(0xFFDB2777)),
  _Cat('Nutrition',   LucideIcons.apple,                 Color(0xFFB45309)),
  _Cat('SOPK',        LucideIcons.ribbon,                Color(0xFF0369A1)),
  _Cat('Hormones',    LucideIcons.activity,              Color(0xFF059669)),
  _Cat('Mental',      LucideIcons.brain,                 Color(0xFF6366F1)),
  _Cat('Fitness',     LucideIcons.dumbbell,              Color(0xFFEA580C)),
  _Cat('Sommeil',     LucideIcons.bedDouble,             Color(0xFF8B5CF6)),
];

String _initial(String name) {
  if (name.isEmpty) return '?';
  final parts = name.split(' ');
  return parts.last[0].toUpperCase();
}

Color _catColor(String cat) {
  for (final c in _categories) {
    if (c.label == cat) return c.color;
  }
  return const Color(0xFF6B7280);
}

// ─── Sample Data ─────────────────────────────────────────────────────────────

const _sampleQuestions = [
  QrQuestion(
    question: 'Est-ce normal d\'avoir des crampes pendant toute la semaine des règles ?',
    description: 'J\'ai des crampes très douloureuses qui durent toute la semaine, pas seulement les premiers jours. Est-ce que je devrais consulter ?',
    category: 'Cycle',
    postedAgo: 'il y a 1h',
    votes: 34,
    answers: [
      QrAnswer(
        doctorName: 'Dr. Sarah Mansouri',
        specialty: 'Gynécologue',
        answer: 'Des douleurs modérées sont normales, mais des crampes invalidantes sur toute la semaine peuvent indiquer une dysménorrhée secondaire. Je vous recommande de consulter un gynécologue pour un examen complet, notamment une échographie pelvienne.',
        answeredAgo: 'il y a 45min',
        helpfulCount: 28,
        yearsExp: 12,
        hospital: 'Clinique Les Jasmins',
      ),
    ],
  ),
  QrQuestion(
    question: 'Mon médecin m\'a prescrit de la progestérone naturelle, y a-t-il des effets secondaires ?',
    category: 'Hormones',
    postedAgo: 'il y a 3h',
    votes: 21,
    answers: [
      QrAnswer(
        doctorName: 'Dr. Karim Belhadj',
        specialty: 'Endocrinologue',
        answer: 'La progestérone naturelle micronisée est très bien tolérée. Les effets possibles incluent une légère somnolence — je recommande de la prendre le soir. Des nausées rares peuvent survenir mais disparaissent après quelques semaines.',
        answeredAgo: 'il y a 2h',
        helpfulCount: 15,
        yearsExp: 18,
        hospital: 'Hôpital Charles Nicolle',
      ),
    ],
  ),
  QrQuestion(
    question: 'Je fais du sport 5 fois par semaine mais je prends du poids. Pourquoi ?',
    description: 'Je mange sainement et je m\'entraîne régulièrement, mais la balance ne bouge pas dans le bon sens.',
    category: 'Fitness',
    postedAgo: 'il y a 6h',
    votes: 57,
  ),
  QrQuestion(
    question: 'Quelle est la différence entre SOPK et endométriose ?',
    category: 'SOPK',
    postedAgo: 'il y a 1j',
    votes: 89,
    answers: [
      QrAnswer(
        doctorName: 'Dr. Sarah Mansouri',
        specialty: 'Gynécologue',
        answer: 'Le SOPK est un trouble hormonal affectant l\'ovulation, caractérisé par un excès d\'androgènes. L\'endométriose est une maladie inflammatoire où du tissu semblable à la muqueuse utérine se développe à l\'extérieur de l\'utérus. Elles peuvent coexister mais sont deux conditions distinctes.',
        answeredAgo: 'il y a 20h',
        helpfulCount: 72,
        yearsExp: 12,
        hospital: 'Clinique Les Jasmins',
      ),
    ],
  ),
];

// ─── Filters ─────────────────────────────────────────────────────────────────

enum _Filter { newest, helpful, answered, unanswered }

extension _FilterLabel on _Filter {
  String get label {
    switch (this) {
      case _Filter.newest:     return 'Récentes';
      case _Filter.helpful:    return 'Plus utiles';
      case _Filter.answered:   return 'Répondues';
      case _Filter.unanswered: return 'En attente';
    }
  }
}

// ═════════════════════════════════════════════════════════════════════════════
//  1 · FEED TAB
// ═════════════════════════════════════════════════════════════════════════════

class QrFeedTab extends StatefulWidget {
  final List<QrQuestion>? questions;
  final Future<void> Function(String text)? onSubmit;
  const QrFeedTab({super.key, this.questions, this.onSubmit});
  @override
  State<QrFeedTab> createState() => _QrFeedTabState();
}

class _QrFeedTabState extends State<QrFeedTab> {
  String _selectedCat = 'Tout';
  _Filter _filter = _Filter.newest;
  final _searchCtrl = TextEditingController();
  bool _searching = false;

  @override
  void dispose() { _searchCtrl.dispose(); super.dispose(); }

  List<QrQuestion> get _filtered {
    var list = widget.questions ?? _sampleQuestions;
    if (_selectedCat != 'Tout') {
      list = list.where((q) => q.category == _selectedCat).toList();
    }
    final query = _searchCtrl.text.trim().toLowerCase();
    if (query.isNotEmpty) {
      list = list.where((q) => q.question.toLowerCase().contains(query)).toList();
    }
    switch (_filter) {
      case _Filter.newest:     break;
      case _Filter.helpful:    list = List.of(list)..sort((a, b) => b.votes.compareTo(a.votes));
      case _Filter.answered:   list = list.where((q) => q.hasAnswer).toList();
      case _Filter.unanswered: list = list.where((q) => !q.hasAnswer).toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final items = _filtered;
    return Stack(children: [
      ListView(
        padding: const EdgeInsets.fromLTRB(0, 8, 0, 100),
        children: [
          // Search
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _buildSearch(context),
          ),
          const SizedBox(height: 16),
          // Categories
          _buildCategoryChips(context),
          const SizedBox(height: 12),
          // Filters
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _buildFilters(context),
          ),
          const SizedBox(height: 16),
          // Content
          if (items.isEmpty)
            _EmptyState(
              searching: _searching || _selectedCat != 'Tout',
              onReset: () => setState(() {
                _selectedCat = 'Tout';
                _searchCtrl.clear();
                _searching = false;
              }),
            )
          else
            ...items.map((q) => Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
              child: _QuestionCard(
                question: q,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => QrDetailScreen(question: q)),
                ),
              ),
            )),
        ],
      ),
      // FAB
      Positioned(
        bottom: 24, left: 20, right: 20,
        child: GestureDetector(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => QrAskScreen(onSubmit: widget.onSubmit)),
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: _C.accent(context),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: _C.main.withOpacity(0.25), blurRadius: 20, offset: const Offset(0, 6)),
              ],
            ),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(LucideIcons.penLine, size: 16, color: Colors.white),
              const SizedBox(width: 10),
              Text('Poser une question anonyme', style: GoogleFonts.inter(
                fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
            ]),
          ),
        ),
      ),
    ]);
  }

  Widget _buildSearch(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: _C.field(context),
        borderRadius: BorderRadius.circular(14)),
      child: TextField(
        controller: _searchCtrl,
        onChanged: (v) => setState(() => _searching = v.isNotEmpty),
        style: GoogleFonts.inter(fontSize: 14, color: _C.t1(context)),
        decoration: InputDecoration(
          hintText: 'Rechercher une question…',
          hintStyle: GoogleFonts.inter(fontSize: 14, color: _C.t3(context)),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 14, right: 10),
            child: Icon(LucideIcons.search, size: 18, color: _C.t3(context)),
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12)),
      ),
    );
  }

  Widget _buildCategoryChips(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final cat = _categories[i];
          final active = _selectedCat == cat.label;
          return GestureDetector(
            onTap: () => setState(() => _selectedCat = cat.label),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: active ? _C.accent(context) : _C.card(context),
                borderRadius: BorderRadius.circular(20),
                border: active ? null : Border.all(color: _C.border(context))),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(cat.icon, size: 14,
                  color: active ? Colors.white : cat.color),
                const SizedBox(width: 6),
                Text(cat.label, style: GoogleFonts.inter(
                  fontSize: 12, fontWeight: FontWeight.w600,
                  color: active ? Colors.white : _C.t2(context))),
              ]),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilters(BuildContext context) {
    final isDefault = _filter == _Filter.newest;
    return GestureDetector(
      onTap: () => _showFilterSheet(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isDefault ? _C.field(context) : _C.accentBg(context),
          borderRadius: BorderRadius.circular(12),
          border: isDefault ? null : Border.all(color: _C.accent(context).withOpacity(0.3))),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(LucideIcons.slidersHorizontal, size: 14,
            color: isDefault ? _C.t3(context) : _C.accent(context)),
          const SizedBox(width: 8),
          Text(isDefault ? 'Filtres' : _filter.label, style: GoogleFonts.inter(
            fontSize: 12, fontWeight: FontWeight.w600,
            color: isDefault ? _C.t2(context) : _C.accent(context))),
          if (!isDefault) ...[
            const SizedBox(width: 6),
            GestureDetector(
              onTap: () => setState(() => _filter = _Filter.newest),
              child: Icon(LucideIcons.x, size: 14, color: _C.accent(context)),
            ),
          ],
        ]),
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: _C.card(context),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const SizedBox(height: 12),
          Container(width: 40, height: 4,
            decoration: BoxDecoration(
              color: _C.border(context),
              borderRadius: BorderRadius.circular(2))),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
            child: Row(children: [
              Text('Trier par', style: GoogleFonts.outfit(
                fontSize: 18, fontWeight: FontWeight.w700, color: _C.t1(context))),
            ]),
          ),
          ..._Filter.values.map((f) {
            final active = _filter == f;
            final IconData icon;
            switch (f) {
              case _Filter.newest:     icon = LucideIcons.clock;
              case _Filter.helpful:    icon = LucideIcons.thumbsUp;
              case _Filter.answered:   icon = LucideIcons.badgeCheck;
              case _Filter.unanswered: icon = LucideIcons.messageCircleQuestion;
            }
            return GestureDetector(
              onTap: () {
                setState(() => _filter = f);
                Navigator.pop(context);
              },
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                child: Row(children: [
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: active
                        ? _C.accentBg(context)
                        : _C.field(context),
                      borderRadius: BorderRadius.circular(10)),
                    child: Icon(icon, size: 16,
                      color: active ? _C.accent(context) : _C.t3(context)),
                  ),
                  const SizedBox(width: 14),
                  Expanded(child: Text(f.label, style: GoogleFonts.inter(
                    fontSize: 15, fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                    color: active ? _C.accent(context) : _C.t1(context)))),
                  if (active)
                    Icon(LucideIcons.check, size: 18, color: _C.accent(context)),
                ]),
              ),
            );
          }),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
        ]),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
//  QUESTION CARD
// ═════════════════════════════════════════════════════════════════════════════

class _QuestionCard extends StatelessWidget {
  final QrQuestion question;
  final VoidCallback onTap;
  const _QuestionCard({required this.question, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final q = question;
    final catColor = _catColor(q.category);
    final dk = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _C.card(context),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _C.border(context)),
          boxShadow: _C.cardShadow(context)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Top row: category + time
          Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: catColor.withOpacity(dk ? 0.15 : 0.08),
                borderRadius: BorderRadius.circular(10)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Container(width: 6, height: 6,
                  decoration: BoxDecoration(color: catColor, shape: BoxShape.circle)),
                const SizedBox(width: 6),
                Text(q.category, style: GoogleFonts.inter(
                  fontSize: 11, fontWeight: FontWeight.w600, color: catColor)),
              ]),
            ),
            const Spacer(),
            Text(q.postedAgo, style: GoogleFonts.inter(
              fontSize: 11, color: _C.t3(context))),
          ]),

          const SizedBox(height: 14),

          // Question
          Text(q.question, style: GoogleFonts.inter(
            fontSize: 15, fontWeight: FontWeight.w600,
            color: _C.t1(context), height: 1.45),
            maxLines: 3, overflow: TextOverflow.ellipsis),

          // Doctor answer preview
          if (q.hasAnswer) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _C.accentBg(context),
                borderRadius: BorderRadius.circular(14)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  // Doctor avatar
                  Container(
                    width: 28, height: 28,
                    decoration: BoxDecoration(
                      color: _C.accent(context).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8)),
                    child: Center(child: Text(
                      _initial(q.answers.first.doctorName),
                      style: GoogleFonts.inter(
                        fontSize: 11, fontWeight: FontWeight.w700,
                        color: _C.accent(context)))),
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        Flexible(child: Text(q.answers.first.doctorName,
                          style: GoogleFonts.inter(
                            fontSize: 12, fontWeight: FontWeight.w600,
                            color: _C.accent(context)),
                          overflow: TextOverflow.ellipsis)),
                        const SizedBox(width: 4),
                        Icon(LucideIcons.badgeCheck, size: 12,
                          color: _C.accent(context)),
                      ]),
                      Text(q.answers.first.specialty, style: GoogleFonts.inter(
                        fontSize: 11, color: _C.t3(context))),
                    ],
                  )),
                ]),
                const SizedBox(height: 10),
                Text(q.answers.first.answer, style: GoogleFonts.inter(
                  fontSize: 13, color: _C.t2(context), height: 1.5),
                  maxLines: 2, overflow: TextOverflow.ellipsis),
              ]),
            ),
          ] else ...[
            const SizedBox(height: 12),
            Row(children: [
              Container(
                width: 6, height: 6,
                decoration: BoxDecoration(
                  color: const Color(0xFFFBBF24), shape: BoxShape.circle)),
              const SizedBox(width: 6),
              Text('En attente de réponse', style: GoogleFonts.inter(
                fontSize: 12, color: _C.t3(context), fontStyle: FontStyle.italic)),
            ]),
          ],

          const SizedBox(height: 16),

          // Footer
          Row(children: [
            Icon(LucideIcons.arrowBigUp, size: 16, color: _C.t3(context)),
            const SizedBox(width: 4),
            Text('${q.votes}', style: GoogleFonts.inter(
              fontSize: 12, fontWeight: FontWeight.w500, color: _C.t3(context))),
            const SizedBox(width: 16),
            Icon(LucideIcons.messageCircle, size: 14, color: _C.t3(context)),
            const SizedBox(width: 4),
            Text('${q.replyCount}', style: GoogleFonts.inter(
              fontSize: 12, fontWeight: FontWeight.w500, color: _C.t3(context))),
            const Spacer(),
            Text('Voir', style: GoogleFonts.inter(
              fontSize: 12, fontWeight: FontWeight.w500, color: _C.accent(context))),
            const SizedBox(width: 2),
            Icon(LucideIcons.chevronRight, size: 14, color: _C.accent(context)),
          ]),
        ]),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
//  EMPTY STATE
// ═════════════════════════════════════════════════════════════════════════════

class _EmptyState extends StatelessWidget {
  final bool searching;
  final VoidCallback? onReset;
  const _EmptyState({this.searching = false, this.onReset});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 60),
      child: Column(children: [
        Container(
          width: 72, height: 72,
          decoration: BoxDecoration(
            color: _C.accentBg(context),
            shape: BoxShape.circle),
          child: Icon(
            searching ? LucideIcons.searchX : LucideIcons.messageCircleQuestion,
            size: 28, color: _C.accent(context)),
        ),
        const SizedBox(height: 20),
        Text(
          searching ? 'Aucun résultat' : 'Aucune question',
          style: GoogleFonts.outfit(
            fontSize: 18, fontWeight: FontWeight.w700, color: _C.t1(context)),
        ),
        const SizedBox(height: 8),
        Text(
          searching
            ? 'Essayez avec d\'autres termes ou réinitialisez les filtres.'
            : 'Soyez la première à poser une question à nos médecins.',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 14, color: _C.t2(context), height: 1.5),
        ),
        if (searching && onReset != null) ...[
          const SizedBox(height: 20),
          GestureDetector(
            onTap: onReset,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                border: Border.all(color: _C.border(context)),
                borderRadius: BorderRadius.circular(12)),
              child: Text('Réinitialiser', style: GoogleFonts.inter(
                fontSize: 13, fontWeight: FontWeight.w500, color: _C.t2(context))),
            ),
          ),
        ],
      ]),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
//  SKELETON LOADING
// ═════════════════════════════════════════════════════════════════════════════

class QrSkeletonCard extends StatelessWidget {
  const QrSkeletonCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _C.card(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _C.border(context))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          _bone(context, 60, 22, radius: 10),
          const Spacer(),
          _bone(context, 50, 14),
        ]),
        const SizedBox(height: 16),
        _bone(context, double.infinity, 16),
        const SizedBox(height: 8),
        _bone(context, 200, 16),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _C.field(context),
            borderRadius: BorderRadius.circular(14)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              _bone(context, 28, 28, radius: 8),
              const SizedBox(width: 10),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _bone(context, 100, 12),
                const SizedBox(height: 4),
                _bone(context, 60, 10),
              ]),
            ]),
            const SizedBox(height: 12),
            _bone(context, double.infinity, 12),
            const SizedBox(height: 6),
            _bone(context, 160, 12),
          ]),
        ),
        const SizedBox(height: 16),
        Row(children: [
          _bone(context, 40, 14),
          const SizedBox(width: 16),
          _bone(context, 30, 14),
        ]),
      ]),
    );
  }

  Widget _bone(BuildContext c, double w, double h, {double radius = 6}) {
    return Container(
      width: w, height: h,
      decoration: BoxDecoration(
        color: _C.field(c),
        borderRadius: BorderRadius.circular(radius)),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
//  2 · QUESTION DETAIL SCREEN
// ═════════════════════════════════════════════════════════════════════════════

class QrDetailScreen extends StatefulWidget {
  final QrQuestion question;
  const QrDetailScreen({super.key, required this.question});
  @override
  State<QrDetailScreen> createState() => _QrDetailScreenState();
}

class _QrDetailScreenState extends State<QrDetailScreen> {
  final Set<int> _helpful = {};
  bool _saved = false;

  @override
  Widget build(BuildContext context) {
    final q = widget.question;
    final top = MediaQuery.of(context).padding.top;
    final bot = MediaQuery.of(context).padding.bottom;
    final catColor = _catColor(q.category);

    return Scaffold(
      backgroundColor: _C.bg(context),
      body: Column(children: [
        // App bar
        Container(
          color: _C.bg(context),
          padding: EdgeInsets.fromLTRB(8, top + 4, 8, 8),
          child: Row(children: [
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(LucideIcons.chevronLeft, size: 22, color: _C.t1(context))),
            const Spacer(),
            IconButton(
              onPressed: () => setState(() => _saved = !_saved),
              icon: Icon(
                _saved ? LucideIcons.bookmarkCheck : LucideIcons.bookmark,
                size: 20, color: _saved ? _C.accent(context) : _C.t3(context))),
            IconButton(
              onPressed: () {},
              icon: Icon(LucideIcons.share2, size: 18, color: _C.t3(context))),
          ]),
        ),
        // Content
        Expanded(
          child: ListView(
            padding: EdgeInsets.fromLTRB(20, 8, 20, bot + 24),
            children: [
              // Anonymous badge + time
              Row(children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: _C.field(context),
                    borderRadius: BorderRadius.circular(10)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(LucideIcons.eyeOff, size: 12, color: _C.t3(context)),
                    const SizedBox(width: 5),
                    Text('Anonyme', style: GoogleFonts.inter(
                      fontSize: 12, fontWeight: FontWeight.w500, color: _C.t2(context))),
                  ]),
                ),
                const SizedBox(width: 8),
                Text(q.postedAgo, style: GoogleFonts.inter(
                  fontSize: 12, color: _C.t3(context))),
              ]),
              const SizedBox(height: 12),
              // Category
              Row(children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: catColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10)),
                  child: Text(q.category, style: GoogleFonts.inter(
                    fontSize: 11, fontWeight: FontWeight.w600, color: catColor)),
                ),
              ]),
              const SizedBox(height: 16),
              // Title
              Text(q.question, style: GoogleFonts.outfit(
                fontSize: 22, fontWeight: FontWeight.w700,
                color: _C.t1(context), height: 1.3)),
              // Description
              if (q.description != null) ...[
                const SizedBox(height: 12),
                Text(q.description!, style: GoogleFonts.inter(
                  fontSize: 14, color: _C.t2(context), height: 1.6)),
              ],
              const SizedBox(height: 16),
              // Actions bar
              Row(children: [
                _actionBtn(context, LucideIcons.arrowBigUp, '${q.votes}', false),
                const SizedBox(width: 6),
                _actionBtn(context, LucideIcons.messageCircle, '${q.replyCount}', false),
                const Spacer(),
                GestureDetector(
                  onTap: () {},
                  child: Icon(LucideIcons.flag, size: 16, color: _C.t3(context)),
                ),
              ]),
              const SizedBox(height: 24),
              // Answers header
              Container(height: 1, color: _C.border(context)),
              const SizedBox(height: 24),
              Row(children: [
                Text(
                  q.hasAnswer
                    ? '${q.answers.length} réponse${q.answers.length > 1 ? 's' : ''} de médecins'
                    : 'En attente de réponse',
                  style: GoogleFonts.outfit(
                    fontSize: 16, fontWeight: FontWeight.w700, color: _C.t1(context)),
                ),
              ]),
              const SizedBox(height: 16),
              // Doctor answers
              if (q.hasAnswer)
                ...q.answers.asMap().entries.map((e) {
                  final idx = e.key;
                  final a = e.value;
                  final liked = _helpful.contains(idx);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _DoctorAnswerCard(
                      answer: a,
                      liked: liked,
                      onLike: () => setState(() {
                        if (liked) _helpful.remove(idx);
                        else _helpful.add(idx);
                      }),
                      onDoctorTap: () => _showDoctorProfile(context, a),
                    ),
                  );
                })
              else
                _buildAwaitingCard(context),
              const SizedBox(height: 24),
              // Similar questions
              Text('Questions similaires', style: GoogleFonts.outfit(
                fontSize: 16, fontWeight: FontWeight.w700, color: _C.t1(context))),
              const SizedBox(height: 12),
              ..._sampleQuestions
                .where((sq) => sq.question != q.question)
                .take(2)
                .map((sq) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => QrDetailScreen(question: sq))),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _C.card(context),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: _C.border(context))),
                      child: Row(children: [
                        Expanded(child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(sq.question, style: GoogleFonts.inter(
                              fontSize: 13, fontWeight: FontWeight.w500,
                              color: _C.t1(context), height: 1.4),
                              maxLines: 2, overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 6),
                            Row(children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: _catColor(sq.category).withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(6)),
                                child: Text(sq.category, style: GoogleFonts.inter(
                                  fontSize: 10, fontWeight: FontWeight.w600,
                                  color: _catColor(sq.category))),
                              ),
                              const SizedBox(width: 8),
                              if (sq.hasAnswer)
                                Icon(LucideIcons.badgeCheck, size: 12,
                                  color: _C.accent(context)),
                            ]),
                          ],
                        )),
                        const SizedBox(width: 8),
                        Icon(LucideIcons.chevronRight, size: 16, color: _C.t3(context)),
                      ]),
                    ),
                  ),
                )),
            ],
          ),
        ),
      ]),
    );
  }

  Widget _actionBtn(BuildContext context, IconData icon, String label, bool active) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: active ? _C.accentBg(context) : _C.field(context),
        borderRadius: BorderRadius.circular(10)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 15, color: active ? _C.accent(context) : _C.t3(context)),
        const SizedBox(width: 5),
        Text(label, style: GoogleFonts.inter(
          fontSize: 12, fontWeight: FontWeight.w500,
          color: active ? _C.accent(context) : _C.t3(context))),
      ]),
    );
  }

  Widget _buildAwaitingCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _C.card(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _C.border(context))),
      child: Column(children: [
        Container(
          width: 48, height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFFFEF3C7),
            shape: BoxShape.circle),
          child: const Icon(LucideIcons.clock, size: 22, color: Color(0xFFF59E0B)),
        ),
        const SizedBox(height: 14),
        Text('En attente de réponse', style: GoogleFonts.inter(
          fontSize: 14, fontWeight: FontWeight.w600, color: _C.t1(context))),
        const SizedBox(height: 6),
        Text('Un médecin répondra bientôt à cette question.',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(fontSize: 13, color: _C.t2(context), height: 1.5)),
      ]),
    );
  }

  void _showDoctorProfile(BuildContext context, QrAnswer a) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _DoctorProfileSheet(answer: a),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
//  DOCTOR ANSWER CARD
// ═════════════════════════════════════════════════════════════════════════════

class _DoctorAnswerCard extends StatelessWidget {
  final QrAnswer answer;
  final bool liked;
  final VoidCallback onLike;
  final VoidCallback? onDoctorTap;
  const _DoctorAnswerCard({
    required this.answer, required this.liked,
    required this.onLike, this.onDoctorTap});

  @override
  Widget build(BuildContext context) {
    final a = answer;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _C.card(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _C.border(context)),
        boxShadow: _C.cardShadow(context)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Doctor header
        GestureDetector(
          onTap: onDoctorTap,
          child: Row(children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: _C.accentBg(context),
                borderRadius: BorderRadius.circular(14)),
              child: Center(child: Text(
                _initial(a.doctorName),
                style: GoogleFonts.outfit(
                  fontSize: 17, fontWeight: FontWeight.w700,
                  color: _C.accent(context)))),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Flexible(child: Text(a.doctorName,
                    style: GoogleFonts.inter(
                      fontSize: 14, fontWeight: FontWeight.w600, color: _C.t1(context)),
                    overflow: TextOverflow.ellipsis)),
                  const SizedBox(width: 5),
                  Icon(LucideIcons.badgeCheck, size: 14, color: _C.accent(context)),
                ]),
                const SizedBox(height: 2),
                Text('${a.specialty}${a.yearsExp > 0 ? ' · ${a.yearsExp} ans' : ''}',
                  style: GoogleFonts.inter(fontSize: 12, color: _C.t2(context))),
                if (a.hospital != null)
                  Text(a.hospital!, style: GoogleFonts.inter(
                    fontSize: 11, color: _C.t3(context))),
              ],
            )),
            Icon(LucideIcons.chevronRight, size: 16, color: _C.t3(context)),
          ]),
        ),
        const SizedBox(height: 16),
        // Answer text
        Text(a.answer, style: GoogleFonts.inter(
          fontSize: 14, color: _C.t1(context), height: 1.65)),
        const SizedBox(height: 16),
        // Footer
        Row(children: [
          GestureDetector(
            onTap: onLike,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: liked ? _C.accentBg(context) : _C.field(context),
                borderRadius: BorderRadius.circular(10),
                border: liked ? Border.all(color: _C.accent(context).withOpacity(0.3)) : null),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(LucideIcons.thumbsUp, size: 14,
                  color: liked ? _C.accent(context) : _C.t3(context)),
                const SizedBox(width: 5),
                Text('Utile · ${a.helpfulCount + (liked ? 1 : 0)}',
                  style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500,
                    color: liked ? _C.accent(context) : _C.t3(context))),
              ]),
            ),
          ),
          const Spacer(),
          if (a.answeredAgo.isNotEmpty)
            Text(a.answeredAgo, style: GoogleFonts.inter(
              fontSize: 11, color: _C.t3(context))),
        ]),
      ]),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
//  DOCTOR PROFILE SHEET
// ═════════════════════════════════════════════════════════════════════════════

class _DoctorProfileSheet extends StatelessWidget {
  final QrAnswer answer;
  const _DoctorProfileSheet({required this.answer});

  @override
  Widget build(BuildContext context) {
    final a = answer;
    final bot = MediaQuery.of(context).padding.bottom;
    return Container(
      margin: const EdgeInsets.only(top: 80),
      decoration: BoxDecoration(
        color: _C.card(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28))),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const SizedBox(height: 12),
        Container(width: 40, height: 4,
          decoration: BoxDecoration(
            color: _C.border(context),
            borderRadius: BorderRadius.circular(2))),
        Padding(
          padding: EdgeInsets.fromLTRB(24, 28, 24, bot + 24),
          child: Column(children: [
            // Avatar
            Container(
              width: 72, height: 72,
              decoration: BoxDecoration(
                color: _C.accentBg(context),
                borderRadius: BorderRadius.circular(22)),
              child: Center(child: Text(
                _initial(a.doctorName),
                style: GoogleFonts.outfit(
                  fontSize: 28, fontWeight: FontWeight.w700,
                  color: _C.accent(context)))),
            ),
            const SizedBox(height: 16),
            // Name + verified
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(a.doctorName, style: GoogleFonts.outfit(
                fontSize: 20, fontWeight: FontWeight.w700, color: _C.t1(context))),
              const SizedBox(width: 6),
              Icon(LucideIcons.badgeCheck, size: 18, color: _C.accent(context)),
            ]),
            const SizedBox(height: 4),
            Text(a.specialty, style: GoogleFonts.inter(
              fontSize: 14, color: _C.t2(context))),
            if (a.hospital != null) ...[
              const SizedBox(height: 2),
              Text(a.hospital!, style: GoogleFonts.inter(
                fontSize: 13, color: _C.t3(context))),
            ],
            const SizedBox(height: 24),
            // Stats row
            Row(children: [
              _stat(context, '${a.yearsExp}', 'ans d\'exp.'),
              Container(width: 1, height: 32, color: _C.border(context)),
              _stat(context, '${a.helpfulCount}', 'réponses'),
              Container(width: 1, height: 32, color: _C.border(context)),
              _stat(context, '4.9', 'note'),
            ]),
            const SizedBox(height: 24),
            // Button
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: _C.field(context),
                  borderRadius: BorderRadius.circular(14)),
                child: Center(child: Text('Voir toutes les réponses',
                  style: GoogleFonts.inter(
                    fontSize: 14, fontWeight: FontWeight.w600, color: _C.t1(context)))),
              ),
            ),
          ]),
        ),
      ]),
    );
  }

  Widget _stat(BuildContext context, String value, String label) {
    return Expanded(child: Column(children: [
      Text(value, style: GoogleFonts.outfit(
        fontSize: 20, fontWeight: FontWeight.w700, color: _C.t1(context))),
      const SizedBox(height: 2),
      Text(label, style: GoogleFonts.inter(
        fontSize: 11, color: _C.t3(context))),
    ]));
  }
}

// ═════════════════════════════════════════════════════════════════════════════
//  3 · ASK QUESTION SCREEN
// ═════════════════════════════════════════════════════════════════════════════

class QrAskScreen extends StatefulWidget {
  final Future<void> Function(String text)? onSubmit;
  const QrAskScreen({super.key, this.onSubmit});
  @override
  State<QrAskScreen> createState() => _QrAskScreenState();
}

class _QrAskScreenState extends State<QrAskScreen> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  String _category = '';
  bool _sending = false;
  static const _maxDesc = 500;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  bool get _canSubmit => _titleCtrl.text.trim().isNotEmpty && _category.isNotEmpty && !_sending;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    final bot = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: _C.bg(context),
      body: Column(children: [
        // Header
        Container(
          color: _C.bg(context),
          padding: EdgeInsets.fromLTRB(8, top + 4, 8, 8),
          child: Row(children: [
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(LucideIcons.x, size: 22, color: _C.t1(context))),
            Expanded(child: Text('Nouvelle question', textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 17, fontWeight: FontWeight.w700, color: _C.t1(context)))),
            GestureDetector(
              onTap: _canSubmit ? _submit : null,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: _canSubmit ? _C.accent(context) : _C.field(context),
                  borderRadius: BorderRadius.circular(10)),
                child: Text('Publier', style: GoogleFonts.inter(
                  fontSize: 13, fontWeight: FontWeight.w600,
                  color: _canSubmit ? Colors.white : _C.t3(context))),
              ),
            ),
          ]),
        ),
        Container(height: 1, color: _C.border(context)),
        // Form
        Expanded(
          child: ListView(
            padding: EdgeInsets.fromLTRB(20, 24, 20, bot + 24),
            children: [
              // Category
              Text('Catégorie', style: GoogleFonts.inter(
                fontSize: 13, fontWeight: FontWeight.w600, color: _C.t1(context))),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8, runSpacing: 8,
                children: _categories.skip(1).map((cat) {
                  final active = _category == cat.label;
                  return GestureDetector(
                    onTap: () => setState(() => _category = cat.label),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: active ? _C.accent(context) : _C.card(context),
                        borderRadius: BorderRadius.circular(12),
                        border: active ? null : Border.all(color: _C.border(context))),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(cat.icon, size: 14,
                          color: active ? Colors.white : cat.color),
                        const SizedBox(width: 6),
                        Text(cat.label, style: GoogleFonts.inter(
                          fontSize: 12, fontWeight: FontWeight.w500,
                          color: active ? Colors.white : _C.t2(context))),
                      ]),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 28),
              // Title
              Text('Votre question', style: GoogleFonts.inter(
                fontSize: 13, fontWeight: FontWeight.w600, color: _C.t1(context))),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: _C.card(context),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _C.border(context))),
                child: TextField(
                  controller: _titleCtrl,
                  onChanged: (_) => setState(() {}),
                  maxLines: 2,
                  style: GoogleFonts.inter(fontSize: 15, color: _C.t1(context), height: 1.5),
                  decoration: InputDecoration(
                    hintText: 'Ex : Est-ce normal de…',
                    hintStyle: GoogleFonts.inter(fontSize: 15, color: _C.t3(context)),
                    border: InputBorder.none)),
              ),
              const SizedBox(height: 24),
              // Description
              Row(children: [
                Text('Détails', style: GoogleFonts.inter(
                  fontSize: 13, fontWeight: FontWeight.w600, color: _C.t1(context))),
                const SizedBox(width: 4),
                Text('(optionnel)', style: GoogleFonts.inter(
                  fontSize: 12, color: _C.t3(context))),
              ]),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: _C.card(context),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _C.border(context))),
                child: TextField(
                  controller: _descCtrl,
                  onChanged: (_) => setState(() {}),
                  maxLines: 5,
                  maxLength: _maxDesc,
                  style: GoogleFonts.inter(fontSize: 14, color: _C.t1(context), height: 1.5),
                  decoration: InputDecoration(
                    hintText: 'Décrivez votre situation pour aider le médecin à mieux répondre…',
                    hintStyle: GoogleFonts.inter(fontSize: 14, color: _C.t3(context)),
                    border: InputBorder.none,
                    counterText: '${_descCtrl.text.length}/$_maxDesc',
                    counterStyle: GoogleFonts.inter(fontSize: 11, color: _C.t3(context)))),
              ),
              const SizedBox(height: 28),
              // Privacy notice
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _C.accentBg(context),
                  borderRadius: BorderRadius.circular(16)),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Icon(LucideIcons.shieldCheck, size: 18, color: _C.accent(context)),
                  const SizedBox(width: 12),
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Publication anonyme', style: GoogleFonts.inter(
                        fontSize: 13, fontWeight: FontWeight.w600, color: _C.accent(context))),
                      const SizedBox(height: 4),
                      Text(
                        'Votre question sera publiée de manière anonyme. Aucune information personnelle ne sera partagée.',
                        style: GoogleFonts.inter(
                          fontSize: 12, color: _C.t2(context), height: 1.5)),
                    ],
                  )),
                ]),
              ),
            ],
          ),
        ),
      ]),
    );
  }

  Future<void> _submit() async {
    setState(() => _sending = true);
    try {
      await widget.onSubmit?.call(_titleCtrl.text.trim());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Question envoyée !', style: GoogleFonts.inter()),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        Navigator.pop(context);
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }
}
