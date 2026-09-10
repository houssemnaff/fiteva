-- ═══════════════════════════════════════════════════════════════════════════
-- Adds feed notification types (post liked / commented) to the existing
-- user_notifications CHECK constraint. See 20260803000000_user_notifications.sql
-- for the original table (event_joined, partner_request_received,
-- partner_request_accepted).
-- ═══════════════════════════════════════════════════════════════════════════

alter table public.user_notifications
  drop constraint if exists user_notifications_type_check;

alter table public.user_notifications
  add constraint user_notifications_type_check check (type in (
    'event_joined',
    'partner_request_received',
    'partner_request_accepted',
    'post_liked',
    'post_commented'
  ));

-- ── ROLLBACK ──────────────────────────────────────────────────────────────
-- alter table public.user_notifications drop constraint if exists user_notifications_type_check;
-- alter table public.user_notifications add constraint user_notifications_type_check
--   check (type in ('event_joined','partner_request_received','partner_request_accepted'));
