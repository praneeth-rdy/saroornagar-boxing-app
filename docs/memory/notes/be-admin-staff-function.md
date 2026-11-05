# Edge Function admin-staff: things to know (be, 2026-11-05)

- Local checks: phone sign-in needs the Twilio stub (`be-local-phone-login.md`), so the curl run
  signed in email/password check users created through the Auth admin API with `phone` in
  `user_metadata` (the trigger reads it). The admin `createUser({ phone })` works with the
  phone provider off; only phone sign-in is refused.
- GoTrue codes the function relies on: `phone_exists` (duplicate phone -> BXDUP),
  `user_not_found` (-> BXNTF), `user_banned` on sign-in after a block.
- No local Deno: `npx -y deno@2.9.6 check --no-lock index.ts` (with `DENO_DIR` in /tmp) type
  checks without writing a lockfile or node_modules into the function folder.
- Env: uses the legacy injected `SUPABASE_ANON_KEY` / `SUPABASE_SERVICE_ROLE_KEY` as the
  package says. If hosted legacy API keys are ever disabled, switch to
  `SUPABASE_PUBLISHABLE_KEYS` / `SUPABASE_SECRET_KEYS` (JSON dictionaries).
- Open for the Architect: `create` still puts `role` in `user_metadata`
  (`be-open-signup-role-escalation.md`); reset_password does not sign the target out of
  existing sessions; block and the profile update are two calls (idempotent, a retry converges).
