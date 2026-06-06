import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CATEGORY MODEL
// ─────────────────────────────────────────────────────────────────────────────
class _CatItem {
  final String key, label;
  final IconData icon;
  final Color accent;
  const _CatItem({
    required this.key,
    required this.label,
    required this.icon,
    required this.accent,
  });
}

const _kCats = [
  _CatItem(key: 'mamans',    label: 'Mamans',    icon: Icons.favorite_rounded,    accent: Color(0xFFE91E63)),
  _CatItem(key: 'baby',      label: 'Bébé',      icon: Icons.child_care_rounded,  accent: Color(0xFF7C4DFF)),
  _CatItem(key: 'sport',     label: 'Sport',     icon: Icons.fitness_center,      accent: Color(0xFF00BCD4)),
  _CatItem(key: 'vitamines', label: 'Vitamines', icon: Icons.eco_rounded,         accent: Color(0xFF4CAF50)),
  _CatItem(key: 'skincare',  label: 'Skincare',  icon: Icons.spa_rounded,         accent: Color(0xFFFF9800)),
  _CatItem(key: 'home',      label: 'Maison',    icon: Icons.home_rounded,        accent: Color(0xFF2196F3)),
  _CatItem(key: 'autre',     label: 'Autre',     icon: Icons.more_horiz_rounded,  accent: Color(0xFF9E9E9E)),
];

// ─────────────────────────────────────────────────────────────────────────────
// BENEFIT MODEL
// ─────────────────────────────────────────────────────────────────────────────
class _BenefitItem {
  final IconData icon;
  final String label, value;
  const _BenefitItem(this.icon, this.value, this.label);
}

const _kBenefits = [
  _BenefitItem(Icons.people_alt_rounded,       '12 000+', 'utilisatrices'),
  _BenefitItem(Icons.storefront_rounded,        '150+',    'marques actives'),
  _BenefitItem(Icons.bolt_rounded,              '48h',     'réponse garantie'),
  _BenefitItem(Icons.trending_up_rounded,       '3×',      'visibilité'),
];

// ─────────────────────────────────────────────────────────────────────────────
// SCREEN
// ─────────────────────────────────────────────────────────────────────────────
class PartnerFormScreen extends StatefulWidget {
  const PartnerFormScreen({super.key});

  @override
  State<PartnerFormScreen> createState() => _PartnerFormScreenState();
}

class _PartnerFormScreenState extends State<PartnerFormScreen>
    with TickerProviderStateMixin {
  // ── Controllers ─────────────────────────────────────────────────────────────
  final _nameCtrl    = TextEditingController();
  final _emailCtrl   = TextEditingController();
  final _brandCtrl   = TextEditingController();
  final _websiteCtrl = TextEditingController();
  final _phoneCtrl   = TextEditingController();
  final _messageCtrl = TextEditingController();

  // ── Focus nodes ──────────────────────────────────────────────────────────────
  final _nameFocus    = FocusNode();
  final _emailFocus   = FocusNode();
  final _brandFocus   = FocusNode();
  final _websiteFocus = FocusNode();
  final _phoneFocus   = FocusNode();
  final _messageFocus = FocusNode();

  // ── State ────────────────────────────────────────────────────────────────────
  String _cat     = '';
  bool   _loading = false;
  bool   _agreed  = false;

  // ── Animations ───────────────────────────────────────────────────────────────
  late final AnimationController _entryCtrl;
  late final AnimationController _btnCtrl;
  late final Animation<double>   _entryFade;
  late final Animation<Offset>   _entrySlide;
  late final Animation<double>   _btnScale;

  // ── Palette ──────────────────────────────────────────────────────────────────
  static const _gold      = Color(0xFFC4972A);
  static const _goldLight = Color(0xFFE6C36A);
  static const _errRed    = Color(0xFFD04040);

  Color _bg(bool d)        => d ? const Color(0xFF0A0A0A) : const Color(0xFFF7F7F5);
  Color _surface(bool d)   => d ? const Color(0xFF161616) : Colors.white;
  Color _surface2(bool d)  => d ? const Color(0xFF1E1E1E) : const Color(0xFFF0F0EE);
  Color _ink(bool d)       => d ? const Color(0xFFF2F2F0) : const Color(0xFF111110);
  Color _inkMuted(bool d)  => d ? const Color(0xFF8A8A88) : const Color(0xFF6B6B68);
  Color _inkSubtle(bool d) => d ? const Color(0xFF4A4A48) : const Color(0xFFAAAAAA);
  Color _divider(bool d)   => d ? const Color(0xFF242424) : const Color(0xFFE8E8E6);
  Color _border(bool d)    => d ? const Color(0xFF2C2C2A) : const Color(0xFFE0E0DE);

  @override
  void initState() {
    super.initState();

    _entryCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 520));
    _btnCtrl   = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 120));

    _entryFade  = CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOut);
    _entrySlide = Tween<Offset>(begin: const Offset(0, 0.04), end: Offset.zero)
        .animate(CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOut));
    _btnScale   = Tween<double>(begin: 1.0, end: 0.96)
        .animate(CurvedAnimation(parent: _btnCtrl, curve: Curves.easeInOut));

    _entryCtrl.forward();

    for (final fn in [
      _nameFocus, _emailFocus, _brandFocus,
      _websiteFocus, _phoneFocus, _messageFocus,
    ]) {
      fn.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    for (final c in [
      _nameCtrl, _emailCtrl, _brandCtrl,
      _websiteCtrl, _phoneCtrl, _messageCtrl,
    ]) { c.dispose(); }
    for (final f in [
      _nameFocus, _emailFocus, _brandFocus,
      _websiteFocus, _phoneFocus, _messageFocus,
    ]) { f.dispose(); }
    _entryCtrl.dispose();
    _btnCtrl.dispose();
    super.dispose();
  }

  // ── Submit ───────────────────────────────────────────────────────────────────
  void _onSubmit(bool isDark) async {
    final name  = _nameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final brand = _brandCtrl.text.trim();

    if (name.isEmpty || email.isEmpty || brand.isEmpty) {
      _err('Veuillez remplir les champs obligatoires (*).');
      return;
    }
    if (!RegExp(r'^[\w\.\+\-]+@[\w\-]+\.[a-z]{2,}$').hasMatch(email)) {
      _err('Adresse email invalide.');
      return;
    }
    if (_cat.isEmpty) {
      _err('Veuillez sélectionner une catégorie.');
      return;
    }
    if (!_agreed) {
      _err('Veuillez accepter les conditions partenaires.');
      return;
    }

    await _btnCtrl.forward();
    await _btnCtrl.reverse();

    setState(() => _loading = true);
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() => _loading = false);
    _showSuccess(isDark);
  }

  void _err(String msg) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: Colors.white, size: 18),
          const SizedBox(width: 10),
          Expanded(child: Text(msg,
              style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w500))),
        ],
      ),
      behavior: SnackBarBehavior.floating,
      backgroundColor: _errRed,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      duration: const Duration(milliseconds: 2800),
    ));
  }

  void _showSuccess(bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _SuccessSheet(
        isDark:  isDark,
        onClose: () { Navigator.pop(context); Navigator.pop(context); },
      ),
    );
  }

  // ── BUILD ────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final d = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: _bg(d),
        body: SafeArea(
          child: FadeTransition(
            opacity: _entryFade,
            child: SlideTransition(
              position: _entrySlide,
              child: Column(
                children: [
                  _buildHeader(d),
                  Container(height: 0.5, color: _divider(d)),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.zero,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHero(d),
                          _buildBenefitsStrip(d),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 28),
                                _buildSectionLabel('VOS COORDONNÉES', d),
                                const SizedBox(height: 14),
                                _buildField(
                                  label: 'Nom complet', isRequired: true,
                                  ctrl: _nameCtrl, focus: _nameFocus,
                                  icon: CupertinoIcons.person, d: d,
                                ),
                                const SizedBox(height: 10),
                                Row(children: [
                                  Expanded(child: _buildField(
                                    label: 'Email', isRequired: true,
                                    ctrl: _emailCtrl, focus: _emailFocus,
                                    icon: CupertinoIcons.mail,
                                    keyboard: TextInputType.emailAddress, d: d,
                                  )),
                                  const SizedBox(width: 10),
                                  Expanded(child: _buildField(
                                    label: 'Téléphone', isRequired: false,
                                    ctrl: _phoneCtrl, focus: _phoneFocus,
                                    icon: CupertinoIcons.phone,
                                    keyboard: TextInputType.phone, d: d,
                                  )),
                                ]),
                                const SizedBox(height: 28),
                                _buildSectionLabel('VOTRE MARQUE', d),
                                const SizedBox(height: 14),
                                _buildField(
                                  label: 'Nom de la marque', isRequired: true,
                                  ctrl: _brandCtrl, focus: _brandFocus,
                                  icon: CupertinoIcons.bag, d: d,
                                ),
                                const SizedBox(height: 10),
                                _buildField(
                                  label: 'Site web ou Instagram', isRequired: false,
                                  ctrl: _websiteCtrl, focus: _websiteFocus,
                                  icon: CupertinoIcons.link,
                                  hint: 'https://…  ou  @votremarque',
                                  keyboard: TextInputType.url, d: d,
                                ),
                                const SizedBox(height: 10),
                                _buildField(
                                  label: 'Présentez votre marque', isRequired: false,
                                  ctrl: _messageCtrl, focus: _messageFocus,
                                  icon: CupertinoIcons.text_alignleft,
                                  hint: 'Parlez-nous de vos produits, de vos valeurs, et de ce qui vous rend unique…',
                                  lines: 4, d: d,
                                ),
                                const SizedBox(height: 28),
                                _buildSectionLabel('CATÉGORIE', d),
                                const SizedBox(height: 14),
                                _buildCategoryGrid(d),
                                const SizedBox(height: 28),
                                _buildAgreementRow(d),
                                const SizedBox(height: 24),
                                _buildSubmitButton(d),
                                const SizedBox(height: 12),
                                _buildFooterNote(d),
                                const SizedBox(height: 40),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Header ───────────────────────────────────────────────────────────────────
  Widget _buildHeader(bool d) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: _surface2(d),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(CupertinoIcons.chevron_left, size: 14, color: _ink(d)),
                    const SizedBox(width: 4),
                    Text('Boutique',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: _ink(d))),
                  ],
                ),
              ),
            ),
          ),
          Text('Partenariat',
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w700,
                  color: _ink(d), letterSpacing: -0.3)),
        ],
      ),
    );
  }

  // ── Hero ─────────────────────────────────────────────────────────────────────
  Widget _buildHero(bool d) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.fromLTRB(22, 24, 22, 24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A1200), Color(0xFF2E1F00), Color(0xFF1A1200)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _gold.withValues(alpha: 0.20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [_gold, _goldLight],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.handshake_rounded, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Devenez partenaire',
                      style: const TextStyle(
                          color: Colors.white, fontSize: 18,
                          fontWeight: FontWeight.w800, letterSpacing: -0.4)),
                  const SizedBox(height: 2),
                  Text('Rejoignez la communauté Fiteva',
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.55),
                          fontSize: 12.5, fontWeight: FontWeight.w400)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(color: Color(0x22C4972A), height: 1),
          const SizedBox(height: 18),
          Text(
            'Touchez des milliers de mamans, femmes enceintes et\nprofessionnels de santé à travers notre application.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.72),
              fontSize: 13.5,
              height: 1.55,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _heroChip('Visibilité premium'),
              _heroChip('Audience ciblée'),
              _heroChip('Accompagnement dédié'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _heroChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _gold.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _gold.withValues(alpha: 0.30)),
      ),
      child: Text(label,
          style: const TextStyle(
              color: _gold, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }

  // ── Benefits strip ────────────────────────────────────────────────────────────
  Widget _buildBenefitsStrip(bool d) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: _surface(d),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _border(d)),
      ),
      child: Row(
        children: _kBenefits.map((b) {
          final isLast = b == _kBenefits.last;
          return Expanded(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _gold.withValues(alpha: d ? 0.15 : 0.10),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(b.icon, color: _gold, size: 16),
                      ),
                      const SizedBox(height: 6),
                      Text(b.value,
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w800,
                              color: _ink(d), letterSpacing: -0.4)),
                      const SizedBox(height: 2),
                      Text(b.label,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 10.5, color: _inkMuted(d),
                              fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
                if (!isLast)
                  Container(width: 0.5, height: 44, color: _border(d)),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Section label ─────────────────────────────────────────────────────────────
  Widget _buildSectionLabel(String text, bool d) {
    return Row(
      children: [
        Container(width: 3, height: 14, decoration: BoxDecoration(
          gradient: const LinearGradient(
              colors: [_gold, _goldLight], begin: Alignment.topCenter, end: Alignment.bottomCenter),
          borderRadius: BorderRadius.circular(2),
        )),
        const SizedBox(width: 8),
        Text(text,
            style: TextStyle(
                fontSize: 10.5, fontWeight: FontWeight.w700,
                color: _inkSubtle(d), letterSpacing: 1.6)),
      ],
    );
  }

  // ── Form field ────────────────────────────────────────────────────────────────
  Widget _buildField({
    required String label,
    required bool isRequired,
    required TextEditingController ctrl,
    required FocusNode focus,
    required bool d,
    required IconData icon,
    String? hint,
    TextInputType? keyboard,
    int lines = 1,
  }) {
    final focused = focus.hasFocus;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      decoration: BoxDecoration(
        color: _surface(d),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: focused ? _gold : _border(d),
          width: focused ? 1.5 : 1.0,
        ),
        boxShadow: focused
            ? [BoxShadow(color: _gold.withValues(alpha: 0.12), blurRadius: 12, offset: const Offset(0, 4))]
            : [BoxShadow(color: Colors.black.withValues(alpha: d ? 0.15 : 0.04), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Row(
        crossAxisAlignment: lines > 1 ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.only(
                left: 14, top: lines > 1 ? 14 : 0, right: 0),
            child: Icon(icon,
                size: 17,
                color: focused ? _gold : _inkSubtle(d)),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
                  child: Text(
                    isRequired ? '$label *' : label,
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      color: focused ? _gold : _inkMuted(d),
                    ),
                  ),
                ),
                TextField(
                  controller: ctrl,
                  focusNode: focus,
                  maxLines: lines,
                  keyboardType: keyboard,
                  style: TextStyle(color: _ink(d), fontSize: 14, fontWeight: FontWeight.w500),
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: TextStyle(color: _inkSubtle(d), fontSize: 13),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Category grid ─────────────────────────────────────────────────────────────
  Widget _buildCategoryGrid(bool d) {
    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 0.85,
      children: _kCats.map((cat) {
        final sel = _cat == cat.key;
        return GestureDetector(
          onTap: () => setState(() => _cat = cat.key),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              gradient: sel
                  ? LinearGradient(
                      colors: [cat.accent.withValues(alpha: 0.85), cat.accent],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: sel ? null : _surface(d),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: sel ? cat.accent : _border(d),
                width: sel ? 0 : 1,
              ),
              boxShadow: sel
                  ? [BoxShadow(color: cat.accent.withValues(alpha: 0.30), blurRadius: 12, offset: const Offset(0, 4))]
                  : [BoxShadow(color: Colors.black.withValues(alpha: d ? 0.12 : 0.04), blurRadius: 6, offset: const Offset(0, 2))],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  cat.icon,
                  size: 22,
                  color: sel ? Colors.white : (d ? cat.accent.withValues(alpha: 0.75) : cat.accent),
                ),
                const SizedBox(height: 6),
                Text(
                  cat.label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: sel ? Colors.white : _inkMuted(d),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── Agreement row ─────────────────────────────────────────────────────────────
  Widget _buildAgreementRow(bool d) {
    return GestureDetector(
      onTap: () => setState(() => _agreed = !_agreed),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 22, height: 22,
            decoration: BoxDecoration(
              gradient: _agreed
                  ? const LinearGradient(colors: [_gold, _goldLight])
                  : null,
              color: _agreed ? null : _surface(d),
              borderRadius: BorderRadius.circular(7),
              border: Border.all(
                  color: _agreed ? _gold : _border(d), width: 1.5),
            ),
            child: _agreed
                ? const Icon(Icons.check_rounded, color: Colors.white, size: 14)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text.rich(
              TextSpan(
                style: TextStyle(fontSize: 12.5, color: _inkMuted(d), height: 1.5),
                children: [
                  const TextSpan(text: "J'accepte les "),
                  TextSpan(
                    text: 'conditions du programme partenaire',
                    style: const TextStyle(
                        color: _gold, fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                        decorationColor: _gold),
                  ),
                  const TextSpan(text: ' de Fiteva.'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Submit button ─────────────────────────────────────────────────────────────
  Widget _buildSubmitButton(bool d) {
    return ScaleTransition(
      scale: _btnScale,
      child: GestureDetector(
        onTap: _loading ? null : () => _onSubmit(d),
        child: Container(
          width: double.infinity,
          height: 58,
          decoration: BoxDecoration(
            gradient: _loading
                ? LinearGradient(colors: [
                    _gold.withValues(alpha: 0.6),
                    _goldLight.withValues(alpha: 0.6),
                  ])
                : const LinearGradient(
                    colors: [Color(0xFFB5871F), _gold, _goldLight],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: _gold.withValues(alpha: _loading ? 0.10 : 0.35),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Center(
            child: _loading
                ? const SizedBox(
                    width: 22, height: 22,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2.5))
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.send_rounded, color: Colors.white, size: 18),
                      SizedBox(width: 10),
                      Text('Envoyer ma candidature',
                          style: TextStyle(
                              color: Colors.white, fontSize: 15.5,
                              fontWeight: FontWeight.w700, letterSpacing: -0.2)),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  // ── Footer note ───────────────────────────────────────────────────────────────
  Widget _buildFooterNote(bool d) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(CupertinoIcons.lock_fill, size: 12, color: _inkSubtle(d)),
        const SizedBox(width: 6),
        Text('Données sécurisées — aucun partage tiers',
            style: TextStyle(
                fontSize: 11.5, color: _inkSubtle(d), fontWeight: FontWeight.w500)),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SUCCESS SHEET
// ─────────────────────────────────────────────────────────────────────────────
class _SuccessSheet extends StatefulWidget {
  final bool isDark;
  final VoidCallback onClose;
  const _SuccessSheet({required this.isDark, required this.onClose});

  @override
  State<_SuccessSheet> createState() => _SuccessSheetState();
}

class _SuccessSheetState extends State<_SuccessSheet>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double>   _scale;
  late final Animation<double>   _fade;

  static const _gold      = Color(0xFFC4972A);
  static const _goldLight = Color(0xFFE6C36A);

  @override
  void initState() {
    super.initState();
    _ctrl  = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _scale = CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut);
    _fade  = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  Color get _surface => widget.isDark ? const Color(0xFF161616) : Colors.white;
  Color get _ink     => widget.isDark ? const Color(0xFFF2F2F0) : const Color(0xFF111110);
  Color get _muted   => widget.isDark ? const Color(0xFF8A8A88) : const Color(0xFF6B6B68);
  Color get _divider => widget.isDark ? const Color(0xFF242424) : const Color(0xFFE8E8E6);
  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: Container(
        margin: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(28),
        ),
        padding: EdgeInsets.fromLTRB(
            28, 20, 28, MediaQuery.of(context).padding.bottom + 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                  color: _divider, borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 32),

            // Checkmark
            ScaleTransition(
              scale: _scale,
              child: Container(
                width: 88, height: 88,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1A1200), Color(0xFF2E1F00)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(color: _gold.withValues(alpha: 0.35), width: 1.5),
                  boxShadow: [BoxShadow(color: _gold.withValues(alpha: 0.25), blurRadius: 24, offset: const Offset(0, 8))],
                ),
                child: const Icon(Icons.check_rounded, color: _gold, size: 38),
              ),
            ),
            const SizedBox(height: 24),

            Text('Candidature envoyée !',
                style: TextStyle(
                    fontSize: 22, fontWeight: FontWeight.w800,
                    color: _ink, letterSpacing: -0.6)),
            const SizedBox(height: 10),
            Text(
              'Notre équipe va analyser votre dossier\net vous recontactera sous 48h.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: _muted, height: 1.65),
            ),
            const SizedBox(height: 28),

            // What's next card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _gold.withValues(alpha: widget.isDark ? 0.10 : 0.07),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _gold.withValues(alpha: 0.20)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Prochaines étapes',
                      style: TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w700,
                          color: _gold, letterSpacing: 0.5)),
                  const SizedBox(height: 10),
                  ...[
                    ('Vérification de votre dossier',   '1–2 jours'),
                    ('Appel de présentation Fiteva',     '3–5 jours'),
                    ('Mise en ligne de votre boutique',  '1 semaine'),
                  ].map((step) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        Container(
                          width: 6, height: 6,
                          decoration: const BoxDecoration(
                              color: _gold, shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 10),
                        Expanded(child: Text(step.$1,
                            style: TextStyle(fontSize: 12.5, color: _ink, fontWeight: FontWeight.w500))),
                        Text(step.$2,
                            style: TextStyle(fontSize: 11.5, color: _muted)),
                      ],
                    ),
                  )),
                ],
              ),
            ),
            const SizedBox(height: 20),

            GestureDetector(
              onTap: widget.onClose,
              child: Container(
                width: double.infinity, height: 56,
                decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFB5871F), _gold, _goldLight],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: _gold.withValues(alpha: 0.30), blurRadius: 16, offset: const Offset(0, 6))]),
                child: const Center(
                  child: Text('Parfait, merci !',
                      style: TextStyle(
                          color: Colors.white, fontSize: 15.5,
                          fontWeight: FontWeight.w700, letterSpacing: -0.2)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
