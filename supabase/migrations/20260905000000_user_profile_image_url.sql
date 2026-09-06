-- ═══════════════════════════════════════════════════════════════════════════
-- user_profiles : remplace les colonnes d'avatar généré (avatar_seed,
-- avatar_style, avatar_bg_color — jamais réellement écrites par l'app, ni
-- affichées comme image) par une vraie photo de profil hébergée sur
-- Cloudinary (image_url).
--
-- La vue public_profiles dépend des colonnes supprimées : DROP COLUMN
-- échoue tant qu'elle existe (CREATE OR REPLACE VIEW ne peut pas non plus
-- retirer des colonnes), donc on la supprime avant l'ALTER TABLE et on la
-- recrée juste après avec le nouveau schéma.
-- ═══════════════════════════════════════════════════════════════════════════

alter table public.user_profiles
  add column if not exists image_url text not null default '';

drop view if exists public_profiles;

alter table public.user_profiles
  drop column if exists avatar_seed,
  drop column if exists avatar_style,
  drop column if exists avatar_bg_color;

create view public_profiles as
  select
    p.id, p.username, p.image_url,
    p.mascot_type, p.mascot_mood,
    coalesce(
      s.plan <> 'free' and s.status in ('active', 'trialing', 'canceling'),
      false
    ) as is_pro
  from user_profiles p
  left join user_subscriptions s on s.user_id = p.id;

grant select on public_profiles to authenticated;

-- ── ROLLBACK ──────────────────────────────────────────────────────────────
-- alter table public.user_profiles
--   add column if not exists avatar_seed     text not null default '',
--   add column if not exists avatar_style    text not null default 'lorelei',
--   add column if not exists avatar_bg_color text not null default '#E0F2F1';
-- drop view if exists public_profiles;
-- alter table public.user_profiles drop column if exists image_url;
-- create view public_profiles as
--   select
--     p.id, p.username, p.avatar_seed, p.avatar_style, p.avatar_bg_color,
--     p.mascot_type, p.mascot_mood,
--     coalesce(
--       s.plan <> 'free' and s.status in ('active', 'trialing', 'canceling'),
--       false
--     ) as is_pro
--   from user_profiles p
--   left join user_subscriptions s on s.user_id = p.id;
-- grant select on public_profiles to authenticated;
