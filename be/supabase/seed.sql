-- Local stack only: known staff logins for manual runs and pgTAP; never apply to hosted.

-- The on_auth_user_created trigger turns each auth user into a profile with the app_metadata role.
insert into auth.users (
  instance_id, id, aud, role, email, encrypted_password, email_confirmed_at,
  raw_app_meta_data, raw_user_meta_data, created_at, updated_at,
  confirmation_token, recovery_token, email_change_token_new, email_change
)
values
  (
    '00000000-0000-0000-0000-000000000000', '00000000-0000-4000-a000-000000000001',
    'authenticated', 'authenticated', 'admin@local.test',
    extensions.crypt('admin-local-1234', extensions.gen_salt('bf')), now(),
    '{"provider": "email", "providers": ["email"], "role": "admin", "full_name": "Local Admin"}',
    '{"full_name": "Local Admin"}',
    now(), now(), '', '', '', ''
  ),
  (
    '00000000-0000-0000-0000-000000000000', '00000000-0000-4000-a000-000000000002',
    'authenticated', 'authenticated', 'coach@local.test',
    extensions.crypt('coach-local-1234', extensions.gen_salt('bf')), now(),
    '{"provider": "email", "providers": ["email"], "role": "coach", "full_name": "Local Coach"}',
    '{"full_name": "Local Coach"}',
    now(), now(), '', '', '', ''
  )
on conflict (id) do nothing;

-- Password sign-in looks the user up through the email identity.
insert into auth.identities (
  id, provider_id, user_id, provider, identity_data, last_sign_in_at, created_at, updated_at
)
select
  u.id, u.id::text, u.id, 'email',
  jsonb_build_object(
    'sub', u.id::text, 'email', u.email, 'email_verified', true, 'phone_verified', false
  ),
  now(), now(), now()
from auth.users u
where u.id in ('00000000-0000-4000-a000-000000000001', '00000000-0000-4000-a000-000000000002')
on conflict (provider_id, provider) do nothing;
