# Current state

Last updated 2026-11-05 (end of the second session). History in `log.md`.

## Where the product stands

Release 1 is built, applied to the hosted project and installed on the owner's phone.
Nothing has been exercised against hosted from the device yet; that walkthrough is the
first thing to do next.

| Area | State |
|---|---|
| `be/` | 5 migrations (`identity`, `trainees_sessions`, `attendance_trials`, `fees_reports`, `harden_profiles`), pgTAP 501 assertions, seed, Edge Function `admin-staff`. All applied to hosted 2026-11-05 through the MCP (`docs/be/architecture.md` Hosted applies). |
| `fe/` | Theme A kit, config, errors, auth, shell, Today, Trainees, Trials (public booking + staff list), Fees and reports, Staff admin. Baseline: `flutter analyze` 0 issues, `flutter test` 321 (plus proofs), release signing with the upload keystore. Proofs under `fe/test/proofs/out/` (gitignored), rendered by `flutter test test/proofs`. |
| Device | Signed release APK (build number = commit count) installed on the owner's phone (model I2214, wireless adb). Rule: reinstall after every landed app run (`.claude/CLAUDE.md` Toolchain). |
| Hosted | Project `qgqmnaxdxuezjlexlfpw`. First admin user exists (login in `creds.md`). Advisors: no RLS gaps (`notes/hosted-advisors-2026-11-05.md`). Migration history uses MCP timestamps (B-10). |
| `docs/` | Review log R1-01..R1-07, R2-01..R2-07 (all fixed except R1-03, R1-04 as backlog B-05, B-06). Backlog A-08..A-11, B-05, B-06, B-09, B-10 open. |

## Blocked on the owner

1. Hosted dashboard: enable the Phone provider (confirmations off) and turn off "Allow new
   users to sign up". Sign-in from the device fails with "phone provider disabled" until the
   first is done.
2. Android application id (D-04): still `com.example.saroornagar_boxing`. Changing it later
   means uninstalling the current build on the phone.
3. Product calls: B-05 (today's ended batch still bookable), B-06 (inactive trainees drop off
   past rosters and reports), `product.md` open question 7 (fee status semantics).
4. Back up `fe/android/keystore/upload-keystore.jks` (passwords in `creds.md`).

## Resume checklist

1. `git status` clean? If not, the last fix (staff list Blocked chip on the name line) or
   the final commit did not land; check `docs/memory/log.md` top entry.
2. Walk the app on the device against hosted with the admin login: sign in, add a trainee,
   mark attendance, book a trial from the sign-in link, record a payment, add a coach.
   Log every defect in `docs/review-log.md` as R3-nn and fix through a developer package.
3. Then the open backlog items, smallest first (A-11, B-09, A-08, A-09, A-10).
