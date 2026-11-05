# Trainees and sessions migration: things to know (be, 2026-11-05)

- `storage.buckets` has RLS: after `tests.authenticate_as(...)` a bucket check returns 0 rows.
  Assert the `trainee-photos` bucket as `postgres` (before switching role or after `reset role`).
- Storage policies were checked only as rows in `pg_policies`; an upload through the Storage
  API was not tried (local phone sign-in needs the Twilio stub, see `be-local-phone-login.md`).
- Choices the package left open, made in the migration: blank phone or notes become null;
  DOB on/before 1900-01-01 fails `BXVAL 'Enter a valid date of birth'`; notes over 500 fail
  `BXVAL 'Notes must be 500 characters or fewer'`; null status, date or times fail `BXVAL`;
  photo path also needs a file name after `<id>/` and no `..` segment. The fe mock must match.
- `private.clean_trainee_input` is volatile on purpose: it calls `private.fail`, and marking it
  stable adds `db lint` warnings like the ones on `normalize_phone`.
