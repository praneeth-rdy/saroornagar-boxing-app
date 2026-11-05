# Task 02 - Edge Function `admin-staff` by email

- **Run:** `.claude/handoffs/2026-11-05-release-1-run-3/`
- **Area:** be
- **Depends on:** task-01
- **Worker:** developer (Opus)
- **Tests:** no (developer self-checks)
- **Schema change approved by the owner:** 2026-11-05 (same request)
- **Hosted apply:** on the owner's say-so, `deploy_edge_function admin-staff`

## Goal
An admin creates staff by email and password (phone optional), resets passwords and blocks
access as before.

## Context the worker needs
`be/CLAUDE.md`; `plan.md`; `functions/admin-staff/index.ts`; task-01's trigger (email from
`auth.users.email`, phone from `app_metadata.phone`); `docs/memory/notes/be-admin-staff-function.md`.

## Files
- `be/supabase/functions/admin-staff/index.ts` - modify
- `docs/be/architecture.md`, `docs/memory/notes/be-admin-staff-function.md` - modify

## Spec
- `create`: body `full_name`, `email`, `password`, `role`, optional `phone`. Validate the
  email (trim, lower, same pattern as the SQL helper; `BXVAL 'Enter a valid email
  address'`), the phone when present (same rule as before). `auth.admin.createUser({
  email, password, email_confirm: true, app_metadata: { role, full_name, phone? },
  user_metadata: { full_name } })`. `email_exists` -> 409 `BXDUP 'A staff member with this
  email already exists'`; a phone unique violation surfaced by the trigger -> 409 `BXDUP
  'This number belongs to another staff member'`.
- `reset_password`, `set_blocked`: unchanged.
- Remove the phone-only paths and messages that no longer apply.

## App impact
`functions.invoke('admin-staff', body: {action: 'create', full_name, email, password, role, phone?})` -> `{profile}`; `BXDUP` messages above.

## Out of scope
SQL changes (task-01). Deploying to hosted.

## Acceptance criteria
- [ ] `deno check` passes if deno is available; otherwise `npx supabase functions serve`
      plus curl against the local stack with the seeded email admin covers create (with and
      without phone), duplicate email, reset_password, set_blocked. Say which ran.
- [ ] No secret in the source beyond `Deno.env.get`.
- [ ] `docs/be/architecture.md` Edge Functions section updated.

## Verification
As in run-1 task-05, with the email admin from `seed.sql`.
