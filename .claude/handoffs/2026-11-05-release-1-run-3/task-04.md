# Task 04 - Staff admin by email

- **Run:** `.claude/handoffs/2026-11-05-release-1-run-3/`
- **Area:** fe
- **Depends on:** task-03
- **Worker:** developer (Opus)
- **Tests:** yes (assistant)
- **Schema change approved by the owner:** n/a
- **Hosted apply:** n/a

## Goal
An admin adds a staff member with name, email, password, role and an optional phone, and
edits name, role and phone.

## Context the worker needs
`fe/CLAUDE.md`; `plan.md`; `features/staff/*`; task-01 contract: `rpc('update_staff',
{p_user_id, p_full_name, p_role, p_phone})` (null clears), `BXDUP 'This number belongs to
another staff member'`; task-02 contract: `admin-staff` `create` body `{action, full_name,
email, password, role, phone?}`, `BXDUP` on a duplicate email or phone, `BXVAL 'Enter a
valid email address'`.

## Files
- `fe/lib/features/staff/data/{staff_repository,supabase_staff_repository}.dart` - modify
- `fe/lib/features/staff/domain/staff_input.dart` (+ generated) - modify
- `fe/lib/features/staff/presentation/{staff_form_screen,staff_list_screen,staff_detail_screen}.dart` - modify
- `fe/test/support/mocks/mock_staff_repository.dart` - modify
- `docs/fe/architecture.md` - modify

## Spec
- `create({fullName, email, password, role, phone?})`; `update(userId, {fullName, role, phone?})`.
- Form (new): Name, Email, Password, Role, Phone (optional, 10 digits). Edit: Name, Role,
  Phone (optional); own role locked as before.
- List rows: subtitle `Coach · email`; detail header: email, then phone when present else
  "No phone". Mock mirrors the messages and the duplicate rules (email, phone).

## Out of scope
Backend. Self password change.

## Acceptance criteria
- [ ] Analyzer, format, codegen clean; suite passes.
- [ ] Widget: form validation for email and optional phone; duplicate email banner; edit
      clears the phone when emptied.
- [ ] Flow (admin): add a coach by email with no phone, open, edit to add a phone.
- [ ] Proofs: staff form (empty, error), staff list typical, staff detail coach (no phone).

## Verification
As task-03.
