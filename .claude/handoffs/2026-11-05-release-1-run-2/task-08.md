# Task 08 - Proof sweep fixes (R2-01 to R2-07)

- **Run:** `.claude/handoffs/2026-11-05-release-1-run-2/`
- **Area:** fe
- **Depends on:** task-07
- **Worker:** developer (Opus)
- **Tests:** yes (assistant: re-render the affected proofs, run the suite)
- **Schema change approved by the owner:** n/a
- **Hosted apply:** n/a

## Goal
Seven small visual defects found in the proof review are fixed so the release build has no
cramped, clipped or double-labelled screens.

## Context the worker needs
`fe/CLAUDE.md`; `docs/review-log.md` rows R2-01 to R2-07. Read every file before editing.
Proof images to compare against: `fe/test/proofs/out/staff_list_heavy.png`,
`staff_detail_coach.png`, `trainee_detail_heavy_notes.png`, `trainee_form_empty.png`,
`today_mark_error.png`, `book_trial_empty.png`, `trials_ten_days.png`.

## Files
- `fe/lib/features/staff/presentation/staff_list_screen.dart` (or the row widget) - R2-01
- `fe/lib/features/staff/presentation/staff_detail_screen.dart` - R2-02
- `fe/lib/features/trainees/presentation/trainee_detail_screen.dart` - R2-03
- the shared date field widget used by the trainee form, record payment and book trial (find it; if each screen has its own, fix all and extract `core/widgets/date_field.dart`) - R2-04
- `fe/lib/features/today/presentation/today_screen.dart` - R2-05
- `fe/lib/features/trials/presentation/book_trial_screen.dart` - R2-06, R2-07
- `fe/test/support/fixtures/trials.dart` - R2-07 fixture
- `docs/fe/architecture.md` - modify only if a widget is added

## Spec
- R2-01: on a blocked staff row, keep the phone on one line: move the `Blocked` chip onto the subtitle line after the role (`Blocked · Coach · +91 ...` is wrong; render the chip first, then the phone, with the subtitle text in `Flexible` + ellipsis), or place the chip under the name. Row height must equal the other rows at 390 px with a 12-digit phone.
- R2-02: the Edit and Reset password buttons stack vertically, each full width (`SecondaryButton` expanded), 12 px apart; `Block access` stays a link below them.
- R2-03: the Notes card shows the whole note (no `maxLines`); notes are capped at 500 characters server-side.
- R2-04: an empty date field shows `Choose a date` in the `muted` colour and regular weight (the same look as a text field hint); a chosen date keeps the current ink style.
- R2-05: the roster list gets bottom padding equal to the sticky bar height plus `AppSpacing.lg` whenever the bar is visible, so the last row clears it.
- R2-06: in `BookTrialScreen`, the fields under the `YOUR AGE` and `ANYTHING WE SHOULD KNOW (OPTIONAL)` eyebrows have no field label of their own (pass no `label`; keep a hint `Age in years` and `Anything the coach should know`). Also drop the `Name` and `Phone` field labels only if the design artboard shows none; it does show them, so keep those two.
- R2-07: subtitle copy becomes `Pick a day and a batch. The coach will expect you.` The trials fixture generates distinct names per day (append the day, e.g. `Rahul Verma` only on day 1), never books a Sunday, and the ten-day fixture has 1 to 3 bookings per day.

## Out of scope
Any other copy or layout change; the accent on avatars, the Record links and the `Set inactive` link are design decisions, not defects.

## Acceptance criteria
- [ ] `flutter analyze` 0 issues; `dart format` clean; suite passes (update any test asserting the old labels or copy).
- [ ] Re-rendered proofs for the seven screens show the fixes (assistant runs `flutter test test/proofs` and lists the seven PNGs).

## Verification
Developer: `flutter analyze`, `flutter test`, `dart format --output=none --set-exit-if-changed <touched files>`. Assistant: full `flutter test` and `flutter test test/proofs`.
