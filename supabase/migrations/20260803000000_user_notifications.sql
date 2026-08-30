-- ═══════════════════════════════════════════════════════════════════════════
-- In-app notifications (bell icon) — distinct from push/FCM (user_fcm_tokens,
-- send-push edge function), which are untouched by this migration.
-- ═══════════════════════════════════════════════════════════════════════════

create table if not exists public.user_notifications (
  id          uuid        primary key default gen_random_uuid(),
  user_id     uuid        not null references public.user_profiles(id) on delete cascade,
  actor_id    uuid        references public.user_profiles(id) on delete set null,
  type        text        not null check (type in (
                'event_joined',
                'partner_request_received',
                'partner_request_accepted'
              )),
  title       text        not null default '',
  body        text        not null default '',
  data        jsonb       not null default '{}'::jsonb,
  is_read     boolean     not null default false,
  created_at  timestamptz not null default now()
);

create index if not exists idx_user_notifications_user_created
  on public.user_notifications (user_id, created_at desc);
create index if not exists idx_user_notifications_unread
  on public.user_notifications (user_id)
  where is_read = false;

alter table public.user_notifications enable row level security;

create policy "notifications_select" on public.user_notifications
  for select using (auth.uid() = user_id);

create policy "notifications_update" on public.user_notifications
  for update using (auth.uid() = user_id) with check (auth.uid() = user_id);

-- Actor inserts a row addressed to a DIFFERENT user (the recipient). This
-- widens the generic "own_%s" (auth.uid() = user_id) RLS pattern used
-- elsewhere in this schema on purpose: the actor and the recipient are
-- different people by design (e.g. B joins A's event → row addressed to A,
-- inserted by B's client). What this policy enforces: the inserting client
-- must be authenticated as the actor it claims to be (auth.uid() =
-- actor_id), can't self-notify (actor_id <> user_id), and `type` is
-- restricted to the fixed enum above. It does NOT verify that the
-- referenced event/partner request in `data` is real — same trust level
-- already accepted for event_participants/partner_join_requests themselves.
create policy "notifications_insert" on public.user_notifications
  for insert with check (
    auth.uid() = actor_id
    and actor_id <> user_id
  );

-- ── ROLLBACK ──────────────────────────────────────────────────────────────
-- drop table if exists public.user_notifications;
