-- Local stack only: known staff logins for manual runs and pgTAP; never apply to hosted.

-- The on_auth_user_created trigger turns each auth user into a profile with the metadata role.
insert into auth.users (
  instance_id, id, aud, role, phone, encrypted_password, phone_confirmed_at,
  raw_app_meta_data, raw_user_meta_data, created_at, updated_at,
  confirmation_token, recovery_token, email_change_token_new, email_change
)
values
  (
    '00000000-0000-0000-0000-000000000000', '00000000-0000-4000-a000-000000000001',
    'authenticated', 'authenticated', '919000000001',
    extensions.crypt('admin-local-1234', extensions.gen_salt('bf')), now(),
    '{"provider": "phone", "providers": ["phone"]}',
    '{"full_name": "Local Admin", "role": "admin"}',
    now(), now(), '', '', '', ''
  ),
  (
    '00000000-0000-0000-0000-000000000000', '00000000-0000-4000-a000-000000000002',
    'authenticated', 'authenticated', '919000000002',
    extensions.crypt('coach-local-1234', extensions.gen_salt('bf')), now(),
    '{"provider": "phone", "providers": ["phone"]}',
    '{"full_name": "Local Coach", "role": "coach"}',
    now(), now(), '', '', '', ''
  )
on conflict (id) do nothing;

-- Password sign-in looks the user up through the phone identity.
insert into auth.identities (
  id, provider_id, user_id, provider, identity_data, last_sign_in_at, created_at, updated_at
)
select
  u.id, u.id::text, u.id, 'phone',
  jsonb_build_object(
    'sub', u.id::text, 'phone', u.phone, 'email_verified', false, 'phone_verified', true
  ),
  now(), now(), now()
from auth.users u
where u.id in ('00000000-0000-4000-a000-000000000001', '00000000-0000-4000-a000-000000000002')
on conflict (provider_id, provider) do nothing;
