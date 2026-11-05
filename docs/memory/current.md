# Current state

Last updated 2026-11-05 (end of the second session, late). History in `log.md`.

## Where the product stands

Release 1 is built, applied to the hosted project and installed on the owner's phone
(build 27). Staff sign in by email with a forgot-password flow; the L5a Classic badge is the
logo and launcher icon; the record-payment screen offers 500 or 800. The owner has signed
in on the device; a full walkthrough against hosted is still the next step.

| Area | State |
|---|---|
| `be/` | 8 migrations (`identity`, `trainees_sessions`, `attendance_trials`, `fees_reports`, `harden_profiles`, `email_sign_in`, `profile_on_metadata`, `fee_tier_800`), pgTAP 523, seed (email accounts), Edge Function `admin-staff` v2 (by email). All on hosted except `fee_tier_800` (B-11). |
| `fe/` | Theme A kit, config, errors, email auth + forgot password, shell, Today, Trainees, Trials, Fees (compact record screen, 500/800), Staff admin by email, brand badge + launcher icon. Baseline: analyze 0, `flutter test` 383 (+54 proofs). Release signing with the upload keystore; app name "Boxing Club". |
| Device | Build 27 installed (model I2214, wireless adb). Reinstall after every landed app run. |
| Hosted | Project `qgqmnaxdxuezjlexlfpw`. Admin by email (login in `creds.md`). Advisors: no RLS gaps. Migration history uses MCP timestamps (B-10). `fee_tier_800` not applied (B-11). |
| `docs/` | Review log R1-01..R1-07, R2-01..R2-07 (all fixed except R1-03, R1-04 as backlog B-05, B-06). Backlog A-08..A-11, B-05, B-06, B-09, B-10 open. |

## Blocked on the owner

1. Hosted dashboard: turn off "Allow new users to sign up"; in Email Templates, "Reset
   Password" must include {{ .Token }} so the forgot-password code arrives (otherwise the
   mail carries a link the app cannot use). Phone provider is no longer needed.
1b. Approve the blocked MCP apply of `20261105111738_fee_tier_800.sql` (B-11).
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
