// Edge Function : rappels quotidiens automatiques.
// À planifier via pg_cron (ex. tous les jours à 8h et 18h).
//
//   POST /functions/v1/daily-reminders  { "slot": "morning" | "evening" }
//
// morning (8h) :
//   - séance planifiée aujourd'hui dans user_weekly_plans
// evening (18h) :
//   - aucun repas loggé aujourd'hui dans user_meal_entries

import { createClient } from "npm:@supabase/supabase-js@2";

const FN_URL = Deno.env.get("SUPABASE_URL")! + "/functions/v1/send-push";

async function sendPush(userId: string, title: string, body: string) {
  await fetch(FN_URL, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      Authorization: `Bearer ${Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")}`,
    },
    body: JSON.stringify({ user_id: userId, title, body }),
  });
}

function todayKeys() {
  const now = new Date();
  const pad = (n: number) => String(n).padStart(2, "0");
  const dateKey = `${now.getFullYear()}-${pad(now.getMonth() + 1)}-${pad(now.getDate())}`;
  // Lundi de la semaine courante + index du jour (0 = lundi)
  const weekday = (now.getDay() + 6) % 7;
  const monday = new Date(now);
  monday.setDate(now.getDate() - weekday);
  const weekStart = `${monday.getFullYear()}-${pad(monday.getMonth() + 1)}-${pad(monday.getDate())}`;
  return { dateKey, weekStart, weekdayIndex: weekday };
}

Deno.serve(async (req) => {
  try {
    const { slot } = await req.json().catch(() => ({ slot: "morning" }));
    const supabase = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
    );
    const { dateKey, weekStart, weekdayIndex } = todayKeys();
    let sent = 0;

    if (slot === "morning") {
      // Séances planifiées aujourd'hui
      const { data: plans } = await supabase
        .from("user_weekly_plans")
        .select("user_id, category_id, status")
        .eq("week_start", weekStart)
        .eq("weekday_index", weekdayIndex)
        .eq("status", "planned");

      for (const p of plans ?? []) {
        await sendPush(
          p.user_id,
          "C'est jour de séance ! 💪",
          p.category_id
            ? `Ta séance ${p.category_id} t'attend aujourd'hui. Tu vas y arriver !`
            : "Ta séance planifiée t'attend aujourd'hui. Tu vas y arriver !",
        );
        sent++;
      }
    } else {
      // evening : utilisateurs avec token mais aucun repas loggé aujourd'hui
      const { data: users } = await supabase
        .from("user_fcm_tokens")
        .select("user_id");
      const uniqueUsers = [...new Set((users ?? []).map((u) => u.user_id))];

      for (const uid of uniqueUsers) {
        const { count } = await supabase
          .from("user_meal_entries")
          .select("id", { count: "exact", head: true })
          .eq("user_id", uid)
          .eq("date", dateKey);

        if ((count ?? 0) === 0) {
          await sendPush(
            uid,
            "N'oublie pas tes repas 🥗",
            "Tu n'as encore rien loggé aujourd'hui. Prends 30 secondes pour suivre ta nutrition !",
          );
          sent++;
        }
      }
    }

    return new Response(JSON.stringify({ slot, sent }), {
      status: 200,
      headers: { "Content-Type": "application/json" },
    });
  } catch (e) {
    return new Response(JSON.stringify({ error: String(e) }), { status: 500 });
  }
});
