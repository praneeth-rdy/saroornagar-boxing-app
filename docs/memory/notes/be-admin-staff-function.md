# Edge Function admin-staff: things to know (be, 2026-11-05)

- Local checks: phone sign-in needs the Twilio stub (`be-local-phone-login.md`), so the curl run
  signed in email/password check users created through the Auth admin API with `phone` in
  `user_metadata` (the trigger reads it). The admin `createUser({ phone })` works with the
  phone provider off; only phone sign-in is refused.
- GoTrue codes the function relies on: `email_exists` (duplicate email -> BXDUP),
  `user_not_found` (-> BXNTF), `user_banned` on sign-in after a block. The phone lives only
  in `app_metadata.phone` now, so a phone clash is the profiles unique key; GoTrue reports a
  trigger error as a generic 500, so the function checks `profiles.phone` before the create
  and again after a failed one.
- Fixed in `20261105110147_profile_on_metadata` (run 3, task-05): Auth admin `createUser`
  inserts `auth.users` with only `provider`/`providers` in `raw_app_meta_data` and writes the
  custom `app_metadata` in a later UPDATE of the same transaction, so the after-insert trigger
  saw no role. `on_auth_user_app_metadata_changed` now calls `private.ensure_profile` too.
  pgTAP reproduces the order with `tests.create_user_like_gotrue`. Local curl after the fix:
  create without and with phone 200 with a profile, duplicate email 409, phone clash 409.
- Curl recipe: sign in `admin@local.test` at `/auth/v1/token?grant_type=password` with the
  local anon key (`npx supabase status -o env`), then POST to `/functions/v1/admin-staff`
  with `apikey` and `Authorization: Bearer <access_token>`. `psql` is not installed on the
  host; use `docker exec -i supabase_db_saroornagar-boxing psql -U postgres`.
- No local Deno: `npx -y deno@2.9.6 check --no-lock index.ts` (with `DENO_DIR` in /tmp) type
  checks without writing a lockfile or node_modules into the function folder.
- Env: uses the legacy injected `SUPABASE_ANON_KEY` / `SUPABASE_SERVICE_ROLE_KEY` as the
  package says. If hosted legacy API keys are ever disabled, switch to
  `SUPABASE_PUBLISHABLE_KEYS` / `SUPABASE_SECRET_KEYS` (JSON dictionaries).
- Open for the Architect: reset_password does not sign the target out of
  existing sessions; block and the profile update are two calls (idempotent, a retry converges).
