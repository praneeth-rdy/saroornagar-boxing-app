# Task 01 - Today: sessions of the day and attendance marking

- **Run:** `.claude/handoffs/2026-11-05-release-1-run-2/`
- **Area:** fe
- **Depends on:** run 1 complete
- **Worker:** developer (Opus)
- **Tests:** yes (assistant)
- **Schema change approved by the owner:** n/a
- **Hosted apply:** n/a

## Goal
The coach opens the app, sees today's batches, marks each trainee present or absent from the
full roster, corrects a mark, marks everyone left absent in one tap, adds an extra session
when needed, and sees which trial visitors booked that batch.

## Context the worker needs
- `fe/CLAUDE.md`; run-1 `plan.md`; this run's `plan.md`. Reference artboard:
  `docs/design/directions/project/A-Today.dc.html` (header, segment, progress, rows, sticky
  action, bottom nav).
- Server (`docs/be/architecture.md`, `docs/memory/notes/be-trainees-sessions.md`,
  `be-attendance-trials.md`): `ensure_day_sessions(p_date)`, `add_extra_session(p_date,
  p_starts_at, p_ends_at)`, `delete_extra_session(p_session_id)`, `session_roster(p_session_id)`,
  `mark_attendance(p_session_id, p_trainee_id, p_status)`, `mark_remaining_absent(p_session_id)`
  -> int, `trial_bookings_between(p_from, p_to)`.
- Not-staff state: `current_profile` raises `BXNTF` for a user without a profile (run-1
  task-08). The shell must show the blocked screen variant for `NotFoundException` with the
  copy "This account is not set up for staff." and a sign-out button.

## Files
- `fe/lib/features/today/domain/{club_session,roster_entry,attendance_mark}.dart` (+ generated) - create
- `fe/lib/features/today/data/{attendance_repository,supabase_attendance_repository}.dart` - create
- `fe/lib/features/today/presentation/{today_providers,today_screen,roster_row,session_segment,progress_card,extra_session_sheet,trial_visitors_card}.dart` - create (replace the stub)
- `fe/lib/features/trials/domain/trial_booking.dart` (+ generated) - create (shared with task-03)
- `fe/lib/features/shell/presentation/shell_screen.dart` - modify - not-staff state
- `fe/lib/core/di/repository_providers.dart`, `fe/lib/core/router/app_router.dart`, `routes.dart` - modify
- `fe/test/support/mocks/mock_attendance_repository.dart`, `fe/test/support/fixtures/{sessions,roster,trials}.dart` - create
- `docs/fe/architecture.md` - modify

## Spec
### Models
`ClubSession(id, sessionDate: DateTime, slot: SessionSlot, startsAt: String, endsAt: String, createdBy?)` with `String get timeLabel` ("6:00 to 8:30 am"); `RosterEntry(traineeId, fullName, photoPath?, status: AttendanceStatus? (null = not marked), markedAt?)`; `AttendanceMark(sessionId, traineeId, status, markedBy?, markedAt)`; `TrialBooking(id, fullName, phone, dateOfBirth?, age?, sessionDate, slot, note?, createdAt)`.

### Repository
```dart
abstract class AttendanceRepository {
  Future<List<ClubSession>> sessionsFor(DateTime date);        // ensure_day_sessions
  Future<ClubSession> addExtraSession(DateTime date, TimeOfDay start, TimeOfDay end);
  Future<void> deleteExtraSession(String sessionId);
  Future<List<RosterEntry>> roster(String sessionId);          // session_roster
  Future<AttendanceMark> mark(String sessionId, String traineeId, AttendanceStatus status);
  Future<int> markRemainingAbsent(String sessionId);
  Future<List<TrialBooking>> trialsBetween(DateTime from, DateTime to); // trial_bookings_between
}
```
Mock: in-memory sessions per date (creates morning/evening for non-Sundays), roster from fixtures, marks upsert with the server's no-op rule, `markRemainingAbsent` counts unmarked active trainees, `BXVAL` messages copied from the backend notes, scenario switch on every call.

### Providers
`selectedDateProvider` (`Notifier<DateTime>`, defaults to today in India time); `daySessionsProvider = FutureProvider.autoDispose.family<List<ClubSession>, DateTime>`; `selectedSessionIdProvider` (`Notifier<String?>`, resets to the first session whose `endsAt` is after now, else the last); `rosterProvider.family<List<RosterEntry>, String>`; `dayTrialsProvider.family<List<TrialBooking>, DateTime>`; `markController` (`AsyncNotifier` with `mark(traineeId, status)` and `markRemainingAbsent()`; optimistic update of the roster list, rollback and banner on failure; `ref.invalidate(rosterProvider)` after `markRemainingAbsent`).

### Screen
- Header: `Eyebrow` with the date (`EEEE d MMMM`, uppercase), `title` "Today" (or the weekday name when another date is selected), a calendar icon button (44 px) opening a date picker limited to 60 days back and 7 ahead.
- `SessionSegment`: `ChoiceRow` of the day's sessions (`Morning`, `Evening`, extras as `Extra 4:00 pm`), plus a `LinkButton('Add extra session')` opening `ExtraSessionSheet` (start and end `TimeOfDay` pickers, `PrimaryButton('Add')`, validation "End time must be after the start time"). An extra session row has a trailing remove action with a confirm dialog; the server's "already has attendance" error shows in a banner.
- Sunday with no extras: `EmptyView(title: 'Closed today', message: 'The club does not train on Sundays.', actionLabel: 'Add an extra session')`.
- `ProgressCard`: "Marked" eyebrow, `title` "14 of 20", caption "6 to go" (or "Everyone marked"). Counts come from the roster only.
- `TrialVisitorsCard` above the roster when `dayTrials` has bookings for the selected slot: eyebrow "TRIAL VISITORS", one `ListRow` per booking (name, formatted phone, age or "DOB d MMM yyyy", note in caption).
- Roster: an `AppCard` of `RosterRow`s: `AvatarInitials`, name, subtitle "Present, 6:02 am" (`h:mm a`, lower-case am/pm) / "Absent" / "Not marked" (muted); trailing two 44 px toggle buttons (check = present, close = absent); selected one filled `accent`/`onAccent` (present) or `ink` on `line` fill (absent); unselected outlined. Tapping the selected one again does nothing. Rows for present trainees show the check in `positive` tint in the subtitle only.
- Empty roster: `EmptyView(title: 'No active trainees', message: 'Add trainees to start marking attendance.', actionLabel: 'Go to Trainees', onAction: go(Routes.trainees))`.
- Sticky bottom `PrimaryButton('Mark the remaining N absent')` while N > 0; confirm dialog "Mark N trainees absent?"; busy while running; success snackbar "N marked absent".
- Errors: `AsyncValueView` for the day's sessions and the roster; mark failures as an `InlineBanner` above the roster with retry.

### Kit and harness fixes folded in (review findings R1-05, R1-06, R1-07)
- `fe/lib/core/widgets/inline_banner.dart`: text up to 3 lines (`maxLines: 3`, ellipsis after).
- `fe/test/proofs/proof_harness.dart`: `renderProof` gains `Future<void> Function(WidgetTester tester)? interact`, awaited after the first pump and before capture, so proofs can type into fields and trigger states; it also loads `MaterialIcons-Regular.otf` from the Flutter SDK cache (`bin/cache/artifacts/material_fonts/`, path from the `FLUTTER_ROOT` env or `flutter --version --machine`) when the file exists, so icons render. Re-render the run-1 proofs (sign-in filled and error, More, blocked) with it.
- Not-staff state in `ShellScreen` as described under Context.

## Out of scope
Trainee detail or editing (task-02). The public booking form (task-03). Reports (task-04).

## Acceptance criteria
- [ ] `flutter analyze`, `dart format`, codegen clean; generated files committed.
- [ ] Unit: providers' default session choice; mock mirrors upsert no-op, inactive trainee `BXVAL`, Sunday behaviour.
- [ ] Widget: marking toggles optimistically and rolls back on error; the sticky button hides at zero; Sunday empty state; trial visitors card appears for the matching slot only.
- [ ] Flow: sign in, land on Today, mark two trainees, mark the rest absent, counts update from the mock.
- [ ] Proofs: Today in no data (no trainees), typical (20 trainees, 14 marked, 2 trial visitors), heavy (60 trainees), Sunday; extra-session sheet.
- [ ] Not-staff shell state renders for `NotFoundException`.

## Verification
From `fe/`: `dart run build_runner build --delete-conflicting-outputs`, `flutter analyze`, `flutter test`, `flutter test test/proofs`, `dart format --output=none --set-exit-if-changed <touched files>`.
