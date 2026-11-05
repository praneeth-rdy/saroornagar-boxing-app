# Open: public sign-up plus metadata role lets anyone become admin (be, 2026-11-05)

Observed on the local stack with a phone provider enabled: `POST /auth/v1/signup` with the
publishable key and `data: {"role": "admin"}` created an `admin` profile, because
`private.handle_new_user` (task-01 spec) trusts `raw_user_meta_data`, which the caller controls.
Without a role it still yields a `coach`, i.e. full staff read access.
Not fixed in task-01 (design decision). Options for the Architect:
- Turn public sign-ups off: hosted dashboard "Allow new users to sign up" off, and
  `[auth] enable_signup = false` locally. Admin `createUser` and password sign-in keep working.
- Defence in depth: take `role` from `raw_app_meta_data` (only the service role can set it),
  which changes task-05 (`app_metadata: { role }`), the seed and `tests.create_user`.
