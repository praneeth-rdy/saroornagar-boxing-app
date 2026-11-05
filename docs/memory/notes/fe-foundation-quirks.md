# fe foundation quirks (2026-11-05, run 1 task-06)

- `Supabase.initialize(anonKey:)` is deprecated in supabase_flutter 2.18.3; `main` passes the
  config's anon key as `publishableKey:`.
- `package:http` is only transitive, so `ClientException` is matched by its `toString()`
  prefix in `supabase_errors.dart` rather than adding `http` as a dependency.
- Riverpod 3 exports `Override` and `ProviderException` from `package:flutter_riverpod/misc.dart`,
  not the main library. A provider reading a failed provider gets the error wrapped in
  `ProviderException`; `AsyncValueView` unwraps it before choosing the view.
- `pumpAndSettle` never returns while a `CircularProgressIndicator` is on screen: the bare
  `App` route shows one, so `pumpApp(tester, settle: false)` exists.
- `InputDecoration.prefixText` only shows when focused or filled; `AppTextField` renders the
  prefix as a `prefixIcon` so `+91` is always visible.
- In a static proof the busy `PrimaryButton` spinner captures as a dot (animation frame 0).
