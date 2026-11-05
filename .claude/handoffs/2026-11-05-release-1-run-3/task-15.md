# Task 15 - Permanent roll numbers for students

- **Run:** `.claude/handoffs/2026-11-05-release-1-run-3/`
- **Area:** be
- **Worker:** developer (Opus)
- **Tests:** yes (developer updates pgTAP)
- **Schema change approved by the owner:** 2026-11-05, "Can you add permanent numeric roll numbers on each student that students can remember for roll callouts while taking attendance?" (column + sequence, design stated back in chat)
- **Hosted apply:** on the owner's say-so, migration `<timestamp>_roll_numbers.sql`
- **Owner request this serves:** the roll number request above.

## Goal (revised, owner 2026-11-05)
Every student has a numeric roll number, unique among ACTIVE students (an inactive student's
number may be reused), chosen in the form with a server-suggested default: the smallest
unused positive number among active students, else the highest plus one.

## Context the worker needs
`be/CLAUDE.md`; `20261105075401_trainees_sessions.sql` (`trainees`, `create_trainee`,
`update_trainee`), `20261105080014_attendance_trials.sql` (`session_roster`); tests 020, 030.

## Spec
- `alter table public.trainees add column roll_no integer`; backfill existing rows 1, 2, 3
  in `created_at, id` order; `set not null`; check `roll_no > 0`; partial unique index
  `trainees_roll_no_active_key on trainees (roll_no) where status = 'active'`. No sequence.
- `private.next_roll_no() returns integer`: the smallest positive integer not used by an
  active student (gaps first), else max + 1; 1 when there are no active students.
- `public.next_roll_no() returns integer`: staff check, returns the private value (the form's
  default).
- `create_trainee(p_full_name, p_phone, p_date_of_birth, p_joined_on, p_notes, p_roll_no
  integer default null)`: null -> `private.next_roll_no()`; `<= 0` -> `BXVAL 'Enter a roll
  number above 0'`; taken by an active student -> `BXDUP 'Roll number N is already in use'`
  (check, then catch unique_violation too). `update_trainee(..., p_roll_no integer)`: same
  rules, ignoring the row itself. `set_trainee_status` to active: `BXDUP` when the number is
  taken by another active student. The old 5-argument `create_trainee` and 6-argument
  `update_trainee` are dropped (replaced).
- `session_roster`: drop and recreate with the same name and an added `roll_no integer`
  column after `trainee_id`; rows ordered by `roll_no`.
- `docs/be/architecture.md`: trainees row, session_roster row, a line that roll numbers are
  permanent and sequence-assigned.
- pgTAP (020 and 030): default numbering 1, 2, 3; a gap (deactivate 2, create -> 2); no gap
  -> max + 1; explicit number accepted; duplicate among active -> `BXDUP`; same number as
  an inactive student allowed; reactivating into a clash -> `BXDUP`; `update_trainee` can
  change the number; roster returns and orders by `roll_no`; `next_roll_no` denied to anon.

## App impact
`trainees` rows gain `roll_no`; `session_roster` rows gain `roll_no` and are ordered by it; `rpc('next_roll_no')` -> int; `create_trainee` and `update_trainee` take `p_roll_no`; `BXDUP 'Roll number N is already in use'`; `BXVAL` on 0 or negative.

## Acceptance criteria
- [ ] `npx supabase db reset` and `npx supabase test db` pass.
