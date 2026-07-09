import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

import 'supabase_config.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// Configuration Stripe — abonnements FITEVA (Gratuit / Pro Mensuel / Pro Annuel)
///
/// ⚠️ SÉCURITÉ : seule la clé PUBLIQUE (pk_...) vit dans l'app.
/// La clé secrète (sk_...) ne doit JAMAIS être embarquée dans le code Flutter :
/// elle est stockée côté Supabase Edge Functions via :
///   supabase secrets set STRIPE_SECRET_KEY=sk_test_...
///
/// Flux de paiement :
///   1. L'app appelle l'Edge Function `stripe-subscription` (action: create)
///   2. La fonction crée le customer + la subscription Stripe (incomplete)
///      et renvoie le client_secret du PaymentIntent
///   3. L'app présente le PaymentSheet natif Stripe
///   4. Après paiement, l'app rappelle la fonction (action: sync) qui
///      enregistre l'abonnement dans la table `user_subscriptions`
///   5. Le webhook `stripe-webhook` tient la table à jour (renouvellements,
///      annulations, échecs de paiement)
/// ─────────────────────────────────────────────────────────────────────────────
class StripeConfig {
  static const String publishableKey =
      'pk_test_51Qb8gxJxlE6jLxsdeHbZNm1VciJPheszw3GlR5qQLdbhNiByAI57NxqrjYQhJIZVn8OzhSBK3zQugPuNPTsiCNsu00Yp0USB9F';

  static const String merchantDisplayName = 'FITEVA';

  /// À appeler dans main() avant runApp() (après WidgetsFlutterBinding).
  static Future<void> initialize() async {
    if (kIsWeb) return; // flutter_stripe PaymentSheet : mobile uniquement
    Stripe.publishableKey = publishableKey;
    await Stripe.instance.applySettings();
  }
}

/// Les 3 offres affichées dans le profil.
enum SubscriptionPlan { free, proMonthly, proAnnual }

extension SubscriptionPlanX on SubscriptionPlan {
  /// Identifiant envoyé à l'Edge Function et stocké en base.
  String get id => switch (this) {
        SubscriptionPlan.free => 'free',
        SubscriptionPlan.proMonthly => 'pro_monthly',
        SubscriptionPlan.proAnnual => 'pro_annual',
      };

  String get label => switch (this) {
        SubscriptionPlan.free => 'Gratuit',
        SubscriptionPlan.proMonthly => 'Pro Mensuel',
        SubscriptionPlan.proAnnual => 'Pro Annuel',
      };

  /// Prix affichés dans l'UI — les montants réellement facturés sont
  /// définis côté Edge Function (supabase/functions/stripe-subscription).
  String get priceLabel => switch (this) {
        SubscriptionPlan.free => '0 €',
        SubscriptionPlan.proMonthly => '9,99 € / mois',
        SubscriptionPlan.proAnnual => '79,99 € / an',
      };

  static SubscriptionPlan fromId(String? id) => switch (id) {
        'pro_monthly' => SubscriptionPlan.proMonthly,
        'pro_annual' => SubscriptionPlan.proAnnual,
        _ => SubscriptionPlan.free,
      };
}

/// Résultat d'une tentative d'abonnement.
class SubscribeResult {
  final bool success;
  final bool canceledByUser;
  final String? error;
  const SubscribeResult._(this.success, this.canceledByUser, this.error);

  static const ok = SubscribeResult._(true, false, null);
  static const canceled = SubscribeResult._(false, true, null);
  factory SubscribeResult.failed(String error) =>
      SubscribeResult._(false, false, error);
}

class StripeService {
  static const String _functionName = 'stripe-subscription';

  /// Abonnement courant depuis la table `user_subscriptions`
  /// (null si l'utilisateur n'a aucune ligne → plan gratuit).
  static Future<Map<String, dynamic>?> fetchSubscription() async {
    final userId = SupabaseConfig.userId;
    if (userId == null) return null;
    try {
      return await SupabaseConfig.table('user_subscriptions')
          .select()
          .eq('user_id', userId)
          .maybeSingle();
    } catch (e) {
      debugPrint('[StripeService] fetchSubscription error: $e');
      return null;
    }
  }

  /// Lance le paiement d'un plan payant via le PaymentSheet Stripe.
  static Future<SubscribeResult> subscribe(SubscriptionPlan plan) async {
    if (plan == SubscriptionPlan.free) {
      return SubscribeResult.failed('Le plan gratuit ne se paie pas.');
    }
    try {
      // 1. Créer la subscription côté serveur (Edge Function)
      final res = await SupabaseConfig.client.functions.invoke(
        _functionName,
        body: {'action': 'create', 'plan': plan.id},
      );
      final data = res.data as Map<String, dynamic>;
      final clientSecret = data['clientSecret'] as String?;
      final subscriptionId = data['subscriptionId'] as String?;
      if (clientSecret == null) {
        return SubscribeResult.failed(
            (data['error'] as String?) ?? 'Réponse serveur invalide.');
      }

      // 2. PaymentSheet natif
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: StripeConfig.merchantDisplayName,
          style: ThemeMode.system,
        ),
      );
      await Stripe.instance.presentPaymentSheet();

      // 3. Synchroniser la table user_subscriptions immédiatement
      await SupabaseConfig.client.functions.invoke(
        _functionName,
        body: {'action': 'sync', 'subscriptionId': subscriptionId},
      );
      return SubscribeResult.ok;
    } on StripeException catch (e) {
      if (e.error.code == FailureCode.Canceled) return SubscribeResult.canceled;
      return SubscribeResult.failed(
          e.error.localizedMessage ?? 'Paiement refusé.');
    } catch (e) {
      debugPrint('[StripeService] subscribe error: $e');
      return SubscribeResult.failed('Erreur de connexion au serveur.');
    }
  }

  /// Annule l'abonnement en cours (à la fin de la période payée).
  static Future<bool> cancelSubscription() async {
    try {
      final res = await SupabaseConfig.client.functions.invoke(
        _functionName,
        body: {'action': 'cancel'},
      );
      final data = res.data as Map<String, dynamic>;
      return data['success'] == true;
    } catch (e) {
      debugPrint('[StripeService] cancel error: $e');
      return false;
    }
  }
}
