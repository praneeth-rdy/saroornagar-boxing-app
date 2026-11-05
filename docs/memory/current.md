# Current state

Last updated 2026-11-05 (end of the second session, late). History in `log.md`.

## Where the product stands

Release 1 is built, applied to the hosted project and installed on the owner's phone
(build 34, "Saroornagar Boxing"). Staff sign in by email with a forgot-password flow; L5a
Classic badge and icon; presence-only attendance with confirmed unmark and session reset;
logs grouped by date; monthly attendance = classes attended per student; the app says
"Student" everywhere; compact record-payment with 500 / 800; roll numbers (unique among active students,
suggested gaps-first, editable) on Today, the Students list and the forms. The owner tests on the device
and reports defects in chat; each becomes an R3-nn row and a direct developer dispatch.

| Area | State |
|---|---|
| `be/` | 11 migrations (through `roll_numbers`), pgTAP 589, seed (email accounts), Edge Function `admin-staff` v2. All applied to hosted 2026-11-05. |
| `fe/` | Theme A kit, config, errors, email auth + forgot password, shell, Today, Trainees, Trials, Fees (compact record screen, 500/800), Staff admin by email, brand badge + launcher icon. Baseline: analyze 0, `flutter test` 428 (incl. 57 proofs). Release signing with the upload keystore; app name "Boxing Club". |
| Device | Build 34 installed and copied to `/sdcard/Download/boxing-club-34.apk` (older copies deleted). Reinstall after every landed app run. |
| Hosted | Project `qgqmnaxdxuezjlexlfpw`. Admin by email (login in `creds.md`). Advisors: no RLS gaps. Migration history uses MCP timestamps (B-10). Migration history uses MCP timestamps (B-10). |
| `docs/` | Review log R1-01..R1-07, R2-01..R2-07 (all fixed except R1-03, R1-04 as backlog B-05, B-06). Backlog A-08..A-11, B-05, B-06, B-09, B-10 open. |

## Blocked on the owner

1. Hosted dashboard: turn off "Allow new users to sign up"; in Email Templates, "Reset
   Password" must include {{ .Token }} so the forgot-password code arrives (otherwise the
   mail carries a link the app cannot use). Phone provider is no longer needed.
1b. The MCP `apply_migration` can be blocked by the permission classifier; the owner says
   "retry now" and approves the prompt.
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
