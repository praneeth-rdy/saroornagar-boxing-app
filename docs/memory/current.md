# Current state

Last updated 2026-11-05 (second session, mid-run). History in `log.md`.

## Where the product stands

Release 1 backend is complete locally and committed (5 migrations, 501 pgTAP assertions,
Edge Function `admin-staff`); nothing applied to hosted. The app foundation and sign-in are
committed (analyze clean, 102 tests, debug APK builds). Run 2 (Today, Trainees, Trials,
Fees, Staff admin) is being built through `tiered-build` from
`.claude/handoffs/2026-11-05-release-1-run-2/`.

| Area | State |
|---|---|
| `be/` | `20261105074646_identity`, `..075401_trainees_sessions`, `..080014_attendance_trials`, `..080602_fees_reports`, `..081756_harden_profiles`; tests 000-040; seed; `functions/admin-staff`. Hosted: not applied, not deployed. |
| `fe/` | Theme A kit, config, errors, router, auth, shell, More tab; Today/Trainees/Trials are stubs until run 2 lands. Deps: riverpod 3.4.3, go_router 18.1.3, supabase_flutter 2.18.3, freezed 4.0.3, intl 0.20.3. Baseline: analyze 0 issues, 102 tests. |
| `docs/` | Architecture maps filled by the workers; review log R1-01..R1-07; backlog B-01..B-08, A-01..A-07. |

## Blocked on the owner (hosted steps, in this order)

1. Dashboard: Authentication > Sign In / Up: turn "Allow new users to sign up" off; enable
   the Phone provider; keep phone confirmations off (`notes/be-open-signup-role-escalation.md`).
2. Say the word for the hosted apply (5 migrations through the MCP `apply_migration`, then
   `deploy_edge_function admin-staff`).
3. Create the first admin in the dashboard (phone + password); the Architect then inserts the
   profile row with role `admin` through the MCP and records the login in `creds.md`.
4. Open points: Android application id (D-04), B-05/B-06 in the backlog, fee status list
   semantics (product.md open question 7).

## Resume checklist

1. If run 2 did not finish: check `.claude/handoffs/2026-11-05-release-1-run-2/` and
   `git status`; re-run `tiered-build` for the remaining tasks.
2. Review run 2 (diffs, proofs under `fe/test/proofs/out/`), commit, then hosted apply on
   the owner's word, then a device run against hosted.
