# Local phone + password sign-in needs an SMS provider block (be, 2026-11-05)

CLI 3.0.0 renamed `[auth.sms] enable_signup` to `enabled`. With `enabled = true` and no SMS
provider, `supabase start` warns "no SMS provider is enabled. Disabling phone login" and
`/auth/v1/token?grant_type=password` returns `phone_provider_disabled`.
Verified fix (not committed, outside task-01 scope): `[auth.sms.twilio] enabled = true`,
`account_sid = "local"`, `message_service_sid = "local"`, and export
`SUPABASE_AUTH_SMS_TWILIO_AUTH_TOKEN=local` before `supabase start`. Then the seed admin
`919000000001` signs in. No SMS is sent while confirmations stay off.
