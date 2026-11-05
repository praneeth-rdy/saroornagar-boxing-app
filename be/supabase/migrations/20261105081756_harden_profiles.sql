-- Harden staff creation and anon grants (review findings R1-01, R1-02).

-- Only the admin API (service role) can write app_metadata, so the role is read from there;
-- a self sign-up, whatever user metadata it sends, gets no profile and so no staff rights.
create or replace function private.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_role text := new.raw_app_meta_data ->> 'role';
begin
  if v_role is null or v_role not in ('admin', 'coach') then
    return new;
  end if;

  insert into public.profiles (id, full_name, phone, role)
  values (
    new.id,
    coalesce(
      nullif(trim(new.raw_app_meta_data ->> 'full_name'), ''),
      nullif(trim(new.raw_user_meta_data ->> 'full_name'), ''),
      nullif(new.phone, ''),
      'Staff'
    ),
    coalesce(nullif(new.phone, ''), new.raw_user_meta_data ->> 'phone'),
    v_role::public.staff_role
  );
  return new;
end;
$$;

revoke execute on function private.handle_new_user() from public, anon, authenticated;

-- Anon reaches data only through book_trial and my_trial_bookings (security definer).
revoke select on
  public.profiles,
  public.trainees,
  public.sessions,
  public.attendance,
  public.trial_bookings,
  public.fee_payments
from anon;
