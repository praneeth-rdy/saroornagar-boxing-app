# Task 05 - Edge Function `admin-staff`

- **Run:** `.claude/handoffs/2026-11-05-release-1-run-1/`
- **Area:** be
- **Depends on:** task-01
- **Worker:** developer (Opus)
- **Tests:** no (developer self-checks; see Verification)
- **Schema change approved by the owner:** 2026-11-05 (function design in the approved proposal: `create_staff`, `reset_staff_password`, `set_staff_blocked` as an Edge Function using the service role)
- **Hosted apply:** on the owner's say-so, `npx supabase functions deploy admin-staff` or the MCP `deploy_edge_function`

## Goal
An admin creates a coach or admin account (phone + password), resets any staff member's
password, and blocks or unblocks access, from the app, without the service role ever
reaching the app.

## Context the worker needs
- `be/CLAUDE.md` (no secrets; server decides). `plan.md`: phone format, phone auth without an
  SMS provider, blocking semantics (profile flag plus auth ban).
- Load the `supabase` skill (Edge Functions section) before writing TypeScript.
- Task-01 defines `profiles` (`role`, `is_blocked`) and `private.normalize_phone` (not
  callable from the function; re-implement the same rule in TypeScript).

## Files
- `be/supabase/functions/admin-staff/index.ts` - create
- `be/supabase/functions/admin-staff/deno.json` - create (if needed for imports)
- `be/supabase/config.toml` - modify - `[functions.admin-staff] verify_jwt = true`
- `docs/be/architecture.md` - modify - Edge Functions section

## Spec
POST only, JSON body `{ "action": "create" | "reset_password" | "set_blocked", ... }`.
Env: `SUPABASE_URL`, `SUPABASE_ANON_KEY`, `SUPABASE_SERVICE_ROLE_KEY` (injected by Supabase; never written anywhere).
1. Build a user client from the request `Authorization` header with the anon key; `getUser()`; missing or invalid -> 401 `{ "code": "BXPRM", "message": "Sign in again" }`.
2. With the service-role client, read `profiles` for that user; not `admin` or `is_blocked` -> 403 `{ "code": "BXPRM", "message": "Only an admin can manage staff" }`.
3. Validate the body; any failure -> 400 `{ "code": "BXVAL", "message": "<what to fix>" }`:
   - `create`: `full_name` (2-80 chars), `phone` (normalize: digits only, 10 -> prefix 91, 12 starting 91), `password` (8-72 chars), `role` (`admin` | `coach`). `auth.admin.createUser({ phone, password, phone_confirm: true, user_metadata: { full_name, role } })`. Duplicate phone -> 409 `{ "code": "BXDUP", "message": "A staff member with this number already exists" }`. Returns 200 `{ "profile": <profiles row> }` (the task-01 trigger creates the row).
   - `reset_password`: `user_id` (uuid), `password` (8-72). Target must have a profile (404 `BXNTF`). `auth.admin.updateUserById(user_id, { password })`. Returns `{ "ok": true }`.
   - `set_blocked`: `user_id`, `blocked` (boolean). Target must exist (`BXNTF`); target is the caller -> 400 `BXVAL "You cannot block yourself"`. `auth.admin.updateUserById(user_id, { ban_duration: blocked ? "876000h" : "none" })` then `update profiles set is_blocked = blocked`. Returns `{ "profile": <row> }`.
4. Unknown action -> 400 `BXVAL`. Unexpected errors -> 500 `{ "code": "BXERR", "message": "Something went wrong" }` with the real error only in the function log.
CORS headers for the Flutter client (`Authorization, apikey, content-type`). No other endpoint.

## App impact
`supabase.functions.invoke('admin-staff', body: {...})`. Error bodies carry `code` (`BXPRM`, `BXVAL`, `BXNTF`, `BXDUP`, `BXERR`) and `message`; the app maps `code` the same way as SQLSTATEs (`BXERR` -> unknown error).

## Out of scope
Any SQL migration. Deleting staff accounts (block instead). Deploying to hosted.

## Acceptance criteria
- [ ] The three actions behave as specified and every error path returns the stated status and `code`.
- [ ] The service role key appears only as `Deno.env.get(...)`.
- [ ] `deno check` (or `npx supabase functions serve` + curl against the local stack with the seeded admin) was run; if neither tool is available, the summary says the function was not executed.
- [ ] `docs/be/architecture.md` lists the function, its actions and error codes.

## Verification
`source ~/.zshrc && cd be && npx supabase functions serve admin-staff --no-verify-jwt` in the background, sign the seeded admin in through the local Auth REST endpoint, curl the three actions, then stop it. Report which of these ran.
