# Task 06 - App foundation: config, Supabase, errors, theme A, widget kit, proofs harness

- **Run:** `.claude/handoffs/2026-11-05-release-1-run-1/`
- **Area:** fe
- **Depends on:** none (server contracts are fixed by tasks 01-05)
- **Worker:** developer (Opus)
- **Tests:** yes (assistant)
- **Schema change approved by the owner:** n/a
- **Hosted apply:** n/a

## Goal
The app boots from `--dart-define` config, initialises Supabase, maps every server failure
to a typed `AppException`, and owns design direction A as theme tokens and a small widget
kit, so every feature screen that follows is built from the same parts. A proofs harness
renders any widget to a PNG for the Architect's screen review.

## Context the worker needs
- `fe/CLAUDE.md` entirely (Stack, Configuration, Layout, Non-negotiable rules, Server
  errors, Design, Conventions, Code guidelines). `docs/decisions.md`: design A tokens.
  Reference artboards: `docs/design/directions/project/A-Palette.dc.html`, `A-Today.dc.html`,
  `A-Trial.dc.html` (read them for proportions and spacing; the kit must reproduce their look).
- Error codes come from `be/supabase/migrations` (`BXVAL`, `BXPRM`, `BXNTF`, `BXDUP`) and the
  Edge Function body `code` (`BXERR` too).

## Files
- `fe/pubspec.yaml` - modify - dependencies below, `assets/fonts/` declaration, Inter font family
- `fe/assets/fonts/Inter-{Regular,Medium,SemiBold,Bold}.ttf` + `OFL.txt` - create - from the Inter release on GitHub (`rsms/inter`, OFL 1.1). If the download is impossible, fall back to the system font in the theme, keep the token, and say so in the summary.
- `fe/lib/main.dart` - modify - bootstrap
- `fe/lib/app.dart` - create - `App` widget: theme + router
- `fe/lib/core/config/app_config.dart` - create
- `fe/lib/core/errors/app_exception.dart` - create
- `fe/lib/core/supabase/supabase_errors.dart`, `supabase_client_provider.dart` - create
- `fe/lib/core/models/{session_slot,attendance_status,trainee_status,payment_method,staff_role}.dart` - create - enums with `unknown` fallback and `fromWire`/`wire`
- `fe/lib/core/theme/{app_colors,app_spacing,app_radius,app_typography,app_theme}.dart` - create
- `fe/lib/core/widgets/` - create - `primary_button.dart`, `secondary_button.dart`, `link_button.dart`, `app_text_field.dart`, `choice_row.dart`, `avatar_initials.dart`, `list_row.dart`, `app_card.dart`, `eyebrow.dart`, `inline_banner.dart`, `state_views.dart` (`LoadingView`, `EmptyView`, `ErrorView`, `PermissionDeniedView`), `async_value_view.dart`
- `fe/lib/core/router/{routes,app_router}.dart` - create - routes constants and a `routerProvider` with a single `/` route rendering `LoadingView` (task-07 fills it)
- `fe/lib/features/startup/presentation/misconfigured_screen.dart` - create
- `fe/lib/core/utils/{phone_format,validators}.dart` - create
- `fe/test/support/scenario.dart`, `fe/test/helpers/pump_app.dart`, `fe/test/proofs/proof_harness.dart` - create
- `fe/.gitignore` - modify - add `test/proofs/out/`
- `docs/fe/architecture.md` - modify - module map rows

## Spec

### Dependencies (`flutter pub add`, latest stable on 2026-11-05; record versions in the summary)
`flutter_riverpod`, `go_router`, `freezed_annotation`, `json_annotation`, `supabase_flutter`, `intl`; dev: `build_runner`, `freezed`, `json_serializable`. Reason: the stack table in `fe/CLAUDE.md`.

### `AppConfig`
`const AppConfig({required this.env, required this.supabaseUrl, required this.supabaseAnonKey})`; `factory AppConfig.fromEnvironment()` using `String.fromEnvironment('APP_ENV'|'SUPABASE_URL'|'SUPABASE_ANON_KEY')`; `bool get isConfigured` (url and key non-empty); `AppEnv` enum `dev | prod` parsed from `APP_ENV`, default `dev`. `appConfigProvider = Provider<AppConfig>` overridden in `main`.

### `main.dart`
`WidgetsFlutterBinding.ensureInitialized()`; config; if not configured -> `runApp(const MisconfiguredApp())` (plain MaterialApp with theme A and `MisconfiguredScreen`: title "App not configured", body "Run with --dart-define-from-file=config/dev.json.", no action); else `await Supabase.initialize(url:, anonKey:)` then `runApp(ProviderScope(overrides: [appConfigProvider.overrideWithValue(config)], child: const App()))`.

### Errors
`sealed class AppException implements Exception { final String message; }` with subclasses `ValidationException`, `PermissionException`, `NotFoundException`, `DuplicateException`, `OfflineException`, `AuthFailedException` (wrong phone or password), `UnknownException`. Each has a default user-facing message; the server message overrides it when present.
`supabase_errors.dart`: `AppException mapSupabaseError(Object error)`: `PostgrestException.code` `BXVAL|BXPRM|BXNTF|BXDUP` -> the matching subclass with the server message; `42501`/`PGRST301` -> `PermissionException`; `FunctionException` whose `details` is a map with `code` -> same mapping (`BXERR` -> `UnknownException`); `AuthException` with `invalid_credentials`/status 400 -> `AuthFailedException`, `AuthRetryableFetchException` -> `OfflineException`; `SocketException`, `ClientException`, `TimeoutException` -> `OfflineException`; `AppException` passes through; anything else -> `UnknownException`. Plus `Future<T> guardSupabase<T>(Future<T> Function() run)` that awaits and rethrows through the mapper. Repositories use it.

### Enums (`core/models`)
Each: values plus `unknown`; `static X fromWire(String? value)` (unknown on null or unmatched); `String get wire`. `SessionSlot` also has `String get label` (`Morning`, `Evening`, `Extra`). Plain enums, no codegen.

### Theme A tokens
`AppColors`: `ground #F5F5F7`, `surface #FFFFFF`, `ink #1D1D1F`, `muted #6E6E73`, `line #E5E5EA` (hairline only inside lists), `accent #0A5FD6`, `accentPressed #084BAA`, `accentSoft #E8F0FC` (selected chip fill), `negative #B3261E`, `negativeSoft #FBEAE8`, `positive #1E7F4F` (present mark only), `onAccent #FFFFFF`. `AppSpacing`: `xs 4, sm 8, md 12, lg 16, gutter 20, xl 24, xxl 32`. `AppRadius`: `card 16, control 12, chip 999`. `AppTypography` (Inter): `eyebrow` 12/600 uppercase letter-spacing 0.8 muted, `title` 28/700 ink, `heading` 20/600, `body` 16/400, `bodyStrong` 16/600, `label` 14/500, `caption` 13/400 muted. `AppTheme.light()`: `ThemeData` with `useMaterial3: true`, `scaffoldBackgroundColor ground`, `colorScheme` from the tokens, `fontFamily 'Inter'`, `textTheme` mapped from the typography, `AppBarTheme` ground, no elevation, no shadows anywhere, `NavigationBarTheme` surface with accent indicator, `InputDecorationTheme` filled surface, radius `control`, no border except a 1.5 accent border when focused and `negative` on error, `FilledButtonTheme` accent/onAccent radius `control` min height 52, `ChipTheme` from `choice_row`. Light only; no dark theme.

### Widget kit (all `const`-friendly, tokens only, no literals)
- `PrimaryButton({label, onPressed, isBusy = false, isExpanded = true})`: filled accent, 52 high, spinner replaces the label while busy, disabled when `onPressed == null` or busy.
- `SecondaryButton`: surface fill, ink text, same shape. `LinkButton({label, onPressed})`: accent text, 44 min height.
- `AppTextField({controller, label, hint, keyboardType, obscureText, errorText, prefixText, textInputAction, onSubmitted, maxLength, enabled})`: label above the field in `label` style, field surface fill, error text in `negative` below.
- `ChoiceRow<T>({options: List<ChoiceOption<T>> (value, label, caption?)}, selected, onSelected})`: horizontally wrapped pills, selected one accent fill + onAccent text, others surface + ink; 44 min height.
- `AvatarInitials({name, photoUrl?, size = 40})`: circle `accentSoft` with up to two initials in accent; shows the image when a url is given.
- `ListRow({leading, title, subtitle, trailing, onTap})`: 64 min height, surface, title `bodyStrong`, subtitle `caption`; rows stacked inside an `AppCard` with `line` hairlines between them; ripple only when `onTap != null`.
- `AppCard({child, padding})`: surface, radius `card`, no border, no shadow.
- `Eyebrow(text)`: `eyebrow` style. `InlineBanner({message, tone: info | error, onRetry?})`: soft fill, one line of text, optional retry link.
- State views, each centred with title + body + optional action: `LoadingView()`, `EmptyView({title, message, actionLabel?, onAction?})`, `ErrorView({message, onRetry})`, `PermissionDeniedView({message, onBack?})`.
- `AsyncValueView<T>({value: AsyncValue<T>, data: Widget Function(T), onRetry, isEmpty: bool Function(T)?, empty: Widget?})`: loading -> `LoadingView`; error -> `PermissionDeniedView` for `PermissionException`, `ErrorView` otherwise with the exception message and retry; data -> `empty` when `isEmpty?.call(data) == true`, else `data(value)`.

### Utils
`formatPhone(String digits)` -> `+91 98765 43210` for 12-digit `91...`, else the input; `normalizePhone(String input)` -> `91` + 10 digits or null when invalid; `validators.dart`: `String? requiredText(String? v, {String label})`, `String? phoneText(String?)` ("Enter a 10-digit mobile number"), `String? passwordText(String?)` (8 to 72).

### Test support (worker creates; assistant extends)
- `test/support/scenario.dart`: `enum MockScenario { success, empty, slow, error, permissionDenied, offline }` and `Future<T> applyScenario<T>(MockScenario s, {required T Function() success, T Function()? empty})`: `slow` waits 2 s then succeeds; `error` throws `UnknownException`; `permissionDenied` throws `PermissionException`; `offline` throws `OfflineException`; `empty` returns `empty()` (or `success()` when null).
- `test/helpers/pump_app.dart`: `Future<void> pumpApp(WidgetTester tester, {List<Override> overrides = const [], Widget? home})`: wraps in `ProviderScope` + `MaterialApp(theme: AppTheme.light())` (or the full `App` when `home` is null) and settles.
- `test/proofs/proof_harness.dart`: `Future<void> renderProof(WidgetTester tester, String name, Widget child, {Size size = const Size(390, 844)})`: loads Inter from `assets/fonts` with `FontLoader` once, sets the view size and device pixel ratio 2, pumps the widget inside `MaterialApp(theme: AppTheme.light())` wrapped in a `RepaintBoundary`, captures it with `tester.runAsync` + `toImage`, writes `test/proofs/out/<name>.png`. Never a golden comparison; the test passes when the file is written. `out/` is gitignored.

### Router skeleton
`routes.dart` with `class Routes { static const signIn = '/sign-in'; today = '/today'; trainees = '/trainees'; trials = '/trials'; more = '/more'; trial = '/trial'; }`. `routerProvider = Provider<GoRouter>` with `initialLocation: Routes.today` and a single `GoRoute(path: '/')`... no: a single route `Routes.today` rendering `const LoadingView()`; task-07 replaces it. `App` is a `ConsumerWidget` building `MaterialApp.router(theme: AppTheme.light(), routerConfig: ref.watch(routerProvider))`.

## Out of scope
Sign-in, auth repository, shell, feature screens (task-07 and run 2). Dark theme. Any `shared_preferences` or storage dependency (run 2 adds it with the trial flow).

## Acceptance criteria
- [ ] `flutter analyze` reports no issues; `dart format` clean on touched files; codegen not needed yet (no freezed models in this task).
- [ ] `flutter test` passes (assistant tests: enum `fromWire` fallback, `mapSupabaseError` for every code and the offline cases, `AppConfig.isConfigured`, `normalizePhone`/`formatPhone`, `AsyncValueView` renders each state, `applyScenario` behaviours, and one `renderProof` smoke writing a PNG of a kit gallery widget built inside the test).
- [ ] No colour, size or text-style literal outside `lib/core/theme`.
- [ ] `flutter run --dart-define-from-file=config/dev.json` boots to the loading screen; running without defines shows the misconfigured screen (worker checks the second one in a widget test if a device run is not possible).
- [ ] `docs/fe/architecture.md` module map lists every new file group.

## Verification
From `fe/`: `flutter pub get`, `flutter analyze`, `flutter test`, `dart format --output=none --set-exit-if-changed <touched files>`. Proofs: `flutter test test/proofs`.
