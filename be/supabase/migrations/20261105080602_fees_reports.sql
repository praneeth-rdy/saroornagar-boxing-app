-- Fee payments and staff reports: monthly payments recorded by staff, fee status and attendance summaries.

-- ---------------------------------------------------------------------------
-- Enums
-- ---------------------------------------------------------------------------

do $$
begin
  create type public.payment_method as enum ('cash', 'upi');
exception
  when duplicate_object then null;
end;
$$;

-- ---------------------------------------------------------------------------
-- Fee tier
-- ---------------------------------------------------------------------------

-- Juniors (under 15 on the given day) pay 500 a month, seniors 1000; no date of birth, no tier.
create or replace function private.fee_tier_amount(p_date_of_birth date, p_on date)
returns integer
language sql
immutable
set search_path = ''
as $$
  select case
    when p_date_of_birth is null or p_on is null then null
    when extract(year from pg_catalog.age(p_on::timestamp, p_date_of_birth::timestamp)) < 15 then 500
    else 1000
  end;
$$;

-- ---------------------------------------------------------------------------
-- Fee payments
-- ---------------------------------------------------------------------------

create table if not exists public.fee_payments (
  id uuid primary key default gen_random_uuid(),
  trainee_id uuid not null references public.trainees (id) on delete cascade,
  amount integer not null check (amount > 0 and amount <= 100000),
  method public.payment_method not null,
  paid_on date not null,
  period_month date not null check (period_month = date_trunc('month', period_month)::date),
  note text null check (note is null or length(note) <= 300),
  recorded_by uuid null references public.profiles (id) on delete set null,
  created_at timestamptz not null default private.clock()
);

-- A trainee's history, newest month first; also serves the trainee foreign key cascade.
create index if not exists fee_payments_trainee_idx
  on public.fee_payments (trainee_id, period_month desc);

-- The fee status list sums one month across every trainee.
create index if not exists fee_payments_period_idx
  on public.fee_payments (period_month);

-- Removing a staff profile nulls recorded_by; the index keeps that from scanning every payment.
create index if not exists fee_payments_recorded_by_idx
  on public.fee_payments (recorded_by);

alter table public.fee_payments enable row level security;

create policy fee_payments_select_staff on public.fee_payments
  for select to authenticated
  using ((select private.is_staff()));

-- Payments change only through the fee functions below; truncate would bypass RLS.
revoke insert, update, delete, truncate, references, trigger on public.fee_payments from anon, authenticated;

-- Record only: several payments for one month are allowed (partial payments), no due logic.
create or replace function public.record_fee_payment(
  p_trainee_id uuid,
  p_amount integer,
  p_method public.payment_method,
  p_paid_on date,
  p_period_month date,
  p_note text default null
)
returns public.fee_payments
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_note text := nullif(trim(p_note), '');
  v_payment public.fee_payments;
begin
  if not private.is_staff() then
    perform private.fail('BXPRM', 'Only club staff can do this');
  end if;

  -- Key share lock so the trainee cannot be deleted between this check and the insert.
  perform 1 from public.trainees where id = p_trainee_id for key share;
  if not found then
    perform private.fail('BXNTF', 'Trainee not found');
  end if;

  if p_paid_on is null then
    perform private.fail('BXVAL', 'Enter the payment date');
  end if;

  if p_paid_on > private.today() then
    perform private.fail('BXVAL', 'The payment date cannot be in the future');
  end if;

  if p_period_month is null or p_period_month <> date_trunc('month', p_period_month)::date then
    perform private.fail('BXVAL', 'Period must be a month');
  end if;

  -- Mirrors the table check so the app gets BXVAL instead of a raw constraint error.
  if p_amount is null or p_amount not between 1 and 100000 then
    perform private.fail('BXVAL', 'Enter an amount between 1 and 100000');
  end if;

  if p_method is null then
    perform private.fail('BXVAL', 'Choose cash or UPI');
  end if;

  if v_note is not null and length(v_note) > 300 then
    perform private.fail('BXVAL', 'Keep the note to 300 characters or fewer');
  end if;

  insert into public.fee_payments (
    trainee_id, amount, method, paid_on, period_month, note, recorded_by, created_at
  )
  values (
    p_trainee_id, p_amount, p_method, p_paid_on, p_period_month, v_note, (select auth.uid()), private.clock()
  )
  returning * into v_payment;

  return v_payment;
end;
$$;

-- A short window to undo a mistaken entry; older payments stay as the club's record.
create or replace function public.delete_fee_payment(p_payment_id uuid)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_created_at timestamptz;
begin
  if not private.is_staff() then
    perform private.fail('BXPRM', 'Only club staff can do this');
  end if;

  select created_at into v_created_at
  from public.fee_payments
  where id = p_payment_id
  for update;
  if not found then
    perform private.fail('BXNTF', 'Payment not found');
  end if;

  if private.clock() > v_created_at + interval '7 days' then
    perform private.fail('BXVAL', 'Payments older than 7 days cannot be removed');
  end if;

  delete from public.fee_payments
  where id = p_payment_id;
end;
$$;

create or replace function public.trainee_fee_history(p_trainee_id uuid)
returns setof public.fee_payments
language plpgsql
security definer
set search_path = ''
as $$
begin
  if not private.is_staff() then
    perform private.fail('BXPRM', 'Only club staff can do this');
  end if;

  perform 1 from public.trainees t where t.id = p_trainee_id;
  if not found then
    perform private.fail('BXNTF', 'Trainee not found');
  end if;

  return query
  select f.*
  from public.fee_payments f
  where f.trainee_id = p_trainee_id
  order by f.period_month desc, f.paid_on desc, f.created_at desc, f.id;
end;
$$;

-- ---------------------------------------------------------------------------
-- Reports
-- ---------------------------------------------------------------------------

-- Unpaid trainees first so staff see who to follow up with; tier is null without a date of birth.
create or replace function public.fee_status_list(p_month date)
returns table (
  trainee_id uuid,
  full_name text,
  photo_path text,
  tier_amount integer,
  paid_amount integer,
  last_paid_on date
)
language plpgsql
security definer
set search_path = ''
as $$
#variable_conflict use_column
begin
  if not private.is_staff() then
    perform private.fail('BXPRM', 'Only club staff can do this');
  end if;

  if p_month is null or p_month <> date_trunc('month', p_month)::date then
    perform private.fail('BXVAL', 'Period must be a month');
  end if;

  return query
  select
    t.id,
    t.full_name,
    t.photo_path,
    private.fee_tier_amount(t.date_of_birth, p_month),
    coalesce(p.paid_amount, 0)::integer,
    p.last_paid_on
  from public.trainees t
  left join (
    select f.trainee_id, sum(f.amount) as paid_amount, max(f.paid_on) as last_paid_on
    from public.fee_payments f
    where f.period_month = p_month
    group by f.trainee_id
  ) p on p.trainee_id = t.id
  where t.status = 'active'
  order by coalesce(p.paid_amount, 0) = 0 desc, lower(t.full_name), t.id;
end;
$$;

-- session_count is the month's total, the same on every row, so the app can show "n of m".
create or replace function public.monthly_attendance_summary(p_month date)
returns table (
  trainee_id uuid,
  full_name text,
  photo_path text,
  present_count integer,
  absent_count integer,
  session_count integer
)
language plpgsql
security definer
set search_path = ''
as $$
#variable_conflict use_column
declare
  v_session_count integer;
begin
  if not private.is_staff() then
    perform private.fail('BXPRM', 'Only club staff can do this');
  end if;

  if p_month is null or p_month <> date_trunc('month', p_month)::date then
    perform private.fail('BXVAL', 'Period must be a month');
  end if;

  select count(*)::integer into v_session_count
  from public.sessions s
  where s.session_date >= p_month
    and s.session_date < (p_month + interval '1 month')::date;

  return query
  select
    t.id,
    t.full_name,
    t.photo_path,
    coalesce(c.present_count, 0)::integer,
    coalesce(c.absent_count, 0)::integer,
    v_session_count
  from public.trainees t
  left join (
    select
      a.trainee_id,
      count(*) filter (where a.status = 'present') as present_count,
      count(*) filter (where a.status = 'absent') as absent_count
    from public.attendance a
    join public.sessions s on s.id = a.session_id
    where s.session_date >= p_month
      and s.session_date < (p_month + interval '1 month')::date
    group by a.trainee_id
  ) c on c.trainee_id = t.id
  where t.status = 'active'
  order by lower(t.full_name), t.id;
end;
$$;

-- ---------------------------------------------------------------------------
-- Execute grants: API roles reach only what they need
-- ---------------------------------------------------------------------------

revoke execute on function private.fee_tier_amount(date, date) from public, anon, authenticated;

revoke execute on function public.record_fee_payment(uuid, integer, public.payment_method, date, date, text) from public, anon;
revoke execute on function public.delete_fee_payment(uuid) from public, anon;
revoke execute on function public.trainee_fee_history(uuid) from public, anon;
revoke execute on function public.fee_status_list(date) from public, anon;
revoke execute on function public.monthly_attendance_summary(date) from public, anon;

grant execute on function public.record_fee_payment(uuid, integer, public.payment_method, date, date, text) to authenticated;
grant execute on function public.delete_fee_payment(uuid) to authenticated;
grant execute on function public.trainee_fee_history(uuid) to authenticated;
grant execute on function public.fee_status_list(date) to authenticated;
grant execute on function public.monthly_attendance_summary(date) to authenticated;
