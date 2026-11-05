# Task 02 - Trainees and sessions

- **Run:** `.claude/handoffs/2026-11-05-release-1-run-1/`
- **Area:** be
- **Depends on:** task-01
- **Worker:** developer (Opus)
- **Tests:** yes (assistant)
- **Schema change approved by the owner:** 2026-11-05, "Consider my approval. Proceed with the implementation."
- **Hosted apply:** on the owner's say-so, migration `<timestamp>_trainees_sessions.sql`

## Goal
Staff keep the trainee roster (with photos) and the club's sessions exist for any day: the
two regular batches appear on demand, extra sessions can be added.

## Context the worker needs
- `be/CLAUDE.md` conventions; `plan.md` decisions (phone format, India dates, writes only
  through functions). Helpers from task-01: `private.fail`, `private.clock`, `private.today`,
  `private.is_staff`, `private.normalize_phone`, `private.set_updated_at`.
- Load the `supabase-postgres-best-practices` skill before writing SQL.

## Files
- `be/supabase/migrations/<timestamp>_trainees_sessions.sql` - create
- `docs/be/architecture.md` - modify - rows for the tables, functions, bucket

## Spec

### Enums
`public.trainee_status` (`active`, `inactive`); `public.session_slot` (`morning`, `evening`, `extra`).

### `public.trainees`
`id uuid primary key default gen_random_uuid()`, `full_name text not null check (length(trim(full_name)) between 2 and 80)`, `phone text null` (normalized), `photo_path text null` (object path in bucket `trainee-photos`), `date_of_birth date null check (date_of_birth > date '1900-01-01')`, `joined_on date null`, `status public.trainee_status not null default 'active'`, `notes text null check (notes is null or length(notes) <= 500)`, `created_by uuid null references public.profiles(id) on delete set null`, `created_at`, `updated_at` (defaults `private.clock()`, trigger `trainees_set_updated_at`). Index `trainees_status_full_name_idx (status, lower(full_name))`.
RLS: `trainees_select_staff` (select, authenticated, `using (private.is_staff())`). Revoke insert/update/delete from anon, authenticated.

Functions (all `security definer set search_path = ''`, granted to `authenticated` only, first line `if not private.is_staff() then perform private.fail('BXPRM', 'Only club staff can do this'); end if;`):
- `public.create_trainee(p_full_name text, p_phone text default null, p_date_of_birth date default null, p_joined_on date default null, p_notes text default null) returns public.trainees`: normalize phone when given (BXVAL from the helper), `date_of_birth` not in the future (`BXVAL 'Date of birth cannot be in the future'`), `joined_on` <= today + 1 day (`BXVAL 'Joining date cannot be in the future'`), name check -> `BXVAL 'Enter a name between 2 and 80 characters'`. Sets `created_by = auth.uid()`.
- `public.update_trainee(p_trainee_id uuid, p_full_name text, p_phone text, p_date_of_birth date, p_joined_on date, p_notes text) returns public.trainees`: same validation; `BXNTF 'Trainee not found'`. Every field is replaced (null clears), so the app sends the full record.
- `public.set_trainee_status(p_trainee_id uuid, p_status public.trainee_status) returns public.trainees`: `BXNTF`; same status is a no-op returning the row.
- `public.set_trainee_photo(p_trainee_id uuid, p_photo_path text) returns public.trainees`: `BXNTF`; path must start with `p_trainee_id::text || '/'` else `BXVAL 'Photo path must be inside the trainee folder'`; null clears.

### Storage bucket `trainee-photos`
`insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types) values ('trainee-photos', 'trainee-photos', false, 2097152, array['image/jpeg','image/png','image/webp']) on conflict (id) do nothing;` Policies on `storage.objects` for `authenticated`, all `bucket_id = 'trainee-photos' and private.is_staff()`: `trainee_photos_select_staff`, `trainee_photos_insert_staff` (with check), `trainee_photos_update_staff`, `trainee_photos_delete_staff`.

### `public.sessions`
`id uuid primary key default gen_random_uuid()`, `session_date date not null`, `slot public.session_slot not null`, `starts_at time not null`, `ends_at time not null check (ends_at > starts_at)`, `created_by uuid null references public.profiles(id) on delete set null`, `created_at timestamptz not null default private.clock()`. Unique index `sessions_regular_slot_key on sessions (session_date, slot) where slot <> 'extra'`. Index `sessions_date_idx (session_date)`.
RLS: `sessions_select_staff` (select, authenticated, `using (private.is_staff())`). Revoke writes.
- `public.ensure_day_sessions(p_date date) returns setof public.sessions`: staff check; if `p_date` is not a Sunday (`extract(isodow from p_date) <> 7`) insert `morning 06:00-08:30` and `evening 17:30-20:00` with `on conflict do nothing` (use the partial unique index via `where not exists`); return every session of that date ordered by `starts_at`. `created_by` is null for auto-created rows.
- `public.add_extra_session(p_date date, p_starts_at time, p_ends_at time) returns public.sessions`: staff check; `p_ends_at <= p_starts_at` -> `BXVAL 'End time must be after the start time'`; `created_by = auth.uid()`.
- `public.delete_extra_session(p_session_id uuid) returns void`: staff check; `BXNTF 'Session not found'`; slot not `extra` -> `BXVAL 'Only extra sessions can be removed'`; any attendance rows -> `BXVAL 'This session already has attendance'` (the `attendance` table lands in task-03; write this check as `exists (select 1 from public.attendance where session_id = p_session_id)` only if that table exists at runtime: implement the check in task-03 instead and leave a one-line comment here saying task-03 adds it). Deletes the row.

## App impact
- `rpc('create_trainee'|'update_trainee'|'set_trainee_status'|'set_trainee_photo')` -> trainee row `{id, full_name, phone, photo_path, date_of_birth, joined_on, status, notes, created_by, created_at, updated_at}`; `select * from trainees` for lists (RLS).
- `rpc('ensure_day_sessions', {p_date})` -> list of `{id, session_date, slot, starts_at, ends_at, created_by, created_at}`; `rpc('add_extra_session')`, `rpc('delete_extra_session')`.
- Photos: upload to `trainee-photos/<trainee_id>/<file>` then `set_trainee_photo`.
- SQLSTATEs: `BXPRM`, `BXNTF`, `BXVAL`.

## Out of scope
Attendance, bookings, fees. Any change to task-01's migration (new file only). Any hosted apply.

## Acceptance criteria
- [ ] Both tables have RLS, named select policies, revoked writes; anon reads nothing; a blocked staff user reads nothing and every function fails `BXPRM`.
- [ ] `ensure_day_sessions` is idempotent (second call creates nothing) and creates nothing on a Sunday.
- [ ] Phone normalization and the date checks fail with `BXVAL`; missing ids fail `BXNTF`.
- [ ] Bucket exists with the four named policies.
- [ ] `npx supabase db reset` and `npx supabase test db` pass; `docs/be/architecture.md` rows updated.

## Verification
As task-01. Assistant writes `tests/020_trainees_sessions.sql` using the `tests` helpers.
