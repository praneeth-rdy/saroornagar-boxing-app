-- Senior fee tier becomes 800 a month; juniors stay at 500. Same signature, so callers and grants are unchanged.

-- Juniors (under 15 on the given day) pay 500 a month, seniors 800; no date of birth, no tier.
create or replace function private.fee_tier_amount(p_date_of_birth date, p_on date)
returns integer
language sql
immutable
set search_path = ''
as $$
  select case
    when p_date_of_birth is null or p_on is null then null
    when extract(year from pg_catalog.age(p_on::timestamp, p_date_of_birth::timestamp)) < 15 then 500
    else 800
  end;
$$;

-- create or replace keeps existing privileges; restated so the helper stays internal regardless.
revoke execute on function private.fee_tier_amount(date, date) from public, anon, authenticated;
