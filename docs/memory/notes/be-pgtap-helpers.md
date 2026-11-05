# pgTAP helper file quirks (be, 2026-11-05)

- pg_prove fails a file with no plan, so `tests/000_helpers.sql` ends with `plan(6)` and
  `has_function` checks; it has no begin/rollback, so the `tests` schema stays committed.
- `tests.authenticate_as` uses `set_config(..., true)`: only effective inside a transaction,
  so every other test file must be `begin; ... rollback;`. A failing statement rolled back to
  a savepoint also undoes the role switch; re-authenticate after it.
- RLS policies calling `private.is_staff()` need only EXECUTE for `authenticated`, not USAGE on
  schema `private` (checked on the local stack).
- `supabase db lint` warns that `normalize_phone` (immutable) and `current_profile` (stable)
  call volatile `private.fail`; harmless, and `fail` must stay volatile so it is never
  constant-folded.
