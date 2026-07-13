-- ═══════════════════════════════════════════════════════════════════════════
-- MIGRATION — Tracking fiable des jours de connexion (streak + total)
-- ═══════════════════════════════════════════════════════════════════════════
--
-- Problème : le streak était entièrement calculé côté client et envoyé tel
-- quel dans user_xp — un client qui upsertait avant d'avoir chargé son état
-- (race au démarrage de l'app) écrasait le vrai streak avec 1.
--
-- Fix : le serveur devient la source de vérité. Un trigger BEFORE UPDATE
-- recalcule streak et total_login_days à partir de la progression de
-- last_active_date, en ignorant les valeurs envoyées par le client.
--   - même jour / date inchangée → compteurs conservés tels quels
--   - date qui recule           → tout est ignoré (client incohérent)
--   - jour suivant (diff = 1)   → streak + 1
--   - trou (diff > 1)           → streak repart à 1
--   - chaque nouveau jour       → total_login_days + 1
--
-- IDEMPOTENT : rejouable sans erreur.
--
-- ── ROLLBACK ─────────────────────────────────────────────────────────────────
-- DROP TRIGGER IF EXISTS trg_track_login_day ON user_xp;
-- DROP FUNCTION IF EXISTS fn_track_login_day();
-- ALTER TABLE user_xp DROP COLUMN IF EXISTS total_login_days;
-- ─────────────────────────────────────────────────────────────────────────────

BEGIN;

-- ── 1. Nombre total de jours de connexion (distincts, pas forcément consécutifs)
ALTER TABLE user_xp
  ADD COLUMN IF NOT EXISTS total_login_days INTEGER NOT NULL DEFAULT 0
  CHECK (total_login_days >= 0);

-- ── 2. Trigger : streak + total_login_days gérés PAR LE SERVEUR ─────────────
CREATE OR REPLACE FUNCTION fn_track_login_day()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
DECLARE
  diff INTEGER;
BEGIN
  IF TG_OP = 'INSERT' THEN
    -- Ligne créée au signup (sans date) ou premier login.
    IF NEW.last_active_date IS NOT NULL THEN
      NEW.streak           := 1;
      NEW.total_login_days := 1;
    ELSE
      NEW.streak           := 0;
      NEW.total_login_days := 0;
    END IF;
    RETURN NEW;
  END IF;

  -- UPDATE sans changement de jour (ex: simple gain de points) :
  -- les compteurs serveur font foi, on ignore ce que le client envoie.
  IF NEW.last_active_date IS NOT DISTINCT FROM OLD.last_active_date THEN
    NEW.streak           := COALESCE(OLD.streak, 0);
    NEW.total_login_days := COALESCE(OLD.total_login_days, 0);
    RETURN NEW;
  END IF;

  -- Premier login jamais enregistré.
  IF OLD.last_active_date IS NULL THEN
    NEW.streak           := 1;
    NEW.total_login_days := COALESCE(OLD.total_login_days, 0) + 1;
    RETURN NEW;
  END IF;

  -- Date qui recule ou effacée : client incohérent, on ne touche à rien.
  IF NEW.last_active_date IS NULL OR NEW.last_active_date < OLD.last_active_date THEN
    NEW.last_active_date := OLD.last_active_date;
    NEW.streak           := COALESCE(OLD.streak, 0);
    NEW.total_login_days := COALESCE(OLD.total_login_days, 0);
    RETURN NEW;
  END IF;

  -- Nouveau jour.
  diff := NEW.last_active_date - OLD.last_active_date;
  IF diff = 1 THEN
    NEW.streak := COALESCE(OLD.streak, 0) + 1;   -- jour consécutif
  ELSE
    NEW.streak := 1;                              -- streak cassé
  END IF;
  NEW.total_login_days := COALESCE(OLD.total_login_days, 0) + 1;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_track_login_day ON user_xp;
CREATE TRIGGER trg_track_login_day
  BEFORE INSERT OR UPDATE ON user_xp
  FOR EACH ROW EXECUTE FUNCTION fn_track_login_day();

-- ── 3. Backfill best-effort des utilisatrices existantes ────────────────────
-- L'historique des logins n'était pas journalisé avant cette migration ; on
-- initialise total_login_days au streak courant (minimum crédible : elles se
-- sont connectées au moins autant de jours que leur streak).
UPDATE user_xp
SET total_login_days = GREATEST(
      streak,
      CASE WHEN last_active_date IS NULL THEN 0 ELSE 1 END)
WHERE total_login_days = 0;

COMMIT;
