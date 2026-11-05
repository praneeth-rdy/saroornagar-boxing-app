# Email sign-in migration: things to know (be, 2026-11-05)

- Hosted apply risk: `20261105105121_email_sign_in` backfills `profiles.email` from
  `auth.users.email` and then sets it `not null`. The hosted first admin was created with a
  phone identity; if that auth user has no email the apply fails with 23502. Give the hosted
  admin an email (Auth admin `updateUser`) before applying, or decide another backfill.
- Local `config.toml` needed no change: CLI 3.0 calls the email switch `[auth.email] enabled`
  (already true) and `enable_confirmations` was already false; `[auth.sms]` left as it was.
- pgTAP helpers are keyed on email now (`tests.create_user(email, password, name, role,
  phone default null)` puts the phone in `app_metadata`, like the Edge Function will). The
  helper file drops the old phone-keyed functions first, since `create or replace` cannot
  rename parameters on a stack that was not reset.
- `update_staff` treats a blank `p_phone` like null (clears), matching how `create_trainee`
  stores a blank phone.
- Seed accounts: `admin@local.test` / `coach@local.test`, no phone.
