# Task 13 - Unmark attendance (presence-only marking)

- **Run:** `.claude/handoffs/2026-11-05-release-1-run-3/`
- **Area:** be
- **Worker:** developer (Opus)
- **Tests:** yes (developer updates pgTAP)
- **Schema change approved by the owner:** 2026-11-05 (owner: coaches mark only the present; the rest are absent when a session has at least one mark; a session with no marks is ignored). New function only, no table change.
- **Hosted apply:** on the owner's say-so, migration `<timestamp>_unmark_attendance.sql`
- **Owner request this serves:** "user need not manually mark absent. They'll only mark people who are present & rest to be considered absent if attendance is taken for at least 1 in the given session. If no attendance is taken on a session - ignore that session in the count" (2026-11-05).

## Goal
A coach can undo a Present tap. Removing the only mark of a session returns it to "not
held", so a mistaken tap never creates a held session.

## Context the worker needs
`be/CLAUDE.md`; `20261105080014_attendance_trials.sql` (`mark_attendance`, locks, grants);
`tests/030_attendance_trials.sql`.

## Spec
- New migration: `public.unmark_attendance(p_session_id uuid, p_trainee_id uuid) returns
  void`, `security definer set search_path = ''`, staff check (`BXPRM`), session key-share
  lock as `mark_attendance`, `BXNTF 'Session not found'`, `BXNTF 'No mark to remove'` when
  no row exists; deletes the row. Grants: execute to `authenticated` only.
- Also `public.reset_session_attendance(p_session_id uuid) returns integer`: staff check,
  session lock as above, `BXNTF 'Session not found'`; deletes every attendance row of the
  session and returns the number removed (0 is fine). Grants to `authenticated` only.
- `docs/be/architecture.md`: both function rows; a line under the attendance table saying absence
  is implicit (no mark in a held session) and `absent` rows are legacy from the first build.
- pgTAP (both functions): positive path, second unmark `BXNTF`, reset returns the count then 0, coach allowed, blocked coach `BXPRM`, anon
  `42501`, and that `monthly_attendance_summary` stops counting a session once its only
  mark is removed.

## Acceptance criteria
- [ ] `npx supabase db reset` and `npx supabase test db` pass; plan correct.
