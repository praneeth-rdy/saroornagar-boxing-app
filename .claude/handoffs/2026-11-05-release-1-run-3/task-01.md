# Task 01 - Profiles by email

- **Run:** `.claude/handoffs/2026-11-05-release-1-run-3/`
- **Area:** be
- **Depends on:** none
- **Worker:** developer (Opus)
- **Tests:** yes (assistant)
- **Schema change approved by the owner:** 2026-11-05, "Can we do an email-password sign-in instead and add a forgot password option too?" (email column, phone optional, as stated back to the owner in chat)
- **Hosted apply:** on the owner's say-so, migration `<timestamp>_email_sign_in.sql`

## Goal
Staff accounts are identified by email: the profile trigger reads the auth user's email,
the phone becomes optional, and the admin can edit a staff member's phone.

## Context the worker needs
`be/CLAUDE.md`; `plan.md` here; migrations `20261105074646_identity.sql` and
`20261105081756_harden_profiles.sql` (current `profiles`, `handle_new_user`,
`handle_user_phone_change`, `update_staff`, `current_profile`); `seed.sql`;
`tests/000_helpers.sql`, `010_identity.sql`. Load `supabase-postgres-best-practices`.

## Files
- `be/supabase/migrations/<timestamp>_email_sign_in.sql` - create
- `be/supabase/seed.sql` - modify - email accounts
- `be/supabase/tests/000_helpers.sql` - modify - `tests.create_user(p_email, p_password, p_full_name, p_role, p_phone default null)`; `tests.authenticate_as(p_email)`; `tests.user_id(p_email)`; `create_user_without_role(p_email, ...)`
- `be/supabase/tests/010_identity.sql` .. `040_fees_reports.sql` - modify - calls to the helpers; new assertions (assistant)
- `be/supabase/config.toml` - modify - `[auth.email] enable_signup = true`, `enable_confirmations = false`; leave `[auth.sms]` as is
- `docs/be/architecture.md` - modify

## Spec
- `alter table public.profiles add column email text`; backfill from `auth.users.email`
  (lower); `alter column email set not null`; `unique (email)`; `alter column phone drop
  not null`; keep `phone unique`. Check `email ~ '^[^@\s]+@[^@\s]+\.[^@\s]+$'`.
- `private.normalize_email(p_email text) returns text immutable`: trim + lower; fails
  `BXVAL 'Enter a valid email address'` when it does not match the pattern.
- `private.handle_new_user()`: same app_metadata rule; inserts `email =
  private.normalize_email(new.email)` (no profile when email is null), `phone =
  nullif(new.phone, '')` or `app_metadata ->> 'phone'` normalized when present.
- Replace `on_auth_user_phone_changed` with `on_auth_user_email_changed` (after update of
  email) keeping `profiles.email` in sync; keep the phone sync trigger too.
- `public.update_staff(p_user_id uuid, p_full_name text, p_role public.staff_role, p_phone text)`:
  new 4-argument function; drop the 3-argument one (`drop function if exists
  public.update_staff(uuid, text, public.staff_role)`; backlog note in the migration
  comment). `p_phone` null clears the phone; otherwise `private.normalize_phone`.
  Same `BXPRM`/`BXNTF`/`BXVAL` rules as before plus `BXDUP 'This number belongs to
  another staff member'` on a phone unique violation. Grants as before.
- `current_profile()` unchanged (returns the row, now with email).
- Seed: admin `admin@local.test` / `admin-local-1234`, coach `coach@local.test` /
  `coach-local-1234`, provider `email`, `email_confirmed_at now()`, identities with
  `provider 'email'` and `identity_data.email`.

## App impact
- `profiles` row gains `email` (string) and `phone` may be null.
- `rpc('update_staff', {p_user_id, p_full_name, p_role, p_phone})`; `BXDUP` on a phone clash.
- Sign-in: `auth.signInWithPassword(email:, password:)`.

## Out of scope
Edge Function (task-02). Any trainee or booking change. Hosted apply.

## Acceptance criteria
- [ ] A user created with an email and an app_metadata role gets a profile with that
      email, lower-cased; a user without an email gets no profile.
- [ ] `update_staff` 4-arg: positive path, phone clear, `BXDUP` on a clash, old rules.
- [ ] `npx supabase db reset` and `npx supabase test db` pass; every test file uses the
      email helpers; `plan(n)` correct.
- [ ] `docs/be/architecture.md` rows updated.

## Verification
`source ~/.zshrc && cd be && npx supabase db reset && npx supabase test db`.
