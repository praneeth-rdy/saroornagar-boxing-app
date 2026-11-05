# Sign-up role escalation: remaining hosted steps (be, 2026-11-05)

Fixed in the schema by `20261105081756_harden_profiles.sql`: the profile role comes only from
`app_metadata` (service role only), so a self sign-up gets no profile. Still to do by hand in
the hosted dashboard (Authentication settings), with the owner, before staff go live:
- Turn "Allow new users to sign up" off (admin `createUser` and password sign-in keep working).
- Enable the Phone provider (password sign-in by phone; no SMS sender needed for that).
- Keep phone confirmations off (`createUser` sets `phone_confirm: true`).
Local `config.toml` still has `enable_signup` at its default; harmless now, untouched here.
