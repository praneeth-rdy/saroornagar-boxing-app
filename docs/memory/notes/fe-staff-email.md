# Staff admin by email: things to know (fe, 2026-11-05, run 3 task-04)

- `staff_providers.dart` was not in the package's file list but had to change: the form
  controller passes `email` and `phone` through to the new repository signatures.
- Tests not yet updated (assistant): `test/support/mocks/mock_staff_repository_test.dart`
  (`_create` helper still passes `phone` and no `email`, the only analyzer error), plus
  `staff_screens_test.dart`, `staff_flow_test.dart`, `staff_proofs_test.dart`, which type a
  phone on the new form and expect `Role · phone` rows.
- Mock create checks in function order: name, email, phone, password, role, then the phone
  clash ("This number belongs to another staff member"), then the taken email ("A staff
  member with this email already exists"). The old create message "A staff member with this
  number already exists" is gone.
- The form sends the email as typed; the function and the mock trim and lower-case it. A
  blank phone goes as null on edit (clears) and is left out of the create body.
- Form order is Name, Email, Password, Role, Phone (optional): the phone sits after the
  role on both new and edit so the edit form keeps the same layout.
