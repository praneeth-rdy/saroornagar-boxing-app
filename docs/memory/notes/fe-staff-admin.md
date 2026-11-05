# Staff admin screens: things to know (fe, 2026-11-05)

- functions_client 2.7.1 (via supabase 2.16.5): a non-2xx JSON answer throws
  `FunctionsHttpException` with the decoded body in `details`, so `{code, message}` maps through
  `_fromFunction`. A transport failure is `FunctionsFetchException` (status 0, the error in
  `details`); the mapper now turns it into `OfflineException` instead of Unknown.
- A gateway 401 (expired or bad JWT, before the function runs) has no BX code and maps to
  `UnknownException`. Not handled; revisit if it shows up on device.
- Staff writes do not invalidate `currentProfileProvider`: the shell watches it with
  `skipLoadingOnRefresh: false`, so a refresh would blank the tabs. An admin renaming
  themselves sees the old name on More until the next load.
- Open: the package hides only "Block access" on the own profile; "Reset password" stays
  (the function allows it). Confirm whether self reset should wait for the self password
  change release.
- `admin-staff` is not deployed to hosted yet (`docs/be/architecture.md`), so the real
  create/reset/block calls fail on device until it is.
