# Task 03 - Trials: public booking and the staff list

- **Run:** `.claude/handoffs/2026-11-05-release-1-run-2/`
- **Area:** fe
- **Depends on:** task-02
- **Worker:** developer (Opus)
- **Tests:** yes (assistant)
- **Schema change approved by the owner:** n/a
- **Hosted apply:** n/a

## Goal
A visitor books a trial session from the app without an account, sees the booking they
made, and staff see every upcoming trial visitor by day and batch.

## Context the worker needs
- `fe/CLAUDE.md`; both `plan.md` files. Reference artboard
  `docs/design/directions/project/A-Trial.dc.html` (layout, chips, copy structure). Product:
  no confirmation step; the booking only informs the coach. The artboard's line "The club
  confirms your slot" is wrong; use the copy below.
- Server: `book_trial(p_full_name, p_phone, p_session_date, p_slot, p_device_key,
  p_date_of_birth?, p_age?, p_note?)` and `my_trial_bookings(p_device_key)` callable with the
  anon key; `trial_bookings_between(p_from, p_to)` for staff. Every `BXVAL`/`BXDUP` message
  in `docs/memory/notes/be-attendance-trials.md`; the mock copies them.
- New dependency `shared_preferences` for the device key.
- `TrialBooking` model exists from task-01.

## Files
- `fe/pubspec.yaml` - modify - `shared_preferences`
- `fe/lib/features/trials/domain/trial_request.dart` (+ generated) - create
- `fe/lib/features/trials/data/{trial_repository,supabase_trial_repository,device_key_store}.dart` - create
- `fe/lib/features/trials/presentation/{trial_providers,book_trial_screen,trial_booked_screen,trials_screen}.dart` - create (replace the stub)
- `fe/lib/features/auth/presentation/sign_in_screen.dart` - modify - "Want to try a session? Book a trial" link
- `fe/lib/core/router/{routes,app_router}.dart`, `route_guards.dart` (public prefix already handled), `fe/lib/core/di/repository_providers.dart` - modify
- `fe/test/support/mocks/{mock_trial_repository,mock_device_key_store}.dart` - create
- `docs/fe/architecture.md` - modify

## Spec
### Data
`DeviceKeyStore` (interface + `SharedPreferencesDeviceKeyStore`): `Future<String> key()` returns the stored 32-char random key or creates one (`Random.secure`, base32-like alphabet). `TrialRequest(fullName, phone, sessionDate, slot, dateOfBirth?, age?, note?)`.
```dart
abstract class TrialRepository {
  Future<TrialBooking> book(TrialRequest request, String deviceKey);   // book_trial
  Future<List<TrialBooking>> mine(String deviceKey);                   // my_trial_bookings
  Future<List<TrialBooking>> between(DateTime from, DateTime to);      // trial_bookings_between (staff)
}
```
Mock: enforces the server order of checks and messages, `DuplicateException` on phone+date+slot, `mine` filters by key and date.

### Public routes (no session needed; `redirectFor` already treats `Routes.trial` and below as public)
- `Routes.trial = '/trial'` -> `BookTrialScreen`; `Routes.trialBooked = '/trial/booked'` -> `TrialBookedScreen` (receives the booking as `extra`; on a cold start without `extra` it redirects to `/trial`).
- `BookTrialScreen`: ground background, back arrow only when there is a route to pop; `Eyebrow('SAROORNAGAR BOXING')`, `title` "Try a session", caption "Pick a day and a batch. The coach will be expecting you."; `AppTextField` Name, Phone (`+91 ` prefix, 10 digits); `Eyebrow('DAY')` + `ChoiceRow` of the next 7 non-Sunday days from today (label `EEE d`, caption `MMM`); `Eyebrow('BATCH')` + `ChoiceRow` Morning (caption "6:00 to 8:30 am") / Evening (caption "5:30 to 8:00 pm"); `Eyebrow('YOUR AGE')` + numeric `AppTextField` Age (3 to 99) with a `LinkButton('Use date of birth instead')` that swaps in a date picker field (one of the two is required); `Eyebrow('ANYTHING WE SHOULD KNOW (OPTIONAL)')` + multiline note (300 max); `PrimaryButton('Book trial')`; below it `LinkButton('Already train here? Sign in')` -> `Routes.signIn`. Server errors in an `InlineBanner` above the button (`DuplicateException` message as given). When `mine` returns upcoming bookings, a card "Your bookings" sits under the title listing them (date, batch) so a returning visitor is not confused.
- `TrialBookedScreen`: `title` "You're booked", body "Come to the club on `EEEE d MMMM` for the `Morning` batch (6:00 to 8:30 am). Ask for the coach when you arrive.", `PrimaryButton('Done')` -> `Routes.trial`, `LinkButton('Book another day')`.
- `SignInScreen` gains `LinkButton('Want to try a session? Book a trial')` under the sign-in button -> `Routes.trial`.

### Staff tab
`TrialsScreen` (`Routes.trials`): `AppBar` "Trials" with a "Book for someone" text action -> `Routes.trial` (pushed; the public form works while signed in). Content: `between(today, today + 30)` grouped by day: `Eyebrow` per day (`EEEE d MMMM`, "TODAY" for today), one `AppCard` per day with `ListRow`s (name; subtitle "Morning · +91 98765 43210"; caption age or DOB and the note). Empty: `EmptyView(title: 'No trials booked', message: 'Bookings made in the app appear here for the next 30 days.', actionLabel: 'Book for someone')`. Pull to refresh.

## Out of scope
Cancel, capacity, confirmation, reminders (open product points). Calling the visitor from the app (no `url_launcher` yet).

## Acceptance criteria
- [ ] Analyzer, format, codegen clean; generated files committed.
- [ ] Unit: device key is created once and reused; `redirectFor` for `/trial/booked` without a session is null; mock errors match the backend messages.
- [ ] Widget: day chips skip Sunday; age/DOB swap enforces one of the two; duplicate booking shows the server message; success navigates to the booked screen.
- [ ] Flow: cold start without a session -> sign-in -> "Book a trial" -> fill -> booked -> Done; signed-in staff see the booking in Trials.
- [ ] Proofs: booking form (empty, filled, with the duplicate error, with "Your bookings"), booked screen, Trials tab (empty, typical 2 days, heavy 10 days).

## Verification
As task-01.
