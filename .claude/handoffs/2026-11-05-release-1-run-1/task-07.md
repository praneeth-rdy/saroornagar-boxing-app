# Task 07 - Sign-in, blocked state, tab shell and route guards

- **Run:** `.claude/handoffs/2026-11-05-release-1-run-1/`
- **Area:** fe
- **Depends on:** task-06
- **Worker:** developer (Opus)
- **Tests:** yes (assistant)
- **Schema change approved by the owner:** n/a
- **Hosted apply:** n/a

## Goal
A coach or admin signs in with phone and password, lands on the Today tab of a four-tab
shell (Today, Trainees, Trials, More), sees their own profile and signs out from More, and a
blocked user sees a blocked screen instead of the app.

## Context the worker needs
- `fe/CLAUDE.md`; task-06's kit, errors and router skeleton; `plan.md` (phone format, phone
  + password auth, blocking semantics). Server: `be/supabase/migrations/*_identity.sql`:
  `rpc('current_profile')` returns `{id, full_name, phone, role, is_blocked, created_at,
  updated_at}` or `BXNTF`; `profiles.role` is `admin | coach`.
- Reference artboards for look and spacing: `docs/design/directions/project/A-Today.dc.html`
  (bottom nav and header), `A-Trial.dc.html` (form layout the sign-in screen mirrors).

## Files
- `fe/lib/core/models/staff_role.dart` - exists from task-06 (`admin`, `coach`, `unknown`)
- `fe/lib/features/auth/domain/staff_profile.dart` (+ `.freezed.dart`, `.g.dart`) - create
- `fe/lib/features/auth/data/auth_repository.dart`, `supabase_auth_repository.dart` - create
- `fe/lib/core/di/repository_providers.dart` - create - `authRepositoryProvider`
- `fe/lib/features/auth/presentation/auth_providers.dart`, `sign_in_screen.dart`, `blocked_screen.dart` - create
- `fe/lib/features/shell/presentation/shell_screen.dart` - create
- `fe/lib/features/today/presentation/today_screen.dart`, `features/trainees/presentation/trainees_screen.dart`, `features/trials/presentation/trials_screen.dart` - create - temporary stubs (run 2 replaces them)
- `fe/lib/features/more/presentation/more_screen.dart` - create
- `fe/lib/core/router/route_guards.dart` - create; `app_router.dart` - modify
- `fe/test/support/mocks/mock_auth_repository.dart`, `fe/test/support/fixtures/profiles.dart` - create
- `docs/fe/architecture.md` - modify - module map and routes

## Spec

### Model
`StaffProfile` (freezed, `fromJson`): `id`, `fullName` (`full_name`), `phone`, `role` (`StaffRole`, via a `JsonKey` converter using `fromWire`), `isBlocked` (`is_blocked`), `createdAt`, `updatedAt`. Getter `isAdmin`.

### Repository
```dart
abstract class AuthRepository {
  bool get hasSession;
  Stream<bool> get sessionChanges;          // emits on sign-in and sign-out
  Future<void> signIn({required String phone, required String password}); // phone = 10 digits as typed
  Future<void> signOut();
  Future<StaffProfile> currentProfile();     // rpc('current_profile')
}
```
`SupabaseAuthRepository(SupabaseClient client)`: `signIn` normalises with `normalizePhone` (null -> throw `ValidationException('Enter a 10-digit mobile number')`), calls `client.auth.signInWithPassword(phone: '+$normalized', password: password)` inside `guardSupabase`; `signOut` -> `client.auth.signOut()`; `currentProfile` -> `client.rpc('current_profile')` parsed with `StaffProfile.fromJson`; `sessionChanges` maps `onAuthStateChange` to `session != null`, `distinct()`.

### Providers (`auth_providers.dart`)
`sessionProvider = StreamProvider<bool>` seeded with `hasSession` then `sessionChanges`; `currentProfileProvider = FutureProvider.autoDispose<StaffProfile>`; `signInControllerProvider = NotifierProvider.autoDispose<SignInController, AsyncValue<void>>` with `Future<void> submit({phone, password})` that sets loading, calls the repository, sets `AsyncError` with the `AppException` on failure (never rethrows); `signOutProvider` is a simple `Future<void> Function()` through the repository.

### Route guards (pure, unit-tested)
`String? redirectFor({required bool hasSession, required String location})`: public locations are `Routes.signIn` and anything under `Routes.trial`; no session and not public -> `Routes.signIn`; session and `location == Routes.signIn` -> `Routes.today`; else null. `app_router.dart` uses `ref.watch(sessionProvider)` through a `refreshListenable` (a `ChangeNotifier` driven by `sessionChanges`) and the guard. Routes: `Routes.signIn` -> `SignInScreen`; `StatefulShellRoute.indexedStack` with four branches (`Routes.today`, `Routes.trainees`, `Routes.trials`, `Routes.more`). Tab roots open with `go`.

### Screens
- `SignInScreen`: ground background, 20 px gutters, top `Eyebrow('SAROORNAGAR BOXING')`, `title` "Sign in", caption "Staff and coaches only.", `AppTextField` phone (`prefixText '+91 '`, `TextInputType.phone`, max 10, validator `phoneText`), password (`obscureText`, show/hide icon button with `aria`-style tooltip, validator `passwordText`), `InlineBanner(error)` above the button when the controller holds an error: `AuthFailedException` -> "That phone number and password do not match."; `OfflineException` -> "You are offline. Check the connection and try again."; other -> the exception message; `PrimaryButton('Sign in', isBusy: loading)`. Submit on keyboard done. On success the guard redirects (no manual navigation).
- `ShellScreen(navigationShell)`: watches `currentProfileProvider`; while loading show `LoadingView`; `PermissionException` or `profile.isBlocked` -> `BlockedScreen` (title "Access blocked", body "Ask the club admin to restore your access.", `SecondaryButton('Sign out')`); other errors -> `ErrorView` with retry (`ref.invalidate`); data -> `Scaffold` with the branch body and a `NavigationBar` (Today, Trainees, Trials, More; outlined icons `today`, `group`, `event_available`, `more_horiz`; selected = accent).
- Stubs (`TodayScreen`, `TraineesScreen`, `TrialsScreen`): `Scaffold` with `AppBar` title and `EmptyView(title: 'Coming next', message: '<Tab> arrives with the next update.', actionLabel: 'Sign out', onAction: signOut)`. One-line comment: run 2 replaces them.
- `MoreScreen`: `AppBar` "More"; `AppCard` with `ListRow(leading: AvatarInitials(name), title: fullName, subtitle: '${formatPhone(phone)} · ${role label}')` (use a middle dot `·`, not an em-dash); below it `SecondaryButton('Sign out')` that calls sign out and lets the guard redirect; while signing out the button is busy.

### Mock
`MockAuthRepository({MockScenario scenario = success, StaffProfile? profile, bool signedIn = false, String validPhone = '9000000001', String validPassword = 'admin-local-1234'})`: `signIn` applies the scenario, then throws `AuthFailedException` unless phone/password match, else sets signed in and emits; `signOut` clears and emits; `currentProfile` applies the scenario and returns `profile` (fixture `adminProfile`, `coachProfile`, `blockedCoachProfile` in `fixtures/profiles.dart`). `sessionChanges` is a broadcast `StreamController`.

## Out of scope
Real Today/Trainees/Trials content, the trial booking screen, staff management UI, password reset UI (run 2). Any new dependency.

## Acceptance criteria
- [ ] `flutter analyze` clean; `dart format` clean; generated files committed.
- [ ] `redirectFor` unit tests cover: no session on `/today` -> sign-in; no session on `/trial` and `/sign-in` -> null; session on `/sign-in` -> today; session on `/more` -> null.
- [ ] Sign-in widget tests: empty fields show validation; wrong credentials show the mismatch banner; offline scenario shows the offline banner; busy button while `slow`.
- [ ] Flow test: boot with `MockAuthRepository(signedIn: false)`, sign in with the valid pair, land on Today; sign out from More returns to sign-in. Second flow: `blockedCoachProfile` shows the blocked screen.
- [ ] Proofs written for `SignInScreen` (empty, filled, error) and `MoreScreen` (admin) and `BlockedScreen` via the task-06 harness.
- [ ] Mock and Supabase repositories expose the same surface; nothing in `lib/` imports the mock.

## Verification
From `fe/`: `dart run build_runner build --delete-conflicting-outputs`, `flutter analyze`, `flutter test`, `flutter test test/proofs`, `dart format --output=none --set-exit-if-changed <touched files>`.
