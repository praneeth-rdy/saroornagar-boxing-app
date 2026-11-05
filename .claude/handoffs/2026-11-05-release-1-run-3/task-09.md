# Task 09 - Compact record-payment screen with a 500 / 800 amount choice

- **Run:** `.claude/handoffs/2026-11-05-release-1-run-3/`
- **Area:** fe
- **Depends on:** task-07, task-08
- **Worker:** developer (Opus)
- **Tests:** yes (assistant: proofs; developer updates existing tests)
- **Schema change approved by the owner:** n/a
- **Hosted apply:** n/a
- **Owner request this serves:** "can you make the payment records screen a bit more compact & simple. Let's also have the amount as a dropdown of 500 or 800." (2026-11-05)

## Goal
Recording a payment takes three taps: amount (500 or 800, preselected from the trainee's
tier), method, Record. Date and month are visible but out of the way; the note is hidden
until wanted.

## Context the worker needs
`fe/CLAUDE.md`; `features/fees/presentation/record_payment_screen.dart`,
`month_navigator.dart`; `features/trainees/domain/trainee.dart` (`feeTier`, `feeTierOn`);
`core/widgets/choice_row.dart`, `date_field.dart`; the mock
`test/support/mocks/mock_fee_repository.dart`; existing tests under
`test/features/fees/` and `test/features/trainees/`; proofs `fees_proofs_test.dart`.
Senior tier is now 800 (task-08): every "1000" tied to the tier in `lib/` and tests becomes
800 (`feeTier`, fixtures, copy such as "Senior, 800 per month").

## Files
- `fe/lib/features/trainees/domain/trainee.dart` - modify - senior tier 800
- `fe/lib/features/fees/presentation/record_payment_screen.dart` - modify (rewrite the body)
- `fe/lib/features/fees/presentation/month_navigator.dart` - modify only if a compact variant is needed
- `fe/test/...` - modify - tests and fixtures that assert 1000 or type an amount
- `docs/fe/architecture.md` - modify if a widget is added

## Spec
Layout, top to bottom, 20 px gutters:
1. Trainee header `AppCard` as now (avatar, name, "Junior, 500 per month" / "Senior, 800
   per month" / "No date of birth").
2. `Eyebrow('AMOUNT')` + `ChoiceRow<int>` with two pills, `500` and `800` (label "500",
   caption "Junior" / "Senior"), preselected from `feeTierOn(today)`; no free-text amount.
   (The owner asked for a dropdown; two pills are the kit's dropdown equivalent and need
   one tap. Keep the pill labels numeric.)
3. `Eyebrow('METHOD')` + `ChoiceRow` Cash / UPI, no default (server message on empty).
4. One compact `AppCard` with two `ListRow`s: "Paid on" with the date on the trailing side
   (tap opens the date picker, default today, not in the future) and "For month" with the
   month on the trailing side and small chevron buttons (prev / next, next capped at next
   month). Replace the full-height `MonthNavigator` and `DateField` here with this card.
5. `LinkButton('Add a note')` that reveals the note field (300 max) in place; hidden again
   is not needed.
6. `PrimaryButton('Record payment')` pinned at the bottom (sticky, like the Today bar).
Server `BXVAL` messages stay in an `InlineBanner` above the button. Success pops with the
"Payment recorded" snackbar as now.

## Out of scope
Fee status list layout, history, deleting payments, any backend file.

## Acceptance criteria
- [ ] Analyzer, format clean; suite passes with the 800 tier.
- [ ] Widget: 500 preselected for a junior, 800 for a senior, none for no DOB; method empty
      shows the server message; the note field appears after the link; next-month cap.
- [ ] Proofs (assistant): `record_payment_prefilled` (senior, 800), `record_payment_junior`,
      `record_payment_error`, `record_payment_note_open`; `fee_status_mixed` re-rendered with
      800 due.

## Verification
From `fe/`: `flutter analyze`, `flutter test`, `flutter test test/proofs`, `dart format --output=none --set-exit-if-changed <touched>`.
