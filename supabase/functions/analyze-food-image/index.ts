// ─────────────────────────────────────────────────────────────────────────────
// Edge Function : analyze-food-image
// Proxy vers OpenRouter (vision) pour l'analyse de photos de nourriture.
// Garde la clé API OpenRouter côté serveur — jamais exposée au client.
//
// Déploiement :
//   supabase secrets set OPENROUTER_API_KEY=sk-or-v1-...
//   supabase functions deploy analyze-food-image
//
// Appel (JWT utilisateur requis, POST JSON) :
//   { "image": "data:image/jpeg;base64,....." }
//     → { "items": [ { name, category, kcal, protein, carbs, fat, fiber,
//                       grams, portion_label }, ... ] }
// ─────────────────────────────────────────────────────────────────────────────
import { createClient } from "npm:@supabase/supabase-js@2";

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

const supabaseAdmin = createClient(
  Deno.env.get("SUPABASE_URL")!,
  Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
);

const OPENROUTER_ENDPOINT = "https://openrouter.ai/api/v1/chat/completions";

// Modèle vision capable de sortie JSON structurée (pas un modèle de rerank —
// nvidia/llama-nemotron-rerank-vl-1b-v2 ne fonctionne pas sur /chat/completions).
const MODEL = "google/gemini-2.5-flash";

const PROMPT = `
Tu es un nutritionniste expert. Analyse cette photo de nourriture et identifie
TOUS les aliments/plats distincts visibles — pas seulement celui qui domine
visuellement. Par exemple, une assiette avec un poulet ET du riz ET des
légumes doit produire TROIS entrées séparées dans "items", pas une seule.
Si un seul aliment est visible, renvoie un tableau "items" avec une seule entrée.

Pour chaque aliment détecté, réponds avec les champs demandés par le schéma :
- name : nom court et clair de l'aliment/plat, en français.
- category : catégorie la plus proche parmi la liste fournie.
- kcal, protein, carbs, fat, fiber : valeurs nutritionnelles estimées
  POUR 100 GRAMMES de cet aliment (pas pour la portion visible).
- grams : poids estimé de la portion visible sur la photo, en grammes.
- portion_label : courte description de la portion (ex. "1 assiette", "1 bol").

Base tes estimations sur des valeurs nutritionnelles réalistes.
`;

const CATEGORY_VALUES = [
  "viandes", "poissons", "oeufslaitiers", "cereales", "legumineuses",
  "legumes", "fruits", "oleagineux", "corpsGras", "platCompose",
  "boissons", "desserts",
];

const FOOD_ITEM_SCHEMA = {
  type: "object",
  properties: {
    name: { type: "string" },
    category: { type: "string", enum: CATEGORY_VALUES },
    kcal: { type: "number" },
    protein: { type: "number" },
    carbs: { type: "number" },
    fat: { type: "number" },
    fiber: { type: "number" },
    grams: { type: "number" },
    portion_label: { type: "string" },
  },
  required: [
    "name", "category", "kcal", "protein", "carbs", "fat",
    "fiber", "grams", "portion_label",
  ],
  additionalProperties: false,
};

const JSON_SCHEMA = {
  name: "food_items",
  strict: true,
  schema: {
    type: "object",
    properties: {
      items: { type: "array", items: FOOD_ITEM_SCHEMA },
    },
    required: ["items"],
    additionalProperties: false,
  },
};

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

    const apiKey = Deno.env.get("OPENROUTER_API_KEY");
    if (!apiKey) {
      return json({ error: "OPENROUTER_API_KEY non configuré" }, 500);
    }

    const body = await req.json();
    const dataUrl = body.image as string | undefined;
    if (!dataUrl || !dataUrl.startsWith("data:")) {
      return json({ error: "Champ 'image' (data URL) manquant" }, 400);
    }

    const orRes = await fetch(OPENROUTER_ENDPOINT, {
      method: "POST",
      headers: {
        Authorization: `Bearer ${apiKey}`,
        "Content-Type": "application/json",
        "HTTP-Referer": "https://fiteva.app",
        "X-Title": "FitEva",
      },
      body: JSON.stringify({
        model: MODEL,
        // Cap la sortie — le JSON attendu est court, et sans cette limite
        // le modèle réserve jusqu'à 65k tokens de budget (402 "insufficient credits").
        max_tokens: 200,
        messages: [
          {
            role: "user",
            content: [
              { type: "text", text: PROMPT },
              { type: "image_url", image_url: { url: dataUrl } },
            ],
          },
        ],
        response_format: { type: "json_schema", json_schema: JSON_SCHEMA },
      }),
    });

    if (!orRes.ok) {
      const errBody = await orRes.text();
      console.error("[analyze-food-image] OpenRouter error", orRes.status, errBody);
      return json({ error: `Échec de l'analyse IA (${orRes.status})` }, 502);
    }

    const decoded = await orRes.json();
    const content = decoded?.choices?.[0]?.message?.content as string | undefined;
    if (!content) {
      return json({ error: "Aucun résultat renvoyé par l'IA." }, 502);
    }

    let parsed: { items?: unknown[] };
    try {
      parsed = JSON.parse(content);
    } catch (e) {
      console.error("[analyze-food-image] JSON invalide", content);
      return json({ error: `Format de résultat IA invalide : ${e}` }, 502);
    }

    if (!parsed.items || parsed.items.length === 0) {
      return json({ error: "Aucun aliment détecté sur cette photo." }, 422);
    }

    return json({ items: parsed.items });
  } catch (e) {
    console.error("[analyze-food-image]", e);
    return json({ error: (e as Error).message }, 500);
  }
});
