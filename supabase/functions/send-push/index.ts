// Edge Function : envoie une notification push FCM à un utilisateur.
//
// Appel :
//   POST /functions/v1/send-push
//   { "user_id": "uuid", "title": "...", "body": "...", "data": { ... } }
//
// Secrets requis (supabase secrets set) :
//   FCM_SERVICE_ACCOUNT — contenu JSON du service account Firebase
//     (Console Firebase → Project Settings → Service accounts → Generate new private key)

import { createClient } from "npm:@supabase/supabase-js@2";

interface PushPayload {
  user_id: string;
  title: string;
  body: string;
  data?: Record<string, string>;
}

// ── Auth Google : JWT signé → access token OAuth2 ────────────────────────────
async function getAccessToken(sa: {
  client_email: string;
  private_key: string;
}): Promise<string> {
  const now = Math.floor(Date.now() / 1000);
  const header = { alg: "RS256", typ: "JWT" };
  const claims = {
    iss: sa.client_email,
    scope: "https://www.googleapis.com/auth/firebase.messaging",
    aud: "https://oauth2.googleapis.com/token",
    iat: now,
    exp: now + 3600,
  };

  const enc = (obj: unknown) =>
    btoa(JSON.stringify(obj)).replace(/\+/g, "-").replace(/\//g, "_").replace(/=+$/, "");
  const unsigned = `${enc(header)}.${enc(claims)}`;

  // Import de la clé privée PEM
  const pem = sa.private_key
    .replace("-----BEGIN PRIVATE KEY-----", "")
    .replace("-----END PRIVATE KEY-----", "")
    .replace(/\s/g, "");
  const keyData = Uint8Array.from(atob(pem), (c) => c.charCodeAt(0));
  const key = await crypto.subtle.importKey(
    "pkcs8", keyData,
    { name: "RSASSA-PKCS1-v1_5", hash: "SHA-256" },
    false, ["sign"],
  );
  const sig = await crypto.subtle.sign(
    "RSASSA-PKCS1-v1_5", key, new TextEncoder().encode(unsigned),
  );
  const sigB64 = btoa(String.fromCharCode(...new Uint8Array(sig)))
    .replace(/\+/g, "-").replace(/\//g, "_").replace(/=+$/, "");

  const jwt = `${unsigned}.${sigB64}`;
  const res = await fetch("https://oauth2.googleapis.com/token", {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: `grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer&assertion=${jwt}`,
  });
  const json = await res.json();
  if (!json.access_token) throw new Error(`OAuth failed: ${JSON.stringify(json)}`);
  return json.access_token;
}

Deno.serve(async (req) => {
  try {
    const payload: PushPayload = await req.json();
    if (!payload.user_id || !payload.title) {
      return new Response(JSON.stringify({ error: "user_id et title requis" }), { status: 400 });
    }

    const sa = JSON.parse(Deno.env.get("FCM_SERVICE_ACCOUNT") ?? "{}");
    if (!sa.client_email) {
      return new Response(JSON.stringify({ error: "FCM_SERVICE_ACCOUNT non configuré" }), { status: 500 });
    }

    // Récupère les tokens de l'utilisateur (service role — bypass RLS)
    const supabase = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
    );
    const { data: tokens, error } = await supabase
      .from("user_fcm_tokens")
      .select("token")
      .eq("user_id", payload.user_id);
    if (error) throw error;
    if (!tokens?.length) {
      return new Response(JSON.stringify({ sent: 0, reason: "no tokens" }), { status: 200 });
    }

    const accessToken = await getAccessToken(sa);
    const projectId = sa.project_id;
    let sent = 0;

    for (const { token } of tokens) {
      const res = await fetch(
        `https://fcm.googleapis.com/v1/projects/${projectId}/messages:send`,
        {
          method: "POST",
          headers: {
            Authorization: `Bearer ${accessToken}`,
            "Content-Type": "application/json",
          },
          body: JSON.stringify({
            message: {
              token,
              notification: { title: payload.title, body: payload.body },
              data: payload.data ?? {},
              android: { priority: "high" },
            },
          }),
        },
      );
      if (res.ok) {
        sent++;
      } else if (res.status === 404 || res.status === 410) {
        // Token expiré → nettoyage
        await supabase.from("user_fcm_tokens").delete().eq("token", token);
      }
    }

    return new Response(JSON.stringify({ sent }), {
      status: 200,
      headers: { "Content-Type": "application/json" },
    });
  } catch (e) {
    return new Response(JSON.stringify({ error: String(e) }), { status: 500 });
  }
});
