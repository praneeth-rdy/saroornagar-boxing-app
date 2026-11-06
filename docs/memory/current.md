# Current state

Last updated 2026-11-06 (docs pass after the 2026-11-05 sessions). History in `log.md`.
Read `docs/decisions.md` first for why things are the way they are.

## Where the product stands

Release 1 shipped 2026-11-05 as a sideloaded APK: built, applied to the hosted project and
installed on the owner's phone (build 41, "Saroornagar Boxing", application id
`com.saroornagarboxing.app`), and shared with the coaches from
`/sdcard/Download/saroornagar-boxing-41.apk`. No Play Store listing. Staff sign in by email
and password; the forgot-password flow is built but its entry point is hidden (admins reset
from Staff). L5a Classic badge and glove icon; presence-only attendance with confirmed unmark
and session reset; logs grouped by date; monthly attendance = classes attended per student;
"Student" in every user-facing string (code and tables keep `trainee`); compact
record-payment with 500 / 800; roll numbers (unique among active students, suggested
gaps-first, editable) on Today, the Students list and the forms, both ordered by them. The
owner tests on the device and reports defects in chat; each becomes an R3-nn row and a
direct developer dispatch.

| Area | State |
|---|---|
| `be/` | 12 migrations (through `backlog_sweep`), pgTAP 600, seed (email accounts), Edge Function `admin-staff` v2. All 12 applied to hosted (last one 2026-11-05). |
| `fe/` | Theme A kit, config, errors, email auth (forgot-password routes kept, link hidden), shell, Today, Students, Trials, Fees (compact record screen, 500/800), reports under More, Staff admin by email, brand badge + launcher icon. Baseline: analyze 0, `flutter test` 440 (incl. 57 proofs). Release signing with the upload keystore; label "Saroornagar Boxing". |
| Device | Build 41 installed and copied to `/sdcard/Download/saroornagar-boxing-41.apk`; the build the owner shares with the coaches. Reinstall and replace the copy after every landed app run (`README.md` Release and install). |
| Hosted | Project `qgqmnaxdxuezjlexlfpw`. Admin by email (login in `creds.md`). Advisors: no RLS gaps. Migration history uses MCP timestamps (B-10). |
| `docs/` | Review log R1-01..R3-04 (all fixed except R1-03, R1-04 as B-05, B-06, now done). Backlog: B-10 todo (only if `db push` is used); S-06 waits on the owner. |

## Blocked on the owner

1. Hosted dashboard: turn off "Allow new users to sign up" (S-06). The reset-password
   template step is dropped: the forgot-password entry point is hidden.
2. Product call: `product.md` open question 7 (fee status: last paid month only, or also
   flag months with no payment).
3. Back up `fe/android/keystore/upload-keystore.jks` (passwords in `creds.md`); it cannot
   be regenerated and a new key forces every user to reinstall.

## Resume checklist

1. `git status` clean? If not, check the top entry of `docs/memory/log.md`.
2. Wait for the owner's device feedback from the coaches; log every defect in
   `docs/review-log.md` as R3-nn and fix through a developer package, then rebuild, install
   and replace the Downloads copy.
