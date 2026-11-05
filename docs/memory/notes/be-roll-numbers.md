# Roll numbers (be, 2026-11-05)

- Package task-15 was revised mid-task from a sequence to a partial unique index; the doc line
  "sequence-assigned" in the package is stale. Numbers are unique among active students only.
- Choices the package left open, made in `20261105154420_roll_numbers.sql`: `update_trainee`'s
  `p_roll_no` defaults to null and null keeps the current number (the fe can omit it); the
  clash check in `update_trainee` runs only when the row is active, so editing an inactive
  student whose number was reused does not fail. Reactivation is where that clash surfaces.
- Backfill disables `trainees_set_updated_at` so existing rows keep their `updated_at`.
- Direct inserts into `trainees` in pgTAP now need a `roll_no` (no column default), else 23502.
- The `unique_violation` handlers cover only concurrent saves; a single-session pgTAP cannot
  reach them.
