-- ═══════════════════════════════════════════════════════════════════════════
-- user_body_logs : journal quotidien de composition corporelle (poids,
-- % masse grasse, tour de taille/hanches/poitrine/cuisses/bras).
--
-- Cette table est référencée depuis longtemps par body_tracking_provider.dart
-- (upsert onConflict 'user_id,date' dans l'écran "Mon Corps") mais n'avait
-- jamais été créée en base : chaque écriture échouait silencieusement
-- (catchError) et retombait sur le cache local uniquement — jamais
-- synchronisée côté serveur, jamais visible sur un autre appareil.
--
-- L'onboarding (étapes Body Composition / Body Measurements) alimente
-- désormais aussi la 1re entrée de ce journal (voir storage_service.dart).
-- ═══════════════════════════════════════════════════════════════════════════

create table if not exists public.user_body_logs (
  user_id      uuid         not null references public.user_profiles(id) on delete cascade,
  date         date         not null,
  weight_kg    numeric(5,1) check (weight_kg between 20 and 300),
  body_fat_pct numeric(4,1) check (body_fat_pct between 3 and 70),
  waist_cm     numeric(5,1),
  hips_cm      numeric(5,1),
  chest_cm     numeric(5,1),
  thighs_cm    numeric(5,1),
  arms_cm      numeric(5,1),
  updated_at   timestamptz  not null default now(),
  primary key (user_id, date)
);

alter table public.user_body_logs enable row level security;

create policy "own_user_body_logs" on public.user_body_logs for all
  using (auth.uid() = user_id) with check (auth.uid() = user_id);

create trigger trg_user_body_logs_upd before update on public.user_body_logs
  for each row execute function set_updated_at();

-- ── ROLLBACK ──────────────────────────────────────────────────────────────
-- drop trigger if exists trg_user_body_logs_upd on public.user_body_logs;
-- drop policy if exists "own_user_body_logs" on public.user_body_logs;
-- drop table if exists public.user_body_logs;
