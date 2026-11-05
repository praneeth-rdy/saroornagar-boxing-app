# Task 17 - Backlog sweep (B-05, B-06, B-09, B-12, B-13)

- **Run:** `.claude/handoffs/2026-11-05-release-1-run-3/`
- **Area:** be
- **Worker:** developer (Opus)
- **Tests:** yes (developer updates pgTAP)
- **Schema change approved by the owner:** 2026-11-05, "Proceed with the remaining work." (policy merge and function bodies; no table change)
- **Hosted apply:** on the owner's say-so, migration `<timestamp>_backlog_sweep.sql`
- **Owner request this serves:** "Proceed with the remaining work." (2026-11-05), `docs/backlog.md` items B-05, B-06, B-09, B-12, B-13.

## Spec (one new migration)
- B-12: every user-facing message that says trainee now says student: `'This student is
  inactive'`, `'Student not found'` (every function that raises it), any other occurrence
  (`grep -n -i trainee` on message strings in the migrations). Recreate only the functions
  whose bodies change; same signatures.
- B-13: `trainee_attendance_history` returns two more columns at the end: `starts_at time`,
  `ends_at time` (drop and recreate, same name).
- B-05: `book_trial` refuses today's batch once it has ended: when `p_session_date =
  private.today()` and the batch end (morning 08:30, evening 20:00, India time via
  `private.clock() at time zone 'Asia/Kolkata'`) is already past -> `BXVAL 'That batch has
  already ended today'`. No rate limit beyond the unique key.
- B-06: `monthly_attendance_summary` lists every student who is active OR has at least one
  attendance mark in the month (inactive students with marks stay in the report);
  `fee_status_list` stays active-only. `session_roster` stays active-only.
- B-09: drop `profiles_select_own` and `profiles_select_staff`; one policy
  `profiles_select_staff_or_own for select to authenticated using (id = (select auth.uid()) or
  (select private.is_staff()))`.
- `docs/be/architecture.md` rows and `docs/backlog.md` statuses (B-05, B-06, B-09, B-12,
  B-13 done, date) updated; the Edge Function needs no change.
- pgTAP: messages, the two new history columns, the ended-batch rule (pin the clock), the
  inactive-with-marks row in the summary, the merged policy (blocked user still reads own row,
  anon nothing).

## Acceptance criteria
- [ ] `npx supabase db reset` and `npx supabase test db` pass; `db lint` shows no new warnings.
