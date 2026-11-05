# Task 08 - Harden profile creation and anon grants

- **Run:** `.claude/handoffs/2026-11-05-release-1-run-1/`
- **Area:** be
- **Depends on:** task-05
- **Worker:** developer (Opus)
- **Tests:** yes (assistant)
- **Schema change approved by the owner:** 2026-11-05 (same proposal; this package changes no table, only the trigger body and grants). Review findings R1-01 and R1-02 in `docs/review-log.md`.
- **Hosted apply:** on the owner's say-so, migration `<timestamp>_harden_profiles.sql`, together with the four earlier ones

## Goal
Nobody can become staff by signing up: a profile exists only for users the admin API
created with a staff role in `app_metadata`, and the anon key has no table-level read on
anything.

## Context the worker needs
- `be/CLAUDE.md`; `docs/memory/notes/be-open-signup-role-escalation.md` (the finding);
  `docs/memory/notes/be-pgtap-helpers.md`; migration `20261105074646_identity.sql`
  (`private.handle_new_user`); Edge Function `functions/admin-staff/index.ts`; `seed.sql`;
  `tests/000_helpers.sql`; the anon assertions in `tests/010` to `040`.

## Files
- `be/supabase/migrations/<timestamp>_harden_profiles.sql` - create
- `be/supabase/functions/admin-staff/index.ts` - modify - `create` sets `app_metadata`
- `be/supabase/seed.sql` - modify - staff role in `raw_app_meta_data`
- `be/supabase/tests/000_helpers.sql` - modify - `tests.create_user` sets `raw_app_meta_data`; new `tests.create_user_without_role(p_phone, p_password)`
- `be/supabase/tests/010_identity.sql` .. `040_fees_reports.sql` - modify - anon direct select now expects `42501`; `plan(n)` kept correct
- `docs/be/architecture.md`, `docs/memory/notes/be-open-signup-role-escalation.md` - modify - record the rule; shrink the note to the hosted dashboard steps that remain

## Spec
- `create or replace function private.handle_new_user()`: read `v_role := new.raw_app_meta_data ->> 'role'`; if `v_role` is not `admin` or `coach`, `return new` without inserting. Otherwise insert with `full_name = coalesce(nullif(trim(new.raw_app_meta_data ->> 'full_name'), ''), nullif(trim(new.raw_user_meta_data ->> 'full_name'), ''), nullif(new.phone, ''), 'Staff')`, `phone` as before, `role = v_role::public.staff_role`. `raw_user_meta_data` is never read for the role. One-line comment: only the admin API can write `app_metadata`.
- `revoke select on public.profiles, public.trainees, public.sessions, public.attendance, public.trial_bookings, public.fee_payments from anon;` `book_trial` and `my_trial_bookings` stay `security definer` and keep working for anon.
- `admin-staff` `create`: `auth.admin.createUser({ phone, password, phone_confirm: true, app_metadata: { role, full_name }, user_metadata: { full_name } })`. Keep `set_blocked` and `reset_password` as they are. Re-run `deno check`.
- `seed.sql` and `tests.create_user`: put `role` and `full_name` into `raw_app_meta_data` alongside the `provider`/`providers` keys GoTrue expects; keep `full_name` in `raw_user_meta_data` as well.
- The profile `role` stays the source of truth after creation (`update_staff` changes it); `app_metadata.role` is only read at sign-up. Say so in `architecture.md`.

## App impact
None for the app's contracts. Non-staff users (no profile) get `BXNTF` from `current_profile`; the app's shell shows the blocked/not-staff state for `BXNTF` as well as `is_blocked` (task-07 already handles `PermissionException`; the fe package for run 2 maps `NotFoundException` on `current_profile` to the same screen with the copy "This account is not set up for staff.").

## Out of scope
Any table or policy change. Rate limiting. Hosted apply or deploy.

## Acceptance criteria
- [ ] A user created with `raw_app_meta_data.role = 'coach'` gets a coach profile; with `'admin'`, an admin profile; a user whose only role is in `raw_user_meta_data` (`admin`) gets no profile; a user with no role gets no profile.
- [ ] Anon direct `select` on each of the six tables raises `42501`; `book_trial` and `my_trial_bookings` still work for anon.
- [ ] `npx supabase db reset` and `npx supabase test db` pass; `deno check` on the Edge Function passes.
- [ ] `docs/be/architecture.md` states the rule; the escalation note lists only the hosted dashboard steps (disable public sign-ups, enable the Phone provider, confirmations off).

## Verification
`source ~/.zshrc && cd be && npx supabase db reset && npx supabase test db`; `deno check supabase/functions/admin-staff/index.ts` if deno is on PATH. Assistant adds the four profile-creation cases to `tests/010_identity.sql` and updates every anon select assertion.
