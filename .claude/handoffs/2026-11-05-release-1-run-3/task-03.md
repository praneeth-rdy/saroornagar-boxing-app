# Task 03 - Sign in by email, forgot password

- **Run:** `.claude/handoffs/2026-11-05-release-1-run-3/`
- **Area:** fe
- **Depends on:** none (contracts fixed in task-01 and plan.md)
- **Worker:** developer (Opus)
- **Tests:** yes (assistant)
- **Schema change approved by the owner:** n/a
- **Hosted apply:** n/a

## Goal
Staff sign in with email and password. A staff member who forgets the password asks for a
code by email, enters it with a new password, and is signed in.

## Context the worker needs
`fe/CLAUDE.md`; `plan.md` here (OTP recovery flow, error copy); current auth feature
(`features/auth/*`, `core/router/*`, `core/supabase/supabase_errors.dart`,
`core/utils/validators.dart`, `test/support/mocks/mock_auth_repository.dart`,
`test/support/fixtures/profiles.dart`). supabase_flutter 2.18.x: `signInWithPassword(email:,
password:)`, `resetPasswordForEmail(email)`, `verifyOTP(type: OtpType.recovery, email:,
token:)`, `updateUser(UserAttributes(password:))`; verify each in `pubspec.lock`'s package
source before use.

## Files
- `fe/lib/features/auth/domain/staff_profile.dart` (+ generated) - modify - `email` (required), `phone` nullable
- `fe/lib/features/auth/data/auth_repository.dart`, `supabase_auth_repository.dart` - modify
- `fe/lib/features/auth/presentation/{auth_providers,sign_in_screen}.dart` - modify
- `fe/lib/features/auth/presentation/{forgot_password_screen,reset_password_screen}.dart` - create
- `fe/lib/core/router/{routes,app_router,route_guards}.dart` - modify - public routes `/forgot-password`, `/reset-password`
- `fe/lib/core/utils/validators.dart` - modify - `emailText`
- `fe/lib/core/supabase/supabase_errors.dart` - modify - recovery error codes
- `fe/lib/features/more/presentation/more_screen.dart` - modify - subtitle shows email, phone when present
- `fe/test/support/mocks/mock_auth_repository.dart`, `fe/test/support/fixtures/profiles.dart` - modify
- every file that renders `profile.phone` as non-null (staff list, staff detail: handle null with "No phone")
- `docs/fe/architecture.md` - modify

## Spec
```dart
abstract class AuthRepository {
  bool get hasSession;
  Stream<bool> get sessionChanges;
  Future<void> signIn({required String email, required String password});
  Future<void> signOut();
  Future<StaffProfile> currentProfile();
  Future<void> requestPasswordReset(String email);                       // resetPasswordForEmail
  Future<void> completePasswordReset({required String email, required String code, required String newPassword}); // verifyOTP(recovery) then updateUser
}
```
- `signIn`: trim + lower the email; `emailText` validator ("Enter a valid email address").
- `SignInScreen`: fields Email (`TextInputType.emailAddress`, autocorrect off) and Password;
  `LinkButton('Forgot password?')` under the button -> `Routes.forgotPassword`; keep the
  trial link. Phone prefix removed.
- `ForgotPasswordScreen` (`/forgot-password`): eyebrow, title "Reset password", caption "We
  will email you a 6-digit code.", Email field (prefilled from the sign-in field when
  passed as `extra`), `PrimaryButton('Send code')`; on success `go('/reset-password',
  extra: email)` whatever the server said about the email's existence; rate-limit error in
  a banner.
- `ResetPasswordScreen` (`/reset-password`, needs the email as `extra`, else redirects to
  `/forgot-password`): caption "Enter the code from the email and choose a new password.",
  Code field (6 digits, numeric), New password, Confirm password (must match), `PrimaryButton
  ('Set new password')`, `LinkButton('Send a new code')` -> `requestPasswordReset` again with
  a snackbar "Code sent". On success the session exists and the guard redirects to Today;
  show a snackbar "Password updated".
- Mapper: `AuthApiException` codes `otp_expired`, `otp_disabled`, invalid token (message
  contains "Token has expired or is invalid") -> `ValidationException('That code is wrong or
  has expired.')`; `over_email_send_rate_limit` / `over_request_rate_limit` ->
  `ValidationException('Too many emails were sent. Try again in a few minutes.')`;
  `email_not_confirmed` -> `ValidationException('This account is not confirmed yet. Ask the
  club admin.')`. Keep the existing mappings; the phone-provider mapping may stay.
- Guards: `/forgot-password` and `/reset-password` are public (no session); with a session
  they redirect to Today like `/sign-in`.
- Mock: `validEmail = 'admin@local.test'`; `requestPasswordReset` records the email and sets
  `lastCode = '123456'`; `completePasswordReset` succeeds only with that code and email,
  else throws the wrong-code `ValidationException`; on success sets signed in. Fixtures get
  emails; `blockedCoachProfile` keeps a phone, `coachProfile` has `phone: null`.

## Out of scope
Staff admin form (task-04). Changing the password while signed in (later). Any backend file.

## Acceptance criteria
- [ ] Analyzer, format, codegen clean; suite passes with fixtures updated.
- [ ] Unit: `emailText`; mapper for the three recovery codes; guards for the two routes.
- [ ] Widget: sign-in validation (bad email), forgot screen sends and navigates, reset screen
      rejects a mismatch and a wrong code, succeeds with `123456`.
- [ ] Flow: sign-in -> Forgot password -> code -> new password -> Today.
- [ ] Proofs: sign-in (empty, error), forgot (empty, sent), reset (empty, wrong code), More
      with email and no phone.

## Verification
From `fe/`: codegen, `flutter analyze`, `flutter test`, `flutter test test/proofs`, `dart format --output=none --set-exit-if-changed <touched>`.
