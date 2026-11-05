# Plan - release 1, run 3 (email sign-in and forgot password)

Owner, 2026-11-05: "Can we do an email-password sign-in instead and add a forgot password
option too?" Replaces phone + password for staff. Trial bookings keep the visitor's phone.

Order: task-01 be (profiles email, trigger, update_staff), task-02 be (Edge Function by
email), task-03 fe (sign-in by email, forgot password flow), task-04 fe (staff admin by
email). The two areas run in parallel; the fe packages build against the contracts below.

## Decisions
- Email is stored lower-cased and trimmed; `profiles.email text not null unique`;
  `profiles.phone text null` (optional, normalized when present).
- Staff are created by the Edge Function with `email_confirm: true`; no confirmation mail.
- Forgot password = Supabase recovery OTP: `auth.resetPasswordForEmail(email)` sends a
  6-digit code (the hosted "Reset Password" template must include `{{ .Token }}`, owner
  step); the app calls `auth.verifyOTP(type: recovery, email, token)` then
  `auth.updateUser(password)`. No deep links, no redirect URLs.
- Free-tier built-in email sender is rate limited (a few mails per hour); enough for a club.
  Custom SMTP is a later decision (`docs/decisions.md`).
- Error copy: wrong or expired code -> "That code is wrong or has expired."; rate limit
  (`over_email_send_rate_limit`) -> "Too many emails were sent. Try again in a few minutes.";
  unknown email on request -> the app still shows the "code sent" screen (no account
  enumeration).
