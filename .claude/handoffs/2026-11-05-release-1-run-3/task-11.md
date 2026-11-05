# Task 11 - Monthly summary counts held sessions only (R3-04)

- **Run:** `.claude/handoffs/2026-11-05-release-1-run-3/`
- **Area:** be
- **Worker:** developer (Opus)
- **Tests:** yes (developer updates pgTAP)
- **Schema change approved by the owner:** 2026-11-05 (bug report: "it shows a total of 4 sessions"; function body only, no table change)
- **Hosted apply:** on the owner's say-so, migration `<timestamp>_summary_held_sessions.sql`
- **Owner request this serves:** the attendance bug report above (2026-11-05).

## Goal
"N sessions this month" counts sessions that were actually held (at least one attendance
mark), not every row `ensure_day_sessions` created when someone merely opened a date.

## Context the worker needs
`be/CLAUDE.md`; `20261105080602_fees_reports.sql` (`monthly_attendance_summary`);
`tests/040_fees_reports.sql` (summary assertions, including "session_count the same on
every row" and the month-boundary cases).

## Spec
- New migration: `create or replace function public.monthly_attendance_summary(p_month
  date)` with the same signature and return type; `v_session_count` = count of sessions in
  the month that have at least one row in `public.attendance`. Everything else unchanged.
- pgTAP: a session with no marks does not count; a session with one mark counts once
  regardless of how many trainees were marked; the existing assertions adjusted.

## Acceptance criteria
- [ ] `npx supabase db reset` and `npx supabase test db` pass.
- [ ] `docs/be/architecture.md` row for `monthly_attendance_summary` says "held sessions".
