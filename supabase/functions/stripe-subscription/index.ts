// ─────────────────────────────────────────────────────────────────────────────
// Edge Function : stripe-subscription
// Gère la création / synchronisation / annulation des abonnements FITEVA.
//
// Déploiement :
//   supabase secrets set STRIPE_SECRET_KEY=sk_test_...
//   supabase functions deploy stripe-subscription
//
// Actions (POST JSON, JWT utilisateur requis) :
//   { "action": "create", "plan": "pro_monthly" | "pro_annual" }
//       → { clientSecret, subscriptionId, customerId }
//   { "action": "sync", "subscriptionId": "sub_..." }
//       → { success, plan, status }
//   { "action": "cancel" }
//       → { success }
// ─────────────────────────────────────────────────────────────────────────────
import Stripe from "npm:stripe@17";
import { createClient } from "npm:@supabase/supabase-js@2";

const stripe = new Stripe(Deno.env.get("STRIPE_SECRET_KEY")!, {
  apiVersion: "2024-06-20",
});

// Client admin (service role) pour écrire dans user_subscriptions
const supabaseAdmin = createClient(
  Deno.env.get("SUPABASE_URL")!,
  Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
);

// Tarifs (en centimes). Modifie ici pour changer les prix facturés.
const PLANS: Record<
  string,
  { amount: number; interval: "month" | "year"; label: string }
> = {
  pro_monthly: { amount: 999, interval: "month", label: "FITEVA Pro Mensuel" },
  pro_annual: { amount: 7999, interval: "year", label: "FITEVA Pro Annuel" },
};

const CORS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

function json(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...CORS, "Content-Type": "application/json" },
  });
}

// Produit "FITEVA Pro" créé automatiquement au premier appel.
async function getOrCreateProduct(): Promise<string> {
  const found = await stripe.products.search({
    query: "metadata['app']:'fiteva' AND active:'true'",
    limit: 1,
  });
  if (found.data.length > 0) return found.data[0].id;
  const product = await stripe.products.create({
    name: "FITEVA Pro",
    metadata: { app: "fiteva" },
  });
  return product.id;
}

// Prix récurrent créé automatiquement (lookup_key = id du plan).
async function getOrCreatePrice(planId: string): Promise<string> {
  const plan = PLANS[planId];
  const found = await stripe.prices.list({
    lookup_keys: [planId],
    active: true,
    limit: 1,
  });
  if (found.data.length > 0) return found.data[0].id;
  const price = await stripe.prices.create({
    product: await getOrCreateProduct(),
    currency: "eur",
    unit_amount: plan.amount,
    recurring: { interval: plan.interval },
    lookup_key: planId,
    nickname: plan.label,
  });
  return price.id;
}

async function getOrCreateCustomer(
  userId: string,
  email: string,
): Promise<string> {
  const { data: row } = await supabaseAdmin
    .from("user_subscriptions")
    .select("stripe_customer_id")
    .eq("user_id", userId)
    .maybeSingle();
  if (row?.stripe_customer_id) return row.stripe_customer_id;

  const customer = await stripe.customers.create({
    email,
    metadata: { user_id: userId },
  });
  await supabaseAdmin.from("user_subscriptions").upsert({
    user_id: userId,
    stripe_customer_id: customer.id,
  });
  return customer.id;
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: CORS });

  try {
    // ── Authentification : utilisateur du JWT ─────────────────────────────
    const authHeader = req.headers.get("Authorization") ?? "";
    const jwt = authHeader.replace("Bearer ", "");
    const { data: userData, error: userErr } =
      await supabaseAdmin.auth.getUser(jwt);
    if (userErr || !userData.user) {
      return json({ error: "Non authentifié" }, 401);
    }
    const user = userData.user;

    const body = await req.json();
    const action = body.action as string;

    // ── CREATE : subscription "incomplete" + client_secret ────────────────
    if (action === "create") {
      const planId = body.plan as string;
      if (!PLANS[planId]) return json({ error: "Plan inconnu" }, 400);

      const customerId = await getOrCreateCustomer(user.id, user.email ?? "");
      const priceId = await getOrCreatePrice(planId);

      const subscription = await stripe.subscriptions.create({
        customer: customerId,
        items: [{ price: priceId }],
        payment_behavior: "default_incomplete",
        payment_settings: { save_default_payment_method: "on_subscription" },
        metadata: { user_id: user.id, plan: planId },
        expand: ["latest_invoice.payment_intent"],
      });

      const invoice = subscription.latest_invoice as Stripe.Invoice;
      const intent = invoice.payment_intent as Stripe.PaymentIntent;

      return json({
        clientSecret: intent.client_secret,
        subscriptionId: subscription.id,
        customerId,
      });
    }

    // ── SYNC : après paiement, enregistrer dans user_subscriptions ────────
    if (action === "sync") {
      const subId = body.subscriptionId as string;
      if (!subId) return json({ error: "subscriptionId manquant" }, 400);

      const sub = await stripe.subscriptions.retrieve(subId);
      if (sub.metadata.user_id !== user.id) {
        return json({ error: "Abonnement d'un autre utilisateur" }, 403);
      }

      const active = sub.status === "active" || sub.status === "trialing";
      await supabaseAdmin.from("user_subscriptions").upsert({
        user_id: user.id,
        plan: active ? sub.metadata.plan : "free",
        status: sub.status,
        stripe_customer_id: sub.customer as string,
        stripe_subscription_id: sub.id,
        current_period_end: new Date(
          sub.current_period_end * 1000,
        ).toISOString(),
      });

      return json({ success: active, plan: sub.metadata.plan, status: sub.status });
    }

    // ── CANCEL : annulation à la fin de la période payée ──────────────────
    if (action === "cancel") {
      const { data: row } = await supabaseAdmin
        .from("user_subscriptions")
        .select("stripe_subscription_id")
        .eq("user_id", user.id)
        .maybeSingle();
      if (!row?.stripe_subscription_id) {
        return json({ error: "Aucun abonnement actif" }, 404);
      }

      await stripe.subscriptions.update(row.stripe_subscription_id, {
        cancel_at_period_end: true,
      });
      await supabaseAdmin
        .from("user_subscriptions")
        .update({ status: "canceling" })
        .eq("user_id", user.id);

      return json({ success: true });
    }

    return json({ error: "Action inconnue" }, 400);
  } catch (e) {
    console.error("[stripe-subscription]", e);
    return json({ error: (e as Error).message }, 500);
  }
});
