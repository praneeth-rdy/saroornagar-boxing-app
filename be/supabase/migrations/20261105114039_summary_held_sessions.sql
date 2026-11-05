-- Monthly summary counts held sessions only: opening a date creates its session rows through
-- ensure_day_sessions, so a session counts only once it has at least one attendance mark.

-- session_count is the month's held total, the same on every row, so the app can show "n of m".
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
    and s.session_date < (p_month + interval '1 month')::date
    and exists (select 1 from public.attendance a where a.session_id = s.id);

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

-- create or replace keeps the existing grants; restated so the file stands on its own.
revoke execute on function public.monthly_attendance_summary(date) from public, anon;
grant execute on function public.monthly_attendance_summary(date) to authenticated;
