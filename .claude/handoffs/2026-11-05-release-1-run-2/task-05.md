# Task 05 - Staff admin: list, create, edit, block, reset password

- **Run:** `.claude/handoffs/2026-11-05-release-1-run-2/`
- **Area:** fe
- **Depends on:** task-04
- **Worker:** developer (Opus)
- **Tests:** yes (assistant)
- **Schema change approved by the owner:** n/a
- **Hosted apply:** n/a

## Goal
An admin manages the club's staff accounts from More: sees everyone, adds a coach or admin
with a phone and password, edits a name or role, resets a password, and blocks or unblocks
access. Coaches do not see this.

## Context the worker needs
- `fe/CLAUDE.md`; both `plan.md` files. Server: `select * from profiles` (staff read all),
  `update_staff(p_user_id, p_full_name, p_role)` (`BXVAL 'You cannot change your own role'`,
  `'Choose a role'`), Edge Function `admin-staff` (`docs/be/architecture.md` Edge Functions
  section and `docs/memory/notes/be-admin-staff-function.md`): actions `create`,
  `reset_password`, `set_blocked`; error bodies `{code, message}` mapped by
  `mapSupabaseError` (`FunctionException`). `StaffProfile` and `AuthRepository` from run 1.

## Files
- `fe/lib/features/staff/data/{staff_repository,supabase_staff_repository}.dart` - create
- `fe/lib/features/staff/domain/staff_input.dart` (+ generated) - create
- `fe/lib/features/staff/presentation/{staff_providers,staff_list_screen,staff_form_screen,staff_detail_screen,reset_password_sheet}.dart` - create
- `fe/lib/features/more/presentation/more_screen.dart` - modify - "Staff" card for admins only
- `fe/lib/core/router/{routes,app_router}.dart`, `fe/lib/core/di/repository_providers.dart` - modify
- `fe/test/support/mocks/mock_staff_repository.dart`, `fe/test/support/fixtures/profiles.dart` - create / extend
- `docs/fe/architecture.md` - modify

## Spec
```dart
abstract class StaffRepository {
  Future<List<StaffProfile>> list();                                     // profiles ordered by full_name
  Future<StaffProfile> create({required String fullName, required String phone, required String password, required StaffRole role}); // functions.invoke admin-staff create
  Future<StaffProfile> update(String userId, {required String fullName, required StaffRole role}); // rpc update_staff
  Future<void> resetPassword(String userId, String password);           // admin-staff reset_password
  Future<StaffProfile> setBlocked(String userId, bool blocked);          // admin-staff set_blocked
}
```
`SupabaseStaffRepository`: `functions.invoke('admin-staff', body: {...})`; a non-2xx response is turned into the matching `AppException` by `mapSupabaseError` using the body `code`; verify `FunctionException` carries the body in `details` in the installed `supabase_flutter` version and adapt the mapper in `supabase_errors.dart` if needed (name the change in the summary). Mock mirrors every message in the function note (name 2-80, phone rule, password 8-72, role, cannot block self, duplicate phone -> `DuplicateException`).

Routes: `Routes.staff = '/more/staff'`, `Routes.staffNew = '/more/staff/new'`, `Routes.staffDetail = '/more/staff/:id'`, `Routes.staffEdit = '/more/staff/:id/edit'`. Each screen checks `currentProfileProvider.isAdmin` and renders `PermissionDeniedView(message: 'Only an admin can manage staff.')` otherwise; `MoreScreen` shows the "Staff" card only for admins.

- `StaffListScreen`: `AppBar` "Staff" with "Add" action; `AppCard` of rows: avatar, name, subtitle "Admin · +91 ..." / "Coach · ..."; blocked rows show a "Blocked" chip (`negativeSoft` fill, `negative` text) and muted name; own row has a "You" caption. Empty cannot happen (the admin is listed); still implement `EmptyView` with "Add staff".
- `StaffFormScreen` (new): name, phone (10 digits), password (8-72, show/hide, helper "Share it with them in person; they can change it later" is NOT offered yet, so the helper says "They will use this to sign in."), role `ChoiceRow` Coach / Admin (default Coach); `PrimaryButton('Add staff')`; `DuplicateException` message in the banner. Edit: name and role only; own role chips disabled with caption "You cannot change your own role".
- `StaffDetailScreen`: header card (avatar, name, phone, role chip, blocked chip), actions: `SecondaryButton('Edit')`, `SecondaryButton('Reset password')` -> `ResetPasswordSheet` (new password + confirm, `PrimaryButton('Reset')`, snackbar "Password reset"), `LinkButton('Block access' | 'Unblock')` with a confirm dialog ("They will be signed out and cannot use the app until unblocked."); hidden for the own profile. Busy states on every action; errors in a banner.

## Out of scope
Deleting staff. Self password change (later release). Any backend change.

## Acceptance criteria
- [ ] Analyzer, format, codegen clean; generated files committed.
- [ ] Unit: mock messages equal the function note; the mapper turns a `{code: 'BXDUP'}` function error into `DuplicateException`.
- [ ] Widget: coach sees the permission view and no Staff card; admin form validation; own role locked; block confirm dialog.
- [ ] Flow (admin): add a coach, open, reset password, block, the list shows Blocked.
- [ ] Proofs: list (admin typical, heavy 15 with blocked rows), form (empty, error), detail (admin viewing coach, admin viewing self), coach's More tab without the Staff card.

## Verification
As task-01.
