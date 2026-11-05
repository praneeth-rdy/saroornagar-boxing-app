# Plan - release 1, run 2 (app features)

Depends on run 1 (`../2026-11-05-release-1-run-1/`): backend migrations 01-04 and 08, the
Edge Function, the app foundation (task-06 kit, errors, theme, proofs harness) and task-07
(auth, shell, guards). Read `../2026-11-05-release-1-run-1/plan.md` for the shared decisions
(phone format, India dates, blocking, upsert marks).

Order: task-01 Today (attendance), task-02 Trainees, task-03 Trials (public booking + staff
list), task-04 Fees and reports, task-05 Staff admin. All `fe`. Sequential: each package
touches the router and the shell.

## Decisions fixed for every package
- Every feature: `domain/` freezed models with `fromJson` matching the SQL row shapes in
  `docs/be/architecture.md`; `data/` repository interface + `Supabase*Repository` using
  `guardSupabase`; a `Mock*Repository` under `fe/test/support/mocks/` that mirrors every
  server rule and `BXVAL` message listed in the backend notes (`docs/memory/notes/be-*.md`);
  `presentation/*_providers.dart` with `autoDispose` providers; screens render through
  `AsyncValueView` and the kit only.
- Dates: the app works in India dates. `DateTime.now()` is converted with the `intl`
  formatter in `Asia/Kolkata`; send `date` parameters as `YYYY-MM-DD` strings; parse times
  (`starts_at`) as `HH:mm:ss`.
- Months are sent as `YYYY-MM-01`.
- Server messages (`AppException.message`) are shown as given in banners; the kit's state
  views carry the retry.
- New dependencies in this run: `shared_preferences` (trial device key), `image_picker`
  (trainee photo). Latest stable, versions recorded in the summaries.
- Naming: routes in `core/router/routes.dart`; nested routes under the owning tab branch;
  tab roots use `go`, detail and form screens use `push`.
- Every screen has empty, loading, error and permission-denied states and a next action in
  the empty state. Proofs: no data, typical, heavy for every screen.
