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
| S-05 | Android application id | blocked (D-04) |
| S-06 | Hosted dashboard: disable public sign-ups, enable the Phone provider with confirmations off, create the first admin user | blocked on the owner |

## Backend

| ID | Item | Status |
|---|---|---|
| B-01 | Identity, helpers, profiles (`20261105074646_identity.sql`) | done (2026-11-05), not applied to hosted |
| B-02 | Trainees, sessions, photo bucket (`20261105075401_trainees_sessions.sql`) | done (2026-11-05), not applied to hosted |
| B-03 | Attendance, trial bookings (`20261105080014_attendance_trials.sql`) | done (2026-11-05), not applied to hosted |
| B-04 | Fee payments, reports (`20261105080602_fees_reports.sql`) | done (2026-11-05), not applied to hosted |
| B-05 | `book_trial`: refuse a batch that has already ended today; consider an anon rate limit | todo |
| B-06 | Decide whether past rosters and reports should include trainees who are now inactive | todo (owner) |
| B-07 | Edge Function `admin-staff` (create, reset_password, set_blocked) | done (2026-11-05), not deployed |
| B-08 | Harden profile creation (app_metadata role) and revoke anon select (`20261105081756_harden_profiles.sql`) | done (2026-11-05), not applied to hosted |

## App

| ID | Item | Status |
|---|---|---|
| A-01 | Foundation: config, Supabase, errors, theme A, widget kit, proofs harness | in progress |
| A-02 | Sign-in, blocked state, tab shell, guards | in progress |
| A-03 | Today: sessions of the day, roster, mark attendance, mark remaining absent | todo (run 2) |
| A-04 | Trainees: list, add, edit, status, photo, attendance history, fee history | todo (run 2) |
| A-05 | Trials: public booking screen, staff list of upcoming bookings | todo (run 2) |
| A-06 | Fees: record payment, fee status list; monthly attendance summary | todo (run 2) |
| A-07 | Staff admin: create, edit, block, reset password (admin only) | todo (run 2) |
| A-08 | Trainee photos: delete the old storage object when a photo is replaced or removed (orphans stay in the bucket today) | todo |
| A-09 | An admin who renames themselves sees the old name on More until the next load (`currentProfileProvider` is not invalidated to avoid blanking the shell) | todo |
| A-10 | Expired-JWT gateway 401 on `admin-staff` maps to the unknown error; map it to a sign-in-again state | todo |
| A-11 | `pumpApp` has no router option; widget tests of screens that call `context.canPop()` wrap their own GoRouter | todo |

## Open decisions

| ID | Decision | Options | Status |
|---|---|---|---|
| D-01 | Design direction | A Ivory and Graphite | decided 2026-11-05 |
| D-02 | First scope | Guest trial booking + coach/staff/admin app; no trainee view | decided 2026-11-05 |
| D-03 | Hosted Supabase project | Owner creates it and shares the project ref and publishable key | decided 2026-11-05, waiting on the owner |
| D-04 | Android application id (currently the Flutter default `com.example.saroornagar_boxing`) | | open |
