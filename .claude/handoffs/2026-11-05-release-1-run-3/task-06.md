# Task 06 - Recovery screens: back links, password messages, proofs

- **Run:** `.claude/handoffs/2026-11-05-release-1-run-3/`
- **Area:** fe
- **Depends on:** task-04
- **Worker:** developer (Opus)
- **Tests:** yes (assistant: proofs + the two widget tests below)
- **Schema change approved by the owner:** n/a
- **Hosted apply:** n/a

## Goal
The forgot-password and reset screens always offer a way back to sign-in, weak or reused
passwords get a plain message, and every recovery screen has proofs.

## Context the worker needs
`fe/CLAUDE.md`; `docs/memory/notes/fe-email-sign-in.md`; `features/auth/presentation/
{forgot_password_screen,reset_password_screen}.dart`; `core/supabase/supabase_errors.dart`;
`test/proofs/auth_proofs_test.dart` and `proof_support.dart`.

## Files
- `fe/lib/features/auth/presentation/forgot_password_screen.dart`, `reset_password_screen.dart` - modify
- `fe/lib/core/supabase/supabase_errors.dart` - modify
- `fe/test/core/supabase/supabase_errors_test.dart`, `fe/test/features/auth/presentation/*` - modify (developer adds the two tests below)
- `fe/test/proofs/auth_proofs_test.dart` - modify (assistant)

## Spec
- Both recovery screens: a `LinkButton('Back to sign in')` under the primary button that
  calls `context.go(Routes.signIn)`; the forgot screen keeps its back arrow when it can pop.
- Mapper: `AuthApiException` code `weak_password` -> `ValidationException('Choose a stronger
  password: at least 8 characters.')`; `same_password` -> `ValidationException('Choose a
  password you have not used before.')`. Checked before the generic 400/422 rules.
- Developer tests: the mapper cases; a widget test that each recovery screen shows the
  back link and it navigates to `/sign-in` (use the small local router pattern from the
  existing auth tests).

## Out of scope
Any other copy. Backend.

## Acceptance criteria
- [ ] Analyzer, format clean; suite passes.
- [ ] Proofs (assistant): `forgot_password_empty`, `forgot_password_sent` (after Send code),
      `reset_password_empty`, `reset_password_wrong_code`, `sign_in_bad_email`, plus the
      re-rendered `more_coach` (email, no phone) and `staff_detail_coach`.

## Verification
From `fe/`: `flutter analyze`, `flutter test`, `flutter test test/proofs`, `dart format --output=none --set-exit-if-changed <touched>`.
