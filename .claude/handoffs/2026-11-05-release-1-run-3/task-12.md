# Task 12 - Monthly attendance shows attended counts; "Trainee" becomes "Student"

- **Run:** `.claude/handoffs/2026-11-05-release-1-run-3/`
- **Area:** fe
- **Depends on:** task-10, task-14 (Today files)
- **Worker:** developer (Opus)
- **Tests:** yes (developer updates tests; assistant renders proofs)
- **Owner request this serves (two messages, 2026-11-05):** "Wherever we show list of attendance logs - need not show separate rows or cards for morning & evening. You can show date-wise logs with each date noting morning & evening if they are present in both and just morning or evening if they are present in only one session." and "Let's not show the target number sessions. Let's only show the number of classes they attended this month inside monthly attendance. If someone clicks on the user, then we can show the list of their attendance logs. Also, let's rename the term Trainee to Student across the app." (2026-11-05)

## Goal
Monthly attendance lists every active student with the number of classes attended this
month; tapping a student opens their attendance log for that month. Everywhere a person
reads the app, the word is "Student", never "Trainee".

## Context the worker needs
`fe/CLAUDE.md`; `features/fees/presentation/attendance_summary_screen.dart`;
`features/trainees/presentation/attendance_history_screen.dart` (month navigator, rows);
`core/router/routes.dart` (`traineeHistory`); every screen, state view, dialog, snackbar,
validator message, semantic label and proof fixture with the word Trainee/trainee/trainees.

## Spec
- Monthly attendance screen: title "Monthly attendance"; month navigator stays; remove the
  "N sessions this month" caption and the "n/m" trailing. Each row: avatar, name, trailing
  `bodyStrong` count ("12") with caption "classes" under it (or subtitle "12 classes
  attended" and no trailing; pick the one that reads cleanly at 390 px). Rows are tappable
  (chevron) and push the student's attendance history for the same month
  (`Routes.traineeHistory` with the month as a query parameter, so the history screen opens
  on that month). Absent counts are not shown. Empty: "No active students".
- `AttendanceHistoryScreen` accepts `?month=YYYY-MM-01` to open on that month.
- Attendance logs are grouped by date, in the history screen AND the recent section of the
  student detail: one `ListRow` per date (title `EEE d MMM`), subtitle built from that
  date's PRESENT marks: "Morning and evening", "Morning", "Evening", extras by time
  ("Morning and extra 4:00 pm"). Absence is implicit (owner, 2026-11-05): dates with no
  present mark do not appear at all, and legacy absent rows are ignored. Counts caption on the history screen becomes
  "12 classes attended" (present marks). Put the grouping in a pure function
  (`groupAttendanceByDate(List<AttendanceRecord>) -> List<AttendanceDay>`) in the trainees
  domain with unit tests (both present, one present one absent, extra session, all absent gives no day).
- Rename: "Student" / "Students" / "student" replaces "Trainee" / "Trainees" / "trainee"
  in every user-facing string: the tab label and icon tooltip, screen titles ("Students",
  "Add student", "Student"), buttons ("Add student"), empty states, confirm dialogs,
  snackbars, validators, error copy ("This student is inactive" where the server message
  is shown as given it stays the server's; the mock mirrors the server), semantics labels,
  and proof names where they are user-visible text (file names may stay). Identifiers,
  routes paths and class names stay (`Trainee`, `/trainees`).
- Student form (add and edit): Name and Phone first; then a `LinkButton('Add more details')`
  that expands, in place, Date of birth, Joined on and Notes (expanded by default on edit
  when any of the three has a value). Owner, 2026-11-05.
- Required-field convention, app-wide: a required field's label ends with " *" (Name *,
  Email *, Password *, Phone * on the trial form); no label says "(optional)" any more.
  Apply to the student, staff, trial and record-payment forms and to `AppTextField` /
  `DateField` labels. A one-line caption under the first form field is not needed.
- `docs/product.md` glossary: "Student: a person who trains at the club (the app's word
  for a trainee since 2026-11-05)". `docs/fe/architecture.md` screen names updated.

## Out of scope
Backend wording (server messages say "trainee"; the app shows them as given; a be
follow-up changes them: backlog item). Renaming code or tables.

## Acceptance criteria
- [ ] `grep -rn "Trainee\|trainee" fe/lib --include=*.dart` matches only identifiers, imports, routes and comments, never a quoted user-facing string (the developer lists any exception).
- [ ] Student form widget test: collapsed by default on add, the link reveals the three fields, expanded on edit with a DOB; `grep -rn "(optional)" fe/lib` returns nothing.
- [ ] Monthly attendance widget test: no session total shown, counts per row, tap pushes the history route with the month.
- [ ] `flutter analyze` 0, `dart format` clean, suite passes.
- [ ] Proofs (assistant): `attendance_summary_typical`, `attendance_summary_heavy`, `trainees_typical`, `trainee_detail_typical`, `trainee_form_empty` (collapsed), `trainee_form_expanded`, `staff_form_empty`, `book_trial_empty`, `today_typical` re-rendered.
