// Edge Function : rappels quotidiens automatiques.
// À planifier via pg_cron (ex. tous les jours à 8h, 9h et 18h).
//
//   POST /functions/v1/daily-reminders  { "slot": "morning" | "cycle" | "evening" | "inactivity" }
//
// morning (8h) :
//   - séance planifiée aujourd'hui dans user_weekly_plans
// cycle (9h) :
//   - conseil adapté à la phase du cycle
// evening (18h) :
//   - aucun repas loggé aujourd'hui dans user_meal_entries
// inactivity (20h) :
//   - aucun workout complété depuis 3+ jours

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
  const weekday = (now.getDay() + 6) % 7;
  const monday = new Date(now);
  monday.setDate(now.getDate() - weekday);
  const weekStart = `${monday.getFullYear()}-${pad(monday.getMonth() + 1)}-${pad(monday.getDate())}`;
  return { dateKey, weekStart, weekdayIndex: weekday };
}

function getCyclePhase(lastPeriod: string | null, cycleDays: number): { phase: string; day: number } {
  if (!lastPeriod) return { phase: "unknown", day: 1 };
  const last = new Date(lastPeriod);
  const now = new Date();
  const diffDays = Math.floor((now.getTime() - last.getTime()) / (1000 * 60 * 60 * 24));
  const currentDay = (diffDays % cycleDays) + 1;

  if (currentDay <= 5) return { phase: "Règles", day: currentDay };
  if (currentDay <= 13) return { phase: "Folliculaire", day: currentDay };
  if (currentDay <= 16) return { phase: "Ovulation", day: currentDay };
  return { phase: "Lutéale", day: currentDay };
}

const cycleMessages: Record<string, { title: string; body: string }> = {
  "Règles": {
    title: "Phase menstruelle 🌙",
    body: "Écoute ton corps aujourd'hui. Privilégie le yoga, la marche douce et le repos.",
  },
  "Folliculaire": {
    title: "Phase folliculaire 🌱",
    body: "Ton énergie remonte ! C'est le moment idéal pour des entraînements intenses.",
  },
  "Ovulation": {
    title: "Pic d'énergie ! ⚡",
    body: "Tu es au sommet de ta forme. Parfait pour le HIIT et les performances max.",
  },
  "Lutéale": {
    title: "Phase lutéale 🍂",
    body: "Ton corps se prépare. Privilégie le Pilates, le yoga et la mobilité.",
  },
};

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
    } else if (slot === "cycle") {
      // Rappels adaptés à la phase du cycle
      const { data: users } = await supabase
        .from("user_fcm_tokens")
        .select("user_id");
      const uniqueUsers = [...new Set((users ?? []).map((u) => u.user_id))];

      for (const uid of uniqueUsers) {
        const { data: bio } = await supabase
          .from("user_biometrics")
          .select("last_period, cycle_duration, health_status")
          .eq("user_id", uid)
          .maybeSingle();

        if (!bio || bio.health_status !== "cycle" || !bio.last_period) continue;

        const cycleDays = parseInt(bio.cycle_duration?.replace(/[^0-9]/g, "") || "28") || 28;
        const { phase } = getCyclePhase(bio.last_period, cycleDays);
        const msg = cycleMessages[phase];
        if (!msg) continue;

        await sendPush(uid, msg.title, msg.body);
        sent++;
      }
    } else if (slot === "inactivity") {
      // Utilisateurs inactifs depuis 3+ jours
      const { data: users } = await supabase
        .from("user_fcm_tokens")
        .select("user_id");
      const uniqueUsers = [...new Set((users ?? []).map((u) => u.user_id))];

      const threeDaysAgo = new Date();
      threeDaysAgo.setDate(threeDaysAgo.getDate() - 3);
      const cutoff = threeDaysAgo.toISOString();

      for (const uid of uniqueUsers) {
        // Check for any workout completion in the last 3 days
        const { count } = await supabase
          .from("user_workout_completions")
          .select("id", { count: "exact", head: true })
          .eq("user_id", uid)
          .gte("completed_at", cutoff);

        if ((count ?? 0) === 0) {
          // Also check video completions (partial activity)
          const { count: videoCount } = await supabase
            .from("user_video_completions")
            .select("id", { count: "exact", head: true })
            .eq("user_id", uid)
            .eq("completed", true)
            .gte("completed_at", cutoff);

          if ((videoCount ?? 0) === 0) {
            await sendPush(
              uid,
              "Tu nous manques ! 💜",
              "Ça fait quelques jours… Même 10 minutes comptent. On s'y remet ?",
            );
            sent++;
          }
        }
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
