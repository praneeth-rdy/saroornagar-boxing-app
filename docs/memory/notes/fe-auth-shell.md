# fe auth and shell (2026-11-05, run 1 task-07)

- `routerProvider` must not `ref.watch(sessionProvider)`: that rebuilds the GoRouter and drops
  the navigation stack. It uses `ref.listen` into a `ValueNotifier<bool>` as `refreshListenable`.
- `redirectFor` checks `/trial` by whole segment; a plain `startsWith('/trial')` also matches
  the staff tab `/trials`.
- `SignInController` checks `ref.mounted` after the await: a successful sign-in redirects,
  which disposes the autoDispose controller before the state write.
- `InlineBanner` is one line with ellipsis; the offline copy on sign-in ("You are offline.
  Check the connection and try again.") likely truncates at phone width. Check the proof.
- A signed-in user with no profile row (self sign-up, `BXNTF`) gets `ErrorView` with retry
  and no sign-out: a dead end the package left open.
- Kit additions for this task: `SecondaryButton.isBusy`, `AppTextField.suffix`.
