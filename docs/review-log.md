# Review log

Every review finding ever raised, with status (open / fixed / refuted / wontfix) and a pointer
to the fix. Read before reviewing; never re-report an item already here.

| ID | Date | Area | Finding | Status |
|---|---|---|---|---|
| R1-01 | 2026-11-05 | be | `private.handle_new_user` takes the role from `raw_user_meta_data`, which a public sign-up controls; a self sign-up could become admin (worker finding, verified on the local stack). | fixed 2026-11-05, `20261105081756_harden_profiles.sql` |
| R1-02 | 2026-11-05 | be | `anon` keeps the table-level `select` grant on every public table; RLS returns zero rows, but the grant is a needless layer. | fixed 2026-11-05, `20261105081756_harden_profiles.sql` |
| R1-03 | 2026-11-05 | be | `book_trial` accepts today's morning batch after it has ended; no anon rate limit beyond the unique key. | open, backlog B-05 |
| R1-04 | 2026-11-05 | be | `session_roster` lists active trainees only, so a trainee set inactive drops off past rosters; `fee_status_list` and `monthly_attendance_summary` likewise. | open, backlog B-06 (decide with the owner) |
| R1-05 | 2026-11-05 | fe | `InlineBanner` is capped at one line, so the offline copy clips at phone width. | fixed by run-2 task-01 (up to 3 lines) |
| R1-06 | 2026-11-05 | fe | `renderProof` takes a widget only: no way to fill a form or trigger an error before capture, and the Material icon font is not loaded, so icons render as boxes. | fixed by run-2 task-01 (`interact` callback, icon font) |
| R1-07 | 2026-11-05 | fe | A signed-in user with no profile (`BXNTF`) gets an error view with no sign-out. | fixed by run-2 task-01 (not-staff state) |
