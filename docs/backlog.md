# Backlog

Prioritised work with status. IDs: `S-nn` setup, `A-nn` app (`fe`), `B-nn` backend (`be`),
`D-nn` open decisions. Status: todo | in progress | done (date) | blocked (on what).

## Setup

| ID | Item | Status |
|---|---|---|
| S-01 | Monorepo scaffold: `fe/` (Flutter, Android), `be/` (supabase init), `docs/`, `.claude/` with the tiered workflow | done (2026-11-05) |
| S-02 | Design directions canvas for the owner to pick from | done (2026-11-05), decision pending (D-01) |
| S-03 | Requirements interview, broad to narrow, recorded in `product.md` | in progress |
| S-04 | Hosted Supabase project: fill `fe/config/*.json`, add `project_ref` to `.mcp.json`, link the CLI | blocked on the owner (project ref, publishable key, access token or `supabase login`) |
| S-05 | Android application id | done (2026-11-05), `com.saroornagarboxing.app` |
| S-06 | Hosted dashboard: disable public sign-ups, enable the Phone provider with confirmations off, enable leaked-password protection if the plan allows | blocked on the owner (admin user created 2026-11-05 through the MCP) |

## Backend

| ID | Item | Status |
|---|---|---|
| B-01 | Identity, helpers, profiles (`20261105074646_identity.sql`) | done (2026-11-05), applied to hosted 2026-11-05 |
| B-02 | Trainees, sessions, photo bucket (`20261105075401_trainees_sessions.sql`) | done (2026-11-05), applied to hosted 2026-11-05 |
| B-03 | Attendance, trial bookings (`20261105080014_attendance_trials.sql`) | done (2026-11-05), applied to hosted 2026-11-05 |
| B-04 | Fee payments, reports (`20261105080602_fees_reports.sql`) | done (2026-11-05), applied to hosted 2026-11-05 |
| B-05 | `book_trial`: refuse a batch that has already ended today; consider an anon rate limit | done (2026-11-05), `20261105160639_backlog_sweep.sql`; no rate limit beyond the unique key; not yet applied to hosted |
| B-06 | Decide whether past rosters and reports should include trainees who are now inactive | done (2026-11-05), `20261105160639_backlog_sweep.sql`: monthly summary keeps inactive students with marks that month; fee status and roster stay active only; not yet applied to hosted |
| B-07 | Edge Function `admin-staff` (create, reset_password, set_blocked) | done (2026-11-05), deployed 2026-11-05 (version 1) |
| B-08 | Harden profile creation (app_metadata role) and revoke anon select (`20261105081756_harden_profiles.sql`) | done (2026-11-05), applied to hosted |
| B-09 | Merge `profiles_select_own` and `profiles_select_staff` into one policy (performance advisor: multiple permissive policies) | done (2026-11-05), `profiles_select_staff_or_own` in `20261105160639_backlog_sweep.sql`; not yet applied to hosted |
| B-13 | `trainee_attendance_history` returns no `starts_at`, so grouped logs show an extra session as "extra" without its time; add the time in a migration and show it in the app | done (2026-11-05), `20261105160639_backlog_sweep.sql`; not yet applied to hosted; app side done (2026-11-05): `AttendanceRecord.startsAt`/`endsAt`, "Morning and extra 4:00 pm" |
| B-12 | Server messages say "trainee" ("This trainee is inactive", "Trainee not found"); the app now says Student. Reword in a migration. | done (2026-11-05), `20261105160639_backlog_sweep.sql`; not yet applied to hosted; app side done (2026-11-05): `AttendanceRecord.startsAt`/`endsAt`, "Morning and extra 4:00 pm" |
| B-11 | Apply `fee_tier_800`, `summary_held_sessions`, `unmark_attendance` to hosted | done (2026-11-05) |
| B-10 | Hosted migration history carries MCP timestamps, not file names; run `supabase migration repair` before any `db push` | todo (only if db push is ever used) |

## App

| ID | Item | Status |
|---|---|---|
| A-01 | Foundation: config, Supabase, errors, theme A, widget kit, proofs harness | done (2026-11-05) |
| A-02 | Sign-in, blocked state, tab shell, guards | done (2026-11-05) |
| A-03 | Today: sessions of the day, roster, mark attendance, mark remaining absent | done (2026-11-05) |
| A-04 | Trainees: list, add, edit, status, photo, attendance history, fee history | done (2026-11-05) |
| A-05 | Trials: public booking screen, staff list of upcoming bookings | done (2026-11-05) |
| A-06 | Fees: record payment, fee status list; monthly attendance summary | done (2026-11-05) |
| A-07 | Staff admin: create, edit, block, reset password (admin only) | done (2026-11-05) |
| A-08 | Trainee photos: delete the old storage object when a photo is replaced or removed (orphans stay in the bucket today) | done (2026-11-05) |
| A-09 | An admin who renames themselves sees the old name on More until the next load (`currentProfileProvider` is not invalidated to avoid blanking the shell) | done (2026-11-05) |
| A-10 | Expired-JWT gateway 401 on `admin-staff` maps to the unknown error; map it to a sign-in-again state | done (2026-11-05): staff actions sign out |
| A-11 | `pumpApp` has no router option; widget tests of screens that call `context.canPop()` wrap their own GoRouter | done (2026-11-05) |

## Open decisions

| ID | Decision | Options | Status |
|---|---|---|---|
| D-01 | Design direction | A Ivory and Graphite | decided 2026-11-05 |
| D-02 | First scope | Guest trial booking + coach/staff/admin app; no trainee view | decided 2026-11-05 |
| D-03 | Hosted Supabase project | Owner creates it and shares the project ref and publishable key | decided 2026-11-05, waiting on the owner |
| D-04 | Android application id | `com.saroornagarboxing.app` (owner, 2026-11-05); set in run-3 task-19 | decided 2026-11-05 |
| D-05 | Logo and app name | L5a Classic badge chosen 2026-11-05 (canvas https://claude.ai/artifact/FL6oyLDsUSpT7RSx7hQcbb, source `docs/design/logos/project/L5a-Classic.dc.html`); launcher label "Saroornagar Boxing" (owner, 2026-11-05) | decided 2026-11-05 |
