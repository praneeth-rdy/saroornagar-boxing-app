# Task 02 - Trainees: list, add, edit, status, photo, history

- **Run:** `.claude/handoffs/2026-11-05-release-1-run-2/`
- **Area:** fe
- **Depends on:** task-01
- **Worker:** developer (Opus)
- **Tests:** yes (assistant)
- **Schema change approved by the owner:** n/a
- **Hosted apply:** n/a

## Goal
Staff keep the roster: find a trainee, add one with the optional details and a photo, edit
them, set them inactive or active, and read their attendance history.

## Context the worker needs
- `fe/CLAUDE.md`; both `plan.md` files. Server: `docs/be/architecture.md` rows for
  `trainees`, `create_trainee`, `update_trainee`, `set_trainee_status`, `set_trainee_photo`,
  `trainee_attendance_history`, bucket `trainee-photos`; validation messages in
  `docs/memory/notes/be-trainees-sessions.md`.
- New dependency `image_picker` (gallery and camera, max 1600 px, JPEG quality 80).

## Files
- `fe/pubspec.yaml` - modify - `image_picker`; `fe/android/app/src/main/AndroidManifest.xml` only if the plugin requires it
- `fe/lib/features/trainees/domain/{trainee,attendance_record}.dart` (+ generated) - create
- `fe/lib/features/trainees/data/{trainee_repository,supabase_trainee_repository}.dart` - create
- `fe/lib/features/trainees/presentation/{trainee_providers,trainees_screen,trainee_detail_screen,trainee_form_screen,trainee_photo_picker,attendance_history_screen}.dart` - create (replace the stub)
- `fe/lib/core/router/{routes,app_router}.dart`, `fe/lib/core/di/repository_providers.dart` - modify
- `fe/test/support/mocks/mock_trainee_repository.dart`, `fe/test/support/fixtures/trainees.dart` - create
- `docs/fe/architecture.md` - modify

## Spec
### Models
`Trainee(id, fullName, phone?, photoPath?, dateOfBirth?, joinedOn?, status: TraineeStatus, notes?, createdAt, updatedAt)` with getters `int? ageOn(DateTime)`, `int? feeTier` (500 under 15, 1000 at 15 and above, null without a date of birth; same rule as the server), `String initials`. `AttendanceRecord(sessionId, sessionDate, slot, status, markedAt)`.

### Repository
```dart
abstract class TraineeRepository {
  Future<List<Trainee>> list({required TraineeStatus status});   // select, RLS, ordered by name
  Future<Trainee> byId(String id);                               // select single; NotFoundException when absent
  Future<Trainee> create(TraineeInput input);                    // create_trainee
  Future<Trainee> update(String id, TraineeInput input);         // update_trainee (full replace)
  Future<Trainee> setStatus(String id, TraineeStatus status);    // set_trainee_status
  Future<Trainee> uploadPhoto(String id, Uint8List bytes, String fileName); // storage upload to "<id>/<uuid>.jpg" then set_trainee_photo
  String? photoUrl(String? photoPath);                           // signed url (1 hour) via createSignedUrl, cached per path
  Future<List<AttendanceRecord>> history(String id, DateTime from, DateTime to);
}
```
`TraineeInput(fullName, phone?, dateOfBirth?, joinedOn?, notes?)` freezed. Mock mirrors trimming, blank-to-null, DOB floor, 500-char notes, phone normalization, and returns a fake photo path.

### Screens and routes
- `Routes.trainees` list; `Routes.traineeNew = '/trainees/new'`; `Routes.traineeDetail = '/trainees/:id'`; `Routes.traineeEdit = '/trainees/:id/edit'`; `Routes.traineeHistory = '/trainees/:id/history'`.
- `TraineesScreen`: `AppBar` "Trainees" with an "Add" text action; search `AppTextField` (filters by name or phone, client side); `ChoiceRow` Active / Inactive (default Active); `AppCard` of `ListRow`s (`AvatarInitials` with photo, name, subtitle phone or "No phone"; inactive rows muted); tap -> detail. Empty active: `EmptyView(title: 'No trainees yet', message: 'Add the first trainee to start marking attendance.', actionLabel: 'Add trainee')`. Empty search: "No one matches".
- `TraineeFormScreen` (new and edit): name (required), phone (10 digits, optional), date of birth (date picker, optional, not in the future; helper text shows the fee tier when set: "Junior, 500 per month" / "Senior, 1000 per month"), joined on (date picker, optional), notes (multiline, 500 max, counter). `PrimaryButton('Add trainee' | 'Save')`; server `BXVAL` in an `InlineBanner`; success pops to the detail.
- `TraineeDetailScreen`: header `AppCard` with a 72 px avatar (tap -> `TraineePhotoPicker` bottom sheet: Take photo / Choose from gallery / Remove; upload progress on the avatar), name `title`, caption line "`+91 98765 43210` · Age 14 · Junior" (omit missing parts), caption "Joined 3 Mar 2026" when present, a status chip (Active in `accentSoft`, Inactive in `line`); actions row: `SecondaryButton('Edit')`, `LinkButton('Set inactive' | 'Set active')` with confirm dialog. Notes card when present. "Attendance" section: eyebrow, last 30 days as `ListRow`s (date `EEE d MMM`, slot label, status), `LinkButton('Full history')` -> history screen; empty: "No sessions marked yet". (Task-04 adds the Fees section below.)
- `AttendanceHistoryScreen`: month navigator (prev/next, cannot go past the current month), rows for that month, counts caption "12 present, 3 absent". Empty: "No sessions this month".
- All state through `AsyncValueView`; `PermissionDeniedView` on `BXPRM`.

## Out of scope
Fees (task-04). Deleting trainees (not in the product). Bulk import.

## Acceptance criteria
- [ ] Analyzer, format, codegen clean; generated files committed.
- [ ] Unit: `feeTier` and `ageOn` boundaries (14y364d, 15y, null); mock validation messages equal the backend notes.
- [ ] Widget: list filter and search; form validation and server banner; status toggle confirm; photo sheet actions call the repository.
- [ ] Flow: add a trainee, open it, edit the name, set inactive, it moves to the Inactive filter.
- [ ] Proofs: list (empty, 12, 80), detail (no data: no phone/dob/notes; typical; heavy notes), form (empty, filled with error), history (empty, typical).

## Verification
As task-01.
