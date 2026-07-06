import 'package:fiteva/l10n/app_localizations.dart';
import 'package:fiteva/services/shop_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ── Colors ───────────────────────────────────────────────────────────────────
const _brand  = Color(0xFF1C4D30);
const _errRed = Color(0xFFC24A4A);

// ── Categories ───────────────────────────────────────────────────────────────
const _kCats = [
  (key: 'mamans',    label: 'Mamans',    icon: Icons.favorite_rounded),
  (key: 'baby',      label: 'Bébé',      icon: Icons.child_care_rounded),
  (key: 'sport',     label: 'Sport',     icon: Icons.fitness_center),
  (key: 'vitamines', label: 'Vitamines', icon: Icons.eco_rounded),
  (key: 'skincare',  label: 'Skincare',  icon: Icons.spa_rounded),
  (key: 'home',      label: 'Maison',    icon: Icons.home_rounded),
  (key: 'autre',     label: 'Autre',     icon: Icons.more_horiz_rounded),
];

class PartnerFormScreen extends ConsumerStatefulWidget {
  const PartnerFormScreen({super.key});

  @override
  ConsumerState<PartnerFormScreen> createState() => _PartnerFormScreenState();
}

class _PartnerFormScreenState extends ConsumerState<PartnerFormScreen> {
  final _formKey     = GlobalKey<FormState>();
  final _nameCtrl    = TextEditingController();
  final _emailCtrl   = TextEditingController();
  final _brandCtrl   = TextEditingController();
  final _websiteCtrl = TextEditingController();
  final _phoneCtrl   = TextEditingController();
  final _messageCtrl = TextEditingController();

  String _cat     = '';
  bool   _loading = false;
  bool   _agreed  = false;

  @override
  void dispose() {
    _nameCtrl.dispose(); _emailCtrl.dispose(); _brandCtrl.dispose();
    _websiteCtrl.dispose(); _phoneCtrl.dispose(); _messageCtrl.dispose();
    super.dispose();
  }

  void _onSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_cat.isEmpty) { _err(ref.read(l10nProvider).formSelectCat); return; }
    if (!_agreed)     { _err(ref.read(l10nProvider).formAcceptCond); return; }

    setState(() => _loading = true);

    // Une candidature est déjà en cours de traitement — on ne renvoie pas de
    // doublon (le formulaire promet un suivi sous 1-2 jours, une deuxième
    // candidature romprait cette promesse et créerait une confusion côté équipe).
    final pending = await ShopService.hasPendingPartnerRequest();
    if (pending == PartnerRequestCheck.alreadyPending) {
      if (!mounted) return;
      setState(() => _loading = false);
      _err('Une candidature est déjà en cours de traitement pour ton compte.');
      return;
    }

    final ok = await ShopService.submitPartnerRequest(
      name:     _nameCtrl.text.trim(),
      email:    _emailCtrl.text.trim(),
      phone:    _phoneCtrl.text.trim(),
      brand:    _brandCtrl.text.trim(),
      website:  _websiteCtrl.text.trim(),
      message:  _messageCtrl.text.trim(),
      category: _cat,
    );
    if (!mounted) return;
    setState(() => _loading = false);
    if (!ok) {
      _err('Une erreur est survenue, veuillez réessayer.');
      return;
    }
    _showSuccess();
  }

  void _err(String msg) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: _errRed,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
    ));
  }

  void _showSuccess() {
    final d = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _SuccessSheet(
        isDark: d,
        onClose: () { Navigator.pop(context); Navigator.pop(context); },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n  = ref.watch(l10nProvider);
    final d     = Theme.of(context).brightness == Brightness.dark;
    final bg    = d ? const Color(0xFF10140F) : const Color.fromARGB(255, 255, 255, 255);
    final surf  = d ? const Color(0xFF1A1F19) : Colors.white;
    final ink   = d ? const Color(0xFFEDF2EC) : const Color(0xFF16211A);
    final muted = d ? const Color(0xFF919C90) : const Color(0xFF6E786F);
    final line  = d ? const Color(0xFF2A302A) : const Color(0xFFECECE8);
    final shadow = d ? <BoxShadow>[] : [
      BoxShadow(color: const Color(0xFF16211A).withValues(alpha: 0.05), blurRadius: 18, offset: const Offset(0, 6)),
    ];

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: bg,
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
              children: [
                // ── Header ───────────────────────────────────────────────
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(color: surf, shape: BoxShape.circle,
                            border: Border.all(color: line, width: 1)),
                        child: Icon(CupertinoIcons.chevron_left, size: 15, color: ink),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(l10n.formDevenirPart,
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800,
                            color: ink, letterSpacing: -0.4)),
                  ],
                ),
                const SizedBox(height: 20),

                // ── Hero — bandeau compact, une seule ligne ──────────────
                Container(
                  padding: const EdgeInsets.fromLTRB(14, 12, 16, 12),
                  decoration: BoxDecoration(
                    color: _brand,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.14), shape: BoxShape.circle),
                        child: const Icon(Icons.handshake_rounded, color: Colors.white, size: 17),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Devenez marque partenaire',
                                style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700,
                                    color: Colors.white, letterSpacing: -0.2)),
                            const SizedBox(height: 2),
                            Text('50K+ utilisatrices · 4.8★ · mise en ligne <1 sem.',
                                maxLines: 1, overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.7))),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // ── Coordonnées ────────────────────────────────────────────
                _SectionCard(
                  surf: surf, line: line, shadow: shadow,
                  icon: CupertinoIcons.person_fill, title: l10n.formCoordonnees, ink: ink,
                  children: [
                    _field(ctrl: _nameCtrl, label: l10n.formNomComplet, icon: CupertinoIcons.person,
                        ink: ink, muted: muted, line: line, d: d,
                        validator: (v) => v!.trim().isEmpty ? l10n.formChampRequis : null),
                    const SizedBox(height: 12),
                    _field(ctrl: _emailCtrl, label: l10n.formEmail, icon: CupertinoIcons.mail,
                        ink: ink, muted: muted, line: line, d: d,
                        keyboard: TextInputType.emailAddress,
                        validator: (v) {
                          if (v!.trim().isEmpty) return l10n.formChampRequis;
                          if (!RegExp(r'^[\w\.\+\-]+@[\w\-]+\.[a-z]{2,}$').hasMatch(v.trim())) return l10n.formEmailInvalid;
                          return null;
                        }),
                    const SizedBox(height: 12),
                    _field(ctrl: _phoneCtrl, label: l10n.formTelephone, icon: CupertinoIcons.phone,
                        ink: ink, muted: muted, line: line, d: d, keyboard: TextInputType.phone,
                        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9+\s]'))]),
                  ],
                ),
                const SizedBox(height: 16),

                // ── Marque ─────────────────────────────────────────────────
                _SectionCard(
                  surf: surf, line: line, shadow: shadow,
                  icon: CupertinoIcons.bag_fill, title: l10n.formVotreMarque, ink: ink,
                  children: [
                    _field(ctrl: _brandCtrl, label: l10n.formNomMarque, icon: CupertinoIcons.bag,
                        ink: ink, muted: muted, line: line, d: d,
                        validator: (v) => v!.trim().isEmpty ? l10n.formChampRequis : null),
                    const SizedBox(height: 12),
                    _field(ctrl: _websiteCtrl, label: l10n.formSiteWeb, icon: CupertinoIcons.link,
                        ink: ink, muted: muted, line: line, d: d,
                        hint: 'https://…  ou  @votremarque', keyboard: TextInputType.url),
                    const SizedBox(height: 12),
                    _field(ctrl: _messageCtrl, label: l10n.formPresenter, icon: CupertinoIcons.text_alignleft,
                        ink: ink, muted: muted, line: line, d: d, hint: l10n.formProduits, lines: 3),
                    const SizedBox(height: 14),
                    Text(l10n.formCategorie.toUpperCase(),
                        style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: muted, letterSpacing: 1.2)),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _kCats.map((cat) {
                        final sel = _cat == cat.key;
                        return GestureDetector(
                          onTap: () => setState(() => _cat = cat.key),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 160),
                            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
                            decoration: BoxDecoration(
                              color: sel ? _brand : (d ? const Color(0xFF232923) : const Color(0xFFF4F4F1)),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: sel ? _brand : line, width: 1),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(cat.icon, size: 14, color: sel ? Colors.white : muted),
                                const SizedBox(width: 6),
                                Text(cat.label,
                                    style: TextStyle(fontSize: 12.5,
                                        fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                                        color: sel ? Colors.white : ink)),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // ── Agreement ──────────────────────────────────────────────
                GestureDetector(
                  onTap: () => setState(() => _agreed = !_agreed),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 160),
                        width: 20, height: 20,
                        decoration: BoxDecoration(
                          color: _agreed ? _brand : Colors.transparent,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: _agreed ? _brand : line, width: 1.5),
                        ),
                        child: _agreed ? const Icon(Icons.check_rounded, color: Colors.white, size: 13) : null,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text.rich(TextSpan(
                          style: TextStyle(fontSize: 13, color: muted, height: 1.5),
                          children: [
                            TextSpan(text: l10n.formJAccepte),
                            TextSpan(
                              text: l10n.formConditions,
                              style: const TextStyle(color: _brand, fontWeight: FontWeight.w600,
                                  decoration: TextDecoration.underline, decorationColor: _brand),
                            ),
                            TextSpan(text: l10n.formDeFiteva),
                          ],
                        )),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),

                // ── Submit ─────────────────────────────────────────────────
                SizedBox(
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _onSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _brand,
                      disabledBackgroundColor: _brand.withValues(alpha: 0.5),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    child: _loading
                        ? const SizedBox(width: 20, height: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(l10n.formEnvoyer, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                              const SizedBox(width: 8),
                              const Icon(CupertinoIcons.arrow_right, size: 16),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(CupertinoIcons.lock_fill, size: 11, color: muted.withValues(alpha: 0.6)),
                    const SizedBox(width: 5),
                    Text(l10n.formSecurise, style: TextStyle(fontSize: 11.5, color: muted.withValues(alpha: 0.6))),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _field({
    required TextEditingController ctrl,
    required String label,
    required IconData icon,
    required Color ink,
    required Color muted,
    required Color line,
    required bool d,
    String? hint,
    TextInputType? keyboard,
    int lines = 1,
    String? Function(String?)? validator,
    List<TextInputFormatter>? inputFormatters,
  }) {
    final fill = d ? const Color(0xFF232923) : const Color(0xFFF4F4F1);
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(13),
      borderSide: BorderSide.none,
    );
    return TextFormField(
      controller: ctrl,
      maxLines: lines,
      keyboardType: keyboard,
      validator: validator,
      inputFormatters: inputFormatters,
      style: TextStyle(color: ink, fontSize: 14, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 2),
          child: Icon(icon, size: 17, color: muted),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 40),
        labelStyle: TextStyle(color: muted, fontSize: 13.5),
        hintStyle: TextStyle(color: muted.withValues(alpha: 0.6), fontSize: 13),
        filled: true,
        fillColor: fill,
        isDense: true,
        border: border,
        enabledBorder: border,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: const BorderSide(color: _brand, width: 1.4),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: const BorderSide(color: _errRed, width: 1.2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: const BorderSide(color: _errRed, width: 1.4),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: lines > 1 ? 14 : 14),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SECTION CARD — regroupe chaque partie du formulaire dans une carte élevée
// avec en-tête icône + titre, pour une hiérarchie plus "pro".
// ─────────────────────────────────────────────────────────────────────────────
class _SectionCard extends StatelessWidget {
  final Color surf;
  final Color line;
  final Color ink;
  final List<BoxShadow> shadow;
  final IconData icon;
  final String title;
  final List<Widget> children;

  const _SectionCard({
    required this.surf,
    required this.line,
    required this.ink,
    required this.shadow,
    required this.icon,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surf,
        borderRadius: BorderRadius.circular(18),
        boxShadow: shadow,
        border: Border.all(color: line, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28, height: 28,
                decoration: BoxDecoration(color: _brand.withValues(alpha: 0.10), borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, size: 14, color: _brand),
              ),
              const SizedBox(width: 10),
              Text(title, style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: ink)),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}

// ── Success Sheet ─────────────────────────────────────────────────────────────
class _SuccessSheet extends ConsumerStatefulWidget {
  final bool isDark;
  final VoidCallback onClose;
  const _SuccessSheet({required this.isDark, required this.onClose});

  @override
  ConsumerState<_SuccessSheet> createState() => _SuccessSheetState();
}

class _SuccessSheetState extends ConsumerState<_SuccessSheet>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl  = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _scale = CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut);
    _fade  = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final l10n    = ref.watch(l10nProvider);
    final surface = widget.isDark ? const Color(0xFF1A1F19) : Colors.white;
    final ink     = widget.isDark ? const Color(0xFFEDF2EC) : const Color(0xFF16211A);
    final muted   = widget.isDark ? const Color(0xFF919C90) : const Color(0xFF6E786F);
    final handle  = widget.isDark ? const Color(0xFF2A302A) : const Color(0xFFE6E6E1);
    final line    = widget.isDark ? const Color(0xFF2A302A) : const Color(0xFFECECE8);

    return FadeTransition(
      opacity: _fade,
      child: Container(
        margin: const EdgeInsets.all(12),
        padding: EdgeInsets.fromLTRB(24, 16, 24, MediaQuery.of(context).padding.bottom + 28),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 36, height: 4,
                decoration: BoxDecoration(color: handle, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 28),

            ScaleTransition(
              scale: _scale,
              child: Container(
                width: 72, height: 72,
                decoration: BoxDecoration(
                  color: _brand.withValues(alpha: widget.isDark ? 0.18 : 0.10),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_rounded, color: _brand, size: 34),
              ),
            ),
            const SizedBox(height: 20),

            Text(l10n.formCandidature,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: ink, letterSpacing: -0.5)),
            const SizedBox(height: 8),
            Text(l10n.formRecontact,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13.5, color: muted, height: 1.5)),
            const SizedBox(height: 22),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(border: Border.all(color: line), borderRadius: BorderRadius.circular(14)),
              child: Column(
                children: [
                  ...[
                    (l10n.formVerif,        '1–2 jours'),
                    (l10n.formAppel,        '3–5 jours'),
                    (l10n.formMiseEnLigne,  '1 semaine'),
                  ].map((s) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        const Icon(Icons.circle, size: 6, color: _brand),
                        const SizedBox(width: 10),
                        Expanded(child: Text(s.$1,
                            style: TextStyle(fontSize: 13, color: ink, fontWeight: FontWeight.w500))),
                        Text(s.$2, style: TextStyle(fontSize: 12, color: muted)),
                      ],
                    ),
                  )),
                ],
              ),
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: widget.onClose,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _brand,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: Text(l10n.formParfait,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
