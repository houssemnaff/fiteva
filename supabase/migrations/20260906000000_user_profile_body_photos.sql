-- ═══════════════════════════════════════════════════════════════════════════
-- user_profiles : ajoute les 4 photos de progression corporelle capturées à
-- l'onboarding (face, gauche, droite, dos), hébergées sur Cloudinary comme
-- image_url. Auparavant sauvegardées uniquement en local (SharedPreferences),
-- donc perdues à la réinstallation et jamais visibles ailleurs dans l'app.
-- ═══════════════════════════════════════════════════════════════════════════

alter table public.user_profiles
  add column if not exists body_photo_front text not null default '',
  add column if not exists body_photo_left  text not null default '',
  add column if not exists body_photo_right text not null default '',
  add column if not exists body_photo_back  text not null default '';

-- ── ROLLBACK ──────────────────────────────────────────────────────────────
-- alter table public.user_profiles
--   drop column if exists body_photo_front,
--   drop column if exists body_photo_left,
--   drop column if exists body_photo_right,
--   drop column if exists body_photo_back;
