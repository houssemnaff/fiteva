import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/stripe_config.dart';
import '../services/supabase_config.dart';

/// Abonnement courant — lu depuis `user_subscriptions` (source de vérité
/// unique, tenue à jour côté serveur par les Edge Functions Stripe).
class SubscriptionState {
  final SubscriptionPlan plan;
  final String status;

  const SubscriptionState({
    this.plan = SubscriptionPlan.free,
    this.status = 'inactive',
  });

  /// Pro tant que l'abonnement est actif, en essai, ou annulé mais encore
  /// dans sa période payée ("canceling" = ne se renouvellera pas, mais
  /// reste actif jusqu'à current_period_end).
  bool get isPro =>
      plan != SubscriptionPlan.free &&
      (status == 'active' || status == 'trialing' || status == 'canceling');
}

class SubscriptionNotifier extends AsyncNotifier<SubscriptionState> {
  @override
  Future<SubscriptionState> build() async {
    final uid = SupabaseConfig.userId;
    debugPrint('[Subscription] build() — uid=$uid');
    final row = await StripeService.fetchSubscription();
    debugPrint('[Subscription] row=$row');
    if (row == null) return const SubscriptionState();
    final s = SubscriptionState(
      plan: SubscriptionPlanX.fromId(row['plan'] as String?),
      status: row['status'] as String? ?? 'inactive',
    );
    debugPrint('[Subscription] plan=${s.plan}, status=${s.status}, isPro=${s.isPro}');
    return s;
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final row = await StripeService.fetchSubscription();
      if (row == null) return const SubscriptionState();
      return SubscriptionState(
        plan: SubscriptionPlanX.fromId(row['plan'] as String?),
        status: row['status'] as String? ?? 'inactive',
      );
    });
  }
}

final subscriptionProvider =
    AsyncNotifierProvider<SubscriptionNotifier, SubscriptionState>(
        SubscriptionNotifier.new);

/// True si l'utilisateur a un abonnement Pro actif — false pendant le
/// chargement ou en cas d'erreur (fail-closed : on ne débloque pas le
/// contenu payant tant qu'on n'a pas confirmé le statut).
final isProProvider = Provider<bool>((ref) {
  final uid = SupabaseConfig.userId;
  if (uid == null) return false;
  return ref.watch(subscriptionProvider).value?.isPro ?? false;
});
