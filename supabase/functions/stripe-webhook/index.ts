// ─────────────────────────────────────────────────────────────────────────────
// Edge Function : stripe-webhook
// Tient la table user_subscriptions à jour : renouvellements, annulations,
// échecs de paiement. Appelée par Stripe, pas par l'app.
//
// Déploiement (SANS vérification JWT — c'est Stripe qui appelle) :
//   supabase functions deploy stripe-webhook --no-verify-jwt
//
// Configuration Stripe (dashboard.stripe.com → Developers → Webhooks) :
//   URL : https://mkzybprlhllcrbwlknkg.supabase.co/functions/v1/stripe-webhook
//   Événements : customer.subscription.updated, customer.subscription.deleted,
//                invoice.payment_succeeded, invoice.payment_failed
// Puis :
//   supabase secrets set STRIPE_WEBHOOK_SECRET=whsec_...
// ─────────────────────────────────────────────────────────────────────────────
import Stripe from "npm:stripe@17";
import { createClient } from "npm:@supabase/supabase-js@2";

const stripe = new Stripe(Deno.env.get("STRIPE_SECRET_KEY")!, {
  apiVersion: "2024-06-20",
});
const cryptoProvider = Stripe.createSubtleCryptoProvider();

const supabaseAdmin = createClient(
  Deno.env.get("SUPABASE_URL")!,
  Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
);

async function upsertFromSubscription(sub: Stripe.Subscription) {
  const userId = sub.metadata.user_id;
  if (!userId) return;

  const active = sub.status === "active" || sub.status === "trialing";
  await supabaseAdmin.from("user_subscriptions").upsert({
    user_id: userId,
    plan: active ? (sub.metadata.plan ?? "free") : "free",
    status: sub.cancel_at_period_end && active ? "canceling" : sub.status,
    stripe_customer_id: sub.customer as string,
    stripe_subscription_id: sub.id,
    current_period_end: new Date(sub.current_period_end * 1000).toISOString(),
  });
}

Deno.serve(async (req) => {
  const signature = req.headers.get("Stripe-Signature");
  if (!signature) return new Response("Missing signature", { status: 400 });

  const rawBody = await req.text();
  let event: Stripe.Event;
  try {
    event = await stripe.webhooks.constructEventAsync(
      rawBody,
      signature,
      Deno.env.get("STRIPE_WEBHOOK_SECRET")!,
      undefined,
      cryptoProvider,
    );
  } catch (e) {
    console.error("[stripe-webhook] signature invalide:", e);
    return new Response("Invalid signature", { status: 400 });
  }

  try {
    switch (event.type) {
      case "customer.subscription.updated":
        await upsertFromSubscription(event.data.object as Stripe.Subscription);
        break;

      case "customer.subscription.deleted": {
        const sub = event.data.object as Stripe.Subscription;
        if (sub.metadata.user_id) {
          await supabaseAdmin
            .from("user_subscriptions")
            .update({ plan: "free", status: "canceled" })
            .eq("user_id", sub.metadata.user_id);
        }
        break;
      }

      case "invoice.payment_succeeded":
      case "invoice.payment_failed": {
        const invoice = event.data.object as Stripe.Invoice;
        const subId = invoice.subscription as string | null;
        if (subId) {
          const sub = await stripe.subscriptions.retrieve(subId);
          await upsertFromSubscription(sub);
        }
        break;
      }
    }
    return new Response(JSON.stringify({ received: true }), {
      headers: { "Content-Type": "application/json" },
    });
  } catch (e) {
    console.error("[stripe-webhook]", e);
    return new Response("Webhook handler error", { status: 500 });
  }
});
