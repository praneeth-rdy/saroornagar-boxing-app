# Task 01 - Identity, shared helpers, profiles

- **Run:** `.claude/handoffs/2026-11-05-release-1-run-1/`
- **Area:** be
- **Depends on:** none
- **Worker:** developer (Opus)
- **Tests:** yes (assistant)
- **Schema change approved by the owner:** 2026-11-05, "Consider my approval. Proceed with the implementation."
- **Hosted apply:** on the owner's say-so, migration `<timestamp>_identity.sql`

## Goal
The backend has its shared helpers, the `profiles` table that gives every auth user a role,
the admin-only `update_staff` function, local seed accounts and the pgTAP helper schema, so
every later package can build on `private.is_staff()`, `private.fail()` and `private.clock()`.

## Context the worker needs
- `be/CLAUDE.md`: SQL conventions, error contract, non-negotiable rules (RLS on every table,
  server decides, no secrets). `plan.md` in this folder: phone format, India dates, blocking,
  pgTAP layout.
- Load the `supabase-postgres-best-practices` skill before writing SQL.
- `supabase/config.toml`: set `[auth.sms] enable_signup = true` and `enable_confirmations =
  false` so phone + password sign-in works locally. Do not change ports.

## Files
- `be/supabase/migrations/<timestamp>_identity.sql` - create - helpers, enum, profiles, trigger, update_staff
- `be/supabase/config.toml` - modify - the two `[auth.sms]` keys only
- `be/supabase/seed.sql` - create - idempotent local accounts
- `be/supabase/tests/000_helpers.sql` - create - `tests` schema helpers (committed, no rollback)
- `docs/be/architecture.md` - modify - table and function rows, State paragraph

## Spec

### Schema `private` and helpers
- `create schema if not exists private;` `revoke all on schema private from public, anon, authenticated;`
- `private.fail(p_code text, p_message text) returns void`: `raise exception using errcode = p_code, message = p_message`.
- `private.clock() returns timestamptz stable`: `coalesce(nullif(current_setting('private.clock', true), '')::timestamptz, now())`.
- `private.today() returns date stable`: `(private.clock() at time zone 'Asia/Kolkata')::date`.
- `private.set_updated_at() returns trigger`: sets `new.updated_at = private.clock()`.
- `private.normalize_phone(p_phone text) returns text immutable`: strip every non-digit; 10 digits -> prefix `91`; 12 digits starting `91` -> as is; otherwise `private.fail('BXVAL', 'Enter a 10-digit mobile number')`.
- `private.is_staff() returns boolean stable security definer set search_path = ''`: true when a `public.profiles` row with `id = auth.uid()` exists and `is_blocked = false`.
- `private.is_admin() returns boolean`: same plus `role = 'admin'`.
- Grant `execute` on `private.is_staff`, `private.is_admin` to `authenticated` (RLS policies call them); every other `private` function stays unexposed (`revoke execute ... from public, anon, authenticated` as appropriate).

### `public.staff_role` enum: `admin`, `coach`.

### `public.profiles`
Columns: `id uuid primary key references auth.users(id) on delete cascade`, `full_name text not null check (length(trim(full_name)) between 2 and 80)`, `phone text not null unique`, `role public.staff_role not null default 'coach'`, `is_blocked boolean not null default false`, `created_at timestamptz not null default private.clock()`, `updated_at timestamptz not null default private.clock()`. Trigger `profiles_set_updated_at` before update.
- RLS enabled. Policies: `profiles_select_own` (select, authenticated, `using (id = auth.uid())`), `profiles_select_staff` (select, authenticated, `using (private.is_staff())`). No insert/update/delete policies. `revoke insert, update, delete on public.profiles from anon, authenticated`.
- `private.handle_new_user() returns trigger security definer set search_path = ''`: inserts the profile with `full_name = coalesce(new.raw_user_meta_data->>'full_name', new.phone, 'Staff')`, `phone = coalesce(new.phone, new.raw_user_meta_data->>'phone')`, `role = coalesce((new.raw_user_meta_data->>'role')::public.staff_role, 'coach')`. Trigger `on_auth_user_created` after insert on `auth.users`. Also `private.handle_user_phone_change()` after update of `phone` on `auth.users` keeps `profiles.phone` in sync.

### `public.update_staff(p_user_id uuid, p_full_name text, p_role public.staff_role) returns public.profiles`
`security definer set search_path = ''`, granted to `authenticated` only. Order: `private.is_admin()` else `BXPRM 'Only an admin can edit staff'`; target exists else `BXNTF 'Staff member not found'`; `p_user_id = auth.uid() and p_role <> current role` -> `BXVAL 'You cannot change your own role'`; name check -> `BXVAL 'Enter a name between 2 and 80 characters'`; update and return the row.

### `public.current_profile() returns public.profiles` 
`security definer set search_path = ''`, granted to `authenticated`: returns the caller's own row (works when blocked), `BXNTF 'Profile not found'` when missing.

### `seed.sql`
Idempotent (`on conflict do nothing` keyed on a fixed uuid): two auth users created by inserting into `auth.users` and `auth.identities` the way the pgTAP helper does (`extensions.crypt(password, extensions.gen_salt('bf'))`, `phone_confirmed_at = now()`, `aud = 'authenticated'`, `role = 'authenticated'`, `raw_user_meta_data` with `full_name` and `role`): admin `919000000001` / `admin-local-1234`, coach `919000000002` / `coach-local-1234`. Local only; the file says so in a one-line comment.

### `tests/000_helpers.sql`
No transaction wrapper. `create schema if not exists tests;` plus: `tests.create_user(p_phone text, p_password text, p_full_name text, p_role text) returns uuid` (same insert as the seed, returns the id, idempotent on phone), `tests.authenticate_as(p_phone text)` (sets `request.jwt.claims` to `{"sub": "<id>", "role": "authenticated"}` and `role authenticated`), `tests.authenticate_as_anon()`, `tests.clear_auth()` (`reset role`, clear the claim), `tests.set_clock(p_at timestamptz)` (`set_config('private.clock', ...)`, local to the transaction), `tests.user_id(p_phone text) returns uuid`. Grant usage on schema `tests` to public.

## App impact
- `rpc('current_profile')` -> `{id, full_name, phone, role, is_blocked, created_at, updated_at}`; `BXNTF` when the user has no profile.
- `rpc('update_staff', {p_user_id, p_full_name, p_role})` -> profile row; `BXPRM`, `BXNTF`, `BXVAL`.
- `select * from profiles` lists staff for admins and coaches (coaches read all staff rows too).
- Blocked users: every other table and function returns `BXPRM`/nothing; the app routes to a blocked screen when `is_blocked` is true.

## Out of scope
Creating auth users or resetting passwords from SQL (Edge Function, task-05). Trainees, sessions, attendance, bookings, fees (tasks 02-04). Any hosted apply.

## Acceptance criteria
- [ ] `npx supabase db reset` applies the migration and the seed without error.
- [ ] `profiles` has RLS with the two named select policies; direct writes revoked.
- [ ] `update_staff` fails `BXPRM` for a coach, `BXNTF` for a missing id, `BXVAL` for a self role change, succeeds for an admin.
- [ ] `current_profile` returns the own row for a blocked user.
- [ ] `private.normalize_phone` accepts 10 and 12-digit forms and fails `BXVAL` otherwise.
- [ ] `tests` helpers exist after `supabase test db` starts; `npx supabase test db` passes.
- [ ] `docs/be/architecture.md` rows updated.

## Verification
`source ~/.zshrc && cd be && npx supabase start -x vector,logflare,studio && npx supabase db reset && npx supabase test db`. Assistant writes `tests/010_identity.sql` covering every criterion above with `throws_ok` on the SQLSTATEs, anon denial on `profiles`, and the blocked-user case.
