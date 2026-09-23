---
name: flutter-security-review
description: Security review for the Fiteva app's Flutter client and Supabase backend — RLS policies, auth, secure storage, data exposure. Use whenever adding/changing a Supabase table, RLS policy, edge function, auth flow, or any code that reads/writes user data (especially health data like cycle/pregnancy tracking), or when explicitly asked for a security review of this app.
---

# Fiteva Security Review

This app stores sensitive personal health data (menstrual cycle, pregnancy, symptoms) behind Supabase + RLS. Treat RLS policy correctness as the primary attack surface — the Flutter client only holds the public anon key, so **RLS is the only thing standing between one user's data and another's**.

## 1. RLS policy checklist (for every new/changed table)

For each table, confirm all four apply where relevant:
- `ALTER TABLE x ENABLE ROW LEVEL SECURITY;` is present — a table without RLS enabled is world-readable/writable via the anon key regardless of policies defined.
- `SELECT` policy scopes to the owner (`auth.uid() = user_id`) unless the data is intentionally public/shared (e.g. `posts`, `community_events`, reference tables like `programs`/`videos` which use `USING (true)` on purpose).
- `INSERT` policy has a `WITH CHECK` that pins `user_id`/`actor_id` to `auth.uid()` — never trust a client-supplied `user_id` without this, or any authenticated user can write rows attributed to someone else.
- For "actor writes to someone else's row" tables (like `user_notifications`, `partner_join_requests`) — this project's established pattern is: `auth.uid() = actor_id AND actor_id <> user_id` (self-notification blocked, actor identity enforced, but the insert is otherwise trusted — see comment in `supabase/migrations/20260803000000_user_notifications.sql`). Follow this same shape for new actor→recipient tables rather than inventing a new trust model.
- `UPDATE`/`DELETE` policies restrict to the owner (`auth.uid() = user_id` or `organizer_id`) — check `USING` alone is enough, or if the update also needs a `WITH CHECK` to stop the owner from reassigning the row to someone else.
- New enum-like `type`/`status` text columns should have a `CHECK` constraint restricting to a known set of values — an unconstrained free-text `type` column lets a compromised/rogue client write arbitrary data other code branches on.

Cross-check the *actual* live schema before trusting `supabase_schema.sql`: this file has drifted from production before (the `user_notifications` table existed only in `supabase/migrations/*.sql` for a while and was missing from the root schema dump). When auditing, prefer querying `pg_policies`/`information_schema` on the live project, or reading every file under `supabase/migrations/`, over trusting the root dump alone.

## 2. Client-side error handling — don't let silence hide a security failure

This codebase has a deliberate convention of swallowing errors (`catch (_) {}` / `catch (e) { debugPrint(...) }`) in fire-and-forget writes (notifications, joins, likes) to keep the UI optimistic. That's an accepted UX tradeoff — but it means **a broken/missing RLS policy fails completely silently in production**. When adding a new write path:
- Keep the swallow-and-debugPrint convention for consistency, but make sure the `debugPrint` actually includes the exception (`$e`), not a generic message — it's the only signal anyone will have.
- Never silently swallow errors on a *read* that gates access control decisions (e.g. "is this user a pro/admin?") — a failed permission check must fail closed (deny), not silently return a default that happens to allow access.

## 3. Secrets & credentials

- `lib/services/supabase_config.dart` hardcodes the Supabase URL and **anon key** — this is expected and safe (the anon key is meant to be public; it's not a secret, RLS is the actual boundary). Flag it only if a **service_role key** or any key with elevated/bypass-RLS privileges ever appears in Flutter code, an asset, or a committed config file — that must never ship to a client.
- Check `.gitignore` covers any `.env`, `google-services.json`/`GoogleService-Info.plist` if they contain non-public keys, and CI config (`codemagic.yaml`) for secrets pulled from environment/vault rather than hardcoded.
- Session tokens: this app already stores the Supabase session via `flutter_secure_storage` (`SecureSessionStorage`, Keystore/Keychain-backed) instead of `SharedPreferences` — keep any new persisted auth/session-like state (API tokens, refresh tokens) on this same secure-storage path, not `shared_preferences`.

## 4. Input handling

- All DB access in this app goes through the Supabase query builder (`SupabaseConfig.table(...).select()/.insert()/.eq()`), which parameterizes values — don't introduce raw string-interpolated SQL (e.g. via `rpc` with concatenated strings) for user-supplied input.
- File uploads (event images, avatars via Cloudinary/Supabase Storage) — check the storage bucket policy restricts writes to the authenticated user's own folder (`(storage.foldername(name))[1] = auth.uid()::text`, matching the existing `event-images` bucket policies) before adding a new bucket.
- User-generated text (post/comment/event content) rendered back in the UI — this is Flutter (`Text` widgets), not a WebView, so standard XSS isn't the concern; the concern is unbounded length/size causing UI or storage issues — check for reasonable length limits on free-text fields if none exist.

## 5. Auth flow

- Auth uses `AuthFlowType.pkce` (`supabase_config.dart`) — keep PKCE for any new auth entry point (social login, magic link) rather than the implicit flow.
- Any screen/action gated to "own data only" must check both client-side (don't show the action) **and** rely on RLS server-side — never rely on the client-side check alone, since API calls can be replayed directly against Supabase with a valid session from any device.

## 6. When reviewing a diff

Report findings ranked: (1) missing/wrong RLS `WITH CHECK` letting a user write/read another user's data — critical; (2) missing `ENABLE ROW LEVEL SECURITY` on a new table — critical; (3) service-role or other privileged key reachable from client code — critical; (4) permission check that fails open on error — high; (5) unconstrained `type`/`status` columns, missing length limits — low/medium. Don't flag the existing swallow-errors-and-debugPrint pattern itself, or the public anon key in `supabase_config.dart` — both are established, intentional conventions in this codebase.
