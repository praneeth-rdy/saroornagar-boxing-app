# fe: roll numbers (task-16)

- Built against the revised task-15 contract before the migration landed: `rpc('next_roll_no')`
  returns a bare integer; `create_trainee` / `update_trainee` take `p_roll_no`. The migration
  on disk at the time (`20261105154420_roll_numbers.sql`) was the earlier sequence version;
  recheck parameter names once task-15 lands.
- The mock checks the roll number after `clean_trainee_input` (name, phone, dates, notes);
  if the server checks it first, swap the order in `MockTraineeRepository._checkRollNo` calls.
- The mock lets an inactive student's number be edited onto an active one's (the unique index
  is partial on active rows); the clash surfaces on reactivation instead.
- Roll badges render digits on Today, so count assertions in today tests look inside
  `ProgressCard` (`_presentCount`) instead of `find.text('1')`.
