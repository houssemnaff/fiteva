import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../services/stripe_config.dart';
import '../../providers/subscription_provider.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// Abonnement — bouton "Passer Pro" du profil + bottom sheet des 3 offres
/// (Gratuit · Pro Mensuel · Pro Annuel), paiement via Stripe PaymentSheet.
///
/// L'état de l'abonnement lui-même (fetch, cache, isPro) vit dans
/// providers/subscription_provider.dart — source de vérité unique partagée
/// avec les autres écrans qui gatent du contenu Pro (tendances, coach IA).
/// ─────────────────────────────────────────────────────────────────────────────

/// Plan actif dérivé de l'abonnement partagé.
final currentPlanProvider = Provider<SubscriptionPlan>((ref) {
  final sub = ref.watch(subscriptionProvider).value;
  if (sub == null) return SubscriptionPlan.free;
  return sub.isPro ? sub.plan : SubscriptionPlan.free;
});

// ─── Bouton affiché dans le profil ───────────────────────────────────────────
class SubscriptionButton extends ConsumerWidget {
  const SubscriptionButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final plan   = ref.watch(currentPlanProvider);
    final isPro  = plan != SubscriptionPlan.free;

    final surf  = isDark ? const Color(0xFF1A1A1A) : Colors.white;
    final ink   = isDark ? const Color(0xFFF0F0EE) : const Color(0xFF111110);
    final muted = isDark ? const Color(0xFF888886) : const Color(0xFF6B6B68);
    final gold  = const Color(0xFFF59E0B);
    final green = const Color(0xFF22C55E);

    return GestureDetector(
      onTap: () => showSubscriptionPlans(context, ref),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: surf,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: gold.withValues(alpha: 0.35), width: 1),
          boxShadow: [BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            Container(
              width: 34, height: 34,
              decoration: BoxDecoration(
                color: gold.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(LucideIcons.crown, size: 16, color: gold),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(isPro ? 'Abonnement ${plan.label}' : 'Passer Pro',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
                      color: ink)),
                  const SizedBox(height: 2),
                  Text(
                    isPro
                        ? 'Gérer mon abonnement'
                        : 'Débloque tous les programmes & fonctionnalités',
                    style: TextStyle(fontSize: 11, color: muted)),
                ],
              ),
            ),
            if (isPro)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: green.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('PRO',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800,
                    color: green, letterSpacing: 0.5)),
              )
            else
              Icon(LucideIcons.chevronRight, size: 16, color: muted),
          ],
        ),
      ),
    );
  }
}

/// Ouvre le bottom sheet des offres.
void showSubscriptionPlans(BuildContext context, WidgetRef ref) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _PlansSheet(),
  );
}

// ─── Bottom sheet : les 3 offres ─────────────────────────────────────────────
class _PlansSheet extends ConsumerStatefulWidget {
  const _PlansSheet();

  @override
  ConsumerState<_PlansSheet> createState() => _PlansSheetState();
}

class _PlansSheetState extends ConsumerState<_PlansSheet> {
  SubscriptionPlan? _processing;

  static const _features = {
    SubscriptionPlan.free: [
      'Programmes de base',
      'Suivi nutrition simple',
      'Communauté',
    ],
    SubscriptionPlan.proMonthly: [
      'Tous les programmes & vidéos',
      'Plans nutrition personnalisés',
      'Suivi cycle / grossesse avancé',
      'Assistant IA illimité',
    ],
    SubscriptionPlan.proAnnual: [
      'Tous les avantages Pro',
      '2 mois offerts (-33 %)',
      'Accès prioritaire aux nouveautés',
    ],
  };

  Future<void> _choosePlan(SubscriptionPlan plan) async {
    if (_processing != null) return;
    final currentPlan = ref.read(currentPlanProvider);
    if (plan == currentPlan) return;

    final messenger = ScaffoldMessenger.of(context);

    // Gratuit sélectionné alors qu'un abonnement Pro est actif → annulation
    if (plan == SubscriptionPlan.free) {
      final confirmed = await _confirmCancel();
      if (confirmed != true || !mounted) return;
      setState(() => _processing = plan);
      final ok = await StripeService.cancelSubscription();
      ref.invalidate(subscriptionProvider);
      if (!mounted) return;
      setState(() => _processing = null);
      Navigator.of(context).pop();
      messenger.showSnackBar(SnackBar(
        content: Text(ok
            ? 'Abonnement annulé — actif jusqu\'à la fin de la période payée.'
            : 'Impossible d\'annuler l\'abonnement, réessaie plus tard.')));
      return;
    }

    // Plan payant → PaymentSheet Stripe
    setState(() => _processing = plan);
    final result = await StripeService.subscribe(plan);
    ref.invalidate(subscriptionProvider);
    if (!mounted) return;
    setState(() => _processing = null);

    if (result.success) {
      Navigator.of(context).pop();
      messenger.showSnackBar(SnackBar(
        content: Text('🎉 Bienvenue dans FITEVA ${plan.label} !')));
    } else if (!result.canceledByUser) {
      messenger.showSnackBar(SnackBar(
        content: Text(result.error ?? 'Le paiement a échoué.')));
    }
  }

  Future<bool?> _confirmCancel() {
    final cs = Theme.of(context).colorScheme;
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: cs.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Revenir au plan gratuit ?',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
        content: Text(
          'Ton abonnement Pro restera actif jusqu\'à la fin de la période déjà payée.',
          style: TextStyle(fontSize: 14, color: cs.onSurface.withValues(alpha: 0.7))),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('Garder Pro',
              style: TextStyle(color: cs.onSurface.withValues(alpha: 0.6)))),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Annuler l\'abonnement',
              style: TextStyle(color: Color(0xFFE53935), fontWeight: FontWeight.w700))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dark  = Theme.of(context).brightness == Brightness.dark;
    final green = const Color(0xFF22C55E);
    final gold  = const Color(0xFFF59E0B);
    final surf  = dark ? const Color(0xFF1A1A1A) : Colors.white;
    final ink   = dark ? const Color(0xFFF0F0EE) : const Color(0xFF111110);
    final muted = dark ? const Color(0xFF888886) : const Color(0xFF6B6B68);
    final div   = dark ? const Color(0xFF2A2A2A) : const Color(0xFFF0F0EE);
    final currentPlan = ref.watch(currentPlanProvider);

    return Container(
      decoration: BoxDecoration(
        color: surf,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 14, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Handle ────────────────────────────────────────────────
              Center(child: Container(
                width: 36, height: 4,
                decoration: BoxDecoration(color: div,
                  borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 20),

              // ── Header ────────────────────────────────────────────────
              Row(children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: gold.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12)),
                  child: Icon(LucideIcons.crown, size: 18, color: gold)),
                const SizedBox(width: 12),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Choisis ton offre',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800,
                      color: ink, letterSpacing: -0.4)),
                  Text('Annulable à tout moment',
                    style: TextStyle(fontSize: 12, color: muted)),
                ]),
              ]),
              const SizedBox(height: 20),

              // ── Les 3 offres ──────────────────────────────────────────
              for (final plan in SubscriptionPlan.values) ...[
                _PlanCard(
                  plan: plan,
                  features: _features[plan]!,
                  isCurrent: plan == currentPlan,
                  isLoading: _processing == plan,
                  highlighted: plan == SubscriptionPlan.proAnnual,
                  green: green, gold: gold, ink: ink,
                  muted: muted, div: div, dark: dark,
                  onTap: () => _choosePlan(plan),
                ),
                const SizedBox(height: 12),
              ],

              // ── Note test ─────────────────────────────────────────────
              Center(child: Text(
                'Paiement sécurisé par Stripe',
                style: TextStyle(fontSize: 11, color: muted))),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Carte d'une offre ───────────────────────────────────────────────────────
class _PlanCard extends StatelessWidget {
  final SubscriptionPlan plan;
  final List<String> features;
  final bool isCurrent, isLoading, highlighted, dark;
  final Color green, gold, ink, muted, div;
  final VoidCallback onTap;

  const _PlanCard({
    required this.plan, required this.features,
    required this.isCurrent, required this.isLoading, required this.highlighted,
    required this.green, required this.gold, required this.ink,
    required this.muted, required this.div, required this.dark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final accent = plan == SubscriptionPlan.free ? muted : green;

    return GestureDetector(
      onTap: isCurrent || isLoading ? null : onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: dark ? const Color(0xFF1F1F1F) : const Color(0xFFFAFAF9),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isCurrent
                ? green
                : highlighted ? gold.withValues(alpha: 0.5) : div,
            width: isCurrent || highlighted ? 1.5 : 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Expanded(
                child: Row(children: [
                  Flexible(child: Text(plan.label,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800,
                      color: ink))),
                  if (highlighted) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: gold.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6)),
                      child: Text('-33 %',
                        style: TextStyle(fontSize: 10,
                          fontWeight: FontWeight.w800, color: gold))),
                  ],
                ]),
              ),
              Text(plan.priceLabel,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800,
                  color: accent)),
            ]),
            const SizedBox(height: 10),

            for (final f in features)
              Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Row(children: [
                  Icon(LucideIcons.check, size: 13, color: accent),
                  const SizedBox(width: 8),
                  Expanded(child: Text(f,
                    style: TextStyle(fontSize: 12, color: muted))),
                ]),
              ),
            const SizedBox(height: 10),

            // ── Bouton ────────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 42,
              child: isCurrent
                  ? Container(
                      decoration: BoxDecoration(
                        color: green.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: green.withValues(alpha: 0.4))),
                      child: Center(child: Text('Plan actuel',
                        style: TextStyle(fontSize: 13,
                          fontWeight: FontWeight.w700, color: green))))
                  : Container(
                      decoration: BoxDecoration(
                        color: plan == SubscriptionPlan.free
                            ? Colors.transparent
                            : green,
                        borderRadius: BorderRadius.circular(12),
                        border: plan == SubscriptionPlan.free
                            ? Border.all(color: div, width: 1.2)
                            : null,
                        boxShadow: plan == SubscriptionPlan.free || isLoading
                            ? []
                            : [BoxShadow(
                                color: green.withValues(alpha: 0.28),
                                blurRadius: 10, offset: const Offset(0, 3))]),
                      child: Center(
                        child: isLoading
                            ? SizedBox(width: 18, height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.2,
                                  color: plan == SubscriptionPlan.free
                                      ? muted : Colors.white))
                            : Text(
                                plan == SubscriptionPlan.free
                                    ? 'Revenir au gratuit'
                                    : 'Choisir ${plan.label}',
                                style: TextStyle(fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: plan == SubscriptionPlan.free
                                      ? muted : Colors.white)))),
            ),
          ],
        ),
      ),
    );
  }
}
