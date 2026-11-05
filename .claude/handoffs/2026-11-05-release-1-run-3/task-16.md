# Task 16 - Roll numbers in the app

- **Run:** `.claude/handoffs/2026-11-05-release-1-run-3/`
- **Area:** fe
- **Depends on:** task-15
- **Worker:** developer (Opus)
- **Tests:** yes (developer updates tests; assistant renders proofs)
- **Owner request this serves:** "add permanent numeric roll numbers on each student that students can remember for roll callouts while taking attendance" (2026-11-05).

## Goal (revised, owner 2026-11-05)
Roll call from Today: the roster lists students by roll number with the number visible; the
Students list, search and the student header show it. The number is chosen in the add and
edit forms, prefilled with the server's suggestion (gaps among active students first, else
highest + 1), and must be unique among active students.

## Context the worker needs
`fe/CLAUDE.md`; `features/trainees/domain/trainee.dart`, `features/today/domain/
roster_entry.dart`, `roster_row.dart`, `trainees_screen.dart`, `trainee_detail_screen.dart`,
mocks and fixtures; server contract from task-15 (`roll_no` on `trainees` rows and on
`session_roster` rows, roster ordered by `roll_no`).

## Spec
- `Trainee.rollNo` (int, required) and `RosterEntry.rollNo` (int, required), `fromJson`
  `roll_no`. Mocks assign sequential numbers starting at 1; fixtures get numbers.
- `RosterRow`: the leading avatar is replaced by a 40 px roll badge: the number in
  `bodyStrong` accent on an `accentSoft` circle (same size as the avatar); name as before.
  The roster is shown in server order (by roll number). The Today search is not needed.
- Students list: subtitle starts with the roll number: "#12 · +91 98765 43210" (or "#12 ·
  No phone"); search also matches the roll number typed as digits. The list is sorted by
  roll number ascending by default (owner, 2026-11-05); the repository orders by `roll_no`.
- Student detail header: caption line starts with "Roll no. 12".
- Add form: a "Roll number *" numeric field at the top (above Name), prefilled from
  `rpc('next_roll_no')` (loading state: the field shows the spinner placeholder until the
  number arrives; failure: empty field with the error banner). Edit form: the same field
  prefilled with the current number. `TraineeInput` gains `rollNo` (int, required);
  `create`/`update` send `p_roll_no`. Server `BXDUP 'Roll number N is already in use'` shows
  in the banner; the mock mirrors the gap-first suggestion and the active-only uniqueness.
  Reactivating a student whose number is now taken shows the server's `BXDUP` in a banner.

## Acceptance criteria
- [ ] Analyzer, format, codegen clean; suite passes.
- [ ] Widget: roster rows show the number; search "12" finds the student with roll 12; add form prefills the suggested number; duplicate shows the banner.
- [ ] Proofs (assistant): `today_typical`, `trainees_typical`, `trainee_detail_typical` re-rendered.
