# Review log

Every review finding ever raised, with status (open / fixed / refuted / wontfix) and a pointer
to the fix. Read before reviewing; never re-report an item already here.

| ID | Date | Area | Finding | Status |
|---|---|---|---|---|
| R1-01 | 2026-11-05 | be | `private.handle_new_user` takes the role from `raw_user_meta_data`, which a public sign-up controls; a self sign-up could become admin (worker finding, verified on the local stack). | fixed by run-1 task-08 (`raw_app_meta_data` only; no profile without a staff role) |
| R1-02 | 2026-11-05 | be | `anon` keeps the table-level `select` grant on every public table; RLS returns zero rows, but the grant is a needless layer. | fixed by run-1 task-08 (revoke select from anon) |
| R1-03 | 2026-11-05 | be | `book_trial` accepts today's morning batch after it has ended; no anon rate limit beyond the unique key. | open, backlog B-05 |
| R1-04 | 2026-11-05 | be | `session_roster` lists active trainees only, so a trainee set inactive drops off past rosters; `fee_status_list` and `monthly_attendance_summary` likewise. | open, backlog B-06 (decide with the owner) |
