-- ═══════════════════════════════════════════════════════════════════════════
-- user_notifications : le destinataire peut supprimer ses propres
-- notifications (swipe-to-delete côté app). Policy manquante à la création
-- de la table (seules select/update/insert existaient).
-- ═══════════════════════════════════════════════════════════════════════════

create policy "notifications_delete" on public.user_notifications
  for delete using (auth.uid() = user_id);

-- ── ROLLBACK ──────────────────────────────────────────────────────────────
-- drop policy if exists "notifications_delete" on public.user_notifications;
