-- ══════════════════════════════════════════════════════════════════════════════
--  FITEVA — Schéma Supabase complet
--  Couvre : Auth · Onboarding · Profile · XP · Workout · Nutrition
--            Cycle · Grossesse · Post-partum · Community · Shop · Santé
-- ══════════════════════════════════════════════════════════════════════════════

-- ─────────────────────────────────────────────────────────────────────────────
-- EXTENSIONS
-- ─────────────────────────────────────────────────────────────────────────────
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ══════════════════════════════════════════════════════════════════════════════
-- SECTION 1 — ENUMS
-- ══════════════════════════════════════════════════════════════════════════════

CREATE TYPE activity_level    AS ENUM ('sedentary','light','moderate','active','veryActive');
CREATE TYPE nutrition_goal    AS ENUM ('loss','maintain','gain');
CREATE TYPE health_status     AS ENUM ('cycle','pregnant','postpartum');
CREATE TYPE cycle_phase       AS ENUM ('regles','folliculaire','ovulation','luteale');
CREATE TYPE meal_type         AS ENUM ('breakfast','lunch','snack','dinner');
CREATE TYPE food_category     AS ENUM (
  'viandes','poissons','oeufslaitiers','cereales','legumineuses',
  'legumes','fruits','oleagineux','corpsGras','platCompose','boissons','desserts'
);
CREATE TYPE program_category  AS ENUM ('home','salle','dance','recuperation','grossesse','zones');
CREATE TYPE day_status        AS ENUM ('rest','planned','done','today');
CREATE TYPE post_category     AS ENUM ('Challenge','Workout','Nutrition','Lifestyle','Other');
CREATE TYPE event_type        AS ENUM ('running','yoga','gym','cycling','swimming','other');
CREATE TYPE pp_recovery_type  AS ENUM ('recent','slowly','active');

-- ══════════════════════════════════════════════════════════════════════════════
-- SECTION 2 — PROFILS UTILISATEUR
-- ══════════════════════════════════════════════════════════════════════════════

-- ── 2.1  Profil principal (lié à auth.users de Supabase) ────────────────────
CREATE TABLE user_profiles (
  id               UUID         PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  username         TEXT         NOT NULL DEFAULT '',
  email            TEXT         NOT NULL DEFAULT '',
  avatar_seed      TEXT         NOT NULL DEFAULT '',
  avatar_style     TEXT         NOT NULL DEFAULT 'lorelei',
  avatar_bg_color  TEXT         NOT NULL DEFAULT '#E0F2F1',
  mascot_type      TEXT         NOT NULL DEFAULT 'default',
  mascot_mood      TEXT         NOT NULL DEFAULT 'happy',
  language         TEXT         NOT NULL DEFAULT 'fr',
  theme_mode       TEXT         NOT NULL DEFAULT 'system',      -- 'light' | 'dark' | 'system'
  onboarding_done  BOOLEAN      NOT NULL DEFAULT false,
  created_at       TIMESTAMPTZ  NOT NULL DEFAULT now(),
  updated_at       TIMESTAMPTZ  NOT NULL DEFAULT now()
);

-- ── 2.2  Données biométriques & fitness (collectées à l'onboarding) ─────────
CREATE TABLE user_biometrics (
  user_id           UUID         PRIMARY KEY REFERENCES user_profiles(id) ON DELETE CASCADE,
  height_cm         NUMERIC(5,1) CHECK (height_cm BETWEEN 100 AND 250),
  weight_kg         NUMERIC(5,1) CHECK (weight_kg BETWEEN 20 AND 300),
  age               INTEGER      CHECK (age BETWEEN 10 AND 120),
  is_female         BOOLEAN      NOT NULL DEFAULT true,
  fitness_level     TEXT         NOT NULL DEFAULT '',           -- 'Débutant' | 'Intermédiaire' | 'Avancé'
  activity_level    activity_level NOT NULL DEFAULT 'moderate',
  nutrition_goal    nutrition_goal NOT NULL DEFAULT 'maintain',
  training_location TEXT         NOT NULL DEFAULT '',           -- 'home' | 'gym' | 'both'
  frequency_days    INTEGER      NOT NULL DEFAULT 3 CHECK (frequency_days BETWEEN 1 AND 7),
  goals             TEXT[]       NOT NULL DEFAULT '{}',
  equipment         TEXT[]       NOT NULL DEFAULT '{}',
  updated_at        TIMESTAMPTZ  NOT NULL DEFAULT now()
);

-- ── 2.3  Objectifs nutritionnels calculés (TDEE) ────────────────────────────
CREATE TABLE user_nutrition_targets (
  user_id          UUID         PRIMARY KEY REFERENCES user_profiles(id) ON DELETE CASCADE,
  tdee_kcal        INTEGER      NOT NULL DEFAULT 2000 CHECK (tdee_kcal > 0),
  protein_g        INTEGER      NOT NULL DEFAULT 150,
  carbs_g          INTEGER      NOT NULL DEFAULT 200,
  fat_g            INTEGER      NOT NULL DEFAULT 65,
  water_ml         INTEGER      NOT NULL DEFAULT 2000,
  updated_at       TIMESTAMPTZ  NOT NULL DEFAULT now()
);

-- ══════════════════════════════════════════════════════════════════════════════
-- SECTION 3 — XP, NIVEAUX & GAMIFICATION
-- ══════════════════════════════════════════════════════════════════════════════

-- ── 3.1  Compte XP global ────────────────────────────────────────────────────
CREATE TABLE user_xp (
  user_id               UUID         PRIMARY KEY REFERENCES user_profiles(id) ON DELETE CASCADE,
  total_xp              INTEGER      NOT NULL DEFAULT 0 CHECK (total_xp >= 0),
  streak                INTEGER      NOT NULL DEFAULT 0 CHECK (streak >= 0),
  last_active_date      DATE,
  login_rewarded_today  BOOLEAN      NOT NULL DEFAULT false,
  badges                TEXT[]       NOT NULL DEFAULT '{}',
  completed_challenges  TEXT[]       NOT NULL DEFAULT '{}',
  updated_at            TIMESTAMPTZ  NOT NULL DEFAULT now()
);

-- ── 3.2  Définitions des challenges ─────────────────────────────────────────
CREATE TABLE xp_challenges (
  key          TEXT    PRIMARY KEY,
  title_fr     TEXT    NOT NULL,
  title_en     TEXT    NOT NULL,
  emoji        TEXT    NOT NULL DEFAULT '',
  target_days  INTEGER NOT NULL DEFAULT 7 CHECK (target_days > 0),
  xp_reward    INTEGER NOT NULL DEFAULT 0 CHECK (xp_reward >= 0)
);

-- ── 3.3  Progression utilisateur par challenge ───────────────────────────────
CREATE TABLE user_challenge_progress (
  user_id        UUID         NOT NULL REFERENCES user_profiles(id) ON DELETE CASCADE,
  challenge_key  TEXT         NOT NULL REFERENCES xp_challenges(key),
  progress       INTEGER      NOT NULL DEFAULT 0 CHECK (progress >= 0),
  completed      BOOLEAN      NOT NULL DEFAULT false,
  completed_at   TIMESTAMPTZ,
  PRIMARY KEY (user_id, challenge_key)
);

-- ── 3.4  Historique XP (pour graphiques / analytics) ────────────────────────
CREATE TABLE xp_history (
  id          UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id     UUID         NOT NULL REFERENCES user_profiles(id) ON DELETE CASCADE,
  amount      INTEGER      NOT NULL,
  reason      TEXT         NOT NULL DEFAULT '',   -- 'daily_login' | 'meal_logged' | etc.
  earned_at   TIMESTAMPTZ  NOT NULL DEFAULT now()
);

-- ══════════════════════════════════════════════════════════════════════════════
-- SECTION 4 — PROGRAMMES, WORKOUTS & VIDÉOS
-- ══════════════════════════════════════════════════════════════════════════════

-- ── 4.1  Programmes ──────────────────────────────────────────────────────────
CREATE TABLE programs (
  id                TEXT             PRIMARY KEY,
  name              TEXT             NOT NULL,
  duration          TEXT             NOT NULL DEFAULT '',
  phases            TEXT             NOT NULL DEFAULT '',
  sessions          TEXT             NOT NULL DEFAULT '',
  color             INTEGER          NOT NULL DEFAULT 0,
  image_url         TEXT             NOT NULL DEFAULT '',
  compatible_cycles TEXT[]           NOT NULL DEFAULT '{}',
  total_points      INTEGER          NOT NULL DEFAULT 0 CHECK (total_points >= 0),
  level             TEXT             NOT NULL DEFAULT '',
  equipment         TEXT[]           NOT NULL DEFAULT '{}',
  category          program_category NOT NULL DEFAULT 'home',
  description       TEXT             NOT NULL DEFAULT '',
  created_at        TIMESTAMPTZ      NOT NULL DEFAULT now()
);

-- ── 4.2  Workouts ─────────────────────────────────────────────────────────────
CREATE TABLE workouts (
  id          TEXT        PRIMARY KEY,
  program_id  TEXT        REFERENCES programs(id) ON DELETE SET NULL,
  title       TEXT        NOT NULL,
  category    TEXT        NOT NULL DEFAULT '',
  duration    TEXT        NOT NULL DEFAULT '',
  level       TEXT        NOT NULL DEFAULT '',
  image_url   TEXT        NOT NULL DEFAULT '',
  calories    TEXT        NOT NULL DEFAULT '0',
  exercises   TEXT[]      NOT NULL DEFAULT '{}',
  phases      TEXT        NOT NULL DEFAULT '',
  points      INTEGER     NOT NULL DEFAULT 0 CHECK (points >= 0),
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ── 4.3  Vidéos d'exercices ──────────────────────────────────────────────────
CREATE TABLE videos (
  id             TEXT        PRIMARY KEY,
  workout_id     TEXT        NOT NULL REFERENCES workouts(id) ON DELETE CASCADE,
  title          TEXT        NOT NULL,
  duration       TEXT        NOT NULL DEFAULT '',
  points         INTEGER     NOT NULL DEFAULT 0 CHECK (points >= 0),
  thumbnail_url  TEXT        NOT NULL DEFAULT '',
  url            TEXT        NOT NULL DEFAULT '', 
  sort_order     INTEGER     NOT NULL DEFAULT 0,
  created_at     TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE videos
ADD COLUMN category TEXT NOT NULL DEFAULT 'dance';
ALTER TABLE videos
ALTER COLUMN workout_id DROP NOT NULL;
ALTER TABLE videos
ADD COLUMN phases TEXT NOT NULL DEFAULT '';


-- ── 4.4  Progression workout utilisateur ────────────────────────────────────
CREATE TABLE user_video_completions (
  user_id     UUID         NOT NULL REFERENCES user_profiles(id) ON DELETE CASCADE,
  video_id    TEXT         NOT NULL REFERENCES videos(id) ON DELETE CASCADE,
  progress    NUMERIC(4,3) NOT NULL DEFAULT 0 CHECK (progress BETWEEN 0 AND 1),
  completed   BOOLEAN      NOT NULL DEFAULT false,
  completed_at TIMESTAMPTZ,
  PRIMARY KEY (user_id, video_id)
);

CREATE TABLE user_workout_completions (
  user_id      UUID         NOT NULL REFERENCES user_profiles(id) ON DELETE CASCADE,
  workout_id   TEXT         NOT NULL REFERENCES workouts(id) ON DELETE CASCADE,
  completed_at TIMESTAMPTZ  NOT NULL DEFAULT now(),
  PRIMARY KEY (user_id, workout_id)
);

CREATE TABLE user_program_completions (
  user_id      UUID         NOT NULL REFERENCES user_profiles(id) ON DELETE CASCADE,
  program_id   TEXT         NOT NULL REFERENCES programs(id) ON DELETE CASCADE,
  completed_at TIMESTAMPTZ  NOT NULL DEFAULT now(),
  PRIMARY KEY (user_id, program_id)
);

-- ── 4.5  Programmes rejoints ─────────────────────────────────────────────────
CREATE TABLE user_joined_programs (
  user_id     UUID         NOT NULL REFERENCES user_profiles(id) ON DELETE CASCADE,
  program_id  TEXT         NOT NULL REFERENCES programs(id) ON DELETE CASCADE,
  joined_at   TIMESTAMPTZ  NOT NULL DEFAULT now(),
  PRIMARY KEY (user_id, program_id)
);

-- ── 4.6  Workouts & programmes favoris ──────────────────────────────────────
CREATE TABLE user_workout_favorites (
  user_id     UUID   NOT NULL REFERENCES user_profiles(id) ON DELETE CASCADE,
  workout_id  TEXT   NOT NULL REFERENCES workouts(id) ON DELETE CASCADE,
  PRIMARY KEY (user_id, workout_id)
);

CREATE TABLE user_program_favorites (
  user_id     UUID   NOT NULL REFERENCES user_profiles(id) ON DELETE CASCADE,
  program_id  TEXT   NOT NULL REFERENCES programs(id) ON DELETE CASCADE,
  PRIMARY KEY (user_id, program_id)
);

-- Favoris pour les vidéos autonomes (workout_id NULL — cartes Dance/Cardio/Récupération)
CREATE TABLE user_video_favorites (
  user_id     UUID   NOT NULL REFERENCES user_profiles(id) ON DELETE CASCADE,
  video_id    TEXT   NOT NULL REFERENCES videos(id) ON DELETE CASCADE,
  PRIMARY KEY (user_id, video_id)
);
ALTER TABLE user_video_favorites ENABLE ROW LEVEL SECURITY;
CREATE POLICY "own_user_video_favorites" ON user_video_favorites FOR ALL
  USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

-- ── 4.7  Plan hebdomadaire ───────────────────────────────────────────────────
CREATE TABLE weekly_plan (
  user_id      UUID         NOT NULL REFERENCES user_profiles(id) ON DELETE CASCADE,
  plan_date    DATE         NOT NULL,
  workout_id   TEXT         REFERENCES workouts(id) ON DELETE SET NULL,
  day_label    TEXT         NOT NULL DEFAULT '',
  status       day_status   NOT NULL DEFAULT 'planned',
  updated_at   TIMESTAMPTZ  NOT NULL DEFAULT now(),
  PRIMARY KEY (user_id, plan_date)
);

-- ── 4.7b Plan hebdomadaire éditable (accueil + écran "Ma semaine") ──────────
-- Table réellement utilisée par WeeklyPlanNotifier (lib/providers/weekly_plan_provider.dart) :
-- une ligne par jour de la semaine en cours, indexée par weekday_index (0=lundi..6=dimanche).
CREATE TABLE user_weekly_plans (
  user_id        UUID     NOT NULL REFERENCES user_profiles(id) ON DELETE CASCADE,
  week_start     DATE     NOT NULL,
  weekday_index  INTEGER  NOT NULL CHECK (weekday_index BETWEEN 0 AND 6),
  category_id    TEXT,
  status         TEXT     NOT NULL DEFAULT 'empty', -- 'empty' | 'rest' | 'planned' | 'done'
  workout_id     TEXT,
  PRIMARY KEY (user_id, week_start, weekday_index)
);

-- ══════════════════════════════════════════════════════════════════════════════
-- SECTION 5 — NUTRITION
-- ══════════════════════════════════════════════════════════════════════════════

-- ── 5.1  Base alimentaire (référence immuable) ───────────────────────────────
CREATE TABLE food_items (
  id             TEXT          PRIMARY KEY,
  name           TEXT          NOT NULL,
  category       food_category NOT NULL,
  kcal           INTEGER       NOT NULL DEFAULT 0 CHECK (kcal >= 0),
  protein        NUMERIC(7,2)  NOT NULL DEFAULT 0,
  carbs          NUMERIC(7,2)  NOT NULL DEFAULT 0,
  fat            NUMERIC(7,2)  NOT NULL DEFAULT 0,
  fiber          NUMERIC(7,2)  NOT NULL DEFAULT 0,
  default_grams  INTEGER       NOT NULL DEFAULT 100 CHECK (default_grams > 0),
  portion_label  TEXT          NOT NULL DEFAULT ''
);

-- ── 5.2  Repas enregistrés (journal) ────────────────────────────────────────
CREATE TABLE meal_entries (
  id            UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id       UUID         NOT NULL REFERENCES user_profiles(id) ON DELETE CASCADE,
  food_item_id  TEXT         REFERENCES food_items(id) ON DELETE SET NULL,
  meal_type     meal_type    NOT NULL DEFAULT 'breakfast',
  log_date      DATE         NOT NULL DEFAULT CURRENT_DATE,
  name          TEXT         NOT NULL DEFAULT '',   -- nom custom si pas dans food_items
  grams         NUMERIC(7,2) NOT NULL DEFAULT 100 CHECK (grams > 0),
  kcal          INTEGER      NOT NULL DEFAULT 0,
  protein       NUMERIC(7,2) NOT NULL DEFAULT 0,
  carbs         NUMERIC(7,2) NOT NULL DEFAULT 0,
  fat           NUMERIC(7,2) NOT NULL DEFAULT 0,
  fiber         NUMERIC(7,2) NOT NULL DEFAULT 0,
  created_at    TIMESTAMPTZ  NOT NULL DEFAULT now()
);

-- ── 5.3  Suivi hydratation ────────────────────────────────────────────────────
CREATE TABLE water_tracking (
  user_id    UUID    NOT NULL REFERENCES user_profiles(id) ON DELETE CASCADE,
  log_date   DATE    NOT NULL DEFAULT CURRENT_DATE,
  water_ml   INTEGER NOT NULL DEFAULT 0 CHECK (water_ml >= 0),
  PRIMARY KEY (user_id, log_date)
);

-- ── 5.4  Budgets repas par type (configurable par l'utilisateur) ─────────────
CREATE TABLE meal_budgets (
  user_id           UUID          NOT NULL REFERENCES user_profiles(id) ON DELETE CASCADE,
  meal_type         meal_type     NOT NULL,
  budget_calories   INTEGER       NOT NULL DEFAULT 0 CHECK (budget_calories >= 0),
  budget_protein_g  NUMERIC(7,2)  NOT NULL DEFAULT 0,
  PRIMARY KEY (user_id, meal_type)
);

-- ── 5.5  Recettes favorites (nutrition) ─────────────────────────────────────
CREATE TABLE nutrition_recipe_favorites (
  user_id      UUID   NOT NULL REFERENCES user_profiles(id) ON DELETE CASCADE,
  recipe_name  TEXT   NOT NULL,
  PRIMARY KEY (user_id, recipe_name)
);

-- ══════════════════════════════════════════════════════════════════════════════
-- SECTION 6 — CYCLE MENSTRUEL & SANTÉ REPRODUCTIVE
-- ══════════════════════════════════════════════════════════════════════════════

-- ── 6.1  Paramètres cycle ────────────────────────────────────────────────────
CREATE TABLE user_cycle_settings (
  user_id           UUID    PRIMARY KEY REFERENCES user_profiles(id) ON DELETE CASCADE,
  health_status     health_status NOT NULL DEFAULT 'cycle',
  cycle_duration    INTEGER NOT NULL DEFAULT 28 CHECK (cycle_duration BETWEEN 21 AND 45),
  last_period_date  DATE,
  updated_at        TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ── 6.2  Historique règles ────────────────────────────────────────────────────
CREATE TABLE period_history (
  id           UUID  PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id      UUID  NOT NULL REFERENCES user_profiles(id) ON DELETE CASCADE,
  start_date   DATE  NOT NULL,
  end_date     DATE,
  notes        TEXT  DEFAULT ''
);

-- ── 6.3  Symptômes journaliers ────────────────────────────────────────────────
CREATE TABLE daily_symptoms (
  id          UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id     UUID         NOT NULL REFERENCES user_profiles(id) ON DELETE CASCADE,
  log_date    DATE         NOT NULL DEFAULT CURRENT_DATE,
  symptom     TEXT         NOT NULL,   -- 'flow' | 'mood' | 'energy' | 'cramps' | custom
  intensity   INTEGER      DEFAULT 3 CHECK (intensity BETWEEN 1 AND 5),
  notes       TEXT         DEFAULT '',
  created_at  TIMESTAMPTZ  NOT NULL DEFAULT now()
);

-- ── 6.4  Humeur & énergie journalière ───────────────────────────────────────
CREATE TABLE daily_moods (
  user_id    UUID     NOT NULL REFERENCES user_profiles(id) ON DELETE CASCADE,
  log_date   DATE     NOT NULL DEFAULT CURRENT_DATE,
  mood       INTEGER  CHECK (mood BETWEEN 1 AND 5),
  energy     INTEGER  CHECK (energy BETWEEN 1 AND 5),
  notes      TEXT     DEFAULT '',
  PRIMARY KEY (user_id, log_date)
);

-- ══════════════════════════════════════════════════════════════════════════════
-- SECTION 7 — GROSSESSE
-- ══════════════════════════════════════════════════════════════════════════════

-- ── 7.1  Paramètres grossesse ────────────────────────────────────────────────
CREATE TABLE user_pregnancy (
  user_id            UUID         PRIMARY KEY REFERENCES user_profiles(id) ON DELETE CASCADE,
  is_pregnant        BOOLEAN      NOT NULL DEFAULT false,
  pregnancy_week_sa  INTEGER      CHECK (pregnancy_week_sa BETWEEN 1 AND 42),
  due_date           DATE,
  updated_at         TIMESTAMPTZ  NOT NULL DEFAULT now()
);

-- ── 7.2  Checklist de grossesse ──────────────────────────────────────────────
CREATE TABLE pregnancy_checklist_items (
  id          UUID     PRIMARY KEY DEFAULT gen_random_uuid(),
  trimester   INTEGER  NOT NULL CHECK (trimester BETWEEN 1 AND 3),
  title       TEXT     NOT NULL,
  description TEXT     NOT NULL DEFAULT '',
  sort_order  INTEGER  NOT NULL DEFAULT 0
);

CREATE TABLE user_pregnancy_checklist (
  user_id   UUID    NOT NULL REFERENCES user_profiles(id) ON DELETE CASCADE,
  item_id   UUID    NOT NULL REFERENCES pregnancy_checklist_items(id) ON DELETE CASCADE,
  done      BOOLEAN NOT NULL DEFAULT false,
  done_at   TIMESTAMPTZ,
  PRIMARY KEY (user_id, item_id)
);

-- ── 7.3  Humeur grossesse par semaine ───────────────────────────────────────
CREATE TABLE pregnancy_moods (
  user_id     UUID    NOT NULL REFERENCES user_profiles(id) ON DELETE CASCADE,
  week_sa     INTEGER NOT NULL CHECK (week_sa BETWEEN 1 AND 42),
  mood        INTEGER CHECK (mood BETWEEN 1 AND 5),
  noted_at    DATE    NOT NULL DEFAULT CURRENT_DATE,
  PRIMARY KEY (user_id, week_sa)
);

-- ── 7.4  Symptômes grossesse ─────────────────────────────────────────────────
CREATE TABLE pregnancy_symptoms (
  id           UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id      UUID         NOT NULL REFERENCES user_profiles(id) ON DELETE CASCADE,
  week_sa      INTEGER      NOT NULL CHECK (week_sa BETWEEN 1 AND 42),
  symptom      TEXT         NOT NULL,
  intensity    INTEGER      DEFAULT 3 CHECK (intensity BETWEEN 1 AND 5),
  notes        TEXT         DEFAULT '',
  logged_at    TIMESTAMPTZ  NOT NULL DEFAULT now()
);

-- ══════════════════════════════════════════════════════════════════════════════
-- SECTION 8 — POST-PARTUM
-- ══════════════════════════════════════════════════════════════════════════════

CREATE TABLE user_postpartum (
  user_id       UUID              PRIMARY KEY REFERENCES user_profiles(id) ON DELETE CASCADE,
  recovery_type pp_recovery_type  NOT NULL DEFAULT 'recent',
  pp_duration   TEXT              NOT NULL DEFAULT '0-2',   -- '0-2' | '2-6' | '6-12' | '3-6m' | '6m+'
  birth_date    DATE,
  notes         TEXT              DEFAULT '',
  updated_at    TIMESTAMPTZ       NOT NULL DEFAULT now()
);

-- ══════════════════════════════════════════════════════════════════════════════
-- SECTION 9 — COMMUNAUTÉ
-- ══════════════════════════════════════════════════════════════════════════════

-- ── 9.1  Posts ────────────────────────────────────────────────────────────────
CREATE TABLE posts (
  id              UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id         UUID         NOT NULL REFERENCES user_profiles(id) ON DELETE CASCADE,
  content         TEXT         NOT NULL DEFAULT '',
  image_url       TEXT         NOT NULL DEFAULT '',
  category        post_category NOT NULL DEFAULT 'Other',
  likes_count     INTEGER      NOT NULL DEFAULT 0 CHECK (likes_count >= 0),
  comments_count  INTEGER      NOT NULL DEFAULT 0 CHECK (comments_count >= 0),
  created_at      TIMESTAMPTZ  NOT NULL DEFAULT now(),
  updated_at      TIMESTAMPTZ  NOT NULL DEFAULT now()
);

-- ── 9.2  Likes ────────────────────────────────────────────────────────────────
CREATE TABLE post_likes (
  user_id     UUID         NOT NULL REFERENCES user_profiles(id) ON DELETE CASCADE,
  post_id     UUID         NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
  created_at  TIMESTAMPTZ  NOT NULL DEFAULT now(),
  PRIMARY KEY (user_id, post_id)
);

-- ── 9.3  Commentaires ─────────────────────────────────────────────────────────
CREATE TABLE post_comments (
  id          UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
  post_id     UUID         NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
  user_id     UUID         NOT NULL REFERENCES user_profiles(id) ON DELETE CASCADE,
  content     TEXT         NOT NULL,
  created_at  TIMESTAMPTZ  NOT NULL DEFAULT now()
);

-- ── 9.4  Événements communautaires ───────────────────────────────────────────
CREATE TABLE community_events (
  id                  UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
  organizer_id        UUID         NOT NULL REFERENCES user_profiles(id) ON DELETE CASCADE,
  title               TEXT         NOT NULL,
  event_type          event_type   NOT NULL DEFAULT 'other',
  event_date          DATE         NOT NULL,
  event_time          TEXT         NOT NULL DEFAULT '',
  location            TEXT         NOT NULL DEFAULT '',
  max_spots           INTEGER      NOT NULL DEFAULT 10 CHECK (max_spots > 0),
  joined_count        INTEGER      NOT NULL DEFAULT 0 CHECK (joined_count >= 0),
  image_url           TEXT         NOT NULL DEFAULT '',
  description         TEXT         NOT NULL DEFAULT '',
  created_at          TIMESTAMPTZ  NOT NULL DEFAULT now()
);

-- Liens sociaux de l'organisateur (comme training_partners) pour que les
-- participantes puissent communiquer.
ALTER TABLE community_events
  ADD COLUMN contact_whatsapp  TEXT NOT NULL DEFAULT '',
  ADD COLUMN contact_instagram TEXT NOT NULL DEFAULT '',
  ADD COLUMN contact_facebook  TEXT NOT NULL DEFAULT '';

-- ── 9.5  Participants aux événements ─────────────────────────────────────────
CREATE TABLE event_participants (
  user_id    UUID         NOT NULL REFERENCES user_profiles(id) ON DELETE CASCADE,
  event_id   UUID         NOT NULL REFERENCES community_events(id) ON DELETE CASCADE,
  joined_at  TIMESTAMPTZ  NOT NULL DEFAULT now(),
  PRIMARY KEY (user_id, event_id)
);

-- ── 9.5b  Stockage — images de couverture des événements ────────────────────
-- Bucket public : les photos de couverture sont visibles par tous dans le
-- feed communauté, mais seul l'organisateur peut écrire dans son propre
-- dossier (chemin '{uid}/xxx.jpg').
INSERT INTO storage.buckets (id, name, public)
VALUES ('event-images', 'event-images', true)
ON CONFLICT (id) DO NOTHING;

CREATE POLICY "event_images_public_read" ON storage.objects FOR SELECT
  USING (bucket_id = 'event-images');
CREATE POLICY "event_images_owner_insert" ON storage.objects FOR INSERT
  WITH CHECK (bucket_id = 'event-images' AND (storage.foldername(name))[1] = auth.uid()::text);
CREATE POLICY "event_images_owner_update" ON storage.objects FOR UPDATE
  USING (bucket_id = 'event-images' AND (storage.foldername(name))[1] = auth.uid()::text);
CREATE POLICY "event_images_owner_delete" ON storage.objects FOR DELETE
  USING (bucket_id = 'event-images' AND (storage.foldername(name))[1] = auth.uid()::text);

-- ── 9.6  Partenaires d'entraînement ─────────────────────────────────────────
CREATE TABLE training_partners (
  id           UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id      UUID         NOT NULL REFERENCES user_profiles(id) ON DELETE CASCADE,
  name         TEXT         NOT NULL DEFAULT '',
  avatar_url   TEXT         NOT NULL DEFAULT '',
  goal         TEXT         NOT NULL DEFAULT '',
  level        TEXT         NOT NULL DEFAULT '',
  region       TEXT         NOT NULL DEFAULT '',
  frequency    TEXT         NOT NULL DEFAULT '',
  description  TEXT         NOT NULL DEFAULT '',
  tags         TEXT[]       NOT NULL DEFAULT '{}',
  created_at   TIMESTAMPTZ  NOT NULL DEFAULT now()
);

-- ── 9.7  Demandes de partenariat (match) ────────────────────────────────────
CREATE TABLE partner_requests (
  id           UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
  from_user_id UUID         NOT NULL REFERENCES user_profiles(id) ON DELETE CASCADE,
  to_user_id   UUID         NOT NULL REFERENCES user_profiles(id) ON DELETE CASCADE,
  status       TEXT         NOT NULL DEFAULT 'pending' CHECK (status IN ('pending','accepted','declined')),
  created_at   TIMESTAMPTZ  NOT NULL DEFAULT now(),
  UNIQUE (from_user_id, to_user_id)
);

-- ── 9.8  Followers ───────────────────────────────────────────────────────────
CREATE TABLE user_follows (
  follower_id  UUID         NOT NULL REFERENCES user_profiles(id) ON DELETE CASCADE,
  following_id UUID         NOT NULL REFERENCES user_profiles(id) ON DELETE CASCADE,
  created_at   TIMESTAMPTZ  NOT NULL DEFAULT now(),
  PRIMARY KEY (follower_id, following_id),
  CHECK (follower_id <> following_id)
);

-- ══════════════════════════════════════════════════════════════════════════════
-- SECTION 10 — SHOP / BOUTIQUE
-- ══════════════════════════════════════════════════════════════════════════════

-- ── 10.1  Catalogue produits ─────────────────────────────────────────────────
CREATE TABLE shop_items (
  id               TEXT         PRIMARY KEY,
  brand            TEXT         NOT NULL,
  title            TEXT         NOT NULL,
  description      TEXT         NOT NULL DEFAULT '',
  category         TEXT         NOT NULL DEFAULT '',
  discount         TEXT         NOT NULL DEFAULT '',         -- '20%' | '2 semaines gratuites'
  discount_value   NUMERIC(6,2) NOT NULL DEFAULT 0,
  etoiles_cost     INTEGER      NOT NULL DEFAULT 0 CHECK (etoiles_cost >= 0),  -- points requis
  days_left        INTEGER      CHECK (days_left >= 0),
  primary_color    INTEGER      NOT NULL DEFAULT 0,
  secondary_color  INTEGER      NOT NULL DEFAULT 0,
  image_url        TEXT         NOT NULL DEFAULT '',
  promo_code       TEXT         NOT NULL DEFAULT '',
  site_url         TEXT         NOT NULL DEFAULT '',
  valid_until      DATE,
  is_active        BOOLEAN      NOT NULL DEFAULT true,
  created_at       TIMESTAMPTZ  NOT NULL DEFAULT now()
);

-- ── 10.2  Wishlist (favoris boutique) ────────────────────────────────────────
CREATE TABLE shop_wishlist (
  user_id      UUID   NOT NULL REFERENCES user_profiles(id) ON DELETE CASCADE,
  shop_item_id TEXT   NOT NULL REFERENCES shop_items(id) ON DELETE CASCADE,
  added_at     TIMESTAMPTZ NOT NULL DEFAULT now(),
  PRIMARY KEY (user_id, shop_item_id)
);


create table partner_join_requests (
  id            uuid primary key default gen_random_uuid(),
  partner_id    uuid not null references training_partners(id) on delete cascade,
  requester_id  uuid not null references auth.users(id),
  owner_id      uuid not null,              -- denormalized training_partners.user_id, for RLS
  status        text not null default 'pending' check (status in ('pending','accepted','declined')),
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now(),
  unique (partner_id, requester_id)          -- can't send two requests to the same partner post
);


alter table training_partners
  add column contact_whatsapp  text,
  add column contact_instagram text,
  add column contact_facebook  text;


-- ── 10.3  Échanges/Redemptions ────────────────────────────────────────────────
CREATE TABLE shop_redemptions (
  id            UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id       UUID         NOT NULL REFERENCES user_profiles(id) ON DELETE CASCADE,
  shop_item_id  TEXT         NOT NULL REFERENCES shop_items(id) ON DELETE CASCADE,
  points_spent  INTEGER      NOT NULL CHECK (points_spent >= 0),
  promo_code    TEXT         NOT NULL DEFAULT '',
  redeemed_at   TIMESTAMPTZ  NOT NULL DEFAULT now(),
  UNIQUE (user_id, shop_item_id)    -- un seul échange par item par user
);

-- ── 10.4  Portefeuille étoiles (points) ──────────────────────────────────────
CREATE TABLE user_points (
  user_id      UUID    PRIMARY KEY REFERENCES user_profiles(id) ON DELETE CASCADE,
  etoiles      INTEGER NOT NULL DEFAULT 0 CHECK (etoiles >= 0),
  updated_at   TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ── 10.5  Historique points ───────────────────────────────────────────────────
CREATE TABLE points_history (
  id          UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id     UUID         NOT NULL REFERENCES user_profiles(id) ON DELETE CASCADE,
  amount      INTEGER      NOT NULL,                         -- positif = gain, négatif = dépense
  reason      TEXT         NOT NULL DEFAULT '',
  earned_at   TIMESTAMPTZ  NOT NULL DEFAULT now()
);

-- ══════════════════════════════════════════════════════════════════════════════
-- SECTION 11 — SANTÉ (MÉDECINS, ARTICLES, LEXIQUE)
-- ══════════════════════════════════════════════════════════════════════════════

-- ── 11.1  Médecins / experts ─────────────────────────────────────────────────
CREATE TABLE doctors (
  id            UUID    PRIMARY KEY DEFAULT gen_random_uuid(),
  name          TEXT    NOT NULL,
  specialty     TEXT    NOT NULL DEFAULT '',
  location      TEXT    NOT NULL DEFAULT '',
  hospital      TEXT    NOT NULL DEFAULT '',
  phone         TEXT    NOT NULL DEFAULT '',
  email         TEXT    NOT NULL DEFAULT '',
  initials      TEXT    NOT NULL DEFAULT '',
  photo_url     TEXT    NOT NULL DEFAULT '',
  color         INTEGER NOT NULL DEFAULT 0,
  rating        NUMERIC(3,2) DEFAULT 0 CHECK (rating BETWEEN 0 AND 5),
  consultations INTEGER NOT NULL DEFAULT 0 CHECK (consultations >= 0),
  is_active     BOOLEAN NOT NULL DEFAULT true
);

-- ── 11.2  Conseils santé ─────────────────────────────────────────────────────
CREATE TABLE health_articles (
  id          UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
  doctor_id   UUID         REFERENCES doctors(id) ON DELETE SET NULL,
  title       TEXT         NOT NULL,
  body        TEXT         NOT NULL DEFAULT '',
  excerpt     TEXT         NOT NULL DEFAULT '',
  category    TEXT         NOT NULL DEFAULT '',
  read_min    INTEGER      NOT NULL DEFAULT 5 CHECK (read_min > 0),
  likes       INTEGER      NOT NULL DEFAULT 0 CHECK (likes >= 0),
  photo_url   TEXT         NOT NULL DEFAULT '',
  color       INTEGER      NOT NULL DEFAULT 0,
  published_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ── 11.3  Articles lus par l'utilisateur ────────────────────────────────────
CREATE TABLE user_read_articles (
  user_id     UUID   NOT NULL REFERENCES user_profiles(id) ON DELETE CASCADE,
  article_id  UUID   NOT NULL REFERENCES health_articles(id) ON DELETE CASCADE,
  read_at     TIMESTAMPTZ NOT NULL DEFAULT now(),
  PRIMARY KEY (user_id, article_id)
);

-- ── 11.4  Questions / Q&A santé ──────────────────────────────────────────────
CREATE TABLE health_questions (
  id             UUID    PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id        UUID    REFERENCES user_profiles(id) ON DELETE SET NULL,
  question       TEXT    NOT NULL,
  doctor_answer  TEXT    NOT NULL DEFAULT '',
  doctor_id      UUID    REFERENCES doctors(id) ON DELETE SET NULL,
  votes          INTEGER NOT NULL DEFAULT 0 CHECK (votes >= 0),
  posted_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ── 11.5  Lexique médical ─────────────────────────────────────────────────────
CREATE TABLE medical_lexique (
  id          UUID  PRIMARY KEY DEFAULT gen_random_uuid(),
  term        TEXT  NOT NULL,
  definition  TEXT  NOT NULL,
  category    TEXT  NOT NULL DEFAULT ''
);

-- ══════════════════════════════════════════════════════════════════════════════
-- SECTION 12 — TRIGGERS
-- ══════════════════════════════════════════════════════════════════════════════

CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN NEW.updated_at = now(); RETURN NEW; END;
$$;

CREATE TRIGGER trg_user_profiles_upd     BEFORE UPDATE ON user_profiles       FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TRIGGER trg_user_biometrics_upd   BEFORE UPDATE ON user_biometrics      FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TRIGGER trg_nutrition_targets_upd BEFORE UPDATE ON user_nutrition_targets FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TRIGGER trg_user_xp_upd           BEFORE UPDATE ON user_xp             FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TRIGGER trg_posts_upd             BEFORE UPDATE ON posts                FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TRIGGER trg_pregnancy_upd         BEFORE UPDATE ON user_pregnancy       FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TRIGGER trg_postpartum_upd        BEFORE UPDATE ON user_postpartum      FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TRIGGER trg_user_points_upd       BEFORE UPDATE ON user_points          FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TRIGGER trg_cycle_settings_upd    BEFORE UPDATE ON user_cycle_settings  FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TRIGGER trg_join_requests_upd     BEFORE UPDATE ON partner_join_requests FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- Auto-incrémenter likes_count sur posts
CREATE OR REPLACE FUNCTION fn_sync_post_likes_count()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    UPDATE posts SET likes_count = likes_count + 1 WHERE id = NEW.post_id;
  ELSIF TG_OP = 'DELETE' THEN
    UPDATE posts SET likes_count = GREATEST(likes_count - 1, 0) WHERE id = OLD.post_id;
  END IF;
  RETURN NULL;
END;
$$;
CREATE TRIGGER trg_post_likes_count
  AFTER INSERT OR DELETE ON post_likes
  FOR EACH ROW EXECUTE FUNCTION fn_sync_post_likes_count();

-- Auto-incrémenter comments_count
CREATE OR REPLACE FUNCTION fn_sync_post_comments_count()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    UPDATE posts SET comments_count = comments_count + 1 WHERE id = NEW.post_id;
  ELSIF TG_OP = 'DELETE' THEN
    UPDATE posts SET comments_count = GREATEST(comments_count - 1, 0) WHERE id = OLD.post_id;
  END IF;
  RETURN NULL;
END;
$$;
CREATE TRIGGER trg_post_comments_count
  AFTER INSERT OR DELETE ON post_comments
  FOR EACH ROW EXECUTE FUNCTION fn_sync_post_comments_count();

-- Auto-incrémenter joined_count sur events
CREATE OR REPLACE FUNCTION fn_sync_event_joined_count()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    UPDATE community_events SET joined_count = joined_count + 1 WHERE id = NEW.event_id;
  ELSIF TG_OP = 'DELETE' THEN
    UPDATE community_events SET joined_count = GREATEST(joined_count - 1, 0) WHERE id = OLD.event_id;
  END IF;
  RETURN NULL;
END;
$$;
CREATE TRIGGER trg_event_joined_count
  AFTER INSERT OR DELETE ON event_participants
  FOR EACH ROW EXECUTE FUNCTION fn_sync_event_joined_count();

-- Créer automatiquement le profil après signup Supabase Auth
CREATE OR REPLACE FUNCTION fn_create_user_profile()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  INSERT INTO user_profiles (id, email)
  VALUES (NEW.id, NEW.email)
  ON CONFLICT DO NOTHING;
  INSERT INTO user_xp     (user_id) VALUES (NEW.id) ON CONFLICT DO NOTHING;
  INSERT INTO user_points (user_id) VALUES (NEW.id) ON CONFLICT DO NOTHING;
  RETURN NEW;
END;
$$;
CREATE TRIGGER trg_on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION fn_create_user_profile();

-- ══════════════════════════════════════════════════════════════════════════════
-- SECTION 13 — ROW LEVEL SECURITY (RLS)
-- ══════════════════════════════════════════════════════════════════════════════

-- Tables privées (chaque user voit seulement ses données)
ALTER TABLE user_profiles              ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_biometrics            ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_nutrition_targets     ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_xp                    ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_challenge_progress    ENABLE ROW LEVEL SECURITY;
ALTER TABLE xp_history                 ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_video_completions     ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_workout_completions   ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_program_completions   ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_joined_programs       ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_workout_favorites     ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_program_favorites     ENABLE ROW LEVEL SECURITY;
-- user_video_favorites : RLS + policy déclarées juste après sa CREATE TABLE (section 4.6)
ALTER TABLE weekly_plan                ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_weekly_plans          ENABLE ROW LEVEL SECURITY;
ALTER TABLE meal_entries               ENABLE ROW LEVEL SECURITY;
ALTER TABLE water_tracking             ENABLE ROW LEVEL SECURITY;
ALTER TABLE meal_budgets               ENABLE ROW LEVEL SECURITY;
ALTER TABLE nutrition_recipe_favorites ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_cycle_settings        ENABLE ROW LEVEL SECURITY;
ALTER TABLE period_history             ENABLE ROW LEVEL SECURITY;
ALTER TABLE daily_symptoms             ENABLE ROW LEVEL SECURITY;
ALTER TABLE daily_moods                ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_pregnancy             ENABLE ROW LEVEL SECURITY;
ALTER TABLE pregnancy_moods            ENABLE ROW LEVEL SECURITY;
ALTER TABLE pregnancy_symptoms         ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_pregnancy_checklist   ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_postpartum            ENABLE ROW LEVEL SECURITY;
ALTER TABLE shop_wishlist              ENABLE ROW LEVEL SECURITY;
ALTER TABLE shop_redemptions           ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_points                ENABLE ROW LEVEL SECURITY;
ALTER TABLE points_history             ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_read_articles         ENABLE ROW LEVEL SECURITY;
ALTER TABLE partner_requests           ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_follows               ENABLE ROW LEVEL SECURITY;

-- user_profiles utilise 'id' (pas 'user_id') comme clé référençant auth.users.
-- Contient l'email (sensible) à côté de username/mascotte (publics pour le
-- feed communautaire) : la lecture directe de la table est donc réservée au
-- propriétaire, et une vue dédiée (public_profiles, ci-dessous) expose
-- uniquement les colonnes sûres pour les autres utilisatrices.
CREATE POLICY "own_user_profiles" ON user_profiles FOR ALL
  USING (auth.uid() = id) WITH CHECK (auth.uid() = id);

-- Vue publique : seules les colonnes safe pour affichage communautaire.
-- Vue "security definer" implicite (propriétaire = postgres) : elle peut lire
-- toutes les lignes de user_profiles même si RLS restreint la table de base
-- à "own row only" pour l'appelant — mais elle ne renvoie jamais l'email.
CREATE OR REPLACE VIEW public_profiles AS
  SELECT id, username, avatar_seed, avatar_style, avatar_bg_color,
         mascot_type, mascot_mood
  FROM user_profiles;

GRANT SELECT ON public_profiles TO authenticated;

-- Policies génériques (user_id = auth.uid())
DO $$
DECLARE tbl TEXT;
BEGIN
  FOR tbl IN SELECT unnest(ARRAY[
    'user_biometrics','user_nutrition_targets','user_xp',
    'user_challenge_progress','xp_history',
    'user_video_completions','user_workout_completions','user_program_completions',
    'user_joined_programs','user_workout_favorites','user_program_favorites',
    'weekly_plan','user_weekly_plans','meal_entries','water_tracking','meal_budgets',
    'nutrition_recipe_favorites','user_cycle_settings','period_history',
    'daily_symptoms','daily_moods','user_pregnancy','pregnancy_moods',
    'pregnancy_symptoms','user_pregnancy_checklist','user_postpartum',
    'shop_wishlist','shop_redemptions','user_points','points_history',
    'user_read_articles'
  ]) LOOP
    EXECUTE format(
      'CREATE POLICY "own_%s" ON %I FOR ALL USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id)',
      tbl, tbl
    );
  END LOOP;
END;
$$;

-- Lecture publique des points/XP : le profil communauté affiche les étoiles
-- et le niveau des autres utilisatrices (écriture toujours réservée via own_*).
CREATE POLICY "user_points_public_read" ON user_points FOR SELECT USING (true);
CREATE POLICY "user_xp_public_read"     ON user_xp     FOR SELECT USING (true);

-- Partner requests : les deux parties concernées peuvent voir
CREATE POLICY "partner_requests_read" ON partner_requests FOR SELECT
  USING (auth.uid() = from_user_id OR auth.uid() = to_user_id);
CREATE POLICY "partner_requests_insert" ON partner_requests FOR INSERT
  WITH CHECK (auth.uid() = from_user_id);
CREATE POLICY "partner_requests_update" ON partner_requests FOR UPDATE
  USING (auth.uid() = to_user_id);

-- User follows
CREATE POLICY "follows_read"   ON user_follows FOR SELECT USING (true);
CREATE POLICY "follows_insert" ON user_follows FOR INSERT WITH CHECK (auth.uid() = follower_id);
CREATE POLICY "follows_delete" ON user_follows FOR DELETE USING (auth.uid() = follower_id);

-- Tables communautaires : lecture publique, écriture réservée à l'auteur
ALTER TABLE posts               ENABLE ROW LEVEL SECURITY;
ALTER TABLE post_likes          ENABLE ROW LEVEL SECURITY;
ALTER TABLE post_comments       ENABLE ROW LEVEL SECURITY;
ALTER TABLE community_events    ENABLE ROW LEVEL SECURITY;
ALTER TABLE event_participants  ENABLE ROW LEVEL SECURITY;
ALTER TABLE training_partners   ENABLE ROW LEVEL SECURITY;

CREATE POLICY "posts_select"    ON posts            FOR SELECT USING (true);
CREATE POLICY "posts_insert"    ON posts            FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "posts_update"    ON posts            FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "posts_delete"    ON posts            FOR DELETE USING (auth.uid() = user_id);

CREATE POLICY "likes_select"    ON post_likes       FOR SELECT USING (true);
CREATE POLICY "likes_insert"    ON post_likes       FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "likes_delete"    ON post_likes       FOR DELETE USING (auth.uid() = user_id);

CREATE POLICY "comments_select" ON post_comments    FOR SELECT USING (true);
CREATE POLICY "comments_insert" ON post_comments    FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "comments_delete" ON post_comments    FOR DELETE USING (auth.uid() = user_id);

CREATE POLICY "events_select"   ON community_events FOR SELECT USING (true);
CREATE POLICY "events_insert"   ON community_events FOR INSERT WITH CHECK (auth.uid() = organizer_id);
CREATE POLICY "events_update"   ON community_events FOR UPDATE USING (auth.uid() = organizer_id);
CREATE POLICY "events_delete"   ON community_events FOR DELETE USING (auth.uid() = organizer_id);

CREATE POLICY "participants_select" ON event_participants FOR SELECT USING (true);
CREATE POLICY "participants_insert" ON event_participants FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "participants_delete" ON event_participants FOR DELETE USING (auth.uid() = user_id);

CREATE POLICY "partners_select" ON training_partners FOR SELECT USING (true);
CREATE POLICY "partners_insert" ON training_partners FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "partners_update" ON training_partners FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "partners_delete" ON training_partners FOR DELETE USING (auth.uid() = user_id);

ALTER TABLE partner_join_requests ENABLE ROW LEVEL SECURITY;

-- Le demandeur voit ses propres demandes, le propriétaire voit celles reçues
CREATE POLICY "join_requests_select" ON partner_join_requests FOR SELECT
  USING (auth.uid() = requester_id OR auth.uid() = owner_id);
CREATE POLICY "join_requests_insert" ON partner_join_requests FOR INSERT
  WITH CHECK (auth.uid() = requester_id);
-- Le propriétaire peut accepter/refuser (update du status)
CREATE POLICY "join_requests_update" ON partner_join_requests FOR UPDATE
  USING (auth.uid() = owner_id);
-- Le demandeur peut réinitialiser sa propre demande (upsert après un refus)
CREATE POLICY "join_requests_requester_reset" ON partner_join_requests FOR UPDATE
  USING (auth.uid() = requester_id) WITH CHECK (auth.uid() = requester_id);

-- Tables de référence : lecture publique uniquement
ALTER TABLE programs                  ENABLE ROW LEVEL SECURITY;
ALTER TABLE workouts                  ENABLE ROW LEVEL SECURITY;
ALTER TABLE videos                    ENABLE ROW LEVEL SECURITY;
ALTER TABLE food_items                ENABLE ROW LEVEL SECURITY;
ALTER TABLE xp_challenges             ENABLE ROW LEVEL SECURITY;
ALTER TABLE shop_items                ENABLE ROW LEVEL SECURITY;
ALTER TABLE doctors                   ENABLE ROW LEVEL SECURITY;
ALTER TABLE health_articles           ENABLE ROW LEVEL SECURITY;
ALTER TABLE health_questions          ENABLE ROW LEVEL SECURITY;
ALTER TABLE medical_lexique           ENABLE ROW LEVEL SECURITY;
ALTER TABLE pregnancy_checklist_items ENABLE ROW LEVEL SECURITY;

CREATE POLICY "ref_programs"    ON programs                  FOR SELECT USING (true);
CREATE POLICY "ref_workouts"    ON workouts                  FOR SELECT USING (true);
CREATE POLICY "ref_videos"      ON videos                    FOR SELECT USING (true);
CREATE POLICY "ref_food"        ON food_items                FOR SELECT USING (true);
CREATE POLICY "ref_challenges"  ON xp_challenges             FOR SELECT USING (true);
CREATE POLICY "ref_shop"        ON shop_items                FOR SELECT USING (true);
CREATE POLICY "ref_doctors"     ON doctors                   FOR SELECT USING (true);
CREATE POLICY "ref_articles"    ON health_articles           FOR SELECT USING (true);
CREATE POLICY "ref_questions"   ON health_questions          FOR SELECT USING (true);
CREATE POLICY "ref_lexique"     ON medical_lexique           FOR SELECT USING (true);
CREATE POLICY "ref_checklist"   ON pregnancy_checklist_items FOR SELECT USING (true);

-- ══════════════════════════════════════════════════════════════════════════════
-- SECTION 14 — INDEX
-- ══════════════════════════════════════════════════════════════════════════════

CREATE INDEX idx_workouts_program        ON workouts(program_id);
CREATE INDEX idx_videos_workout          ON videos(workout_id, sort_order);
CREATE INDEX idx_meal_entries_user_date  ON meal_entries(user_id, log_date);
CREATE INDEX idx_meal_entries_meal_type  ON meal_entries(user_id, log_date, meal_type);
CREATE INDEX idx_daily_symptoms_user     ON daily_symptoms(user_id, log_date);
CREATE INDEX idx_daily_moods_user        ON daily_moods(user_id, log_date);
CREATE INDEX idx_posts_created           ON posts(created_at DESC);
CREATE INDEX idx_posts_user              ON posts(user_id);
CREATE INDEX idx_food_items_category     ON food_items(category);
CREATE INDEX idx_xp_history_user         ON xp_history(user_id, earned_at DESC);
CREATE INDEX idx_points_history_user     ON points_history(user_id, earned_at DESC);
CREATE INDEX idx_events_date             ON community_events(event_date);
CREATE INDEX idx_period_history_user     ON period_history(user_id, start_date DESC);
CREATE INDEX idx_pregnancy_symptoms      ON pregnancy_symptoms(user_id, week_sa);
CREATE INDEX idx_post_comments_post      ON post_comments(post_id, created_at);
CREATE INDEX idx_shop_items_category     ON shop_items(category) WHERE is_active = true;

-- ══════════════════════════════════════════════════════════════════════════════
-- SECTION 15 — SEED : DONNÉES DE RÉFÉRENCE
-- ══════════════════════════════════════════════════════════════════════════════

-- ── Challenges XP ────────────────────────────────────────────────────────────
INSERT INTO xp_challenges (key, title_fr, title_en, emoji, target_days, xp_reward) VALUES
  ('water',     'Boire de l''eau',  'Drink water',       '💧', 7, 30),
  ('mood7',     'Humeur 7 jours',   'Mood tracking 7d',  '😊', 7, 40),
  ('cycleWeek', 'Semaine cycle',    'Cycle awareness',   '🌸', 7, 50);

-- ── Programmes ───────────────────────────────────────────────────────────────
INSERT INTO programs (id, name, duration, phases, sessions, color, image_url, compatible_cycles, total_points, level, equipment, category) VALUES
('prog_home_glow',        'Home Glow',        '4 semaines', 'Règles + Foll. + Ovul.', '3 séances / sem.', -13181736, 'assets/images/fullbody.jpg',  ARRAY['Folliculaire','Ovulation'],            100, 'Tous niveaux',  ARRAY['Mat','Dumbbells'],                'home'),
('prog_pilates_reset',    'Pilates Reset',    '8 semaines', 'Toutes phases',           '3 séances / sem.', -14583808, 'assets/images/pilates.jpg',   ARRAY['Règles','Lutéale'],                   100, 'Débutant',      ARRAY['Mat'],                            'home'),
('prog_booty_home',       'Booty From Home',  '4 semaines', 'Toutes phases',           '4 séances / sem.', -14737007, 'assets/images/strength.jpg',  ARRAY['Folliculaire','Lutéale'],             100, 'Intermédiaire', ARRAY['Mat','Resistance Band'],          'home'),
('prog_salle_builder',    'Body Builder',     '6 semaines', 'Follic. + Ovul.',         '4 séances / sem.', -14643408, 'assets/images/strength.jpg',  ARRAY['Folliculaire','Ovulation'],           100, 'Intermédiaire', ARRAY['Barbell','Dumbbells','Bench'],    'salle'),
('prog_salle_stronger',   'Stronger You',     '4 semaines', 'Toutes phases',           '3 séances / sem.', -13983182, 'assets/images/upper.jpg',     ARRAY['Règles','Ovulation'],                 100, 'Avancé',        ARRAY['Dumbbells','Cable Machine'],      'salle'),
('prog_salle_lean',       'Lean 4 Life',      '4 semaines', 'Toutes phases',           '3 séances / sem.', -16749764, 'assets/images/fullbody.jpg',  ARRAY['Règles','Folliculaire','Lutéale'],    100, 'Tous niveaux',  ARRAY['Barbell','Dumbbells'],            'salle'),
('prog_dance_zumba_flow', 'Zumba Flow',       '4 semaines', 'Toutes phases',           '3 séances / sem.', -1834016,  'assets/images/fullbody.jpg',  ARRAY['Folliculaire','Ovulation'],           100, 'Tous niveaux',  ARRAY[]::TEXT[],                         'dance'),
('prog_recovery_gentle',  'Gentle Recovery',  '2 semaines', 'Toutes phases',           '5 séances / sem.', -16722608, 'assets/images/fullbody.jpg',  ARRAY['Règles','Lutéale'],                    80, 'Tous niveaux',  ARRAY['Mat'],                            'recuperation'),
('prog_pregnancy_safe',   'Pregnancy Safe',   '9 mois',     'Grossesse',               '3 séances / sem.', -17416,    'assets/images/fullbody.jpg',  ARRAY['Grossesse'],                          120, 'Débutant',      ARRAY['Mat'],                            'grossesse');

-- ── Workouts ──────────────────────────────────────────────────────────────────
INSERT INTO workouts (id, program_id, title, category, duration, level, image_url, calories, exercises, points) VALUES
('home_glow_1',       'prog_home_glow',       'Lower Body Flow',      'MAISON',       '20 min', 'Tous niveaux',  'assets/images/fullbody.jpg',  '220', ARRAY['Squats','Glute Bridge','Lunges'],           35),
('home_glow_2',       'prog_home_glow',       'Core & Posture',       'MAISON',       '18 min', 'Débutant',      'assets/images/slim1.png',     '180', ARRAY['Dead Bug','Bird Dog','Plank'],              30),
('home_glow_3',       'prog_home_glow',       'Quick Cardio',         'MAISON',       '15 min', 'Intermédiaire', 'assets/images/fiteva_girl.jpg','200', ARRAY['March Run','Jumping Jacks','High Knees'],   35),
('pilates_reset_1',   'prog_pilates_reset',   'Morning Centering',    'MAISON',       '25 min', 'Débutant',      'assets/images/pilates.jpg',   '180', ARRAY['Breathing','Roll Up','Hundred'],            35),
('pilates_reset_2',   'prog_pilates_reset',   'Spine Mobility',       'MAISON',       '22 min', 'Tous niveaux',  'assets/images/Core.jpg',      '170', ARRAY['Cat-Cow','Side Reach','Teaser Prep'],       32),
('pilates_reset_3',   'prog_pilates_reset',   'Deep Core Work',       'MAISON',       '20 min', 'Intermédiaire', 'assets/images/Core.jpg',      '190', ARRAY['Single Leg Stretch','Leg Circle','Plank'],  33),
('booty_home_1',      'prog_booty_home',      'Glute Activation',     'MAISON',       '18 min', 'Débutant',      'assets/images/strength.jpg',  '200', ARRAY['Clamshell','Glute Bridge','Kickback'],      30),
('booty_home_2',      'prog_booty_home',      'Booty Sculpt',         'MAISON',       '24 min', 'Intermédiaire', 'assets/images/upper.jpg',     '240', ARRAY['Squats','Sumo Squats','Split Squats'],      35),
('booty_home_3',      'prog_booty_home',      'Finisher Burn',        'MAISON',       '12 min', 'Tous niveaux',  'assets/images/fullbody.jpg',  '150', ARRAY['Pulse Squats','Donkey Kicks','Wall Sit'],   35),
('salle_body_1',      'prog_salle_builder',   'Heavy Compound',       'SALLE',        '25 min', 'Intermédiaire', 'assets/images/strength.jpg',  '260', ARRAY['Deadlift','Back Squat','Bench Press'],      35),
('salle_body_2',      'prog_salle_builder',   'Pull Focus',           'SALLE',        '20 min', 'Avancé',        'assets/images/upper.jpg',     '230', ARRAY['Pull-ups','Row Machine','Lat Pulldown'],    33),
('salle_body_3',      'prog_salle_builder',   'Leg Power',            'SALLE',        '22 min', 'Débutant',      'assets/images/workout.jpeg',  '240', ARRAY['Leg Press','Lunges','Calf Raises'],         32),
('salle_body_squat',  'prog_salle_builder',   'Squat',                'SALLE',        '15 min', 'Intermédiaire', 'assets/images/strength.jpg',  '200', ARRAY['Back Squat','Goblet Squat','Jump Squat'],   30),
('salle_stronger_1',  'prog_salle_stronger',  'Upper Push',           'SALLE',        '20 min', 'Intermédiaire', 'assets/images/upper.jpg',     '220', ARRAY['Push-ups','Dumbbell Press','Tricep Dips'],  34),
('salle_stronger_2',  'prog_salle_stronger',  'Back Builder',         'SALLE',        '22 min', 'Avancé',        'assets/images/strength.jpg',  '240', ARRAY['Lat Pulldown','Bent Over Row','Face Pull'], 33),
('salle_stronger_3',  'prog_salle_stronger',  'Arms Finish',          'SALLE',        '15 min', 'Tous niveaux',  'assets/images/workout.jpeg',  '180', ARRAY['Bicep Curls','Hammer Curls','Overhead Press'],33),
('salle_lean_1',      'prog_salle_lean',      'Full Body Strength',   'SALLE',        '25 min', 'Tous niveaux',  'assets/images/fullbody.jpg',  '240', ARRAY['Squats','Press','Rows'],                    34),
('salle_lean_2',      'prog_salle_lean',      'Burn Circuit',         'SALLE',        '20 min', 'Intermédiaire', 'assets/images/upper.jpg',     '230', ARRAY['Thrusters','Mountain Climbers','Burpees'],  33),
('salle_lean_3',      'prog_salle_lean',      'Core Finisher',        'SALLE',        '12 min', 'Débutant',      'assets/images/Core.jpg',      '150', ARRAY['Plank','Russian Twist','Leg Raise'],        33),
('dance_zumba_1',     'prog_dance_zumba_flow','Zumba Basics',         'DANCE',        '20 min', 'Débutant',      'assets/images/fullbody.jpg',  '200', ARRAY['Basic Step','Hip Movement','Arm Patterns'], 35),
('dance_zumba_2',     'prog_dance_zumba_flow','Zumba Party',          'DANCE',        '25 min', 'Intermédiaire', 'assets/images/fullbody.jpg',  '250', ARRAY['Salsa','Reggaeton','Latin Moves'],          35),
('dance_zumba_3',     'prog_dance_zumba_flow','Zumba Cardio Blast',   'DANCE',        '30 min', 'Avancé',        'assets/images/fullbody.jpg',  '300', ARRAY['Fast Pace','Complex Moves','Combinations'], 30),
('recup_gentle_1',    'prog_recovery_gentle', 'Yoga Relaxation',      'RECUPERATION', '15 min', 'Tous niveaux',  'assets/images/fullbody.jpg',  '80',  ARRAY['Child Pose','Cat-Cow','Savasana'],          25),
('recup_gentle_2',    'prog_recovery_gentle', 'Stretching Session',   'RECUPERATION', '18 min', 'Tous niveaux',  'assets/images/fullbody.jpg',  '90',  ARRAY['Full Body Stretch','Deep Stretches','Breathing'],27),
('recup_gentle_3',    'prog_recovery_gentle', 'Foam Rolling',         'RECUPERATION', '20 min', 'Intermédiaire', 'assets/images/fullbody.jpg',  '100', ARRAY['Foam Roll','Mobility Work','Joint Care'],   28),
('preg_safe_1',       'prog_pregnancy_safe',  'First Trimester Cardio','GROSSESSE',   '20 min', 'Débutant',      'assets/images/fullbody.jpg',  '150', ARRAY['Walking','Light Cardio','Breathing'],       40),
('preg_safe_2',       'prog_pregnancy_safe',  'Pelvic Floor Strength', 'GROSSESSE',   '18 min', 'Tous niveaux',  'assets/images/fullbody.jpg',  '120', ARRAY['Pelvic Floor','Kegels','Core Work'],        40),
('preg_safe_3',       'prog_pregnancy_safe',  'Prenatal Yoga',         'GROSSESSE',   '25 min', 'Tous niveaux',  'assets/images/fullbody.jpg',  '140', ARRAY['Prenatal Poses','Stretching','Meditation'], 40);

-- ── Vidéos ───────────────────────────────────────────────────────────────────
INSERT INTO videos (id, workout_id, title, duration, points, url, sort_order) VALUES
('vid_hg1_1','home_glow_1','Warm Up','3 min',12,'',1),('vid_hg1_2','home_glow_1','Main Workout','14 min',12,'',2),('vid_hg1_3','home_glow_1','Cool Down','3 min',11,'',3),
('vid_hg2_1','home_glow_2','Core Activation','6 min',10,'',1),('vid_hg2_2','home_glow_2','Posture Work','10 min',10,'',2),('vid_hg2_3','home_glow_2','Stretch','2 min',10,'',3),
('vid_hg3_1','home_glow_3','Cardio Warm Up','3 min',12,'',1),('vid_hg3_2','home_glow_3','HIIT Circuit','10 min',12,'',2),('vid_hg3_3','home_glow_3','Recovery','2 min',11,'',3),
('vid_pr1_1','pilates_reset_1','Breathing Exercise','5 min',12,'',1),('vid_pr1_2','pilates_reset_1','Roll Up Series','12 min',12,'',2),('vid_pr1_3','pilates_reset_1','Hundred Prep','8 min',11,'',3),
('vid_pr2_1','pilates_reset_2','Spine Warm Up','6 min',11,'',1),('vid_pr2_2','pilates_reset_2','Mobility Flow','12 min',11,'',2),('vid_pr2_3','pilates_reset_2','Teaser Prep','4 min',10,'',3),
('vid_pr3_1','pilates_reset_3','Core Activation','7 min',11,'',1),('vid_pr3_2','pilates_reset_3','Core Series','11 min',11,'',2),('vid_pr3_3','pilates_reset_3','Core Finisher','2 min',11,'',3),
('vid_sb1_1','salle_body_1','Form Check','5 min',12,'',1),('vid_sb1_2','salle_body_1','Heavy Sets','16 min',12,'',2),('vid_sb1_3','salle_body_1','Recovery','4 min',11,'',3),
('vid_squat_1','salle_body_squat','Technique Squat','3 min',30,'assets/videos/squat.mp4',1),
('vid_dz1_1','dance_zumba_1','Intro & Warm Up','4 min',12,'',1),('vid_dz1_2','dance_zumba_1','Basic Steps','12 min',12,'',2),('vid_dz1_3','dance_zumba_1','Cool Down','4 min',11,'',3),
('vid_rg1_1','recup_gentle_1','Centering','3 min',8,'',1),('vid_rg1_2','recup_gentle_1','Gentle Flow','10 min',9,'',2),('vid_rg1_3','recup_gentle_1','Meditation','2 min',8,'',3),
('vid_ps1_1','preg_safe_1','Safe Start','3 min',13,'',1),('vid_ps1_2','preg_safe_1','Cardio Flow','14 min',14,'',2),('vid_ps1_3','preg_safe_1','Recovery','3 min',13,'',3);

-- ── Aliments (food_items) — 140 entrées condensées ──────────────────────────
INSERT INTO food_items (id,name,category,kcal,protein,carbs,fat,fiber,default_grams,portion_label) VALUES
('chicken_breast','Poulet (filet)','viandes',165,31.0,0.0,3.6,0,150,'1 filet'),
('chicken_thigh','Cuisse de poulet','viandes',209,24.0,0.0,12.0,0,120,'1 cuisse'),
('turkey_breast','Dinde (filet)','viandes',157,30.0,0.0,3.5,0,150,'1 filet'),
('beef_lean','Bœuf haché 5%','viandes',137,20.5,0.0,6.0,0,100,'1 steak (100 g)'),
('beef_steak','Steak de bœuf','viandes',172,26.0,0.0,7.2,0,130,'1 steak'),
('pork_tenderloin','Filet de porc','viandes',143,22.0,0.0,5.9,0,130,'1 portion'),
('lamb_leg','Agneau (gigot)','viandes',192,23.0,0.0,11.0,0,130,'1 tranche'),
('ham_cooked','Jambon cuit (blanc)','viandes',107,17.0,1.2,3.6,0,45,'2 tranches'),
('chorizo','Chorizo','viandes',379,19.0,2.0,33.0,0,30,'6 rondelles'),
('salmon','Saumon (filet)','poissons',208,20.0,0.0,13.0,0,150,'1 filet'),
('tuna_canned','Thon en boîte (naturel)','poissons',116,26.0,0.0,1.0,0,120,'1 boîte'),
('cod','Cabillaud','poissons',82,18.0,0.0,0.7,0,150,'1 filet'),
('trout','Truite','poissons',148,20.0,0.0,7.2,0,150,'1 filet'),
('sardines','Sardines à l''huile','poissons',208,24.0,0.0,12.0,0,85,'1 boîte'),
('shrimp','Crevettes décortiquées','poissons',99,21.0,0.9,1.1,0,100,'100 g'),
('mussels','Moules','poissons',86,12.0,3.7,2.2,0,200,'200 g'),
('mackerel','Maquereau','poissons',205,19.0,0.0,14.0,0,120,'1 filet'),
('egg_whole','Œuf entier','oeufslaitiers',155,13.0,1.1,11.0,0,60,'1 œuf'),
('egg_white','Blanc d''œuf','oeufslaitiers',52,11.0,0.7,0.2,0,35,'1 blanc'),
('greek_yogurt','Yaourt grec (0%)','oeufslaitiers',59,10.0,3.6,0.4,0,150,'1 pot'),
('yogurt_nature','Yaourt nature','oeufslaitiers',61,3.8,4.7,3.2,0,125,'1 pot'),
('cottage_cheese','Fromage blanc (0%)','oeufslaitiers',45,7.8,3.2,0.3,0,150,'1 pot'),
('milk_skimmed','Lait écrémé','oeufslaitiers',34,3.4,4.9,0.1,0,200,'1 verre'),
('milk_whole','Lait entier','oeufslaitiers',61,3.2,4.8,3.3,0,200,'1 verre'),
('cheddar','Cheddar','oeufslaitiers',403,25.0,1.3,33.0,0,30,'1 tranche'),
('mozzarella','Mozzarella','oeufslaitiers',280,17.0,3.1,22.0,0,60,'½ boule'),
('parmesan','Parmesan râpé','oeufslaitiers',431,38.0,3.2,29.0,0,20,'2 c.à.s'),
('feta','Feta','oeufslaitiers',264,14.0,4.1,21.0,0,50,'1 portion'),
('rice_white','Riz blanc (cuit)','cereales',130,2.7,28.0,0.3,0.4,150,'1 portion'),
('rice_brown','Riz complet (cuit)','cereales',112,2.6,23.0,0.9,1.8,150,'1 portion'),
('quinoa','Quinoa (cuit)','cereales',120,4.4,21.0,1.9,2.8,150,'1 portion'),
('pasta_cooked','Pâtes (cuites)','cereales',131,5.0,25.0,1.1,1.8,180,'1 portion'),
('pasta_ww','Pâtes complètes (cuites)','cereales',124,5.3,23.0,1.0,3.2,180,'1 portion'),
('oats','Flocons d''avoine','cereales',389,17.0,66.0,7.0,10.6,60,'6 c.à.s'),
('bread_whole','Pain complet','cereales',247,9.0,41.0,3.4,6.5,40,'2 tranches'),
('bread_white','Pain blanc (baguette)','cereales',272,8.5,53.0,1.6,2.4,50,'2 tranches'),
('sweet_potato','Patate douce (cuite)','cereales',86,1.6,20.0,0.1,3.0,150,'1 petite'),
('potato','Pomme de terre (cuite)','cereales',77,2.0,17.0,0.1,1.8,150,'1 moyenne'),
('couscous','Couscous (cuit)','cereales',112,3.8,23.0,0.2,1.4,150,'1 portion'),
('corn','Maïs doux','cereales',86,3.2,19.0,1.2,2.7,100,'100 g'),
('granola','Granola nature','cereales',471,10.0,64.0,20.0,6.0,50,'1 bol'),
('lentils','Lentilles (cuites)','legumineuses',116,9.0,20.0,0.4,7.9,150,'1 portion'),
('chickpeas','Pois chiches (cuits)','legumineuses',164,8.9,27.0,2.6,7.6,150,'1 portion'),
('black_beans','Haricots noirs (cuits)','legumineuses',132,8.9,24.0,0.5,8.7,150,'1 portion'),
('white_beans','Haricots blancs (cuits)','legumineuses',139,9.7,25.0,0.5,10.5,150,'1 portion'),
('edamame','Edamame','legumineuses',121,11.0,8.9,5.2,5.2,100,'100 g'),
('tofu','Tofu ferme','legumineuses',144,17.0,2.8,8.7,0.3,100,'100 g'),
('hummus','Houmous','legumineuses',166,7.9,14.0,9.6,6.0,60,'3 c.à.s'),
('spinach','Épinards','legumes',23,2.9,3.6,0.4,2.2,100,'1 grosse poignée'),
('broccoli','Brocoli','legumes',34,2.8,7.0,0.4,2.6,150,'1 portion'),
('carrots','Carottes','legumes',41,0.9,10.0,0.2,2.8,100,'2 carottes'),
('tomato','Tomate','legumes',18,0.9,3.9,0.2,1.2,120,'1 moyenne'),
('cucumber','Concombre','legumes',15,0.7,3.6,0.1,0.5,150,'½ concombre'),
('bell_pepper','Poivron rouge','legumes',31,1.0,6.0,0.3,2.1,100,'1 moyen'),
('zucchini','Courgette','legumes',17,1.2,3.1,0.3,1.0,150,'1 petite'),
('eggplant','Aubergine','legumes',25,1.0,5.9,0.2,3.0,150,'½ aubergine'),
('onion','Oignon','legumes',40,1.1,9.3,0.1,1.7,80,'1 moyen'),
('garlic','Ail','legumes',149,6.4,33.0,0.5,2.1,5,'1 gousse'),
('mushroom','Champignons de Paris','legumes',22,3.1,3.3,0.3,1.0,100,'100 g'),
('lettuce','Salade verte','legumes',15,1.4,2.9,0.2,1.3,80,'1 bol'),
('cauliflower','Chou-fleur','legumes',25,1.9,5.0,0.3,2.0,150,'1 portion'),
('green_beans','Haricots verts','legumes',31,1.8,7.1,0.1,3.4,150,'1 portion'),
('apple','Pomme','fruits',52,0.3,14.0,0.2,2.4,150,'1 moyenne'),
('banana','Banane','fruits',89,1.1,23.0,0.3,2.6,120,'1 moyenne'),
('orange','Orange','fruits',47,0.9,12.0,0.1,2.4,150,'1 moyenne'),
('avocado','Avocat (½)','fruits',160,2.0,9.0,15.0,6.7,80,'½ avocat'),
('strawberry','Fraises','fruits',32,0.7,7.7,0.3,2.0,150,'1 bol'),
('blueberry','Myrtilles','fruits',57,0.7,14.0,0.3,2.4,100,'1 petite poignée'),
('mango','Mangue','fruits',60,0.8,15.0,0.4,1.6,150,'½ mangue'),
('pineapple','Ananas','fruits',50,0.5,13.0,0.1,1.4,150,'2 tranches'),
('grapes','Raisins','fruits',69,0.7,18.0,0.2,0.9,100,'1 grappe'),
('kiwi','Kiwi','fruits',61,1.1,15.0,0.5,3.0,80,'1 kiwi'),
('watermelon','Pastèque','fruits',30,0.6,7.6,0.2,0.4,200,'1 tranche'),
('dates','Dattes','fruits',277,1.8,75.0,0.2,6.7,30,'3 dattes'),
('almonds','Amandes','oleagineux',579,21.0,22.0,50.0,12.5,30,'1 petite poignée'),
('walnuts','Noix','oleagineux',654,15.0,14.0,65.0,6.7,30,'5 cerneaux'),
('cashews','Noix de cajou','oleagineux',553,18.0,30.0,44.0,3.3,30,'1 petite poignée'),
('peanuts','Cacahuètes','oleagineux',567,26.0,16.0,49.0,8.5,30,'1 petite poignée'),
('peanut_butter','Beurre de cacahuète','oleagineux',588,25.0,20.0,50.0,6.0,30,'2 c.à.s'),
('almond_butter','Beurre d''amande','oleagineux',614,21.0,19.0,56.0,10.3,30,'2 c.à.s'),
('chia_seeds','Graines de chia','oleagineux',486,17.0,42.0,31.0,34.4,20,'2 c.à.s'),
('flaxseeds','Graines de lin','oleagineux',534,18.0,29.0,42.0,27.3,15,'1 c.à.s'),
('pumpkin_seeds','Graines de courge','oleagineux',559,30.0,11.0,49.0,6.0,30,'2 c.à.s'),
('olive_oil','Huile d''olive','corpsGras',884,0.0,0.0,100.0,0,10,'1 c.à.s'),
('butter','Beurre','corpsGras',717,0.9,0.1,81.0,0,10,'1 noisette'),
('coconut_oil','Huile de coco','corpsGras',862,0.0,0.0,99.0,0,10,'1 c.à.s'),
('avocado_oil','Huile d''avocat','corpsGras',884,0.0,0.0,100.0,0,10,'1 c.à.s'),
('caesar_salad','Salade César (poulet)','platCompose',180,15.0,9.0,10.0,2.0,250,'1 portion'),
('chicken_rice_bowl','Bowl poulet riz','platCompose',410,38.0,42.0,8.0,3.5,400,'1 bowl'),
('protein_smoothie','Smoothie protéiné','platCompose',280,25.0,30.0,6.0,3.0,350,'1 verre'),
('overnight_oats','Overnight oats','platCompose',320,14.0,48.0,8.0,6.0,300,'1 bol'),
('veggie_wrap','Wrap légumes & houmous','platCompose',340,12.0,45.0,13.0,7.0,200,'1 wrap'),
('pasta_bolognese','Pâtes bolognaise','platCompose',380,22.0,48.0,10.0,4.0,350,'1 assiette'),
('vegetable_soup','Soupe de légumes','platCompose',75,3.0,14.0,1.0,4.0,300,'1 bol'),
('water','Eau','boissons',0,0.0,0.0,0.0,0,250,'1 verre'),
('coffee_black','Café noir','boissons',2,0.3,0.0,0.0,0,200,'1 tasse'),
('orange_juice','Jus d''orange (pressé)','boissons',45,0.7,10.0,0.2,0.2,200,'1 verre'),
('almond_milk','Boisson amande','boissons',24,0.9,3.2,1.1,0.3,200,'1 verre'),
('oat_milk','Boisson avoine','boissons',47,1.0,9.0,1.5,0.8,200,'1 verre'),
('green_tea','Thé vert','boissons',1,0.2,0.0,0.0,0,250,'1 tasse'),
('dark_chocolate','Chocolat noir 85%','desserts',598,12.0,24.0,52.0,10.9,30,'3 carrés'),
('honey','Miel','desserts',304,0.3,82.0,0.0,0.2,15,'1 c.à.s'),
('rice_cake','Galette de riz','desserts',387,7.8,85.0,2.8,1.6,20,'2 galettes'),
('protein_bar','Barre protéinée','desserts',380,22.0,37.0,12.0,3.5,60,'1 barre'),
('whey_protein','Whey protéine (vanille)','desserts',370,74.0,8.0,6.0,0.5,30,'1 dose');

-- ── Checklist grossesse ──────────────────────────────────────────────────────
INSERT INTO pregnancy_checklist_items (trimester, title, description, sort_order) VALUES
(1,'Première consultation','Prendre rendez-vous avec votre gynécologue ou sage-femme.',1),
(1,'Déclaration de grossesse','Déclarer la grossesse avant la fin du 3ème mois.',2),
(1,'Prise d''acide folique','Supplémenter en acide folique (800 µg/j).',3),
(1,'Arrêt alcool & tabac','Éliminer toute consommation d''alcool et de tabac.',4),
(2,'Échographie du 2ème trimestre','Morphologie fœtale vers 22 SA.',1),
(2,'Cours de préparation à la naissance','S''inscrire aux cours de préparation.',2),
(2,'Bilan sanguin du 2ème trimestre','Réaliser les analyses prescrites.',3),
(3,'Visite de la maternité','Préparer le dossier et visiter la maternité.',1),
(3,'Plan de naissance','Rédiger votre plan de naissance.',2),
(3,'Valise de maternité','Préparer la valise pour la maternité.',3),
(3,'Installation bébé','Monter le lit, le bain, les vêtements.',4);

-- ══════════════════════════════════════════════════════════════════════════════
-- SECTION 13 — ABONNEMENTS STRIPE
-- (Nouvelle section : exécuter ce bloc seul dans le SQL Editor si le reste
--  du schéma est déjà appliqué.)
-- ══════════════════════════════════════════════════════════════════════════════

-- ── 13.1  Abonnement de l'utilisateur (1 ligne par user) ─────────────────────
-- plan   : 'free' | 'pro_monthly' | 'pro_annual'
-- status : statut Stripe ('active','trialing','past_due','canceled',
--          'incomplete', ...) + 'canceling' (annulation en fin de période)
CREATE TABLE user_subscriptions (
  user_id                 UUID         PRIMARY KEY REFERENCES user_profiles(id) ON DELETE CASCADE,
  plan                    TEXT         NOT NULL DEFAULT 'free'
                                       CHECK (plan IN ('free','pro_monthly','pro_annual')),
  status                  TEXT         NOT NULL DEFAULT 'inactive',
  stripe_customer_id      TEXT,
  stripe_subscription_id  TEXT,
  current_period_end      TIMESTAMPTZ,
  created_at              TIMESTAMPTZ  NOT NULL DEFAULT now(),
  updated_at              TIMESTAMPTZ  NOT NULL DEFAULT now()
);

CREATE INDEX idx_user_subscriptions_customer
  ON user_subscriptions (stripe_customer_id);

CREATE TRIGGER trg_user_subscriptions_upd
  BEFORE UPDATE ON user_subscriptions
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- ── 13.2  RLS : lecture seule pour l'utilisateur ─────────────────────────────
-- Les écritures passent UNIQUEMENT par les Edge Functions (service role),
-- jamais par l'app — un utilisateur ne peut pas s'attribuer le plan Pro.
ALTER TABLE user_subscriptions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "read_own_subscription" ON user_subscriptions
  FOR SELECT USING (auth.uid() = user_id);

-- ── 13.3  Helper : l'utilisateur courant est-il Pro ? ────────────────────────
-- Utilisable dans d'autres policies RLS ou via .rpc('is_pro') côté app.
CREATE OR REPLACE FUNCTION is_pro()
RETURNS BOOLEAN LANGUAGE sql SECURITY DEFINER STABLE AS $$
  SELECT EXISTS (
    SELECT 1 FROM user_subscriptions
    WHERE user_id = auth.uid()
      AND plan IN ('pro_monthly','pro_annual')
      AND status IN ('active','trialing','canceling')
      AND (current_period_end IS NULL OR current_period_end > now())
  );
$$;


-- ══════════════════════════════════════════════════════════════════════════
--  14. RGPD — demandes de suppression de compte
-- ══════════════════════════════════════════════════════════════════════════
-- Le SDK client ne peut pas supprimer auth.users directement (nécessite la
-- clé service_role, jamais embarquée côté app). PrivacyService.deleteAllUserData()
-- efface toutes les lignes de données de l'utilisateur puis insère ici une
-- demande, à traiter côté serveur (edge function / cron avec service_role)
-- pour finaliser la suppression du compte Auth.
CREATE TABLE account_deletion_requests (
  id           UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id      UUID         NOT NULL,
  requested_at TIMESTAMPTZ  NOT NULL DEFAULT now(),
  processed_at TIMESTAMPTZ
);

ALTER TABLE account_deletion_requests ENABLE ROW LEVEL SECURITY;

-- L'utilisateur peut créer sa propre demande, mais ne peut ni la lire ni la
-- modifier ensuite (évite de fuiter/altérer l'état de traitement) — seul le
-- service_role, qui bypass RLS, peut lire/traiter la file.
CREATE POLICY "own_account_deletion_insert" ON account_deletion_requests
  FOR INSERT WITH CHECK (auth.uid() = user_id);
