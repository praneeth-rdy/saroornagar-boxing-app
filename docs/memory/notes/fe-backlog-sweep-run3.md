# fe backlog sweep A-08..A-11, B-13 app side (2026-11-05, run 3 task-18)

- A-10 picks sign-out over a banner: the staff controllers call `signOutProvider` on an
  `AuthFailedException`; only `admin-staff` calls can raise it (update_staff is PostgREST,
  whose expired JWT maps to `PermissionException` via PGRST301, unchanged).
- A-09: the shell uses `skipLoadingOnRefresh: !profile.hasError`. A refresh that then fails
  still shows the shell's `ErrorView`; Riverpod keeps the old value, but `skipError` was not
  turned on so a blocked or deleted profile still wins.
- A-08: `uploadPhoto` and `removePhoto` read `photo_path` before writing (one extra select).
- Extras without a `starts_at` (a server without task-17's migration) keep the old count
  wording, so the app works against hosted before that migration is applied.
- zsh does not word-split `$files`: pipe file lists to `xargs dart format`.
