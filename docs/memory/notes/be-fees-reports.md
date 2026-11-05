# Fee payments and reports migration: things to know (be, 2026-11-05)

- Choices the package left open, made in `20261105080602_fees_reports.sql` (the fe mock must
  match): null `p_paid_on` fails `BXVAL 'Enter the payment date'`; null method fails
  `BXVAL 'Choose cash or UPI'`; note trimmed, blank stored as null, over 300 fails
  `BXVAL 'Keep the note to 300 characters or fewer'`; payments can be recorded for inactive
  trainees (arrears); deletion is allowed up to exactly `created_at + 7 days`.
- Tier age uses `age(p_on, dob)` years: a 29 February birthday turns 15 on 1 March in non-leap
  years. `fee_tier_amount` also returns null when `p_on` is null.
- Extra index `fee_payments_recorded_by_idx` (FK on profile delete), as for `attendance`.
- Open for the Architect: `paid_on` and `period_month` have no lower bound, so a typo year
  (0026) is accepted; `fee_status_list` and `monthly_attendance_summary` list only active
  trainees, so an inactive trainee's payments for that month do not appear there.
- `20261105114039_summary_held_sessions.sql`: `session_count` now counts only sessions with an
  attendance mark (opening a date creates empty session rows). `present_count`/`absent_count`
  were already mark-based. The fe mock repository's summary must apply the same held rule.
