-- ═══════════════════════════════════════════════════════════════════════════
-- MIGRATION — Refonte gamification "Points + Diamants"
-- ═══════════════════════════════════════════════════════════════════════════
--
-- Avant : XP (progression, user_xp/xp_history) + étoiles (monnaie boutique,
--         user_points/points_history), deux systèmes indépendants.
-- Après : POINTS  = progression/niveaux (ex-XP)   — jamais dépensés.
--         DIAMANTS = monnaie boutique (ex-étoiles) — crédités UNIQUEMENT
--         au passage de niveau (trigger fn_award_level_up_diamonds).
--
-- Renommages uniquement — AUCUNE donnée supprimée.
-- IDEMPOTENT : chaque étape vérifie l'état réel de la base avant d'agir,
-- le script peut être rejoué sans erreur (utile si un run précédent a
-- échoué en cours de route, ou si les noms de policies diffèrent du schéma).
--
-- ── PLAN DE ROLLBACK ─────────────────────────────────────────────────────────
-- BEGIN;
--   DROP TRIGGER IF EXISTS trg_award_level_up_diamonds ON user_xp;
--   DROP FUNCTION IF EXISTS fn_award_level_up_diamonds();
--   ALTER TABLE shop_items    RENAME COLUMN diamonds_cost TO etoiles_cost;
--   ALTER TABLE user_diamonds RENAME COLUMN diamonds TO etoiles;
--   ALTER TABLE user_diamonds RENAME TO user_points;
--   ALTER TABLE points_progress_history RENAME TO xp_history;
--   ALTER TABLE diamonds_history        RENAME TO points_history;
--   ALTER TABLE user_xp RENAME COLUMN total_points TO total_xp;
--   (les policies renommées peuvent rester : elles suivent leurs tables ;
--    restaurer aussi fn_create_user_profile — version qui insérait dans
--    user_points.)
-- COMMIT;
-- ─────────────────────────────────────────────────────────────────────────────

BEGIN;

-- ── 1. user_xp : la table garde son nom, la colonne devient total_points ────
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.columns
             WHERE table_schema = 'public' AND table_name = 'user_xp'
               AND column_name = 'total_xp') THEN
    ALTER TABLE user_xp RENAME COLUMN total_xp TO total_points;
  END IF;
END $$;

-- ── 2. points_history (ex-étoiles boutique) → diamonds_history ──────────────
--    (renommée AVANT xp_history pour éviter toute collision de nom)
DO $$
BEGIN
  IF to_regclass('public.points_history') IS NOT NULL
     AND to_regclass('public.diamonds_history') IS NULL THEN
    ALTER TABLE points_history RENAME TO diamonds_history;
  END IF;
END $$;

-- ── 3. xp_history → points_progress_history ─────────────────────────────────
--    Nom explicite : historique de la PROGRESSION (points), distinct de
--    diamonds_history (portefeuille boutique).
DO $$
BEGIN
  IF to_regclass('public.xp_history') IS NOT NULL
     AND to_regclass('public.points_progress_history') IS NULL THEN
    ALTER TABLE xp_history RENAME TO points_progress_history;
  END IF;
END $$;

-- ── 4. user_points → user_diamonds, etoiles → diamonds ──────────────────────
DO $$
BEGIN
  IF to_regclass('public.user_points') IS NOT NULL
     AND to_regclass('public.user_diamonds') IS NULL THEN
    ALTER TABLE user_points RENAME TO user_diamonds;
  END IF;
  IF EXISTS (SELECT 1 FROM information_schema.columns
             WHERE table_schema = 'public' AND table_name = 'user_diamonds'
               AND column_name = 'etoiles') THEN
    ALTER TABLE user_diamonds RENAME COLUMN etoiles TO diamonds;
  END IF;
END $$;

-- ── 5. shop_items.etoiles_cost → diamonds_cost ──────────────────────────────
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.columns
             WHERE table_schema = 'public' AND table_name = 'shop_items'
               AND column_name = 'etoiles_cost') THEN
    ALTER TABLE shop_items RENAME COLUMN etoiles_cost TO diamonds_cost;
  END IF;
END $$;

-- ── 6. Policies RLS ──────────────────────────────────────────────────────────
-- Les policies suivent automatiquement les tables renommées. Pour chaque
-- policy attendue : renomme l'ancienne si elle existe, sinon la CRÉE avec le
-- bon nom (couvre le cas où la base n'avait jamais eu ces policies, ou les
-- avait sous un autre nom). RLS est (ré)activé au passage.
DO $$
BEGIN
  -- diamonds_history : écriture réservée au propriétaire
  EXECUTE 'ALTER TABLE diamonds_history ENABLE ROW LEVEL SECURITY';
  IF EXISTS (SELECT 1 FROM pg_policies WHERE schemaname = 'public'
             AND tablename = 'diamonds_history' AND policyname = 'own_points_history') THEN
    ALTER POLICY "own_points_history" ON diamonds_history RENAME TO "own_diamonds_history";
  ELSIF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname = 'public'
             AND tablename = 'diamonds_history' AND policyname = 'own_diamonds_history') THEN
    CREATE POLICY "own_diamonds_history" ON diamonds_history FOR ALL
      USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);
  END IF;

  -- points_progress_history : écriture réservée au propriétaire
  EXECUTE 'ALTER TABLE points_progress_history ENABLE ROW LEVEL SECURITY';
  IF EXISTS (SELECT 1 FROM pg_policies WHERE schemaname = 'public'
             AND tablename = 'points_progress_history' AND policyname = 'own_xp_history') THEN
    ALTER POLICY "own_xp_history" ON points_progress_history RENAME TO "own_points_progress_history";
  ELSIF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname = 'public'
             AND tablename = 'points_progress_history' AND policyname = 'own_points_progress_history') THEN
    CREATE POLICY "own_points_progress_history" ON points_progress_history FOR ALL
      USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);
  END IF;

  -- user_diamonds : écriture réservée au propriétaire
  EXECUTE 'ALTER TABLE user_diamonds ENABLE ROW LEVEL SECURITY';
  IF EXISTS (SELECT 1 FROM pg_policies WHERE schemaname = 'public'
             AND tablename = 'user_diamonds' AND policyname = 'own_user_points') THEN
    ALTER POLICY "own_user_points" ON user_diamonds RENAME TO "own_user_diamonds";
  ELSIF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname = 'public'
             AND tablename = 'user_diamonds' AND policyname = 'own_user_diamonds') THEN
    CREATE POLICY "own_user_diamonds" ON user_diamonds FOR ALL
      USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);
  END IF;

  -- user_diamonds : lecture publique (profil communauté)
  IF EXISTS (SELECT 1 FROM pg_policies WHERE schemaname = 'public'
             AND tablename = 'user_diamonds' AND policyname = 'user_points_public_read') THEN
    ALTER POLICY "user_points_public_read" ON user_diamonds RENAME TO "user_diamonds_public_read";
  ELSIF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname = 'public'
             AND tablename = 'user_diamonds' AND policyname = 'user_diamonds_public_read') THEN
    CREATE POLICY "user_diamonds_public_read" ON user_diamonds FOR SELECT USING (true);
  END IF;

  -- user_xp : la table ne change pas de nom, mais on s'assure que ses
  -- policies existent (own_user_xp + lecture publique du niveau).
  EXECUTE 'ALTER TABLE user_xp ENABLE ROW LEVEL SECURITY';
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname = 'public'
             AND tablename = 'user_xp' AND policyname = 'own_user_xp') THEN
    CREATE POLICY "own_user_xp" ON user_xp FOR ALL
      USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname = 'public'
             AND tablename = 'user_xp' AND policyname = 'user_xp_public_read') THEN
    CREATE POLICY "user_xp_public_read" ON user_xp FOR SELECT USING (true);
  END IF;
END $$;

-- ── 7. Trigger signup : créer la ligne user_diamonds (au lieu de user_points)
CREATE OR REPLACE FUNCTION fn_create_user_profile()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  INSERT INTO user_profiles (id, email)
  VALUES (NEW.id, NEW.email)
  ON CONFLICT DO NOTHING;
  INSERT INTO user_xp       (user_id) VALUES (NEW.id) ON CONFLICT DO NOTHING;
  INSERT INTO user_diamonds (user_id) VALUES (NEW.id) ON CONFLICT DO NOTHING;
  RETURN NEW;
END;
$$;

-- ── 8. Bonus diamants au passage de niveau ───────────────────────────────────
-- Seuils de niveau (points) :   0   100   300   600   1000   1600   2400
-- Niveau                     :  1    2     3     4      5      6      7
-- Bonus diamants au passage  :  -   10    15    20     30     40     60
--
-- Idempotent : reason unique 'level_up_bonus_L<n>' par user — un niveau ne
-- crédite jamais deux fois, même si le client tente aussi de créditer
-- (DiamondsService.creditLevelUpBonus fait le même test côté app).
CREATE OR REPLACE FUNCTION fn_award_level_up_diamonds()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
  thresholds CONSTANT INTEGER[] := ARRAY[0, 100, 300, 600, 1000, 1600, 2400];
  bonuses    CONSTANT INTEGER[] := ARRAY[0,  10,  15,  20,   30,   40,   60];
  old_pts    INTEGER := 0;
  old_level  INTEGER := 1;
  new_level  INTEGER := 1;
  bonus      INTEGER;
BEGIN
  IF TG_OP = 'UPDATE' THEN
    old_pts := COALESCE(OLD.total_points, 0);
  END IF;

  FOR i IN REVERSE array_length(thresholds, 1)..1 LOOP
    IF old_pts >= thresholds[i] THEN old_level := i; EXIT; END IF;
  END LOOP;
  FOR i IN REVERSE array_length(thresholds, 1)..1 LOOP
    IF COALESCE(NEW.total_points, 0) >= thresholds[i] THEN new_level := i; EXIT; END IF;
  END LOOP;

  IF new_level <= old_level THEN RETURN NEW; END IF;

  FOR lvl IN (old_level + 1)..new_level LOOP
    bonus := bonuses[lvl];
    CONTINUE WHEN bonus <= 0;
    CONTINUE WHEN EXISTS (
      SELECT 1 FROM diamonds_history
      WHERE user_id = NEW.user_id
        AND reason  = 'level_up_bonus_L' || lvl
    );
    INSERT INTO diamonds_history (user_id, amount, reason)
    VALUES (NEW.user_id, bonus, 'level_up_bonus_L' || lvl);
    INSERT INTO user_diamonds (user_id, diamonds)
    VALUES (NEW.user_id, bonus)
    ON CONFLICT (user_id) DO UPDATE
      SET diamonds   = user_diamonds.diamonds + EXCLUDED.diamonds,
          updated_at = now();
  END LOOP;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_award_level_up_diamonds ON user_xp;
CREATE TRIGGER trg_award_level_up_diamonds
  AFTER INSERT OR UPDATE OF total_points ON user_xp
  FOR EACH ROW EXECUTE FUNCTION fn_award_level_up_diamonds();

-- ── 9. (OPTIONNEL — commenté) Backfill des niveaux déjà atteints ─────────────
-- Les utilisatrices déjà au-delà d'un seuil au moment de la migration n'ont
-- jamais reçu leur bonus (le trigger ne voit que les passages FUTURS).
-- Décommenter pour créditer rétroactivement les niveaux déjà atteints :
--
-- DO $$
-- DECLARE
--   thresholds CONSTANT INTEGER[] := ARRAY[0, 100, 300, 600, 1000, 1600, 2400];
--   bonuses    CONSTANT INTEGER[] := ARRAY[0,  10,  15,  20,   30,   40,   60];
--   r RECORD;
-- BEGIN
--   FOR r IN SELECT user_id, total_points FROM user_xp LOOP
--     FOR lvl IN 2..array_length(thresholds, 1) LOOP
--       EXIT WHEN r.total_points < thresholds[lvl];
--       CONTINUE WHEN EXISTS (
--         SELECT 1 FROM diamonds_history
--         WHERE user_id = r.user_id AND reason = 'level_up_bonus_L' || lvl);
--       INSERT INTO diamonds_history (user_id, amount, reason)
--       VALUES (r.user_id, bonuses[lvl], 'level_up_bonus_L' || lvl);
--       UPDATE user_diamonds SET diamonds = diamonds + bonuses[lvl],
--         updated_at = now() WHERE user_id = r.user_id;
--     END LOOP;
--   END LOOP;
-- END;
-- $$;

COMMIT;
