# App architecture (fe)

The module map of the Flutter app. Whoever adds, removes or renames a file, provider or route
updates the matching row in the same change.

## State (2026-11-05)

Foundation (run 1 task-06): config, Supabase bootstrap, error mapping, theme A tokens, widget
kit, router skeleton with one placeholder route, test support and the proofs harness. No
features yet. Dependencies: flutter_riverpod 3.4.3, go_router 18.1.3, supabase_flutter
2.18.3, intl 0.20.3, freezed_annotation 3.1.0, json_annotation 4.12.0; dev build_runner
2.17.1, freezed 4.0.3, json_serializable 6.15.2. Inter 4.1 (OFL) bundled under
`assets/fonts/`.

## Module map

| Area | Files | Notes |
|---|---|---|
| Bootstrap | `lib/main.dart`, `lib/app.dart` | `main` reads `AppConfig`; unconfigured -> `MisconfiguredApp`, else `Supabase.initialize` (publishable key) and `ProviderScope` overriding `appConfigProvider`. `App` = theme + `routerProvider`. |
| Config | `lib/core/config/app_config.dart` | `AppConfig.fromEnvironment()`, `isConfigured`, `AppEnv` (`dev` default, `prod`), `appConfigProvider`. |
| Errors | `lib/core/errors/app_exception.dart` | Sealed `AppException`: `Validation`, `Permission`, `NotFound`, `Duplicate`, `Offline`, `AuthFailed`, `Unknown`, each with `defaultMessage`. |
| Supabase | `lib/core/supabase/supabase_errors.dart`, `supabase_client_provider.dart` | `mapSupabaseError` (BXVAL/BXPRM/BXNTF/BXDUP/BXERR, 42501/PGRST301, auth, offline), `guardSupabase`, `supabaseClientProvider`. |
| Models | `lib/core/models/{session_slot,attendance_status,trainee_status,payment_method,staff_role}.dart` | Plain enums mirroring the Postgres enums: `wire`, `fromWire` -> `unknown` fallback; `SessionSlot.label`. |
| Theme | `lib/core/theme/{app_colors,app_spacing,app_radius,app_sizes,app_typography,app_theme}.dart` | Direction A tokens; `app_sizes` holds component dimensions (control 52, tap target 44, row 64, avatar 40). `AppTheme.light()` only. |
| Widget kit | `lib/core/widgets/{primary_button,secondary_button,link_button,app_text_field,choice_row,avatar_initials,list_row,app_card,eyebrow,inline_banner,state_views,async_value_view}.dart` | `PrimaryButton` and `SecondaryButton` take `isBusy`; `AppTextField` takes a `suffix` control. `state_views`: `LoadingView`, `EmptyView`, `ErrorView`, `PermissionDeniedView`. `ListRow.divide` puts hairlines between rows in an `AppCard(padding: EdgeInsets.zero)`. |
| DI | `lib/core/di/repository_providers.dart` | `authRepositoryProvider` (Supabase implementation; tests override with the mock). |
| Router | `lib/core/router/routes.dart`, `route_guards.dart`, `app_router.dart` | `Routes` constants; pure `redirectFor(hasSession, location)` (public: `/sign-in`, `/trial` and below); `routerProvider` built once, `refreshListenable` = a `ValueNotifier<bool>` fed by `ref.listen(sessionProvider)`, `StatefulShellRoute.indexedStack` with four branches. |
| Auth | `lib/features/auth/domain/staff_profile.dart` (+ `.freezed.dart`, `.g.dart`), `data/auth_repository.dart`, `data/supabase_auth_repository.dart`, `presentation/{auth_providers,sign_in_screen,blocked_screen,sign_out_button}.dart` | `StaffProfile` (`isAdmin`); `AuthRepository` (`hasSession`, `sessionChanges`, `signIn`, `signOut`, `currentProfile` = `rpc('current_profile')`); phone sign-in as `+91...` through `signInWithPassword`. Providers: `sessionProvider` (stream, seeded with `hasSession`), `currentProfileProvider` (autoDispose), `signInControllerProvider` (`SignInController`, `AsyncValue<void>`), `signOutProvider`. `SignOutButton` = busy `SecondaryButton`, failure as a snackbar. |
| Shell | `lib/features/shell/presentation/shell_screen.dart` | Watches `currentProfileProvider`: loading -> `LoadingView`; `PermissionException` or `isBlocked` -> `BlockedScreen`; other errors -> `ErrorView` with retry; else `NavigationBar` (Today, Trainees, Trials, More) over the branch. |
| Tabs | `lib/features/{today,trainees,trials}/presentation/*_screen.dart`, `lib/features/more/presentation/more_screen.dart` | Today, Trainees, Trials are run 1 stubs (`EmptyView` "Coming next" with sign out); More shows the profile row and `SignOutButton`. |
| Utils | `lib/core/utils/phone_format.dart`, `validators.dart` | `formatPhone`, `normalizePhone` (same rule as `private.normalize_phone`); `requiredText`, `phoneText`, `passwordText` (8 chars to 72 bytes). |
| Startup | `lib/features/startup/presentation/misconfigured_screen.dart`, `misconfigured_app.dart` | Shown when the build has no Supabase URL or key. |
| Test support | `test/support/scenario.dart`, `test/support/mocks/mock_auth_repository.dart`, `test/support/fixtures/profiles.dart`, `test/helpers/pump_app.dart`, `test/proofs/proof_harness.dart` | `MockScenario` + `applyScenario`; `MockAuthRepository` (one valid pair, default `9000000001` / `admin-local-1234`; broadcast `sessionChanges`); fixtures `adminProfile`, `coachProfile`, `blockedCoachProfile`; `pumpApp` of the whole `App` needs an `authRepositoryProvider` override; `pumpApp` (`settle: false` for spinners); `renderProof` writes `test/proofs/out/<name>.png` (gitignored). |

## Routes

| Route | Screen | Guard |
|---|---|---|
| `/sign-in` | `SignInScreen` | public; with a session -> `/today` |
| `/today` | `TodayScreen` (shell branch 0, stub) | session, else `/sign-in` |
| `/trainees` | `TraineesScreen` (shell branch 1, stub) | session, else `/sign-in` |
| `/trials` | `TrialsScreen` (shell branch 2, stub) | session, else `/sign-in` |
| `/more` | `MoreScreen` (shell branch 3) | session, else `/sign-in` |
| `/trial` and below | none yet (run 2) | public |
