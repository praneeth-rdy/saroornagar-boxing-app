# Plan - release 1, run 1 (backend + app foundation)

Owner approval of the release 1 schema (`docs/memory/notes/schema-proposal-release-1.md`):
2026-11-05, "Consider my approval. Proceed with the implementation."

Run 1a (be, sequential): task-01 identity + helpers, task-02 trainees + sessions,
task-03 attendance + trial bookings, task-04 fee payments + reports, task-05 Edge Function
`admin-staff`. Run 1b (fe, sequential): task-06 foundation (deps, config, Supabase, errors,
theme A, widget kit, proofs harness), task-07 sign-in, blocked state, tab shell and guards.
Run 2 (separate handoff dir): Today, trainees, trials, fees, staff admin screens.

## Decisions fixed for every package

- Phone numbers are stored as digits with the country code and no plus (`919876543210`).
  Input accepts 10 digits (India, prefixed with 91) or 12 digits starting with 91; anything
  else is `BXVAL`. The app shows `+91 98765 43210`.
- Staff sign in with Supabase phone + password (`signInWithPassword(phone, password)`).
  Users are created by the `admin-staff` Edge Function through the Auth admin API with
  `phone_confirm: true`; no SMS provider. Hosted needs the Phone provider enabled with
  confirmations off (owner step, recorded in memory). Local: `[auth.sms] enable_signup =
  true, enable_confirmations = false` in `config.toml`.
- The first admin on hosted is created by the owner in the dashboard (phone + password);
  the Architect then promotes that profile to `admin` through the MCP. Local seed creates
  an admin and a coach for pgTAP and manual runs.
- Club dates are India dates: `private.today()` = `(private.clock() at time zone
  'Asia/Kolkata')::date`. Every `date` column is an India calendar date.
- Blocking: `profiles.is_blocked` makes `private.is_staff()` false, so RLS hides every
  table and every function fails with `BXPRM`. The Edge Function also bans the auth user so
  sessions die. A blocked user can still read their own profile row (the app shows a
  blocked screen).
- `mark_attendance` is an upsert: marking again with another status corrects the record;
  the same status is a no-op. `BXDUP` is reserved for duplicate trial bookings.
- Every write goes through a `security definer` function; `insert/update/delete` are revoked
  from `anon` and `authenticated` on every public table. Reads use RLS select policies.
- pgTAP: `supabase/tests/000_helpers.sql` installs a `tests` schema (committed, no
  rollback); every other test file is `begin; select plan(n); ...; select * from finish();
  rollback;`.
- Session timings fixed: morning 06:00-08:30, evening 17:30-20:00 (`product.md`).
- Fee tier: `private.fee_tier_amount(p_date_of_birth, p_on)` = 500 if age < 15 on `p_on`,
  1000 if >= 15, null when the date of birth is null.
