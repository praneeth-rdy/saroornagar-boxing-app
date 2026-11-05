# Task 05 - Profile creation when app_metadata arrives after the insert

- **Run:** `.claude/handoffs/2026-11-05-release-1-run-3/`
- **Area:** be
- **Depends on:** task-01, task-02
- **Worker:** developer (Opus)
- **Tests:** yes (assistant)
- **Schema change approved by the owner:** 2026-11-05 (same request; no new column, a trigger only)
- **Hosted apply:** on the owner's say-so, migration `<timestamp>_profile_on_metadata.sql`, after `20261105105121_email_sign_in.sql`
- **Owner request this serves:** "Can we do an email-password sign-in instead and add a forgot password option too?" (2026-11-05). The logo work is a separate, unrelated thread.

## Goal
Staff created through the Auth admin API get their profile. GoTrue inserts the `auth.users`
row with only `provider`/`providers` in `raw_app_meta_data` and writes the custom
`app_metadata` in a later update of the same transaction, so the after-insert trigger
never sees the role (review finding R3-02; it broke every `admin-staff` create).

## Context the worker needs
`be/CLAUDE.md`; `docs/memory/notes/be-email-sign-in.md`, `be-admin-staff-function.md`;
migration `20261105105121_email_sign_in.sql` (read only; this package adds a NEW migration
after it, never an edit); `tests/000_helpers.sql`, `010_identity.sql`; `functions/admin-staff/index.ts`.

## Files
- `be/supabase/migrations/<timestamp>_profile_on_metadata.sql` - create (`npx supabase migration new profile_on_metadata`)
- `be/supabase/tests/000_helpers.sql` - modify - `tests.create_user_like_gotrue(p_email, p_password, p_full_name, p_role)` that inserts the auth user with only provider keys, then updates `raw_app_meta_data` to add `role` and `full_name` (two statements, like GoTrue)
- `be/supabase/tests/010_identity.sql` - modify (assistant) - the cases below
- `docs/be/architecture.md`, `docs/memory/notes/be-admin-staff-function.md` - modify

## Spec
- In the new migration, extract the profile insert into `private.ensure_profile(p_user auth.users) returns void`:
  reads role and full_name from `p_user.raw_app_meta_data`, email from `p_user.email`,
  phone as task-01 defined; returns without inserting when the role is not admin/coach or
  the email is null; `insert ... on conflict (id) do nothing`.
- `create or replace function private.handle_new_user()` so it calls `private.ensure_profile(new)`.
- New `private.handle_user_app_metadata_change() returns trigger` calling
  `private.ensure_profile(new)`; trigger `on_auth_user_app_metadata_changed after update of
  raw_app_meta_data on auth.users for each row when (old.raw_app_meta_data is distinct from
  new.raw_app_meta_data)`.
- A later change of `app_metadata.role` on an existing profile changes nothing
  (`profiles.role` stays the source of truth after creation).
- The Edge Function needs no code change; re-run its curl check (create with and without a
  phone now returns 200 with a profile; duplicate email 409; phone clash 409).

## App impact
None beyond task-02's contract.

## Out of scope
Any other trigger or table. Hosted apply.

## Acceptance criteria
- [ ] pgTAP: `create_user_like_gotrue` yields a profile with the right email, name and role;
      a later role change in app_metadata does not alter `profiles.role`; the direct-insert
      helper still works; a user whose metadata update carries no role gets no profile.
- [ ] `npx supabase db reset` and `npx supabase test db` pass.
- [ ] `npx supabase functions serve admin-staff` + curl: create (with and without phone)
      returns 200 with a profile; say which ran.
- [ ] `docs/be/architecture.md` lists the new trigger and helper.

## Verification
`source ~/.zshrc && cd be && npx supabase db reset && npx supabase test db`; the functions serve + curl sequence from `docs/memory/notes/be-admin-staff-function.md`.
