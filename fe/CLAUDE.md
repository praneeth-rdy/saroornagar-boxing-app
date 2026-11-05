# Boxing club app (Flutter)

The Android app for a boxing club in Saroornagar: coaches take, view and manage trainee
attendance; people book trial sessions. Product scope and the open questions live in
`../docs/product.md`; do not assume a role, flow or rule that file does not state.

- Current state: `../docs/memory/current.md`, always. It is rewritten at the end of every work
  session, so trust it over any date written into this file. `../docs/backlog.md` lists what is
  done and what is left.
- This folder holds frontend code only. Server logic, SQL and Supabase configuration go to
  `../be`; if a task needs them, say so and stop at the boundary. A change that needs both a
  schema change and an app change is two packages: `be` first (owner approves the schema), then
  `fe`.

## Stack

| Layer | Choice |
|---|---|
| App | Flutter stable (3.47.7+, Dart 3.13.5+), Riverpod 3, go_router, freezed + json_serializable (generated files committed), supabase_flutter, intl |
| Backend | Supabase: Postgres, Auth, Storage; RLS + Postgres functions called with `rpc()`. Lives in `../be`. |
| Lints | `flutter_lints` + `prefer_single_quotes`, `avoid_print`, `require_trailing_commas` (`analysis_options.yaml`) |

Android only for now. The Android application id is still the Flutter default
(`com.example.saroornagar_boxing`) until the owner decides one; it changes in
`android/app/build.gradle.kts` before any release build. New dependencies only through a
handoff package that names the reason and the version; add the packages above when the first
package needs them.

## Configuration (env files)

Runtime configuration reaches the app only through `--dart-define`, read in
`lib/core/config/app_config.dart` (to be created with the first feature). The values live in
JSON files under `config/` and are passed with `--dart-define-from-file`:

| File | Purpose |
|---|---|
| `config/dev.json` | `APP_ENV=dev`, the hosted Supabase project: the one development database for every run and test on a device. |
| `config/prod.json` | `APP_ENV=prod`, the production Supabase project (the same project until a second one exists). Release builds only. |
| `config/*.local.json` | Personal overrides, gitignored. |

Keys: `APP_ENV` (`dev` | `prod`), `SUPABASE_URL`, `SUPABASE_ANON_KEY`. Only the
anon/publishable key may appear in these files; the `service_role` key never does. A new
configurable value is a new key in both files plus a field on `AppConfig`; nothing is
hard-coded in a screen or repository. A build without a URL and key shows a misconfigured
screen, never a mock backend.

## Layout (target; create folders as features land)

```
config/        dev.json, prod.json (see Configuration)
lib/main.dart, app.dart
lib/core/
  config/      AppConfig from --dart-define
  di/          repository providers (Supabase implementations; tests override them)
  supabase/    SDK bootstrap, client provider, SQLSTATE -> AppException mapping, row helpers
  router/      routes, pure redirect rules (route_guards.dart), GoRouter
  theme/       colour, spacing, typography tokens, ThemeData
  widgets/     shared UI kit (buttons, fields, chips, list rows, nav bar, state views)
  models/      shared enums with parse-safe `unknown` fallbacks
  errors/      AppException hierarchy
  utils/       formatters, validators
lib/features/<feature>/{domain,data,presentation}
test/          unit, widget and flow tests against the mock test doubles in test/support/ (helpers/ has the harness; proofs/ the screenshot harness)
android/       platform project
```

Each feature's `data/` holds a repository interface and a `supabase_*_repository.dart`; the
mock implementations live under `test/support/mocks/` as test doubles. Screens depend on the
interface only. `../docs/fe/architecture.md` is the module map.

## Commands

All from `fe/`.

| Purpose | Command | Notes |
|---|---|---|
| Deps | `flutter pub get` | |
| Codegen | `dart run build_runner build --delete-conflicting-outputs` | After editing freezed / json models. Commit the generated files. |
| Static analysis | `flutter analyze` | Baseline: see `../docs/memory/current.md`. Don't add new issues. |
| Tests | `flutter test` | Mock test doubles. `test/` mirrors `lib/` for unit tests; `*_flow_test.dart` boot the whole app. |
| Format | `dart format --output=none --set-exit-if-changed <touched files>` | Never a bare `dart format lib test` on files you did not touch. |
| Run (dev) | `flutter run --dart-define-from-file=config/dev.json` | The hosted development database. |
| Build (release) | `flutter build apk --release --dart-define-from-file=config/prod.json` | |
| Smoke build | `flutter build apk --debug` | |

## Non-negotiable rules

- **The server decides.** Attendance records, booking state, membership state and admin rights
  change only in Postgres functions (called with `rpc()`) or Edge Functions. The app never
  writes status columns directly and never assumes a transition succeeded: it renders what the
  server returns.
- **Test doubles follow server rules.** When a server rule changes in `../be`, update the
  matching mock under `test/support/mocks/` so the tests assert the real rule.
- **No secrets in code or the repo.** Only the Supabase anon/publishable key may reach the
  app, and only through the config files.
- **Privacy.** A trainee's phone number, attendance history and notes are visible only to the
  club's staff and to that trainee; never to another trainee.
- **Honest UI.** Stats and counts come from real data only, never placeholders shown as fact.
- **Supabase MCP has full access to the hosted project** for development. Schema changes
  still go through `../be` migration files, applied to hosted only on the owner's say-so.

## Server errors

Postgres functions raise custom SQLSTATEs that `lib/core/supabase/supabase_errors.dart` maps
to `AppException`s: `BXVAL` (validation), `BXPRM` (permission), `BXNTF` (not found), `BXDUP`
(duplicate, e.g. attendance already marked or a slot already booked). A new server error
reuses these codes; a new code is added in both areas together with its mapping and UI copy.

## Design

- The design direction is chosen by the owner from the design-directions canvas (see
  `../docs/decisions.md` once decided) and encoded as tokens in `lib/core/theme`.
- Use the tokens in `lib/core/theme` and the widgets in `lib/core/widgets`. Never hard-code
  colours or text styles in a screen.
- Tab roots open with `go`, never `push`; a notification tap rebuilds the stack with the
  owning tab at the root.
- Everything that looks tappable acts; nothing that acts looks static. Every screen has a next
  action in its empty state.

## Architecture

Canonical description: `../docs/fe/architecture.md`. Short version: `main.dart` bootstraps
Supabase from `AppConfig` and runs the app inside a `ProviderScope`; the app widget owns only
the theme and the GoRouter. Every feature exposes a repository interface in `data/`; a
`<feature>RepositoryProvider` provides the Supabase implementation, overridden by tests.
Screens watch `FutureProvider.autoDispose(.family)` or `Notifier` providers in
`presentation/*_providers.dart` and render through `AsyncValueView` and the state views.
Redirect rules are pure functions in `route_guards.dart` with their own unit tests.

## Conventions

- Styling comes from `lib/core/theme` only and the shared kit in `lib/core/widgets`. New UI
  references tokens, never colour or size literals.
- Use `.withValues(alpha: x)`; `withOpacity` is deprecated and must not appear in `lib/`.
- Repositories throw `AppException` subclasses only; the Supabase layer maps SDK and SQLSTATE
  errors in `lib/core/supabase/supabase_errors.dart`. Screens never catch raw exceptions: they
  render `AsyncValue` through `AsyncValueView` / `ErrorView` / `PermissionDeniedView` /
  `EmptyView` / `LoadingView`, each with a retry where it makes sense.
- Every screen or flow covers loading, empty, error, permission-denied and retry states; the
  test doubles' scenario switch (success / empty / slow / error / permission denied / offline)
  exercises each one in tests.
- Models are freezed classes with `fromJson`; shared enums parse unknown wire values to an
  `unknown` member instead of throwing. Run codegen after editing them and commit the output.
- Configuration comes from `AppConfig`; no URL, key, flag or environment name is written into a
  feature file.
- Tests: unit tests mirror `lib/` paths under `test/`; flow tests boot the whole app with the
  harness under `test/helpers/`; widget tests wrap with the shared pump helper. Override
  providers through `ProviderScope` overrides, never by editing production code.

## Code guidelines

These apply to every tier and every file in this folder (Dart, tests).

### Naming
- Dart: `lowerCamelCase` for variables, functions, parameters; `UpperCamelCase` for types and
  enums; `snake_case.dart` for files.
- **Local variables and parameters never start with `_`.** A leading underscore is reserved for
  library-private members and private widget/state classes.
- Names say what the thing is, not its type: `trainees` not `traineeList`, `status` not
  `statusEnum`. No Hungarian prefixes, no abbreviations.
- Booleans read as predicates: `isPresent`, `hasSlots`. Functions read as verbs:
  `markAttendance()`, `bookTrial()`. Getters are nouns.
- Providers end in `Provider` and live in the feature's `presentation/*_providers.dart`.
  Repository interfaces end in `Repository`, mocks start with `Mock`, Supabase implementations
  with `Supabase`.
- Single-letter names only for trivial loop indices and lambda params that are obvious.

### Structure
- One widget, provider group, repository, or model per file, named after the file.
- Functions do one thing and stay short (aim for under 40 lines). If a `build()` needs a
  section, extract a widget class, not a `_buildX()` method, whenever the piece is reused, has
  its own state, or is more than ~30 lines.
- Widgets: `const` constructors wherever possible, `super.key`, prefer `StatelessWidget` /
  `ConsumerWidget`. Scope `ref.watch` to the smallest provider that carries the needed value.
- Providers hold state and orchestration only; they do not import widgets or `BuildContext`.
  Repositories talk to the backend; screens talk to providers. Keep that layering.
- Models are immutable: freezed, `const` constructors, `copyWith` from codegen.
- Dispose what you create: controllers, focus nodes, streams, timers. Prefer `autoDispose`
  providers for screen-scoped data.
- No magic numbers in widget trees: name reused constants or use the tokens.

### Error handling
- Never leave an empty `catch`. Either handle it, surface it, or write a one-line comment
  saying why ignoring is correct.
- No `print`. Use `debugPrint` if a message is truly needed, otherwise nothing.
- Don't throw across the UI boundary; the repository layer converts failures into
  `AppException`s and the provider layer into `AsyncValue`s.

### Comments and prose
- Comment the *why*, never the *what*. Delete comments that restate the code.
- Comments are short: one line, two at most. No banners, no section dividers.
- **Never write the user's request or conversation into comments.** Code carries no memory of
  who asked for it; that context lives in git history and handoff files.
- `///` doc comments on public API only, one sentence, no boilerplate.
- **No em-dashes** in code comments, doc comments, user-facing strings, handoff packages, or
  reports. No emoji. Plain ASCII punctuation.
- `TODO` comments need context.

### Simplicity and robustness
- Prefer the simplest implementation that fully meets the acceptance criteria. No abstractions,
  config knobs, or extension points for needs that do not exist yet.
- Robust means handling the failure cases that can actually happen (offline, a duplicate mark,
  a permission denial, an unknown enum value from the server) with a clear fallback, not
  wrapping everything in defensive checks.
- Do not add layers to code that works fine flat. When in doubt between clever and obvious,
  pick obvious.

### Accuracy (no hallucinating)
- Only call APIs, packages, classes, methods and server functions you have verified exist:
  read the file, check `pubspec.lock`, read the migration in `../be`. Never invent a method or
  an `rpc()` name because it sounds right.
- Read a file before editing it. Never edit from memory of what it "probably" contains.
- If a fact is unknown, find out or say so. Workers return `BLOCKED` with the question rather
  than guessing; the Architect does not present unverified claims in reviews or reports.
- Report outcomes as they are: if `flutter analyze` or `flutter test` was not run, say so.

### Formatting and hygiene
- Run `dart format` on every touched Dart file. Trailing commas on multi-line argument lists.
- Imports: `dart:` then `package:` then relative, each group sorted, no unused imports. Use
  relative imports inside `lib/`; tests import `package:saroornagar_boxing/...`.
- Never commit environment or build files (`build/`, `.dart_tool/`, `.env*`, keystores,
  `config/*.local.json`). Do commit `*.freezed.dart` and `*.g.dart`.
- Match the surrounding code's style when editing an existing file; do not reformat code you
  were not asked to change.

### Tests
- Test names describe behaviour: `test('markAttendance throws DuplicateMark when already
  marked today', ...)`.
- Arrange / act / assert, one behaviour per test, no logic in tests.
- Mock at the boundary (repository provider overrides, the scenario switch), never by editing
  production code.

## Agent workflow

The product is worked on from the repo root, whose `.claude/CLAUDE.md` holds the tier split
(Fable as Architect, Opus `developer`, Sonnet `assistant`; Haiku never), the routing and git
rules, the agents, the `/build` skill, the `tiered-build` workflow and the handoff packages.
This file is the app's conventions and is loaded whenever work touches files here.

- Any change under `lib/`, `android/` or `test/` goes to the `developer` agent with a handoff
  package, even one-liners. The Architect edits `config/`, `pubspec.yaml` metadata and docs
  directly.
- Server work is out of this folder: a table, column, policy, function or SQLSTATE is proposed
  to the owner and planned as a `be` package first; the `fe` package follows, changing the
  Supabase repository and the mock repository together.
- Tests, codegen, smoke checks, proofs, sweeps and log triage go to the `assistant`.
