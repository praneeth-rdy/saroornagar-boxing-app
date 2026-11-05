# fe email sign-in and password recovery (2026-11-05, run 3 task-03)

- Built before the task-01 migration existed: `StaffProfile.email` is required, so
  `current_profile` fails to parse against hosted until `<ts>_email_sign_in.sql` is applied.
- `verifyOTP(recovery)` creates the session, so the guard redirects to Today before
  `updateUser(password)` returns. The reset screen captures the root `ScaffoldMessenger`
  first; "Password updated", or the failure if `updateUser` fails, shows after the redirect.
- The forgot screen `go`es to `/reset-password` (package spec), so the reset screen has no
  back route; both recovery screens now carry a "Back to sign in" link (task-06).
- GoTrue `weak_password` / `same_password` map to plain ValidationExceptions (task-06); the
  SDK throws `AuthWeakPasswordException` for the first, matched by its code.
- The mock code is single use; `completePasswordReset` also needs the last requested email.
- `coachProfile` lost its phone, so tests that used `9000000002` as a taken staff phone now
  pass where they expected `BXDUP`; those tests and the phone-typing sign-in tests need
  updating (assistant / task-04).
