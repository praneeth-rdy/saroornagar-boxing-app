# Hosted advisors after the release 1 apply (2026-11-05)

- Security: 21 "authenticated can execute SECURITY DEFINER function" and 2 "anon can execute"
  (`book_trial`, `my_trial_bookings`). All intended: every function checks `private.is_staff()`
  or scopes by device key; anon has no table grants. Leaked-password protection is off
  (dashboard setting, may need the Pro plan).
- Performance: 11 unused indexes (empty database, expected) and one "multiple permissive
  policies" on `profiles` (backlog B-09).
- Hosted migration versions are MCP timestamps (backlog B-10).
