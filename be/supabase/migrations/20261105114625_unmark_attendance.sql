-- Presence-only marking: a coach undoes a Present tap by removing the mark, so removing the
-- only mark of a session returns it to not held and it drops out of the monthly counts.
-- reset_session_attendance clears a whole session taken by mistake in one call.

create or replace function public.unmark_attendance(
  p_session_id uuid,
  p_trainee_id uuid
)
returns void
language plpgsql
security definer
set search_path = ''
as $$
begin
  if not private.is_staff() then
    perform private.fail('BXPRM', 'Only club staff can do this');
  end if;

  -- Same key share lock as mark_attendance, so delete_extra_session sees a consistent state.
  perform 1 from public.sessions where id = p_session_id for key share;
  if not found then
    perform private.fail('BXNTF', 'Session not found');
  end if;

  -- No trainee status check: a mark made before a trainee went inactive can still be undone.
  delete from public.attendance
  where session_id = p_session_id
    and trainee_id = p_trainee_id;
  if not found then
    perform private.fail('BXNTF', 'No mark to remove');
  end if;
end;
$$;

-- Returns the number removed; 0 on a session with no marks so a repeated reset is harmless.
create or replace function public.reset_session_attendance(p_session_id uuid)
returns integer
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_removed integer;
begin
  if not private.is_staff() then
    perform private.fail('BXPRM', 'Only club staff can do this');
  end if;

  perform 1 from public.sessions where id = p_session_id for key share;
  if not found then
    perform private.fail('BXNTF', 'Session not found');
  end if;

  delete from public.attendance
  where session_id = p_session_id;

  get diagnostics v_removed = row_count;
  return v_removed;
end;
$$;

revoke execute on function public.unmark_attendance(uuid, uuid) from public, anon;
revoke execute on function public.reset_session_attendance(uuid) from public, anon;
grant execute on function public.unmark_attendance(uuid, uuid) to authenticated;
grant execute on function public.reset_session_attendance(uuid) to authenticated;
