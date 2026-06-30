import 'package:fiteva/l10n/app_localizations.dart';
import 'package:fiteva/services/shop_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  final _formKey   = GlobalKey<FormState>();
  final _nameCtrl    = TextEditingController();
  final _emailCtrl   = TextEditingController();
  final _brandCtrl   = TextEditingController();
  final _websiteCtrl = TextEditingController();
  final _phoneCtrl   = TextEditingController();
  final _messageCtrl = TextEditingController();

  String _cat     = '';
  bool   _loading = false;
  bool   _agreed  = false;

  static const _gold    = Color(0xFFC4972A);
  static const _errRed  = Color(0xFFD04040);

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
    final bg    = d ? const Color(0xFF0F0F0F) : const Color(0xFFF8F8F6);
    final ink   = d ? const Color(0xFFF0F0EE) : const Color(0xFF111110);
    final muted = d ? const Color(0xFF888886) : const Color(0xFF6B6B68);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: bg,
        appBar: AppBar(
          backgroundColor: bg,
          elevation: 0,
          leading: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Icon(CupertinoIcons.chevron_left, color: ink, size: 20),
          ),
          title: Text(l10n.formDevenirPart,
              style: TextStyle(color: ink, fontSize: 16, fontWeight: FontWeight.w700)),
          centerTitle: true,
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
            children: [
              // ── Intro ──────────────────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _gold.withValues(alpha: d ? 0.12 : 0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _gold.withValues(alpha: 0.22)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.handshake_rounded, color: _gold, size: 22),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        l10n.formSubtitle,
                        style: TextStyle(fontSize: 13, color: muted, height: 1.5),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // ── Coordonnées ────────────────────────────────────────────
              _sectionLabel(l10n.formCoordonnees, ink),
              const SizedBox(height: 12),
              _field(
                ctrl: _nameCtrl, label: l10n.formNomComplet, d: d,
                icon: CupertinoIcons.person,
                validator: (v) => v!.trim().isEmpty ? l10n.formChampRequis : null,
              ),
              const SizedBox(height: 10),
              _field(
                ctrl: _emailCtrl, label: l10n.formEmail, d: d,
                icon: CupertinoIcons.mail,
                keyboard: TextInputType.emailAddress,
                validator: (v) {
                  if (v!.trim().isEmpty) return l10n.formChampRequis;
                  if (!RegExp(r'^[\w\.\+\-]+@[\w\-]+\.[a-z]{2,}$').hasMatch(v.trim())) return l10n.formEmailInvalid;
                  return null;
                },
              ),
              const SizedBox(height: 10),
              _field(
                ctrl: _phoneCtrl, label: l10n.formTelephone, d: d,
                icon: CupertinoIcons.phone,
                keyboard: TextInputType.phone,
              ),
              const SizedBox(height: 28),

              // ── Marque ─────────────────────────────────────────────────
              _sectionLabel(l10n.formVotreMarque, ink),
              const SizedBox(height: 12),
              _field(
                ctrl: _brandCtrl, label: l10n.formNomMarque, d: d,
                icon: CupertinoIcons.bag,
                validator: (v) => v!.trim().isEmpty ? l10n.formChampRequis : null,
              ),
              const SizedBox(height: 10),
              _field(
                ctrl: _websiteCtrl, label: l10n.formSiteWeb, d: d,
                icon: CupertinoIcons.link,
                hint: 'https://…  ou  @votremarque',
                keyboard: TextInputType.url,
              ),
              const SizedBox(height: 10),
              _field(
                ctrl: _messageCtrl, label: l10n.formPresenter, d: d,
                icon: CupertinoIcons.text_alignleft,
                hint: l10n.formProduits,
                lines: 3,
              ),
              const SizedBox(height: 28),

              // ── Catégorie ──────────────────────────────────────────────
              _sectionLabel(l10n.formCategorie, ink),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _kCats.map((cat) {
                  final sel = _cat == cat.key;
                  return GestureDetector(
                    onTap: () => setState(() => _cat = cat.key),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                      decoration: BoxDecoration(
                        color: sel ? _gold : (d ? const Color(0xFF1E1E1E) : Colors.white),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: sel ? _gold : (d ? const Color(0xFF2C2C2A) : const Color(0xFFE0E0DE)),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(cat.icon, size: 15,
                              color: sel ? Colors.white : _gold),
                          const SizedBox(width: 6),
                          Text(cat.label,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: sel ? Colors.white : muted,
                              )),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 28),

              // ── Agreement ──────────────────────────────────────────────
              GestureDetector(
                onTap: () => setState(() => _agreed = !_agreed),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: 22, height: 22,
                      decoration: BoxDecoration(
                        color: _agreed ? _gold : Colors.transparent,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: _agreed ? _gold : (d ? const Color(0xFF444442) : const Color(0xFFCCCCCA)),
                          width: 1.5,
                        ),
                      ),
                      child: _agreed
                          ? const Icon(Icons.check_rounded, color: Colors.white, size: 14)
                          : null,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text.rich(TextSpan(
                        style: TextStyle(fontSize: 13, color: muted, height: 1.5),
                        children: [
                          TextSpan(text: l10n.formJAccepte),
                          TextSpan(
                            text: l10n.formConditions,
                            style: const TextStyle(
                              color: _gold, fontWeight: FontWeight.w600,
                              decoration: TextDecoration.underline,
                              decorationColor: _gold,
                            ),
                          ),
                          TextSpan(text: l10n.formDeFiteva),
                        ],
                      )),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ── Submit ─────────────────────────────────────────────────
              SizedBox(
                height: 54,
                child: ElevatedButton(
                  onPressed: _loading ? null : _onSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _gold,
                    disabledBackgroundColor: _gold.withValues(alpha: 0.5),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: _loading
                      ? const SizedBox(width: 20, height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                      : Text(l10n.formEnvoyer,
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(CupertinoIcons.lock_fill, size: 11,
                      color: d ? const Color(0xFF555553) : const Color(0xFFBBBBB9)),
                  const SizedBox(width: 5),
                  Text(l10n.formSecurise,
                      style: TextStyle(
                        fontSize: 11.5,
                        color: d ? const Color(0xFF555553) : const Color(0xFFBBBBB9),
                      )),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String text, Color ink) {
    return Text(text,
        style: TextStyle(
            fontSize: 15, fontWeight: FontWeight.w700, color: ink));
  }

  Widget _field({
    required TextEditingController ctrl,
    required String label,
    required bool d,
    required IconData icon,
    String? hint,
    TextInputType? keyboard,
    int lines = 1,
    String? Function(String?)? validator,
  }) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(
          color: d ? const Color(0xFF2C2C2A) : const Color(0xFFE0E0DE)),
    );
    return TextFormField(
      controller: ctrl,
      maxLines: lines,
      keyboardType: keyboard,
      validator: validator,
      style: TextStyle(
          color: d ? const Color(0xFFF0F0EE) : const Color(0xFF111110),
          fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, size: 18, color: _gold),
        filled: true,
        fillColor: d ? const Color(0xFF191919) : Colors.white,
        labelStyle: TextStyle(
            color: d ? const Color(0xFF888886) : const Color(0xFF888886),
            fontSize: 13.5),
        hintStyle: TextStyle(
            color: d ? const Color(0xFF444442) : const Color(0xFFBBBBB9),
            fontSize: 13),
        border: border,
        enabledBorder: border,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _gold, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFD04040)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFD04040), width: 1.5),
        ),
        contentPadding: EdgeInsets.symmetric(
            horizontal: 14, vertical: lines > 1 ? 14 : 0),
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

  static const _gold = Color(0xFFC4972A);

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
    final surface = widget.isDark ? const Color(0xFF161616) : Colors.white;
    final ink     = widget.isDark ? const Color(0xFFF0F0EE) : const Color(0xFF111110);
    final muted   = widget.isDark ? const Color(0xFF888886) : const Color(0xFF6B6B68);
    final handle  = widget.isDark ? const Color(0xFF2A2A28) : const Color(0xFFE8E8E6);

    return FadeTransition(
      opacity: _fade,
      child: Container(
        margin: const EdgeInsets.all(12),
        padding: EdgeInsets.fromLTRB(
            24, 16, 24, MediaQuery.of(context).padding.bottom + 28),
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
                  color: _gold.withValues(alpha: widget.isDark ? 0.15 : 0.10),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_rounded, color: _gold, size: 34),
              ),
            ),
            const SizedBox(height: 20),

            Text(l10n.formCandidature,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800,
                    color: ink, letterSpacing: -0.5)),
            const SizedBox(height: 8),
            Text(l10n.formRecontact,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13.5, color: muted, height: 1.5)),
            const SizedBox(height: 24),

            // Steps
            ...[
              (l10n.formVerif,        '1–2 jours'),
              (l10n.formAppel,        '3–5 jours'),
              (l10n.formMiseEnLigne,  '1 semaine'),
            ].map((s) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  const Icon(Icons.circle, size: 6, color: _gold),
                  const SizedBox(width: 10),
                  Expanded(child: Text(s.$1,
                      style: TextStyle(fontSize: 13, color: ink, fontWeight: FontWeight.w500))),
                  Text(s.$2, style: TextStyle(fontSize: 12, color: muted)),
                ],
              ),
            )),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: widget.onClose,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _gold,
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
